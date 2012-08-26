Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id B2E2D6B0082
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 06:12:30 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH 3/3] mm: Move the tlb flushing inside of unmap vmas
Date: Sun, 26 Aug 2012 13:11:39 +0300
Message-Id: <1345975899-2236-4-git-send-email-haggaie@mellanox.com>
In-Reply-To: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
References: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Haggai Eran <haggaie@mellanox.com>

From: Sagi Grimberg <sagig@mellanox.com>

This patch removes another hurdle preventing sleeping in mmu notifiers. It is
based on the assumption that we cannot sleep between calls to tlb_gather_mmu,
and tlb_finish_mmu.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 mm/memory.c | 12 ++++--------
 mm/mmap.c   |  7 -------
 2 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e721432..ca2e0cd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1327,6 +1327,9 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 	if (end <= vma->vm_start)
 		return;
 
+	lru_add_drain();
+	tlb_gather_mmu(tlb, vma->vm_mm, 0);
+	update_hiwater_rss(vma->vm_mm);
 	if (vma->vm_file)
 		uprobe_munmap(vma, start, end);
 
@@ -1354,6 +1357,7 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 		} else
 			unmap_page_range(tlb, vma, start, end, details);
 	}
+	tlb_finish_mmu(tlb, start_addr, end_addr);
 }
 
 /**
@@ -1402,14 +1406,10 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
 	struct mmu_gather tlb;
 	unsigned long end = start + size;
 
-	lru_add_drain();
-	tlb_gather_mmu(&tlb, mm, 0);
-	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, start, end);
 	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
 		unmap_single_vma(&tlb, vma, start, end, details);
 	mmu_notifier_invalidate_range_end(mm, start, end);
-	tlb_finish_mmu(&tlb, start, end);
 }
 
 /**
@@ -1428,13 +1428,9 @@ static void zap_page_range_single(struct vm_area_struct *vma, unsigned long addr
 	struct mmu_gather tlb;
 	unsigned long end = address + size;
 
-	lru_add_drain();
-	tlb_gather_mmu(&tlb, mm, 0);
-	update_hiwater_rss(mm);
 	mmu_notifier_invalidate_range_start(mm, address, end);
 	unmap_single_vma(&tlb, vma, address, end, details);
 	mmu_notifier_invalidate_range_end(mm, address, end);
-	tlb_finish_mmu(&tlb, address, end);
 }
 
 /**
diff --git a/mm/mmap.c b/mm/mmap.c
index 731da04..4b614fe 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1908,11 +1908,7 @@ static void unmap_region(struct mm_struct *mm,
 	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
 	struct mmu_gather tlb;
 
-	lru_add_drain();
-	tlb_gather_mmu(&tlb, mm, 0);
-	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end);
-	tlb_finish_mmu(&tlb, start, end);
 	free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
 				 next ? next->vm_start : 0);
 }
@@ -2288,14 +2284,11 @@ void exit_mmap(struct mm_struct *mm)
 	if (!vma)	/* Can happen if dup_mmap() received an OOM */
 		return;
 
-	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb_gather_mmu(&tlb, mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
-	tlb_finish_mmu(&tlb, 0, -1);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 
 	/*
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
