Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id B23676B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 19:46:44 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id hr9so3883497vcb.15
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:46:44 -0700 (PDT)
Received: from mail-ve0-x234.google.com (mail-ve0-x234.google.com [2607:f8b0:400c:c01::234])
        by mx.google.com with ESMTPS id vd8si1310846vdc.70.2014.04.24.16.46.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 16:46:43 -0700 (PDT)
Received: by mail-ve0-f180.google.com with SMTP id jz11so3854809veb.11
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:46:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
References: <53558507.9050703@zytor.com>
	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
	<53559F48.8040808@intel.com>
	<CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
	<20140422075459.GD11182@twins.programming.kicks-ass.net>
	<CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
	<alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
	<20140423184145.GH17824@quack.suse.cz>
	<CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
	<20140424065133.GX26782@laptop.programming.kicks-ass.net>
	<alpine.LSU.2.11.1404241110160.2443@eggly.anvils>
	<CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
	<alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
Date: Thu, 24 Apr 2014 16:46:43 -0700
Message-ID: <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=047d7b3437521ee23e04f7d276af
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

--047d7b3437521ee23e04f7d276af
Content-Type: text/plain; charset=UTF-8

On Thu, Apr 24, 2014 at 1:02 PM, Hugh Dickins <hughd@google.com> wrote:
>
> There is no need to free all the pages immediately after doing the
> TLB flush: that's merely how it's structured at present; page freeing
> can be left until the end as now, or when out from under the spinlock.

Hmm. In fact, if we to the actual TLB flush still under the ptl lock,
the current code will "just work". We can just keep the
set_page_dirty() at the scanning part, because there's no race with
mkclean() as long as we hold the lock.

So all that requires would be to split our current "tlb_flush_mmu()"
into the actual tlb flushing part, and the free_pages_and_swap_cache()
part. And then we do the TLB flushing inside the ptl, to make sure
that we flush tlb's before anybody can do mkclean().

And then we make the case of doing "set_page_dirty()" force a TLB
flush (but *not* force breaking out of the loop).

This gives us the best of all worlds:

 - maximum batching for the common case (no shared dirty pte entries)

 - if we find any dirty page table entries, we will batch as much as
we can within the ptl lock

 - we do the TLB shootdown holding the page table lock (but that's not
new - ptep_get_and_flush does the same

 - but we do the batched freeing of pages outside the lock

 - and the patch is pretty simple too (no need for the "one dirty bit
in the 'struct page *' pointer" games.

IOW, how about the attached patch that entirely replaces my previous
two patches. DaveH - does this fix your test-case, while _not_
introducing any new BUG_ON() triggers?

I didn't test the patch, maybe I did something stupid. It compiles for
me, but it only works for the HAVE_GENERIC_MMU_GATHER case, but
introducing tlb_flush_mmu_tlbonly() and tlb_flush_mmu_free() into the
non-generic cases should be trivial, since they really are just that
old "tlb_flush_mmu()" function split up (the tlb_flush_mmu() function
remains available for other non-forced flush users)

So assuming this does work for DaveH, then the arm/ia64/um/whatever
people would need to do those trivial transforms too, but it really
shouldn't be too painful.

Comments? DaveH?

               Linus

--047d7b3437521ee23e04f7d276af
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_huep92xg0

IG1tL21lbW9yeS5jIHwgNTMgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0t
LS0tLS0tLS0tLS0tLS0KIDEgZmlsZSBjaGFuZ2VkLCAzNCBpbnNlcnRpb25zKCspLCAxOSBkZWxl
dGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9tZW1vcnkuYyBiL21tL21lbW9yeS5jCmluZGV4IDkz
ZTMzMmQ1ZWQ3Ny4uMDM3YjgxMmE5NTMxIDEwMDY0NAotLS0gYS9tbS9tZW1vcnkuYworKysgYi9t
bS9tZW1vcnkuYwpAQCAtMjMyLDE3ICsyMzIsMTggQEAgdm9pZCB0bGJfZ2F0aGVyX21tdShzdHJ1
Y3QgbW11X2dhdGhlciAqdGxiLCBzdHJ1Y3QgbW1fc3RydWN0ICptbSwgdW5zaWduZWQgbG9uZwog
I2VuZGlmCiB9CiAKLXZvaWQgdGxiX2ZsdXNoX21tdShzdHJ1Y3QgbW11X2dhdGhlciAqdGxiKQor
c3RhdGljIHZvaWQgdGxiX2ZsdXNoX21tdV90bGJvbmx5KHN0cnVjdCBtbXVfZ2F0aGVyICp0bGIp
CiB7Ci0Jc3RydWN0IG1tdV9nYXRoZXJfYmF0Y2ggKmJhdGNoOwotCi0JaWYgKCF0bGItPm5lZWRf
Zmx1c2gpCi0JCXJldHVybjsKIAl0bGItPm5lZWRfZmx1c2ggPSAwOwogCXRsYl9mbHVzaCh0bGIp
OwogI2lmZGVmIENPTkZJR19IQVZFX1JDVV9UQUJMRV9GUkVFCiAJdGxiX3RhYmxlX2ZsdXNoKHRs
Yik7CiAjZW5kaWYKK30KKworc3RhdGljIHZvaWQgdGxiX2ZsdXNoX21tdV9mcmVlKHN0cnVjdCBt
bXVfZ2F0aGVyICp0bGIpCit7CisJc3RydWN0IG1tdV9nYXRoZXJfYmF0Y2ggKmJhdGNoOwogCiAJ
Zm9yIChiYXRjaCA9ICZ0bGItPmxvY2FsOyBiYXRjaDsgYmF0Y2ggPSBiYXRjaC0+bmV4dCkgewog
CQlmcmVlX3BhZ2VzX2FuZF9zd2FwX2NhY2hlKGJhdGNoLT5wYWdlcywgYmF0Y2gtPm5yKTsKQEAg
LTI1MSw2ICsyNTIsMTQgQEAgdm9pZCB0bGJfZmx1c2hfbW11KHN0cnVjdCBtbXVfZ2F0aGVyICp0
bGIpCiAJdGxiLT5hY3RpdmUgPSAmdGxiLT5sb2NhbDsKIH0KIAordm9pZCB0bGJfZmx1c2hfbW11
KHN0cnVjdCBtbXVfZ2F0aGVyICp0bGIpCit7CisJaWYgKCF0bGItPm5lZWRfZmx1c2gpCisJCXJl
dHVybjsKKwl0bGJfZmx1c2hfbW11X3RsYm9ubHkodGxiKTsKKwl0bGJfZmx1c2hfbW11X2ZyZWUo
dGxiKTsKK30KKwogLyogdGxiX2ZpbmlzaF9tbXUKICAqCUNhbGxlZCBhdCB0aGUgZW5kIG9mIHRo
ZSBzaG9vdGRvd24gb3BlcmF0aW9uIHRvIGZyZWUgdXAgYW55IHJlc291cmNlcwogICoJdGhhdCB3
ZXJlIHJlcXVpcmVkLgpAQCAtMTEyNyw4ICsxMTM2LDEwIEBAIGFnYWluOgogCQkJaWYgKFBhZ2VB
bm9uKHBhZ2UpKQogCQkJCXJzc1tNTV9BTk9OUEFHRVNdLS07CiAJCQllbHNlIHsKLQkJCQlpZiAo
cHRlX2RpcnR5KHB0ZW50KSkKKwkJCQlpZiAocHRlX2RpcnR5KHB0ZW50KSkgeworCQkJCQlmb3Jj
ZV9mbHVzaCA9IDE7CiAJCQkJCXNldF9wYWdlX2RpcnR5KHBhZ2UpOworCQkJCX0KIAkJCQlpZiAo
cHRlX3lvdW5nKHB0ZW50KSAmJgogCQkJCSAgICBsaWtlbHkoISh2bWEtPnZtX2ZsYWdzICYgVk1f
U0VRX1JFQUQpKSkKIAkJCQkJbWFya19wYWdlX2FjY2Vzc2VkKHBhZ2UpOwpAQCAtMTEzNyw5ICsx
MTQ4LDEwIEBAIGFnYWluOgogCQkJcGFnZV9yZW1vdmVfcm1hcChwYWdlKTsKIAkJCWlmICh1bmxp
a2VseShwYWdlX21hcGNvdW50KHBhZ2UpIDwgMCkpCiAJCQkJcHJpbnRfYmFkX3B0ZSh2bWEsIGFk
ZHIsIHB0ZW50LCBwYWdlKTsKLQkJCWZvcmNlX2ZsdXNoID0gIV9fdGxiX3JlbW92ZV9wYWdlKHRs
YiwgcGFnZSk7Ci0JCQlpZiAoZm9yY2VfZmx1c2gpCisJCQlpZiAodW5saWtlbHkoIV9fdGxiX3Jl
bW92ZV9wYWdlKHRsYiwgcGFnZSkpKSB7CisJCQkJZm9yY2VfZmx1c2ggPSAxOwogCQkJCWJyZWFr
OworCQkJfQogCQkJY29udGludWU7CiAJCX0KIAkJLyoKQEAgLTExNzQsMTggKzExODYsMTEgQEAg
YWdhaW46CiAKIAlhZGRfbW1fcnNzX3ZlYyhtbSwgcnNzKTsKIAlhcmNoX2xlYXZlX2xhenlfbW11
X21vZGUoKTsKLQlwdGVfdW5tYXBfdW5sb2NrKHN0YXJ0X3B0ZSwgcHRsKTsKIAotCS8qCi0JICog
bW11X2dhdGhlciByYW4gb3V0IG9mIHJvb20gdG8gYmF0Y2ggcGFnZXMsIHdlIGJyZWFrIG91dCBv
ZgotCSAqIHRoZSBQVEUgbG9jayB0byBhdm9pZCBkb2luZyB0aGUgcG90ZW50aWFsIGV4cGVuc2l2
ZSBUTEIgaW52YWxpZGF0ZQotCSAqIGFuZCBwYWdlLWZyZWUgd2hpbGUgaG9sZGluZyBpdC4KLQkg
Ki8KKwkvKiBEbyB0aGUgYWN0dWFsIFRMQiBmbHVzaCBiZWZvcmUgZHJvcHBpbmcgcHRsICovCiAJ
aWYgKGZvcmNlX2ZsdXNoKSB7CiAJCXVuc2lnbmVkIGxvbmcgb2xkX2VuZDsKIAotCQlmb3JjZV9m
bHVzaCA9IDA7Ci0KIAkJLyoKIAkJICogRmx1c2ggdGhlIFRMQiBqdXN0IGZvciB0aGUgcHJldmlv
dXMgc2VnbWVudCwKIAkJICogdGhlbiB1cGRhdGUgdGhlIHJhbmdlIHRvIGJlIHRoZSByZW1haW5p
bmcKQEAgLTExOTMsMTEgKzExOTgsMjEgQEAgYWdhaW46CiAJCSAqLwogCQlvbGRfZW5kID0gdGxi
LT5lbmQ7CiAJCXRsYi0+ZW5kID0gYWRkcjsKLQotCQl0bGJfZmx1c2hfbW11KHRsYik7Ci0KKwkJ
dGxiX2ZsdXNoX21tdV90bGJvbmx5KHRsYik7CiAJCXRsYi0+c3RhcnQgPSBhZGRyOwogCQl0bGIt
PmVuZCA9IG9sZF9lbmQ7CisJfQorCXB0ZV91bm1hcF91bmxvY2soc3RhcnRfcHRlLCBwdGwpOwor
CisJLyoKKwkgKiBJZiB3ZSBmb3JjZWQgYSBUTEIgZmx1c2ggKGVpdGhlciBkdWUgdG8gcnVubmlu
ZyBvdXQgb2YKKwkgKiBiYXRjaCBidWZmZXJzIG9yIGJlY2F1c2Ugd2UgbmVlZGVkIHRvIGZsdXNo
IGRpcnR5IFRMQgorCSAqIGVudHJpZXMgYmVmb3JlIHJlbGVhc2luZyB0aGUgcHRsKSwgZnJlZSB0
aGUgYmF0Y2hlZAorCSAqIG1lbW9yeSB0b28uIFJlc3RhcnQgaWYgd2UgZGlkbid0IGRvIGV2ZXJ5
dGhpbmcuCisJICovCisJaWYgKGZvcmNlX2ZsdXNoKSB7CisJCWZvcmNlX2ZsdXNoID0gMDsKKwkJ
dGxiX2ZsdXNoX21tdV9mcmVlKHRsYik7CiAKIAkJaWYgKGFkZHIgIT0gZW5kKQogCQkJZ290byBh
Z2FpbjsK
--047d7b3437521ee23e04f7d276af--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
