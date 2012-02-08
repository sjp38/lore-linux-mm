Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 9F0AD6B13F5
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 10:52:48 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/6] pagemap: avoid splitting thp when reading /proc/pid/pagemap
Date: Wed,  8 Feb 2012 10:51:37 -0500
Message-Id: <1328716302-16871-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thp split is not necessary if we explicitly check whether pmds are
mapping thps or not. This patch introduces this check and adds code
to generate pagemap entries for pmds mapping thps, which results in
less performance impact of pagemap on thp.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

ToDo:
  - Avoid thp split in another 2 split_huge_page_pmd() in mm/memcontrol.c

Changes since v3:
  - Generate pagemap entry directly from pmd to avoid messy casting

Changes since v2:
  - Add comment on if check in thp_pte_to_pagemap_entry()
  - Convert type of offset into unsigned long

Changes since v1:
  - Move pfn declaration to the beginning of pagemap_pte_range()
---
 fs/proc/task_mmu.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 47 insertions(+), 6 deletions(-)

diff --git 3.3-rc2.orig/fs/proc/task_mmu.c 3.3-rc2/fs/proc/task_mmu.c
index 7dcd2a2..eb0a93e 100644
--- 3.3-rc2.orig/fs/proc/task_mmu.c
+++ 3.3-rc2/fs/proc/task_mmu.c
@@ -603,6 +603,9 @@ struct pagemapread {
 	u64 *buffer;
 };
 
+#define PAGEMAP_WALK_SIZE	(PMD_SIZE)
+#define PAGEMAP_WALK_MASK	(PMD_MASK)
+
 #define PM_ENTRY_BYTES      sizeof(u64)
 #define PM_STATUS_BITS      3
 #define PM_STATUS_OFFSET    (64 - PM_STATUS_BITS)
@@ -661,6 +664,27 @@ static u64 pte_to_pagemap_entry(pte_t pte)
 	return pme;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static u64 thp_pmd_to_pagemap_entry(pmd_t pmd, int offset)
+{
+	u64 pme = 0;
+	/*
+	 * Currently pmd for thp is always present because thp can not be
+	 * swapped-out, migrated, or HWPOISONed (split in such cases instead.)
+	 * This if-check is just to prepare for future implementation.
+	 */
+	if (pmd_present(pmd))
+		pme = PM_PFRAME(pmd_pfn(pmd) + offset)
+			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
+	return pme;
+}
+#else
+static inline u64 thp_pmd_to_pagemap_entry(pmd_t pmd, int offset)
+{
+	return 0;
+}
+#endif
+
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
@@ -668,14 +692,33 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
-
-	split_huge_page_pmd(walk->mm, pmd);
+	u64 pfn = PM_NOT_PRESENT;
 
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
-	for (; addr != end; addr += PAGE_SIZE) {
-		u64 pfn = PM_NOT_PRESENT;
 
+	spin_lock(&walk->mm->page_table_lock);
+	if (pmd_trans_huge(*pmd)) {
+		if (pmd_trans_splitting(*pmd)) {
+			spin_unlock(&walk->mm->page_table_lock);
+			wait_split_huge_page(vma->anon_vma, pmd);
+		} else {
+			for (; addr != end; addr += PAGE_SIZE) {
+				unsigned long offset = (addr & ~PAGEMAP_WALK_MASK)
+					>> PAGE_SHIFT;
+				pfn = thp_pmd_to_pagemap_entry(*pmd, offset);
+				err = add_to_pagemap(addr, pfn, pm);
+				if (err)
+					break;
+			}
+			spin_unlock(&walk->mm->page_table_lock);
+			return err;
+		}
+	} else {
+		spin_unlock(&walk->mm->page_table_lock);
+	}
+
+	for (; addr != end; addr += PAGE_SIZE) {
 		/* check to see if we've left 'vma' behind
 		 * and need a new, higher one */
 		if (vma && (addr >= vma->vm_end))
@@ -757,8 +800,6 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
  * determine which areas of memory are actually mapped and llseek to
  * skip over unmapped regions.
  */
-#define PAGEMAP_WALK_SIZE	(PMD_SIZE)
-#define PAGEMAP_WALK_MASK	(PMD_MASK)
 static ssize_t pagemap_read(struct file *file, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
