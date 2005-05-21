From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 15:15:04 +1000 (EST)
Subject: [PATCH 14/15] PTI: Move IA64 mlpt code behind interface
In-Reply-To: <Pine.LNX.4.61.0505211506080.8979@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211513270.8979@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211409350.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211417450.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211455390.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211500180.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211506080.8979@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 14 of 15.

This patch moves the mlpt specific code for the ia64 architecture behind 
the
architecture specific part of the page table interface.

 	*Shifted some defines from init.c to ia64-mlpt.c
 	*Moved the set of functions that controls the level of cached
 	 directories from init.c to ia64-mlpt.c.
 	*Moved through the files that call pgalloc.h which
 	 is now a part of the page table implementation and
 	 call page_table.h instead, which is independent.

  arch/ia64/kernel/process.c          |    2
  arch/ia64/kernel/smp.c              |    3 -
  arch/ia64/kernel/smpboot.c          |    3 -
  arch/ia64/mm/contig.c               |    5 +-
  arch/ia64/mm/discontig.c            |    2
  arch/ia64/mm/fixed-mlpt/mlpt-ia64.c |   82 
++++++++++++++++++++++++++++++++++++
  arch/ia64/mm/init.c                 |   56 +-----------------------
  arch/ia64/mm/tlb.c                  |    2
  arch/ia64/sn/kernel/sn2/cache.c     |    1
  include/asm-ia64/tlb.h              |   20 +-------
  10 files changed, 97 insertions(+), 79 deletions(-)

Index: linux-2.6.12-rc4/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/mm/init.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/mm/init.c	2005-05-19 
18:36:14.000000000 +1000
@@ -20,7 +20,9 @@
  #include <linux/swap.h>
  #include <linux/proc_fs.h>
  #include <linux/bitops.h>
+#include <linux/page_table.h>

+#include <asm/mlpt.h>
  #include <asm/a.out.h>
  #include <asm/dma.h>
  #include <asm/ia32.h>
@@ -28,7 +30,6 @@
  #include <asm/machvec.h>
  #include <asm/numa.h>
  #include <asm/patch.h>
-#include <asm/pgalloc.h>
  #include <asm/sal.h>
  #include <asm/sections.h>
  #include <asm/system.h>
@@ -39,9 +40,6 @@

  DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);

-DEFINE_PER_CPU(unsigned long *, __pgtable_quicklist);
-DEFINE_PER_CPU(long, __pgtable_quicklist_size);
-
  extern void ia64_tlb_init (void);

  unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
@@ -56,53 +54,6 @@
  struct page *zero_page_memmap_ptr;	/* map entry for zero page */
  EXPORT_SYMBOL(zero_page_memmap_ptr);

-#define MIN_PGT_PAGES			25UL
-#define MAX_PGT_FREES_PER_PASS		16L
-#define PGT_FRACTION_OF_NODE_MEM	16
-
-static inline long
-max_pgt_pages(void)
-{
-	u64 node_free_pages, max_pgt_pages;
-
-#ifndef	CONFIG_NUMA
-	node_free_pages = nr_free_pages();
-#else
-	node_free_pages = nr_free_pages_pgdat(NODE_DATA(numa_node_id()));
-#endif
-	max_pgt_pages = node_free_pages / PGT_FRACTION_OF_NODE_MEM;
-	max_pgt_pages = max(max_pgt_pages, MIN_PGT_PAGES);
-	return max_pgt_pages;
-}
-
-static inline long
-min_pages_to_free(void)
-{
-	long pages_to_free;
-
-	pages_to_free = pgtable_quicklist_size - max_pgt_pages();
-	pages_to_free = min(pages_to_free, MAX_PGT_FREES_PER_PASS);
-	return pages_to_free;
-}
-
-void
-check_pgt_cache(void)
-{
-	long pages_to_free;
-
-	if (unlikely(pgtable_quicklist_size <= MIN_PGT_PAGES))
-		return;
-
-	preempt_disable();
-	while (unlikely((pages_to_free = min_pages_to_free()) > 0)) {
-		while (pages_to_free--) {
-			free_page((unsigned 
long)pgtable_quicklist_alloc());
-		}
-		preempt_enable();
-		preempt_disable();
-	}
-	preempt_enable();
-}

  void
  lazy_mmu_prot_update (pte_t pte)
@@ -555,10 +506,11 @@
  	pg_data_t *pgdat;
  	int i;
  	static struct kcore_list kcore_mem, kcore_vmem, kcore_kernel;
-
+#ifdef CONFIG_MLPT
  	BUG_ON(PTRS_PER_PGD * sizeof(pgd_t) != PAGE_SIZE);
  	BUG_ON(PTRS_PER_PMD * sizeof(pmd_t) != PAGE_SIZE);
  	BUG_ON(PTRS_PER_PTE * sizeof(pte_t) != PAGE_SIZE);
+#endif

  #ifdef CONFIG_PCI
  	/*
Index: linux-2.6.12-rc4/arch/ia64/kernel/process.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/kernel/process.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/kernel/process.c	2005-05-19 
18:36:14.000000000 +1000
@@ -27,13 +27,13 @@
  #include <linux/efi.h>
  #include <linux/interrupt.h>
  #include <linux/delay.h>
+#include <linux/page_table.h>

  #include <asm/cpu.h>
  #include <asm/delay.h>
  #include <asm/elf.h>
  #include <asm/ia32.h>
  #include <asm/irq.h>
-#include <asm/pgalloc.h>
  #include <asm/processor.h>
  #include <asm/sal.h>
  #include <asm/tlbflush.h>
Index: linux-2.6.12-rc4/arch/ia64/kernel/smp.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/kernel/smp.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/kernel/smp.c	2005-05-19 
18:36:14.000000000 +1000
@@ -30,6 +30,7 @@
  #include <linux/delay.h>
  #include <linux/efi.h>
  #include <linux/bitops.h>
+#include <linux/page_table.h>

  #include <asm/atomic.h>
  #include <asm/current.h>
@@ -38,8 +39,6 @@
  #include <asm/io.h>
  #include <asm/irq.h>
  #include <asm/page.h>
-#include <asm/pgalloc.h>
-#include <asm/pgtable.h>
  #include <asm/processor.h>
  #include <asm/ptrace.h>
  #include <asm/sal.h>
Index: linux-2.6.12-rc4/arch/ia64/kernel/smpboot.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/kernel/smpboot.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/kernel/smpboot.c	2005-05-19 
18:36:14.000000000 +1000
@@ -41,6 +41,7 @@
  #include <linux/efi.h>
  #include <linux/percpu.h>
  #include <linux/bitops.h>
+#include <linux/page_table.h>

  #include <asm/atomic.h>
  #include <asm/cache.h>
@@ -52,8 +53,6 @@
  #include <asm/machvec.h>
  #include <asm/mca.h>
  #include <asm/page.h>
-#include <asm/pgalloc.h>
-#include <asm/pgtable.h>
  #include <asm/processor.h>
  #include <asm/ptrace.h>
  #include <asm/sal.h>
Index: linux-2.6.12-rc4/arch/ia64/mm/contig.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/mm/contig.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/mm/contig.c	2005-05-19 
18:36:14.000000000 +1000
@@ -19,10 +19,9 @@
  #include <linux/efi.h>
  #include <linux/mm.h>
  #include <linux/swap.h>
+#include <linux/page_table.h>

  #include <asm/meminit.h>
-#include <asm/pgalloc.h>
-#include <asm/pgtable.h>
  #include <asm/sections.h>
  #include <asm/mca.h>

@@ -61,8 +60,10 @@
  	printk("%d reserved pages\n", reserved);
  	printk("%d pages shared\n", shared);
  	printk("%d pages swap cached\n", cached);
+#ifdef CONFIG_MLPT
  	printk("%ld pages in page table cache\n",
  		pgtable_quicklist_total_size());
+#endif
  }

  /* physical address where the bootmem map is located */
Index: linux-2.6.12-rc4/arch/ia64/mm/discontig.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/mm/discontig.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/mm/discontig.c	2005-05-19 
18:36:14.000000000 +1000
@@ -21,7 +21,7 @@
  #include <linux/acpi.h>
  #include <linux/efi.h>
  #include <linux/nodemask.h>
-#include <asm/pgalloc.h>
+#include <linux/page_table.h>
  #include <asm/tlb.h>
  #include <asm/meminit.h>
  #include <asm/numa.h>
Index: linux-2.6.12-rc4/arch/ia64/mm/tlb.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/mm/tlb.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/mm/tlb.c	2005-05-19 18:36:14.000000000 
+1000
@@ -16,10 +16,10 @@
  #include <linux/sched.h>
  #include <linux/smp.h>
  #include <linux/mm.h>
+#include <linux/page_table.h>

  #include <asm/delay.h>
  #include <asm/mmu_context.h>
-#include <asm/pgalloc.h>
  #include <asm/pal.h>
  #include <asm/tlbflush.h>

Index: linux-2.6.12-rc4/include/asm-ia64/tlb.h
===================================================================
--- linux-2.6.12-rc4.orig/include/asm-ia64/tlb.h	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/include/asm-ia64/tlb.h	2005-05-19 
18:36:14.000000000 +1000
@@ -224,22 +224,8 @@
  	__tlb_remove_tlb_entry(tlb, ptep, addr);	\
  } while (0)

-#define pte_free_tlb(tlb, ptep)				\
-do {							\
-	tlb->need_flush = 1;				\
-	__pte_free_tlb(tlb, ptep);			\
-} while (0)
-
-#define pmd_free_tlb(tlb, ptep)				\
-do {							\
-	tlb->need_flush = 1;				\
-	__pmd_free_tlb(tlb, ptep);			\
-} while (0)
-
-#define pud_free_tlb(tlb, pudp)				\
-do {							\
-	tlb->need_flush = 1;				\
-	__pud_free_tlb(tlb, pudp);			\
-} while (0)
+#ifdef CONFIG_MLPT
+#include <asm-generic/tlb-mlpt.h>
+#endif

  #endif /* _ASM_IA64_TLB_H */
Index: linux-2.6.12-rc4/arch/ia64/sn/kernel/sn2/cache.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/sn/kernel/sn2/cache.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/sn/kernel/sn2/cache.c	2005-05-19 
18:36:14.000000000 +1000
@@ -7,7 +7,6 @@
   *
   */
  #include <linux/module.h>
-#include <asm/pgalloc.h>

  /**
   * sn_flush_all_caches - flush a range of address from all caches (incl. 
L4)
Index: linux-2.6.12-rc4/arch/ia64/mm/fixed-mlpt/mlpt-ia64.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/mm/fixed-mlpt/mlpt-ia64.c	2005-05-19 
18:32:00.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/mm/fixed-mlpt/mlpt-ia64.c	2005-05-19 
18:36:14.000000000 +1000
@@ -1 +1,83 @@
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/init.h>

+#include <linux/bootmem.h>
+#include <linux/efi.h>
+#include <linux/elf.h>
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/module.h>
+#include <linux/personality.h>
+#include <linux/reboot.h>
+#include <linux/slab.h>
+#include <linux/swap.h>
+#include <linux/proc_fs.h>
+#include <linux/bitops.h>
+#include <linux/page_table.h>
+
+#include <asm/a.out.h>
+#include <asm/dma.h>
+#include <asm/ia32.h>
+#include <asm/io.h>
+#include <asm/machvec.h>
+#include <asm/numa.h>
+#include <asm/patch.h>
+#include <asm/sal.h>
+#include <asm/sections.h>
+#include <asm/system.h>
+#include <asm/tlb.h>
+#include <asm/uaccess.h>
+#include <asm/unistd.h>
+#include <asm/mca.h>
+
+DEFINE_PER_CPU(unsigned long *, __pgtable_quicklist);
+DEFINE_PER_CPU(long, __pgtable_quicklist_size);
+
+#define MIN_PGT_PAGES			25UL
+#define MAX_PGT_FREES_PER_PASS		16L
+#define PGT_FRACTION_OF_NODE_MEM	16
+
+static inline long
+max_pgt_pages(void)
+{
+	u64 node_free_pages, max_pgt_pages;
+
+#ifndef	CONFIG_NUMA
+	node_free_pages = nr_free_pages();
+#else
+	node_free_pages = nr_free_pages_pgdat(NODE_DATA(numa_node_id()));
+#endif
+	max_pgt_pages = node_free_pages / PGT_FRACTION_OF_NODE_MEM;
+	max_pgt_pages = max(max_pgt_pages, MIN_PGT_PAGES);
+	return max_pgt_pages;
+}
+
+static inline long
+min_pages_to_free(void)
+{
+	long pages_to_free;
+
+	pages_to_free = pgtable_quicklist_size - max_pgt_pages();
+	pages_to_free = min(pages_to_free, MAX_PGT_FREES_PER_PASS);
+	return pages_to_free;
+}
+
+void
+check_pgt_cache(void)
+{
+	long pages_to_free;
+
+	if (unlikely(pgtable_quicklist_size <= MIN_PGT_PAGES))
+		return;
+
+	preempt_disable();
+	while (unlikely((pages_to_free = min_pages_to_free()) > 0)) {
+		while (pages_to_free--) {
+			free_page((unsigned 
long)pgtable_quicklist_alloc());
+		}
+		preempt_enable();
+		preempt_disable();
+	}
+	preempt_enable();
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
