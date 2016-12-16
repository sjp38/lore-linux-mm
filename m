Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC706B0253
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:16:02 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so122976894pfy.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:16:02 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q8si7941051pgf.282.2016.12.16.06.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:16:01 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] oom-reaper: use madvise_dontneed() instead of unmap_page_range()
Date: Fri, 16 Dec 2016 17:15:56 +0300
Message-Id: <20161216141556.75130-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161216141556.75130-1-kirill.shutemov@linux.intel.com>
References: <20161216141556.75130-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Logic on whether we can reap pages from the VMA should match what we
have in madvise_dontneed(). In particular, we should skip, VM_PFNMAP
VMAs, but we don't now.

Let's just call madvise_dontneed() from __oom_reap_task_mm(), so we
won't need to sync the logic in the future.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/internal.h |  7 +++----
 mm/madvise.c  |  2 +-
 mm/memory.c   |  2 +-
 mm/oom_kill.c | 15 ++-------------
 4 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 44d68895a9b9..5c355855e4ad 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -41,10 +41,9 @@ int do_swap_page(struct vm_fault *vmf);
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
-void unmap_page_range(struct mmu_gather *tlb,
-			     struct vm_area_struct *vma,
-			     unsigned long addr, unsigned long end,
-			     struct zap_details *details);
+long madvise_dontneed(struct vm_area_struct *vma,
+			     struct vm_area_struct **prev,
+			     unsigned long start, unsigned long end);
 
 extern int __do_page_cache_readahead(struct address_space *mapping,
 		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
diff --git a/mm/madvise.c b/mm/madvise.c
index aa4c502caecb..8c9f19b62b4a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -468,7 +468,7 @@ static long madvise_free(struct vm_area_struct *vma,
  * An interface that causes the system to free clean pages and flush
  * dirty pages is already available as msync(MS_INVALIDATE).
  */
-static long madvise_dontneed(struct vm_area_struct *vma,
+long madvise_dontneed(struct vm_area_struct *vma,
 			     struct vm_area_struct **prev,
 			     unsigned long start, unsigned long end)
 {
diff --git a/mm/memory.c b/mm/memory.c
index eed102070dcb..f8836232a492 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1271,7 +1271,7 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	return addr;
 }
 
-void unmap_page_range(struct mmu_gather *tlb,
+static void unmap_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end,
 			     struct zap_details *details)
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 96a53ab0c9eb..59a00b1c3145 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -479,7 +479,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 *				out_of_memory
 	 *				  select_bad_process
 	 *				    # no TIF_MEMDIE task selects new victim
-	 *  unmap_page_range # frees some memory
+	 *  madvise_dontneed # frees some memory
 	 */
 	mutex_lock(&oom_lock);
 
@@ -508,16 +508,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
-		if (is_vm_hugetlb_page(vma))
-			continue;
-
-		/*
-		 * mlocked VMAs require explicit munlocking before unmap.
-		 * Let's keep it simple here and skip such VMAs.
-		 */
-		if (vma->vm_flags & VM_LOCKED)
-			continue;
-
 		/*
 		 * Only anonymous pages have a good chance to be dropped
 		 * without additional steps which we cannot afford as we
@@ -529,8 +519,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		 * count elevated without a good reason.
 		 */
 		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
-			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
-					 NULL);
+			madvise_dontneed(vma, &vma, vma->vm_start, vma->vm_end);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
