Received: from lacrosse.redhat.com (root@lacrosse.redhat.com [207.175.42.154])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA06985
	for <linux-mm@kvack.org>; Mon, 5 Apr 1999 22:15:33 -0400
Message-ID: <37096E02.C9E53CE2@redhat.com>
Date: Mon, 05 Apr 1999 22:14:26 -0400
From: Doug Ledford <dledford@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] arca-vm-2.2.5
References: <Pine.LNX.4.05.9904060128120.447-100000@laser.random>
Content-Type: multipart/mixed;
 boundary="------------892F0747B97E6C780945C500"
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------892F0747B97E6C780945C500
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Andrea Arcangeli wrote:
> 
> On Mon, 5 Apr 1999, Chuck Lever wrote:
> 
> >buckets out of 32K buckets have hundreds of buffers).  i have a new hash
> >function that works very well, and even helps inter-run variance and
> >perceived interactive response.  i'll post more on this soon.
> 
> Cool! ;)) But could you tell me _how_ do you design an hash function? Are
> you doing math or do you use instinct? I never gone into the details of
> benchmarking or designing an hash function simply because I don't like
> fuzzy hash and instead I want to replace them with RB-trees all over the
> place (and I know the math about RB-trees), but I like to learn how to
> design an hash function anyway (even if I don't want to discover that
> myself without reading docs as usual ;).
> 
> >but also the page hash function uses the hash table size as a shift value
> >when computing the index, so it may combine the interesting bits in a
> >different (worse) way when you change the hash table size.  i'm planning
> >to instrument the page hash to see exactly what's going on.
> 
> Agreed. This is true. I thought about that and I am resizing the hash
> table size to the original 11 bit now (since you are confirming that I
> broken the hash function).
> 
> >IMHO, i'd think if the buffer cache has a large hash table, you'd want the
> >page cache to have a table as large or larger.  both track roughly the
> >same number of objects...  and the page cache is probably used more often
> 
> Agreed.

Hmmm...I've talked about this a few times to Alan Cox and Stephen
Tweedie.  I didn't bother to instrument the hash function because in
this case I knew it was tuned to the size of the inode structs.  But, I
did implement a variable sized page cache hash table array.  I did this
because at 512MB of RAM, having only 2048 hash buckets (11 bits) became
a real bottleneck in page cache hash entry lookups.  Essentially, when
the number of physical pages per hash buckets gets too large, then hash
chains can grow excessively long and take entirely too long to look up
when the page is not in the page cache (or when it is but it's at the
end of a long chain).  Since these lookups occur as frequently as they
do, they get to be excessive quickly.  I'm attaching the patch I've been
using here for a while.  Feel free to try it out.  One of the best tests
for the effect of this patch is a bonnie run on a machine with more disk
speed than CPU power.  In that case the page cache lookup becomes a
bottleneck.  In other conditions, you see the same disk speed results
but with smaller % CPU utilization.  On a PII400 dual machine with 512MB
RAM and a 4 Cheetah RAID0 array it made a 10MByte/s difference in
throughput.  On another machine it made a roughly 6 to 8% difference in
CPU utilization.


-- 
  Doug Ledford   <dledford@redhat.com>
   Opinions expressed are my own, but
      they should be everybody's.
--------------892F0747B97E6C780945C500
Content-Type: application/octet-stream;
 name="page-2.2.2.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="page-2.2.2.patch"

LS0tIGxpbnV4L2luY2x1ZGUvbGludXgvcGFnZW1hcC5oLnBhZ2UJVGh1IEphbiAyOCAxNzo0
MzoxNyAxOTk5CisrKyBsaW51eC9pbmNsdWRlL2xpbnV4L3BhZ2VtYXAuaAlNb24gTWFyICA4
IDA3OjM3OjU0IDE5OTkKQEAgLTE3LDEzICsxNywxMyBAQAogCXJldHVybiBQQUdFX09GRlNF
VCArIFBBR0VfU0laRSAqIChwYWdlIC0gbWVtX21hcCk7CiB9CiAKLSNkZWZpbmUgUEFHRV9I
QVNIX0JJVFMgMTEKLSNkZWZpbmUgUEFHRV9IQVNIX1NJWkUgKDEgPDwgUEFHRV9IQVNIX0JJ
VFMpCi0KICNkZWZpbmUgUEFHRV9BR0VfVkFMVUUgMTYKLQogZXh0ZXJuIHVuc2lnbmVkIGxv
bmcgcGFnZV9jYWNoZV9zaXplOyAvKiAjIG9mIHBhZ2VzIGN1cnJlbnRseSBpbiB0aGUgaGFz
aCB0YWJsZSAqLwotZXh0ZXJuIHN0cnVjdCBwYWdlICogcGFnZV9oYXNoX3RhYmxlW1BBR0Vf
SEFTSF9TSVpFXTsKK2V4dGVybiBzdHJ1Y3QgcGFnZSAqKiBwYWdlX2hhc2hfdGFibGU7Citl
eHRlcm4gdW5zaWduZWQgbG9uZyBwYWdlX2hhc2hfc2l6ZTsKK2V4dGVybiB1bnNpZ25lZCBs
b25nIHBhZ2VfaGFzaF9tYXNrOworZXh0ZXJuIHVuc2lnbmVkIGxvbmcgcGFnZV9oYXNoX2Jp
dHM7CitleHRlcm4gbG9uZyBwYWdlX2NhY2hlX2luaXQobG9uZywgbG9uZyk7CiAKIC8qCiAg
KiBXZSB1c2UgYSBwb3dlci1vZi10d28gaGFzaCB0YWJsZSB0byBhdm9pZCBhIG1vZHVsdXMs
CkBAIC0zNSw4ICszNSw4IEBACiB7CiAjZGVmaW5lIGkgKCgodW5zaWduZWQgbG9uZykgaW5v
ZGUpLyhzaXplb2Yoc3RydWN0IGlub2RlKSAmIH4gKHNpemVvZihzdHJ1Y3QgaW5vZGUpIC0g
MSkpKQogI2RlZmluZSBvIChvZmZzZXQgPj4gUEFHRV9TSElGVCkKLSNkZWZpbmUgcyh4KSAo
KHgpKygoeCk+PlBBR0VfSEFTSF9CSVRTKSkKLQlyZXR1cm4gcyhpK28pICYgKFBBR0VfSEFT
SF9TSVpFLTEpOworI2RlZmluZSBzKHgpICgoeCkrKCh4KT4+cGFnZV9oYXNoX2JpdHMpKQor
CXJldHVybiBzKGkrbykgJiBwYWdlX2hhc2hfbWFzazsKICN1bmRlZiBpCiAjdW5kZWYgbwog
I3VuZGVmIHMKLS0tIGxpbnV4L2luaXQvbWFpbi5jLnBhZ2UJTW9uIEZlYiAyMiAyMjo0NDo1
MyAxOTk5CisrKyBsaW51eC9pbml0L21haW4uYwlNb24gTWFyICA4IDA3OjM3OjU0IDE5OTkK
QEAgLTE5LDYgKzE5LDcgQEAKICNpbmNsdWRlIDxsaW51eC91dHNuYW1lLmg+CiAjaW5jbHVk
ZSA8bGludXgvaW9wb3J0Lmg+CiAjaW5jbHVkZSA8bGludXgvaW5pdC5oPgorI2luY2x1ZGUg
PGxpbnV4L3BhZ2VtYXAuaD4KICNpbmNsdWRlIDxsaW51eC9zbXBfbG9jay5oPgogI2luY2x1
ZGUgPGxpbnV4L2Jsay5oPgogI2luY2x1ZGUgPGxpbnV4L2hkcmVnLmg+CkBAIC0xMTQ5LDYg
KzExNTAsNyBAQAogCQlpbml0cmRfc3RhcnQgPSAwOwogCX0KICNlbmRpZgorCW1lbW9yeV9z
dGFydCA9IHBhZ2VfY2FjaGVfaW5pdChtZW1vcnlfc3RhcnQsIG1lbW9yeV9lbmQpOwogCW1l
bV9pbml0KG1lbW9yeV9zdGFydCxtZW1vcnlfZW5kKTsKIAlrbWVtX2NhY2hlX3NpemVzX2lu
aXQoKTsKICNpZmRlZiBDT05GSUdfUFJPQ19GUwotLS0gbGludXgvbW0vZmlsZW1hcC5jLnBh
Z2UJTW9uIEZlYiAyMiAyMjo0NDo1MyAxOTk5CisrKyBsaW51eC9tbS9maWxlbWFwLmMJTW9u
IE1hciAgOCAwNzozNzo1NCAxOTk5CkBAIC0xMyw2ICsxMyw3IEBACiAjaW5jbHVkZSA8bGlu
dXgvc2htLmg+CiAjaW5jbHVkZSA8bGludXgvbW1hbi5oPgogI2luY2x1ZGUgPGxpbnV4L2xv
Y2tzLmg+CisjaW5jbHVkZSA8bGludXgvaW5pdC5oPgogI2luY2x1ZGUgPGxpbnV4L3BhZ2Vt
YXAuaD4KICNpbmNsdWRlIDxsaW51eC9zd2FwLmg+CiAjaW5jbHVkZSA8bGludXgvc21wX2xv
Y2suaD4KQEAgLTIzLDYgKzI0LDcgQEAKIAogI2luY2x1ZGUgPGFzbS9wZ3RhYmxlLmg+CiAj
aW5jbHVkZSA8YXNtL3VhY2Nlc3MuaD4KKyNpbmNsdWRlIDxhc20vaW8uaD4KIAogLyoKICAq
IFNoYXJlZCBtYXBwaW5ncyBpbXBsZW1lbnRlZCAzMC4xMS4xOTk0LiBJdCdzIG5vdCBmdWxs
eSB3b3JraW5nIHlldCwKQEAgLTMyLDcgKzM0LDQ1IEBACiAgKi8KIAogdW5zaWduZWQgbG9u
ZyBwYWdlX2NhY2hlX3NpemUgPSAwOwotc3RydWN0IHBhZ2UgKiBwYWdlX2hhc2hfdGFibGVb
UEFHRV9IQVNIX1NJWkVdOwordW5zaWduZWQgbG9uZyBwYWdlX2hhc2hfc2l6ZSA9IDA7Cit1
bnNpZ25lZCBsb25nIHBhZ2VfaGFzaF9iaXRzID0gMDsKK3Vuc2lnbmVkIGxvbmcgcGFnZV9o
YXNoX21hc2sgPSAwOworc3RydWN0IHBhZ2UgKiogcGFnZV9oYXNoX3RhYmxlID0gTlVMTDsK
KworLyoKKyAqIFRoZSBpbml0IGZ1bmN0aW9uIHRoYXQgc3RhcnRzIG9mZiBvdXIgcGFnZSBj
YWNoZQorICovCitsb25nIF9faW5pdCBwYWdlX2NhY2hlX2luaXQoIGxvbmcgbWVtX2JlZ2lu
LCBsb25nIG1lbV9lbmQgKQoreworCWxvbmcgY2FjaGVfYmVnaW47CisJbG9uZyBpOworCisJ
Zm9yKGk9MDsgaSA8IHNpemVvZihsb25nKSAqIDg7IGkrKykKKwkJaWYodmlydF90b19waHlz
KCh2b2lkICopbWVtX2VuZCkgJiAoMTw8aSkpCisJCQlwYWdlX2hhc2hfYml0cyA9IGk7CisJ
cGFnZV9oYXNoX2JpdHMgLT0gKFBBR0VfU0hJRlQgKyAyKTsKKwlpZihwYWdlX2hhc2hfYml0
cyA8IDEwKQorCQlwYWdlX2hhc2hfYml0cyA9IDEwOworCWNhY2hlX2JlZ2luID0gKG1lbV9i
ZWdpbiArIChQQUdFX1NJWkUgLSAxKSkgJiB+UEFHRV9TSVpFOworCXBhZ2VfaGFzaF9zaXpl
ID0gMSA8PCBwYWdlX2hhc2hfYml0czsKKwlwYWdlX2hhc2hfbWFzayA9IHBhZ2VfaGFzaF9z
aXplIC0gMTsKKwlpZiAoICgodmlydF90b19waHlzKCh2b2lkICopY2FjaGVfYmVnaW4pIDw9
IDB4ZmZmZmYpICYmIAorCSAgICAgICh2aXJ0X3RvX3BoeXMoKHZvaWQgKiljYWNoZV9iZWdp
bikgPj0gKDB4OWYwMDAgLSBwYWdlX2hhc2hfc2l6ZSkpKSApCisJeworCQkvKgorCQkgKiBP
dXIgc3RydWN0dXJlIHdvdWxkIGZhbGwgaW50byB0aGUgbWlkZGxlIG9mIHRoZSB1cHBlciAK
KwkJICogQklPUyBhcmVhIG9mIHRoZSBjb21wdXRlciwgZ28gYWJvdmUgaXQgdG8gdGhlIDFN
QiBtYXJrCisJCSAqIGFuZCBzdGFydCBmcm9tIHRoZXJlCisJCSAqLworCQljYWNoZV9iZWdp
biA9IChsb25nKXBoeXNfdG9fdmlydCgweDEwMDAwMCk7CisJfQorCXBhZ2VfaGFzaF90YWJs
ZSA9IChzdHJ1Y3QgcGFnZSAqKiljYWNoZV9iZWdpbjsKKwltZW1zZXQocGFnZV9oYXNoX3Rh
YmxlLCAwLCBwYWdlX2hhc2hfc2l6ZSAqIHNpemVvZih2b2lkKSk7CisJcHJpbnRrKEtFUk5f
SU5GTyAicGFnZV9jYWNoZV9pbml0OiBhbGxvY2F0ZWQgJWxkayBvZiBSQU0gd2l0aCAlbGQg
aGFzaCAiCisJCSJidWNrZXRzLlxuIiwgKHBhZ2VfaGFzaF9zaXplICogc2l6ZW9mKHZvaWQg
KikpIC8gMTAyNCwKKwkJcGFnZV9oYXNoX3NpemUpOworCXJldHVybihjYWNoZV9iZWdpbiAr
IChwYWdlX2hhc2hfc2l6ZSAqIHNpemVvZih2b2lkICopKSk7Cit9CiAKIC8qCiAgKiBTaW1w
bGUgcm91dGluZXMgZm9yIGJvdGggbm9uLXNoYXJlZCBhbmQgc2hhcmVkIG1hcHBpbmdzLgo=
--------------892F0747B97E6C780945C500--

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
