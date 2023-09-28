REQS=$(wildcard *.conf)
CRTS=$(REQS:.conf=.pfx)

.SECONDARY: $(REQS:.conf=.pass) $(REQS:.conf=.csr) $(REQS:.conf=.crt) $(REQS:.conf=.key)

all: ca.crt $(CRTS)

%.key:
	openssl genrsa -out $@ 4096
#	openssl genpkey -algorithm ED25519 -out $@
#	openssl ecparam -genkey -name prime256v1 -out $@

%.pass:
	openssl rand -out $@ -base64 12

ca.crt: ca.key ca.cfg
	openssl req -new -x509 -key ca.key -noenc -days 3650 -out ca.crt -config ca.cfg

%.csr: %.key %.conf
	openssl req -new -out $@ -key $*.key -config $*.conf

%.crt: ca.crt %.conf %.key %.csr
	openssl x509 -req -in $*.csr -CA ca.crt -CAkey ca.key -CAcreateserial -CAserial ca.srl -days 398 -copy_extensions copy -out $@

%.pfx: %.crt %.key %.pass
	openssl pkcs12 -legacy -export -out $*.pfx -inkey $*.key -in $*.crt -password file:$*.pass
