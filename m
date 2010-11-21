Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 97F4D6B0088
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 09:30:59 -0500 (EST)
Received: by pwi6 with SMTP id 6so1268837pwi.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 06:30:57 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 2/2] Prevent promotion of page in madvise_dontneed
Date: Sun, 21 Nov 2010 23:30:24 +0900
Message-Id: <5d205f8a4df078b0da3681063bbf37382b02dd23.1290349672.git.minchan.kim@gmail.com>
In-Reply-To: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
In-Reply-To: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
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
---
 include/linux/mm.h |    4 ++--
 mm/madvise.c       |    4 ++--
 mm/memory.c        |    9 ++++++---
 mm/mmap.c          |    4 ++--
 4 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 721f451..1555abe 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -778,11 +778,11 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
-		unsigned long size, struct zap_details *);
+		unsigned long size, struct zap_details *, int promote);
 unsigned long unmap_vmas(struct mmu_gather **tlb,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *);
+		struct zap_details *, int promote);
 
 /**
  * mm_walk - callbacks for walk_page_range
diff --git a/mm/madvise.c b/mm/madvise.c
index 319528b..247e5fd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -171,9 +171,9 @@ static long madvise_dontneed(struct vm_area_struct * vma,
 			.nonlinear_vma = vma,
 			.last_index = ULONG_MAX,
 		};
-		zap_page_range(vma, start, end - start, &details);
+		zap_page_range(vma, start, end - start, &details, 0);
 	} else
-		zap_page_range(vma, start, end - start, NULL);
+		zap_page_range(vma, start, end - start, NULL, 0);
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 02e48aa..276abdb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1075,6 +1075,7 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
  * @end_addr: virtual address at which to end unmapping
  * @nr_accounted: Place number of unmapped pages in vm-accountable vma's here
  * @details: details of nonlinear truncation or shared cache invalidation
+ * @promote: whether pages inclued vma would be promoted or not
  *
  * Returns the end address of the unmapping (restart addr if interrupted).
  *
@@ -1096,7 +1097,7 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
 unsigned long unmap_vmas(struct mmu_gather **tlbp,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
-		struct zap_details *details)
+		struct zap_details *details, int promote)
 {
 	long zap_work = ZAP_BLOCK_SIZE;
 	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
@@ -1184,9 +1185,10 @@ out:
  * @address: starting address of pages to zap
  * @size: number of bytes to zap
  * @details: details of nonlinear truncation or shared cache invalidation
+ * @promote: whether the page would be promoted or not
  */
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
-		unsigned long size, struct zap_details *details)
+		unsigned long size, struct zap_details *details, int promote)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mmu_gather *tlb;
@@ -1196,7 +1198,8 @@ unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	end = unmap_vmas(&tlb, vma, address, end,
+			&nr_accounted, details, promote);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
diff --git a/mm/mmap.c b/mm/mmap.c
index b179abb..0d42c08 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1904,7 +1904,7 @@ static void unmap_region(struct mm_struct *mm,
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL, 1);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
@@ -2278,7 +2278,7 @@ void exit_mmap(struct mm_struct *mm)
 	tlb = tlb_gather_mmu(mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL, 1);
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
