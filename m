Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 53A4B6B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 01:56:57 -0400 (EDT)
Received: by laka10 with SMTP id a10so3091042lak.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 22:56:56 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id m10si9612062laj.171.2015.06.14.22.56.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 22:56:55 -0700 (PDT)
Received: by lbbti3 with SMTP id ti3so9279487lbb.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 22:56:54 -0700 (PDT)
Subject: [PATCH v4] pagemap: switch to the new format and do some cleanup
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Mon, 15 Jun 2015 08:56:49 +0300
Message-ID: <20150615055649.4485.92087.stgit@zurg>
In-Reply-To: <20150609200021.21971.13598.stgit@zurg>
References: <20150609200021.21971.13598.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mark Williamson <mwilliamson@undo-software.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

This patch removes page-shift bits (scheduled to remove since 3.11) and
completes migration to the new bit layout. Also it cleans messy macro.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

---

v4: fix misprint PM_PFEAME_BITS -> PM_PFRAME_BITS
---
 fs/proc/task_mmu.c    |  147 ++++++++++++++++---------------------------------
 tools/vm/page-types.c |   29 +++-------
 2 files changed, 58 insertions(+), 118 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f1b9ae8..99fa2ae 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -710,23 +710,6 @@ const struct file_operations proc_tid_smaps_operations = {
 	.release	= proc_map_release,
 };
 
-/*
- * We do not want to have constant page-shift bits sitting in
- * pagemap entries and are about to reuse them some time soon.
- *
- * Here's the "migration strategy":
- * 1. when the system boots these bits remain what they are,
- *    but a warning about future change is printed in log;
- * 2. once anyone clears soft-dirty bits via clear_refs file,
- *    these flag is set to denote, that user is aware of the
- *    new API and those page-shift bits change their meaning.
- *    The respective warning is printed in dmesg;
- * 3. In a couple of releases we will remove all the mentions
- *    of page-shift in pagemap entries.
- */
-
-static bool soft_dirty_cleared __read_mostly;
-
 enum clear_refs_types {
 	CLEAR_REFS_ALL = 1,
 	CLEAR_REFS_ANON,
@@ -887,13 +870,6 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	if (type < CLEAR_REFS_ALL || type >= CLEAR_REFS_LAST)
 		return -EINVAL;
 
-	if (type == CLEAR_REFS_SOFT_DIRTY) {
-		soft_dirty_cleared = true;
-		pr_warn_once("The pagemap bits 55-60 has changed their meaning!"
-			     " See the linux/Documentation/vm/pagemap.txt for "
-			     "details.\n");
-	}
-
 	task = get_proc_task(file_inode(file));
 	if (!task)
 		return -ESRCH;
@@ -961,38 +937,26 @@ typedef struct {
 struct pagemapread {
 	int pos, len;		/* units: PM_ENTRY_BYTES, not bytes */
 	pagemap_entry_t *buffer;
-	bool v2;
 	bool show_pfn;
 };
 
 #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
 #define PAGEMAP_WALK_MASK	(PMD_MASK)
 
-#define PM_ENTRY_BYTES      sizeof(pagemap_entry_t)
-#define PM_STATUS_BITS      3
-#define PM_STATUS_OFFSET    (64 - PM_STATUS_BITS)
-#define PM_STATUS_MASK      (((1LL << PM_STATUS_BITS) - 1) << PM_STATUS_OFFSET)
-#define PM_STATUS(nr)       (((nr) << PM_STATUS_OFFSET) & PM_STATUS_MASK)
-#define PM_PSHIFT_BITS      6
-#define PM_PSHIFT_OFFSET    (PM_STATUS_OFFSET - PM_PSHIFT_BITS)
-#define PM_PSHIFT_MASK      (((1LL << PM_PSHIFT_BITS) - 1) << PM_PSHIFT_OFFSET)
-#define __PM_PSHIFT(x)      (((u64) (x) << PM_PSHIFT_OFFSET) & PM_PSHIFT_MASK)
-#define PM_PFRAME_MASK      ((1LL << PM_PSHIFT_OFFSET) - 1)
-#define PM_PFRAME(x)        ((x) & PM_PFRAME_MASK)
-/* in "new" pagemap pshift bits are occupied with more status bits */
-#define PM_STATUS2(v2, x)   (__PM_PSHIFT(v2 ? x : PAGE_SHIFT))
-
-#define __PM_SOFT_DIRTY      (1LL)
-#define __PM_MMAP_EXCLUSIVE  (2LL)
-#define PM_PRESENT          PM_STATUS(4LL)
-#define PM_SWAP             PM_STATUS(2LL)
-#define PM_FILE             PM_STATUS(1LL)
-#define PM_NOT_PRESENT(v2)  PM_STATUS2(v2, 0)
+#define PM_ENTRY_BYTES		sizeof(pagemap_entry_t)
+#define PM_PFRAME_BITS		54
+#define PM_PFRAME_MASK		GENMASK_ULL(PM_PFRAME_BITS - 1, 0)
+#define PM_SOFT_DIRTY		BIT_ULL(55)
+#define PM_MMAP_EXCLUSIVE	BIT_ULL(56)
+#define PM_FILE			BIT_ULL(61)
+#define PM_SWAP			BIT_ULL(62)
+#define PM_PRESENT		BIT_ULL(63)
+
 #define PM_END_OF_BUFFER    1
 
-static inline pagemap_entry_t make_pme(u64 val)
+static inline pagemap_entry_t make_pme(u64 frame, u64 flags)
 {
-	return (pagemap_entry_t) { .pme = val };
+	return (pagemap_entry_t) { .pme = (frame & PM_PFRAME_MASK) | flags };
 }
 
 static int add_to_pagemap(unsigned long addr, pagemap_entry_t *pme,
@@ -1013,7 +977,7 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 
 	while (addr < end) {
 		struct vm_area_struct *vma = find_vma(walk->mm, addr);
-		pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
+		pagemap_entry_t pme = make_pme(0, 0);
 		/* End of address space hole, which we mark as non-present. */
 		unsigned long hole_end;
 
@@ -1033,7 +997,7 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 
 		/* Addresses in the VMA. */
 		if (vma->vm_flags & VM_SOFTDIRTY)
-			pme.pme |= PM_STATUS2(pm->v2, __PM_SOFT_DIRTY);
+			pme = make_pme(0, PM_SOFT_DIRTY);
 		for (; addr < min(end, vma->vm_end); addr += PAGE_SIZE) {
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
@@ -1044,50 +1008,44 @@ out:
 	return err;
 }
 
-static void pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
+static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 		struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
-	u64 frame = 0, flags;
+	u64 frame = 0, flags = 0;
 	struct page *page = NULL;
-	int flags2 = 0;
 
 	if (pte_present(pte)) {
 		if (pm->show_pfn)
 			frame = pte_pfn(pte);
-		flags = PM_PRESENT;
+		flags |= PM_PRESENT;
 		page = vm_normal_page(vma, addr, pte);
 		if (pte_soft_dirty(pte))
-			flags2 |= __PM_SOFT_DIRTY;
+			flags |= PM_SOFT_DIRTY;
 	} else if (is_swap_pte(pte)) {
 		swp_entry_t entry;
 		if (pte_swp_soft_dirty(pte))
-			flags2 |= __PM_SOFT_DIRTY;
+			flags |= PM_SOFT_DIRTY;
 		entry = pte_to_swp_entry(pte);
 		frame = swp_type(entry) |
 			(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
-		flags = PM_SWAP;
+		flags |= PM_SWAP;
 		if (is_migration_entry(entry))
 			page = migration_entry_to_page(entry);
-	} else {
-		if (vma->vm_flags & VM_SOFTDIRTY)
-			flags2 |= __PM_SOFT_DIRTY;
-		*pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, flags2));
-		return;
 	}
 
 	if (page && !PageAnon(page))
 		flags |= PM_FILE;
 	if (page && page_mapcount(page) == 1)
-		flags2 |= __PM_MMAP_EXCLUSIVE;
-	if ((vma->vm_flags & VM_SOFTDIRTY))
-		flags2 |= __PM_SOFT_DIRTY;
+		flags |= PM_MMAP_EXCLUSIVE;
+	if (vma->vm_flags & VM_SOFTDIRTY)
+		flags |= PM_SOFT_DIRTY;
 
-	*pme = make_pme(PM_PFRAME(frame) | PM_STATUS2(pm->v2, flags2) | flags);
+	return make_pme(frame, flags);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
-		pmd_t pmd, int offset, int pmd_flags2)
+static pagemap_entry_t thp_pmd_to_pagemap_entry(struct pagemapread *pm,
+		pmd_t pmd, int offset, u64 flags)
 {
 	u64 frame = 0;
 
@@ -1099,15 +1057,16 @@ static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *p
 	if (pmd_present(pmd)) {
 		if (pm->show_pfn)
 			frame = pmd_pfn(pmd) + offset;
-		*pme = make_pme(PM_PFRAME(frame) | PM_PRESENT |
-				PM_STATUS2(pm->v2, pmd_flags2));
-	} else
-		*pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, pmd_flags2));
+		flags |= PM_PRESENT;
+	}
+
+	return make_pme(frame, flags);
 }
 #else
-static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
-		pmd_t pmd, int offset, int pmd_flags2)
+static pagemap_entry_t thp_pmd_to_pagemap_entry(struct pagemapread *pm,
+		pmd_t pmd, int offset, u64 flags)
 {
+	return make_pme(0, 0);
 }
 #endif
 
@@ -1121,18 +1080,16 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	int err = 0;
 
 	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		int pmd_flags2;
+		u64 flags = 0;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
-			pmd_flags2 = __PM_SOFT_DIRTY;
-		else
-			pmd_flags2 = 0;
+			flags |= PM_SOFT_DIRTY;
 
 		if (pmd_present(*pmd)) {
 			struct page *page = pmd_page(*pmd);
 
 			if (page_mapcount(page) == 1)
-				pmd_flags2 |= __PM_MMAP_EXCLUSIVE;
+				flags |= PM_MMAP_EXCLUSIVE;
 		}
 
 		for (; addr != end; addr += PAGE_SIZE) {
@@ -1141,7 +1098,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 			offset = (addr & ~PAGEMAP_WALK_MASK) >>
 					PAGE_SHIFT;
-			thp_pmd_to_pagemap_entry(&pme, pm, *pmd, offset, pmd_flags2);
+			pme = thp_pmd_to_pagemap_entry(pm, *pmd, offset, flags);
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
 				break;
@@ -1161,7 +1118,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	for (; addr < end; pte++, addr += PAGE_SIZE) {
 		pagemap_entry_t pme;
 
-		pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
+		pme = pte_to_pagemap_entry(pm, vma, addr, *pte);
 		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			break;
@@ -1174,19 +1131,18 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 }
 
 #ifdef CONFIG_HUGETLB_PAGE
-static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
-					pte_t pte, int offset, int flags2)
+static pagemap_entry_t huge_pte_to_pagemap_entry(struct pagemapread *pm,
+					pte_t pte, int offset, u64 flags)
 {
 	u64 frame = 0;
 
 	if (pte_present(pte)) {
 		if (pm->show_pfn)
 			frame = pte_pfn(pte) + offset;
-		*pme = make_pme(PM_PFRAME(frame) | PM_PRESENT |
-				PM_STATUS2(pm->v2, flags2));
-	} else
-		*pme = make_pme(PM_NOT_PRESENT(pm->v2)			|
-				PM_STATUS2(pm->v2, flags2));
+		flags |= PM_PRESENT;
+	}
+
+	return make_pme(frame, flags);
 }
 
 /* This function walks within one hugetlb entry in the single call */
@@ -1197,17 +1153,15 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 	struct pagemapread *pm = walk->private;
 	struct vm_area_struct *vma = walk->vma;
 	int err = 0;
-	int flags2;
+	u64 flags = 0;
 	pagemap_entry_t pme;
 
 	if (vma->vm_flags & VM_SOFTDIRTY)
-		flags2 = __PM_SOFT_DIRTY;
-	else
-		flags2 = 0;
+		flags |= PM_SOFT_DIRTY;
 
 	for (; addr != end; addr += PAGE_SIZE) {
 		int offset = (addr & ~hmask) >> PAGE_SHIFT;
-		huge_pte_to_pagemap_entry(&pme, pm, *pte, offset, flags2);
+		pme = huge_pte_to_pagemap_entry(pm, *pte, offset, flags);
 		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			return err;
@@ -1228,7 +1182,9 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
  * Bits 0-54  page frame number (PFN) if present
  * Bits 0-4   swap type if swapped
  * Bits 5-54  swap offset if swapped
- * Bits 55-60 page shift (page size = 1<<page shift)
+ * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
+ * Bit  56    page exclusively mapped
+ * Bits 57-60 zero
  * Bit  61    page is file-page or shared-anon
  * Bit  62    page swapped
  * Bit  63    page present
@@ -1269,7 +1225,6 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 
 	/* do not disclose physical addresses: attack vector */
 	pm.show_pfn = file_ns_capable(file, &init_user_ns, CAP_SYS_ADMIN);
-	pm.v2 = soft_dirty_cleared;
 	pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
 	pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
 	ret = -ENOMEM;
@@ -1339,10 +1294,6 @@ static int pagemap_open(struct inode *inode, struct file *file)
 {
 	struct mm_struct *mm;
 
-	pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
-			"to stop being page-shift some time soon. See the "
-			"linux/Documentation/vm/pagemap.txt for details.\n");
-
 	mm = proc_mem_open(inode, PTRACE_MODE_READ);
 	if (IS_ERR(mm))
 		return PTR_ERR(mm);
diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index 3a9f193..e1d5ff8 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -57,26 +57,15 @@
  * pagemap kernel ABI bits
  */
 
-#define PM_ENTRY_BYTES      sizeof(uint64_t)
-#define PM_STATUS_BITS      3
-#define PM_STATUS_OFFSET    (64 - PM_STATUS_BITS)
-#define PM_STATUS_MASK      (((1LL << PM_STATUS_BITS) - 1) << PM_STATUS_OFFSET)
-#define PM_STATUS(nr)       (((nr) << PM_STATUS_OFFSET) & PM_STATUS_MASK)
-#define PM_PSHIFT_BITS      6
-#define PM_PSHIFT_OFFSET    (PM_STATUS_OFFSET - PM_PSHIFT_BITS)
-#define PM_PSHIFT_MASK      (((1LL << PM_PSHIFT_BITS) - 1) << PM_PSHIFT_OFFSET)
-#define __PM_PSHIFT(x)      (((uint64_t) (x) << PM_PSHIFT_OFFSET) & PM_PSHIFT_MASK)
-#define PM_PFRAME_MASK      ((1LL << PM_PSHIFT_OFFSET) - 1)
-#define PM_PFRAME(x)        ((x) & PM_PFRAME_MASK)
-
-#define __PM_SOFT_DIRTY      (1LL)
-#define __PM_MMAP_EXCLUSIVE  (2LL)
-#define PM_PRESENT          PM_STATUS(4LL)
-#define PM_SWAP             PM_STATUS(2LL)
-#define PM_FILE             PM_STATUS(1LL)
-#define PM_SOFT_DIRTY       __PM_PSHIFT(__PM_SOFT_DIRTY)
-#define PM_MMAP_EXCLUSIVE   __PM_PSHIFT(__PM_MMAP_EXCLUSIVE)
-
+#define PM_ENTRY_BYTES		8
+#define PM_PFRAME_BITS		54
+#define PM_PFRAME_MASK		((1LL << PM_PFRAME_BITS) - 1)
+#define PM_PFRAME(x)		((x) & PM_PFRAME_MASK)
+#define PM_SOFT_DIRTY		(1ULL << 55)
+#define PM_MMAP_EXCLUSIVE	(1ULL << 56)
+#define PM_FILE			(1ULL << 61)
+#define PM_SWAP			(1ULL << 62)
+#define PM_PRESENT		(1ULL << 63)
 
 /*
  * kernel page flags

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
