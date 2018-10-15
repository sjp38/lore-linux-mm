Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB416B000D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 07:37:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n23-v6so19634343pfk.23
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:37:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d11-v6si10442931pgg.91.2018.10.15.04.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 04:37:00 -0700 (PDT)
Date: Mon, 15 Oct 2018 12:36:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: thp: fix mmu_notifier in
 migrate_misplaced_transhuge_page()
Message-ID: <20181015113656.GG6931@suse.de>
References: <20181013002430.698-1-aarcange@redhat.com>
 <20181013002430.698-3-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181013002430.698-3-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Aaron Tomlin <atomlin@redhat.com>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 12, 2018 at 08:24:29PM -0400, Andrea Arcangeli wrote:
> change_huge_pmd() after arming the numa/protnone pmd doesn't flush the
> TLB right away. do_huge_pmd_numa_page() flushes the TLB before calling
> migrate_misplaced_transhuge_page(). By the time
> do_huge_pmd_numa_page() runs some CPU could still access the page
> through the TLB.
> 
> change_huge_pmd() before arming the numa/protnone transhuge pmd calls
> mmu_notifier_invalidate_range_start(). So there's no need of
> mmu_notifier_invalidate_range_start()/mmu_notifier_invalidate_range_only_end()
> sequence in migrate_misplaced_transhuge_page() too, because by the
> time migrate_misplaced_transhuge_page() runs, the pmd mapping has
> already been invalidated in the secondary MMUs. It has to or if a
> secondary MMU can still write to the page, the migrate_page_copy()
> would lose data.
> 
> However an explicit mmu_notifier_invalidate_range() is needed before
> migrate_misplaced_transhuge_page() starts copying the data of the
> transhuge page or the below can happen for MMU notifier users sharing
> the primary MMU pagetables and only implementing ->invalidate_range:
> 
> CPU0		CPU1		GPU sharing linux pagetables using
>                                 only ->invalidate_range
> -----------	------------	---------
> 				GPU secondary MMU writes to the page
> 				mapped by the transhuge pmd
> change_pmd_range()
> mmu..._range_start()
> ->invalidate_range_start() noop
> change_huge_pmd()
> set_pmd_at(numa/protnone)
> pmd_unlock()
> 		do_huge_pmd_numa_page()
> 		CPU TLB flush globally (1)
> 		CPU cannot write to page
> 		migrate_misplaced_transhuge_page()
> 				GPU writes to the page...
> 		migrate_page_copy()
> 				...GPU stops writing to the page
> CPU TLB flush (2)
> mmu..._range_end() (3)
> ->invalidate_range_stop() noop
> ->invalidate_range()
> 				GPU secondary MMU is invalidated
> 				and cannot write to the page anymore
> 				(too late)
> 
> Just like we need a CPU TLB flush (1) because the TLB flush (2)
> arrives too late, we also need a mmu_notifier_invalidate_range()
> before calling migrate_misplaced_transhuge_page(), because the
> ->invalidate_range() in (3) also arrives too late.
> 
> This requirement is the result of the lazy optimization in
> change_huge_pmd() that releases the pmd_lock without first flushing
> the TLB and without first calling mmu_notifier_invalidate_range().
> 
> Even converting the removed mmu_notifier_invalidate_range_only_end()
> into a mmu_notifier_invalidate_range_end() would not have been enough
> to fix this, because it run after migrate_page_copy().
> 
> After the hugepage data copy is done
> migrate_misplaced_transhuge_page() can proceed and call set_pmd_at
> without having to flush the TLB nor any secondary MMUs because the
> secondary MMU invalidate, just like the CPU TLB flush, has to happen
> before the migrate_page_copy() is called or it would be a bug in the
> first place (and it was for drivers using ->invalidate_range()).
> 
> KVM is unaffected because it doesn't implement ->invalidate_range().
> 
> The standard PAGE_SIZEd migrate_misplaced_page is less accelerated and
> uses the generic migrate_pages which transitions the pte from
> numa/protnone to a migration entry in try_to_unmap_one() and flushes
> TLBs and all mmu notifiers there before copying the page.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs
