Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB1376B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:45:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c76so22208573qkj.11
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:45:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t29si6145972qte.300.2017.08.30.13.45.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 13:45:55 -0700 (PDT)
Date: Wed, 30 Aug 2017 16:45:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170830204549.GA9445@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
 <20170830172747.GE13559@redhat.com>
 <20170830182013.GD2386@redhat.com>
 <180A2625-E3AB-44BF-A3B7-E687299B9DA9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <180A2625-E3AB-44BF-A3B7-E687299B9DA9@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 30, 2017 at 11:40:08AM -0700, Nadav Amit wrote:
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > On Wed, Aug 30, 2017 at 07:27:47PM +0200, Andrea Arcangeli wrote:
> >> On Tue, Aug 29, 2017 at 07:46:07PM -0700, Nadav Amit wrote:
> >>> Therefore, IIUC, try_to_umap_one() should only call
> >>> mmu_notifier_invalidate_range() after ptep_get_and_clear() and
> >> 
> >> That would trigger an unnecessarily double call to
> >> ->invalidate_range() both from mmu_notifier_invalidate_range() after
> >> ptep_get_and_clear() and later at the end in
> >> mmu_notifier_invalidate_range_end().
> >> 
> >> The only advantage of adding a mmu_notifier_invalidate_range() after
> >> ptep_get_and_clear() is to flush the secondary MMU TLBs (keep in mind
> >> the pagetables have to be shared with the primary MMU in order to use
> >> the ->invalidate_range()) inside the PT lock.
> >> 
> >> So if mmu_notifier_invalidate_range() after ptep_get_and_clear() is
> >> needed or not, again boils down to the issue if the old code calling
> >> ->invalidate_page outside the PT lock was always broken before or
> >> not. I don't see why exactly it was broken, we even hold the page lock
> >> there so I don't see a migration race possible either. Of course the
> >> constraint to be safe is that the put_page in try_to_unmap_one cannot
> >> be the last one, and that had to be enforced by the caller taking an
> >> additional reference on it.
> >> 
> >> One can wonder if the primary MMU TLB flush in ptep_clear_flush
> >> (should_defer_flush returning false) could be put after releasing the
> >> PT lock too (because that's not different from deferring the secondary
> >> MMU notifier TLB flush in ->invalidate_range down to
> >> mmu_notifier_invalidate_range_end) even if TTU_BATCH_FLUSH isn't set,
> >> which may be safe too for the same reasons.
> >> 
> >> When should_defer_flush returns true we already defer the primary MMU
> >> TLB flush to much later to even mmu_notifier_invalidate_range_end, not
> >> just after the PT lock release so at least when should_defer_flush is
> >> true, it looks obviously safe to defer the secondary MMU TLB flush to
> >> mmu_notifier_invalidate_range_end for the drivers implementing
> >> ->invalidate_range.
> >> 
> >> If I'm wrong and all TLB flushes must happen inside the PT lock, then
> >> we should at least reconsider the implicit call to ->invalidate_range
> >> method from mmu_notifier_invalidate_range_end or we would call it
> >> twice unnecessarily which doesn't look optimal. Either ways this
> >> doesn't look optimal. We would need to introduce a
> >> mmu_notifier_invalidate_range_end_full that calls also
> >> ->invalidate_range in such case so we skip the ->invalidate_range call
> >> in mmu_notifier_invalidate_range_end if we put an explicit
> >> mmu_notifier_invalidate_range() after ptep_get_and_clear inside the PT
> >> lock like you suggested above.
> > 
> > So i went over call to try_to_unmap() (try_to_munlock() is fine as it
> > does not clear the CPU page table entry). I believe they are 2 cases
> > where you can get a new pte entry after we release spinlock and before
> > we call mmu_notifier_invalidate_range_end()
> > 
> > First case is :
> > if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
> >  ...
> >  break;
> > }
> > 
> > The pte is clear, there was an error condition and this should never
> > happen but a racing thread might install a new pte in the meantime.
> > Maybe we should restore the pte value here. Anyway when this happens
> > bad things are going on.
> > 
> > The second case is non dirty anonymous page and MADV_FREE. But here
> > the application is telling us that no one should care about that
> > virtual address any more. So i am not sure how much we should care.
> > 
> > 
> > If we ignore this 2 cases than the CPU pte can never be replace by
> > something else between the time we release the spinlock and the time
> > we call mmu_notifier_invalidate_range_end() so not invalidating the
> > devices tlb is ok here. Do we want this kind of optimization ?
> 
> The mmu_notifier users would have to be aware that invalidations may be
> deferred. If they perform their ``invalidationsa??a?? unconditionally, it may be
> ok. If the notifier users avoid invalidations based on the PTE in the
> secondary page-table, it can be a problem.

So i look at both AMD and Intel IOMMU. AMD always flush and current pte value
do not matter AFAICT (i doubt that hardware rewalk the page table just to
decide not to flush that would be terribly dumb for hardware engineer to do
so).

Intel have a deferred flush mecanism, basicly if no device is actively using
the page table then there is no flush (see deferred invalidation in [1]). But
i am unsure about the hardware ie does it also means that when a PASID is not
actively use then the IOMMU TLB is also invalid for that PASID. Also i am bit
unsure about ATS/PASID specification in respect to having device always report
when they are done with a given PASID (ie does the spec say that device tlb
must be invalidated when device stop using a pasid).

https://www.intel.com/content/www/us/en/embedded/technology/virtualization/vt-directed-io-spec.html

So i think we can side with caution here and call invalidate_range() under the
page table lock. If IOMMU folks see performance issue with real workload due
to the double invalidation that take place then we can work on that.

KVM or XEN are not impacted by this as they only care about start/end with this
patchset.

Andrea is that inline with your assessment ?


> On another note, you may want to consider combining the secondary page-table
> mechanisms with the existing TLB-flush mechanisms. Right now, it is
> partially done: tlb_flush_mmu_tlbonly(), for example, calls
> mmu_notifier_invalidate_range(). However, tlb_gather_mmu() does not call
> mmu_notifier_invalidate_range_start().

tlb_gather_mmu() is always call in place that are themself bracketed by
mmu_notifier_invalidate_range_start()/end()

> 
> This can also prevent all kind of inconsistencies, and potential bugs. For
> instance, clear_refs_write() calls mmu_notifier_invalidate_range_start/end()
> but in between there is no call for mmu_notifier_invalidate_range().

It is for softdirty, we should probably invalidate_range() in that case i
need to check how dirtyness is handled in ATS/PASID ie does device update
the dirty bit of the CPU page table on write. Or maybe device don't update
the dirty flag.

JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
