Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9E766B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 18:17:43 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g13so23199631qta.6
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:17:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x3si6467828qtf.188.2017.08.30.15.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 15:17:42 -0700 (PDT)
Date: Thu, 31 Aug 2017 00:17:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Message-ID: <20170830221739.GK13559@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-3-jglisse@redhat.com>
 <6D58FBE4-5D03-49CC-AAFF-3C1279A5A849@gmail.com>
 <20170830172747.GE13559@redhat.com>
 <20170830182013.GD2386@redhat.com>
 <180A2625-E3AB-44BF-A3B7-E687299B9DA9@gmail.com>
 <20170830204549.GA9445@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830204549.GA9445@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Nadav Amit <nadav.amit@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 30, 2017 at 04:45:49PM -0400, Jerome Glisse wrote:
> So i look at both AMD and Intel IOMMU. AMD always flush and current pte value
> do not matter AFAICT (i doubt that hardware rewalk the page table just to
> decide not to flush that would be terribly dumb for hardware engineer to do
> so).
> 
> Intel have a deferred flush mecanism, basicly if no device is actively using
> the page table then there is no flush (see deferred invalidation in [1]). But
> i am unsure about the hardware ie does it also means that when a PASID is not
> actively use then the IOMMU TLB is also invalid for that PASID. Also i am bit
> unsure about ATS/PASID specification in respect to having device always report
> when they are done with a given PASID (ie does the spec say that device tlb
> must be invalidated when device stop using a pasid).
> 
> https://www.intel.com/content/www/us/en/embedded/technology/virtualization/vt-directed-io-spec.html
> 
> So i think we can side with caution here and call invalidate_range() under the
> page table lock. If IOMMU folks see performance issue with real workload due
> to the double invalidation that take place then we can work on that.
> 
> KVM or XEN are not impacted by this as they only care about start/end with this
> patchset.
> 
> Andrea is that inline with your assessment ?

That is obviously safe. The mmu_notifier_invalidate_range()
calls under PT lock could always be removed later.

However I'm afraid I've to figure out if
mmu_notifier_invalidate_range() must run inside the PT lock
regardless, because that's just the very same problem of
->invalidate_page run outside the PT lock with a majority of
production kernels out there:

	pte_unmap_unlock(pte, ptl);
	if (ret != SWAP_FAIL && ret != SWAP_MLOCK && !(flags & TTU_MUNLOCK))
		mmu_notifier_invalidate_page(mm, address);

So even if we take the easy route for mmu_notifier_invalidate_range,
I'm still forced to think about this issue.

Currently I tend to believe the old code is safe and in turn I'm more
inclined to skip the explicit mmu_notifier_invalidate_range() inside
the PT lock for amd_iommu_v2 and intel-svm, and add it later if it's
truly proven unsafe.

However as long as the reason for this is just to keep it simpler and
robustness, I don't mind either ways. Double call is not nice though
and not doing double call will mess the code more.

So I thought it was attractive to explain why it was safe not to run
mmu_notifier_invalidate_range() inside the PT lock, which would then
allow for the most strightforward and more optimal upstream
implementation (in addition of not having to fix the old code).

> It is for softdirty, we should probably invalidate_range() in that case i
> need to check how dirtyness is handled in ATS/PASID ie does device update
> the dirty bit of the CPU page table on write. Or maybe device don't update
> the dirty flag.

They both call handle_mm_fault and establish a readonly secondary MMU
mapping and then call handle_mm_fault again before there's a DMA to
memory, to establish a writable mapping and set the dirty bit here at
the first write fault post read fault:

	bool write = vmf->flags & FAULT_FLAG_WRITE;

	vmf->ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
		goto unlock;

	entry = pmd_mkyoung(orig_pmd);
	if (write)
		entry = pmd_mkdirty(entry);
[..]
	if (vmf->flags & FAULT_FLAG_WRITE) {
		if (!pte_write(entry))
			return do_wp_page(vmf);
		entry = pte_mkdirty(entry);
	}

I doubt the PT lock is relevant for how the dirty bit gets set by
those two faulting-capable iommus.

All it matters is that post clear_refs_write there's a
mmu_notifier_invalidate_range_end so ->invalidate_range is called and
at the next write they call handle_mm_fault(FAULT_FLAG_WRITE) once
again. Where exactly the invalidate runs (i.e. post PT lock) I don't
see a big issue there, definitely clear_refs wouldn't change the
pte/hugepmd to point to a different page, so any coherency issue with
primary and secondary MMU temporarily being out of sync doesn't exist
there.

Kirill is the last committer to the handle_mm_fault line in both
drivers so it'd be great if he can double check to confirm that's the
way the dirty bit is handled and in turn causes no concern at
->invalidate_range time.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
