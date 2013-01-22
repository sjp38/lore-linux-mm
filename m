Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D737B6B0009
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:43:58 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 3/5] Bug fix: Do not split pages when freeing pagetable pages.
Date: Tue, 22 Jan 2013 19:43:02 +0800
Message-Id: <1358854984-6073-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358854984-6073-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358854984-6073-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

The old way we free pagetable pages was wrong.

The old way is:
When we got a hugepage, we split it into smaller pages. And sometimes,
we only need to free some of the smaller pages because the others are
still in use. And the whole larger page will be freed if all the smaller
pages are not in use. All these were done in remove_pmd/pud_table().

But there is no way to know if the larger page has been split. As a result,
there is no way to decide when to split.

Actually, there is no need to split larger pages into smaller ones.

We do it in the following new way:
1) For direct mapped pages, all the pages were freed when they were offlined.
   And since menmory offline is done section by section, all the memory ranges
   being removed are aligned to PAGE_SIZE. So only need to deal with unaligned
   pages when freeing vmemmap pages.

2) For vmemmap pages being used to store page_struct, if part of the larger
   page is still in use, just fill the unused part with 0xFD. And when the
   whole page is fulfilled with 0xFD, then free the larger page.

This problem is caused by the following related patch:
memory-hotplug-common-apis-to-support-page-tables-hot-remove.patch
memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix.patch
memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix.patch
memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix.patch
memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix.patch

This patch will fix the problem based on the above patches.

Reported-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c |  148 +++++++++++++++---------------------------------
 1 files changed, 46 insertions(+), 102 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 6d1a768..9fbed24 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -777,7 +777,7 @@ static bool __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd)
 
 static void __meminit
 remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
-		 bool direct, bool split)
+		 bool direct)
 {
 	unsigned long next, pages = 0;
 	pte_t *pte;
@@ -807,23 +807,9 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 			/*
 			 * Do not free direct mapping pages since they were
 			 * freed when offlining, or simplely not in use.
-			 *
-			 * Do not free pages split from larger page since only
-			 * the _count of the 1st page struct is available.
-			 * Free the larger page when it is fulfilled with 0xFD.
 			 */
-			if (!direct) {
-				if (split) {
-					/*
-					 * Fill the split 4KB page with 0xFD.
-					 * When the whole 2MB page is fulfilled
-					 * with 0xFD, it could be freed.
-					 */
-					memset((void *)addr, PAGE_INUSE,
-						PAGE_SIZE);
-				} else
-					free_pagetable(pte_page(*pte), 0);
-			}
+			if (!direct)
+				free_pagetable(pte_page(*pte), 0);
 
 			spin_lock(&init_mm.page_table_lock);
 			pte_clear(&init_mm, addr, pte);
@@ -833,26 +819,24 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 			pages++;
 		} else {
 			/*
+			 * If we are here, we are freeing vmemmap pages since
+			 * direct mapped memory ranges to be freed are aligned.
+			 *
 			 * If we are not removing the whole page, it means
-			 * other ptes in this page are being used and we cannot
-			 * remove them. So fill the unused ptes with 0xFD, and
-			 * remove the page when it is wholly filled with 0xFD.
+			 * other page structs in this page are being used and
+			 * we canot remove them. So fill the unused page_structs
+			 * with 0xFD, and remove the page when it is wholly
+			 * filled with 0xFD.
 			 */
 			memset((void *)addr, PAGE_INUSE, next - addr);
 
-			/*
-			 * If the range is not aligned to PAGE_SIZE, then the
-			 * page is definitely not split from larger page.
-			 */
 			page_addr = page_address(pte_page(*pte));
 			if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
-				if (!direct)
-					free_pagetable(pte_page(*pte), 0);
+				free_pagetable(pte_page(*pte), 0);
 
 				spin_lock(&init_mm.page_table_lock);
 				pte_clear(&init_mm, addr, pte);
 				spin_unlock(&init_mm.page_table_lock);
-				pages++;
 			}
 		}
 	}
@@ -865,13 +849,12 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 
 static void __meminit
 remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
-		 bool direct, bool split)
+		 bool direct)
 {
-	unsigned long pte_phys, next, pages = 0;
+	unsigned long next, pages = 0;
 	pte_t *pte_base;
 	pmd_t *pmd;
 	void *page_addr;
-	bool split_pmd = split, split_pte = false;
 
 	pmd = pmd_start + pmd_index(addr);
 	for (; addr < end; addr = next, pmd++) {
@@ -883,63 +866,35 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 		if (pmd_large(*pmd)) {
 			if (IS_ALIGNED(addr, PMD_SIZE) &&
 			    IS_ALIGNED(next, PMD_SIZE)) {
-				if (!direct) {
-					if (split_pmd) {
-						/*
-						 * Fill the split 2MB page with
-						 * 0xFD. When the whole 1GB page
-						 * is fulfilled with 0xFD, it
-						 * could be freed.
-						 */
-						memset((void *)addr, PAGE_INUSE,
-							PMD_SIZE);
-					} else {
-						free_pagetable(pmd_page(*pmd),
+				if (!direct)
+					free_pagetable(pmd_page(*pmd),
 						       get_order(PMD_SIZE));
-					}
-				}
 
 				spin_lock(&init_mm.page_table_lock);
 				pmd_clear(pmd);
 				spin_unlock(&init_mm.page_table_lock);
-
-				/*
-				 * For non-direct mapping, pages means
-				 * nothing.
-				 */
 				pages++;
+			} else {
+				/* If here, we are freeing vmemmap pages. */
+				memset((void *)addr, PAGE_INUSE, next - addr);
+
+				page_addr = page_address(pmd_page(*pmd));
+				if (!memchr_inv(page_addr, PAGE_INUSE,
+						PMD_SIZE)) {
+					free_pagetable(pmd_page(*pmd),
+						       get_order(PMD_SIZE));
 
-				continue;
+					spin_lock(&init_mm.page_table_lock);
+					pmd_clear(pmd);
+					spin_unlock(&init_mm.page_table_lock);
+				}
 			}
 
-			/*
-			 * We use 2M page, but we need to remove part of them,
-			 * so split 2M page to 4K page.
-			 */
-			pte_base = (pte_t *)alloc_low_page(&pte_phys);
-			BUG_ON(!pte_base);
-			__split_large_page((pte_t *)pmd, addr,
-					   (pte_t *)pte_base);
-			split_pte = true;
-
-			spin_lock(&init_mm.page_table_lock);
-			pmd_populate_kernel(&init_mm, pmd, __va(pte_phys));
-			spin_unlock(&init_mm.page_table_lock);
-
-			flush_tlb_all();
+			continue;
 		}
 
 		pte_base = (pte_t *)map_low_page((pte_t *)pmd_page_vaddr(*pmd));
-		remove_pte_table(pte_base, addr, next, direct, split_pte);
-
-		if (!direct && split_pte) {
-			page_addr = page_address(pmd_page(*pmd));
-			if (!memchr_inv(page_addr, PAGE_INUSE, PMD_SIZE)) {
-				free_pagetable(pmd_page(*pmd),
-					       get_order(PMD_SIZE));
-			}
-		}
-
+		remove_pte_table(pte_base, addr, next, direct);
 		free_pte_table(pte_base, pmd);
 		unmap_low_page(pte_base);
 	}
@@ -953,11 +908,10 @@ static void __meminit
 remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 		 bool direct)
 {
-	unsigned long pmd_phys, next, pages = 0;
+	unsigned long next, pages = 0;
 	pmd_t *pmd_base;
 	pud_t *pud;
 	void *page_addr;
-	bool split_pmd = false;
 
 	pud = pud_start + pud_index(addr);
 	for (; addr < end; addr = next, pud++) {
@@ -977,37 +931,27 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 				pud_clear(pud);
 				spin_unlock(&init_mm.page_table_lock);
 				pages++;
-				continue;
-			}
+			} else {
+				/* If here, we are freeing vmemmap pages. */
+				memset((void *)addr, PAGE_INUSE, next - addr);
 
-			/*
-			 * We use 1G page, but we need to remove part of them,
-			 * so split 1G page to 2M page.
-			 */
-			pmd_base = (pmd_t *)alloc_low_page(&pmd_phys);
-			BUG_ON(!pmd_base);
-			__split_large_page((pte_t *)pud, addr,
-					   (pte_t *)pmd_base);
-			split_pmd = true;
+				page_addr = page_address(pud_page(*pud));
+				if (!memchr_inv(page_addr, PAGE_INUSE,
+						PUD_SIZE)) {
+					free_pagetable(pud_page(*pud),
+						       get_order(PUD_SIZE));
 
-			spin_lock(&init_mm.page_table_lock);
-			pud_populate(&init_mm, pud, __va(pmd_phys));
-			spin_unlock(&init_mm.page_table_lock);
+					spin_lock(&init_mm.page_table_lock);
+					pud_clear(pud);
+					spin_unlock(&init_mm.page_table_lock);
+				}
+			}
 
-			flush_tlb_all();
+			continue;
 		}
 
 		pmd_base = (pmd_t *)map_low_page((pmd_t *)pud_page_vaddr(*pud));
-		remove_pmd_table(pmd_base, addr, next, direct, split_pmd);
-
-		if (!direct && split_pmd) {
-			page_addr = page_address(pud_page(*pud));
-			if (!memchr_inv(page_addr, PAGE_INUSE, PUD_SIZE)) {
-				free_pagetable(pud_page(*pud),
-					       get_order(PUD_SIZE));
-			}
-		}
-
+		remove_pmd_table(pmd_base, addr, next, direct);
 		free_pmd_table(pmd_base, pud);
 		unmap_low_page(pmd_base);
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
