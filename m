Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0CE3D6B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 06:13:45 -0400 (EDT)
Date: Mon, 12 Oct 2009 19:13:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] munmap() don't check sysctl_max_mapcount
In-Reply-To: <Pine.LNX.4.64.0910091007010.17240@sister.anvils>
References: <20091002180533.5F77.A69D9226@jp.fujitsu.com> <Pine.LNX.4.64.0910091007010.17240@sister.anvils>
Message-Id: <20091012184654.E4D0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="------_4AD2FB0E00000000E504_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--------_4AD2FB0E00000000E504_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Hi Hugh

> > Hi everyone,
> > 
> > Is this good idea?
> 
> Sorry, I overlooked this earlier.
> 
> Correct me if I'm wrong, but from the look of your patch,
> I believe anyone could increase their mapcount arbitrarily far beyond
> sysctl_max_map_count, just by taking little bites out of a large mmap.
> 
> In which case there's not much point in having sysctl_max_map_count
> at all.  Perhaps there isn't much point to it anyway, and the answer
> is just to raise it to where it catches runaways but interferes with
> nobody else?
> 
> If you change your patch so that do_munmap() cannot increase the final
> number vmas beyond sysctl_max_map_count, that would seem reasonable.
> But would that satisfy your testcase?  And does the testcase really
> matter in practice?  It doesn't seem to have upset anyone before.

Very thank you for payed attention to my patch. Yes, this is real issue.
my customer suffer from it.

May I explain why you haven't seen this issue? this issue is architecture
independent problem. however register stack architecture (e.g. ia64, sparc)
dramatically increase the possibility of the heppen this issue.

Why? the stack of the typical architecture have one PROT_READ|PROT_WRITE area and one
PROT_NONE area (it is called as guard page).
if the process multiple thread, stack layout is

fig1)
  +--------+--------+-------+-------+--------------
  | thr-0  | thr-0  | thr-1 | thr-1 | 
  | guard  | stack  | guard | stack | ......
  +--------+--------+-------+-------+-------------

Thus, stack freeing didn't make vma splitting. in the other hand,
the stack of the register stack architecture have two PROT_READ|PROT_WRITE
area and one PROT_NONE area.
then, stack layout is

fig2)
  +-----------+--------+------------------+-------+------------------+-----------
  | thr-0     | thr-0  | thr-0 stack      | thr-1 | thr-1 stack      | thr-2 
  | reg-stack | guard  | + thr-1 regstack | guard | + thr-2 regstack | guard
  +-----------+--------+------------------+-------+------------------+-----------

Then, stack unmapping may cause vma splitting.

However, non-register stack architecture don't free from this issue.
if the program use malloc(), it can makes fig2 layout. please run attached
test program (test_max_mapcount_for_86.c), it should addressed the problem.


And, I doubt I haven't catch your mention. May I ask some question?
Honestly I don't think max_map_count is important knob. it is strange
mutant of limit of virtual address space in the process.
At very long time ago (probably the stone age), linux doesn't have
vma rb_tree handling, then many vma directly cause find_vma slow down.
However current linux have good scalability. it can handle many vma issue.
So, Why do you think max_mapcount sould be strictly keeped?

Honestly, I doubt nobody suffer from removing sysctl_max_mapcount.


And yes, stack unmapping have exceptional charactatics. the guard zone
gurantee it never raise map_count. 
So, I think the attached patch (0001-Don-t...) is the same as you talked about, right?
I can accept it. I haven't test it on ia64. however, at least it works
well on x86.


BUT, I still think kernel souldn't refuse any resource deallocation.
otherwise, people discourage proper resource deallocation and encourage
brutal intentional memory leak programming style. What do you think?


--------_4AD2FB0E00000000E504_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="test_max_mapcount_for_86.c"
Content-Disposition: attachment;
 filename="test_max_mapcount_for_86.c"
Content-Transfer-Encoding: base64

ICAjaW5jbHVkZTxzdGRpby5oPg0KICAjaW5jbHVkZTxzdGRsaWIuaD4NCiAgI2luY2x1ZGU8c3Ry
aW5nLmg+DQogICNpbmNsdWRlPHB0aHJlYWQuaD4NCiAgI2luY2x1ZGU8ZXJybm8uaD4NCiAgI2lu
Y2x1ZGU8dW5pc3RkLmg+DQogDQogICNkZWZpbmUgVEhSRUFEX05VTSAzMDAwMA0KICAjZGVmaW5l
IE1BTF9TSVpFICg4KjEwMjQqMTAyNCkNCiANCiB2b2lkICp3YWl0X3RocmVhZCh2b2lkICphcmdz
KQ0KIHsNCiAJdm9pZCAqYWRkcjsNCiANCiAJYWRkciA9IG1hbGxvYyhNQUxfU0laRSk7DQoNCiNp
ZiAwDQogCWlmKGFkZHIpDQogCQltZW1zZXQoYWRkciwgMSwgTUFMX1NJWkUpOw0KI2VuZGlmDQog
CXNsZWVwKDEwKTsNCiANCiAJcmV0dXJuIE5VTEw7DQogfQ0KIA0KIHZvaWQgKndhaXRfdGhyZWFk
Mih2b2lkICphcmdzKQ0KIHsNCiAJc2xlZXAoNjApOw0KIA0KIAlyZXR1cm4gTlVMTDsNCiB9DQog
DQogaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkNCiB7DQogCWludCBpOw0KIAlwdGhy
ZWFkX3QgdGhyZWFkW1RIUkVBRF9OVU1dLCB0aDsNCiAJaW50IHJldCwgY291bnQgPSAwOw0KIAlw
dGhyZWFkX2F0dHJfdCBhdHRyOw0KIA0KIAlyZXQgPSBwdGhyZWFkX2F0dHJfaW5pdCgmYXR0cik7
DQogCWlmKHJldCkgew0KIAkJcGVycm9yKCJwdGhyZWFkX2F0dHJfaW5pdCIpOw0KIAl9DQogDQog
CXJldCA9IHB0aHJlYWRfYXR0cl9zZXRkZXRhY2hzdGF0ZSgmYXR0ciwgUFRIUkVBRF9DUkVBVEVf
REVUQUNIRUQpOw0KIAlpZihyZXQpIHsNCiAJCXBlcnJvcigicHRocmVhZF9hdHRyX3NldGRldGFj
aHN0YXRlIik7DQogCX0NCiANCiAJZm9yIChpID0gMDsgaSA8IFRIUkVBRF9OVU07IGkrKykgew0K
IAkJcmV0ID0gcHRocmVhZF9jcmVhdGUoJnRoLCAmYXR0ciwgd2FpdF90aHJlYWQsIE5VTEwpOw0K
IAkJaWYocmV0KSB7DQogCQkJZnByaW50ZihzdGRlcnIsICJbJWRdICIsIGNvdW50KTsNCiAJCQlw
ZXJyb3IoInB0aHJlYWRfY3JlYXRlIik7DQogCQl9IGVsc2Ugew0KIAkJCXByaW50ZigiWyVkXSBj
cmVhdGUgT0suXG4iLCBjb3VudCk7DQogCQl9DQogCQljb3VudCsrOw0KIA0KIAkJcmV0ID0gcHRo
cmVhZF9jcmVhdGUoJnRocmVhZFtpXSwgJmF0dHIsIHdhaXRfdGhyZWFkMiwgTlVMTCk7DQogCQlp
ZihyZXQpIHsNCiAJCQlmcHJpbnRmKHN0ZGVyciwgIlslZF0gIiwgY291bnQpOw0KIAkJCXBlcnJv
cigicHRocmVhZF9jcmVhdGUiKTsNCiAJCX0gZWxzZSB7DQogCQkJcHJpbnRmKCJbJWRdIGNyZWF0
ZSBPSy5cbiIsIGNvdW50KTsNCiAJCX0NCiAJCWNvdW50Kys7DQogCX0NCiANCiAJc2xlZXAoMzYw
MCk7DQogCXJldHVybiAwOw0KIH0NCg==
--------_4AD2FB0E00000000E504_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="0001-Don-t-make-ENOMEM-temporary-mapcount-exceeding-in-mu.patch"
Content-Disposition: attachment;
 filename="0001-Don-t-make-ENOMEM-temporary-mapcount-exceeding-in-mu.patch"
Content-Transfer-Encoding: base64

RnJvbSBjNzdmZDExZjU3OWRjNDk3YjY5MjUwMWZjYThhMTJhZDhhOTQzYTIwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBLT1NBS0kgTW90b2hpcm8gPGtvc2FraS5tb3RvaGlyb0BqcC5m
dWppdHN1LmNvbT4KRGF0ZTogTW9uLCAxMiBPY3QgMjAwOSAxODozNDoyMCArMDkwMApTdWJqZWN0
OiBbUEFUQ0hdIERvbid0IG1ha2UgRU5PTUVNIHRlbXBvcmFyeSBtYXBjb3VudCBleGNlZWRpbmcg
aW4gbXVubWFwKCkKCk9uIGlhNjQsIHRoZSBmb2xsb3dpbmcgdGVzdCBwcm9ncmFtIGV4aXQgYWJu
b3JtYWxseSwgYmVjYXVzZQpnbGliYyB0aHJlYWQgbGlicmFyeSBjYWxsZWQgYWJvcnQoKS4KCiA9
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQog
KGdkYikgYnQKICMwICAweGEwMDAwMDAwMDAwMTA2MjAgaW4gX19rZXJuZWxfc3lzY2FsbF92aWFf
YnJlYWsgKCkKICMxICAweDIwMDAwMDAwMDAzMjA4ZTAgaW4gcmFpc2UgKCkgZnJvbSAvbGliL2xp
YmMuc28uNi4xCiAjMiAgMHgyMDAwMDAwMDAwMzI0MDkwIGluIGFib3J0ICgpIGZyb20gL2xpYi9s
aWJjLnNvLjYuMQogIzMgIDB4MjAwMDAwMDAwMDI3YzNlMCBpbiBfX2RlYWxsb2NhdGVfc3RhY2sg
KCkgZnJvbSAvbGliL2xpYnB0aHJlYWQuc28uMAogIzQgIDB4MjAwMDAwMDAwMDI3ZjdjMCBpbiBz
dGFydF90aHJlYWQgKCkgZnJvbSAvbGliL2xpYnB0aHJlYWQuc28uMAogIzUgIDB4MjAwMDAwMDAw
MDQ3ZWY2MCBpbiBfX2Nsb25lMiAoKSBmcm9tIC9saWIvbGliYy5zby42LjEKID09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09CgpUaGUgZmFjdCBp
cywgZ2xpYmMgY2FsbCBtdW5tYXAoKSB3aGVuIHRocmVhZCBleGl0bmcgdGltZSBmb3IgZnJlZWlu
ZyBzdGFjaywgYW5kCml0IGFzc3VtZSBtdW5sb2NrKCkgbmV2ZXIgZmFpbC4gSG93ZXZlciwgbXVu
bWFwKCkgb2Z0ZW4gbWFrZSB2bWEgc3BsaXR0aW5nCmFuZCBpdCB3aXRoIG1hbnkgbWFwY291bnQg
bWFrZSAtRU5PTUVNLgoKT2ggd2VsbCwgdGhhdCdzIGNyYXp5LCBiZWNhdXNlIHN0YWNrIHVubWFw
cGluZyBuZXZlciBpbmNyZWFzZSBtYXBjb3VudC4KVGhlIG1heGNvdW50IGV4Y2VlZGluZyBpcyBv
bmx5IHRlbXBvcmFyeS4gaW50ZXJuYWwgdGVtcG9yYXJ5IGV4Y2VlZGluZwpzaG91bGRuJ3QgbWFr
ZSBFTk9NRU0uCgpUaGlzIHBhdGNoIGRvZXMgaXQuCgogdGVzdF9tYXhfbWFwY291bnQuYwogPT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09CiAgI2luY2x1ZGU8c3RkaW8uaD4KICAjaW5jbHVkZTxzdGRsaWIuaD4KICAjaW5jbHVk
ZTxzdHJpbmcuaD4KICAjaW5jbHVkZTxwdGhyZWFkLmg+CiAgI2luY2x1ZGU8ZXJybm8uaD4KICAj
aW5jbHVkZTx1bmlzdGQuaD4KCiAgI2RlZmluZSBUSFJFQURfTlVNIDMwMDAwCiAgI2RlZmluZSBN
QUxfU0laRSAoOCoxMDI0KjEwMjQpCgogdm9pZCAqd2FpdF90aHJlYWQodm9pZCAqYXJncykKIHsK
IAl2b2lkICphZGRyOwoKIAlhZGRyID0gbWFsbG9jKE1BTF9TSVpFKTsKIAlzbGVlcCgxMCk7Cgog
CXJldHVybiBOVUxMOwogfQoKIHZvaWQgKndhaXRfdGhyZWFkMih2b2lkICphcmdzKQogewogCXNs
ZWVwKDYwKTsKCiAJcmV0dXJuIE5VTEw7CiB9CgogaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKmFy
Z3ZbXSkKIHsKIAlpbnQgaTsKIAlwdGhyZWFkX3QgdGhyZWFkW1RIUkVBRF9OVU1dLCB0aDsKIAlp
bnQgcmV0LCBjb3VudCA9IDA7CiAJcHRocmVhZF9hdHRyX3QgYXR0cjsKCiAJcmV0ID0gcHRocmVh
ZF9hdHRyX2luaXQoJmF0dHIpOwogCWlmKHJldCkgewogCQlwZXJyb3IoInB0aHJlYWRfYXR0cl9p
bml0Iik7CiAJfQoKIAlyZXQgPSBwdGhyZWFkX2F0dHJfc2V0ZGV0YWNoc3RhdGUoJmF0dHIsIFBU
SFJFQURfQ1JFQVRFX0RFVEFDSEVEKTsKIAlpZihyZXQpIHsKIAkJcGVycm9yKCJwdGhyZWFkX2F0
dHJfc2V0ZGV0YWNoc3RhdGUiKTsKIAl9CgogCWZvciAoaSA9IDA7IGkgPCBUSFJFQURfTlVNOyBp
KyspIHsKIAkJcmV0ID0gcHRocmVhZF9jcmVhdGUoJnRoLCAmYXR0ciwgd2FpdF90aHJlYWQsIE5V
TEwpOwogCQlpZihyZXQpIHsKIAkJCWZwcmludGYoc3RkZXJyLCAiWyVkXSAiLCBjb3VudCk7CiAJ
CQlwZXJyb3IoInB0aHJlYWRfY3JlYXRlIik7CiAJCX0gZWxzZSB7CiAJCQlwcmludGYoIlslZF0g
Y3JlYXRlIE9LLlxuIiwgY291bnQpOwogCQl9CiAJCWNvdW50Kys7CgogCQlyZXQgPSBwdGhyZWFk
X2NyZWF0ZSgmdGhyZWFkW2ldLCAmYXR0ciwgd2FpdF90aHJlYWQyLCBOVUxMKTsKIAkJaWYocmV0
KSB7CiAJCQlmcHJpbnRmKHN0ZGVyciwgIlslZF0gIiwgY291bnQpOwogCQkJcGVycm9yKCJwdGhy
ZWFkX2NyZWF0ZSIpOwogCQl9IGVsc2UgewogCQkJcHJpbnRmKCJbJWRdIGNyZWF0ZSBPSy5cbiIs
IGNvdW50KTsKIAkJfQogCQljb3VudCsrOwogCX0KCiAJc2xlZXAoMzYwMCk7CiAJcmV0dXJuIDA7
CiB9CiA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT0KClNpZ25lZC1vZmYtYnk6IEtPU0FLSSBNb3RvaGlybyA8a29zYWtpLm1v
dG9oaXJvQGpwLmZ1aml0c3UuY29tPgotLS0KIG1tL21tYXAuYyB8ICAgMzggKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrLS0tLS0tLS0KIDEgZmlsZXMgY2hhbmdlZCwgMzAgaW5zZXJ0aW9u
cygrKSwgOCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9tbWFwLmMgYi9tbS9tbWFwLmMK
aW5kZXggODY1ODMwZC4uNDFhYjU3NiAxMDA2NDQKLS0tIGEvbW0vbW1hcC5jCisrKyBiL21tL21t
YXAuYwpAQCAtMTgzMCwxMCArMTgzMCwxMCBAQCBkZXRhY2hfdm1hc190b19iZV91bm1hcHBlZChz
dHJ1Y3QgbW1fc3RydWN0ICptbSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsCiB9CiAKIC8q
Ci0gKiBTcGxpdCBhIHZtYSBpbnRvIHR3byBwaWVjZXMgYXQgYWRkcmVzcyAnYWRkcicsIGEgbmV3
IHZtYSBpcyBhbGxvY2F0ZWQKLSAqIGVpdGhlciBmb3IgdGhlIGZpcnN0IHBhcnQgb3IgdGhlIHRh
aWwuCisgKiBfX3NwbGl0X3ZtYSgpIGJ5cGFzc2VzIHN5c2N0bF9tYXhfbWFwX2NvdW50IGNoZWNr
aW5nLiAgV2UgdXNlIHRoaXMgb24gdGhlCisgKiBtdW5tYXAgcGF0aCB3aGVyZSBpdCBkb2Vzbid0
IG1ha2Ugc2Vuc2UgdG8gZmFpbC4KICAqLwotaW50IHNwbGl0X3ZtYShzdHJ1Y3QgbW1fc3RydWN0
ICogbW0sIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqIHZtYSwKK3N0YXRpYyBpbnQgX19zcGxpdF92
bWEoc3RydWN0IG1tX3N0cnVjdCAqIG1tLCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKiB2bWEsCiAJ
ICAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCBpbnQgbmV3X2JlbG93KQogewogCXN0cnVjdCBtZW1w
b2xpY3kgKnBvbDsKQEAgLTE4NDMsOSArMTg0Myw2IEBAIGludCBzcGxpdF92bWEoc3RydWN0IG1t
X3N0cnVjdCAqIG1tLCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKiB2bWEsCiAJCQkJCX4oaHVnZV9w
YWdlX21hc2soaHN0YXRlX3ZtYSh2bWEpKSkpKQogCQlyZXR1cm4gLUVJTlZBTDsKIAotCWlmICht
bS0+bWFwX2NvdW50ID49IHN5c2N0bF9tYXhfbWFwX2NvdW50KQotCQlyZXR1cm4gLUVOT01FTTsK
LQogCW5ldyA9IGttZW1fY2FjaGVfYWxsb2Modm1fYXJlYV9jYWNoZXAsIEdGUF9LRVJORUwpOwog
CWlmICghbmV3KQogCQlyZXR1cm4gLUVOT01FTTsKQEAgLTE4ODUsNiArMTg4MiwxOSBAQCBpbnQg
c3BsaXRfdm1hKHN0cnVjdCBtbV9zdHJ1Y3QgKiBtbSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICog
dm1hLAogCXJldHVybiAwOwogfQogCisvKgorICogU3BsaXQgYSB2bWEgaW50byB0d28gcGllY2Vz
IGF0IGFkZHJlc3MgJ2FkZHInLCBhIG5ldyB2bWEgaXMgYWxsb2NhdGVkCisgKiBlaXRoZXIgZm9y
IHRoZSBmaXJzdCBwYXJ0IG9yIHRoZSB0YWlsLgorICovCitpbnQgc3BsaXRfdm1hKHN0cnVjdCBt
bV9zdHJ1Y3QgKiBtbSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICogdm1hLAorCSAgICAgIHVuc2ln
bmVkIGxvbmcgYWRkciwgaW50IG5ld19iZWxvdykKK3sKKwlpZiAobW0tPm1hcF9jb3VudCA+PSBz
eXNjdGxfbWF4X21hcF9jb3VudCkKKwkJcmV0dXJuIC1FTk9NRU07CisKKwlyZXR1cm4gX19zcGxp
dF92bWEobW0sIHZtYSwgYWRkciwgbmV3X2JlbG93KTsKK30KKwogLyogTXVubWFwIGlzIHNwbGl0
IGludG8gMiBtYWluIHBhcnRzIC0tIHRoaXMgcGFydCB3aGljaCBmaW5kcwogICogd2hhdCBuZWVk
cyBkb2luZywgYW5kIHRoZSBhcmVhcyB0aGVtc2VsdmVzLCB3aGljaCBkbyB0aGUKICAqIHdvcmsu
ICBUaGlzIG5vdyBoYW5kbGVzIHBhcnRpYWwgdW5tYXBwaW5ncy4KQEAgLTE5MjAsNyArMTkzMCwx
OSBAQCBpbnQgZG9fbXVubWFwKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCB1bnNpZ25lZCBsb25nIHN0
YXJ0LCBzaXplX3QgbGVuKQogCSAqIHBsYWNlcyB0bXAgdm1hIGFib3ZlLCBhbmQgaGlnaGVyIHNw
bGl0X3ZtYSBwbGFjZXMgdG1wIHZtYSBiZWxvdy4KIAkgKi8KIAlpZiAoc3RhcnQgPiB2bWEtPnZt
X3N0YXJ0KSB7Ci0JCWludCBlcnJvciA9IHNwbGl0X3ZtYShtbSwgdm1hLCBzdGFydCwgMCk7CisJ
CWludCBlcnJvcjsKKworCQkvKgorCQkgKiBJZiB2bWEgbmVlZCB0byBzcGxpdCBib3RoIGhlYWQg
YW5kIHRhaWwgb2YgdGhlIHZtYSwKKwkJICogbWFwY291bnQgY2FuIGV4Y2VlZCBtYXhfbWFwY291
bnQuIE90aGVyd2lzZSwgdGhlCisJCSAqIGV4Y2VlZGluZyBpcyB0bXBvcmFyeS4gbGF0ZXIgZGV0
YWNoX3ZtYXNfdG9fYmVfdW5tYXBwZWQoKQorCQkgKiBkZWNyZW1lbnQgbWFwY291bnQgbGVzcyB0
aGFuIG1heF9tYXBjb3VudC4gd2UgZG9uJ3QgbmVlZAorCQkgKiB0byBjYXJlIGl0LgorCQkgKi8K
KwkJaWYgKGVuZCA8IHZtYS0+dm1fZW5kICYmIG1tLT5tYXBfY291bnQgPj0gc3lzY3RsX21heF9t
YXBfY291bnQpCisJCQlyZXR1cm4gLUVOT01FTTsKKworCQllcnJvciA9IF9fc3BsaXRfdm1hKG1t
LCB2bWEsIHN0YXJ0LCAwKTsKIAkJaWYgKGVycm9yKQogCQkJcmV0dXJuIGVycm9yOwogCQlwcmV2
ID0gdm1hOwpAQCAtMTkyOSw3ICsxOTUxLDcgQEAgaW50IGRvX211bm1hcChzdHJ1Y3QgbW1fc3Ry
dWN0ICptbSwgdW5zaWduZWQgbG9uZyBzdGFydCwgc2l6ZV90IGxlbikKIAkvKiBEb2VzIGl0IHNw
bGl0IHRoZSBsYXN0IG9uZT8gKi8KIAlsYXN0ID0gZmluZF92bWEobW0sIGVuZCk7CiAJaWYgKGxh
c3QgJiYgZW5kID4gbGFzdC0+dm1fc3RhcnQpIHsKLQkJaW50IGVycm9yID0gc3BsaXRfdm1hKG1t
LCBsYXN0LCBlbmQsIDEpOworCQlpbnQgZXJyb3IgPSBfX3NwbGl0X3ZtYShtbSwgbGFzdCwgZW5k
LCAxKTsKIAkJaWYgKGVycm9yKQogCQkJcmV0dXJuIGVycm9yOwogCX0KLS0gCjEuNi4yLjUKCg==
--------_4AD2FB0E00000000E504_MULTIPART_MIXED_--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
