Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D29576B00FD
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:12:09 -0400 (EDT)
Message-ID: <517FED51.8010008@parallels.com>
Date: Tue, 30 Apr 2013 20:12:01 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 3/5] pagemap: introduce pagemap_entry_t without pmshift bits
References: <517FED13.8090806@parallels.com>
In-Reply-To: <517FED13.8090806@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Matt Mackall <mpm@selenic.com>, Marcelo Tosatti <mtosatti@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

These bits are always constant (== PAGE_SHIFT) and just occupy space in
the entry.  Moreover, in next patch we will need to report one more bit in
the pagemap, but all bits are already busy on it.

That said, describe the pagemap entry that has 6 more free zero bits.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
---
 fs/proc/task_mmu.c |   40 ++++++++++++++++++++++------------------
 1 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ef6f6c6..39d6412 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -807,6 +807,7 @@ typedef struct {
 struct pagemapread {
 	int pos, len;
 	pagemap_entry_t *buffer;
+	bool v2;
 };
 
 #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
@@ -820,14 +821,16 @@ struct pagemapread {
 #define PM_PSHIFT_BITS      6
 #define PM_PSHIFT_OFFSET    (PM_STATUS_OFFSET - PM_PSHIFT_BITS)
 #define PM_PSHIFT_MASK      (((1LL << PM_PSHIFT_BITS) - 1) << PM_PSHIFT_OFFSET)
-#define PM_PSHIFT(x)        (((u64) (x) << PM_PSHIFT_OFFSET) & PM_PSHIFT_MASK)
+#define __PM_PSHIFT(x)      (((u64) (x) << PM_PSHIFT_OFFSET) & PM_PSHIFT_MASK)
 #define PM_PFRAME_MASK      ((1LL << PM_PSHIFT_OFFSET) - 1)
 #define PM_PFRAME(x)        ((x) & PM_PFRAME_MASK)
+/* in "new" pagemap pshift bits are occupied with more status bits */
+#define PM_STATUS2(v2, x)   (__PM_PSHIFT(v2 ? x : PAGE_SHIFT))
 
 #define PM_PRESENT          PM_STATUS(4LL)
 #define PM_SWAP             PM_STATUS(2LL)
 #define PM_FILE             PM_STATUS(1LL)
-#define PM_NOT_PRESENT      PM_PSHIFT(PAGE_SHIFT)
+#define PM_NOT_PRESENT(v2)  PM_STATUS2(v2, 0)
 #define PM_END_OF_BUFFER    1
 
 static inline pagemap_entry_t make_pme(u64 val)
@@ -850,7 +853,7 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 	struct pagemapread *pm = walk->private;
 	unsigned long addr;
 	int err = 0;
-	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
+	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
 
 	for (addr = start; addr < end; addr += PAGE_SIZE) {
 		err = add_to_pagemap(addr, &pme, pm);
@@ -860,7 +863,7 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 	return err;
 }
 
-static void pte_to_pagemap_entry(pagemap_entry_t *pme,
+static void pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 		struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
 	u64 frame, flags;
@@ -879,18 +882,18 @@ static void pte_to_pagemap_entry(pagemap_entry_t *pme,
 		if (is_migration_entry(entry))
 			page = migration_entry_to_page(entry);
 	} else {
-		*pme = make_pme(PM_NOT_PRESENT);
+		*pme = make_pme(PM_NOT_PRESENT(pm->v2));
 		return;
 	}
 
 	if (page && !PageAnon(page))
 		flags |= PM_FILE;
 
-	*pme = make_pme(PM_PFRAME(frame) | PM_PSHIFT(PAGE_SHIFT) | flags);
+	*pme = make_pme(PM_PFRAME(frame) | PM_STATUS2(pm->v2, 0) | flags);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
+static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 					pmd_t pmd, int offset)
 {
 	/*
@@ -900,12 +903,12 @@ static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
 	 */
 	if (pmd_present(pmd))
 		*pme = make_pme(PM_PFRAME(pmd_pfn(pmd) + offset)
-				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT);
+				| PM_STATUS2(pm->v2, 0) | PM_PRESENT);
 	else
-		*pme = make_pme(PM_NOT_PRESENT);
+		*pme = make_pme(PM_NOT_PRESENT(pm->v2));
 }
 #else
-static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
+static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 						pmd_t pmd, int offset)
 {
 }
@@ -918,7 +921,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
-	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
+	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
 
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
@@ -928,7 +931,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 			offset = (addr & ~PAGEMAP_WALK_MASK) >>
 					PAGE_SHIFT;
-			thp_pmd_to_pagemap_entry(&pme, *pmd, offset);
+			thp_pmd_to_pagemap_entry(&pme, pm, *pmd, offset);
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
 				break;
@@ -945,7 +948,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		 * and need a new, higher one */
 		if (vma && (addr >= vma->vm_end)) {
 			vma = find_vma(walk->mm, addr);
-			pme = make_pme(PM_NOT_PRESENT);
+			pme = make_pme(PM_NOT_PRESENT(pm->v2));
 		}
 
 		/* check that 'vma' actually covers this address,
@@ -953,7 +956,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		if (vma && (vma->vm_start <= addr) &&
 		    !is_vm_hugetlb_page(vma)) {
 			pte = pte_offset_map(pmd, addr);
-			pte_to_pagemap_entry(&pme, vma, addr, *pte);
+			pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
 			/* unmap before userspace copy */
 			pte_unmap(pte);
 		}
@@ -968,14 +971,14 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 }
 
 #ifdef CONFIG_HUGETLB_PAGE
-static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme,
+static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 					pte_t pte, int offset)
 {
 	if (pte_present(pte))
 		*pme = make_pme(PM_PFRAME(pte_pfn(pte) + offset)
-				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT);
+				| PM_STATUS2(pm->v2, 0) | PM_PRESENT);
 	else
-		*pme = make_pme(PM_NOT_PRESENT);
+		*pme = make_pme(PM_NOT_PRESENT(pm->v2));
 }
 
 /* This function walks within one hugetlb entry in the single call */
@@ -989,7 +992,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 
 	for (; addr != end; addr += PAGE_SIZE) {
 		int offset = (addr & ~hmask) >> PAGE_SHIFT;
-		huge_pte_to_pagemap_entry(&pme, *pte, offset);
+		huge_pte_to_pagemap_entry(&pme, pm, *pte, offset);
 		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			return err;
@@ -1051,6 +1054,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!count)
 		goto out_task;
 
+	pm.v2 = false;
 	pm.len = PM_ENTRY_BYTES * (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
 	pm.buffer = kmalloc(pm.len, GFP_TEMPORARY);
 	ret = -ENOMEM;
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
