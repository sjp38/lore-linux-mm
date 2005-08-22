Date: Mon, 22 Aug 2005 22:31:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [RFT][PATCH 2/2] pagefault scalability alternative
In-Reply-To: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Then add Hugh's pagefault scalability alternative on top.

--- 26136m1-/arch/i386/kernel/vm86.c	2005-08-19 14:30:02.000000000 +0100
+++ 26136m1+/arch/i386/kernel/vm86.c	2005-08-22 12:41:30.000000000 +0100
@@ -134,17 +134,16 @@ struct pt_regs * fastcall save_v86_state
 	return ret;
 }
 
-static void mark_screen_rdonly(struct task_struct * tsk)
+static void mark_screen_rdonly(struct mm_struct *mm)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte, *mapped;
+	pte_t *pte;
+	spinlock_t *ptl;
 	int i;
 
-	preempt_disable();
-	spin_lock(&tsk->mm->page_table_lock);
-	pgd = pgd_offset(tsk->mm, 0xA0000);
+	pgd = pgd_offset(mm, 0xA0000);
 	if (pgd_none_or_clear_bad(pgd))
 		goto out;
 	pud = pud_offset(pgd, 0xA0000);
@@ -153,16 +152,14 @@ static void mark_screen_rdonly(struct ta
 	pmd = pmd_offset(pud, 0xA0000);
 	if (pmd_none_or_clear_bad(pmd))
 		goto out;
-	pte = mapped = pte_offset_map(pmd, 0xA0000);
+	pte = pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
 	for (i = 0; i < 32; i++) {
 		if (pte_present(*pte))
 			set_pte(pte, pte_wrprotect(*pte));
 		pte++;
 	}
-	pte_unmap(mapped);
+	pte_unmap_unlock(pte, ptl);
 out:
-	spin_unlock(&tsk->mm->page_table_lock);
-	preempt_enable();
 	flush_tlb();
 }
 
@@ -306,7 +303,7 @@ static void do_sys_vm86(struct kernel_vm
 
 	tsk->thread.screen_bitmap = info->screen_bitmap;
 	if (info->flags & VM86_SCREEN_BITMAP)
-		mark_screen_rdonly(tsk);
+		mark_screen_rdonly(tsk->mm);
 	__asm__ __volatile__(
 		"xorl %%eax,%%eax; movl %%eax,%%fs; movl %%eax,%%gs\n\t"
 		"movl %0,%%esp\n\t"
--- 26136m1-/arch/i386/mm/ioremap.c	2005-08-08 11:56:42.000000000 +0100
+++ 26136m1+/arch/i386/mm/ioremap.c	2005-08-22 12:41:30.000000000 +0100
@@ -28,7 +28,7 @@ static int ioremap_pte_range(pmd_t *pmd,
 	unsigned long pfn;
 
 	pfn = phys_addr >> PAGE_SHIFT;
-	pte = pte_alloc_kernel(&init_mm, pmd, addr);
+	pte = pte_alloc_kernel(pmd, addr);
 	if (!pte)
 		return -ENOMEM;
 	do {
@@ -87,14 +87,12 @@ static int ioremap_page_range(unsigned l
 	flush_cache_all();
 	phys_addr -= addr;
 	pgd = pgd_offset_k(addr);
-	spin_lock(&init_mm.page_table_lock);
 	do {
 		next = pgd_addr_end(addr, end);
 		err = ioremap_pud_range(pgd, addr, next, phys_addr+addr, flags);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	spin_unlock(&init_mm.page_table_lock);
 	flush_tlb_all();
 	return err;
 }
--- 26136m1-/arch/i386/mm/pgtable.c	2005-08-19 14:30:02.000000000 +0100
+++ 26136m1+/arch/i386/mm/pgtable.c	2005-08-22 12:41:30.000000000 +0100
@@ -153,14 +153,15 @@ pte_t *pte_alloc_one_kernel(struct mm_st
 
 struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	struct page *pte;
+	struct page *page;
 
 #ifdef CONFIG_HIGHPTE
-	pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|__GFP_ZERO, 0);
+	page = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|__GFP_ZERO, 0);
 #else
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	page = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
 #endif
-	return pte;
+	pte_lock_init(page);
+	return page;
 }
 
 void pmd_ctor(void *pmd, kmem_cache_t *cache, unsigned long flags)
@@ -266,3 +267,45 @@ void pgd_free(pgd_t *pgd)
 	/* in the non-PAE case, free_pgtables() clears user pgd entries */
 	kmem_cache_free(pgd_cache, pgd);
 }
+
+#ifdef CONFIG_HIGHPTE
+/*
+ * This is out-of-line here in order to get the header includes working.
+ * Perhaps we should add a linux/pgtable.h to get around that, though
+ * the problem is really with all that kmap_atomic needs to pull in.
+ */
+pte_t *pte_offset_map(pmd_t *pmd, unsigned long address)
+{
+	struct page *page = pmd_page(*pmd);
+	return (pte_t *)kmap_atomic(page, KM_PTE0) + pte_index(address);
+}
+#endif /* CONFIG_HIGHPTE */
+
+#if defined(CONFIG_SPLIT_PTLOCK) || defined(CONFIG_HIGHPTE)
+/*
+ * This is out-of-line here in order to get the header includes working,
+ * and avoid repeated evaluation of pmd_page when CONFIG_SPLIT_PTLOCK.
+ */
+pte_t *pte_offset_map_lock(struct mm_struct *mm, pmd_t *pmd,
+			unsigned long address, spinlock_t **ptlp)
+{
+	struct page *page = pmd_page(*pmd);
+	spinlock_t *ptl;
+	pte_t *pte;
+
+#ifdef CONFIG_SPLIT_PTLOCK
+	ptl = __pte_lockptr(page);
+#else
+	ptl = &mm->page_table_lock;
+#endif
+	*ptlp = ptl;
+
+#ifdef CONFIG_HIGHPTE
+	pte = (pte_t *)kmap_atomic(page, KM_PTE0) + pte_index(address);
+#else
+	pte = (pte_t *)page_address(page) + pte_index(address);
+#endif
+	spin_lock(ptl);
+	return pte;
+}
+#endif /* CONFIG_SPLIT_PTLOCK || CONFIG_HIGHPTE */
--- 26136m1-/arch/i386/oprofile/backtrace.c	2005-08-08 11:56:42.000000000 +0100
+++ 26136m1+/arch/i386/oprofile/backtrace.c	2005-08-22 12:41:30.000000000 +0100
@@ -12,6 +12,7 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <asm/ptrace.h>
+#include <asm/uaccess.h>
 
 struct frame_head {
 	struct frame_head * ebp;
@@ -21,26 +22,26 @@ struct frame_head {
 static struct frame_head *
 dump_backtrace(struct frame_head * head)
 {
-	oprofile_add_trace(head->ret);
+	struct frame_head khead[2];
 
-	/* frame pointers should strictly progress back up the stack
-	 * (towards higher addresses) */
-	if (head >= head->ebp)
+	/*
+	 * Hugh: I've most probably got this wrong, but I believe
+	 * it's along the right lines, and should be easily fixed -
+	 * and don't forget to run sparse over it, thanks.
+	 * As before, check beyond the frame_head too before
+	 * accepting it, though I don't really get that logic.
+	 */
+	if (__copy_from_user_inatomic(khead, head, sizeof(khead)))
 		return NULL;
 
-	return head->ebp;
-}
+	oprofile_add_trace(khead[0].ret);
 
-/* check that the page(s) containing the frame head are present */
-static int pages_present(struct frame_head * head)
-{
-	struct mm_struct * mm = current->mm;
-
-	/* FIXME: only necessary once per page */
-	if (!check_user_page_readable(mm, (unsigned long)head))
-		return 0;
+	/* frame pointers should strictly progress back up the stack
+	 * (towards higher addresses) */
+	if (head >= khead[0].ebp)
+		return NULL;
 
-	return check_user_page_readable(mm, (unsigned long)(head + 1));
+	return khead[0].ebp;
 }
 
 /*
@@ -97,15 +98,6 @@ x86_backtrace(struct pt_regs * const reg
 		return;
 	}
 
-#ifdef CONFIG_SMP
-	if (!spin_trylock(&current->mm->page_table_lock))
-		return;
-#endif
-
-	while (depth-- && head && pages_present(head))
+	while (depth-- && head)
 		head = dump_backtrace(head);
-
-#ifdef CONFIG_SMP
-	spin_unlock(&current->mm->page_table_lock);
-#endif
 }
--- 26136m1-/arch/ia64/mm/init.c	2005-08-08 11:56:43.000000000 +0100
+++ 26136m1+/arch/ia64/mm/init.c	2005-08-22 12:41:30.000000000 +0100
@@ -275,26 +275,21 @@ put_kernel_page (struct page *page, unsi
 
 	pgd = pgd_offset_k(address);		/* note: this is NOT pgd_offset()! */
 
-	spin_lock(&init_mm.page_table_lock);
 	{
 		pud = pud_alloc(&init_mm, pgd, address);
 		if (!pud)
 			goto out;
-
 		pmd = pmd_alloc(&init_mm, pud, address);
 		if (!pmd)
 			goto out;
-		pte = pte_alloc_map(&init_mm, pmd, address);
+		pte = pte_alloc_kernel(pmd, address);
 		if (!pte)
 			goto out;
-		if (!pte_none(*pte)) {
-			pte_unmap(pte);
+		if (!pte_none(*pte))
 			goto out;
-		}
 		set_pte(pte, mk_pte(page, pgprot));
-		pte_unmap(pte);
 	}
-  out:	spin_unlock(&init_mm.page_table_lock);
+  out:
 	/* no need for flush_tlb */
 	return page;
 }
--- 26136m1-/arch/x86_64/mm/ioremap.c	2005-08-08 11:56:50.000000000 +0100
+++ 26136m1+/arch/x86_64/mm/ioremap.c	2005-08-22 12:41:30.000000000 +0100
@@ -60,7 +60,7 @@ static inline int remap_area_pmd(pmd_t *
 	if (address >= end)
 		BUG();
 	do {
-		pte_t * pte = pte_alloc_kernel(&init_mm, pmd, address);
+		pte_t * pte = pte_alloc_kernel(pmd, address);
 		if (!pte)
 			return -ENOMEM;
 		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
@@ -105,7 +105,6 @@ static int remap_area_pages(unsigned lon
 	flush_cache_all();
 	if (address >= end)
 		BUG();
-	spin_lock(&init_mm.page_table_lock);
 	do {
 		pud_t *pud;
 		pud = pud_alloc(&init_mm, pgd, address);
@@ -119,7 +118,6 @@ static int remap_area_pages(unsigned lon
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		pgd++;
 	} while (address && (address < end));
-	spin_unlock(&init_mm.page_table_lock);
 	flush_tlb_all();
 	return error;
 }
--- 26136m1-/fs/exec.c	2005-08-19 14:30:09.000000000 +0100
+++ 26136m1+/fs/exec.c	2005-08-22 12:41:30.000000000 +0100
@@ -309,25 +309,24 @@ void install_arg_page(struct vm_area_str
 	pud_t * pud;
 	pmd_t * pmd;
 	pte_t * pte;
+	spinlock_t *ptl;
 
 	if (unlikely(anon_vma_prepare(vma)))
-		goto out_sig;
+		goto out;
 
 	flush_dcache_page(page);
 	pgd = pgd_offset(mm, address);
-
-	spin_lock(&mm->page_table_lock);
 	pud = pud_alloc(mm, pgd, address);
 	if (!pud)
 		goto out;
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		goto out;
-	pte = pte_alloc_map(mm, pmd, address);
+	pte = pte_alloc_map_lock(mm, pmd, address, &ptl);
 	if (!pte)
 		goto out;
 	if (!pte_none(*pte)) {
-		pte_unmap(pte);
+		pte_unmap_unlock(pte, ptl);
 		goto out;
 	}
 	inc_mm_counter(mm, rss);
@@ -335,14 +334,11 @@ void install_arg_page(struct vm_area_str
 	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
 	page_add_anon_rmap(page, vma, address);
-	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+	pte_unmap_unlock(pte, ptl);
 
 	/* no need for flush_tlb */
 	return;
 out:
-	spin_unlock(&mm->page_table_lock);
-out_sig:
 	__free_page(page);
 	force_sig(SIGKILL, current);
 }
--- 26136m1-/fs/hugetlbfs/inode.c	2005-08-08 11:57:11.000000000 +0100
+++ 26136m1+/fs/hugetlbfs/inode.c	2005-08-22 12:41:30.000000000 +0100
@@ -92,7 +92,7 @@ out:
 }
 
 /*
- * Called under down_write(mmap_sem), page_table_lock is not held
+ * Called under down_write(mmap_sem)
  */
 
 #ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
@@ -321,7 +321,7 @@ hugetlb_vmtruncate_list(struct prio_tree
 
 		v_length = vma->vm_end - vma->vm_start;
 
-		zap_hugepage_range(vma,
+		unmap_hugepage_range(vma,
 				vma->vm_start + v_offset,
 				v_length - v_offset);
 	}
--- 26136m1-/fs/proc/task_mmu.c	2005-08-19 14:30:10.000000000 +0100
+++ 26136m1+/fs/proc/task_mmu.c	2005-08-22 12:41:30.000000000 +0100
@@ -186,10 +186,11 @@ static void smaps_pte_range(struct vm_ar
 				struct mem_size_stats *mss)
 {
 	pte_t *pte, ptent;
+	spinlock_t *ptl;
 	unsigned long pfn;
 	struct page *page;
 
-	pte = pte_offset_map(pmd, addr);
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	do {
 		ptent = *pte;
 		if (pte_none(ptent) || !pte_present(ptent))
@@ -213,8 +214,8 @@ static void smaps_pte_range(struct vm_ar
 				mss->private_clean += PAGE_SIZE;
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
-	cond_resched_lock(&vma->vm_mm->page_table_lock);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
 }
 
 static inline void smaps_pmd_range(struct vm_area_struct *vma, pud_t *pud,
@@ -272,13 +273,8 @@ static int show_smap(struct seq_file *m,
 	struct mem_size_stats mss;
 
 	memset(&mss, 0, sizeof mss);
-
-	if (mm) {
-		spin_lock(&mm->page_table_lock);
+	if (mm)
 		smaps_pgd_range(vma, vma->vm_start, vma->vm_end, &mss);
-		spin_unlock(&mm->page_table_lock);
-	}
-
 	return show_map_internal(m, v, &mss);
 }
 
@@ -407,9 +403,8 @@ static struct numa_maps *get_numa_maps(c
 	for_each_node(i)
 		md->node[i] =0;
 
-	spin_lock(&mm->page_table_lock);
  	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
-		page = follow_page(mm, vaddr, 0);
+		page = follow_page(mm, vaddr, 0, 0);
 		if (page) {
 			int count = page_mapcount(page);
 
@@ -422,8 +417,8 @@ static struct numa_maps *get_numa_maps(c
 				md->anon++;
 			md->node[page_to_nid(page)]++;
 		}
+		cond_resched();
 	}
-	spin_unlock(&mm->page_table_lock);
 	return md;
 }
 
--- 26136m1-/include/asm-generic/tlb.h	2005-06-17 20:48:29.000000000 +0100
+++ 26136m1+/include/asm-generic/tlb.h	2005-08-22 12:41:30.000000000 +0100
@@ -135,10 +135,10 @@ static inline void tlb_remove_page(struc
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep)					\
+#define pte_free_tlb(tlb, page)					\
 	do {							\
 		tlb->need_flush = 1;				\
-		__pte_free_tlb(tlb, ptep);			\
+		__pte_free_tlb(tlb, page);			\
 	} while (0)
 
 #ifndef __ARCH_HAS_4LEVEL_HACK
--- 26136m1-/include/asm-i386/pgalloc.h	2005-06-17 20:48:29.000000000 +0100
+++ 26136m1+/include/asm-i386/pgalloc.h	2005-08-22 12:41:30.000000000 +0100
@@ -27,13 +27,16 @@ static inline void pte_free_kernel(pte_t
 	free_page((unsigned long)pte);
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct page *page)
 {
-	__free_page(pte);
+	pte_lock_deinit(page);
+	__free_page(page);
 }
 
-
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb, page)	do {	\
+	pte_lock_deinit(page);			\
+	tlb_remove_page((tlb), (page));		\
+} while (0)
 
 #ifdef CONFIG_X86_PAE
 /*
--- 26136m1-/include/asm-i386/pgtable.h	2005-08-19 14:30:12.000000000 +0100
+++ 26136m1+/include/asm-i386/pgtable.h	2005-08-22 12:41:30.000000000 +0100
@@ -202,7 +202,8 @@ extern unsigned long pg0[];
 
 #define pte_present(x)	((x).pte_low & (_PAGE_PRESENT | _PAGE_PROTNONE))
 
-#define pmd_none(x)	(!pmd_val(x))
+/* To avoid harmful races, pmd_none(x) should check only the lower when PAE */
+#define pmd_none(x)	(!(unsigned long)pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
 #define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK & ~_PAGE_USER)) != _KERNPG_TABLE)
 
@@ -401,9 +402,8 @@ extern pte_t *lookup_address(unsigned lo
 
 extern void noexec_setup(const char *str);
 
-#if defined(CONFIG_HIGHPTE)
-#define pte_offset_map(dir, address) \
-	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + pte_index(address))
+#ifdef CONFIG_HIGHPTE
+extern pte_t *pte_offset_map(pmd_t *pmd, unsigned long address);
 #define pte_offset_map_nested(dir, address) \
 	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + pte_index(address))
 #define pte_unmap(pte) kunmap_atomic(pte, KM_PTE0)
@@ -416,6 +416,12 @@ extern void noexec_setup(const char *str
 #define pte_unmap_nested(pte) do { } while (0)
 #endif
 
+#if defined(CONFIG_HIGHPTE) || defined(CONFIG_SPLIT_PTLOCK)
+#define __HAVE_PTE_OFFSET_MAP_LOCK
+extern pte_t *pte_offset_map_lock(struct mm_struct *mm,
+		pmd_t *pmd, unsigned long address, spinlock_t **ptlp);
+#endif
+
 /*
  * The i386 doesn't have any external MMU info: the kernel page
  * tables contain all the necessary information.
--- 26136m1-/include/asm-ia64/pgalloc.h	2005-08-20 16:44:38.000000000 +0100
+++ 26136m1+/include/asm-ia64/pgalloc.h	2005-08-22 12:41:30.000000000 +0100
@@ -119,7 +119,9 @@ pmd_populate_kernel(struct mm_struct *mm
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long addr)
 {
-	return virt_to_page(pgtable_quicklist_alloc());
+	struct page *page = virt_to_page(pgtable_quicklist_alloc());
+	pte_lock_init(page);
+	return page;
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
@@ -128,17 +130,18 @@ static inline pte_t *pte_alloc_one_kerne
 	return pgtable_quicklist_alloc();
 }
 
-static inline void pte_free(struct page *pte)
+static inline void pte_free(struct page *page)
 {
-	pgtable_quicklist_free(page_address(pte));
+	pte_lock_deinit(page);
+	pgtable_quicklist_free(page_address(page));
 }
 
-static inline void pte_free_kernel(pte_t * pte)
+static inline void pte_free_kernel(pte_t *pte)
 {
 	pgtable_quicklist_free(pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pte_free_tlb(tlb, page)	pte_free(page)
 
 extern void check_pgt_cache(void);
 
--- 26136m1-/include/asm-x86_64/pgalloc.h	2005-06-17 20:48:29.000000000 +0100
+++ 26136m1+/include/asm-x86_64/pgalloc.h	2005-08-22 12:41:30.000000000 +0100
@@ -18,11 +18,6 @@ static inline void pmd_populate(struct m
 	set_pmd(pmd, __pmd(_PAGE_TABLE | (page_to_pfn(pte) << PAGE_SHIFT)));
 }
 
-extern __inline__ pmd_t *get_pmd(void)
-{
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL);
-}
-
 extern __inline__ void pmd_free(pmd_t *pmd)
 {
 	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
@@ -77,10 +72,11 @@ static inline pte_t *pte_alloc_one_kerne
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	void *p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
-	if (!p)
+	struct page *page = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	if (!page)
 		return NULL;
-	return virt_to_page(p);
+	pte_lock_init(page);
+	return page;
 }
 
 /* Should really implement gc for free page table pages. This could be
@@ -89,15 +85,19 @@ static inline struct page *pte_alloc_one
 extern __inline__ void pte_free_kernel(pte_t *pte)
 {
 	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
-	free_page((unsigned long)pte); 
+	free_page((unsigned long)pte);
 }
 
-extern inline void pte_free(struct page *pte)
+extern inline void pte_free(struct page *page)
 {
-	__free_page(pte);
+	pte_lock_deinit(page);
+	__free_page(page);
 } 
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb, page)	do {	\
+	pte_lock_deinit(page);			\
+	tlb_remove_page((tlb), (page));		\
+} while (0)
 
 #define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
 #define __pud_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
--- 26136m1-/include/linux/hugetlb.h	2005-08-08 11:57:23.000000000 +0100
+++ 26136m1+/include/linux/hugetlb.h	2005-08-22 12:41:30.000000000 +0100
@@ -16,7 +16,6 @@ static inline int is_vm_hugetlb_page(str
 int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int);
-void zap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
 void unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 int hugetlb_report_meminfo(char *);
@@ -91,7 +90,6 @@ static inline unsigned long hugetlb_tota
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
 #define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
-#define zap_hugepage_range(vma, start, len)	BUG()
 #define unmap_hugepage_range(vma, start, end)	BUG()
 #define is_hugepage_mem_enough(size)		0
 #define hugetlb_report_meminfo(buf)		0
--- 26136m1-/include/linux/mm.h	2005-08-19 14:30:13.000000000 +0100
+++ 26136m1+/include/linux/mm.h	2005-08-22 12:41:30.000000000 +0100
@@ -709,10 +709,6 @@ static inline void unmap_shared_mapping_
 }
 
 extern int vmtruncate(struct inode * inode, loff_t offset);
-extern pud_t *FASTCALL(__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address));
-extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address));
-extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
-extern pte_t *FASTCALL(pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
 extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot);
 extern int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, unsigned long pgoff, pgprot_t prot);
 extern int __handle_mm_fault(struct mm_struct *mm,struct vm_area_struct *vma, unsigned long address, int write_access);
@@ -764,16 +760,15 @@ struct shrinker;
 extern struct shrinker *set_shrinker(int, shrinker_t);
 extern void remove_shrinker(struct shrinker *shrinker);
 
-/*
- * On a two-level or three-level page table, this ends up being trivial. Thus
- * the inlining and the symmetry break with pte_alloc_map() that does all
- * of this out-of-line.
- */
+pud_t *__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+pmd_t *__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
+int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
+
 /*
  * The following ifdef needed to get the 4level-fixup.h header to work.
  * Remove it when 4level-fixup.h has been removed.
  */
-#ifdef CONFIG_MMU
 #ifndef __ARCH_HAS_4LEVEL_HACK 
 static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
@@ -788,8 +783,58 @@ static inline pmd_t *pmd_alloc(struct mm
 		return __pmd_alloc(mm, pud, address);
 	return pmd_offset(pud, address);
 }
-#endif
-#endif /* CONFIG_MMU */
+#endif /* !__ARCH_HAS_4LEVEL_HACK */
+
+#ifdef CONFIG_SPLIT_PTLOCK
+#define __pte_lockptr(page)	((spinlock_t *)&((page)->private))
+#define pte_lock_init(page)	spin_lock_init(__pte_lockptr(page))
+#define pte_lock_deinit(page)	((page)->mapping = NULL)
+#define pte_lockptr(mm, pmd)	__pte_lockptr(pmd_page(*(pmd)))
+#else
+#define pte_lock_init(page)	do {} while (0)
+#define pte_lock_deinit(page)	do {} while (0)
+#define pte_lockptr(mm, pmd)	(&(mm)->page_table_lock)
+#endif /* !CONFIG_SPLIT_PTLOCK */
+
+#ifndef __HAVE_PTE_OFFSET_MAP_LOCK
+static inline pte_t *pte_offset_map_lock(struct mm_struct *mm,
+		pmd_t *pmd, unsigned long address, spinlock_t **ptlp)
+{
+	spinlock_t *ptl = pte_lockptr(mm, pmd);
+	pte_t *pte = pte_offset_map(pmd, address);
+	*ptlp = ptl;
+	spin_lock(ptl);
+	return pte;
+}
+#endif /* !__HAVE_PTE_OFFSET_MAP_LOCK */
+
+#define pte_unmap_unlock(pte, ptl)	do {	\
+	spin_unlock(ptl);			\
+	pte_unmap(pte);				\
+} while (0)
+
+static inline pte_t *pte_alloc_map(struct mm_struct *mm,
+		pmd_t *pmd, unsigned long address)
+{
+	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, address) < 0)
+		return NULL;
+	return pte_offset_map(pmd, address);
+}
+
+static inline pte_t *pte_alloc_map_lock(struct mm_struct *mm,
+		pmd_t *pmd, unsigned long address, spinlock_t **ptlp)
+{
+	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, address) < 0)
+		return NULL;
+	return pte_offset_map_lock(mm, pmd, address, ptlp);
+}
+
+static inline pte_t *pte_alloc_kernel(pmd_t *pmd, unsigned long address)
+{
+	if (!pmd_present(*pmd) && __pte_alloc_kernel(pmd, address) < 0)
+		return NULL;
+	return pte_offset_kernel(pmd, address);
+}
 
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
@@ -839,6 +884,7 @@ extern int split_vma(struct mm_struct *,
 extern int insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
 	struct rb_node **, struct rb_node *);
+extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
 extern void exit_mmap(struct mm_struct *);
@@ -929,8 +975,7 @@ extern struct vm_area_struct *find_exten
 extern struct page * vmalloc_to_page(void *addr);
 extern unsigned long vmalloc_to_pfn(void *addr);
 extern struct page * follow_page(struct mm_struct *mm, unsigned long address,
-		int write);
-extern int check_user_page_readable(struct mm_struct *mm, unsigned long address);
+		int write, int acquire);
 int remap_pfn_range(struct vm_area_struct *, unsigned long,
 		unsigned long, unsigned long, pgprot_t);
 
--- 26136m1-/include/linux/rmap.h	2005-08-08 11:57:24.000000000 +0100
+++ 26136m1+/include/linux/rmap.h	2005-08-22 12:41:30.000000000 +0100
@@ -95,7 +95,8 @@ int try_to_unmap(struct page *);
 /*
  * Called from mm/filemap_xip.c to unmap empty zero page
  */
-pte_t *page_check_address(struct page *, struct mm_struct *, unsigned long);
+pte_t *page_check_address(struct page *, struct mm_struct *,
+				unsigned long, spinlock_t **);
 
 
 /*
--- 26136m1-/include/linux/sched.h	2005-08-20 16:44:38.000000000 +0100
+++ 26136m1+/include/linux/sched.h	2005-08-22 12:41:30.000000000 +0100
@@ -227,12 +227,42 @@ arch_get_unmapped_area_topdown(struct fi
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
 
+#ifdef CONFIG_SPLIT_PTLOCK
+/*
+ * The mm counters are not protected by its page_table_lock,
+ * so must be incremented atomically - for now, revisit it later.
+ */
+#ifdef ATOMIC64_INIT
+#define set_mm_counter(mm, member, value) atomic64_set(&(mm)->_##member, value)
+#define get_mm_counter(mm, member) ((unsigned long)atomic64_read(&(mm)->_##member))
+#define add_mm_counter(mm, member, value) atomic64_add(value, &(mm)->_##member)
+#define inc_mm_counter(mm, member) atomic64_inc(&(mm)->_##member)
+#define dec_mm_counter(mm, member) atomic64_dec(&(mm)->_##member)
+typedef atomic64_t mm_counter_t;
+#else /* !ATOMIC64_INIT */
+/*
+ * This may limit process memory to 2^31 * PAGE_SIZE which may be around 8TB
+ * if using 4KB page size
+ */
+#define set_mm_counter(mm, member, value) atomic_set(&(mm)->_##member, value)
+#define get_mm_counter(mm, member) ((unsigned long)atomic_read(&(mm)->_##member))
+#define add_mm_counter(mm, member, value) atomic_add(value, &(mm)->_##member)
+#define inc_mm_counter(mm, member) atomic_inc(&(mm)->_##member)
+#define dec_mm_counter(mm, member) atomic_dec(&(mm)->_##member)
+typedef atomic_t mm_counter_t;
+#endif /* !ATOMIC64_INIT */
+#else  /* !CONFIG_SPLIT_PTLOCK */
+/*
+ * The mm counters are protected by its page_table_lock,
+ * so can be incremented directly.
+ */
 #define set_mm_counter(mm, member, value) (mm)->_##member = (value)
 #define get_mm_counter(mm, member) ((mm)->_##member)
 #define add_mm_counter(mm, member, value) (mm)->_##member += (value)
 #define inc_mm_counter(mm, member) (mm)->_##member++
 #define dec_mm_counter(mm, member) (mm)->_##member--
 typedef unsigned long mm_counter_t;
+#endif /* !CONFIG_SPLIT_PTLOCK */
 
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
--- 26136m1-/kernel/fork.c	2005-08-19 14:30:13.000000000 +0100
+++ 26136m1+/kernel/fork.c	2005-08-22 12:41:30.000000000 +0100
@@ -190,7 +190,8 @@ static inline int dup_mmap(struct mm_str
 	struct mempolicy *pol;
 
 	down_write(&oldmm->mmap_sem);
-	flush_cache_mm(current->mm);
+	down_write(&mm->mmap_sem);
+	flush_cache_mm(oldmm);
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
@@ -205,7 +206,7 @@ static inline int dup_mmap(struct mm_str
 	rb_parent = NULL;
 	pprev = &mm->mmap;
 
-	for (mpnt = current->mm->mmap ; mpnt ; mpnt = mpnt->vm_next) {
+	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
 		struct file *file;
 
 		if (mpnt->vm_flags & VM_DONTCOPY) {
@@ -252,12 +253,8 @@ static inline int dup_mmap(struct mm_str
 		}
 
 		/*
-		 * Link in the new vma and copy the page table entries:
-		 * link in first so that swapoff can see swap entries.
-		 * Note that, exceptionally, here the vma is inserted
-		 * without holding mm->mmap_sem.
+		 * Link in the new vma and copy the page table entries.
 		 */
-		spin_lock(&mm->page_table_lock);
 		*pprev = tmp;
 		pprev = &tmp->vm_next;
 
@@ -266,8 +263,7 @@ static inline int dup_mmap(struct mm_str
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		retval = copy_page_range(mm, current->mm, tmp);
-		spin_unlock(&mm->page_table_lock);
+		retval = copy_page_range(mm, oldmm, tmp);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
@@ -278,7 +274,8 @@ static inline int dup_mmap(struct mm_str
 	retval = 0;
 
 out:
-	flush_tlb_mm(current->mm);
+	flush_tlb_mm(oldmm);
+	up_write(&mm->mmap_sem);
 	up_write(&oldmm->mmap_sem);
 	return retval;
 fail_nomem_policy:
@@ -477,7 +474,7 @@ static int copy_mm(unsigned long clone_f
 		 * allows optimizing out ipis; the tlb_gather_mmu code
 		 * is an example.
 		 */
-		spin_unlock_wait(&oldmm->page_table_lock);
+		spin_unlock_wait(&oldmm->page_table_lock); /* Hugh?? */
 		goto good_mm;
 	}
 
--- 26136m1-/kernel/futex.c	2005-06-17 20:48:29.000000000 +0100
+++ 26136m1+/kernel/futex.c	2005-08-22 12:41:30.000000000 +0100
@@ -204,15 +204,13 @@ static int get_futex_key(unsigned long u
 	/*
 	 * Do a quick atomic lookup first - this is the fastpath.
 	 */
-	spin_lock(&current->mm->page_table_lock);
-	page = follow_page(mm, uaddr, 0);
+	page = follow_page(mm, uaddr, 0, 1);
 	if (likely(page != NULL)) {
 		key->shared.pgoff =
 			page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-		spin_unlock(&current->mm->page_table_lock);
+		put_page(page);
 		return 0;
 	}
-	spin_unlock(&current->mm->page_table_lock);
 
 	/*
 	 * Do it the general way.
--- 26136m1-/mm/Kconfig	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1+/mm/Kconfig	2005-08-22 12:41:30.000000000 +0100
@@ -111,3 +111,19 @@ config SPARSEMEM_STATIC
 config SPARSEMEM_EXTREME
 	def_bool y
 	depends on SPARSEMEM && !SPARSEMEM_STATIC
+
+config SPLIT_PTLOCK
+	bool "Finer-grained page table locking"
+	depends on SMP
+	default y
+	help
+	  Heavily threaded applications might benefit from splitting
+	  the mm page_table_lock, so that faults on different parts of
+	  the user address space can be handled with less contention.
+
+	  So far, only i386, ia64 and x86_64 architectures have been
+	  converted: the other MMU architectures should fail to build.
+
+	  For testing purposes, the patch defaults this option to Y.
+	  To test for improvements which come from narrowing the scope
+	  of the page_table_lock, without splitting it, choose N.
--- 26136m1-/mm/filemap_xip.c	2005-08-08 11:57:25.000000000 +0100
+++ 26136m1+/mm/filemap_xip.c	2005-08-22 12:41:30.000000000 +0100
@@ -172,8 +172,10 @@ __xip_unmap (struct address_space * mapp
 	struct mm_struct *mm;
 	struct prio_tree_iter iter;
 	unsigned long address;
+	pmd_t *pmd;
 	pte_t *pte;
 	pte_t pteval;
+	spinlock_t *ptl;
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
@@ -181,19 +183,13 @@ __xip_unmap (struct address_space * mapp
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-		/*
-		 * We need the page_table_lock to protect us from page faults,
-		 * munmap, fork, etc...
-		 */
-		pte = page_check_address(ZERO_PAGE(address), mm,
-					 address);
-		if (!IS_ERR(pte)) {
+		pte = page_check_address(ZERO_PAGE(address), mm, address, &ptl);
+		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
 			BUG_ON(pte_dirty(pteval));
-			pte_unmap(pte);
-			spin_unlock(&mm->page_table_lock);
+			pte_unmap_unlock(pte, ptl);
 		}
 	}
 	spin_unlock(&mapping->i_mmap_lock);
--- 26136m1-/mm/fremap.c	2005-06-17 20:48:29.000000000 +0100
+++ 26136m1+/mm/fremap.c	2005-08-22 12:41:30.000000000 +0100
@@ -64,21 +64,18 @@ int install_page(struct mm_struct *mm, s
 	pud_t *pud;
 	pgd_t *pgd;
 	pte_t pte_val;
+	spinlock_t *ptl;
 
 	pgd = pgd_offset(mm, addr);
-	spin_lock(&mm->page_table_lock);
-	
 	pud = pud_alloc(mm, pgd, addr);
 	if (!pud)
-		goto err_unlock;
-
+		goto err;
 	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
-		goto err_unlock;
-
-	pte = pte_alloc_map(mm, pmd, addr);
+		goto err;
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
-		goto err_unlock;
+		goto err;
 
 	/*
 	 * This page may have been truncated. Tell the
@@ -87,27 +84,25 @@ int install_page(struct mm_struct *mm, s
 	err = -EINVAL;
 	inode = vma->vm_file->f_mapping->host;
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (!page->mapping || page->index >= size)
-		goto err_unlock;
+	if (!page->mapping || page->index >= size) {
+		pte_unmap_unlock(pte, ptl);
+		goto err;
+	}
 
 	zap_pte(mm, vma, addr, pte);
-
-	inc_mm_counter(mm,rss);
+	inc_mm_counter(mm, rss);
 	flush_icache_page(vma, page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 	page_add_file_rmap(page);
 	pte_val = *pte;
-	pte_unmap(pte);
 	update_mmu_cache(vma, addr, pte_val);
-
+	pte_unmap_unlock(pte, ptl);
 	err = 0;
-err_unlock:
-	spin_unlock(&mm->page_table_lock);
+err:
 	return err;
 }
 EXPORT_SYMBOL(install_page);
 
-
 /*
  * Install a file pte to a given virtual memory address, release any
  * previously existing mapping.
@@ -121,37 +116,29 @@ int install_file_pte(struct mm_struct *m
 	pud_t *pud;
 	pgd_t *pgd;
 	pte_t pte_val;
+	spinlock_t *ptl;
 
 	pgd = pgd_offset(mm, addr);
-	spin_lock(&mm->page_table_lock);
-	
 	pud = pud_alloc(mm, pgd, addr);
 	if (!pud)
-		goto err_unlock;
-
+		goto err;
 	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
-		goto err_unlock;
-
-	pte = pte_alloc_map(mm, pmd, addr);
+		goto err;
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
-		goto err_unlock;
+		goto err;
 
 	zap_pte(mm, vma, addr, pte);
-
 	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
 	pte_val = *pte;
-	pte_unmap(pte);
 	update_mmu_cache(vma, addr, pte_val);
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-
-err_unlock:
-	spin_unlock(&mm->page_table_lock);
+	pte_unmap_unlock(pte, ptl);
+	err = 0;
+err:
 	return err;
 }
 
-
 /***
  * sys_remap_file_pages - remap arbitrary pages of a shared backing store
  *                        file within an existing vma.
--- 26136m1-/mm/hugetlb.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1+/mm/hugetlb.c	2005-08-22 12:41:30.000000000 +0100
@@ -268,6 +268,17 @@ static pte_t make_huge_pte(struct vm_are
 	return entry;
 }
 
+static void add_huge_rss(struct mm_struct *mm, long nbytes)
+{
+	/*
+	 * Take the page_table_lock here when updating mm_counter,
+	 * though we won't need it in the case when it's an atomic.
+	 */
+	spin_lock(&mm->page_table_lock);
+	add_mm_counter(mm, rss, nbytes >> PAGE_SHIFT);
+	spin_unlock(&mm->page_table_lock);
+}
+
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			    struct vm_area_struct *vma)
 {
@@ -276,6 +287,9 @@ int copy_hugetlb_page_range(struct mm_st
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
 
+	/* Assume we alloc them all because unmap will assume we did */
+	add_huge_rss(dst, end - addr);
+
 	while (addr < end) {
 		dst_pte = huge_pte_alloc(dst, addr);
 		if (!dst_pte)
@@ -285,7 +299,6 @@ int copy_hugetlb_page_range(struct mm_st
 		entry = *src_pte;
 		ptepage = pte_page(entry);
 		get_page(ptepage);
-		add_mm_counter(dst, rss, HPAGE_SIZE / PAGE_SIZE);
 		set_huge_pte_at(dst, addr, dst_pte, entry);
 		addr += HPAGE_SIZE;
 	}
@@ -323,20 +336,10 @@ void unmap_hugepage_range(struct vm_area
 		page = pte_page(pte);
 		put_page(page);
 	}
-	add_mm_counter(mm, rss,  -((end - start) >> PAGE_SHIFT));
+	add_huge_rss(mm, start - end);
 	flush_tlb_range(vma, start, end);
 }
 
-void zap_hugepage_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long length)
-{
-	struct mm_struct *mm = vma->vm_mm;
-
-	spin_lock(&mm->page_table_lock);
-	unmap_hugepage_range(vma, start, start + length);
-	spin_unlock(&mm->page_table_lock);
-}
-
 int hugetlb_prefault(struct address_space *mapping, struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = current->mm;
@@ -349,7 +352,9 @@ int hugetlb_prefault(struct address_spac
 
 	hugetlb_prefault_arch_hook(mm);
 
-	spin_lock(&mm->page_table_lock);
+	/* Assume we alloc them all because unmap will assume we did */
+	add_huge_rss(mm, vma->vm_end - vma->vm_start);
+
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += HPAGE_SIZE) {
 		unsigned long idx;
 		pte_t *pte = huge_pte_alloc(mm, addr);
@@ -386,11 +391,9 @@ int hugetlb_prefault(struct address_spac
 				goto out;
 			}
 		}
-		add_mm_counter(mm, rss, HPAGE_SIZE / PAGE_SIZE);
 		set_huge_pte_at(mm, addr, pte, make_huge_pte(vma, page));
 	}
 out:
-	spin_unlock(&mm->page_table_lock);
 	return ret;
 }
 
--- 26136m1-/mm/memory.c	2005-08-20 16:54:41.000000000 +0100
+++ 26136m1+/mm/memory.c	2005-08-22 12:41:30.000000000 +0100
@@ -260,6 +260,12 @@ void free_pgtables(struct mmu_gather **t
 		struct vm_area_struct *next = vma->vm_next;
 		unsigned long addr = vma->vm_start;
 
+		/*
+		 * Make vma invisible to rmap before freeing pgtables.
+		 */
+		anon_vma_unlink(vma);
+		unlink_file_vma(vma);
+
 		if (is_hugepage_only_range(vma->vm_mm, addr, HPAGE_SIZE)) {
 			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
@@ -272,6 +278,8 @@ void free_pgtables(struct mmu_gather **t
 							HPAGE_SIZE)) {
 				vma = next;
 				next = vma->vm_next;
+				anon_vma_unlink(vma);
+				unlink_file_vma(vma);
 			}
 			free_pgd_range(tlb, addr, vma->vm_end,
 				floor, next? next->vm_start: ceiling);
@@ -280,65 +288,46 @@ void free_pgtables(struct mmu_gather **t
 	}
 }
 
-pte_t fastcall *pte_alloc_map(struct mm_struct *mm, pmd_t *pmd,
-				unsigned long address)
+int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 {
-	if (!pmd_present(*pmd)) {
-		struct page *new;
+	struct page *new = pte_alloc_one(mm, address);
+	if (!new)
+		return -ENOMEM;
 
-		spin_unlock(&mm->page_table_lock);
-		new = pte_alloc_one(mm, address);
-		spin_lock(&mm->page_table_lock);
-		if (!new)
-			return NULL;
-		/*
-		 * Because we dropped the lock, we should re-check the
-		 * entry, as somebody else could have populated it..
-		 */
-		if (pmd_present(*pmd)) {
-			pte_free(new);
-			goto out;
-		}
-		inc_mm_counter(mm, nr_ptes);
-		inc_page_state(nr_page_table_pages);
-		pmd_populate(mm, pmd, new);
+	spin_lock(&mm->page_table_lock);
+	if (pmd_present(*pmd)) {
+		pte_free(new);
+		goto out;
 	}
+	inc_mm_counter(mm, nr_ptes);
+	inc_page_state(nr_page_table_pages);
+	pmd_populate(mm, pmd, new);
 out:
-	return pte_offset_map(pmd, address);
+	spin_unlock(&mm->page_table_lock);
+	return 0;
 }
 
-pte_t fastcall * pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
 {
-	if (!pmd_present(*pmd)) {
-		pte_t *new;
-
-		spin_unlock(&mm->page_table_lock);
-		new = pte_alloc_one_kernel(mm, address);
-		spin_lock(&mm->page_table_lock);
-		if (!new)
-			return NULL;
+	pte_t *new = pte_alloc_one_kernel(&init_mm, address);
+	if (!new)
+		return -ENOMEM;
 
-		/*
-		 * Because we dropped the lock, we should re-check the
-		 * entry, as somebody else could have populated it..
-		 */
-		if (pmd_present(*pmd)) {
-			pte_free_kernel(new);
-			goto out;
-		}
-		pmd_populate_kernel(mm, pmd, new);
+	spin_lock(&init_mm.page_table_lock);
+	if (pmd_present(*pmd)) {
+		pte_free_kernel(new);
+		goto out;
 	}
+	pmd_populate_kernel(&init_mm, pmd, new);
 out:
-	return pte_offset_kernel(pmd, address);
+	spin_unlock(&init_mm.page_table_lock);
+	return 0;
 }
 
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
  * covered by this vma.
- *
- * dst->page_table_lock is held on entry and exit,
- * but may be dropped within p[mg]d_alloc() and pte_alloc_map().
  */
 
 static inline void
@@ -357,7 +346,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
 			/* make sure dst_mm is on swapoff's mmlist. */
 			if (unlikely(list_empty(&dst_mm->mmlist))) {
 				spin_lock(&mmlist_lock);
-				list_add(&dst_mm->mmlist, &src_mm->mmlist);
+				if (list_empty(&dst_mm->mmlist))
+					list_add(&dst_mm->mmlist, &src_mm->mmlist);
 				spin_unlock(&mmlist_lock);
 			}
 		}
@@ -409,26 +399,30 @@ static int copy_pte_range(struct mm_stru
 		unsigned long addr, unsigned long end)
 {
 	pte_t *src_pte, *dst_pte;
+	spinlock_t *src_ptl, *dst_ptl;
 	unsigned long vm_flags = vma->vm_flags;
-	int progress;
+	int progress = 0;
 
 again:
-	dst_pte = pte_alloc_map(dst_mm, dst_pmd, addr);
+	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
 		return -ENOMEM;
 	src_pte = pte_offset_map_nested(src_pmd, addr);
+	src_ptl = pte_lockptr(src_mm, src_pmd);
+	spin_lock(src_ptl);
 
-	progress = 0;
-	spin_lock(&src_mm->page_table_lock);
 	do {
 		/*
 		 * We are holding two locks at this point - either of them
 		 * could generate latencies in another task on another CPU.
 		 */
-		if (progress >= 32 && (need_resched() ||
-		    need_lockbreak(&src_mm->page_table_lock) ||
-		    need_lockbreak(&dst_mm->page_table_lock)))
-			break;
+		if (progress >= 32) {
+			progress = 0;
+			if (need_resched() ||
+			    need_lockbreak(src_ptl) ||
+			    need_lockbreak(dst_ptl))
+				break;
+		}
 		if (pte_none(*src_pte)) {
 			progress++;
 			continue;
@@ -436,11 +430,11 @@ again:
 		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vm_flags, addr);
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
-	spin_unlock(&src_mm->page_table_lock);
 
+	spin_unlock(src_ptl);
 	pte_unmap_nested(src_pte - 1);
-	pte_unmap(dst_pte - 1);
-	cond_resched_lock(&dst_mm->page_table_lock);
+	pte_unmap_unlock(dst_pte - 1, dst_ptl);
+	cond_resched();
 	if (addr != end)
 		goto again;
 	return 0;
@@ -519,8 +513,9 @@ static void zap_pte_range(struct mmu_gat
 				struct zap_details *details)
 {
 	pte_t *pte;
+	spinlock_t *ptl;
 
-	pte = pte_offset_map(pmd, addr);
+	pte = pte_offset_map_lock(tlb->mm, pmd, addr, &ptl);
 	do {
 		pte_t ptent = *pte;
 		if (pte_none(ptent))
@@ -582,7 +577,7 @@ static void zap_pte_range(struct mmu_gat
 			free_swap_and_cache(pte_to_swp_entry(ptent));
 		pte_clear_full(tlb->mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
+	pte_unmap_unlock(pte - 1, ptl);
 }
 
 static inline void zap_pmd_range(struct mmu_gather *tlb, pud_t *pud,
@@ -658,10 +653,10 @@ static void unmap_page_range(struct mmu_
  *
  * Returns the end address of the unmapping (restart addr if interrupted).
  *
- * Unmap all pages in the vma list.  Called under page_table_lock.
+ * Unmap all pages in the vma list.
  *
- * We aim to not hold page_table_lock for too long (for scheduling latency
- * reasons).  So zap pages in ZAP_BLOCK_SIZE bytecounts.  This means we need to
+ * We aim to not hold locks for too long (for scheduling latency reasons).
+ * So zap pages in ZAP_BLOCK_SIZE bytecounts.  This means we need to
  * return the ending mmu_gather to the caller.
  *
  * Only addresses between `start' and `end' will be unmapped.
@@ -723,16 +718,15 @@ unsigned long unmap_vmas(struct mmu_gath
 			tlb_finish_mmu(*tlbp, tlb_start, start);
 
 			if (need_resched() ||
-				need_lockbreak(&mm->page_table_lock) ||
 				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
 				if (i_mmap_lock) {
 					/* must reset count of rss freed */
 					*tlbp = tlb_gather_mmu(mm, fullmm);
 					goto out;
 				}
-				spin_unlock(&mm->page_table_lock);
+				preempt_enable();
 				cond_resched();
-				spin_lock(&mm->page_table_lock);
+				preempt_disable();
 			}
 
 			*tlbp = tlb_gather_mmu(mm, fullmm);
@@ -759,37 +753,36 @@ unsigned long zap_page_range(struct vm_a
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
 
-	if (is_vm_hugetlb_page(vma)) {
-		zap_hugepage_range(vma, address, size);
-		return end;
-	}
-
 	lru_add_drain();
-	spin_lock(&mm->page_table_lock);
+	preempt_disable();
 	tlb = tlb_gather_mmu(mm, 0);
 	end = unmap_vmas(&tlb, mm, vma, address, end, &nr_accounted, details);
 	tlb_finish_mmu(tlb, address, end);
-	spin_unlock(&mm->page_table_lock);
+	preempt_enable();
 	return end;
 }
 
 /*
  * Do a quick page-table lookup for a single page.
- * mm->page_table_lock must be held.
  */
-static struct page *__follow_page(struct mm_struct *mm, unsigned long address,
-			int read, int write, int accessed)
+struct page *follow_page(struct mm_struct *mm, unsigned long address,
+			int write, int acquire)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *ptep, pte;
+	spinlock_t *ptl;
 	unsigned long pfn;
 	struct page *page;
 
 	page = follow_huge_addr(mm, address, write);
-	if (! IS_ERR(page))
-		return page;
+	if (!IS_ERR(page)) {
+		if (acquire && !PageReserved(page))
+			page_cache_get(page);
+		goto out;
+	}
+	page = NULL;
 
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
@@ -802,51 +795,37 @@ static struct page *__follow_page(struct
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
-	if (pmd_huge(*pmd))
-		return follow_huge_pmd(mm, address, pmd, write);
 
-	ptep = pte_offset_map(pmd, address);
+	if (pmd_huge(*pmd)) {
+		page = follow_huge_pmd(mm, address, pmd, write);
+		if (page && acquire && !PageReserved(page))
+			page_cache_get(page);
+		goto out;
+	}
+
+	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (!ptep)
 		goto out;
 
 	pte = *ptep;
-	pte_unmap(ptep);
 	if (pte_present(pte)) {
 		if (write && !pte_write(pte))
-			goto out;
-		if (read && !pte_read(pte))
-			goto out;
+			goto unlock;
 		pfn = pte_pfn(pte);
 		if (pfn_valid(pfn)) {
 			page = pfn_to_page(pfn);
-			if (accessed) {
-				if (write && !pte_dirty(pte) &&!PageDirty(page))
-					set_page_dirty(page);
-				mark_page_accessed(page);
-			}
-			return page;
+			if (write && !pte_dirty(pte) &&!PageDirty(page))
+				set_page_dirty(page);
+			if (acquire && !PageReserved(page))
+				page_cache_get(page);
+			mark_page_accessed(page);
 		}
 	}
-
+unlock:
+	pte_unmap_unlock(ptep, ptl);
 out:
-	return NULL;
-}
-
-inline struct page *
-follow_page(struct mm_struct *mm, unsigned long address, int write)
-{
-	return __follow_page(mm, address, 0, write, 1);
-}
-
-/*
- * check_user_page_readable() can be called frm niterrupt context by oprofile,
- * so we need to avoid taking any non-irq-safe locks
- */
-int check_user_page_readable(struct mm_struct *mm, unsigned long address)
-{
-	return __follow_page(mm, address, 1, 0, 0) != NULL;
+	return page;
 }
-EXPORT_SYMBOL(check_user_page_readable);
 
 static inline int
 untouched_anonymous_page(struct mm_struct* mm, struct vm_area_struct *vma,
@@ -943,13 +922,12 @@ int get_user_pages(struct task_struct *t
 						&start, &len, i);
 			continue;
 		}
-		spin_lock(&mm->page_table_lock);
 		do {
 			int write_access = write;
 			struct page *page;
 
-			cond_resched_lock(&mm->page_table_lock);
-			while (!(page = follow_page(mm, start, write_access))) {
+			cond_resched();
+			while (!(page = follow_page(mm, start, write_access, !!pages))) {
 				int ret;
 
 				/*
@@ -963,7 +941,6 @@ int get_user_pages(struct task_struct *t
 					page = ZERO_PAGE(start);
 					break;
 				}
-				spin_unlock(&mm->page_table_lock);
 				ret = __handle_mm_fault(mm, vma, start, write_access);
 
 				/*
@@ -989,13 +966,10 @@ int get_user_pages(struct task_struct *t
 				default:
 					BUG();
 				}
-				spin_lock(&mm->page_table_lock);
 			}
 			if (pages) {
 				pages[i] = page;
 				flush_dcache_page(page);
-				if (!PageReserved(page))
-					page_cache_get(page);
 			}
 			if (vmas)
 				vmas[i] = vma;
@@ -1003,7 +977,6 @@ int get_user_pages(struct task_struct *t
 			start += PAGE_SIZE;
 			len--;
 		} while (len && start < vma->vm_end);
-		spin_unlock(&mm->page_table_lock);
 	} while (len);
 	return i;
 }
@@ -1013,8 +986,9 @@ static int zeromap_pte_range(struct mm_s
 			unsigned long addr, unsigned long end, pgprot_t prot)
 {
 	pte_t *pte;
+	spinlock_t *ptl;
 
-	pte = pte_alloc_map(mm, pmd, addr);
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
 	do {
@@ -1022,7 +996,7 @@ static int zeromap_pte_range(struct mm_s
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, addr, pte, zero_pte);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
+	pte_unmap_unlock(pte - 1, ptl);
 	return 0;
 }
 
@@ -1072,14 +1046,12 @@ int zeromap_page_range(struct vm_area_st
 	BUG_ON(addr >= end);
 	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
-	spin_lock(&mm->page_table_lock);
 	do {
 		next = pgd_addr_end(addr, end);
 		err = zeromap_pud_range(mm, pgd, addr, next, prot);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	spin_unlock(&mm->page_table_lock);
 	return err;
 }
 
@@ -1093,8 +1065,9 @@ static int remap_pte_range(struct mm_str
 			unsigned long pfn, pgprot_t prot)
 {
 	pte_t *pte;
+	spinlock_t *ptl;
 
-	pte = pte_alloc_map(mm, pmd, addr);
+	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
 	do {
@@ -1103,7 +1076,7 @@ static int remap_pte_range(struct mm_str
 			set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
+	pte_unmap_unlock(pte - 1, ptl);
 	return 0;
 }
 
@@ -1171,7 +1144,6 @@ int remap_pfn_range(struct vm_area_struc
 	pfn -= addr >> PAGE_SHIFT;
 	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
-	spin_lock(&mm->page_table_lock);
 	do {
 		next = pgd_addr_end(addr, end);
 		err = remap_pud_range(mm, pgd, addr, next,
@@ -1179,7 +1151,6 @@ int remap_pfn_range(struct vm_area_struc
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	spin_unlock(&mm->page_table_lock);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1198,15 +1169,15 @@ static inline pte_t maybe_mkwrite(pte_t 
 }
 
 /*
- * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
+ * We hold the mm semaphore for reading and the pte_lock.
  */
-static inline void break_cow(struct vm_area_struct * vma, struct page * new_page, unsigned long address, 
-		pte_t *page_table)
+static inline void break_cow(struct vm_area_struct *vma,
+	struct page *new_page, unsigned long address, pte_t *page_table)
 {
 	pte_t entry;
 
-	entry = maybe_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot)),
-			      vma);
+	entry = mk_pte(new_page, vma->vm_page_prot);
+	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	ptep_establish(vma, address, page_table, entry);
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
@@ -1217,9 +1188,6 @@ static inline void break_cow(struct vm_a
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
  *
- * Goto-purists beware: the only reason for goto's here is that it results
- * in better assembly code.. The "default" path will see no jumps at all.
- *
  * Note that this routine assumes that the protection checks have been
  * done by the caller (the low-level page fault routine in most cases).
  * Thus we can safely just mark it writable once we've done any necessary
@@ -1229,16 +1197,18 @@ static inline void break_cow(struct vm_a
  * change only once the write actually happens. This avoids a few races,
  * and potentially makes it more efficient.
  *
- * We hold the mm semaphore and the page_table_lock on entry and exit
- * with the page_table_lock released.
- */
-static int do_wp_page(struct mm_struct *mm, struct vm_area_struct * vma,
-	unsigned long address, pte_t *page_table, pmd_t *pmd, pte_t pte)
+ * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * but allow concurrent faults), with pte both mapped and locked.
+ * We return with mmap_sem still held, but pte unmapped and unlocked.
+ */
+static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		spinlock_t *ptl, pte_t orig_pte)
 {
 	struct page *old_page, *new_page;
-	unsigned long pfn = pte_pfn(pte);
+	unsigned long pfn = pte_pfn(orig_pte);
 	pte_t entry;
-	int ret;
+	int ret = VM_FAULT_MINOR;
 
 	if (unlikely(!pfn_valid(pfn))) {
 		/*
@@ -1246,11 +1216,10 @@ static int do_wp_page(struct mm_struct *
 		 * at least the kernel stops what it's doing before it corrupts
 		 * data, but for the moment just pretend this is OOM.
 		 */
-		pte_unmap(page_table);
 		printk(KERN_ERR "do_wp_page: bogus page at address %08lx\n",
 				address);
-		spin_unlock(&mm->page_table_lock);
-		return VM_FAULT_OOM;
+		ret = VM_FAULT_OOM;
+		goto unlock;
 	}
 	old_page = pfn_to_page(pfn);
 
@@ -1259,24 +1228,22 @@ static int do_wp_page(struct mm_struct *
 		unlock_page(old_page);
 		if (reuse) {
 			flush_cache_page(vma, address, pfn);
-			entry = maybe_mkwrite(pte_mkyoung(pte_mkdirty(pte)),
-					      vma);
+			entry = pte_mkyoung(pte_mkdirty(orig_pte));
+			entry = maybe_mkwrite(entry, vma);
 			ptep_set_access_flags(vma, address, page_table, entry, 1);
 			update_mmu_cache(vma, address, entry);
 			lazy_mmu_prot_update(entry);
-			pte_unmap(page_table);
-			spin_unlock(&mm->page_table_lock);
-			return VM_FAULT_MINOR|VM_FAULT_WRITE;
+			ret |= VM_FAULT_WRITE;
+			goto unlock;
 		}
 	}
-	pte_unmap(page_table);
 
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
 	if (!PageReserved(old_page))
 		page_cache_get(old_page);
-	spin_unlock(&mm->page_table_lock);
+	pte_unmap_unlock(page_table, ptl);
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto no_new_page;
@@ -1290,13 +1257,12 @@ static int do_wp_page(struct mm_struct *
 			goto no_new_page;
 		copy_user_highpage(new_page, old_page, address);
 	}
+
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	ret = VM_FAULT_MINOR;
-	spin_lock(&mm->page_table_lock);
-	page_table = pte_offset_map(pmd, address);
-	if (likely(pte_same(*page_table, pte))) {
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (likely(pte_same(*page_table, orig_pte))) {
 		if (PageAnon(old_page))
 			dec_mm_counter(mm, anon_rss);
 		if (PageReserved(old_page))
@@ -1312,10 +1278,10 @@ static int do_wp_page(struct mm_struct *
 		new_page = old_page;
 		ret |= VM_FAULT_WRITE;
 	}
-	pte_unmap(page_table);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
-	spin_unlock(&mm->page_table_lock);
+unlock:
+	pte_unmap_unlock(page_table, ptl);
 	return ret;
 
 no_new_page:
@@ -1388,13 +1354,6 @@ again:
 
 	restart_addr = zap_page_range(vma, start_addr,
 					end_addr - start_addr, details);
-
-	/*
-	 * We cannot rely on the break test in unmap_vmas:
-	 * on the one hand, we don't want to restart our loop
-	 * just because that broke out for the page_table_lock;
-	 * on the other hand, it does no test when vma is small.
-	 */
 	need_break = need_resched() ||
 			need_lockbreak(details->i_mmap_lock);
 
@@ -1643,38 +1602,43 @@ void swapin_readahead(swp_entry_t entry,
 }
 
 /*
- * We hold the mm semaphore and the page_table_lock on entry and
- * should release the pagetable lock on exit..
- */
-static int do_swap_page(struct mm_struct * mm,
-	struct vm_area_struct * vma, unsigned long address,
-	pte_t *page_table, pmd_t *pmd, pte_t orig_pte, int write_access)
+ * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * but allow concurrent faults), and pte mapped but not yet locked.
+ * We return with mmap_sem still held, but pte unmapped and unlocked.
+ */
+static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		int write_access, pte_t orig_pte)
 {
+	spinlock_t *ptl;
 	struct page *page;
-	swp_entry_t entry = pte_to_swp_entry(orig_pte);
+	swp_entry_t entry;
 	pte_t pte;
 	int ret = VM_FAULT_MINOR;
 
+	if (sizeof(pte_t) > sizeof(unsigned long)) {
+		ptl = pte_lockptr(mm, pmd);
+		spin_lock(ptl);
+		if (unlikely(!pte_same(*page_table, orig_pte)))
+			goto unlock;
+		spin_unlock(ptl);
+	}
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+
+	entry = pte_to_swp_entry(orig_pte);
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
  		page = read_swap_cache_async(entry, vma, address);
 		if (!page) {
 			/*
-			 * Back out if somebody else faulted in this pte while
-			 * we released the page table lock.
+			 * Back out if somebody else faulted in this pte
+			 * while we released the pte_lock.
 			 */
-			spin_lock(&mm->page_table_lock);
-			page_table = pte_offset_map(pmd, address);
+			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 			if (likely(pte_same(*page_table, orig_pte)))
 				ret = VM_FAULT_OOM;
-			else
-				ret = VM_FAULT_MINOR;
-			pte_unmap(page_table);
-			spin_unlock(&mm->page_table_lock);
-			goto out;
+			goto unlock;
 		}
 
 		/* Had to read the page from swap area: Major fault */
@@ -1688,14 +1652,11 @@ static int do_swap_page(struct mm_struct
 
 	/*
 	 * Back out if somebody else faulted in this pte while we
-	 * released the page table lock.
+	 * released the pte_lock.
 	 */
-	spin_lock(&mm->page_table_lock);
-	page_table = pte_offset_map(pmd, address);
-	if (unlikely(!pte_same(*page_table, orig_pte))) {
-		ret = VM_FAULT_MINOR;
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (unlikely(!pte_same(*page_table, orig_pte)))
 		goto out_nomap;
-	}
 
 	if (unlikely(!PageUptodate(page))) {
 		ret = VM_FAULT_SIGBUS;
@@ -1722,7 +1683,7 @@ static int do_swap_page(struct mm_struct
 
 	if (write_access) {
 		if (do_wp_page(mm, vma, address,
-				page_table, pmd, pte) == VM_FAULT_OOM)
+				page_table, pmd, ptl, pte) == VM_FAULT_OOM)
 			ret = VM_FAULT_OOM;
 		goto out;
 	}
@@ -1730,72 +1691,70 @@ static int do_swap_page(struct mm_struct
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
 	lazy_mmu_prot_update(pte);
-	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+unlock:
+	pte_unmap_unlock(page_table, ptl);
 out:
 	return ret;
+
 out_nomap:
-	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
+	pte_unmap_unlock(page_table, ptl);
 	unlock_page(page);
 	page_cache_release(page);
-	goto out;
+	return ret;
 }
 
 /*
- * We are called with the MM semaphore and page_table_lock
- * spinlock held to protect against concurrent faults in
- * multithreaded programs. 
- */
-static int
-do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		pte_t *page_table, pmd_t *pmd, int write_access,
-		unsigned long addr)
+ * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * but allow concurrent faults), and pte mapped but not yet locked.
+ * We return with mmap_sem still held, but pte unmapped and unlocked.
+ */
+static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		int write_access)
 {
+	spinlock_t *ptl;
 	pte_t entry;
-	struct page * page = ZERO_PAGE(addr);
-
-	/* Read-only mapping of ZERO_PAGE. */
-	entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
 
-	/* ..except if it's a write access */
 	if (write_access) {
+		struct page *page;
+
 		/* Allocate our own private page. */
 		pte_unmap(page_table);
-		spin_unlock(&mm->page_table_lock);
 
 		if (unlikely(anon_vma_prepare(vma)))
 			goto no_mem;
-		page = alloc_zeroed_user_highpage(vma, addr);
+		page = alloc_zeroed_user_highpage(vma, address);
 		if (!page)
 			goto no_mem;
 
-		spin_lock(&mm->page_table_lock);
-		page_table = pte_offset_map(pmd, addr);
-
+		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table)) {
-			pte_unmap(page_table);
 			page_cache_release(page);
-			spin_unlock(&mm->page_table_lock);
 			goto out;
 		}
 		inc_mm_counter(mm, rss);
-		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
-							 vma->vm_page_prot)),
-				      vma);
+		entry = mk_pte(page, vma->vm_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		lru_cache_add_active(page);
 		SetPageReferenced(page);
-		page_add_anon_rmap(page, vma, addr);
+		page_add_anon_rmap(page, vma, address);
+	} else {
+		/* Read-only mapping of ZERO_PAGE. */
+		entry = mk_pte(ZERO_PAGE(addr), vma->vm_page_prot);
+		entry = pte_wrprotect(entry);
+		ptl = pte_lockptr(mm, pmd);
+		spin_lock(ptl);
+		if (!pte_none(*page_table))
+			goto out;
 	}
 
-	set_pte_at(mm, addr, page_table, entry);
-	pte_unmap(page_table);
+	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, addr, entry);
+	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
-	spin_unlock(&mm->page_table_lock);
 out:
+	pte_unmap_unlock(page_table, ptl);
 	return VM_FAULT_MINOR;
 no_mem:
 	return VM_FAULT_OOM;
@@ -1810,25 +1769,23 @@ no_mem:
  * As this is called only for pages that do not currently exist, we
  * do not need to flush old virtual caches or the TLB.
  *
- * This is called with the MM semaphore held and the page table
- * spinlock held. Exit with the spinlock released.
- */
-static int
-do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-	unsigned long address, int write_access, pte_t *page_table, pmd_t *pmd)
+ * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * but allow concurrent faults), and pte mapped but not yet locked.
+ * We return with mmap_sem still held, but pte unmapped and unlocked.
+ */
+static int do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		int write_access)
 {
-	struct page * new_page;
+	spinlock_t *ptl;
+	struct page *new_page;
 	struct address_space *mapping = NULL;
 	pte_t entry;
 	unsigned int sequence = 0;
 	int ret = VM_FAULT_MINOR;
 	int anon = 0;
 
-	if (!vma->vm_ops || !vma->vm_ops->nopage)
-		return do_anonymous_page(mm, vma, page_table,
-					pmd, write_access, address);
 	pte_unmap(page_table);
-	spin_unlock(&mm->page_table_lock);
 
 	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
@@ -1836,7 +1793,6 @@ do_no_page(struct mm_struct *mm, struct 
 		smp_rmb(); /* serializes i_size against truncate_count */
 	}
 retry:
-	cond_resched();
 	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
 	/*
 	 * No smp_rmb is needed here as long as there's a full
@@ -1869,19 +1825,20 @@ retry:
 		anon = 1;
 	}
 
-	spin_lock(&mm->page_table_lock);
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	/*
 	 * For a file-backed vma, someone could have truncated or otherwise
 	 * invalidated this page.  If unmap_mapping_range got called,
 	 * retry getting the page.
 	 */
 	if (mapping && unlikely(sequence != mapping->truncate_count)) {
-		sequence = mapping->truncate_count;
-		spin_unlock(&mm->page_table_lock);
+		pte_unmap_unlock(page_table, ptl);
 		page_cache_release(new_page);
+		cond_resched();
+		sequence = mapping->truncate_count;
+		smp_rmb();
 		goto retry;
 	}
-	page_table = pte_offset_map(pmd, address);
 
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
@@ -1908,55 +1865,55 @@ retry:
 			page_add_anon_rmap(new_page, vma, address);
 		} else
 			page_add_file_rmap(new_page);
-		pte_unmap(page_table);
 	} else {
 		/* One of our sibling threads was faster, back out. */
-		pte_unmap(page_table);
 		page_cache_release(new_page);
-		spin_unlock(&mm->page_table_lock);
 		goto out;
 	}
 
 	/* no need to invalidate: a not-present page shouldn't be cached */
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
-	spin_unlock(&mm->page_table_lock);
 out:
+	pte_unmap_unlock(page_table, ptl);
 	return ret;
 oom:
 	page_cache_release(new_page);
-	ret = VM_FAULT_OOM;
-	goto out;
+	return VM_FAULT_OOM;
 }
 
 /*
  * Fault of a previously existing named mapping. Repopulate the pte
  * from the encoded file_pte if possible. This enables swappable
  * nonlinear vmas.
- */
-static int do_file_page(struct mm_struct * mm, struct vm_area_struct * vma,
-	unsigned long address, int write_access, pte_t *pte, pmd_t *pmd)
+ *
+ * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * but allow concurrent faults), and pte mapped but not yet locked.
+ * We return with mmap_sem still held, but pte unmapped and unlocked.
+ */
+static int do_file_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		int write_access, pte_t orig_pte)
 {
-	unsigned long pgoff;
+	pgoff_t pgoff;
 	int err;
 
-	BUG_ON(!vma->vm_ops || !vma->vm_ops->nopage);
-	/*
-	 * Fall back to the linear mapping if the fs does not support
-	 * ->populate:
-	 */
-	if (!vma->vm_ops->populate ||
-			(write_access && !(vma->vm_flags & VM_SHARED))) {
-		pte_clear(mm, address, pte);
-		return do_no_page(mm, vma, address, write_access, pte, pmd);
-	}
-
-	pgoff = pte_to_pgoff(*pte);
+	if (sizeof(pte_t) > sizeof(unsigned long)) {
+		spinlock_t *ptl = pte_lockptr(mm, pmd);
+		spin_lock(ptl);
+		err = !pte_same(*page_table, orig_pte);
+		pte_unmap_unlock(page_table, ptl);
+		if (err)
+			return VM_FAULT_MINOR;
+	} else
+		pte_unmap(page_table);
 
-	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+	BUG_ON(!vma->vm_ops || !vma->vm_ops->populate);
+	BUG_ON(!(vma->vm_flags & VM_SHARED));
 
-	err = vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE, vma->vm_page_prot, pgoff, 0);
+	pgoff = pte_to_pgoff(orig_pte);
+	err = vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE,
+					vma->vm_page_prot, pgoff, 0);
 	if (err == -ENOMEM)
 		return VM_FAULT_OOM;
 	if (err)
@@ -1973,56 +1930,56 @@ static int do_file_page(struct mm_struct
  * with external mmu caches can use to update those (ie the Sparc or
  * PowerPC hashed page tables that act as extended TLBs).
  *
- * Note the "page_table_lock". It is to protect against kswapd removing
- * pages from under us. Note that kswapd only ever _removes_ pages, never
- * adds them. As such, once we have noticed that the page is not present,
- * we can drop the lock early.
- *
- * The adding of pages is protected by the MM semaphore (which we hold),
- * so we don't need to worry about a page being suddenly been added into
- * our VM.
- *
- * We enter with the pagetable spinlock held, we are supposed to
- * release it when done.
+ * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * but allow concurrent faults), and pte mapped but not yet locked.
+ * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
-	struct vm_area_struct * vma, unsigned long address,
-	int write_access, pte_t *pte, pmd_t *pmd)
+		struct vm_area_struct *vma, unsigned long address,
+		pte_t *pte, pmd_t *pmd, int write_access)
 {
 	pte_t entry;
+	spinlock_t *ptl;
 
 	entry = *pte;
 	if (!pte_present(entry)) {
-		/*
-		 * If it truly wasn't present, we know that kswapd
-		 * and the PTE updates will not touch it later. So
-		 * drop the lock.
-		 */
-		if (pte_none(entry))
-			return do_no_page(mm, vma, address, write_access, pte, pmd);
+		if (pte_none(entry)) {
+			if (!vma->vm_ops || !vma->vm_ops->nopage)
+				return do_anonymous_page(mm, vma, address,
+					pte, pmd, write_access);
+			return do_no_page(mm, vma, address,
+					pte, pmd, write_access);
+		}
 		if (pte_file(entry))
-			return do_file_page(mm, vma, address, write_access, pte, pmd);
-		return do_swap_page(mm, vma, address, pte, pmd, entry, write_access);
+			return do_file_page(mm, vma, address,
+					pte, pmd, write_access, entry);
+		return do_swap_page(mm, vma, address,
+					pte, pmd, write_access, entry);
 	}
 
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+	if (unlikely(!pte_same(*pte, entry)))
+		goto out;
 	if (write_access) {
 		if (!pte_write(entry))
-			return do_wp_page(mm, vma, address, pte, pmd, entry);
+			return do_wp_page(mm, vma, address,
+					pte, pmd, ptl, entry);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
 	ptep_set_access_flags(vma, address, pte, entry, write_access);
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
-	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+out:
+	pte_unmap_unlock(pte, ptl);
 	return VM_FAULT_MINOR;
 }
 
 /*
  * By the time we get here, we already hold the mm semaphore
  */
-int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct * vma,
+int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, int write_access)
 {
 	pgd_t *pgd;
@@ -2036,30 +1993,19 @@ int __handle_mm_fault(struct mm_struct *
 
 	if (is_vm_hugetlb_page(vma))
 		return VM_FAULT_SIGBUS;	/* mapping truncation does this. */
-
-	/*
-	 * We need the page table lock to synchronize with kswapd
-	 * and the SMP-safe atomic PTE updates.
-	 */
 	pgd = pgd_offset(mm, address);
-	spin_lock(&mm->page_table_lock);
-
 	pud = pud_alloc(mm, pgd, address);
 	if (!pud)
 		goto oom;
-
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		goto oom;
-
 	pte = pte_alloc_map(mm, pmd, address);
 	if (!pte)
 		goto oom;
-	
-	return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
 
- oom:
-	spin_unlock(&mm->page_table_lock);
+	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+oom:
 	return VM_FAULT_OOM;
 }
 
@@ -2067,29 +2013,22 @@ int __handle_mm_fault(struct mm_struct *
 /*
  * Allocate page upper directory.
  *
- * We've already handled the fast-path in-line, and we own the
- * page table lock.
+ * We've already handled the fast-path in-line.
  */
-pud_t fastcall *__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+pud_t *__pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
-	pud_t *new;
-
-	spin_unlock(&mm->page_table_lock);
-	new = pud_alloc_one(mm, address);
-	spin_lock(&mm->page_table_lock);
+	pud_t *new = pud_alloc_one(mm, address);
 	if (!new)
 		return NULL;
 
-	/*
-	 * Because we dropped the lock, we should re-check the
-	 * entry, as somebody else could have populated it..
-	 */
+	spin_lock(&mm->page_table_lock);
 	if (pgd_present(*pgd)) {
 		pud_free(new);
 		goto out;
 	}
 	pgd_populate(mm, pgd, new);
- out:
+out:
+	spin_unlock(&mm->page_table_lock);
 	return pud_offset(pgd, address);
 }
 #endif /* __PAGETABLE_PUD_FOLDED */
@@ -2098,23 +2037,15 @@ pud_t fastcall *__pud_alloc(struct mm_st
 /*
  * Allocate page middle directory.
  *
- * We've already handled the fast-path in-line, and we own the
- * page table lock.
+ * We've already handled the fast-path in-line.
  */
-pmd_t fastcall *__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+pmd_t *__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 {
-	pmd_t *new;
-
-	spin_unlock(&mm->page_table_lock);
-	new = pmd_alloc_one(mm, address);
-	spin_lock(&mm->page_table_lock);
+	pmd_t *new = pmd_alloc_one(mm, address);
 	if (!new)
 		return NULL;
 
-	/*
-	 * Because we dropped the lock, we should re-check the
-	 * entry, as somebody else could have populated it..
-	 */
+	spin_lock(&mm->page_table_lock);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud)) {
 		pmd_free(new);
@@ -2129,7 +2060,8 @@ pmd_t fastcall *__pmd_alloc(struct mm_st
 	pgd_populate(mm, pud, new);
 #endif /* __ARCH_HAS_4LEVEL_HACK */
 
- out:
+out:
+	spin_unlock(&mm->page_table_lock);
 	return pmd_offset(pud, address);
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
--- 26136m1-/mm/mempolicy.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1+/mm/mempolicy.c	2005-08-22 12:41:30.000000000 +0100
@@ -243,9 +243,9 @@ static int check_pte_range(struct mm_str
 {
 	pte_t *orig_pte;
 	pte_t *pte;
+	spinlock_t *ptl;
 
-	spin_lock(&mm->page_table_lock);
-	orig_pte = pte = pte_offset_map(pmd, addr);
+	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	do {
 		unsigned long pfn;
 		unsigned int nid;
@@ -259,8 +259,7 @@ static int check_pte_range(struct mm_str
 		if (!test_bit(nid, nodes))
 			break;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(orig_pte);
-	spin_unlock(&mm->page_table_lock);
+	pte_unmap_unlock(orig_pte, ptl);
 	return addr != end;
 }
 
--- 26136m1-/mm/mmap.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1+/mm/mmap.c	2005-08-22 12:41:30.000000000 +0100
@@ -177,26 +177,36 @@ static void __remove_shared_vm_struct(st
 }
 
 /*
- * Remove one vm structure and free it.
+ * Unlink a file-based vm structure from its prio_tree
+ * to hide it from rmap before freeing its page tables.
  */
-static void remove_vm_struct(struct vm_area_struct *vma)
+void unlink_file_vma(struct vm_area_struct *vma)
 {
 	struct file *file = vma->vm_file;
 
-	might_sleep();
 	if (file) {
 		struct address_space *mapping = file->f_mapping;
 		spin_lock(&mapping->i_mmap_lock);
 		__remove_shared_vm_struct(vma, file, mapping);
 		spin_unlock(&mapping->i_mmap_lock);
 	}
+}
+
+/*
+ * Close a vm structure and free it, returning the next.
+ */
+static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
+{
+	struct vm_area_struct *next = vma->vm_next;
+
+	might_sleep();
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
-	if (file)
-		fput(file);
-	anon_vma_unlink(vma);
+	if (vma->vm_file)
+		fput(vma->vm_file);
 	mpol_free(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
+	return next;
 }
 
 asmlinkage unsigned long sys_brk(unsigned long brk)
@@ -1599,44 +1609,26 @@ find_extend_vma(struct mm_struct * mm, u
 }
 #endif
 
-/* Normal function to fix up a mapping
- * This function is the default for when an area has no specific
- * function.  This may be used as part of a more specific routine.
- *
- * By the time this function is called, the area struct has been
- * removed from the process mapping list.
- */
-static void unmap_vma(struct mm_struct *mm, struct vm_area_struct *area)
-{
-	size_t len = area->vm_end - area->vm_start;
-
-	area->vm_mm->total_vm -= len >> PAGE_SHIFT;
-	if (area->vm_flags & VM_LOCKED)
-		area->vm_mm->locked_vm -= len >> PAGE_SHIFT;
-	vm_stat_unaccount(area);
-	remove_vm_struct(area);
-}
-
 /*
- * Update the VMA and inode share lists.
- *
- * Ok - we have the memory areas we should free on the 'free' list,
+ * Ok - we have the memory areas we should free on the vma list,
  * so release them, and do the vma updates.
  */
-static void unmap_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
+static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
 {
+
 	do {
-		struct vm_area_struct *next = vma->vm_next;
-		unmap_vma(mm, vma);
-		vma = next;
+		long pages = vma_pages(vma);
+		mm->total_vm -= pages;
+		if (vma->vm_flags & VM_LOCKED)
+			mm->locked_vm -= pages;
+		__vm_stat_account(mm, vma->vm_flags, vma->vm_file, -pages);
+		vma = remove_vma(vma);
 	} while (vma);
 	validate_mm(mm);
 }
 
 /*
  * Get rid of page table information in the indicated region.
- *
- * Called with the page table lock held.
  */
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
@@ -1647,14 +1639,14 @@ static void unmap_region(struct mm_struc
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
-	spin_lock(&mm->page_table_lock);
+	preempt_disable();
 	tlb = tlb_gather_mmu(mm, 0);
 	unmap_vmas(&tlb, mm, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
-	spin_unlock(&mm->page_table_lock);
+	preempt_enable();
 }
 
 /*
@@ -1795,7 +1787,7 @@ int do_munmap(struct mm_struct *mm, unsi
 	unmap_region(mm, vma, prev, start, end);
 
 	/* Fix up all other VM information */
-	unmap_vma_list(mm, vma);
+	remove_vma_list(mm, vma);
 
 	return 0;
 }
@@ -1929,9 +1921,7 @@ void exit_mmap(struct mm_struct *mm)
 	unsigned long end;
 
 	lru_add_drain();
-
-	spin_lock(&mm->page_table_lock);
-
+	preempt_disable();
 	flush_cache_mm(mm);
 	tlb = tlb_gather_mmu(mm, 1);
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
@@ -1939,24 +1929,13 @@ void exit_mmap(struct mm_struct *mm)
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
-
-	mm->mmap = mm->mmap_cache = NULL;
-	mm->mm_rb = RB_ROOT;
-	set_mm_counter(mm, rss, 0);
-	mm->total_vm = 0;
-	mm->locked_vm = 0;
-
-	spin_unlock(&mm->page_table_lock);
+	preempt_enable();
 
 	/*
 	 * Walk the list again, actually closing and freeing it
-	 * without holding any MM locks.
 	 */
-	while (vma) {
-		struct vm_area_struct *next = vma->vm_next;
-		remove_vm_struct(vma);
-		vma = next;
-	}
+	while (vma)
+		vma = remove_vma(vma);
 
 	BUG_ON(get_mm_counter(mm, nr_ptes) > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
 }
--- 26136m1-/mm/mprotect.c	2005-08-20 16:44:38.000000000 +0100
+++ 26136m1+/mm/mprotect.c	2005-08-22 12:41:30.000000000 +0100
@@ -29,8 +29,9 @@ static void change_pte_range(struct mm_s
 		unsigned long addr, unsigned long end, pgprot_t newprot)
 {
 	pte_t *pte;
+	spinlock_t *ptl;
 
-	pte = pte_offset_map(pmd, addr);
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	do {
 		if (pte_present(*pte)) {
 			pte_t ptent;
@@ -44,7 +45,7 @@ static void change_pte_range(struct mm_s
 			lazy_mmu_prot_update(ptent);
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
+	pte_unmap_unlock(pte - 1, ptl);
 }
 
 static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
@@ -88,7 +89,6 @@ static void change_protection(struct vm_
 	BUG_ON(addr >= end);
 	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
-	spin_lock(&mm->page_table_lock);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
@@ -96,7 +96,6 @@ static void change_protection(struct vm_
 		change_pud_range(mm, pgd, addr, next, newprot);
 	} while (pgd++, addr = next, addr != end);
 	flush_tlb_range(vma, start, end);
-	spin_unlock(&mm->page_table_lock);
 }
 
 static int
--- 26136m1-/mm/mremap.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1+/mm/mremap.c	2005-08-22 12:41:30.000000000 +0100
@@ -22,35 +22,7 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static pte_t *get_one_pte_map_nested(struct mm_struct *mm, unsigned long addr)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte = NULL;
-
-	pgd = pgd_offset(mm, addr);
-	if (pgd_none_or_clear_bad(pgd))
-		goto end;
-
-	pud = pud_offset(pgd, addr);
-	if (pud_none_or_clear_bad(pud))
-		goto end;
-
-	pmd = pmd_offset(pud, addr);
-	if (pmd_none_or_clear_bad(pmd))
-		goto end;
-
-	pte = pte_offset_map_nested(pmd, addr);
-	if (pte_none(*pte)) {
-		pte_unmap_nested(pte);
-		pte = NULL;
-	}
-end:
-	return pte;
-}
-
-static pte_t *get_one_pte_map(struct mm_struct *mm, unsigned long addr)
+static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -68,35 +40,39 @@ static pte_t *get_one_pte_map(struct mm_
 	if (pmd_none_or_clear_bad(pmd))
 		return NULL;
 
-	return pte_offset_map(pmd, addr);
+	return pmd;
 }
 
-static inline pte_t *alloc_one_pte_map(struct mm_struct *mm, unsigned long addr)
+static pmd_t *alloc_new_pmd(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
-
 	pud = pud_alloc(mm, pgd, addr);
 	if (!pud)
 		return NULL;
+
 	pmd = pmd_alloc(mm, pud, addr);
-	if (pmd)
-		pte = pte_alloc_map(mm, pmd, addr);
-	return pte;
+	if (!pmd)
+		return NULL;
+
+	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, addr) < 0)
+		return NULL;
+
+	return pmd;
 }
 
-static int
-move_one_page(struct vm_area_struct *vma, unsigned long old_addr,
-		struct vm_area_struct *new_vma, unsigned long new_addr)
+static void move_ptes(struct vm_area_struct *vma,
+		unsigned long old_addr, pmd_t *old_pmd,
+		unsigned long old_end, struct vm_area_struct *new_vma,
+		unsigned long new_addr, pmd_t *new_pmd)
 {
 	struct address_space *mapping = NULL;
 	struct mm_struct *mm = vma->vm_mm;
-	int error = 0;
-	pte_t *src, *dst;
+	pte_t *old_pte, *new_pte, pte;
+	spinlock_t *old_ptl, *new_ptl;
 
 	if (vma->vm_file) {
 		/*
@@ -111,74 +87,75 @@ move_one_page(struct vm_area_struct *vma
 		    new_vma->vm_truncate_count != vma->vm_truncate_count)
 			new_vma->vm_truncate_count = 0;
 	}
-	spin_lock(&mm->page_table_lock);
 
-	src = get_one_pte_map_nested(mm, old_addr);
-	if (src) {
-		/*
-		 * Look to see whether alloc_one_pte_map needs to perform a
-		 * memory allocation.  If it does then we need to drop the
-		 * atomic kmap
-		 */
-		dst = get_one_pte_map(mm, new_addr);
-		if (unlikely(!dst)) {
-			pte_unmap_nested(src);
-			if (mapping)
-				spin_unlock(&mapping->i_mmap_lock);
-			dst = alloc_one_pte_map(mm, new_addr);
-			if (mapping && !spin_trylock(&mapping->i_mmap_lock)) {
-				spin_unlock(&mm->page_table_lock);
-				spin_lock(&mapping->i_mmap_lock);
-				spin_lock(&mm->page_table_lock);
-			}
-			src = get_one_pte_map_nested(mm, old_addr);
-		}
-		/*
-		 * Since alloc_one_pte_map can drop and re-acquire
-		 * page_table_lock, we should re-check the src entry...
-		 */
-		if (src) {
-			if (dst) {
-				pte_t pte;
-				pte = ptep_clear_flush(vma, old_addr, src);
-				/* ZERO_PAGE can be dependant on virtual addr */
-				if (pfn_valid(pte_pfn(pte)) &&
-					pte_page(pte) == ZERO_PAGE(old_addr))
-					pte = pte_wrprotect(mk_pte(ZERO_PAGE(new_addr), new_vma->vm_page_prot));
-				set_pte_at(mm, new_addr, dst, pte);
-			} else
-				error = -ENOMEM;
-			pte_unmap_nested(src);
-		}
-		if (dst)
-			pte_unmap(dst);
-	}
-	spin_unlock(&mm->page_table_lock);
+	/*
+	 * We don't have to worry about the ordering of src and dst
+	 * pte locks because exclusive mmap_sem prevents deadlock.
+	 */
+	old_pte = pte_offset_map_lock(mm, old_pmd, old_addr, &old_ptl);
+	new_pte = pte_offset_map_nested(new_pmd, new_addr);
+	new_ptl = pte_lockptr(mm, new_pmd);
+	if (new_ptl != old_ptl)
+		spin_lock(new_ptl);
+
+	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
+				   new_pte++, new_addr += PAGE_SIZE) {
+		if (pte_none(*old_pte))
+			continue;
+		pte = ptep_clear_flush(vma, old_addr, old_pte);
+#ifdef CONFIG_MIPS
+		/* ZERO_PAGE can be dependant on virtual addr */
+		if (pfn_valid(pte_pfn(pte)) &&
+				pte_page(pte) == ZERO_PAGE(old_addr))
+			pte = pte_wrprotect(mk_pte(ZERO_PAGE(new_addr),
+						new_vma->vm_page_prot));
+#endif
+		set_pte_at(mm, new_addr, new_pte, pte);
+	}
+
+	if (new_ptl != old_ptl)
+		spin_unlock(new_ptl);
+	pte_unmap_nested(new_pte - 1);
+	pte_unmap_unlock(old_pte - 1, old_ptl);
+
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
-	return error;
 }
 
+#define LATENCY_LIMIT	(64 * PAGE_SIZE)
+
 static unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len)
 {
-	unsigned long offset;
+	unsigned long extent, next, old_end;
+	pmd_t *old_pmd, *new_pmd;
 
-	flush_cache_range(vma, old_addr, old_addr + len);
+	old_end = old_addr + len;
+	flush_cache_range(vma, old_addr, old_end);
 
-	/*
-	 * This is not the clever way to do this, but we're taking the
-	 * easy way out on the assumption that most remappings will be
-	 * only a few pages.. This also makes error recovery easier.
-	 */
-	for (offset = 0; offset < len; offset += PAGE_SIZE) {
-		if (move_one_page(vma, old_addr + offset,
-				new_vma, new_addr + offset) < 0)
-			break;
+	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
+		next = (old_addr + PMD_SIZE) & PMD_MASK;
+		if (next - 1 > old_end)
+			next = old_end;
+		extent = next - old_addr;
+		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
+		if (!old_pmd)
+			continue;
+		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
+		if (!new_pmd)
+			break;
+		next = (new_addr + PMD_SIZE) & PMD_MASK;
+		if (extent > next - new_addr)
+			extent = next - new_addr;
+		if (extent > LATENCY_LIMIT)
+			extent = LATENCY_LIMIT;
+		move_ptes(vma, old_addr, old_pmd, old_addr + extent,
+				new_vma, new_addr, new_pmd);
 	}
-	return offset;
+
+	return len + old_addr - old_end;	/* how much done */
 }
 
 static unsigned long move_vma(struct vm_area_struct *vma,
--- 26136m1-/mm/msync.c	2005-08-08 11:57:25.000000000 +0100
+++ 26136m1+/mm/msync.c	2005-08-22 12:41:30.000000000 +0100
@@ -17,21 +17,25 @@
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 
-/*
- * Called with mm->page_table_lock held to protect against other
- * threads/the swapper from ripping pte's out from under us.
- */
-
 static void sync_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end)
 {
 	pte_t *pte;
+	spinlock_t *ptl;
+	int progress = 0;
 
-	pte = pte_offset_map(pmd, addr);
+again:
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	do {
 		unsigned long pfn;
 		struct page *page;
 
+		if (progress >= 64) {
+			progress = 0;
+			if (need_resched() || need_lockbreak(ptl))
+				break;
+		}
+		progress++;
 		if (!pte_present(*pte))
 			continue;
 		if (!pte_maybe_dirty(*pte))
@@ -46,8 +50,12 @@ static void sync_pte_range(struct vm_are
 		if (ptep_clear_flush_dirty(vma, addr, pte) ||
 		    page_test_and_clear_dirty(page))
 			set_page_dirty(page);
+		progress += 3;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+	if (addr != end)
+		goto again;
 }
 
 static inline void sync_pmd_range(struct vm_area_struct *vma, pud_t *pud,
@@ -96,38 +104,13 @@ static void sync_page_range(struct vm_ar
 	BUG_ON(addr >= end);
 	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
-	spin_lock(&mm->page_table_lock);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
 		sync_pud_range(vma, pgd, addr, next);
 	} while (pgd++, addr = next, addr != end);
-	spin_unlock(&mm->page_table_lock);
-}
-
-#ifdef CONFIG_PREEMPT
-static inline void filemap_sync(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end)
-{
-	const size_t chunk = 64 * 1024;	/* bytes */
-	unsigned long next;
-
-	do {
-		next = addr + chunk;
-		if (next > end || next < addr)
-			next = end;
-		sync_page_range(vma, addr, next);
-		cond_resched();
-	} while (addr = next, addr != end);
-}
-#else
-static inline void filemap_sync(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end)
-{
-	sync_page_range(vma, addr, end);
 }
-#endif
 
 /*
  * MS_SYNC syncs the entire file - including mappings.
@@ -150,7 +133,7 @@ static int msync_interval(struct vm_area
 		return -EBUSY;
 
 	if (file && (vma->vm_flags & VM_SHARED)) {
-		filemap_sync(vma, addr, end);
+		sync_page_range(vma, addr, end);
 
 		if (flags & MS_SYNC) {
 			struct address_space *mapping = file->f_mapping;
--- 26136m1-/mm/rmap.c	2005-08-20 16:44:38.000000000 +0100
+++ 26136m1+/mm/rmap.c	2005-08-22 12:41:30.000000000 +0100
@@ -244,37 +244,44 @@ unsigned long page_address_in_vma(struct
 /*
  * Check that @page is mapped at @address into @mm.
  *
- * On success returns with mapped pte and locked mm->page_table_lock.
+ * On success returns with mapped pte and pte_lock.
  */
 pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address)
+			  unsigned long address, spinlock_t **ptlp)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	spinlock_t *ptl;
 
-	/*
-	 * We need the page_table_lock to protect us from page faults,
-	 * munmap, fork, etc...
-	 */
-	spin_lock(&mm->page_table_lock);
 	pgd = pgd_offset(mm, address);
-	if (likely(pgd_present(*pgd))) {
-		pud = pud_offset(pgd, address);
-		if (likely(pud_present(*pud))) {
-			pmd = pmd_offset(pud, address);
-			if (likely(pmd_present(*pmd))) {
-				pte = pte_offset_map(pmd, address);
-				if (likely(pte_present(*pte) &&
-					   page_to_pfn(page) == pte_pfn(*pte)))
-					return pte;
-				pte_unmap(pte);
-			}
-		}
+	if (!pgd_present(*pgd))
+		return NULL;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return NULL;
+
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		return NULL;
+
+	pte = pte_offset_map(pmd, address);
+	/* Make a quick check before getting the lock */
+	if (!pte_present(*pte)) {
+		pte_unmap(pte);
+		return NULL;
+	}
+
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
+		*ptlp = ptl;
+		return pte;
 	}
-	spin_unlock(&mm->page_table_lock);
-	return ERR_PTR(-ENOENT);
+	pte_unmap_unlock(pte, ptl);
+	return NULL;
 }
 
 /*
@@ -287,28 +294,28 @@ static int page_referenced_one(struct pa
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *pte;
+	spinlock_t *ptl;
 	int referenced = 0;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address);
-	if (!IS_ERR(pte)) {
-		if (ptep_clear_flush_young(vma, address, pte))
-			referenced++;
+	pte = page_check_address(page, mm, address, &ptl);
+	if (!pte)
+		goto out;
 
-		/* Pretend the page is referenced if the task has the
-		   swap token and is in the middle of a page fault. */
-		if (mm != current->mm && !ignore_token &&
-				has_swap_token(mm) &&
-				sem_is_read_locked(&mm->mmap_sem))
-			referenced++;
+	if (ptep_clear_flush_young(vma, address, pte))
+		referenced++;
 
-		(*mapcount)--;
-		pte_unmap(pte);
-		spin_unlock(&mm->page_table_lock);
-	}
+	/* Pretend the page is referenced if the task has the
+	   swap token and is in the middle of a page fault. */
+	if (mm != current->mm && !ignore_token && has_swap_token(mm) &&
+			sem_is_read_locked(&mm->mmap_sem))
+		referenced++;
+
+	(*mapcount)--;
+	pte_unmap_unlock(pte, ptl);
 out:
 	return referenced;
 }
@@ -438,7 +445,7 @@ int page_referenced(struct page *page, i
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
  *
- * The caller needs to hold the mm->page_table_lock.
+ * The caller needs to hold the pte_lock.
  */
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
@@ -465,7 +472,7 @@ void page_add_anon_rmap(struct page *pag
  * page_add_file_rmap - add pte mapping to a file page
  * @page: the page to add the mapping to
  *
- * The caller needs to hold the mm->page_table_lock.
+ * The caller needs to hold the pte_lock.
  */
 void page_add_file_rmap(struct page *page)
 {
@@ -481,7 +488,7 @@ void page_add_file_rmap(struct page *pag
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
  *
- * Caller needs to hold the mm->page_table_lock.
+ * The caller needs to hold the pte_lock.
  */
 void page_remove_rmap(struct page *page)
 {
@@ -514,14 +521,15 @@ static int try_to_unmap_one(struct page 
 	unsigned long address;
 	pte_t *pte;
 	pte_t pteval;
+	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address);
-	if (IS_ERR(pte))
+	pte = page_check_address(page, mm, address, &ptl);
+	if (!pte)
 		goto out;
 
 	/*
@@ -555,7 +563,8 @@ static int try_to_unmap_one(struct page 
 		swap_duplicate(entry);
 		if (list_empty(&mm->mmlist)) {
 			spin_lock(&mmlist_lock);
-			list_add(&mm->mmlist, &init_mm.mmlist);
+			if (list_empty(&mm->mmlist))
+				list_add(&mm->mmlist, &init_mm.mmlist);
 			spin_unlock(&mmlist_lock);
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
@@ -568,8 +577,7 @@ static int try_to_unmap_one(struct page 
 	page_cache_release(page);
 
 out_unmap:
-	pte_unmap(pte);
-	spin_unlock(&mm->page_table_lock);
+	pte_unmap_unlock(pte, ptl);
 out:
 	return ret;
 }
@@ -603,19 +611,14 @@ static void try_to_unmap_cluster(unsigne
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte, *original_pte;
+	pte_t *pte;
 	pte_t pteval;
+	spinlock_t *ptl;
 	struct page *page;
 	unsigned long address;
 	unsigned long end;
 	unsigned long pfn;
 
-	/*
-	 * We need the page_table_lock to protect us from page faults,
-	 * munmap, fork, etc...
-	 */
-	spin_lock(&mm->page_table_lock);
-
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
 	if (address < vma->vm_start)
@@ -625,17 +628,17 @@ static void try_to_unmap_cluster(unsigne
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
-		goto out_unlock;
+		return;
 
 	pud = pud_offset(pgd, address);
 	if (!pud_present(*pud))
-		goto out_unlock;
+		return;
 
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
-		goto out_unlock;
+		return;
 
-	for (original_pte = pte = pte_offset_map(pmd, address);
+	for (pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 			address < end; pte++, address += PAGE_SIZE) {
 
 		if (!pte_present(*pte))
@@ -671,9 +674,7 @@ static void try_to_unmap_cluster(unsigne
 		(*mapcount)--;
 	}
 
-	pte_unmap(original_pte);
-out_unlock:
-	spin_unlock(&mm->page_table_lock);
+	pte_unmap_unlock(pte - 1, ptl);
 }
 
 static int try_to_unmap_anon(struct page *page)
--- 26136m1-/mm/swap_state.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1+/mm/swap_state.c	2005-08-22 12:41:30.000000000 +0100
@@ -263,8 +263,7 @@ static inline void free_swap_cache(struc
 
 /* 
  * Perform a free_page(), also freeing any swap cache associated with
- * this page if it is the last user of the page. Can not do a lock_page,
- * as we are holding the page_table_lock spinlock.
+ * this page if it is the last user of the page.
  */
 void free_page_and_swap_cache(struct page *page)
 {
--- 26136m1-/mm/swapfile.c	2005-08-19 14:30:14.000000000 +0100
+++ 26136m1+/mm/swapfile.c	2005-08-22 12:41:30.000000000 +0100
@@ -397,8 +397,6 @@ void free_swap_and_cache(swp_entry_t ent
 
 /*
  * Since we're swapping it in, we mark it as old.
- *
- * vma->vm_mm->page_table_lock is held.
  */
 static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
 		unsigned long addr, swp_entry_t entry, struct page *page)
@@ -420,23 +418,25 @@ static int unuse_pte_range(struct vm_are
 				unsigned long addr, unsigned long end,
 				swp_entry_t entry, struct page *page)
 {
-	pte_t *pte;
 	pte_t swp_pte = swp_entry_to_pte(entry);
+	pte_t *pte;
+	spinlock_t *ptl;
+	int found = 0;
 
-	pte = pte_offset_map(pmd, addr);
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	do {
 		/*
 		 * swapoff spends a _lot_ of time in this loop!
 		 * Test inline before going to call unuse_pte.
 		 */
 		if (unlikely(pte_same(*pte, swp_pte))) {
-			unuse_pte(vma, pte, addr, entry, page);
-			pte_unmap(pte);
-			return 1;
+			unuse_pte(vma, pte++, addr, entry, page);
+			found = 1;
+			break;
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap(pte - 1);
-	return 0;
+	pte_unmap_unlock(pte - 1, ptl);
+	return found;
 }
 
 static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
@@ -518,12 +518,10 @@ static int unuse_mm(struct mm_struct *mm
 		down_read(&mm->mmap_sem);
 		lock_page(page);
 	}
-	spin_lock(&mm->page_table_lock);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma && unuse_vma(vma, entry, page))
 			break;
 	}
-	spin_unlock(&mm->page_table_lock);
 	up_read(&mm->mmap_sem);
 	/*
 	 * Currently unuse_mm cannot fail, but leave error handling
--- 26136m1-/mm/vmalloc.c	2005-06-17 20:48:29.000000000 +0100
+++ 26136m1+/mm/vmalloc.c	2005-08-22 12:41:30.000000000 +0100
@@ -88,7 +88,7 @@ static int vmap_pte_range(pmd_t *pmd, un
 {
 	pte_t *pte;
 
-	pte = pte_alloc_kernel(&init_mm, pmd, addr);
+	pte = pte_alloc_kernel(pmd, addr);
 	if (!pte)
 		return -ENOMEM;
 	do {
@@ -146,14 +146,12 @@ int map_vm_area(struct vm_struct *area, 
 
 	BUG_ON(addr >= end);
 	pgd = pgd_offset_k(addr);
-	spin_lock(&init_mm.page_table_lock);
 	do {
 		next = pgd_addr_end(addr, end);
 		err = vmap_pud_range(pgd, addr, next, prot, pages);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	spin_unlock(&init_mm.page_table_lock);
 	flush_cache_vmap((unsigned long) area->addr, end);
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
