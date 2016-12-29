Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E06916B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:16:57 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j15so200341908ioj.7
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 20:16:57 -0800 (PST)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id v83si35280881iod.8.2016.12.28.20.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 20:16:57 -0800 (PST)
Received: by mail-it0-x244.google.com with SMTP id b123so38017137itb.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 20:16:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161229140837.5fff906d@roar.ozlabs.ibm.com>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-3-npiggin@gmail.com>
 <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
 <20161226111654.76ab0957@roar.ozlabs.ibm.com> <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
 <20161227211946.3770b6ce@roar.ozlabs.ibm.com> <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
 <20161228135358.59f47204@roar.ozlabs.ibm.com> <CA+55aFz-evT+NiZY0GhO719M+=u==TbCqxTJTjp+pJevhDnRrw@mail.gmail.com>
 <20161229140837.5fff906d@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Dec 2016 20:16:56 -0800
Message-ID: <CA+55aFxGz8R8J9jLvKpLUgyhWVYcgtObhbHBP7eZzZyc05AODw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Content-Type: multipart/mixed; boundary=94eb2c058c72274b180544c45b20
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

--94eb2c058c72274b180544c45b20
Content-Type: text/plain; charset=UTF-8

On Wed, Dec 28, 2016 at 8:08 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
>
> Okay. The name could be a bit better though I think, for readability.
> Just a BUILD_BUG_ON if it is not constant and correct bit numbers?

I have a slightly edited patch - moved the comments around and added
some new comments (about both the sign bit, but also about how the
smp_mb() shouldn't be necessary even for the non-atomic fallback).

I also did a BUILD_BUG_ON(), except the other way around - keeping it
about the sign bit in the byte, just just verifying that yes,
PG_waiters is that sign bit.

> BTW. I just notice in your patch too that you didn't use "nr" in the
> generic version.

And I fixed that too.

Of course, I didn't test the changes (apart from building it). But
I've been running the previous version since yesterday, so far no
issues.

                Linus

--94eb2c058c72274b180544c45b20
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ix9uzfl90

IGFyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9wcy5oIHwgMTMgKysrKysrKysrKysrKwogaW5jbHVk
ZS9saW51eC9wYWdlLWZsYWdzLmggICAgfCAgMiArLQogbW0vZmlsZW1hcC5jICAgICAgICAgICAg
ICAgICAgfCAzNiArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrLS0tLS0KIDMgZmlsZXMg
Y2hhbmdlZCwgNDUgaW5zZXJ0aW9ucygrKSwgNiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9h
cmNoL3g4Ni9pbmNsdWRlL2FzbS9iaXRvcHMuaCBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL2JpdG9w
cy5oCmluZGV4IDY4NTU3ZjUyYjk2MS4uODU0MDIyNzcyYzViIDEwMDY0NAotLS0gYS9hcmNoL3g4
Ni9pbmNsdWRlL2FzbS9iaXRvcHMuaAorKysgYi9hcmNoL3g4Ni9pbmNsdWRlL2FzbS9iaXRvcHMu
aApAQCAtMTM5LDYgKzEzOSwxOSBAQCBzdGF0aWMgX19hbHdheXNfaW5saW5lIHZvaWQgX19jbGVh
cl9iaXQobG9uZyBuciwgdm9sYXRpbGUgdW5zaWduZWQgbG9uZyAqYWRkcikKIAlhc20gdm9sYXRp
bGUoImJ0ciAlMSwlMCIgOiBBRERSIDogIklyIiAobnIpKTsKIH0KIAorc3RhdGljIF9fYWx3YXlz
X2lubGluZSBib29sIGNsZWFyX2JpdF91bmxvY2tfaXNfbmVnYXRpdmVfYnl0ZShsb25nIG5yLCB2
b2xhdGlsZSB1bnNpZ25lZCBsb25nICphZGRyKQoreworCWJvb2wgbmVnYXRpdmU7CisJYXNtIHZv
bGF0aWxlKExPQ0tfUFJFRklYICJhbmRiICUyLCUxXG5cdCIKKwkJQ0NfU0VUKHMpCisJCTogQ0Nf
T1VUKHMpIChuZWdhdGl2ZSksIEFERFIKKwkJOiAiaXIiICgoY2hhcikgfigxIDw8IG5yKSkgOiAi
bWVtb3J5Iik7CisJcmV0dXJuIG5lZ2F0aXZlOworfQorCisvLyBMZXQgZXZlcnlib2R5IGtub3cg
d2UgaGF2ZSBpdAorI2RlZmluZSBjbGVhcl9iaXRfdW5sb2NrX2lzX25lZ2F0aXZlX2J5dGUgY2xl
YXJfYml0X3VubG9ja19pc19uZWdhdGl2ZV9ieXRlCisKIC8qCiAgKiBfX2NsZWFyX2JpdF91bmxv
Y2sgLSBDbGVhcnMgYSBiaXQgaW4gbWVtb3J5CiAgKiBAbnI6IEJpdCB0byBjbGVhcgpkaWZmIC0t
Z2l0IGEvaW5jbHVkZS9saW51eC9wYWdlLWZsYWdzLmggYi9pbmNsdWRlL2xpbnV4L3BhZ2UtZmxh
Z3MuaAppbmRleCBjNTZiMzk4OTBhNDEuLjZiNTgxOGQ2ZGUzMiAxMDA2NDQKLS0tIGEvaW5jbHVk
ZS9saW51eC9wYWdlLWZsYWdzLmgKKysrIGIvaW5jbHVkZS9saW51eC9wYWdlLWZsYWdzLmgKQEAg
LTczLDEzICs3MywxMyBAQAogICovCiBlbnVtIHBhZ2VmbGFncyB7CiAJUEdfbG9ja2VkLAkJLyog
UGFnZSBpcyBsb2NrZWQuIERvbid0IHRvdWNoLiAqLwotCVBHX3dhaXRlcnMsCQkvKiBQYWdlIGhh
cyB3YWl0ZXJzLCBjaGVjayBpdHMgd2FpdHF1ZXVlICovCiAJUEdfZXJyb3IsCiAJUEdfcmVmZXJl
bmNlZCwKIAlQR191cHRvZGF0ZSwKIAlQR19kaXJ0eSwKIAlQR19scnUsCiAJUEdfYWN0aXZlLAor
CVBHX3dhaXRlcnMsCQkvKiBQYWdlIGhhcyB3YWl0ZXJzLCBjaGVjayBpdHMgd2FpdHF1ZXVlLiBN
dXN0IGJlIGJpdCAjNyBhbmQgaW4gdGhlIHNhbWUgYnl0ZSBhcyAiUEdfbG9ja2VkIiAqLwogCVBH
X3NsYWIsCiAJUEdfb3duZXJfcHJpdl8xLAkvKiBPd25lciB1c2UuIElmIHBhZ2VjYWNoZSwgZnMg
bWF5IHVzZSovCiAJUEdfYXJjaF8xLApkaWZmIC0tZ2l0IGEvbW0vZmlsZW1hcC5jIGIvbW0vZmls
ZW1hcC5jCmluZGV4IDgyZjI2Y2RlODMwYy4uNmIxZDk2Zjg2YTljIDEwMDY0NAotLS0gYS9tbS9m
aWxlbWFwLmMKKysrIGIvbW0vZmlsZW1hcC5jCkBAIC05MTIsNiArOTEyLDI5IEBAIHZvaWQgYWRk
X3BhZ2Vfd2FpdF9xdWV1ZShzdHJ1Y3QgcGFnZSAqcGFnZSwgd2FpdF9xdWV1ZV90ICp3YWl0ZXIp
CiB9CiBFWFBPUlRfU1lNQk9MX0dQTChhZGRfcGFnZV93YWl0X3F1ZXVlKTsKIAorI2lmbmRlZiBj
bGVhcl9iaXRfdW5sb2NrX2lzX25lZ2F0aXZlX2J5dGUKKworLyoKKyAqIFBHX3dhaXRlcnMgaXMg
dGhlIGhpZ2ggYml0IGluIHRoZSBzYW1lIGJ5dGUgYXMgUEdfbG9jay4KKyAqCisgKiBPbiB4ODYg
KGFuZCBvbiBtYW55IG90aGVyIGFyY2hpdGVjdHVyZXMpLCB3ZSBjYW4gY2xlYXIgUEdfbG9jayBh
bmQKKyAqIHRlc3QgdGhlIHNpZ24gYml0IGF0IHRoZSBzYW1lIHRpbWUuIEJ1dCBpZiB0aGUgYXJj
aGl0ZWN0dXJlIGRvZXMKKyAqIG5vdCBzdXBwb3J0IHRoYXQgc3BlY2lhbCBvcGVyYXRpb24sIHdl
IGp1c3QgZG8gdGhpcyBhbGwgYnkgaGFuZAorICogaW5zdGVhZC4KKyAqCisgKiBUaGUgcmVhZCBv
ZiBQR193YWl0ZXJzIGhhcyB0byBiZSBhZnRlciAob3IgY29uY3VycmVudGx5IHdpdGgpIFBHX2xv
Y2tlZAorICogYmVpbmcgY2xlYXJlZCwgYnV0IGEgbWVtb3J5IGJhcnJpZXIgc2hvdWxkIGJlIHVu
bmVjY3NzYXJ5IHNpbmNlIGl0IGlzCisgKiBpbiB0aGUgc2FtZSBieXRlIGFzIFBHX2xvY2tlZC4K
KyAqLworc3RhdGljIGlubGluZSBib29sIGNsZWFyX2JpdF91bmxvY2tfaXNfbmVnYXRpdmVfYnl0
ZShsb25nIG5yLCB2b2xhdGlsZSB2b2lkICptZW0pCit7CisJY2xlYXJfYml0X3VubG9jayhuciwg
bWVtKTsKKwkvKiBzbXBfbWJfX2FmdGVyX2F0b21pYygpOyAqLworCXJldHVybiB0ZXN0X2JpdChQ
R193YWl0ZXJzKTsKK30KKworI2VuZGlmCisKIC8qKgogICogdW5sb2NrX3BhZ2UgLSB1bmxvY2sg
YSBsb2NrZWQgcGFnZQogICogQHBhZ2U6IHRoZSBwYWdlCkBAIC05MjEsMTYgKzk0NCwxOSBAQCBF
WFBPUlRfU1lNQk9MX0dQTChhZGRfcGFnZV93YWl0X3F1ZXVlKTsKICAqIG1lY2hhbmlzbSBiZXR3
ZWVuIFBhZ2VMb2NrZWQgcGFnZXMgYW5kIFBhZ2VXcml0ZWJhY2sgcGFnZXMgaXMgc2hhcmVkLgog
ICogQnV0IHRoYXQncyBPSyAtIHNsZWVwZXJzIGluIHdhaXRfb25fcGFnZV93cml0ZWJhY2soKSBq
dXN0IGdvIGJhY2sgdG8gc2xlZXAuCiAgKgotICogVGhlIG1iIGlzIG5lY2Vzc2FyeSB0byBlbmZv
cmNlIG9yZGVyaW5nIGJldHdlZW4gdGhlIGNsZWFyX2JpdCBhbmQgdGhlIHJlYWQKLSAqIG9mIHRo
ZSB3YWl0cXVldWUgKHRvIGF2b2lkIFNNUCByYWNlcyB3aXRoIGEgcGFyYWxsZWwgd2FpdF9vbl9w
YWdlX2xvY2tlZCgpKS4KKyAqIE5vdGUgdGhhdCB0aGlzIGRlcGVuZHMgb24gUEdfd2FpdGVycyBi
ZWluZyB0aGUgc2lnbiBiaXQgaW4gdGhlIGJ5dGUKKyAqIHRoYXQgY29udGFpbnMgUEdfbG9ja2Vk
IC0gdGh1cyB0aGUgQlVJTERfQlVHX09OKCkuIFRoYXQgYWxsb3dzIHVzIHRvCisgKiBjbGVhciB0
aGUgUEdfbG9ja2VkIGJpdCBhbmQgdGVzdCBQR193YWl0ZXJzIGF0IHRoZSBzYW1lIHRpbWUgZmFp
cmx5CisgKiBwb3J0YWJseSAoYXJjaGl0ZWN0dXJlcyB0aGF0IGRvIExML1NDIGNhbiB0ZXN0IGFu
eSBiaXQsIHdoaWxlIHg4NiBjYW4KKyAqIHRlc3QgdGhlIHNpZ24gYml0KS4KICAqLwogdm9pZCB1
bmxvY2tfcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSkKIHsKKwlCVUlMRF9CVUdfT04oUEdfd2FpdGVy
cyAhPSA3KTsKIAlwYWdlID0gY29tcG91bmRfaGVhZChwYWdlKTsKIAlWTV9CVUdfT05fUEFHRSgh
UGFnZUxvY2tlZChwYWdlKSwgcGFnZSk7Ci0JY2xlYXJfYml0X3VubG9jayhQR19sb2NrZWQsICZw
YWdlLT5mbGFncyk7Ci0Jc21wX21iX19hZnRlcl9hdG9taWMoKTsKLQl3YWtlX3VwX3BhZ2UocGFn
ZSwgUEdfbG9ja2VkKTsKKwlpZiAoY2xlYXJfYml0X3VubG9ja19pc19uZWdhdGl2ZV9ieXRlKFBH
X2xvY2tlZCwgJnBhZ2UtPmZsYWdzKSkKKwkJd2FrZV91cF9wYWdlX2JpdChwYWdlLCBQR19sb2Nr
ZWQpOwogfQogRVhQT1JUX1NZTUJPTCh1bmxvY2tfcGFnZSk7CiAK
--94eb2c058c72274b180544c45b20--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
