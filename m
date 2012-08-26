Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 2ED766B0080
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 06:12:28 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH 2/3] mm: Move the tlb flushing into free_pgtables
Date: Sun, 26 Aug 2012 13:11:38 +0300
Message-Id: <1345975899-2236-3-git-send-email-haggaie@mellanox.com>
In-Reply-To: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
References: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Christoph Lameter <clameter@sgi.com>, Haggai Eran <haggaie@mellanox.com>

From: Sagi Grimberg <sagig@mellanox.com>

The conversion of the locks taken for reverse map scanning would
require taking sleeping locks in free_pgtables() and we cannot sleep
while gathering pages for a tlb flush.

Move the tlb_gather/tlb_finish call to free_pgtables() to be done
for each vma. This may add a number of tlb flushes depending on the
number of vmas that cannot be coalesced into one.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 mm/memory.c | 3 +++
 mm/mmap.c   | 4 ++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index b657a2e..e721432 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -553,6 +553,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		unlink_file_vma(vma);
 
 		if (is_vm_hugetlb_page(vma)) {
+			tlb_gather_mmu(tlb, vma->vm_mm, 0);
 			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		} else {
@@ -566,9 +567,11 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 				unlink_anon_vmas(vma);
 				unlink_file_vma(vma);
 			}
+			tlb_gather_mmu(tlb, vma->vm_mm, 0);
 			free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
 		}
+		tlb_finish_mmu(tlb, addr, vma->vm_end);
 		vma = next;
 	}
 }
diff --git a/mm/mmap.c b/mm/mmap.c
index e3e8691..731da04 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1912,9 +1912,9 @@ static void unmap_region(struct mm_struct *mm,
 	tlb_gather_mmu(&tlb, mm, 0);
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end);
+	tlb_finish_mmu(&tlb, start, end);
 	free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
 				 next ? next->vm_start : 0);
-	tlb_finish_mmu(&tlb, start, end);
 }
 
 /*
@@ -2295,8 +2295,8 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(&tlb, 0, -1);
+	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
