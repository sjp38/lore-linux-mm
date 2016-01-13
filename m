Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0E26B0005
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 07:31:46 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id uo6so341881216pac.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:31:46 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id jj2si1801914pac.179.2016.01.13.04.31.45
        for <linux-mm@kvack.org>;
        Wed, 13 Jan 2016 04:31:45 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: fix split_huge_page() after mremap() of THP
Date: Wed, 13 Jan 2016 15:31:40 +0300
Message-Id: <1452688300-121543-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Sasha Levin has reported KASAN out-of-bounds bug[1].
It points to "if (!is_swap_pte(pte[i]))" in unfreeze_page_vma() as a
problematic access.

The cause is that split_huge_page() doesn't handle THP correctly if it's
not allingned to PMD boundary. It can happen after mremap().

Test-case (not always triggers the bug):

	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <sys/mman.h>

	#define MB (1024UL*1024)
	#define SIZE (2*MB)
	#define BASE ((void *)0x400000000000)

	int main()
	{
		char *p;

		p = mmap(BASE, SIZE, PROT_READ | PROT_WRITE,
				MAP_FIXED | MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE,
				-1, 0);
		if (p == MAP_FAILED)
			perror("mmap"), exit(1);
		p = mremap(BASE, SIZE, SIZE, MREMAP_FIXED | MREMAP_MAYMOVE,
				BASE + SIZE + 8192);
		if (p == MAP_FAILED)
			perror("mremap"), exit(1);
		system("echo 1 > /sys/kernel/debug/split_huge_pages");
		return 0;
	}

The patch fixes freeze and unfreeze paths to handle page table boundary
crossing.

It also makes mapcount vs. count check in split_huge_page_to_list()
stricter:
 - after freeze we don't expect any subpage mapped as we remove them
   from rmap when setting up migration entries;
 - count must be 1, meaning only caller has reference to the page;

[1] https://gist.github.com/sashalevin/c67fbea55e7c0576972a

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 72 +++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 51 insertions(+), 21 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 22385253cd5e..ea1baf9b45b4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3115,6 +3115,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		unsigned long address)
 {
+	unsigned long haddr = address & HPAGE_PMD_MASK;
 	spinlock_t *ptl;
 	pgd_t *pgd;
 	pud_t *pud;
@@ -3136,34 +3137,48 @@ static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
 	}
 	if (pmd_trans_huge(*pmd)) {
 		if (page == pmd_page(*pmd))
-			__split_huge_pmd_locked(vma, pmd, address, true);
+			__split_huge_pmd_locked(vma, pmd, haddr, true);
 		spin_unlock(ptl);
 		return;
 	}
 	spin_unlock(ptl);
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
-	for (i = 0; i < HPAGE_PMD_NR; i++, address += PAGE_SIZE, page++) {
+	for (i = 0; i < HPAGE_PMD_NR;
+			i++, address += PAGE_SIZE, page++, pte++) {
 		pte_t entry, swp_pte;
 		swp_entry_t swp_entry;
 
-		if (!pte_present(pte[i]))
+		/*
+		 * We've just crossed page table boundary: need to map next one.
+		 * It can happen if THP was mremaped to non PMD-aligned address.
+		 */
+		if (unlikely(address == haddr + HPAGE_PMD_SIZE)) {
+			pte_unmap_unlock(pte - 1, ptl);
+			pmd = mm_find_pmd(vma->vm_mm, address);
+			if (!pmd)
+				return;
+			pte = pte_offset_map_lock(vma->vm_mm, pmd,
+					address, &ptl);
+		}
+
+		if (!pte_present(*pte))
 			continue;
-		if (page_to_pfn(page) != pte_pfn(pte[i]))
+		if (page_to_pfn(page) != pte_pfn(*pte))
 			continue;
 		flush_cache_page(vma, address, page_to_pfn(page));
-		entry = ptep_clear_flush(vma, address, pte + i);
+		entry = ptep_clear_flush(vma, address, pte);
 		if (pte_dirty(entry))
 			SetPageDirty(page);
 		swp_entry = make_migration_entry(page, pte_write(entry));
 		swp_pte = swp_entry_to_pte(swp_entry);
 		if (pte_soft_dirty(entry))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
-		set_pte_at(vma->vm_mm, address, pte + i, swp_pte);
+		set_pte_at(vma->vm_mm, address, pte, swp_pte);
 		page_remove_rmap(page, false);
 		put_page(page);
 	}
-	pte_unmap_unlock(pte, ptl);
+	pte_unmap_unlock(pte - 1, ptl);
 }
 
 static void freeze_page(struct anon_vma *anon_vma, struct page *page)
@@ -3175,14 +3190,13 @@ static void freeze_page(struct anon_vma *anon_vma, struct page *page)
 
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff,
 			pgoff + HPAGE_PMD_NR - 1) {
-		unsigned long haddr;
+		unsigned long address = __vma_address(page, avc->vma);
 
-		haddr = __vma_address(page, avc->vma) & HPAGE_PMD_MASK;
 		mmu_notifier_invalidate_range_start(avc->vma->vm_mm,
-				haddr, haddr + HPAGE_PMD_SIZE);
-		freeze_page_vma(avc->vma, page, haddr);
+				address, address + HPAGE_PMD_SIZE);
+		freeze_page_vma(avc->vma, page, address);
 		mmu_notifier_invalidate_range_end(avc->vma->vm_mm,
-				haddr, haddr + HPAGE_PMD_SIZE);
+				address, address + HPAGE_PMD_SIZE);
 	}
 }
 
@@ -3193,17 +3207,33 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 	pmd_t *pmd;
 	pte_t *pte, entry;
 	swp_entry_t swp_entry;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
 	int i;
 
 	pmd = mm_find_pmd(vma->vm_mm, address);
 	if (!pmd)
 		return;
+
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
-	for (i = 0; i < HPAGE_PMD_NR; i++, address += PAGE_SIZE, page++) {
-		if (!is_swap_pte(pte[i]))
+	for (i = 0; i < HPAGE_PMD_NR;
+			i++, address += PAGE_SIZE, page++, pte++) {
+		/*
+		 * We've just crossed page table boundary: need to map next one.
+		 * It can happen if THP was mremaped to non-PMD aligned address.
+		 */
+		if (unlikely(address == haddr + HPAGE_PMD_SIZE)) {
+			pte_unmap_unlock(pte - 1, ptl);
+			pmd = mm_find_pmd(vma->vm_mm, address);
+			if (!pmd)
+				return;
+			pte = pte_offset_map_lock(vma->vm_mm, pmd,
+					address, &ptl);
+		}
+
+		if (!is_swap_pte(*pte))
 			continue;
 
-		swp_entry = pte_to_swp_entry(pte[i]);
+		swp_entry = pte_to_swp_entry(*pte);
 		if (!is_migration_entry(swp_entry))
 			continue;
 		if (migration_entry_to_page(swp_entry) != page)
@@ -3219,12 +3249,12 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 			entry = maybe_mkwrite(entry, vma);
 
 		flush_dcache_page(page);
-		set_pte_at(vma->vm_mm, address, pte + i, entry);
+		set_pte_at(vma->vm_mm, address, pte, entry);
 
 		/* No need to invalidate - it was non-present before */
-		update_mmu_cache(vma, address, pte + i);
+		update_mmu_cache(vma, address, pte);
 	}
-	pte_unmap_unlock(pte, ptl);
+	pte_unmap_unlock(pte - 1, ptl);
 }
 
 static void unfreeze_page(struct anon_vma *anon_vma, struct page *page)
@@ -3430,7 +3460,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	spin_lock(&split_queue_lock);
 	count = page_count(head);
 	mapcount = total_mapcount(head);
-	if (mapcount == count - 1) {
+	if (!mapcount && count == 1) {
 		if (!list_empty(page_deferred_list(head))) {
 			split_queue_len--;
 			list_del(page_deferred_list(head));
@@ -3438,13 +3468,13 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		spin_unlock(&split_queue_lock);
 		__split_huge_page(page, list);
 		ret = 0;
-	} else if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount > count - 1) {
+	} else if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
 		spin_unlock(&split_queue_lock);
 		pr_alert("total_mapcount: %u, page_count(): %u\n",
 				mapcount, count);
 		if (PageTail(page))
 			dump_page(head, NULL);
-		dump_page(page, "total_mapcount(head) > page_count(head) - 1");
+		dump_page(page, "total_mapcount(head) > 0");
 		BUG();
 	} else {
 		spin_unlock(&split_queue_lock);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
