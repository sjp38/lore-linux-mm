Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA49C8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 05:09:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d47-v6so2164306edb.3
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 02:09:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45-v6si2165156eds.137.2018.09.13.02.09.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 02:09:51 -0700 (PDT)
Date: Thu, 13 Sep 2018 11:09:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180913090950.GD20287@dhcp22.suse.cz>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
 <20180912075054.GZ10951@dhcp22.suse.cz>
 <20180912134203.GJ10951@dhcp22.suse.cz>
 <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu 13-09-18 11:44:03, Tetsuo Handa wrote:
> On 2018/09/12 22:42, Michal Hocko wrote:
> > On Wed 12-09-18 09:50:54, Michal Hocko wrote:
> >> On Tue 11-09-18 23:01:57, Tetsuo Handa wrote:
> >>> On 2018/09/10 21:55, Michal Hocko wrote:
> >>>> This is a very coarse implementation of the idea I've had before.
> >>>> Please note that I haven't tested it yet. It is mostly to show the
> >>>> direction I would wish to go for.
> >>>
> >>> Hmm, this patchset does not allow me to boot. ;-)
> >>>
> >>>         free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
> >>>                         FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> >>>
> >>> [    1.875675] sched_clock: Marking stable (1810466565, 65169393)->(1977240380, -101604422)
> >>> [    1.877833] registered taskstats version 1
> >>> [    1.877853] Loading compiled-in X.509 certificates
> >>> [    1.878835] zswap: loaded using pool lzo/zbud
> >>> [    1.880835] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> >>
> >> This is vm_prev == NULL. I thought we always have vm_prev as long as
> >> this is not a single VMA in the address space. I will double check this.
> > 
> > So this is me misunderstanding the code. vm_next, vm_prev are not a full
> > doubly linked list. The first entry doesn't really refer to the last
> > entry. So the above cannot work at all. We can go around this in two
> > ways. Either keep the iteration or use the following which should cover
> > the full mapped range, unless I am missing something
> > 
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 64e8ccce5282..078295344a17 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -3105,7 +3105,7 @@ void exit_mmap(struct mm_struct *mm)
> >  		up_write(&mm->mmap_sem);
> >  	}
> >  
> > -	free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
> > +	free_pgd_range(&tlb, vma->vm_start, mm->highest_vm_end,
> >  			FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> >  	tlb_finish_mmu(&tlb, 0, -1);
> >  
> 
> This is bad because architectures where hugetlb_free_pgd_range() does
> more than free_pgd_range() need to check VM_HUGETLB flag for each "vma".
> Thus, I think we need to keep the iteration.

Fair point. I have looked more closely and most of them simply redirect
to free_pgd_range but ppc and sparc are doing some pretty involved
tricks which we cannot really skip. So I will go and split
free_pgtables into two phases and keep per vma loops. So this
incremental update on top

commit e568c3f34e11c1a7abb4fe6f26e51eb8f60620c3
Author: Michal Hocko <mhocko@suse.com>
Date:   Thu Sep 13 11:08:00 2018 +0200

    fold me "mm, oom: hand over MMF_OOM_SKIP to exit path if it is guranteed to finish"
    
    - split free_pgtables into unlinking and actual freeing part. We cannot
      rely on free_pgd_range because of hugetlb pages on ppc resp. sparc
      which do their own tear down

diff --git a/mm/internal.h b/mm/internal.h
index 87256ae1bef8..35adbfec4935 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -40,6 +40,9 @@ void page_writeback_init(void);
 
 vm_fault_t do_swap_page(struct vm_fault *vmf);
 
+void __unlink_vmas(struct vm_area_struct *vma);
+void __free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
+		unsigned long floor, unsigned long ceiling);
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..cf910ed5f283 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -612,20 +612,23 @@ void free_pgd_range(struct mmu_gather *tlb,
 	} while (pgd++, addr = next, addr != end);
 }
 
-void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
+void __unlink_vmas(struct vm_area_struct *vma)
+{
+	while (vma) {
+		unlink_anon_vmas(vma);
+		unlink_file_vma(vma);
+		vma = vma->vm_next;
+	}
+}
+
+/* expects that __unlink_vmas has been called already */
+void __free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
 		unsigned long addr = vma->vm_start;
 
-		/*
-		 * Hide vma from rmap and truncate_pagecache before freeing
-		 * pgtables
-		 */
-		unlink_anon_vmas(vma);
-		unlink_file_vma(vma);
-
 		if (is_vm_hugetlb_page(vma)) {
 			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next ? next->vm_start : ceiling);
@@ -637,8 +640,6 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
 				next = vma->vm_next;
-				unlink_anon_vmas(vma);
-				unlink_file_vma(vma);
 			}
 			free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next ? next->vm_start : ceiling);
@@ -647,6 +648,13 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	}
 }
 
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		unsigned long floor, unsigned long ceiling)
+{
+	__unlink_vmas(vma);
+	__free_pgtables(tlb, vma, floor, ceiling);
+}
+
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 {
 	spinlock_t *ptl;
diff --git a/mm/mmap.c b/mm/mmap.c
index 078295344a17..f4b562e21764 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3082,20 +3082,14 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
-	/* oom_reaper cannot race with the page tables teardown */
-	if (oom)
-		down_write(&mm->mmap_sem);
 	/*
-	 * Hide vma from rmap and truncate_pagecache before freeing
-	 * pgtables
+	 * oom_reaper cannot race with the page tables teardown but we
+	 * want to make sure that the exit path can take over the full
+	 * tear down when it is safe to do so
 	 */
-	while (vma) {
-		unlink_anon_vmas(vma);
-		unlink_file_vma(vma);
-		vma = vma->vm_next;
-	}
-	vma = mm->mmap;
 	if (oom) {
+		down_write(&mm->mmap_sem);
+		__unlink_vmas(vma);
 		/*
 		 * the exit path is guaranteed to finish the memory tear down
 		 * without any unbound blocking at this stage so make it clear
@@ -3103,10 +3097,11 @@ void exit_mmap(struct mm_struct *mm)
 		 */
 		mm->mmap = NULL;
 		up_write(&mm->mmap_sem);
+		__free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
+	} else {
+		free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	}
 
-	free_pgd_range(&tlb, vma->vm_start, mm->highest_vm_end,
-			FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
 	/*
-- 
Michal Hocko
SUSE Labs
