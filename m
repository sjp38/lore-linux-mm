Date: Sun, 5 May 2002 16:48:19 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] architecture-independand si_meminfo
Message-ID: <20020505164819.A20395@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Si_meminfo() is basically the same for all architectures (mips is a little
different by providing a value for the shared field that is different from
the originial intent, I will come back to this later), so it makes to have just
one instance of it:

--- 1.10/arch/alpha/mm/init.c	Fri May  3 14:10:15 2002
+++ edited/arch/alpha/mm/init.c	Sun May  5 16:56:26 2002
@@ -36,8 +36,6 @@
 
 mmu_gather_t mmu_gathers[NR_CPUS];
 
-unsigned long totalram_pages;
-
 extern void die_if_kernel(char *,struct pt_regs *,long);
 
 static struct pcb_struct original_pcb;
@@ -390,15 +388,3 @@
 	printk ("Freeing initrd memory: %ldk freed\n", (end - __start) >> 10);
 }
 #endif
-
-void
-si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh = 0;
-	val->mem_unit = PAGE_SIZE;
-}
--- 1.3/arch/alpha/mm/numa.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/alpha/mm/numa.c	Sun May  5 16:58:06 2002
@@ -358,7 +358,6 @@
 	extern int page_is_ram(unsigned long) __init;
 	extern char _text, _etext, _data, _edata;
 	extern char __init_begin, __init_end;
-	extern unsigned long totalram_pages;
 	unsigned long nid, i;
 	mem_map_t * lmem_map;
 
--- 1.10/arch/arm/mm/init.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/arm/mm/init.c	Sun May  5 16:56:29 2002
@@ -48,7 +48,6 @@
 
 #define TABLE_SIZE	((TABLE_OFFSET + PTRS_PER_PTE) * sizeof(pte_t))
 
-static unsigned long totalram_pages;
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern char _stext, _text, _etext, _end, __init_begin, __init_end;
 
@@ -631,14 +630,3 @@
 
 __setup("keepinitrd", keepinitrd_setup);
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram  = totalram_pages;
-	val->sharedram = 0;
-	val->freeram   = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh  = 0;
-	val->mem_unit  = PAGE_SIZE;
-}
--- 1.7/arch/cris/mm/init.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/cris/mm/init.c	Sun May  5 16:57:40 2002
@@ -114,8 +114,6 @@
 #include <asm/io.h>
 #include <asm/mmu_context.h>
 
-static unsigned long totalram_pages;
-
 struct pgtable_cache_struct quicklists;  /* see asm/pgalloc.h */
 
 const char bad_pmd_string[] = "Bad pmd in pte_alloc: %08lx\n";
@@ -470,16 +468,4 @@
         }
         printk ("Freeing unused kernel memory: %luk freed\n", 
 		(&__init_end - &__init_begin) >> 10);
-}
-
-void 
-si_meminfo(struct sysinfo *val)
-{
-        val->totalram = totalram_pages;
-        val->sharedram = 0;
-        val->freeram = nr_free_pages();
-        val->bufferram = atomic_read(&buffermem_pages);
-        val->totalhigh = 0;
-        val->freehigh = 0;
-        val->mem_unit = PAGE_SIZE;
 }
--- 1.14/arch/i386/mm/init.c	Fri May  3 14:25:13 2002
+++ edited/arch/i386/mm/init.c	Sun May  5 16:56:11 2002
@@ -41,8 +41,6 @@
 
 mmu_gather_t mmu_gathers[NR_CPUS];
 unsigned long highstart_pfn, highend_pfn;
-static unsigned long totalram_pages;
-static unsigned long totalhigh_pages;
 
 /*
  * NOTE: pagetable_init alloc all the fixmap pagetables contiguous on the
@@ -560,18 +558,6 @@
 	}
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = totalhigh_pages;
-	val->freehigh = nr_free_highpages();
-	val->mem_unit = PAGE_SIZE;
-	return;
-}
 
 #if defined(CONFIG_X86_PAE)
 static struct kmem_cache_s *pae_pgd_cachep;
--- 1.13/arch/ia64/mm/init.c	Fri May  3 14:27:24 2002
+++ edited/arch/ia64/mm/init.c	Sun May  5 16:56:48 2002
@@ -36,8 +36,6 @@
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
-static unsigned long totalram_pages;
-
 static int pgt_cache_water[2] = { 25, 50 };
 
 void
@@ -156,19 +154,6 @@
 		__free_page(page);
 		++totalram_pages;
 	}
-}
-
-void
-si_meminfo (struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh = 0;
-	val->mem_unit = PAGE_SIZE;
-	return;
 }
 
 void
--- 1.4/arch/m68k/mm/init.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/m68k/mm/init.c	Sun May  5 16:56:52 2002
@@ -35,8 +35,6 @@
 
 mmu_gather_t mmu_gathers[NR_CPUS];
 
-unsigned long totalram_pages = 0;
-
 int do_check_pgt_cache(int low, int high)
 {
 	int freed = 0;
@@ -202,18 +200,3 @@
 	printk ("Freeing initrd memory: %dk freed\n", pages);
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-    unsigned long i;
-
-    i = max_mapnr;
-    val->totalram = totalram_pages;
-    val->sharedram = 0;
-    val->freeram = nr_free_pages();
-    val->bufferram = atomic_read(&buffermem_pages);
-    val->totalhigh = 0;
-    val->freehigh = 0;
-    val->mem_unit = PAGE_SIZE;
-    return;
-}
--- 1.2/arch/m68k/mm/motorola.c	Tue Feb  5 08:39:13 2002
+++ edited/arch/m68k/mm/motorola.c	Sun May  5 16:58:26 2002
@@ -286,7 +286,6 @@
 }
 
 extern char __init_begin, __init_end;
-extern unsigned long totalram_pages;
 
 void free_initmem(void)
 {
--- 1.3/arch/mips/mm/init.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/mips/mm/init.c	Sun May  5 16:57:00 2002
@@ -45,8 +45,6 @@
 
 mmu_gather_t mmu_gathers[NR_CPUS];
 
-static unsigned long totalram_pages;
-
 extern void prom_free_prom_memory(void);
 
 
@@ -264,17 +262,4 @@
 	}
 	printk("Freeing unused kernel memory: %dk freed\n",
 	       (&__init_end - &__init_begin) >> 10);
-}
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = atomic_read(&shmem_nrpages);
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh = nr_free_highpages();
-	val->mem_unit = PAGE_SIZE;
-
-	return;
 }
--- 1.3/arch/mips64/mm/init.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/mips64/mm/init.c	Sun May  5 16:56:54 2002
@@ -40,8 +40,6 @@
 
 mmu_gather_t mmu_gathers[NR_CPUS];
 
-unsigned long totalram_pages;
-
 void pgd_init(unsigned long page)
 {
 	unsigned long *p, *end;
@@ -457,18 +455,4 @@
 	}
 	printk("Freeing unused kernel memory: %ldk freed\n",
 	       (&__init_end - &__init_begin) >> 10);
-}
-
-void
-si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = atomic_read(&shmem_nrpages);
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh = nr_free_highpages();
-	val->mem_unit = PAGE_SIZE;
-
-	return;
 }
--- 1.2/arch/mips64/sgi-ip27/ip27-memory.c	Tue Feb  5 08:45:04 2002
+++ edited/arch/mips64/sgi-ip27/ip27-memory.c	Sun May  5 16:58:52 2002
@@ -265,7 +265,6 @@
 {
 	extern char _stext, _etext, _fdata, _edata;
 	extern char __init_begin, __init_end;
-	extern unsigned long totalram_pages;
 	extern unsigned long setup_zero_pages(void);
 	cnodeid_t nid;
 	unsigned long tmp;
--- 1.2/arch/parisc/mm/init.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/parisc/mm/init.c	Sun May  5 16:57:02 2002
@@ -20,7 +20,6 @@
 
 #include <asm/pgalloc.h>
 
-static unsigned long totalram_pages;
 extern unsigned long max_pfn, mem_max;
 
 void free_initmem(void)  {
@@ -451,29 +450,3 @@
 #endif
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-	int i;
-
-	i = max_mapnr;
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-#if 0
-	while (i-- > 0)  {
-		if (PageReserved(mem_map+i))
-			continue;
-		val->totalram++;
-		if (!atomic_read(&mem_map[i].count))
-			continue;
-		val->sharedram += atomic_read(&mem_map[i].count) - 1;
-	}
-	val->totalram <<= PAGE_SHIFT;
-	val->sharedram <<= PAGE_SHIFT;
-#endif
-	val->totalhigh = 0;
-	val->freehigh = 0;
-	return;
-}
--- 1.15/arch/ppc/mm/init.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/ppc/mm/init.c	Sun May  5 16:57:08 2002
@@ -70,8 +70,6 @@
 int mem_init_done;
 int init_bootmem_done;
 int boot_mapsize;
-unsigned long totalram_pages;
-unsigned long totalhigh_pages;
 #ifdef CONFIG_ALL_PPC
 unsigned long agp_special_page;
 #endif
@@ -143,17 +141,6 @@
 	printk("%d pages shared\n",shared);
 	printk("%d pages swap cached\n",cached);
 	printk("%ld buffermem pages\n", nr_buffermem_pages());
-}
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = totalhigh_pages;
-	val->freehigh = nr_free_highpages();
-	val->mem_unit = PAGE_SIZE;
 }
 
 /* Free up now-unused memory */
--- 1.12/arch/ppc64/mm/init.c	Fri May  3 14:30:02 2002
+++ edited/arch/ppc64/mm/init.c	Sun May  5 16:57:05 2002
@@ -73,7 +73,6 @@
 unsigned long ioremap_bot = IMALLOC_BASE;
 
 static int boot_mapsize;
-static unsigned long totalram_pages;
 
 extern pgd_t swapper_pg_dir[];
 extern char __init_begin, __init_end;
@@ -136,17 +135,6 @@
 	printk("%d pages shared\n",shared);
 	printk("%d pages swap cached\n",cached);
 	printk("%ld buffermem pages\n", nr_buffermem_pages());
-}
-
-void si_meminfo(struct sysinfo *val)
-{
- 	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh = 0;
-	val->mem_unit = PAGE_SIZE;
 }
 
 void *
--- 1.8/arch/s390/mm/init.c	Fri May  3 15:31:18 2002
+++ edited/arch/s390/mm/init.c	Sun May  5 16:57:11 2002
@@ -39,8 +39,6 @@
 
 mmu_gather_t mmu_gathers[NR_CPUS];
 
-static unsigned long totalram_pages;
-
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((__aligned__(PAGE_SIZE)));
 char  empty_zero_page[PAGE_SIZE] __attribute__((__aligned__(PAGE_SIZE)));
 
@@ -230,14 +228,3 @@
         }
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh = 0;
-	val->mem_unit = PAGE_SIZE;
-}
--- 1.8/arch/s390x/mm/init.c	Fri May  3 15:33:47 2002
+++ edited/arch/s390x/mm/init.c	Sun May  5 16:57:16 2002
@@ -39,8 +39,6 @@
 
 mmu_gather_t mmu_gathers[NR_CPUS];
 
-static unsigned long totalram_pages;
-
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((__aligned__(PAGE_SIZE)));
 char  empty_zero_page[PAGE_SIZE] __attribute__((__aligned__(PAGE_SIZE)));
 
@@ -242,17 +240,6 @@
 	}
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-        val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh = 0;
-	val->mem_unit = PAGE_SIZE;
-}
 
 /*
  * Overrides for Emacs so that we follow Linus's tabbing style.
--- 1.7/arch/sh/mm/init.c	Tue Apr 30 00:18:45 2002
+++ edited/arch/sh/mm/init.c	Sun May  5 16:57:20 2002
@@ -48,9 +48,6 @@
 bootmem_data_t discontig_node_bdata[NR_NODES];
 #endif
 
-static unsigned long totalram_pages;
-static unsigned long totalhigh_pages;
-
 void show_mem(void)
 {
 	int i, total = 0, reserved = 0;
@@ -203,15 +200,3 @@
 	printk ("Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = totalhigh_pages;
-	val->freehigh = nr_free_highpages();
-	val->mem_unit = PAGE_SIZE;
-	return;
-}
--- 1.6/arch/sparc/kernel/sun4d_smp.c	Fri Mar 22 06:48:14 2002
+++ edited/arch/sparc/kernel/sun4d_smp.c	Sun May  5 16:59:10 2002
@@ -63,8 +63,6 @@
 extern volatile int smp_commenced;
 extern int __smp4d_processor_id(void);
 
-extern unsigned long totalram_pages;
-
 /* #define SMP_DEBUG */
 
 #ifdef SMP_DEBUG
--- 1.5/arch/sparc/kernel/sun4m_smp.c	Sat Mar 16 00:12:06 2002
+++ edited/arch/sparc/kernel/sun4m_smp.c	Sun May  5 16:59:15 2002
@@ -59,8 +59,6 @@
 extern volatile int smp_commenced;
 extern int __smp4m_processor_id(void);
 
-extern unsigned long totalram_pages;
-
 /*#define SMP_DEBUG*/
 
 #ifdef SMP_DEBUG
--- 1.10/arch/sparc/mm/init.c	Wed May  1 19:39:53 2002
+++ edited/arch/sparc/mm/init.c	Sun May  5 16:57:30 2002
@@ -55,8 +55,6 @@
 extern unsigned int sparc_ramdisk_size;
 
 unsigned long highstart_pfn, highend_pfn;
-unsigned long totalram_pages;
-unsigned long totalhigh_pages;
 
 pte_t *kmap_pte;
 pgprot_t kmap_prot;
@@ -504,18 +502,6 @@
 	}
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = totalhigh_pages;
-	val->freehigh = nr_free_highpages();
-
-	val->mem_unit = PAGE_SIZE;
-}
 
 void flush_page_to_ram(struct page *page)
 {
--- 1.14/arch/sparc/mm/srmmu.c	Fri May  3 14:51:41 2002
+++ edited/arch/sparc/mm/srmmu.c	Sun May  5 17:00:12 2002
@@ -1105,7 +1105,6 @@
 extern void sparc_context_init(int);
 
 extern int linux_num_cpus;
-extern unsigned long totalhigh_pages;
 
 void (*poke_srmmu)(void) __initdata = NULL;
 
--- 1.25/arch/sparc64/mm/init.c	Fri May  3 13:27:09 2002
+++ edited/arch/sparc64/mm/init.c	Sun May  5 16:57:23 2002
@@ -1790,17 +1790,3 @@
 	}
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram = num_physpages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-
-	/* These are always zero on Sparc64. */
-	val->totalhigh = 0;
-	val->freehigh = 0;
-
-	val->mem_unit = PAGE_SIZE;
-}
--- 1.5/arch/x86_64/mm/init.c	Fri May  3 14:52:23 2002
+++ edited/arch/x86_64/mm/init.c	Sun May  5 16:57:33 2002
@@ -39,8 +39,6 @@
 
 mmu_gather_t mmu_gathers[NR_CPUS];
 
-static unsigned long totalram_pages;
-
 /*
  * NOTE: pagetable_init alloc all the fixmap pagetables contiguous on the
  * physical space so we can cache the place of the first one and move
@@ -385,15 +383,3 @@
 	}
 }
 #endif
-
-void si_meminfo(struct sysinfo *val)
-{
-	val->totalram = totalram_pages;
-	val->sharedram = 0;
-	val->freeram = nr_free_pages();
-	val->bufferram = atomic_read(&buffermem_pages);
-	val->totalhigh = 0;
-	val->freehigh = nr_free_highpages();
-	val->mem_unit = PAGE_SIZE;
-	return;
-}
--- 1.41/include/linux/swap.h	Tue Apr 30 22:53:23 2002
+++ edited/include/linux/swap.h	Sun May  5 16:55:39 2002
@@ -96,6 +96,8 @@
 /* Swap 50% full? Release swapcache more aggressively.. */
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
+extern unsigned long totalram_pages;
+extern unsigned long totalhigh_pages;
 extern unsigned int nr_free_pages(void);
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
--- 1.55/mm/page_alloc.c	Fri May  3 13:27:09 2002
+++ edited/mm/page_alloc.c	Sun May  5 16:56:08 2002
@@ -23,6 +23,8 @@
 #include <linux/compiler.h>
 #include <linux/module.h>
 
+unsigned long totalram_pages;
+unsigned long totalhigh_pages;
 int nr_swap_pages;
 int nr_active_pages;
 int nr_inactive_pages;
@@ -601,6 +603,22 @@
 
 	get_page_state(&ps);
 	return ps.nr_pagecache;
+}
+
+void si_meminfo(struct sysinfo *val)
+{
+	val->totalram = totalram_pages;
+	val->sharedram = 0;
+	val->freeram = nr_free_pages();
+	val->bufferram = atomic_read(&buffermem_pages);
+#ifdef CONFIG_HIGHMEM
+	val->totalhigh = totalhigh_pages;
+	val->freehigh = nr_free_highpages();
+#else
+	val->totalhigh = 0;
+	val->freehigh = 0;
+#endif
+	val->mem_unit = PAGE_SIZE;
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
