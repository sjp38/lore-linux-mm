Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A663B6B02AC
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 12:17:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so416173901pgq.7
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:17:35 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e4si19083968plj.170.2016.12.19.09.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 09:17:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] mm: drop unused argument of zap_page_range()
Date: Mon, 19 Dec 2016 20:17:21 +0300
Message-Id: <20161219171722.77995-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161219171722.77995-1-kirill.shutemov@linux.intel.com>
References: <20161219171722.77995-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There's no users of zap_page_range() who wants non-NULL 'details'.
Let's drop it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/s390/mm/gmap.c               | 2 +-
 arch/x86/mm/mpx.c                 | 2 +-
 drivers/android/binder.c          | 2 +-
 drivers/staging/android/ion/ion.c | 3 +--
 include/linux/mm.h                | 2 +-
 mm/madvise.c                      | 2 +-
 mm/memory.c                       | 5 ++---
 7 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index ec1f0dedb948..59ac93714fa4 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -687,7 +687,7 @@ void gmap_discard(struct gmap *gmap, unsigned long from, unsigned long to)
 		/* Find vma in the parent mm */
 		vma = find_vma(gmap->mm, vmaddr);
 		size = min(to - gaddr, PMD_SIZE - (gaddr & ~PMD_MASK));
-		zap_page_range(vma, vmaddr, size, NULL);
+		zap_page_range(vma, vmaddr, size);
 	}
 	up_read(&gmap->mm->mmap_sem);
 }
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index e4f800999b32..4bfb31e79d5d 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -796,7 +796,7 @@ static noinline int zap_bt_entries_mapping(struct mm_struct *mm,
 			return -EINVAL;
 
 		len = min(vma->vm_end, end) - addr;
-		zap_page_range(vma, addr, len, NULL);
+		zap_page_range(vma, addr, len);
 		trace_mpx_unmap_zap(addr, addr+len);
 
 		vma = vma->vm_next;
diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index 3c71b982bf2a..d97f6725cf8c 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -629,7 +629,7 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 		page = &proc->pages[(page_addr - proc->buffer) / PAGE_SIZE];
 		if (vma)
 			zap_page_range(vma, (uintptr_t)page_addr +
-				proc->user_buffer_offset, PAGE_SIZE, NULL);
+				proc->user_buffer_offset, PAGE_SIZE);
 err_vm_insert_page_failed:
 		unmap_kernel_range((unsigned long)page_addr, PAGE_SIZE);
 err_map_kernel_failed:
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index b653451843c8..0fb0e28ace70 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -865,8 +865,7 @@ static void ion_buffer_sync_for_device(struct ion_buffer *buffer,
 	list_for_each_entry(vma_list, &buffer->vmas, list) {
 		struct vm_area_struct *vma = vma_list->vma;
 
-		zap_page_range(vma, vma->vm_start, vma->vm_end - vma->vm_start,
-			       NULL);
+		zap_page_range(vma, vma->vm_start, vma->vm_end - vma->vm_start);
 	}
 	mutex_unlock(&buffer->lock);
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5f6bea4c9d41..92dcada8caaf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1158,7 +1158,7 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
 void zap_page_range(struct vm_area_struct *vma, unsigned long address,
-		unsigned long size, struct zap_details *);
+		unsigned long size);
 void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long start, unsigned long end);
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 0e3828eae9f8..aa4c502caecb 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -476,7 +476,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
 		return -EINVAL;
 
-	zap_page_range(vma, start, end - start, NULL);
+	zap_page_range(vma, start, end - start);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index c03b18f13619..6192ca3e45dc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1370,12 +1370,11 @@ void unmap_vmas(struct mmu_gather *tlb,
  * @vma: vm_area_struct holding the applicable pages
  * @start: starting address of pages to zap
  * @size: number of bytes to zap
- * @details: details of shared cache invalidation
  *
  * Caller must protect the VMA list
  */
 void zap_page_range(struct vm_area_struct *vma, unsigned long start,
-		unsigned long size, struct zap_details *details)
+		unsigned long size)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather tlb;
@@ -1386,7 +1385,7 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, start, end);
 	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
-		unmap_single_vma(&tlb, vma, start, end, details);
+		unmap_single_vma(&tlb, vma, start, end, NULL);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 	tlb_finish_mmu(&tlb, start, end);
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
