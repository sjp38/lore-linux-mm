Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A18176B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 15:58:44 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id r10so3435273lbi.29
        for <linux-mm@kvack.org>; Mon, 19 Aug 2013 12:58:42 -0700 (PDT)
Date: Mon, 19 Aug 2013 23:58:36 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] mm: Track vma changes with VM_SOFTDIRTY bit
Message-ID: <20130819195836.GO23919@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Pavel reported that in case if vma area get unmapped and
then mapped (or expanded) in-place, the soft dirty tracker
won't be able to recognize this situation since it works on
pte level and ptes are get zapped on unmap, loosing soft
dirty bit of course.

So to resolve this situation we need to track actions
on vma level, there VM_SOFTDIRTY flag comes in. When
new vma area created (or old expanded) we set this bit,
and keep it here until application calls for clearing
soft dirty bit.

Thus when user space application track memory changes
now it can detect if vma area is renewed.

Reported-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/exec.c          |    2 +-
 fs/proc/task_mmu.c |   46 ++++++++++++++++++++++++++++++++++++----------
 include/linux/mm.h |    6 ++++++
 mm/mmap.c          |   12 +++++++++++-
 4 files changed, 54 insertions(+), 12 deletions(-)

Index: linux-2.6.git/fs/exec.c
===================================================================
--- linux-2.6.git.orig/fs/exec.c
+++ linux-2.6.git/fs/exec.c
@@ -266,7 +266,7 @@ static int __bprm_mm_init(struct linux_b
 	BUILD_BUG_ON(VM_STACK_FLAGS & VM_STACK_INCOMPLETE_SETUP);
 	vma->vm_end = STACK_TOP_MAX;
 	vma->vm_start = vma->vm_end - PAGE_SIZE;
-	vma->vm_flags = VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
+	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 
Index: linux-2.6.git/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.git.orig/fs/proc/task_mmu.c
+++ linux-2.6.git/fs/proc/task_mmu.c
@@ -740,6 +740,9 @@ static inline void clear_soft_dirty(stru
 		ptent = pte_file_clear_soft_dirty(ptent);
 	}
 
+	if (vma->vm_flags & VM_SOFTDIRTY)
+		vma->vm_flags &= ~VM_SOFTDIRTY;
+
 	set_pte_at(vma->vm_mm, addr, pte, ptent);
 #endif
 }
@@ -949,13 +952,15 @@ static void pte_to_pagemap_entry(pagemap
 		if (is_migration_entry(entry))
 			page = migration_entry_to_page(entry);
 	} else {
-		*pme = make_pme(PM_NOT_PRESENT(pm->v2));
+		if (vma->vm_flags & VM_SOFTDIRTY)
+			flags2 |= __PM_SOFT_DIRTY;
+		*pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, flags2));
 		return;
 	}
 
 	if (page && !PageAnon(page))
 		flags |= PM_FILE;
-	if (pte_soft_dirty(pte))
+	if ((vma->vm_flags & VM_SOFTDIRTY) || pte_soft_dirty(pte))
 		flags2 |= __PM_SOFT_DIRTY;
 
 	*pme = make_pme(PM_PFRAME(frame) | PM_STATUS2(pm->v2, flags2) | flags);
@@ -974,7 +979,7 @@ static void thp_pmd_to_pagemap_entry(pag
 		*pme = make_pme(PM_PFRAME(pmd_pfn(pmd) + offset)
 				| PM_STATUS2(pm->v2, pmd_flags2) | PM_PRESENT);
 	else
-		*pme = make_pme(PM_NOT_PRESENT(pm->v2));
+		*pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, pmd_flags2));
 }
 #else
 static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
@@ -997,7 +1002,11 @@ static int pagemap_pte_range(pmd_t *pmd,
 	if (vma && pmd_trans_huge_lock(pmd, vma) == 1) {
 		int pmd_flags2;
 
-		pmd_flags2 = (pmd_soft_dirty(*pmd) ? __PM_SOFT_DIRTY : 0);
+		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
+			pmd_flags2 = __PM_SOFT_DIRTY;
+		else
+			pmd_flags2 = 0;
+
 		for (; addr != end; addr += PAGE_SIZE) {
 			unsigned long offset;
 
@@ -1015,12 +1024,17 @@ static int pagemap_pte_range(pmd_t *pmd,
 	if (pmd_trans_unstable(pmd))
 		return 0;
 	for (; addr != end; addr += PAGE_SIZE) {
+		int flags2;
 
 		/* check to see if we've left 'vma' behind
 		 * and need a new, higher one */
 		if (vma && (addr >= vma->vm_end)) {
 			vma = find_vma(walk->mm, addr);
-			pme = make_pme(PM_NOT_PRESENT(pm->v2));
+			if (vma && (vma->vm_flags & VM_SOFTDIRTY))
+				flags2 = __PM_SOFT_DIRTY;
+			else
+				flags2 = 0;
+			pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, flags2));
 		}
 
 		/* check that 'vma' actually covers this address,
@@ -1044,13 +1058,15 @@ static int pagemap_pte_range(pmd_t *pmd,
 
 #ifdef CONFIG_HUGETLB_PAGE
 static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
-					pte_t pte, int offset)
+					pte_t pte, int offset, int flags2)
 {
 	if (pte_present(pte))
-		*pme = make_pme(PM_PFRAME(pte_pfn(pte) + offset)
-				| PM_STATUS2(pm->v2, 0) | PM_PRESENT);
+		*pme = make_pme(PM_PFRAME(pte_pfn(pte) + offset)	|
+				PM_STATUS2(pm->v2, flags2)		|
+				PM_PRESENT);
 	else
-		*pme = make_pme(PM_NOT_PRESENT(pm->v2));
+		*pme = make_pme(PM_NOT_PRESENT(pm->v2)			|
+				PM_STATUS2(pm->v2, flags2));
 }
 
 /* This function walks within one hugetlb entry in the single call */
@@ -1059,12 +1075,22 @@ static int pagemap_hugetlb_range(pte_t *
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
+	struct vm_area_struct *vma;
 	int err = 0;
+	int flags2;
 	pagemap_entry_t pme;
 
+	vma = find_vma(walk->mm, addr);
+	WARN_ON_ONCE(!vma);
+
+	if (vma && (vma->vm_flags & VM_SOFTDIRTY))
+		flags2 = __PM_SOFT_DIRTY;
+	else
+		flags2 = 0;
+
 	for (; addr != end; addr += PAGE_SIZE) {
 		int offset = (addr & ~hmask) >> PAGE_SHIFT;
-		huge_pte_to_pagemap_entry(&pme, pm, *pte, offset);
+		huge_pte_to_pagemap_entry(&pme, pm, *pte, offset, flags2);
 		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			return err;
Index: linux-2.6.git/include/linux/mm.h
===================================================================
--- linux-2.6.git.orig/include/linux/mm.h
+++ linux-2.6.git/include/linux/mm.h
@@ -115,6 +115,12 @@ extern unsigned int kobjsize(const void
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
 
+#ifdef CONFIG_MEM_SOFT_DIRTY
+# define VM_SOFTDIRTY	0x08000000	/* Not soft dirty clean area */
+#else
+# define VM_SOFTDIRTY	0
+#endif
+
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
Index: linux-2.6.git/mm/mmap.c
===================================================================
--- linux-2.6.git.orig/mm/mmap.c
+++ linux-2.6.git/mm/mmap.c
@@ -1616,6 +1616,15 @@ out:
 	if (file)
 		uprobe_mmap(vma);
 
+	/*
+	 * New (or expanded) vma always get soft dirty status.
+	 * Otherwise user-space soft-dirty page tracker won't
+	 * be able to distinguish situation when vma area unmapped,
+	 * then new mapped in-place (which must be aimed as
+	 * a completely new data area).
+	 */
+	vma->vm_flags |= VM_SOFTDIRTY;
+
 	return addr;
 
 unmap_and_free_vma:
@@ -2663,6 +2672,7 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED)
 		mm->locked_vm += (len >> PAGE_SHIFT);
+	vma->vm_flags |= VM_SOFTDIRTY;
 	return addr;
 }
 
@@ -2930,7 +2940,7 @@ int install_special_mapping(struct mm_st
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
 
-	vma->vm_flags = vm_flags | mm->def_flags | VM_DONTEXPAND;
+	vma->vm_flags = vm_flags | mm->def_flags | VM_DONTEXPAND | VM_SOFTDIRTY;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
 
 	vma->vm_ops = &special_mapping_vmops;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
