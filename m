Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E328D6B0087
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 10:03:37 -0500 (EST)
Received: by mail-iw0-f169.google.com with SMTP id 38so3377619iwn.14
        for <linux-mm@kvack.org>; Sun, 28 Nov 2010 07:03:36 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 3/3] Prevent promotion of page in madvise_dontneed
Date: Mon, 29 Nov 2010 00:02:57 +0900
Message-Id: <48315b5fe54efa08982aa7df77e8abe793889e3a.1290956059.git.minchan.kim@gmail.com>
In-Reply-To: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
In-Reply-To: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Now zap_pte_range alwayas promotes pages which are pte_young &&
!VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
it's unnecessary since the page wouldn't use any more.

If the page is sharred by other processes and it's real working set

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Wu Fengguang <fengguang.wu@intel.com>

Changelog since v1:
- change word from promote to activate
- add activate argument to zap_pte_range and family function
---
 include/linux/mm.h |    4 ++--
 mm/madvise.c       |    4 ++--
 mm/memory.c        |   38 +++++++++++++++++++++++---------------
 mm/mmap.c          |    4 ++--
 4 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e097df6..6032881 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -779,11 +779,11 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
-		unsigned long size, struct zap_details *);
+		unsigned long size, struct zap_details *, bool activate);
 unsigned long unmap_vmas(struct mmu_gather **tlb,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *);
+		struct zap_details *, bool activate);
 
 /**
  * mm_walk - callbacks for walk_page_range
diff --git a/mm/madvise.c b/mm/madvise.c
index 319528b..8bc4b2d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -171,9 +171,9 @@ static long madvise_dontneed(struct vm_area_struct * vma,
 			.nonlinear_vma = vma,
 			.last_index = ULONG_MAX,
 		};
-		zap_page_range(vma, start, end - start, &details);
+		zap_page_range(vma, start, end - start, &details, false);
 	} else
-		zap_page_range(vma, start, end - start, NULL);
+		zap_page_range(vma, start, end - start, NULL, false);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 2c989f3..249e23a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -891,7 +891,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				long *zap_work, struct zap_details *details,
+				bool activate)
 {
 	struct mm_struct *mm = tlb->mm;
 	pte_t *pte;
@@ -949,7 +950,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent) &&
-				    likely(!VM_SequentialReadHint(vma)))
+				    likely(!VM_SequentialReadHint(vma)) &&
+					activate)
 					mark_page_accessed(page);
 				rss[MM_FILEPAGES]--;
 			}
@@ -989,7 +991,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				long *zap_work, struct zap_details *details,
+				bool activate)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -1002,7 +1005,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 			continue;
 		}
 		next = zap_pte_range(tlb, vma, pmd, addr, next,
-						zap_work, details);
+					zap_work, details, activate);
 	} while (pmd++, addr = next, (addr != end && *zap_work > 0));
 
 	return addr;
@@ -1011,7 +1014,8 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				long *zap_work, struct zap_details *details,
+				bool activate)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -1024,7 +1028,7 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 			continue;
 		}
 		next = zap_pmd_range(tlb, vma, pud, addr, next,
-						zap_work, details);
+					zap_work, details, activate);
 	} while (pud++, addr = next, (addr != end && *zap_work > 0));
 
 	return addr;
@@ -1033,7 +1037,8 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 static unsigned long unmap_page_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				long *zap_work, struct zap_details *details,
+				bool activate)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -1052,7 +1057,7 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
 			continue;
 		}
 		next = zap_pud_range(tlb, vma, pgd, addr, next,
-						zap_work, details);
+						zap_work, details, activate);
 	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
 	tlb_end_vma(tlb, vma);
 	mem_cgroup_uncharge_end();
@@ -1075,6 +1080,7 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
  * @end_addr: virtual address at which to end unmapping
  * @nr_accounted: Place number of unmapped pages in vm-accountable vma's here
  * @details: details of nonlinear truncation or shared cache invalidation
+ * @activate: whether pages included in the vma should be activated or not
  *
  * Returns the end address of the unmapping (restart addr if interrupted).
  *
@@ -1096,7 +1102,7 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
 unsigned long unmap_vmas(struct mmu_gather **tlbp,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *details)
+		struct zap_details *details, bool activate)
 {
 	long zap_work = ZAP_BLOCK_SIZE;
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
@@ -1149,8 +1155,8 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
 
 				start = end;
 			} else
-				start = unmap_page_range(*tlbp, vma,
-						start, end, &zap_work, details);
+				start = unmap_page_range(*tlbp, vma, start,
+					end, &zap_work, details, activate);
 
 			if (zap_work > 0) {
 				BUG_ON(start != end);
@@ -1184,9 +1190,10 @@ out:
  * @address: starting address of pages to zap
  * @size: number of bytes to zap
  * @details: details of nonlinear truncation or shared cache invalidation
+ * @activate: whether pages included in the vma should be activated or not
  */
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
-		unsigned long size, struct zap_details *details)
+		unsigned long size, struct zap_details *details, bool activate)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather *tlb;
@@ -1196,7 +1203,8 @@ unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted,
+		details, activate);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
@@ -1220,7 +1228,7 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 	if (address < vma->vm_start || address + size > vma->vm_end ||
 	    		!(vma->vm_flags & VM_PFNMAP))
 		return -1;
-	zap_page_range(vma, address, size, NULL);
+	zap_page_range(vma, address, size, NULL, false);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(zap_vma_ptes);
@@ -2481,7 +2489,7 @@ again:
 	}
 
 	restart_addr = zap_page_range(vma, start_addr,
-					end_addr - start_addr, details);
+			end_addr - start_addr, details, true);
 	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
 
 	if (restart_addr >= end_addr) {
diff --git a/mm/mmap.c b/mm/mmap.c
index b179abb..0ed5ab3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1904,7 +1904,7 @@ static void unmap_region(struct mm_struct *mm,
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL, true);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
@@ -2278,7 +2278,7 @@ void exit_mmap(struct mm_struct *mm)
 	tlb = tlb_gather_mmu(mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL, true);
 	vm_unacct_memory(nr_accounted);
 
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
