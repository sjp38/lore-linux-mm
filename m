Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 871486B0253
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 12:57:12 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p187so13149207oif.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 09:57:12 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z65si5131715oig.73.2017.10.05.09.57.10
        for <linux-mm@kvack.org>;
        Thu, 05 Oct 2017 09:57:11 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH] mm: page_vma_mapped: Ensure pmd is loaded with READ_ONCE outside of lock
Date: Thu,  5 Oct 2017 17:57:10 +0100
Message-Id: <1507222630-5839-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Will Deacon <will.deacon@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, stable@vger.kernel.org

Loading the pmd without holding the pmd_lock exposes us to races with
concurrent updaters of the page tables but, worse still, it also allows
the compiler to cache the pmd value in a register and reuse it later on,
even if we've performed a READ_ONCE in between and seen a more recent
value.

In the case of page_vma_mapped_walk, this leads to the following crash
when the pmd loaded for the initial pmd_trans_huge check is all zeroes
and a subsequent valid table entry is loaded by check_pmd. We then
proceed into map_pte, but the compiler re-uses the zero entry inside
pte_offset_map, resulting in a junk pointer being installed in pvmw->pte:

[  254.032812] PC is at check_pte+0x20/0x170
[  254.032948] LR is at page_vma_mapped_walk+0x2e0/0x540
[...]
[  254.036114] Process doio (pid: 2463, stack limit = 0xffff00000f2e8000)
[  254.036361] Call trace:
[  254.038977] [<ffff000008233328>] check_pte+0x20/0x170
[  254.039137] [<ffff000008233758>] page_vma_mapped_walk+0x2e0/0x540
[  254.039332] [<ffff000008234adc>] page_mkclean_one+0xac/0x278
[  254.039489] [<ffff000008234d98>] rmap_walk_file+0xf0/0x238
[  254.039642] [<ffff000008236e74>] rmap_walk+0x64/0xa0
[  254.039784] [<ffff0000082370c8>] page_mkclean+0x90/0xa8
[  254.040029] [<ffff0000081f3c64>] clear_page_dirty_for_io+0x84/0x2a8
[  254.040311] [<ffff00000832f984>] mpage_submit_page+0x34/0x98
[  254.040518] [<ffff00000832fb4c>] mpage_process_page_bufs+0x164/0x170
[  254.040743] [<ffff00000832fc8c>] mpage_prepare_extent_to_map+0x134/0x2b8
[  254.040969] [<ffff00000833530c>] ext4_writepages+0x484/0xe30
[  254.041175] [<ffff0000081f6ab4>] do_writepages+0x44/0xe8
[  254.041372] [<ffff0000081e5bd4>] __filemap_fdatawrite_range+0xbc/0x110
[  254.041568] [<ffff0000081e5e68>] file_write_and_wait_range+0x48/0xd8
[  254.041739] [<ffff000008324310>] ext4_sync_file+0x80/0x4b8
[  254.041907] [<ffff0000082bd434>] vfs_fsync_range+0x64/0xc0
[  254.042106] [<ffff0000082332b4>] SyS_msync+0x194/0x1e8

This patch fixes the problem by ensuring that READ_ONCE is used before
the initial checks on the pmd, and this value is subsequently used when
checking whether or not the pmd is present. pmd_check is removed and the
pmd_present check is inlined directly.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: <stable@vger.kernel.org>
Fixes: f27176cfc363 ("mm: convert page_mkclean_one() to use page_vma_mapped_walk()")
Tested-by: Yury Norov <ynorov@caviumnetworks.com>
Tested-by: Richard Ruigrok <rruigrok@codeaurora.org>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 mm/page_vma_mapped.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index 6a03946469a9..6b85f5464246 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -6,17 +6,6 @@
 
 #include "internal.h"
 
-static inline bool check_pmd(struct page_vma_mapped_walk *pvmw)
-{
-	pmd_t pmde;
-	/*
-	 * Make sure we don't re-load pmd between present and !trans_huge check.
-	 * We need a consistent view.
-	 */
-	pmde = READ_ONCE(*pvmw->pmd);
-	return pmd_present(pmde) && !pmd_trans_huge(pmde);
-}
-
 static inline bool not_found(struct page_vma_mapped_walk *pvmw)
 {
 	page_vma_mapped_walk_done(pvmw);
@@ -116,6 +105,7 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	pgd_t *pgd;
 	p4d_t *p4d;
 	pud_t *pud;
+	pmd_t pmde;
 
 	/* The only possible pmd mapping has been handled on last iteration */
 	if (pvmw->pmd && !pvmw->pte)
@@ -148,7 +138,13 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	if (!pud_present(*pud))
 		return false;
 	pvmw->pmd = pmd_offset(pud, pvmw->address);
-	if (pmd_trans_huge(*pvmw->pmd) || is_pmd_migration_entry(*pvmw->pmd)) {
+	/*
+	 * Make sure the pmd value isn't cached in a register by the
+	 * compiler and used as a stale value after we've observed a
+	 * subsequent update.
+	 */
+	pmde = READ_ONCE(*pvmw->pmd);
+	if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
 		pvmw->ptl = pmd_lock(mm, pvmw->pmd);
 		if (likely(pmd_trans_huge(*pvmw->pmd))) {
 			if (pvmw->flags & PVMW_MIGRATION)
@@ -175,9 +171,8 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 			spin_unlock(pvmw->ptl);
 			pvmw->ptl = NULL;
 		}
-	} else {
-		if (!check_pmd(pvmw))
-			return false;
+	} else if (!pmd_present(pmde)) {
+		return false;
 	}
 	if (!map_pte(pvmw))
 		goto next_pte;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
