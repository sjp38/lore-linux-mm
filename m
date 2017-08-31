Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF146B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 13:12:47 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u63so536039qkb.5
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 10:12:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4si190075qtj.358.2017.08.31.10.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 10:12:46 -0700 (PDT)
Date: Thu, 31 Aug 2017 19:12:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170831171241.GE31400@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
 <20170830172747.GE13559@redhat.com>
 <003685D9-4DA9-42DC-AF46-7A9F8A43E61F@gmail.com>
 <20170830212514.GI13559@redhat.com>
 <75825BFF-8ACC-4CAB-93EB-AD9673747518@gmail.com>
 <20170831004719.GF9445@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170831004719.GF9445@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Nadav Amit <nadav.amit@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, iommu <iommu@lists.linux-foundation.org>

On Wed, Aug 30, 2017 at 08:47:19PM -0400, Jerome Glisse wrote:
> On Wed, Aug 30, 2017 at 04:25:54PM -0700, Nadav Amit wrote:
> > For both CoW and KSM, the correctness is maintained by calling
> > ptep_clear_flush_notify(). If you defer the secondary MMU invalidation
> > (i.e., replacing ptep_clear_flush_notify() with ptep_clear_flush() ), you
> > will cause memory corruption, and page-lock would not be enough.
> 
> Just to add up, the IOMMU have its own CPU page table walker and it can
> walk the page table at any time (not the page table current to current
> CPU, IOMMU have an array that match a PASID with a page table and device
> request translation for a given virtual address against a PASID).
> 
> So this means the following can happen with ptep_clear_flush() only:
> 
>   CPU                          | IOMMU
>                                | - walk page table populate tlb at addr A
>   - clear pte at addr A        |
>   - set new pte                |
      mmu_notifier_invalidate_range_end | -flush IOMMU/device tlb

> 
> Device is using old page and CPU new page :(

That condition won't be persistent.

> 
> But with ptep_clear_flush_notify()
> 
>   CPU                          | IOMMU
>                                | - walk page table populate tlb at addr A
>   - clear pte at addr A        |
>   - notify -> invalidate_range | > flush IOMMU/device tlb
>   - set new pte                |
> 
> So now either the IOMMU see the empty pte and trigger a page fault (this is
> if there is a racing IOMMU ATS right after the IOMMU/device tlb flush but
> before setting the new pte) or it see the new pte. Either way both IOMMU
> and CPU have a coherent view of what a virtual address points to.

Sure, the _notify version is obviously safe.

> Andrea explained to me the historical reasons set_pte_at_notify call the
> change_pte callback and it was intended so that KVM could update the
> secondary page table directly without having to fault. It is now a pointless
> optimization as the call to range_start() happening in all the places before
> any set_pte_at_notify() invalidate the secondary page table and thus will
> lead to page fault for the vm. I have talk with Andrea on way to bring back
> this optimization.

Yes, we known for a long time, the optimization got basically disabled
when range_start/end expanded. It'd be nice to optimize change_pte
again but this is for later.

> Yes we need the following sequence for IOMMU:
>  - clear pte
>  - invalidate IOMMU/device TLB
>  - set new pte
> 
> Otherwise the IOMMU page table walker can populate IOMMU/device tlb with
> stall entry.
> 
> Note that this is not necessary for all the case. For try_to_unmap it
> is fine for instance to move the IOMMU tlb shoot down after changing the
> CPU page table as we are not pointing the pte to a different page. Either
> we clear the pte or we set a swap entry and as long as the page that use
> to be pointed by the pte is not free before the IOMMU tlb flush then we
> are fine.
> 
> In fact i think the only case where we need the above sequence (clear,
> flush secondary tlb, set new pte) is for COW. I think all other cases
> we can get rid of invalidate_range() from inside the page table lock
> and rely on invalidate_range_end() to call unconditionaly.

Even with CoW, it's not big issue if the IOMMU keeps reading from the
old page for a little while longer (in between PT lock release and
mmu_notifier_invalidate_range_end).

How can you tell you read the old data a bit longer, because it
noticed the new page only when mmu_notifier_invalidate_range_end run,
and not because the CPU was faster at writing than the IOMMU was fast
at loading the new pagetable?

I figure it would be detectable only that the CPU could see pageA
changing before pageB. The iommu-v2 could see pageB changing before
pageA. If that's a concern that is the only good reason I can think of
right now, for requiring ->invalidate_page inside the CoW PT lock to
enforce the same ordering. However if the modifications happens
simultaneously and it's a correct runtime, the order must not matter,
but still it would be detectable which may not be desirable.

Currently the _notify is absolutely needed to run ->invalidate_range
before put_page is run in the CoW code below, because of the put_page
that is done in a not scalable place, it would be better moved down
regardless of ->invalidate_range to reduce the size of the PT lock
protected critical section.

-	if (new_page)
-		put_page(new_page);

	pte_unmap_unlock(vmf->pte, vmf->ptl);
	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	if (new_page)
+		put_page(new_page);

Of course the iommu will not immediately start reading from the new
page, but even if it triggers a write protect fault and calls
handle_mm_fault, it will find a writeable pte already there and it'll
get an ->invalidate_range as soon as mmu_notifier_invalidate_range_end
runs so it can sure notice the new page.

Now write_protect_page in KSM...

What bad can happen if iommu keeps writing to the write protected
page, for a little while longer? As long as nothing writes to the page
anymore by the time write_protect_page() returns, pages_identical will
work. How do you know the IOMMU was just a bit faster and wrote a few
more bytes and it wasn't mmu_notifier_invalidate_range_end  that run a
bit later after dropping the PT lock?

Now replace_page in KSM...

	ptep_clear_flush_notify(vma, addr, ptep);
	set_pte_at_notify(mm, addr, ptep, newpte);

	page_remove_rmap(page, false);
	if (!page_mapped(page))
		try_to_free_swap(page);
-	put_page(page);

	pte_unmap_unlock(ptep, ptl);
	err = 0;
out_mn:
	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
out:
+	put_page(page); /* TODO: broken of course, fix error cases */
	return err;
}

If we free the old page after mmu_notifier_invalidate_range_end
(fixing up the error case, the above change ignores the error paths),
the content of the old and new page are identical for replace_page.

Even if new page takes immediately a COW, how do you know the IOMMU
was just a bit slower and read the old page content pre-COW? They're
guaranteed identical and both readonly already at that point.

All the above considered, if this is getting way too complex, it may
be preferable to keep things obviously safe and always run
mmu_notifier_invalidate_range inside the PT lock and be done with it,
and remove the ->invalidate_range from
mmu_notifier_invalidate_range_end too to avoid the double invalidates
for the secondary MMUs with hardware pagetable walkers and shared
pagetables with the primary MMU.

In principle the primary reason for doing _notify or explicit
mmu_notifier_invalidate_range() is to keep things simpler and to avoid
having to care where pages exactly gets freed (i.e. before or after
mmu_notifier_invalidate_range_end).

For example zap_page_range tlb gather freeing strictly requires an
explicit mmu_notifier_invalidate_range before the page is actually
freed (because the tlb gather will free the pages well before
mmu_notifier_invalidate_range_end can run).

The concern that an ->invalidate_range is always needed before PT lock
is released if the primary TLB was flushed inside PT lock, is a more
recent concern and it looks like to me it's not always needed but
perhaps only in some case.

An example where the ->invalidate_range inside
mmu_notifier_invalidate_range_end pays off, is madvise_free_pte_range.
That doesn't flush the TLB before setting the pagetable clean. So the
primary MMU can still write through the dirty primary TLB without
setting the dirty/accessed bit after madvise_free_pte_range returns.

			ptent = ptep_get_and_clear_full(mm, addr, pte,
							tlb->fullmm);

			ptent = pte_mkold(ptent);
			ptent = pte_mkclean(ptent);
			set_pte_at(mm, addr, pte, ptent);
			tlb_remove_tlb_entry(tlb, pte, addr);

Not even the primary TLB is flushed here. All concurrent writes of the
primary MMU can still go lost while MADV_FREE runs. All that is
guaranteed is that after madvise MADV_FREE syscall returns to
userland, the new writes will stick, so then it's also enough to call
->invalidate_range inside the single
mmu_notifier_invalidate_range_end:

	madvise_free_page_range(&tlb, vma, start, end);
	mmu_notifier_invalidate_range_end(mm, start, end);
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This why we got both _notify and mmu_notifier_invalidate_range_end. If
we remove ->invalidate_range from mmu_notifier_invalidate_range_end,
we'll have to add a mmu_notifier_invalidate_range in places like above
(just before or just after mmu_notifier_invalidate_range_end above).

So with ptep_clear_flush_notify that avoids any issue with page
freeing in places like CoW, and the explicit
mmu_notifier_invalidate_range in the tlb gather, the rest got covered
automatically by mmu_notifier_invalidate_range_end. And again this is
only started to be needed when we added support for hardware pagetable
walkers that cannot stop the pagetable walking (unless they break the
sharing of the pagetable with the primary MMU which of course is not
desirable and it would cause unnecessary overhead).

The current ->invalidate_range handling however results in double
calls here and there when armed, but it reduces the number of explicit
hooks required in the common code and it keeps the mmu_notifier code
less intrusive and more optimal when disarmed (but less optimal when
armed). So the current state is a reasonable tradeoff, but there's
room for optimization.

> I might ponder on all this for more cleanup for mmu_notifier as i have
> some optimization that i have line up for it but this is next cycle
> material. For 4.13 i believe the current patchset is the safest way
> to go.

Yes, lots of material above for pondering, but the current status is
fine.

Did you look in reducing the range flushed in try_to_unmap_once to
PAGE_SIZE << compound_order(page)? That looked a straightforward
optimization possible that won't add any complexity and it would avoid
to worsen the granularity of the invalidates during try_to_unmap
compared to the previous code.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
