From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070331193107.1800.28259.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
References: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 2/2] i386 arch page size slab fixes
Date: Sat, 31 Mar 2007 11:31:07 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

Fixup i386 arch for SLUB support

i386 arch code currently uses the page struct of slabs for various purposes.
This interferes with slub and so SLUB has been disabled for i386 by setting
ARCH_USES_SLAB_PAGE_STRUCT.

This patch removes the use of page sized slabs for maintaining pgds and pmds.

Patch by William Irwin with only very minor modifications by me which are

1. Removal of HIGHMEM64G slab caches. It seems that virtualization hosts
   require a a full pgd page.

2. Add missing virtualization hook. Seems that we need a new way
   of serializing paravirt_alloc(). It may need to do its own serialization.

3. Remove ARCH_USES_SLAB_PAGE_STRUCT

Note that this makes things work without debugging on.
The arch still fails to boot properly if full SLUB debugging is on with
a cryptic message:

CPU: AMD Athlon(tm) 64 Processor 3000+ stepping 00
Checking 'hlt' instruction... OK.
ACPI: Core revision 20070126
ACPI: setting ELCR to 0200 (from 1ca0)
BUG: at kernel/sched.c:3417 sub_preempt_count()
 [<c0342d43>] _spin_unlock_irq+0x13/0x30
 [<c01160e6>] schedule_tail+0x36/0xd0
 [<c0102df8>] __switch_to+0x28/0x180
 [<c0103f9a>] ret_from_fork+0x6/0x1c
 [<c012acf0>] kthread+0x0/0xe0

This may have a coule of reasons:

1. SLUB breakage. kmalloc caches have been initialized but maybe debugging
   uses a facility that is not available that early (can find nothing).

2. SLAB does not enable full debugging for page order slabs. SLUB does.
   So we were so far unable to verify that the code is clean for these
   slabs. There could be some unsolved slab issues. i386 fails to boot
   if any of the debug options that require additional metadata at the
   end of an object or poisoning is enabled. Boot will work with sanity
   checks only.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: William Lee Irwin III <wli@holomorphy.com>

Index: linux-2.6.21-rc5-mm3/arch/i386/mm/init.c
===================================================================
--- linux-2.6.21-rc5-mm3.orig/arch/i386/mm/init.c	2007-03-30 18:26:11.000000000 -0700
+++ linux-2.6.21-rc5-mm3/arch/i386/mm/init.c	2007-03-30 18:28:04.000000000 -0700
@@ -696,31 +696,6 @@ int remove_memory(u64 start, u64 size)
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif
 
-struct kmem_cache *pgd_cache;
-struct kmem_cache *pmd_cache;
-
-void __init pgtable_cache_init(void)
-{
-	if (PTRS_PER_PMD > 1) {
-		pmd_cache = kmem_cache_create("pmd",
-					PTRS_PER_PMD*sizeof(pmd_t),
-					PTRS_PER_PMD*sizeof(pmd_t),
-					0,
-					pmd_ctor,
-					NULL);
-		if (!pmd_cache)
-			panic("pgtable_cache_init(): cannot create pmd cache");
-	}
-	pgd_cache = kmem_cache_create("pgd",
-				PTRS_PER_PGD*sizeof(pgd_t),
-				PTRS_PER_PGD*sizeof(pgd_t),
-				0,
-				pgd_ctor,
-				PTRS_PER_PMD == 1 ? pgd_dtor : NULL);
-	if (!pgd_cache)
-		panic("pgtable_cache_init(): Cannot create pgd cache");
-}
-
 /*
  * This function cannot be __init, since exceptions don't work in that
  * section.  Put this after the callers, so that it cannot be inlined.
Index: linux-2.6.21-rc5-mm3/arch/i386/mm/pageattr.c
===================================================================
--- linux-2.6.21-rc5-mm3.orig/arch/i386/mm/pageattr.c	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm3/arch/i386/mm/pageattr.c	2007-03-30 18:28:04.000000000 -0700
@@ -87,24 +87,23 @@ static void flush_kernel_map(void *arg)
 
 static void set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte) 
 { 
-	struct page *page;
-	unsigned long flags;
+	struct mm_struct *mm;
 
 	set_pte_atomic(kpte, pte); 	/* change init_mm */
 	if (PTRS_PER_PMD > 1)
 		return;
 
-	spin_lock_irqsave(&pgd_lock, flags);
-	for (page = pgd_list; page; page = (struct page *)page->index) {
-		pgd_t *pgd;
+	spin_lock(&mmlist_lock);
+	list_for_each_entry(mm, &init_mm.mmlist, mmlist) {
+		pgd_t *pgd = mm->pgd;
 		pud_t *pud;
 		pmd_t *pmd;
-		pgd = (pgd_t *)page_address(page) + pgd_index(address);
+
 		pud = pud_offset(pgd, address);
 		pmd = pmd_offset(pud, address);
 		set_pte_atomic((pte_t *)pmd, pte);
 	}
-	spin_unlock_irqrestore(&pgd_lock, flags);
+	spin_unlock(&mmlist_lock);
 }
 
 /* 
Index: linux-2.6.21-rc5-mm3/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.21-rc5-mm3.orig/arch/i386/mm/pgtable.c	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm3/arch/i386/mm/pgtable.c	2007-03-30 18:28:04.000000000 -0700
@@ -181,109 +181,30 @@ void reserve_top_address(unsigned long r
 #endif
 }
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
-{
-	return (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
-}
-
-struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
-{
-	struct page *pte;
-
-#ifdef CONFIG_HIGHPTE
-	pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|__GFP_ZERO, 0);
-#else
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
-#endif
-	return pte;
-}
-
-void pmd_ctor(void *pmd, struct kmem_cache *cache, unsigned long flags)
-{
-	memset(pmd, 0, PTRS_PER_PMD*sizeof(pmd_t));
-}
-
-/*
- * List of all pgd's needed for non-PAE so it can invalidate entries
- * in both cached and uncached pgd's; not needed for PAE since the
- * kernel pmd is shared. If PAE were not to share the pmd a similar
- * tactic would be needed. This is essentially codepath-based locking
- * against pageattr.c; it is the unique case in which a valid change
- * of kernel pagetables can't be lazily synchronized by vmalloc faults.
- * vmalloc faults work because attached pagetables are never freed.
- * The locking scheme was chosen on the basis of manfred's
- * recommendations and having no core impact whatsoever.
- * -- wli
- */
-DEFINE_SPINLOCK(pgd_lock);
-struct page *pgd_list;
-
-static inline void pgd_list_add(pgd_t *pgd)
-{
-	struct page *page = virt_to_page(pgd);
-	page->index = (unsigned long)pgd_list;
-	if (pgd_list)
-		set_page_private(pgd_list, (unsigned long)&page->index);
-	pgd_list = page;
-	set_page_private(page, (unsigned long)&pgd_list);
-}
-
-static inline void pgd_list_del(pgd_t *pgd)
-{
-	struct page *next, **pprev, *page = virt_to_page(pgd);
-	next = (struct page *)page->index;
-	pprev = (struct page **)page_private(page);
-	*pprev = next;
-	if (next)
-		set_page_private(next, (unsigned long)pprev);
-}
-
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
-{
-	unsigned long flags;
-
-	if (PTRS_PER_PMD == 1) {
-		memset(pgd, 0, USER_PTRS_PER_PGD*sizeof(pgd_t));
-		spin_lock_irqsave(&pgd_lock, flags);
-	}
-
-	clone_pgd_range((pgd_t *)pgd + USER_PTRS_PER_PGD,
-			swapper_pg_dir + USER_PTRS_PER_PGD,
-			KERNEL_PGD_PTRS);
-
-	if (PTRS_PER_PMD > 1)
-		return;
-
-	/* must happen under lock */
-	paravirt_alloc_pd_clone(__pa(pgd) >> PAGE_SHIFT,
-			__pa(swapper_pg_dir) >> PAGE_SHIFT,
-			USER_PTRS_PER_PGD, PTRS_PER_PGD - USER_PTRS_PER_PGD);
-
-	pgd_list_add(pgd);
-	spin_unlock_irqrestore(&pgd_lock, flags);
-}
-
-/* never called when PTRS_PER_PMD > 1 */
-void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
-{
-	unsigned long flags; /* can be called from interrupt context */
-
-	paravirt_release_pd(__pa(pgd) >> PAGE_SHIFT);
-	spin_lock_irqsave(&pgd_lock, flags);
-	pgd_list_del(pgd);
-	spin_unlock_irqrestore(&pgd_lock, flags);
-}
+#define __pgd_alloc()	((pgd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT))
+#define __pgd_free(pgd)	free_page((unsigned long)(pgd))
 
 pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	int i;
-	pgd_t *pgd = kmem_cache_alloc(pgd_cache, GFP_KERNEL);
+	pgd_t *pgd = __pgd_alloc();
 
-	if (PTRS_PER_PMD == 1 || !pgd)
+	if (!pgd)
+		return NULL;
+	clone_pgd_range((pgd_t *)pgd + USER_PTRS_PER_PGD,
+		swapper_pg_dir + USER_PTRS_PER_PGD, KERNEL_PGD_PTRS);
+	if (PTRS_PER_PMD == 1)
 		return pgd;
+	/*
+	 * Beware. We do not have the pgd_lock for serialization anymore.
+	 * paravirt_alloc_pd_clone needs to have its own serialization?
+	 */
+	 paravirt_alloc_pd_clone(__pa(pgd) >> PAGE_SHIFT,
+		__pa(swapper_pg_dir) >> PAGE_SHIFT,
+		USER_PTRS_PER_PGD, PTRS_PER_PGD - USER_PTRS_PER_PGD);
 
 	for (i = 0; i < USER_PTRS_PER_PGD; ++i) {
-		pmd_t *pmd = kmem_cache_alloc(pmd_cache, GFP_KERNEL);
+		pmd_t *pmd = (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
 		if (!pmd)
 			goto out_oom;
 		paravirt_alloc_pd(__pa(pmd) >> PAGE_SHIFT);
@@ -296,9 +217,9 @@ out_oom:
 		pgd_t pgdent = pgd[i];
 		void* pmd = (void *)__va(pgd_val(pgdent)-1);
 		paravirt_release_pd(__pa(pmd) >> PAGE_SHIFT);
-		kmem_cache_free(pmd_cache, pmd);
+		free_page((unsigned long)pmd);
 	}
-	kmem_cache_free(pgd_cache, pgd);
+	__pgd_free(pgd);
 	return NULL;
 }
 
@@ -312,8 +233,8 @@ void pgd_free(pgd_t *pgd)
 			pgd_t pgdent = pgd[i];
 			void* pmd = (void *)__va(pgd_val(pgdent)-1);
 			paravirt_release_pd(__pa(pmd) >> PAGE_SHIFT);
-			kmem_cache_free(pmd_cache, pmd);
+			free_page((unsigned long)pmd);
 		}
 	/* in the non-PAE case, free_pgtables() clears user pgd entries */
-	kmem_cache_free(pgd_cache, pgd);
+	__pgd_free(pgd);
 }
Index: linux-2.6.21-rc5-mm3/include/asm-i386/pgalloc.h
===================================================================
--- linux-2.6.21-rc5-mm3.orig/include/asm-i386/pgalloc.h	2007-03-30 18:26:15.000000000 -0700
+++ linux-2.6.21-rc5-mm3/include/asm-i386/pgalloc.h	2007-03-30 18:28:04.000000000 -0700
@@ -35,8 +35,22 @@ do {								\
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(pgd_t *pgd);
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
-extern struct page *pte_alloc_one(struct mm_struct *, unsigned long);
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long uvaddr)
+{
+	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+}
+
+#ifdef CONFIG_HIGHPTE
+static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long uvaddr)
+{
+	return alloc_page(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|__GFP_ZERO);
+}
+#else /* !CONFIG_HIGHPTE */
+static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long uvaddr)
+{
+	return alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+}
+#endif /* !CONFIG_HIGHPTE */
 
 static inline void pte_free_kernel(pte_t *pte)
 {
Index: linux-2.6.21-rc5-mm3/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.21-rc5-mm3.orig/include/asm-i386/pgtable.h	2007-03-30 18:26:15.000000000 -0700
+++ linux-2.6.21-rc5-mm3/include/asm-i386/pgtable.h	2007-03-30 18:28:04.000000000 -0700
@@ -35,15 +35,6 @@ struct vm_area_struct;
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
 extern unsigned long empty_zero_page[1024];
 extern pgd_t swapper_pg_dir[1024];
-extern struct kmem_cache *pgd_cache;
-extern struct kmem_cache *pmd_cache;
-extern spinlock_t pgd_lock;
-extern struct page *pgd_list;
-
-void pmd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_dtor(void *, struct kmem_cache *, unsigned long);
-void pgtable_cache_init(void);
 void paging_init(void);
 
 /*
Index: linux-2.6.21-rc5-mm3/include/asm-i386/pgtable-2level.h
===================================================================
--- linux-2.6.21-rc5-mm3.orig/include/asm-i386/pgtable-2level.h	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm3/include/asm-i386/pgtable-2level.h	2007-03-30 18:28:04.000000000 -0700
@@ -67,5 +67,6 @@ static inline int pte_exec_kernel(pte_t 
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
 void vmalloc_sync_all(void);
+#define pgtable_cache_init()		do { } while (0)
 
 #endif /* _I386_PGTABLE_2LEVEL_H */
Index: linux-2.6.21-rc5-mm3/include/asm-i386/pgtable-3level.h
===================================================================
--- linux-2.6.21-rc5-mm3.orig/include/asm-i386/pgtable-3level.h	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm3/include/asm-i386/pgtable-3level.h	2007-03-30 18:28:04.000000000 -0700
@@ -188,5 +188,6 @@ static inline pmd_t pfn_pmd(unsigned lon
 #define __pmd_free_tlb(tlb, x)		do { } while (0)
 
 #define vmalloc_sync_all() ((void)0)
+void pgtable_cache_init(void);
 
 #endif /* _I386_PGTABLE_3LEVEL_H */
Index: linux-2.6.21-rc5-mm3/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.21-rc5-mm3.orig/arch/i386/mm/fault.c	2007-03-30 18:26:11.000000000 -0700
+++ linux-2.6.21-rc5-mm3/arch/i386/mm/fault.c	2007-03-30 18:28:04.000000000 -0700
@@ -618,19 +618,19 @@ void vmalloc_sync_all(void)
 	BUILD_BUG_ON(TASK_SIZE & ~PGDIR_MASK);
 	for (address = start; address >= TASK_SIZE; address += PGDIR_SIZE) {
 		if (!test_bit(pgd_index(address), insync)) {
-			unsigned long flags;
-			struct page *page;
+			struct mm_struct *mm;
+			int broken = 0;
 
-			spin_lock_irqsave(&pgd_lock, flags);
-			for (page = pgd_list; page; page =
-					(struct page *)page->index)
-				if (!vmalloc_sync_one(page_address(page),
-								address)) {
-					BUG_ON(page != pgd_list);
-					break;
-				}
-			spin_unlock_irqrestore(&pgd_lock, flags);
-			if (!page)
+			spin_lock(&mmlist_lock);
+			list_for_each_entry(mm, &init_mm.mmlist, mmlist) {
+				if (vmalloc_sync_one(mm->pgd, address))
+					continue;
+				BUG_ON(mm->mmlist.prev != &init_mm.mmlist);
+				broken = 1;
+				break;
+			}
+			spin_unlock(&mmlist_lock);
+			if (!broken)
 				set_bit(pgd_index(address), insync);
 		}
 		if (address == start && test_bit(pgd_index(address), insync))
Index: linux-2.6.21-rc5-mm3/arch/i386/Kconfig
===================================================================
--- linux-2.6.21-rc5-mm3.orig/arch/i386/Kconfig	2007-03-30 18:27:03.000000000 -0700
+++ linux-2.6.21-rc5-mm3/arch/i386/Kconfig	2007-03-30 18:28:04.000000000 -0700
@@ -79,10 +79,6 @@ config ARCH_MAY_HAVE_PC_FDC
 	bool
 	default y
 
-config ARCH_USES_SLAB_PAGE_STRUCT
-	bool
-	default y
-
 config DMI
 	bool
 	default y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
