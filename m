Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 593666B0105
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 13:06:20 -0400 (EDT)
Message-ID: <515F0484.1010703@parallels.com>
Date: Fri, 05 Apr 2013 21:06:12 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [RFC PATCH 1/1] mm: Another attempt to monitor task's memory changes
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, Matthew Wilcox <willy@linux.intel.com>

Hello,

This is another attempt (previous one was [1]) to implement support for 
memory snapshot for the the checkpoint-restore project (http://criu.org).
Let me remind what the issue is.

<< EOF
To create a dump of an application(s) we save all the information about it
to files, and the biggest part of such dump is the contents of tasks' memory.
However, there are usage scenarios where it's not required to get _all_ the
task memory while creating a dump. For example, when doing periodical dumps,
it's only required to take full memory dump only at the first step and then
take incremental changes of memory. Another example is live migration. We 
copy all the memory to the destination node without stopping all tasks, then
stop them, check for what pages has changed, dump it and the rest of the state,
then copy it to the destination node. This decreases freeze time significantly.

That said, some help from kernel to watch how processes modify the contents
of their memory is required. Previous attempt used ftrace to inform userspace
about memory being written to. This one is different.

EOF

The proposal is to introduce a soft dirty bit on pte (for x86 it's the same
bit that is used by kmemcheck), that is set at the same time as the regular
dirty bit is, but that can be cleared by hands. It is cleared by writing "4"
into the existing /proc/pid/clear_refs file. When soft dirty is cleared, the
pte is also being write-protected to make #pf occur on next write and raise 
the soft dirty bit again. Reading this bit is currently done via the
/proc/pid/pagemap file. There's no bits left in there :( but there are 6
effectively constant bits used for page-shift, so I (for RFC only) reuse the
highest one of them, which is normally zero. Would it be OK to introduce the
"pagemap2" file without this page-size constant?


Previous approach was not nice, because ftrace could drop events so we might
miss significant information about page updates. This way of tracking the
changes is reliable, no pages will be changed w/o being noticed.

Another issue with the previous approach was, that it was impossible to use
one to watch arbitrary task -- task had to mark memory areas with madvise
itself to make events occur. Also, program, that monitored the update events
could interfere with anyone else trying to mess with ftrace.

This approach works on any task via it's proc, and can be used on different
tasks in parallel.

Also, Andrew was asking for some performance numbers related to the change.
Now I can say, that as long as soft dirty bits are not cleared, no performance
penalty occur, since the soft dirty bit and the regular dirty bit are set at 
the same time within the same instruction. When soft dirty is cleared via 
clear_refs, the task in question might slow down, but it will depend on how
actively it uses the memory.


What do you think, does it make sense to develop this approach further?


Links:
[1] http://permalink.gmane.org/gmane.linux.kernel.mm/91428

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

 arch/x86/include/asm/pgtable.h       |   14 +++++++-
 arch/x86/include/asm/pgtable_types.h |    6 +++
 fs/proc/task_mmu.c                   |   59 ++++++++++++++++++++++++++++-------
 mm/Kconfig                           |   11 ++++++
 4 files changed, 77 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 1e67223..45c22a1 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -92,6 +92,11 @@ static inline int pte_dirty(pte_t pte)
 	return pte_flags(pte) & _PAGE_DIRTY;
 }
 
+static inline int pte_soft_dirty(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_SOFTDIRTY;
+}
+
 static inline int pte_young(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_ACCESSED;
@@ -102,6 +107,11 @@ static inline int pmd_young(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_ACCESSED;
 }
 
+static inline int pmd_soft_dirty(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_SOFTDIRTY;
+}
+
 static inline int pte_write(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_RW;
@@ -207,7 +217,7 @@ static inline pte_t pte_mkexec(pte_t pte)
 
 static inline pte_t pte_mkdirty(pte_t pte)
 {
-	return pte_set_flags(pte, _PAGE_DIRTY);
+	return pte_set_flags(pte, _PAGE_DIRTY | _PAGE_SOFTDIRTY);
 }
 
 static inline pte_t pte_mkyoung(pte_t pte)
@@ -271,7 +281,7 @@ static inline pmd_t pmd_wrprotect(pmd_t pmd)
 
 static inline pmd_t pmd_mkdirty(pmd_t pmd)
 {
-	return pmd_set_flags(pmd, _PAGE_DIRTY);
+	return pmd_set_flags(pmd, _PAGE_DIRTY | _PAGE_SOFTDIRTY);
 }
 
 static inline pmd_t pmd_mkhuge(pmd_t pmd)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 567b5d0..72502a0 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -55,6 +55,12 @@
 #define _PAGE_HIDDEN	(_AT(pteval_t, 0))
 #endif
 
+#ifdef CONFIG_MEM_SOFTDIRTY
+#define _PAGE_SOFTDIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
+#else
+#define _PAGE_SOFTDIRTY	(_AT(pteval_t, 0))
+#endif
+
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
 #define _PAGE_NX	(_AT(pteval_t, 1) << _PAGE_BIT_NX)
 #else
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3e636d8..924df45 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -688,10 +688,32 @@ const struct file_operations proc_tid_smaps_operations = {
 	.release	= seq_release_private,
 };
 
+#define CLEAR_REFS_ALL 1
+#define CLEAR_REFS_ANON 2
+#define CLEAR_REFS_MAPPED 3
+#define CLEAR_REFS_SOFT_DIRTY 4
+
+struct crefs_walk_priv {
+	struct vm_area_struct *vma;
+	int type;
+};
+
+static inline void clear_soft_dirty(struct vm_area_struct *vma,
+		unsigned long addr, pte_t *pte)
+{
+#ifdef CONFIG_MEM_SOFTDIRTY
+	pte_t ptent = *pte;
+	ptent = pte_wrprotect(ptent);
+	ptent = pte_clear_flags(ptent, _PAGE_SOFTDIRTY);
+	set_pte_at(vma->vm_mm, addr, pte, ptent);
+#endif
+}
+
 static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
-	struct vm_area_struct *vma = walk->private;
+	struct crefs_walk_priv *cp = walk->private;
+	struct vm_area_struct *vma = cp->vma;
 	pte_t *pte, ptent;
 	spinlock_t *ptl;
 	struct page *page;
@@ -706,6 +728,11 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 		if (!pte_present(ptent))
 			continue;
 
+		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
+			clear_soft_dirty(vma, addr, pte);
+			continue;
+		}
+
 		page = vm_normal_page(vma, addr, ptent);
 		if (!page)
 			continue;
@@ -719,10 +746,6 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 
-#define CLEAR_REFS_ALL 1
-#define CLEAR_REFS_ANON 2
-#define CLEAR_REFS_MAPPED 3
-
 static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 				size_t count, loff_t *ppos)
 {
@@ -741,20 +764,24 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	rv = kstrtoint(strstrip(buffer), 10, &type);
 	if (rv < 0)
 		return rv;
-	if (type < CLEAR_REFS_ALL || type > CLEAR_REFS_MAPPED)
+	if (type < CLEAR_REFS_ALL || type > CLEAR_REFS_SOFT_DIRTY)
 		return -EINVAL;
 	task = get_proc_task(file_inode(file));
 	if (!task)
 		return -ESRCH;
 	mm = get_task_mm(task);
 	if (mm) {
+		struct crefs_walk_priv cp = {
+			.type = type,
+		};
 		struct mm_walk clear_refs_walk = {
 			.pmd_entry = clear_refs_pte_range,
 			.mm = mm,
+			.private = &cp,
 		};
 		down_read(&mm->mmap_sem);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
-			clear_refs_walk.private = vma;
+			cp.vma = vma;
 			if (is_vm_hugetlb_page(vma))
 				continue;
 			/*
@@ -814,6 +841,11 @@ struct pagemapread {
 #define PM_PRESENT          PM_STATUS(4LL)
 #define PM_SWAP             PM_STATUS(2LL)
 #define PM_FILE             PM_STATUS(1LL)
+#ifdef CONFIG_MEM_SOFTDIRTY
+#define PM_SOFT_DIRTY       (PM_STATUS(1LL) >> 1)
+#else
+#define PM_SOFT_DIRTY       0
+#endif
 #define PM_NOT_PRESENT      PM_PSHIFT(PAGE_SHIFT)
 #define PM_END_OF_BUFFER    1
 
@@ -872,13 +904,15 @@ static void pte_to_pagemap_entry(pagemap_entry_t *pme,
 
 	if (page && !PageAnon(page))
 		flags |= PM_FILE;
+	if (pte_soft_dirty(pte))
+		flags |= PM_SOFT_DIRTY;
 
 	*pme = make_pme(PM_PFRAME(frame) | PM_PSHIFT(PAGE_SHIFT) | flags);
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
-					pmd_t pmd, int offset)
+		pmd_t pmd, int offset, u64 pmd_flags)
 {
 	/*
 	 * Currently pmd for thp is always present because thp can not be
@@ -887,13 +921,13 @@ static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
 	 */
 	if (pmd_present(pmd))
 		*pme = make_pme(PM_PFRAME(pmd_pfn(pmd) + offset)
-				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT);
+				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT | pmd_flags);
 	else
 		*pme = make_pme(PM_NOT_PRESENT);
 }
 #else
 static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme,
-						pmd_t pmd, int offset)
+		pmd_t pmd, int offset, pagemap_entry_t pmd_flags)
 {
 }
 #endif
@@ -910,12 +944,15 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
 	if (vma && pmd_trans_huge_lock(pmd, vma) == 1) {
+		u64 pmd_flags;
+
+		pmd_flags = (pmd_soft_dirty(*pmd) ? PM_SOFT_DIRTY : 0);
 		for (; addr != end; addr += PAGE_SIZE) {
 			unsigned long offset;
 
 			offset = (addr & ~PAGEMAP_WALK_MASK) >>
 					PAGE_SHIFT;
-			thp_pmd_to_pagemap_entry(&pme, *pmd, offset);
+			thp_pmd_to_pagemap_entry(&pme, *pmd, offset, pmd_flags);
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
 				break;
diff --git a/mm/Kconfig b/mm/Kconfig
index ae55c1e..16c6bc3 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -467,3 +467,14 @@ config FRONTSWAP
 	  and swap data is stored as normal on the matching swap device.
 
 	  If unsure, say Y to enable frontswap.
+
+config MEM_SOFTDIRTY
+	bool "Track memory changes"
+	depends on CHECKPOINT_RESTORE && !KMEMCHECK
+	select PROC_PAGE_MONITOR
+	help
+	  This option enables memory changes tracking by introducing a
+	  soft dirty bit on pte-s. This bit it set when someone writes
+	  into a page just as regular dirty bit, but unlike the latter
+	  it can be cleared by hands.
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
