Message-ID: <463FF3D3.9060007@redhat.com>
Date: Mon, 07 May 2007 23:51:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [PATCH] stub MADV_FREE implementation
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au> <463B598B.80200@redhat.com> <463BC62C.3060605@yahoo.com.au>
In-Reply-To: <463BC62C.3060605@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------050908060300040602000504"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ulrich Drepper <drepper@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Dave Jones <davej@redhat.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050908060300040602000504
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Until we have better performance numbers on the lazy reclaim path,
we can just alias MADV_FREE to MADV_DONTNEED with this trivial
patch.

This way glibc can go ahead with the optimization on their side
and we can figure out the kernel side later.

Signed-off-by: Rik van Riel <riel@redhat.com>

---
When I get back from the Red Hat Summit (Saturday), I will run more
performance numbers with and without the lazy reclaiming of pages.

Nick Piggin wrote:
> Ulrich Drepper wrote:
>> Nick Piggin wrote:
>>
>>> What I found is that, on this system, MADV_FREE performance improvement
>>> was in the noise when you look at it on top of the MADV_DONTNEED glibc
>>> and down_read(mmap_sem) patch in sysbench.
>>
>>
>> I don't want to judge the numbers since I cannot but I want to make an
>> observations: even if in the SMP case MADV_FREE turns out to not be a
>> bigger boost then there is still the UP case to keep in mind where Rik
>> measured a significant speed-up.  As long as the SMP case isn't hurt
>> this is reaosn enough to use the patch.  With more and more cores on one
>> processor SMP systems are pushed evermore to the high-end side.  You'll
>> find many installations which today use SMP will be happy enough with
>> many-core UP machines.
> 
> OK, sure. I think we need more numbers though.
> 
> And even if this was a patch with _no_ possibility for regressions and it
> was a completely trivial one that improves performance in some cases...
> one big problem is that it uses another page flag.
> 
> I literally have about 4 or 5 new page flags I'd like to add today :) I
> can't of course, because we have very few spare ones left.
> 
>  From the MySQL numbers on this system, it seems like performance is in the
> noise, and MADV_DONTNEED makes the _vast_ majority of the improvement.
> This is also the case with Rik's benchmarks, and while he did see some
> improvement, I found the runs to be quite variable, so it would be ideal
> to get a larger sample.
> 
> And the fact that the poor behaviour of the old style malloc/free went
> unnoticed for so long indicates that it won't be the end of the world if
> we didn't merge MADV_FREE right now.
> 


-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--------------050908060300040602000504
Content-Type: text/plain;
 name="stub-madv_free"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="stub-madv_free"

IGluY2x1ZGUvYXNtLWFscGhhL21tYW4uaCAgIHwgICAgMSArCiBpbmNsdWRlL2FzbS1nZW5l
cmljL21tYW4uaCB8ICAgIDEgKwogaW5jbHVkZS9hc20tbWlwcy9tbWFuLmggICAgfCAgICAx
ICsKIGluY2x1ZGUvYXNtLXBhcmlzYy9tbWFuLmggIHwgICAgMSArCiBpbmNsdWRlL2FzbS1z
cGFyYy9tbWFuLmggICB8ICAgIDIgLS0KIGluY2x1ZGUvYXNtLXNwYXJjNjQvbW1hbi5oIHwg
ICAgMiAtLQogaW5jbHVkZS9hc20teHRlbnNhL21tYW4uaCAgfCAgICAxICsKIG1tL21hZHZp
c2UuYyAgICAgICAgICAgICAgIHwgICAgMiArKwogOCBmaWxlcyBjaGFuZ2VkLCA3IGluc2Vy
dGlvbnMoKyksIDQgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20tYWxw
aGEvbW1hbi5oIGIvaW5jbHVkZS9hc20tYWxwaGEvbW1hbi5oCmluZGV4IDkwZDdjMzUuLmQ0
N2I1YTMgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvYXNtLWFscGhhL21tYW4uaAorKysgYi9pbmNs
dWRlL2FzbS1hbHBoYS9tbWFuLmgKQEAgLTQyLDYgKzQyLDcgQEAgI2RlZmluZSBNQURWX1NF
UVVFTlRJQUwJMgkJLyogZXhwZWN0IHNlcQogI2RlZmluZSBNQURWX1dJTExORUVECTMJCS8q
IHdpbGwgbmVlZCB0aGVzZSBwYWdlcyAqLwogI2RlZmluZQlNQURWX1NQQUNFQVZBSUwJNQkJ
LyogZW5zdXJlIHJlc291cmNlcyBhcmUgYXZhaWxhYmxlICovCiAjZGVmaW5lIE1BRFZfRE9O
VE5FRUQJNgkJLyogZG9uJ3QgbmVlZCB0aGVzZSBwYWdlcyAqLworI2RlZmluZSBNQURWX0ZS
RUUJNwkJLyogZG9uJ3QgbmVlZCB0aGUgcGFnZXMgb3IgdGhlIGRhdGEgKi8KIAogLyogY29t
bW9uL2dlbmVyaWMgcGFyYW1ldGVycyAqLwogI2RlZmluZSBNQURWX1JFTU9WRQk5CQkvKiBy
ZW1vdmUgdGhlc2UgcGFnZXMgJiByZXNvdXJjZXMgKi8KZGlmZiAtLWdpdCBhL2luY2x1ZGUv
YXNtLWdlbmVyaWMvbW1hbi5oIGIvaW5jbHVkZS9hc20tZ2VuZXJpYy9tbWFuLmgKaW5kZXgg
NWUzZGRlMi4uMzRhOWZmMSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9hc20tZ2VuZXJpYy9tbWFu
LmgKKysrIGIvaW5jbHVkZS9hc20tZ2VuZXJpYy9tbWFuLmgKQEAgLTI5LDYgKzI5LDcgQEAg
I2RlZmluZSBNQURWX1JBTkRPTQkxCQkvKiBleHBlY3QgcmFuZG9tIAogI2RlZmluZSBNQURW
X1NFUVVFTlRJQUwJMgkJLyogZXhwZWN0IHNlcXVlbnRpYWwgcGFnZSByZWZlcmVuY2VzICov
CiAjZGVmaW5lIE1BRFZfV0lMTE5FRUQJMwkJLyogd2lsbCBuZWVkIHRoZXNlIHBhZ2VzICov
CiAjZGVmaW5lIE1BRFZfRE9OVE5FRUQJNAkJLyogZG9uJ3QgbmVlZCB0aGVzZSBwYWdlcyAq
LworI2RlZmluZSBNQURWX0ZSRUUJNQkJLyogZG9uJ3QgbmVlZCB0aGUgcGFnZXMgb3IgdGhl
IGRhdGEgKi8KIAogLyogY29tbW9uIHBhcmFtZXRlcnM6IHRyeSB0byBrZWVwIHRoZXNlIGNv
bnNpc3RlbnQgYWNyb3NzIGFyY2hpdGVjdHVyZXMgKi8KICNkZWZpbmUgTUFEVl9SRU1PVkUJ
OQkJLyogcmVtb3ZlIHRoZXNlIHBhZ2VzICYgcmVzb3VyY2VzICovCmRpZmYgLS1naXQgYS9p
bmNsdWRlL2FzbS1taXBzL21tYW4uaCBiL2luY2x1ZGUvYXNtLW1pcHMvbW1hbi5oCmluZGV4
IGU0ZDZmMWYuLjY4MDY3ZmYgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvYXNtLW1pcHMvbW1hbi5o
CisrKyBiL2luY2x1ZGUvYXNtLW1pcHMvbW1hbi5oCkBAIC02NSw2ICs2NSw3IEBAICNkZWZp
bmUgTUFEVl9SQU5ET00JMQkJLyogZXhwZWN0IHJhbmRvbSAKICNkZWZpbmUgTUFEVl9TRVFV
RU5USUFMCTIJCS8qIGV4cGVjdCBzZXF1ZW50aWFsIHBhZ2UgcmVmZXJlbmNlcyAqLwogI2Rl
ZmluZSBNQURWX1dJTExORUVECTMJCS8qIHdpbGwgbmVlZCB0aGVzZSBwYWdlcyAqLwogI2Rl
ZmluZSBNQURWX0RPTlRORUVECTQJCS8qIGRvbid0IG5lZWQgdGhlc2UgcGFnZXMgKi8KKyNk
ZWZpbmUgTUFEVl9GUkVFCTUJCS8qIGRvbid0IG5lZWQgdGhlIHBhZ2VzIG9yIHRoZSBkYXRh
ICovCiAKIC8qIGNvbW1vbiBwYXJhbWV0ZXJzOiB0cnkgdG8ga2VlcCB0aGVzZSBjb25zaXN0
ZW50IGFjcm9zcyBhcmNoaXRlY3R1cmVzICovCiAjZGVmaW5lIE1BRFZfUkVNT1ZFCTkJCS8q
IHJlbW92ZSB0aGVzZSBwYWdlcyAmIHJlc291cmNlcyAqLwpkaWZmIC0tZ2l0IGEvaW5jbHVk
ZS9hc20tcGFyaXNjL21tYW4uaCBiL2luY2x1ZGUvYXNtLXBhcmlzYy9tbWFuLmgKaW5kZXgg
ZGVmZTc1Mi4uMzQ3ZmJjYSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9hc20tcGFyaXNjL21tYW4u
aAorKysgYi9pbmNsdWRlL2FzbS1wYXJpc2MvbW1hbi5oCkBAIC0zOCw2ICszOCw3IEBAICNk
ZWZpbmUgTUFEVl9ET05UTkVFRCAgIDQgICAgICAgICAgICAgICAKICNkZWZpbmUgTUFEVl9T
UEFDRUFWQUlMIDUgICAgICAgICAgICAgICAvKiBpbnN1cmUgdGhhdCByZXNvdXJjZXMgYXJl
IHJlc2VydmVkICovCiAjZGVmaW5lIE1BRFZfVlBTX1BVUkdFICA2ICAgICAgICAgICAgICAg
LyogUHVyZ2UgcGFnZXMgZnJvbSBWTSBwYWdlIGNhY2hlICovCiAjZGVmaW5lIE1BRFZfVlBT
X0lOSEVSSVQgNyAgICAgICAgICAgICAgLyogSW5oZXJpdCBwYXJlbnRzIHBhZ2Ugc2l6ZSAq
LworI2RlZmluZSBNQURWX0ZSRUUJOAkJLyogZG9uJ3QgbmVlZCB0aGUgcGFnZXMgb3IgdGhl
IGRhdGEgKi8KIAogLyogY29tbW9uL2dlbmVyaWMgcGFyYW1ldGVycyAqLwogI2RlZmluZSBN
QURWX1JFTU9WRQk5CQkvKiByZW1vdmUgdGhlc2UgcGFnZXMgJiByZXNvdXJjZXMgKi8KZGlm
ZiAtLWdpdCBhL2luY2x1ZGUvYXNtLXNwYXJjL21tYW4uaCBiL2luY2x1ZGUvYXNtLXNwYXJj
L21tYW4uaAppbmRleCBiN2RjNDBiLi41ZWM3MTA2IDEwMDY0NAotLS0gYS9pbmNsdWRlL2Fz
bS1zcGFyYy9tbWFuLmgKKysrIGIvaW5jbHVkZS9hc20tc3BhcmMvbW1hbi5oCkBAIC0zMyw4
ICszMyw2IEBAICNkZWZpbmUgTUNfVU5MT0NLICAgICAgIDMgIC8qIFVubG9jayBwYWcKICNk
ZWZpbmUgTUNfTE9DS0FTICAgICAgIDUgIC8qIExvY2sgYW4gZW50aXJlIGFkZHJlc3Mgc3Bh
Y2Ugb2YgdGhlIGNhbGxpbmcgcHJvY2VzcyAqLwogI2RlZmluZSBNQ19VTkxPQ0tBUyAgICAg
NiAgLyogVW5sb2NrIGVudGlyZSBhZGRyZXNzIHNwYWNlIG9mIGNhbGxpbmcgcHJvY2VzcyAq
LwogCi0jZGVmaW5lIE1BRFZfRlJFRQkweDUJCS8qIChTb2xhcmlzKSBjb250ZW50cyBjYW4g
YmUgZnJlZWQgKi8KLQogI2lmZGVmIF9fS0VSTkVMX18KICNpZm5kZWYgX19BU1NFTUJMWV9f
CiAjZGVmaW5lIGFyY2hfbW1hcF9jaGVjawlzcGFyY19tbWFwX2NoZWNrCmRpZmYgLS1naXQg
YS9pbmNsdWRlL2FzbS1zcGFyYzY0L21tYW4uaCBiL2luY2x1ZGUvYXNtLXNwYXJjNjQvbW1h
bi5oCmluZGV4IDhjYzE4NjAuLjAzYjA1ZDUgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvYXNtLXNw
YXJjNjQvbW1hbi5oCisrKyBiL2luY2x1ZGUvYXNtLXNwYXJjNjQvbW1hbi5oCkBAIC0zMyw4
ICszMyw2IEBAICNkZWZpbmUgTUNfVU5MT0NLICAgICAgIDMgIC8qIFVubG9jayBwYWcKICNk
ZWZpbmUgTUNfTE9DS0FTICAgICAgIDUgIC8qIExvY2sgYW4gZW50aXJlIGFkZHJlc3Mgc3Bh
Y2Ugb2YgdGhlIGNhbGxpbmcgcHJvY2VzcyAqLwogI2RlZmluZSBNQ19VTkxPQ0tBUyAgICAg
NiAgLyogVW5sb2NrIGVudGlyZSBhZGRyZXNzIHNwYWNlIG9mIGNhbGxpbmcgcHJvY2VzcyAq
LwogCi0jZGVmaW5lIE1BRFZfRlJFRQkweDUJCS8qIChTb2xhcmlzKSBjb250ZW50cyBjYW4g
YmUgZnJlZWQgKi8KLQogI2lmZGVmIF9fS0VSTkVMX18KICNpZm5kZWYgX19BU1NFTUJMWV9f
CiAjZGVmaW5lIGFyY2hfbW1hcF9jaGVjawlzcGFyYzY0X21tYXBfY2hlY2sKZGlmZiAtLWdp
dCBhL2luY2x1ZGUvYXNtLXh0ZW5zYS9tbWFuLmggYi9pbmNsdWRlL2FzbS14dGVuc2EvbW1h
bi5oCmluZGV4IDliOTI2MjAuLjEzNDU3MDMgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvYXNtLXh0
ZW5zYS9tbWFuLmgKKysrIGIvaW5jbHVkZS9hc20teHRlbnNhL21tYW4uaApAQCAtNzIsNiAr
NzIsNyBAQCAjZGVmaW5lIE1BRFZfUkFORE9NCTEJCS8qIGV4cGVjdCByYW5kb20gCiAjZGVm
aW5lIE1BRFZfU0VRVUVOVElBTAkyCQkvKiBleHBlY3Qgc2VxdWVudGlhbCBwYWdlIHJlZmVy
ZW5jZXMgKi8KICNkZWZpbmUgTUFEVl9XSUxMTkVFRAkzCQkvKiB3aWxsIG5lZWQgdGhlc2Ug
cGFnZXMgKi8KICNkZWZpbmUgTUFEVl9ET05UTkVFRAk0CQkvKiBkb24ndCBuZWVkIHRoZXNl
IHBhZ2VzICovCisjZGVmaW5lIE1BRFZfRlJFRQk1CQkvKiBkb24ndCBuZWVkIHRoZSBwYWdl
cyBvciB0aGUgZGF0YSAqLwogCiAvKiBjb21tb24gcGFyYW1ldGVyczogdHJ5IHRvIGtlZXAg
dGhlc2UgY29uc2lzdGVudCBhY3Jvc3MgYXJjaGl0ZWN0dXJlcyAqLwogI2RlZmluZSBNQURW
X1JFTU9WRQk5CQkvKiByZW1vdmUgdGhlc2UgcGFnZXMgJiByZXNvdXJjZXMgKi8KZGlmZiAt
LWdpdCBhL21tL21hZHZpc2UuYyBiL21tL21hZHZpc2UuYwppbmRleCBlNzUwOTZiLi5hZDA2
N2YyIDEwMDY0NAotLS0gYS9tbS9tYWR2aXNlLmMKKysrIGIvbW0vbWFkdmlzZS5jCkBAIC0y
Miw2ICsyMiw3IEBAIHN0YXRpYyBpbnQgbWFkdmlzZV9uZWVkX21tYXBfd3JpdGUoaW50IGIK
IAljYXNlIE1BRFZfUkVNT1ZFOgogCWNhc2UgTUFEVl9XSUxMTkVFRDoKIAljYXNlIE1BRFZf
RE9OVE5FRUQ6CisJY2FzZSBNQURWX0ZSRUU6CiAJCXJldHVybiAwOwogCWRlZmF1bHQ6CiAJ
CS8qIGJlIHNhZmUsIGRlZmF1bHQgdG8gMS4gbGlzdCBleGNlcHRpb25zIGV4cGxpY2l0bHkg
Ki8KQEAgLTIzNCw2ICsyMzUsNyBAQCBtYWR2aXNlX3ZtYShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1
Y3QgKnZtYSwgCiAJCWJyZWFrOwogCiAJY2FzZSBNQURWX0RPTlRORUVEOgorCWNhc2UgTUFE
Vl9GUkVFOgogCQllcnJvciA9IG1hZHZpc2VfZG9udG5lZWQodm1hLCBwcmV2LCBzdGFydCwg
ZW5kKTsKIAkJYnJlYWs7CiAK
--------------050908060300040602000504--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
