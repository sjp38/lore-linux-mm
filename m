Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 3D0D46B13F6
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 10:52:49 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 6/6] pagemap: introduce data structure for pagemap entry
Date: Wed,  8 Feb 2012 10:51:42 -0500
Message-Id: <1328716302-16871-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently a local variable of pagemap entry in pagemap_pte_range()
is named pfn and typed with u64, but it's not correct (pfn should
be unsigned long.)
This patch introduces special type for pagemap entry and replace
code with it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

Changes since v4:
  - Rename pme_t to pagemap_entry_t
---
 fs/proc/task_mmu.c |   69 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 38 insertions(+), 31 deletions(-)

diff --git 3.3-rc2.orig/fs/proc/task_mmu.c 3.3-rc2/fs/proc/task_mmu.c
index de94384..7810281 100644
--- 3.3-rc2.orig/fs/proc/task_mmu.c
+++ 3.3-rc2/fs/proc/task_mmu.c
@@ -589,9 +589,13 @@ const struct file_operations proc_clear_refs_operations = {
 	.llseek		= noop_llseek,
 };
 
+typedef struct {
+	u64 pme;
+} pagemap_entry_t;
+
 struct pagemapread {
 	int pos, len;
-	u64 *buffer;
+	pagemap_entry_t *buffer;
 };
 
 #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
@@ -614,10 +618,15 @@ struct pagemapread {
 #define PM_NOT_PRESENT      PM_PSHIFT(PAGE_SHIFT)
 #define PM_END_OF_BUFFER    1
 
-static int add_to_pagemap(unsigned long addr, u64 pfn,
+static inline pagemap_entry_t make_pme(u64 val)
+{
+	return (pagemap_entry_t) { .pme = val };
+}
+
+static int add_to_pagemap(unsigned long addr, pagemap_entry_t *pme,
 			  struct pagemapread *pm)
 {
-	pm->buffer[pm->pos++] = pfn;
+	pm->buffer[pm->pos++] = *pme;
 	if (pm->pos >= pm->len)
 		return PM_END_OF_BUFFER;
 	return 0;
@@ -629,8 +638,10 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 	struct pagemapread *pm = walk->private;
 	unsigned long addr;
 	int err = 0;
+	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
+
 	for (addr = start; addr < end; addr += PAGE_SIZE) {
-		err = add_to_pagemap(addr, PM_NOT_PRESENT, pm);
+		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			break;
 	}
@@ -643,36 +654,33 @@ static u64 swap_pte_to_pagemap_entry(pte_t pte)
 	return swp_type(e) | (swp_offset(e) << MAX_SWAPFILES_SHIFT);
 }
 
-static u64 pte_to_pagemap_entry(pte_t pte)
+static void pte_to_pagemap_entry(pagemap_entry_t *pme, pte_t pte)
 {
-	u64 pme = 0;
 	if (is_swap_pte(pte))
-		pme = PM_PFRAME(swap_pte_to_pagemap_entry(pte))
-			| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP;
+		*pme = make_pme(PM_PFRAME(swap_pte_to_pagemap_entry(pte))
+				| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP);
 	else if (pte_present(pte))
-		pme = PM_PFRAME(pte_pfn(pte))
-			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
-	return pme;
+		*pme = make_pme(PM_PFRAME(pte_pfn(pte))
+				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static u64 thp_pmd_to_pagemap_entry(pmd_t pmd, int offset)
+static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
+					pmd_t pmd, int offset)
 {
-	u64 pme = 0;
 	/*
 	 * Currently pmd for thp is always present because thp can not be
 	 * swapped-out, migrated, or HWPOISONed (split in such cases instead.)
 	 * This if-check is just to prepare for future implementation.
 	 */
 	if (pmd_present(pmd))
-		pme = PM_PFRAME(pmd_pfn(pmd) + offset)
-			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
-	return pme;
+		*pme = make_pme(PM_PFRAME(pmd_pfn(pmd) + offset)
+				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT);
 }
 #else
-static inline u64 thp_pmd_to_pagemap_entry(pmd_t pmd, int offset)
+static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
+						pmd_t pmd, int offset)
 {
-	return 0;
 }
 #endif
 
@@ -683,7 +691,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
-	u64 pfn = PM_NOT_PRESENT;
+	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
 
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
@@ -692,8 +700,8 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		for (; addr != end; addr += PAGE_SIZE) {
 			unsigned long offset = (addr & ~PAGEMAP_WALK_MASK)
 				>> PAGE_SHIFT;
-			pfn = thp_pmd_to_pagemap_entry(*pmd, offset);
-			err = add_to_pagemap(addr, pfn, pm);
+			thp_pmd_to_pagemap_entry(&pme, *pmd, offset);
+			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
 				break;
 		}
@@ -712,11 +720,11 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		if (vma && (vma->vm_start <= addr) &&
 		    !is_vm_hugetlb_page(vma)) {
 			pte = pte_offset_map(pmd, addr);
-			pfn = pte_to_pagemap_entry(*pte);
+			pte_to_pagemap_entry(&pme, *pte);
 			/* unmap before userspace copy */
 			pte_unmap(pte);
 		}
-		err = add_to_pagemap(addr, pfn, pm);
+		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			return err;
 	}
@@ -727,13 +735,12 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 }
 
 #ifdef CONFIG_HUGETLB_PAGE
-static u64 huge_pte_to_pagemap_entry(pte_t pte, int offset)
+static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme,
+					pte_t pte, int offset)
 {
-	u64 pme = 0;
 	if (pte_present(pte))
-		pme = PM_PFRAME(pte_pfn(pte) + offset)
-			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
-	return pme;
+		*pme = make_pme(PM_PFRAME(pte_pfn(pte) + offset)
+				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT);
 }
 
 /* This function walks within one hugetlb entry in the single call */
@@ -743,12 +750,12 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 {
 	struct pagemapread *pm = walk->private;
 	int err = 0;
-	u64 pfn;
+	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
 
 	for (; addr != end; addr += PAGE_SIZE) {
 		int offset = (addr & ~hmask) >> PAGE_SHIFT;
-		pfn = huge_pte_to_pagemap_entry(*pte, offset);
-		err = add_to_pagemap(addr, pfn, pm);
+		huge_pte_to_pagemap_entry(&pme, *pte, offset);
+		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			return err;
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
