Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2326B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:49:04 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v20so1000751qtg.10
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 10:49:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m8si5493779qtg.301.2017.08.30.10.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 10:49:03 -0700 (PDT)
Date: Wed, 30 Aug 2017 13:48:58 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170830174857.GC2386@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <20170830165250.GD13559@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170830165250.GD13559@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 30, 2017 at 06:52:50PM +0200, Andrea Arcangeli wrote:
> Hello Jerome,
> 
> On Tue, Aug 29, 2017 at 07:54:36PM -0400, Jerome Glisse wrote:
> > Replacing all mmu_notifier_invalidate_page() by mmu_notifier_invalidat_range()
> > and making sure it is bracketed by call to mmu_notifier_invalidate_range_start/
> > end.
> > 
> > Note that because we can not presume the pmd value or pte value we have to
> > assume the worse and unconditionaly report an invalidation as happening.
> 
> I pointed out in earlier email ->invalidate_range can only be
> implemented (as mutually exclusive alternative to
> ->invalidate_range_start/end) by secondary MMUs that shares the very
> same pagetables with the core linux VM of the primary MMU, and those
> invalidate_range are already called by
> __mmu_notifier_invalidate_range_end. The other bit is done by the MMU
> gather (because mmu_notifier_invalidate_range_start is a noop for
> drivers that implement s->invalidate_range).
> 
> The difference between sharing the same pagetables or not allows for
> ->invalidate_range to work because when the Linux MM changes the
> primary MMU pagetables it also automatically invalidated updates
> secondary MMU at the same time (because of the pagetable sharing
> between primary and secondary MMUs). So then all that is left to do is
> an invalidate_range to flush the secondary MMU TLBs.
> 
> There's no need of action in mmu_notifier_invalidate_range_start for
> those pagetable sharing drivers because there's no risk of a secondary
> MMU shadow pagetable layer to be re-created in between
> mmu_notifier_invalidate_range_start and the actual pagetable
> invalidate because again the pagetables are shared.

Yes but we still need to call invalidate_range() while under the page
table spinlock as this hardware sharing the CPU page table have their
own tlb (not even talking about tlb of each individual devices that
use PASID/ATS).

If we do not call it under spinlock then there is a chance that something
else get mapped between the time we drop the CPU page table and the
time we call mmu_notifier_invalidate_range_end() which itself call
invalidate_range().

Actually i would remove the call to invalidate_range() from range_end()
and audit all places where we call range_end() to assert that there is
a call to invalidate_range() under the page table spinlock that preced
it.

> 
> void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> 				  unsigned long start, unsigned long end)
> {
> 	struct mmu_notifier *mn;
> 	int id;
> 
> 	id = srcu_read_lock(&srcu);
> 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> 		/*
> 		 * Call invalidate_range here too to avoid the need for the
> 		 * subsystem of having to register an invalidate_range_end
> 		 * call-back when there is invalidate_range already. Usually a
> 		 * subsystem registers either invalidate_range_start()/end() or
> 		 * invalidate_range(), so this will be no additional overhead
> 		 * (besides the pointer check).
> 		 */
> 		if (mn->ops->invalidate_range)
> 			mn->ops->invalidate_range(mn, mm, start, end);
> 			^^^^^^^^^^^^^^^^^^^^^^^^^
> 		if (mn->ops->invalidate_range_end)
> 			mn->ops->invalidate_range_end(mn, mm, start, end);
> 	}
> 	srcu_read_unlock(&srcu, id);
> }
> 
> So this conversion from invalidate_page to invalidate_range looks
> superflous and the final mmu_notifier_invalidate_range_end should be
> enough.

See above.

> AFIK only amd_iommu_v2 and intel-svm (svm as in shared virtual memory)
> uses it.

powerpc has something similar too but i don't know its status

> My suggestion is to remove from below all
> mmu_notifier_invalidate_range calls and keep only the
> mmu_notifier_invalidate_range_end and test both amd_iommu_v2 and
> intel-svm with it under heavy swapping.
> 
> The only critical constraint to keep for invalidate_range to stay safe
> with a single call of mmu_notifier_invalidate_range_end after put_page
> is that the put_page cannot be the last put_page. That only applies to
> the case where the page isn't freed through MMU gather (MMU gather
> calls mmu_notifier_invalidate_range of its own before freeing the
> page, as opposed mmu gather does nothing for drivers using
> invalidate_range_start/end because invalidate_range_start acted as
> barrier to avoid establishing mappings on the secondary MMUs for
> those).
> 
> Not strictly required but I think it would be safer and more efficient
> to replace the put_page with something like:
> 
> static inline void put_page_not_freeing(struct page *page)
> {
> 	page = compound_head(page);
> 
> 	if (put_page_testzero(page))
> 		VM_WARN_ON_PAGE(1, page);
> }

Yes adding such check make sense.

Thank for looking into this too

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
