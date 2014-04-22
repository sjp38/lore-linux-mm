Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
	by kanga.kvack.org (Postfix) with ESMTP id 284316B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 20:31:37 -0400 (EDT)
Received: by mail-ve0-f173.google.com with SMTP id oy12so8658597veb.18
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 17:31:36 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id h11si6557443vcu.152.2014.04.21.17.31.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 17:31:36 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id lf12so1731756vcb.39
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 17:31:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53559F48.8040808@intel.com>
References: <1398032742.19682.11.camel@pasglop>
	<CA+55aFz1sK+PF96LYYZY7OB7PBpxZu-uNLWLvPiRz-tJsBqX3w@mail.gmail.com>
	<1398054064.19682.32.camel@pasglop>
	<1398057630.19682.38.camel@pasglop>
	<CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com>
	<53558507.9050703@zytor.com>
	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
	<53559F48.8040808@intel.com>
Date: Mon, 21 Apr 2014 17:31:33 -0700
Message-ID: <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=047d7b3a9250101fe704f796bdc0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

--047d7b3a9250101fe704f796bdc0
Content-Type: text/plain; charset=UTF-8

On Mon, Apr 21, 2014 at 3:44 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>
> I came up with something pretty similar to what you've got.  I used some
> local variables for the dirty state rather than using the pte, but
> otherwise looks pretty similar.  It actually boots, runs, and
> superficially looks to be doing the right thing.

.. except your version doesn't seem to have a chance of even compiling
on anything that doesn't use asm-generic/tlb.h and thus
HAVE_GENERIC_MMU_GATHER.

Now, I don't know that mine works either, but at least I tried. I've
love to hear if somebody who has a cross-compile environment set up
for the non-generic architectures. I tried 'um', but we have at least
arm, ia64, s390 and sh that don't use the generic mmu gather logic.

I'm not entirely sure why ARM doesn't do the generic one, but I think
s390 is TLB-coherent at the ptep_get_and_clear() point, so there just
doing the set_page_dirty() is fine (assuming it compiles - there could
be some header file ordering issue).

> I fixed free_pages_and_swap_cache() but just making a first pass through
> the array and clearing the bits.

Yeah. I have to say, I think it's a bit ugly.

I am personally starting to think that we could just make
release_pages() ignore the low bit of the "struct page" pointer in the
array it is passed in, and then free_pages_and_swap_cache() could
easily just do the "set_page_dirty()" in the loop it already does.

Now, I agree that that is certainly *also* a bit ugly, but it ends up
simplifying everything else, so it's a preferable kind of ugly to me.

So here's a suggested *incremental* patch (on top of my previous patch
that did the interface change) that does that.

Does this work for people? It *looks* sane. It compiles for me (tested
on x86 that uses generic mmu gather, and on UM that does not).

                Linus

--047d7b3a9250101fe704f796bdc0
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_huagj60t1

IG1tL21lbW9yeS5jICAgICB8ICA1ICstLS0tCiBtbS9zd2FwLmMgICAgICAgfCAgOCArKysrKysr
LQogbW0vc3dhcF9zdGF0ZS5jIHwgMTQgKysrKysrKysrKysrLS0KIDMgZmlsZXMgY2hhbmdlZCwg
MjAgaW5zZXJ0aW9ucygrKSwgNyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9tZW1vcnku
YyBiL21tL21lbW9yeS5jCmluZGV4IDYyZmRjZDE5OTVmNC4uMTc0NTQyYWIyYjkwIDEwMDY0NAot
LS0gYS9tbS9tZW1vcnkuYworKysgYi9tbS9tZW1vcnkuYwpAQCAtMjgzLDExICsyODMsOCBAQCBp
bnQgX190bGJfcmVtb3ZlX3BhZ2Uoc3RydWN0IG1tdV9nYXRoZXIgKnRsYiwgc3RydWN0IHBhZ2Ug
KnBhZ2UsIGJvb2wgZGlydHkpCiAKIAlWTV9CVUdfT04oIXRsYi0+bmVlZF9mbHVzaCk7CiAKLQkv
KiBGSVhNRSEgVGhpcyBuZWVkcyB0byBiZSBiYXRjaGVkIHRvbyAqLwotCWlmIChkaXJ0eSkKLQkJ
c2V0X3BhZ2VfZGlydHkocGFnZSk7CiAJYmF0Y2ggPSB0bGItPmFjdGl2ZTsKLQliYXRjaC0+cGFn
ZXNbYmF0Y2gtPm5yKytdID0gcGFnZTsKKwliYXRjaC0+cGFnZXNbYmF0Y2gtPm5yKytdID0gKHZv
aWQgKikgKGRpcnR5ICsgKHVuc2lnbmVkIGxvbmcpcGFnZSk7CiAJaWYgKGJhdGNoLT5uciA9PSBi
YXRjaC0+bWF4KSB7CiAJCWlmICghdGxiX25leHRfYmF0Y2godGxiKSkKIAkJCXJldHVybiAwOwpk
aWZmIC0tZ2l0IGEvbW0vc3dhcC5jIGIvbW0vc3dhcC5jCmluZGV4IDljZTQzYmE0NDk4Yi4uMWE1
OGM1OGM3ZjQxIDEwMDY0NAotLS0gYS9tbS9zd2FwLmMKKysrIGIvbW0vc3dhcC5jCkBAIC04MjEs
OCArODIxLDE0IEBAIHZvaWQgcmVsZWFzZV9wYWdlcyhzdHJ1Y3QgcGFnZSAqKnBhZ2VzLCBpbnQg
bnIsIGludCBjb2xkKQogCXN0cnVjdCBscnV2ZWMgKmxydXZlYzsKIAl1bnNpZ25lZCBsb25nIHVu
aW5pdGlhbGl6ZWRfdmFyKGZsYWdzKTsKIAorCS8qCisJICogTk9URSEgVGhlIGxvdyBiaXQgb2Yg
dGhlIHN0cnVjdCBwYWdlIHBvaW50ZXIgaW4KKwkgKiB0aGUgInBhZ2VzW10iIGFycmF5IGlzIHVz
ZWQgYXMgYSBkaXJ0eSBiaXQsIHNvCisJICogd2UgaWdub3JlIGl0CisJICovCiAJZm9yIChpID0g
MDsgaSA8IG5yOyBpKyspIHsKLQkJc3RydWN0IHBhZ2UgKnBhZ2UgPSBwYWdlc1tpXTsKKwkJdW5z
aWduZWQgbG9uZyBwYWdldmFsID0gKHVuc2lnbmVkIGxvbmcpcGFnZXNbaV07CisJCXN0cnVjdCBw
YWdlICpwYWdlID0gKHZvaWQgKikofjF1bCAmIHBhZ2V2YWwpOwogCiAJCWlmICh1bmxpa2VseShQ
YWdlQ29tcG91bmQocGFnZSkpKSB7CiAJCQlpZiAoem9uZSkgewpkaWZmIC0tZ2l0IGEvbW0vc3dh
cF9zdGF0ZS5jIGIvbW0vc3dhcF9zdGF0ZS5jCmluZGV4IGU3NmFjZTMwZDQzNi4uYmIwYjJkNjc1
YTgyIDEwMDY0NAotLS0gYS9tbS9zd2FwX3N0YXRlLmMKKysrIGIvbW0vc3dhcF9zdGF0ZS5jCkBA
IC0yNTgsNiArMjU4LDExIEBAIHZvaWQgZnJlZV9wYWdlX2FuZF9zd2FwX2NhY2hlKHN0cnVjdCBw
YWdlICpwYWdlKQogLyoKICAqIFBhc3NlZCBhbiBhcnJheSBvZiBwYWdlcywgZHJvcCB0aGVtIGFs
bCBmcm9tIHN3YXBjYWNoZSBhbmQgdGhlbiByZWxlYXNlCiAgKiB0aGVtLiAgVGhleSBhcmUgcmVt
b3ZlZCBmcm9tIHRoZSBMUlUgYW5kIGZyZWVkIGlmIHRoaXMgaXMgdGhlaXIgbGFzdCB1c2UuCisg
KgorICogTk9URSEgVGhlIGxvdyBiaXQgb2YgdGhlICJzdHJ1Y3QgcGFnZSIgcG9pbnRlcnMgcGFz
c2VkIGluIGlzIGEgZGlydHkKKyAqIGluZGljYXRvciwgc2F5aW5nIHRoYXQgdGhlIHBhZ2UgbmVl
ZHMgdG8gYmUgbWFya2VkIGRpcnR5IGJlZm9yZSBmcmVlaW5nLgorICoKKyAqIHJlbGVhc2VfcGFn
ZXMoKSBpdHNlbGYgaWdub3JlcyB0aGF0IGJpdC4KICAqLwogdm9pZCBmcmVlX3BhZ2VzX2FuZF9z
d2FwX2NhY2hlKHN0cnVjdCBwYWdlICoqcGFnZXMsIGludCBucikKIHsKQEAgLTI2OCw4ICsyNzMs
MTMgQEAgdm9pZCBmcmVlX3BhZ2VzX2FuZF9zd2FwX2NhY2hlKHN0cnVjdCBwYWdlICoqcGFnZXMs
IGludCBucikKIAkJaW50IHRvZG8gPSBtaW4obnIsIFBBR0VWRUNfU0laRSk7CiAJCWludCBpOwog
Ci0JCWZvciAoaSA9IDA7IGkgPCB0b2RvOyBpKyspCi0JCQlmcmVlX3N3YXBfY2FjaGUocGFnZXBb
aV0pOworCQlmb3IgKGkgPSAwOyBpIDwgdG9kbzsgaSsrKSB7CisJCQl1bnNpZ25lZCBsb25nIHBh
Z2V2YWwgPSAodW5zaWduZWQgbG9uZykgcGFnZXBbaV07CisJCQlzdHJ1Y3QgcGFnZSAqcGFnZSA9
ICh2b2lkICopKH4xdWwgJiBwYWdldmFsKTsKKwkJCWlmIChwYWdldmFsICYgMSkKKwkJCQlzZXRf
cGFnZV9kaXJ0eShwYWdlKTsKKwkJCWZyZWVfc3dhcF9jYWNoZShwYWdlKTsKKwkJfQogCQlyZWxl
YXNlX3BhZ2VzKHBhZ2VwLCB0b2RvLCAwKTsKIAkJcGFnZXAgKz0gdG9kbzsKIAkJbnIgLT0gdG9k
bzsK
--047d7b3a9250101fe704f796bdc0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
