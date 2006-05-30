Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:10:04 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:10:03 +1000 (EST)
Subject: [Patch 2/17] PTI: Abstract default page table A
Message-ID: <Pine.LNX.4.61.0605301706450.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add the default page table as a compulsory options in the i386 config
  and the IA64 config (in the Kernel Hacking section).

  default-pt.c (default page table implementation) is now to be compiled 
into
  mm/Makefile.

  Delete the default page table implementation from memory.c (that was 
moved
  to default-pt.c in the previous patch).

  Put page table tear down functions in default-pt.c (page table 
implementation
  from memory.c)

  arch/i386/Kconfig.debug |    9 ++
  arch/ia64/Kconfig.debug |    9 ++
  mm/Makefile             |    3
  mm/default-pt.c         |  148 
++++++++++++++++++++++++++++++++++++++++++++++++
  mm/memory.c             |  121 ---------------------------------------
  5 files changed, 169 insertions(+), 121 deletions(-)
Index: linux-rc5/arch/ia64/Kconfig.debug
===================================================================
--- linux-rc5.orig/arch/ia64/Kconfig.debug	2006-05-28 
00:59:09.530730600 +1000
+++ linux-rc5/arch/ia64/Kconfig.debug	2006-05-28 01:00:06.998994096 
+1000
@@ -3,6 +3,15 @@
  source "lib/Kconfig.debug"

  choice
+	prompt "Page table selection"
+	default DEFAULT-PT
+
+config  DEFAULT_PT
+	bool "DEFAULT-PT"
+
+endchoice
+
+choice
  	prompt "Physical memory granularity"
  	default IA64_GRANULE_64MB

Index: linux-rc5/mm/Makefile
===================================================================
--- linux-rc5.orig/mm/Makefile	2006-05-28 00:59:09.530730600 +1000
+++ linux-rc5/mm/Makefile	2006-05-28 01:00:06.998994096 +1000
@@ -6,6 +6,9 @@
  mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o 
\
  			   mlock.o mmap.o mprotect.o mremap.o msync.o 
rmap.o \
  			   vmalloc.o
+ifdef CONFIG_MMU
+mmu-$(CONFIG_DEFAULT_PT)+= default-pt.o
+endif

  obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o 
fadvise.o \
  			   page_alloc.o page-writeback.o pdflush.o \
Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 00:59:09.530730600 +1000
+++ linux-rc5/mm/memory.c	2006-05-28 01:00:06.999993944 +1000
@@ -91,31 +91,6 @@
  }
  __setup("norandmaps", disable_randmaps);

-
-/*
- * If a p?d_bad entry is found while walking page tables, report
- * the error, before resetting entry to p?d_none.  Usually (but
- * very seldom) called out from the p?d_none_or_clear_bad macros.
- */
-
-void pgd_clear_bad(pgd_t *pgd)
-{
-	pgd_ERROR(*pgd);
-	pgd_clear(pgd);
-}
-
-void pud_clear_bad(pud_t *pud)
-{
-	pud_ERROR(*pud);
-	pud_clear(pud);
-}
-
-void pmd_clear_bad(pmd_t *pmd)
-{
-	pmd_ERROR(*pmd);
-	pmd_clear(pmd);
-}
-
  /*
   * Note: this doesn't free the actual pages themselves. That
   * has been handled earlier when unmapping all the memory regions.
@@ -298,41 +273,6 @@
  	}
  }

-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
-{
-	struct page *new = pte_alloc_one(mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	pte_lock_init(new);
-	spin_lock(&mm->page_table_lock);
-	if (pmd_present(*pmd)) {	/* Another has populated it */
-		pte_lock_deinit(new);
-		pte_free(new);
-	} else {
-		mm->nr_ptes++;
-		inc_page_state(nr_page_table_pages);
-		pmd_populate(mm, pmd, new);
-	}
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-}
-
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
-{
-	pte_t *new = pte_alloc_one_kernel(&init_mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	spin_lock(&init_mm.page_table_lock);
-	if (pmd_present(*pmd))		/* Another has populated it */
-		pte_free_kernel(new);
-	else
-		pmd_populate_kernel(&init_mm, pmd, new);
-	spin_unlock(&init_mm.page_table_lock);
-	return 0;
-}
-
  static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int 
anon_rss)
  {
  	if (file_rss)
@@ -2284,67 +2224,6 @@

  EXPORT_SYMBOL_GPL(__handle_mm_fault);

-#ifndef __PAGETABLE_PUD_FOLDED
-/*
- * Allocate page upper directory.
- * We've already handled the fast-path in-line.
- */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
-{
-	pud_t *new = pud_alloc_one(mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	spin_lock(&mm->page_table_lock);
-	if (pgd_present(*pgd))		/* Another has populated it */
-		pud_free(new);
-	else
-		pgd_populate(mm, pgd, new);
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-}
-#else
-/* Workaround for gcc 2.96 */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
-{
-	return 0;
-}
-#endif /* __PAGETABLE_PUD_FOLDED */
-
-#ifndef __PAGETABLE_PMD_FOLDED
-/*
- * Allocate page middle directory.
- * We've already handled the fast-path in-line.
- */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
-{
-	pmd_t *new = pmd_alloc_one(mm, address);
-	if (!new)
-		return -ENOMEM;
-
-	spin_lock(&mm->page_table_lock);
-#ifndef __ARCH_HAS_4LEVEL_HACK
-	if (pud_present(*pud))		/* Another has populated it */
-		pmd_free(new);
-	else
-		pud_populate(mm, pud, new);
-#else
-	if (pgd_present(*pud))		/* Another has populated it */
-		pmd_free(new);
-	else
-		pgd_populate(mm, pud, new);
-#endif /* __ARCH_HAS_4LEVEL_HACK */
-	spin_unlock(&mm->page_table_lock);
-	return 0;
-}
-#else
-/* Workaround for gcc 2.96 */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
-{
-	return 0;
-}
-#endif /* __PAGETABLE_PMD_FOLDED */
-
  int make_pages_present(unsigned long addr, unsigned long end)
  {
  	int ret, len, write;
Index: linux-rc5/mm/default-pt.c
===================================================================
--- linux-rc5.orig/mm/default-pt.c	2006-05-28 01:00:04.790329864 
+1000
+++ linux-rc5/mm/default-pt.c	2006-05-28 01:00:07.000993792 +1000
@@ -78,6 +78,154 @@
  	return 0;
  }

+/*
+ * Note: this doesn't free the actual pages themselves. That
+ * has been handled earlier when unmapping all the memory regions.
+ */
+static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd)
+{
+	struct page *page = pmd_page(*pmd);
+	pmd_clear(pmd);
+	pte_lock_deinit(page);
+	pte_free_tlb(tlb, page);
+	dec_page_state(nr_page_table_pages);
+	tlb->mm->nr_ptes--;
+}
+
+static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
+				unsigned long addr, unsigned long end,
+				unsigned long floor, unsigned long 
ceiling)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		free_pte_range(tlb, pmd);
+	} while (pmd++, addr = next, addr != end);
+
+	start &= PUD_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= PUD_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pmd = pmd_offset(pud, start);
+	pud_clear(pud);
+	pmd_free_tlb(tlb, pmd);
+}
+
+static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				unsigned long floor, unsigned long 
ceiling)
+{
+	pud_t *pud;
+	unsigned long next;
+	unsigned long start;
+
+	start = addr;
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		free_pmd_range(tlb, pud, addr, next, floor, ceiling);
+	} while (pud++, addr = next, addr != end);
+
+	start &= PGDIR_MASK;
+	if (start < floor)
+		return;
+	if (ceiling) {
+		ceiling &= PGDIR_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		return;
+
+	pud = pud_offset(pgd, start);
+	pgd_clear(pgd);
+	pud_free_tlb(tlb, pud);
+}
+
+/*
+ * This function frees user-level page tables of a process.
+ *
+ * Must be called with pagetable lock held.
+ */
+void free_pgd_range(struct mmu_gather **tlb,
+			unsigned long addr, unsigned long end,
+			unsigned long floor, unsigned long ceiling)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	unsigned long start;
+
+	/*
+	 * The next few lines have given us lots of grief...
+	 *
+	 * Why are we testing PMD* at this top level?  Because often
+	 * there will be no work to do at all, and we'd prefer not to
+	 * go all the way down to the bottom just to discover that.
+	 *
+	 * Why all these "- 1"s?  Because 0 represents both the bottom
+	 * of the address space and the top of it (using -1 for the
+	 * top wouldn't help much: the masks would do the wrong thing).
+	 * The rule is that addr 0 and floor 0 refer to the bottom of
+	 * the address space, but end 0 and ceiling 0 refer to the top
+	 * Comparisons need to use "end - 1" and "ceiling - 1" (though
+	 * that end 0 case should be mythical).
+	 *
+	 * Wherever addr is brought up or ceiling brought down, we must
+	 * be careful to reject "the opposite 0" before it confuses the
+	 * subsequent tests.  But what about where end is brought down
+	 * by PMD_SIZE below? no, end can't go down to 0 there.
+	 *
+	 * Whereas we round start (addr) and ceiling down, by different
+	 * masks at different levels, in order to test whether a table
+	 * now has no other vmas using it, so can be freed, we don't
+	 * bother to round floor or end up - the tests don't need that.
+	 */
+
+	addr &= PMD_MASK;
+	if (addr < floor) {
+		addr += PMD_SIZE;
+		if (!addr)
+			return;
+	}
+	if (ceiling) {
+		ceiling &= PMD_MASK;
+		if (!ceiling)
+			return;
+	}
+	if (end - 1 > ceiling - 1)
+		end -= PMD_SIZE;
+	if (addr > end - 1)
+		return;
+
+	start = addr;
+	pgd = pgd_offset((*tlb)->mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		free_pud_range(*tlb, pgd, addr, next, floor, ceiling);
+	} while (pgd++, addr = next, addr != end);
+
+	if (!(*tlb)->fullmm)
+		flush_tlb_pgtables((*tlb)->mm, start, end);
+}
+
  #ifndef __PAGETABLE_PUD_FOLDED
  /*
   * Allocate page upper directory.
Index: linux-rc5/arch/i386/Kconfig.debug
===================================================================
--- linux-rc5.orig/arch/i386/Kconfig.debug	2006-05-28 
00:59:09.530730600 +1000
+++ linux-rc5/arch/i386/Kconfig.debug	2006-05-28 01:00:07.000993792 
+1000
@@ -2,6 +2,15 @@

  source "lib/Kconfig.debug"

+choice
+	prompt "Page table selection"
+	default DEFAULT-PT
+
+config  DEFAULT_PT
+	bool "DEFAULT-PT"
+
+endchoice
+
  config EARLY_PRINTK
  	bool "Early printk" if EMBEDDED && DEBUG_KERNEL
  	default y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
