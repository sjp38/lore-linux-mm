Received: from sgi.com (sgi.SGI.COM [192.48.153.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA02931
	for <Linux-MM@kvack.org>; Mon, 22 Feb 1999 16:24:52 -0500
Date: Mon, 22 Feb 1999 13:18:47 -0800
From: kanoj@kulten.engr.sgi.com (Kanoj Sarcar)
Message-Id: <9902221318.ZM2584@kulten.engr.sgi.com>
Subject: ia32 vmalloc patch
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Linux-MM@kvack.org, linux-kernel@vger.rutgers.edu
Cc: kanoj@kulten.engr.sgi.com
List-ID: <linux-mm.kvack.org>

I have a 2.2.1 patch for the ia32 specific vmalloc implementation, that
obviates the need for scanning all process page directories when a new
kernel page table has to be allocated, by allocating the maximum possible
number of page tables at start up.

Previous discussions of this are at
http://humbolt.nl.linux.org/lists/linux-mm/1999-02/msg00040.html

I ran tests on UP and MP systems with varying amounts of memory to test
the basic working of the patch. I also ran AIM7 on a 4cpu 1200M machine.
The result:
regular 2.2.1 kernel - Peak 1834.7, Sustained 1527.4
patched 2.2.1 kernel - Peak 1926.2, Sustained 1546.8

which is about a 5% improvement in the peak rate.

The patch limits the amount of vmalloc memory for ia32 systems to
VMALLOC_RESERVE (64Mb) on all memory configurations - note that big
memory systems ( ~960 Mb physical, 3Gb user space) already are
constrained to somewhat less than 64Mb vmalloc space.

Could people please try out the patch and let me know of problems/
improvements? I am a newbie to the Linux/open source environment, so
I would appreciate any help with getting the code into the development
tree if there is a perceived benefit.

Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a00Hc5/setup.c     Wed Feb 17 12:56:09 1999
+++ arch/i386/kernel/setup.c    Wed Feb 17 13:35:43 1999
@@ -39,6 +39,7 @@
 #include <asm/io.h>
 #include <asm/smp.h>
 #include <asm/cobalt.h>
+#include <asm/pgtable.h>

 /*
  * Machine setup..
@@ -327,7 +328,6 @@
        *to = '\0';
        *cmdline_p = command_line;

-#define VMALLOC_RESERVE        (64 << 20)      /* 64MB for vmalloc */
 #define MAXMEM ((unsigned long)(-PAGE_OFFSET-VMALLOC_RESERVE))

        if (memory_end > MAXMEM)
--- /usr/tmp/p_rdiff_a00HeX/init.c      Wed Feb 17 12:56:48 1999
+++ arch/i386/mm/init.c Wed Feb 17 13:35:52 1999
@@ -31,12 +31,6 @@
 extern void show_net_buffers(void);
 extern unsigned long init_smp_mappings(unsigned long);

-void __bad_pte_kernel(pmd_t *pmd)
-{
-       printk("Bad pmd in pte_alloc: %08lx\n", pmd_val(*pmd));
-       pmd_val(*pmd) = _KERNPG_TABLE + __pa(BAD_PAGETABLE);
-}
-
 void __bad_pte(pmd_t *pmd)
 {
        printk("Bad pmd in pte_alloc: %08lx\n", pmd_val(*pmd));
@@ -43,28 +37,6 @@
        pmd_val(*pmd) = _PAGE_TABLE + __pa(BAD_PAGETABLE);
 }

-pte_t *get_pte_kernel_slow(pmd_t *pmd, unsigned long offset)
-{
-       pte_t *pte;
-
-       pte = (pte_t *) __get_free_page(GFP_KERNEL);
-       if (pmd_none(*pmd)) {
-               if (pte) {
-                       clear_page((unsigned long)pte);
-                       pmd_val(*pmd) = _KERNPG_TABLE + __pa(pte);
-                       return pte + offset;
-               }
-               pmd_val(*pmd) = _KERNPG_TABLE + __pa(BAD_PAGETABLE);
-               return NULL;
-       }
-       free_page((unsigned long)pte);
-       if (pmd_bad(*pmd)) {
-               __bad_pte_kernel(pmd);
-               return NULL;
-       }
-       return (pte_t *) pmd_page(*pmd) + offset;
-}
-
 pte_t *get_pte_slow(pmd_t *pmd, unsigned long offset)
 {
        unsigned long pte;
@@ -211,7 +183,29 @@
 }

 /*
- * allocate page table(s) for compile-time fixed mappings
+ * allocate kernel page table(s) for vmalloc range, tlb flushed in
+ * paging_init (careful with 32 bit wraparound in while loop)
+ */
+static unsigned long __init kptbl_init(unsigned long start_mem)
+{
+       unsigned long address = VMALLOC_START;
+       pgd_t *dir = pgd_offset_k(address);
+
+       start_mem = PAGE_ALIGN(start_mem);
+       while ((address < VMALLOC_END) && (address >= VMALLOC_START)) {
+               memset((void *)start_mem, 0, PAGE_SIZE);
+               pgd_val(*dir) = _KERNPG_TABLE | __pa(start_mem);
+               address = (address + PGDIR_SIZE) & PGDIR_MASK;
+               dir++;
+               start_mem += PAGE_SIZE;
+       }
+       return start_mem;
+}
+
+/*
+ * allocate page table(s) for compile-time fixed mappings, taking
+ * care not to reallocate a page table if kptbl_init already
+ * allocated one.
  */
 static unsigned long __init fixmap_init(unsigned long start_mem)
 {
@@ -225,9 +219,11 @@
        {
                address = __fix_to_virt(__end_of_fixed_addresses-idx);
                pg_dir = swapper_pg_dir + (address >> PGDIR_SHIFT);
-               memset((void *)start_mem, 0, PAGE_SIZE);
-               pgd_val(*pg_dir) = _PAGE_TABLE | __pa(start_mem);
-               start_mem += PAGE_SIZE;
+               if (!pgd_val(*pg_dir)) {
+                       memset((void *)start_mem, 0, PAGE_SIZE);
+                       pgd_val(*pg_dir) = _PAGE_TABLE | __pa(start_mem);
+                       start_mem += PAGE_SIZE;
+               }
        }

        return start_mem;
@@ -336,6 +332,11 @@
                        address += PAGE_SIZE;
                }
        }
+
+       /* define VMALLOC_START */
+       high_memory = (void *) (end_mem & PAGE_MASK);
+       start_mem = kptbl_init(start_mem);
+
        start_mem = fixmap_init(start_mem);
 #ifdef __SMP__
        start_mem = init_smp_mappings(start_mem);
@@ -392,7 +393,6 @@
        unsigned long tmp;

        end_mem &= PAGE_MASK;
-       high_memory = (void *) end_mem;
        max_mapnr = num_physpages = MAP_NR(end_mem);

        /* clear the zero-page */
--- /usr/tmp/p_rdiff_a00Eew/pgtable.h   Wed Feb 17 12:58:37 1999
+++ include/asm-i386/pgtable.h  Wed Feb 17 13:35:36 1999
@@ -208,7 +208,9 @@
 #define VMALLOC_OFFSET (8*1024*1024)
 #define VMALLOC_START  (((unsigned long) high_memory + VMALLOC_OFFSET) &
~(VMALLOC_OFFSET-1))
 #define VMALLOC_VMADDR(x) ((unsigned long)(x))
-#define VMALLOC_END    (FIXADDR_START)
+#define VMALLOC_RESERVE        (64 << 20)
+#define VMALLOC_END    (((FIXADDR_START - VMALLOC_START) > (VMALLOC_RESERVE))
? \
+                               (VMALLOC_START + VMALLOC_RESERVE) :
(FIXADDR_START))

 /*
  * The 4MB page is guessing..  Detailed in the infamous "Chapter H"
@@ -438,7 +440,6 @@
 }

 extern pte_t *get_pte_slow(pmd_t *pmd, unsigned long address_preadjusted);
-extern pte_t *get_pte_kernel_slow(pmd_t *pmd, unsigned long
address_preadjusted);

 extern __inline__ pte_t *get_pte_fast(void)
 {
@@ -479,7 +480,6 @@
 }

 extern void __bad_pte(pmd_t *pmd);
-extern void __bad_pte_kernel(pmd_t *pmd);

 #define pte_free_kernel(pte)    free_pte_fast(pte)
 #define pte_free(pte)           free_pte_fast(pte)
@@ -489,18 +489,6 @@
 extern inline pte_t * pte_alloc_kernel(pmd_t * pmd, unsigned long address)
 {
        address = (address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
-       if (pmd_none(*pmd)) {
-               pte_t * page = (pte_t *) get_pte_fast();
-
-               if (!page)
-                       return get_pte_kernel_slow(pmd, address);
-               pmd_val(*pmd) = _KERNPG_TABLE + __pa(page);
-               return page + address;
-       }
-       if (pmd_bad(*pmd)) {
-               __bad_pte_kernel(pmd);
-               return NULL;
-       }
        return (pte_t *) pmd_page(*pmd) + address;
 }

@@ -545,32 +533,7 @@

 extern int do_check_pgt_cache(int, int);

-extern inline void set_pgdir(unsigned long address, pgd_t entry)
-{
-       struct task_struct * p;
-       pgd_t *pgd;
-#ifdef __SMP__
-       int i;
-#endif
-
-       read_lock(&tasklist_lock);
-       for_each_task(p) {
-               if (!p->mm)
-                       continue;
-               *pgd_offset(p->mm,address) = entry;
-       }
-       read_unlock(&tasklist_lock);
-#ifndef __SMP__
-       for (pgd = (pgd_t *)pgd_quicklist; pgd; pgd = (pgd_t *)*(unsigned long
*)pgd)
-               pgd[address >> PGDIR_SHIFT] = entry;
-#else
-       /* To pgd_alloc/pgd_free, one holds master kernel lock and so does our
callee, so we can
-          modify pgd caches of other CPUs as well. -jj */
-       for (i = 0; i < NR_CPUS; i++)
-               for (pgd = (pgd_t *)cpu_data[i].pgd_quick; pgd; pgd = (pgd_t
*)*(unsigned long *)pgd)
-                       pgd[address >> PGDIR_SHIFT] = entry;
-#endif
-}
+#define set_pgdir(addr, entry) do { } while (0)

 extern pgd_t swapper_pg_dir[1024];

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
