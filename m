Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0AD366B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 21:02:04 -0400 (EDT)
Message-ID: <4A7393D9.50807@redhat.com>
Date: Fri, 31 Jul 2009 21:01:13 -0400
From: Jim Paradis <jparadis@redhat.com>
MIME-Version: 1.0
Subject: [PATCH 2/2] Dirty page tracking & on-the-fly memory mirroring
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


This patch is a reference implementation of a memory-mirroring module
("pagesync").  It is the same code that Stratus uses minus some
hardware-specific bits.  This module scans through physical memory,
clearing the hardware dirty bit of any dirty page and setting the
software dirty bit.  If a dirty page has the *hardware* dirty bit
set on a subsequent scan, we know that the page has been re-dirtied
and it is a candidate for being copied again.

This code is invoked through this API:

    struct pagesync_page_range {
        unsigned int start;
        unsigned int num;
    }

    typedef int (*copy_proc)(unsigned long start_pfn,
                unsigned long count,
                int blackout, void *context);

    typedef int (*sync_proc)(int max_range,
                 struct pagesync_page_range *copy_range,
                 void *context);

    int pagesync_synchronize_memory(copy_proc copy, sync_proc sync,
                unsigned int threshold,
                unsigned int passes,
                void *context)

The "copy" and "sync" functions are system-specific and supplied by the
caller.  The "copy" function copies a range of memory from the current
node to the destination node, while the "sync" function does final
cleanups and cuts over to the new node.



 Kconfig               |   12
 mm/Makefile           |    4
 mm/init_32.c          |    2
 mm/pagesync.h         |   66 ++
 mm/pagesync_harvest.c | 1124 
++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/pagesync_harvest.h |   69 +++
 mm/pagesync_syncd.c   |  259 +++++++++++
 mm/pagesync_syncd.h   |  185 ++++++++
 8 files changed, 1721 insertions(+)

Signed-off-by: jparadis@redhat.com

diff -up linux-2.6-git-track/arch/x86/Kconfig.harvest 
linux-2.6-git-track/arch/x86/Kconfig
--- linux-2.6-git-track/arch/x86/Kconfig.harvest    2009-07-21 
13:52:56.000000000 -0400
+++ linux-2.6-git-track/arch/x86/Kconfig    2009-07-28 
16:54:36.000000000 -0400
@@ -1138,6 +1138,18 @@ config TRACK_DIRTY_PAGES
       memory to another system or node.  Most users will
       say n here.
 
+config PAGESYNC_HARVEST
+    tristate "Enable reference implementation of pagesync harvest code"
+    default n
+    depends on TRACK_DIRTY_PAGES && EXPERIMENTAL
+    ---help---
+      Turning this on builds a reference implementation of
+      a page-harvesting driver.  This driver makes use of
+      dirty page tracking to allow on-the-fly mirroring of
+      system memory.  This could be useful, for example, for
+      failing over to a spare module in a cluster configuration.
+      Most users will say n here.
+
 # Common NUMA Features
 config NUMA
     bool "Numa Memory Allocation and Scheduler Support"
diff -up linux-2.6-git-track/arch/x86/mm/init_32.c.harvest 
linux-2.6-git-track/arch/x86/mm/init_32.c
--- linux-2.6-git-track/arch/x86/mm/init_32.c.harvest    2009-07-21 
13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/init_32.c    2009-07-21 
18:30:57.000000000 -0400
@@ -1075,3 +1075,5 @@ int __init reserve_bootmem_generic(unsig
 {
     return reserve_bootmem(phys, len, flags);
 }
+
+EXPORT_SYMBOL_GPL(swapper_pg_dir);
diff -up linux-2.6-git-track/arch/x86/mm/Makefile.harvest 
linux-2.6-git-track/arch/x86/mm/Makefile
--- linux-2.6-git-track/arch/x86/mm/Makefile.harvest    2009-07-21 
13:52:56.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/Makefile    2009-07-21 
18:37:41.000000000 -0400
@@ -21,4 +21,8 @@ obj-$(CONFIG_K8_NUMA)        += k8topology_64.
 obj-$(CONFIG_ACPI_NUMA)        += srat_$(BITS).o
 obj-$(CONFIG_TRACK_DIRTY_PAGES)    += track.o
 
+obj-$(CONFIG_PAGESYNC_HARVEST) += pagesync.o
+
+pagesync-objs := pagesync_harvest.o pagesync_syncd.o
+
 obj-$(CONFIG_MEMTEST)        += memtest.o
diff -up linux-2.6-git-track/arch/x86/mm/pagesync_harvest.c.harvest 
linux-2.6-git-track/arch/x86/mm/pagesync_harvest.c
--- linux-2.6-git-track/arch/x86/mm/pagesync_harvest.c.harvest   
 2009-07-21 18:30:57.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/pagesync_harvest.c    2009-07-28 
12:30:58.000000000 -0400
@@ -0,0 +1,1123 @@
+/* Low-level routines for memory mirroring.  Tracks dirty pages and
+ * utilizes provided copy routine to transfer pages which have changed
+ * between harvest passes.
+ *
+ * Copyright (C) 2006, 2007, 2009 Stratus Technologies Bermuda Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  
02111-1307  USA
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/init.h>
+#include "pagesync_harvest.h"
+#include "pagesync_syncd.h"
+#include <linux/interrupt.h>
+#include <linux/mm.h>
+#include <linux/spinlock.h>
+#include <linux/sched.h>
+#include <linux/vmalloc.h>
+#include <asm/io.h>
+#include <asm/mm_track.h>
+#include <asm/tlbflush.h>
+#include <asm/pgtable.h>
+
+
+#ifdef CONFIG_TRACK_DIRTY_PAGES
+
+#if PAGETABLE_LEVELS <= 3
+static inline unsigned pud_index(unsigned long address)
+{
+    return 0;
+}
+#endif
+
+#if PAGETABLE_LEVELS < 3
+static inline unsigned long pmd_pfn(pmd_t pmd)
+{
+    return (pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT;
+}
+#endif
+
+
+
+#define DBGPRNT(lvl, args...)            \
+({                        \
+    if (lvl & dbgmask)            \
+        printk(args);            \
+})
+
+enum {
+    DBGLVL_NONE     = 0x00,
+    DBGLVL_HARVEST  = 0x01,
+    DBGLVL_BROWNOUT = 0x02,
+    DBGLVL_TIMER    = 0x04,
+};
+
+static int dbgmask = 0xff;
+
+/*
+ * Caller dirties a page for OS_DEBUG prints (ringbuffer).
+ * Provide that page here, so we can track it, as it will be
+ * dirtied on the way to the sync point.
+ */
+void *pagesync_scratch_page;
+EXPORT_SYMBOL(pagesync_scratch_page);
+static spinlock_t *pagesync_scratch_lock;
+EXPORT_SYMBOL(pagesync_scratch_lock);
+
+#define MAX_COPYRANGE    100    /* this is actually defined in cc/host.h */
+#define NEARBY        6
+enum {
+    IN_BROWNOUT = 0,
+    IN_BLACKOUT = 1,
+};
+
+struct pagesync_data {
+    unsigned long flags[NR_CPUS];
+    copy_proc copy;
+    sync_proc sync;
+    void *context;
+    int status;        /* return status from command inside blackout */
+    int max_range;        /* # of valid ranges in following CopyRange */
+    struct pagesync_page_range CopyRange[MAX_COPYRANGE];
+    unsigned long nearby;    /* insert merge tunable */
+    unsigned int  duration_in_ms;    /* blackout during */
+    unsigned long bitcnt;    /* number of bits find in last harvest */
+    int blackout;        /* 1 == blackout, 0 == brownout */
+    int pass;        /* # of times through harvest/process cycle */
+    int done;        /* 1 == done - time to leave */
+    unsigned int threshold;    /* number of dirty pages before sync */
+    atomic_t r;
+    atomic_t harvest_waiters;
+};
+
+struct blackout_data {
+    atomic_t r[5];
+    unsigned int oncpu;
+    unsigned long (*func)(void *);
+    void *arg;
+};
+
+static unsigned long idx_to_va(unsigned long pgd_idx,
+             unsigned long pud_idx,
+             unsigned long pmd_idx,
+             unsigned long pte_idx)
+{
+    unsigned long va =
+        (pgd_idx << PGDIR_SHIFT) +
+        (pud_idx << PUD_SHIFT)   +
+        (pmd_idx << PMD_SHIFT)   +
+        (pte_idx << PAGE_SHIFT);
+    static const unsigned long hole_mask =
+        ~((1UL << (__VIRTUAL_MASK_SHIFT - 1)) - 1);
+
+    if (va & hole_mask) {
+        /* Sign extend to canonical addr */
+        va |= hole_mask;
+    }
+    return  va;
+}
+
+static void harvest_table(pgd_t *pgd_base,
+              unsigned long start,
+              unsigned long end)
+{
+    unsigned long i, j, k, l;
+
+    pgd_t *pgd;
+
+    unsigned long pgd_start, pgd_end;
+    unsigned long pud_start, pud_end;
+    unsigned long pmd_start, pmd_end;
+    unsigned long pte_start, pte_end;
+
+    unsigned long pud_last;
+    unsigned long pmd_last;
+    unsigned long pte_last;
+
+    /*
+     * end marks the first byte after the upper limit of the address
+     * range
+     */
+    end--;
+
+    if (!pgd_base) {
+        printk("%s: null pgd?\n", __func__);
+        return;
+    }
+
+    pgd_start = pgd_index(start);
+    pgd_end = pgd_index(end);
+
+    pud_start = pud_index(start);
+    pud_end = pud_index(end);
+
+    pmd_start = pmd_index(start);
+    pmd_end = pmd_index(end);
+
+    pte_start = pte_index(start);
+    pte_end = pte_index(end);
+
+    pgd = pgd_base + pgd_start;
+
+    for (i = pgd_start; i <= pgd_end; i++, pgd++) {
+
+        pud_t *pud;
+
+        if (pgd_none(*pgd) || !pgd_present(*pgd))
+            continue;
+
+        if (i == pgd_start)
+            j = pud_start;
+        else
+            j = 0;
+
+        pud = pud_offset(pgd, 0) + j;
+
+        if (i == pgd_end)
+            pud_last = pud_end;
+        else
+            pud_last = PTRS_PER_PUD - 1;
+
+        for (; j <= pud_last; j++, pud++) {
+            pmd_t *pmd;
+            pud_t tmp_pud = *pud;
+
+            if (pud_none(tmp_pud) || !pud_present(tmp_pud))
+                continue;
+
+            if ((i == pgd_start) && (j == pud_start))
+                k = pmd_start;
+            else
+                k = 0;
+
+            pmd = pmd_offset(pud, 0) + k;
+
+            if ((i == pgd_end) && (j == pud_end))
+                pmd_last = pmd_end;
+            else
+                pmd_last = PTRS_PER_PMD - 1;
+
+            for (; k <= pmd_last; k++, pmd++) {
+                pte_t *pte;
+                pmd_t tmp_pmd = *pmd;
+
+                if (pmd_none(tmp_pmd) || !pmd_present(tmp_pmd))
+                    continue;
+
+                if (pmd_large(tmp_pmd)) {
+                    /*
+                     * Hardware may have flipped on the
+                     * ACCESSED bit.  If so,
+                     * track the pmd page itself.
+                     */
+                    if (pmd_val(tmp_pmd) & _PAGE_ACCESSED) {
+                        set_pmd(&tmp_pmd, __pmd(pmd_val(tmp_pmd) & 
~_PAGE_ACCESSED));
+                        mm_track_phys((void *) virt_to_phys(pmd));
+                    }
+                    if (pmd_val(tmp_pmd) & _PAGE_DIRTY)
+                        set_pmd(&tmp_pmd, __pmd((pmd_val(tmp_pmd) & 
~_PAGE_DIRTY) | _PAGE_SOFTDIRTY));
+                    if (pmd_val(tmp_pmd) != pmd_val(*pmd)) {
+                        set_pmd(pmd, tmp_pmd);
+                        __flush_tlb_one(idx_to_va(i, j, k, 0));
+                    }
+                    continue;
+                }
+
+                if ((i == pgd_start) && (j == pud_start) && (k == 
pmd_start))
+                    l = pte_start;
+                else
+                    l = 0;
+
+                pte = pte_offset_kernel(pmd, 0) + l;
+
+                if ((i == pgd_end) && (j == pud_end) && (k == pmd_end))
+                    pte_last = pte_end;
+                else
+                    pte_last = PTRS_PER_PTE - 1;
+
+                for (; l <= pte_last; l++, pte++) {
+
+                    pte_t tmp_pte = *pte;
+
+                    /*
+                     * Hardware may have flipped on the ACCESSED bit.  
If so,
+                     * track the pte page itself.
+                     */
+                    if (pte_val(tmp_pte) & _PAGE_ACCESSED) {
+                        set_pte(&tmp_pte, __pte(pte_val(tmp_pte) & 
~_PAGE_ACCESSED));
+                        mm_track_phys((void *) virt_to_phys(pte));
+                    }
+                    if (pte_val(tmp_pte) & _PAGE_DIRTY)
+                        set_pte(&tmp_pte, __pte((pte_val(tmp_pte) & 
~_PAGE_DIRTY) | _PAGE_SOFTDIRTY));
+
+                    if (pte_val(tmp_pte) != pte_val(*pte)) {
+                        set_pte(pte, tmp_pte);
+                        __flush_tlb_one(idx_to_va(i, j, k, l));
+                    }
+                }
+            }
+        }
+    }
+}
+
+static void harvest_mm(struct mm_struct *mm)
+{
+    struct vm_area_struct *mmap, *vma;
+
+    vma = mmap = mm->mmap;
+    if (!mmap)
+        return;
+
+    do {
+        unsigned long start, end;
+
+        if (!vma)
+            break;
+
+        start = vma->vm_start;
+        end   = vma->vm_end;
+
+        harvest_table(mm->pgd, start, end);
+
+    } while ((vma = vma->vm_next) != mmap);
+}
+
+static void harvest_user(void)
+{
+    struct task_struct *p;
+#ifdef CONFIG_SMP
+    int task_count = 0;
+    int this_cpu = smp_processor_id();
+    int num_cpus = num_online_cpus();
+#endif
+
+    for_each_process(p) {
+        struct mm_struct *mm = p->mm;
+
+#ifdef CONFIG_SMP
+        if (this_cpu != (task_count++ % num_cpus))
+            continue;
+#endif
+
+        if (!mm)
+            continue;
+
+        harvest_mm(mm);
+    }
+}
+
+static pgd_t *get_pgd(unsigned long address)
+{
+    pgd_t *pgd;
+
+#if PAGETABLE_LEVELS > 3
+    pgd = &init_level4_pgt[0];
+#else
+    pgd = &swapper_pg_dir[0];
+#endif
+    pgd += pgd_index(address);
+    if (!pgd_present(*pgd))
+        return NULL;
+
+    return pgd;
+}
+
+/*
+ * Difference or zero
+ *
+ *  d <- (x - y), x >= y
+ *        0    , x < y
+ */
+static unsigned long
+doz(unsigned long x, unsigned long y)
+{
+    if (x < y)
+        return 0;
+
+    return x - y;
+}
+
+/*
+ * Merge closest two regions to free up one slot in table.
+ */
+static int
+merge(struct pagesync_data *x)
+{
+    int i, ii;
+    unsigned long delta, ndelta;
+    unsigned long end;
+    struct pagesync_page_range *cr = x->CopyRange;
+
+    i = 0;
+    ii = ~0;
+    delta = ~0UL;
+    do {
+        end = cr[i].start + cr[i].num - 1;
+        ndelta = cr[i+1].start - end;
+
+        if (ndelta <= delta) {
+            delta = ndelta;
+            ii = i;
+        }
+    } while (i++ < (x->max_range - 1));
+
+    if (ii == ~0)
+        return 1;
+
+    cr[ii].num = (cr[ii+1].start + cr[ii+1].num) - cr[ii].start;
+
+    /* shift everyone down */
+    x->max_range--;
+    for (i = ii + 1; i < x->max_range; i++) {
+        cr[i].start = cr[i+1].start;
+        cr[i].num   = cr[i+1].num;
+    }
+
+    return 0;
+}
+
+static int
+insert_pfn(struct pagesync_data *x, unsigned long pfn)
+{
+    int i;
+    int ii;
+    struct pagesync_page_range *cr = x->CopyRange;
+    int nearby = x->nearby;
+
+ restart:
+    for (i = 0; i < x->max_range; i++) {
+        unsigned long start = cr[i].start;
+        unsigned long len   = cr[i].num;
+        unsigned long end   = start + len - 1;
+
+        /* inside current region: start <= pfn <= end */
+        if ((pfn - start) <= (len - 1))
+            return 0;
+
+        /* adjacent to start start-nearby <= pfn <= start */
+        if ((pfn - doz(start, nearby)) <= start - doz(start, nearby)) {
+            cr[i].num  += (cr[i].start - pfn);
+            cr[i].start = pfn;
+            return 0;
+        }
+
+        /* adjacent to end: end <= pfn <= end+nearby */
+        if ((pfn - end) <= nearby) {
+            cr[i].num += pfn - end;
+            end += pfn - end;
+ again:
+            if (i+1 == x->max_range)
+                return 0;
+
+            /* this range may overlap or abut next range */
+            /* after insert        (next.start - nearby) <= end */
+            if (doz(cr[i+1].start, nearby) <= end) {
+                cr[i].num = (cr[i+1].start + cr[i+1].num)
+                    - cr[i].start;
+                end = cr[i].start + cr[i].num - 1;
+
+                /* shift everyone down */
+                x->max_range--;
+                for (ii = i + 1; ii < x->max_range; ii++) {
+                    cr[ii].start = cr[ii+1].start;
+                    cr[ii].num   = cr[ii+1].num;
+                }
+                goto again;
+            }
+
+            return 0;
+        }
+
+        /* before region    pfn < start-nearby    - OR - */
+        /*            !at end of array    - AND - */
+        /* between regions    end+nearby < pfn < next.start-nearby */
+        if ((pfn < doz(start, nearby)) ||
+            ((i+1 == x->max_range) &&
+            ((end+nearby < pfn) &&
+             (pfn < doz(cr[i+1].start, nearby))))) {
+            if (x->max_range == MAX_COPYRANGE) {
+                if (merge(x))
+                    return 1;
+                goto restart;
+            }
+            /* shift everyone up to make room */
+            for (ii = x->max_range; ii > i; ii--) {
+                cr[ii].start = cr[ii-1].start;
+                cr[ii].num   = cr[ii-1].num;
+            }
+            if (pfn < doz(start, nearby))
+                ii = i;        /* before region */
+            else
+                ii = i + 1;    /* between regions */
+            cr[ii].start = pfn;
+            cr[ii].num = 1;
+            x->max_range++;
+            return 0;
+        }
+    }
+
+    if (x->max_range == MAX_COPYRANGE)
+        if (merge(x))
+            return 1;
+
+    /* append to array */
+    cr[x->max_range].start = pfn;
+    cr[x->max_range].num = 1;
+    x->max_range++;
+
+    return 0;
+}
+
+static unsigned long virt_to_pfn(void *addr)
+{
+    unsigned long phys = virt_to_phys(addr);
+    return phys >> PAGE_SHIFT;
+}
+
+static int add_stack_pages(struct pagesync_data *x, unsigned long *addr)
+{
+    unsigned long dummy;
+    unsigned long *stack;
+    unsigned long pfn, num_pfns;
+    int rc = 0;
+    unsigned long i;
+
+    stack = addr != NULL ? addr : &dummy;
+
+    pfn = (unsigned long)(virt_to_phys(stack) & ~(THREAD_SIZE - 1));
+    pfn >>= PAGE_SHIFT;
+    num_pfns = (THREAD_SIZE + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
+
+    for (i = 0; i < num_pfns; i++, pfn++) {
+        rc = insert_pfn(x, pfn);
+        if (rc)
+            return rc;
+    }
+
+    return 0;
+}
+
+/*
+ * With a fundamental knowledge of what absolutely MUST be copied
+ * by the HOST during blackout, add pfn's to the copy range list.
+ *
+ * All page tables are added to avoid having to deal with optimizing
+ * which ptes might be set dirty or accessed by the last few operations
+ * before blackout.
+ *
+ * After page tables, the remainder of the pages are our known "working
+ * set".  This includes the stack frames for this task and processor and
+ * the pagesync structure (which we are making dirty by compiling this 
list).
+ *
+ * Finally, all pages marked as dirty in their pte's are added to the
+ * list.  These are pages which escaped the harvest/process cycles and
+ * were presumably dirtied between harvest and here.
+ */
+static int setup_blackout_copylist(struct pagesync_data *x)
+{
+    pgd_t *pgd;
+
+    int i, j, k;
+    int n;
+
+    x->max_range = 0;
+
+    pgd = get_pgd(PAGE_OFFSET);
+
+    if (!pgd) {
+        printk(KERN_WARNING "%s: null pgd\n", __func__);
+        return PAGESYNC_ERR_MERGE_FAIL;
+    }
+
+    if (insert_pfn(x, virt_to_pfn(pgd)))
+        return PAGESYNC_ERR_MERGE_FAIL;
+
+    for (n = pgd_index(PAGE_OFFSET); n < PTRS_PER_PGD; n++, pgd++) {
+
+        pud_t *pud;
+
+        if (pgd_none(*pgd) || !pgd_present(*pgd))
+            continue;
+
+        pud = pud_offset(pgd, 0);
+
+        if (insert_pfn(x, virt_to_pfn(pud)))
+            return PAGESYNC_ERR_MERGE_FAIL;
+
+        for (i = 0; i < PTRS_PER_PUD; i++, pud++) {
+
+            pmd_t *pmd;
+
+            if (pud_none(*pud) || !pud_present(*pud))
+                continue;
+
+            pmd = pmd_offset(pud, 0);
+
+            if (insert_pfn(x, virt_to_pfn(pmd)))
+                return PAGESYNC_ERR_MERGE_FAIL;
+
+            for (j = 0; j < PTRS_PER_PMD; j++, pmd++) {
+
+                pte_t *pte;
+
+                if (pmd_none(*pmd) || !pmd_present(*pmd))
+                    continue;
+
+                if (pmd_large(*pmd)) {
+                    if ((pmd_val(*pmd) & _PAGE_DIRTY)) {
+                        unsigned long p, pfn = pmd_pfn(*pmd);
+                        for (p = 0; p < PTRS_PER_PTE; p++) {
+                            if (insert_pfn(x, pfn + p))
+                                return PAGESYNC_ERR_MERGE_FAIL;
+                        }
+                    }
+                    continue;
+                }
+
+                pte = pte_offset_kernel(pmd, 0);
+
+                if (insert_pfn(x, virt_to_pfn(pte)))
+                    return PAGESYNC_ERR_MERGE_FAIL;
+
+                for (k = 0; k < PTRS_PER_PTE; k++, pte++) {
+
+                    if (pte_none(*pte) || !pte_present(*pte))
+                        continue;
+
+                    if (pte_val(*pte) & _PAGE_DIRTY) {
+                        if (insert_pfn(x, pte_pfn(*pte)))
+                            return PAGESYNC_ERR_MERGE_FAIL;
+                    }
+                }
+            }
+        }
+    }
+
+    /* copy the stack we are working from */
+    if (add_stack_pages(x, NULL))
+        return PAGESYNC_ERR_MERGE_FAIL;
+
+    /* add pagesync structure */
+    if (insert_pfn(x, virt_to_pfn(x)))
+        return PAGESYNC_ERR_MERGE_FAIL;
+
+    /* add mm_tracking_struct (disable_tracking() dirtied it). */
+    if (insert_pfn(x, virt_to_pfn(&mm_tracking_struct)))
+        return PAGESYNC_ERR_MERGE_FAIL;
+
+    /*
+     * add the scratch page, in case the caller wants
+     * to dirty it on the way to sync.
+     */
+    if (insert_pfn(x, virt_to_pfn(pagesync_scratch_page)))
+        return PAGESYNC_ERR_MERGE_FAIL;
+
+    if (insert_pfn(x, virt_to_pfn(pagesync_scratch_lock)))
+        return PAGESYNC_ERR_MERGE_FAIL;
+
+    return PAGESYNC_ERR_OK;
+}
+
+static void harvest_kernel(void)
+{
+    unsigned long n, i, j, k;
+
+    pgd_t *pgd = get_pgd(PAGE_OFFSET);
+
+    if (!pgd) {
+        printk(KERN_WARNING "%s: null pgd\n", __func__);
+        return;
+    }
+
+    /* Skip addrs < PAGE_OFFSET */
+    for (n = pgd_index(PAGE_OFFSET); n < PTRS_PER_PGD; n++, pgd++) {
+        pud_t *pud;
+
+        if (pgd_none(*pgd) || !pgd_present(*pgd))
+            continue;
+
+        pud = pud_offset(pgd, 0);
+
+        if (!pud) {
+            printk(KERN_WARNING "%s: null pud?\n", __func__);
+            return;
+        }
+
+        for (i = 0; i < PTRS_PER_PUD; i++, pud++) {
+
+            pmd_t *pmd;
+
+            if (pud_none(*pud) || !pud_present(*pud))
+                continue;
+
+            pmd = pmd_offset(pud, 0);
+
+            for (j = 0; j < PTRS_PER_PMD; j++, pmd++) {
+                pte_t *pte;
+                pmd_t tmp_pmd = *pmd;
+
+                if (pmd_none(tmp_pmd) || !pmd_present(tmp_pmd))
+                    continue;
+
+                if (pmd_large(tmp_pmd)) {
+                    if (pmd_val(tmp_pmd) & _PAGE_DIRTY)
+                        set_pmd(&tmp_pmd, __pmd((pmd_val(tmp_pmd) & 
~_PAGE_DIRTY) | _PAGE_SOFTDIRTY));
+                    if (pmd_val(tmp_pmd) != pmd_val(*pmd)) {
+                        set_pmd(pmd, tmp_pmd);
+                        __flush_tlb_one(idx_to_va(n, i, j, 0));
+                        mm_track_phys((void *)virt_to_phys(pmd));
+                    }
+                    continue;
+                }
+
+                pte = pte_offset_kernel(pmd, 0);
+
+                for (k = 0; k < PTRS_PER_PTE; k++, pte++) {
+                    pte_t tmp_pte = *pte;
+
+                    if (pte_none(tmp_pte) || !pte_present(tmp_pte))
+                        continue;
+
+                    if (pte_val(tmp_pte) & _PAGE_DIRTY)
+                        set_pte(&tmp_pte, __pte((pte_val(tmp_pte) & 
~_PAGE_DIRTY) | _PAGE_SOFTDIRTY));
+
+                    if (pte_val(tmp_pte) != pte_val(*pte)) {
+                        set_pte(pte, tmp_pte);
+                        __flush_tlb_one(idx_to_va(n, i, j, k));
+                        mm_track_phys((void *) virt_to_phys(pte));
+                    }
+                }
+            }
+        }
+    }
+}
+
+static unsigned long harvest(void *arg)
+{
+#ifdef CONFIG_SMP
+    struct pagesync_data * x = (struct pagesync_data *) arg;
+#else
+    if (smp_processor_id() != 0)
+        return 0;
+#endif
+
+    harvest_user();
+
+#ifdef CONFIG_SMP
+    if (smp_processor_id() == 0)
+        atomic_set(&x->harvest_waiters, 0);
+
+    rendezvous(&x->r);
+
+    if (smp_processor_id() == 0) {
+        /* Wait for all other cpus to go to the next */
+        /* rendezvous (having also flushed their tlbs). */
+        while (atomic_read(&x->harvest_waiters) <
+                    num_online_cpus() - 1)
+            ; /* wait */
+        harvest_kernel();
+    }
+#else
+    harvest_kernel();
+#endif
+
+    return 0;
+}
+
+
+static void pagesync_blackout(void *arg, unsigned int numprocs)
+{
+    struct blackout_data * x = (struct blackout_data *) arg;
+    unsigned long flags;
+
+    rendezvous_sched(&x->r[0]);
+    local_bh_disable();
+    rendezvous(&x->r[1]);
+    local_irq_save(flags);
+    rendezvous(&x->r[2]);
+
+    (void)x->func(x->arg);
+
+    if (x->arg) {
+        struct pagesync_data *sdp = (struct pagesync_data *)(x->arg);
+        __flush_tlb_all();
+        atomic_inc(&sdp->harvest_waiters);
+    }
+
+    rendezvous(&x->r[3]);
+
+    local_irq_restore(flags);
+    local_bh_enable();
+}
+
+/*
+ * Call the specified function with the provided argument in
+ * during a blackout.
+ */
+static void pagesync_exec_onall(unsigned long (*func)(void *), void * arg)
+{
+    struct blackout_data x;
+
+    init_rendezvous(&x.r[0]);
+    init_rendezvous(&x.r[1]);
+    init_rendezvous(&x.r[2]);
+    init_rendezvous(&x.r[3]);
+    init_rendezvous(&x.r[4]);
+    x.oncpu = safe_smp_processor_id();
+    x.func  = func;
+    x.arg   = arg;
+
+    pagesync_syncd_start(pagesync_blackout, &x, 0);
+    pagesync_syncd_finish();
+}
+
+static void enable_tracking(void)
+{
+    /* initialize tracking structure */
+    atomic_set(&mm_tracking_struct.count, 0);
+    memset(mm_tracking_struct.vector, 0, mm_tracking_struct.bitcnt/8);
+
+    /* turn on tracking */
+    mm_tracking_struct.active = 1;
+}
+
+static void disable_tracking(void)
+{
+    /* turn off tracking */
+    mm_tracking_struct.active = 0;
+}
+
+static int is_in_copylist(struct pagesync_data *x, unsigned int pfn)
+{
+    int i;
+
+    for (i = 0; i < x->max_range; i++) {
+        unsigned int start = x->CopyRange[i].start;
+        unsigned int end = start + x->CopyRange[i].num;
+        if (pfn >= start && pfn < end)
+            return 1;
+    }
+
+    return 0;
+}
+
+static int bit_is_set(struct pagesync_data *x,
+              unsigned int pfn,
+              unsigned long *vector)
+{
+    if (!x->blackout)
+        return test_and_clear_bit(pfn, vector);
+
+    /*
+     * Optimization:  We are in blackout and we have already 
constructed the
+     * blackout copylist.  Any pages in there will be copied by the SMI
+     * handler (syncpoint).  So don't allow process vector to copy any of
+     * these pages or else they'll get copied twice.
+     */
+    if (is_in_copylist(x, pfn))
+        return 0;
+
+    return test_bit(pfn, vector);
+}
+
+static void process_vector(void *arg)
+{
+    struct pagesync_data * x = (struct pagesync_data *) arg;
+    unsigned long pfn;
+    unsigned long start_pfn, runlength;
+
+    /* traverse the the bitmap looking for dirty pages */
+    runlength = 0;
+    start_pfn = 0;
+
+    for (pfn = 0; pfn < mm_tracking_struct.bitcnt; pfn++) {
+        if (bit_is_set(x, pfn, mm_tracking_struct.vector)) {
+            if (!(x->blackout))
+                atomic_dec(&mm_tracking_struct.count);
+            if (runlength == 0)
+                start_pfn = pfn;
+            runlength++;
+        } else if (runlength) {
+            x->status = x->copy(start_pfn, runlength,
+                        x->blackout, x->context);
+            if (x->status != PAGESYNC_ERR_OK) {
+                printk(KERN_WARNING "%s: %d error (%d), start_pfn %lx, 
runlength %lx\n",
+                    __func__, __LINE__,
+                    x->status,
+                    start_pfn,
+                    runlength);
+                return;
+            }
+            start_pfn = runlength = 0;
+        }
+    }
+
+    /* Catch the last ones. */
+    if (runlength) {
+        x->status = x->copy(start_pfn, runlength,
+                    x->blackout, x->context);
+        if (x->status != PAGESYNC_ERR_OK) {
+            printk(KERN_WARNING "%s: %d\n", __func__, __LINE__);
+            return;
+        }
+    }
+}
+
+/*
+ * This is where all processors are sent for blackout processing.
+ * The driving processor is diverted to work on harvest and if necessary
+ * entry to Common Code for synchronization.  All other processors are
+ * spinning in a rendezvous at the bottom of this routine waiting for
+ * the driving processor to finish.
+ */
+static unsigned long brownout_cycle(void *arg)
+{
+    struct pagesync_data * x = (struct pagesync_data *) arg;
+
+#ifndef CONFIG_SMP
+    if (safe_smp_processor_id() != 0)
+        return 0;
+#endif
+
+    harvest_user();
+
+#ifdef CONFIG_SMP
+    if (safe_smp_processor_id() == 0)
+        atomic_set(&x->harvest_waiters, 0);
+
+    rendezvous(&x->r);
+
+    if (safe_smp_processor_id() != 0)
+        return 0;
+#endif
+
+    while (atomic_read(&x->harvest_waiters) < num_online_cpus() - 1)
+        ; /* Wait */
+
+    harvest_kernel();
+
+    x->bitcnt = atomic_read(&mm_tracking_struct.count);
+
+    if ((x->bitcnt < x->threshold) || (x->pass == 0)) {
+        x->blackout = IN_BLACKOUT;
+
+        disable_tracking();
+
+        x->status = setup_blackout_copylist(x);
+        if (x->status)
+            return 0;
+
+        process_vector(x);
+        if (x->status)
+            return PAGESYNC_ERR_COPY_FAIL;
+
+        x->status = x->sync(x->max_range,
+                    x->CopyRange,
+                    x->context);
+        x->done = 1;
+
+        if (x->status) {
+            printk(KERN_WARNING "%s: %d (%s)\n", __func__, __LINE__,
+                   PAGESYNC_ERR_STRING(x->status));
+        }
+
+        return 0;
+    }
+
+    return 0;
+}
+
+
+
+/*
+ * This routine is responsible for driving all of the memory
+ * synchronization processing.  When complete the sync function should
+ * be called to enter blackout and finalize synchronization.
+ */
+int pagesync_synchronize_memory(copy_proc copy,
+                 sync_proc sync,
+                 unsigned int threshold,
+                 unsigned int passes,
+                 void *context)
+{
+    int status;
+    struct pagesync_data *x;
+
+    x = kmalloc(sizeof(struct pagesync_data), GFP_KERNEL);
+    if (x == NULL) {
+        printk(KERN_WARNING "unable to allocate pagesync control 
structure\n");
+        return 1;
+    }
+
+    memset(x, 0, sizeof(struct pagesync_data));
+
+    x->copy = copy;
+    x->sync = sync;
+    x->bitcnt = 0;
+    x->blackout = IN_BROWNOUT;
+    x->done = 0;
+    x->threshold = threshold;
+    x->context = context;
+    x->nearby = NEARBY;
+
+    /* clean up hardware dirty bits */
+    init_rendezvous(&x->r);
+    pagesync_exec_onall(harvest, x);
+    enable_tracking();
+
+    /*
+     * Copy all memory.  After this we only copy modified
+     * pages, so we need to make sure the unchanged parts
+     * get copied at least once.
+     */
+    status = x->copy(0, ~0, 0, x->context);
+    if (status != PAGESYNC_ERR_OK) {
+        printk(KERN_WARNING "%s: %d\n", __func__, __LINE__);
+        goto pagesync_sync_out;
+    }
+
+
+    for (x->pass = passes; (x->pass >= 0); x->pass--) {
+        DBGPRNT(DBGLVL_BROWNOUT,
+            "brownout pass %d - %ld pages found (%d)\n",
+            x->pass, x->bitcnt,
+            atomic_read(&mm_tracking_struct.count));
+
+        init_rendezvous(&x->r);
+        pagesync_exec_onall(brownout_cycle, x);
+        if (x->status) {
+            printk(KERN_WARNING "%s(%d): brownout_cycle failed \n",
+                   __func__, __LINE__);
+            /* flush any incomplete transactions */
+            x->copy(~0, ~0, 0, x->context);
+            break;
+        }
+        if (x->done)
+            break;
+
+        /* Give back some time to everybody else */
+        schedule();
+
+        process_vector(x);
+        if (x->status) {
+            printk(KERN_WARNING "%s(%d): process_vector failed \n",
+                   __func__, __LINE__);
+            /* flush any incomplete transactions */
+            x->copy(~0, ~0, 0, x->context);
+            break;
+        }
+    }
+
+    disable_tracking();
+
+    DBGPRNT(DBGLVL_BROWNOUT, "last pass found %ld pages\n", x->bitcnt);
+    DBGPRNT(DBGLVL_BROWNOUT, "copy range max %d\n", x->max_range);
+
+    status = x->status;
+
+pagesync_sync_out:
+
+    kfree(x);
+
+    return status;
+}
+EXPORT_SYMBOL(pagesync_synchronize_memory);
+
+int __init pagesync_harvest_init(void)
+{
+    int result;
+    extern unsigned long num_physpages;
+
+
+    result = pagesync_syncd_init();
+    if (result)
+        return result;
+
+    mm_tracking_struct.vector = vmalloc(num_physpages/8);
+    mm_tracking_struct.bitcnt = num_physpages;
+
+    if (mm_tracking_struct.vector == NULL) {
+        printk(KERN_WARNING "%s: unable to allocate memory tracking 
bitmap\n",
+               __func__);
+        goto out_no_mm_track;
+    }
+
+    pagesync_scratch_page = (void *)__get_free_pages(GFP_KERNEL, 0);
+    if (!pagesync_scratch_page)
+        goto out_no_fsp;
+
+    pagesync_scratch_lock = kmalloc(sizeof(spinlock_t),
+                             GFP_KERNEL);
+    if (!pagesync_scratch_lock)
+        goto out_no_fsl;
+
+    spin_lock_init(pagesync_scratch_lock);
+
+    return 0;
+
+out_no_fsl:
+    free_pages((unsigned long)pagesync_scratch_page, 0);
+    pagesync_scratch_page = NULL;
+out_no_fsp:
+    vfree(mm_tracking_struct.vector);
+    mm_tracking_struct.vector = NULL;
+out_no_mm_track:
+    return -ENOMEM;
+}
+
+void __exit pagesync_harvest_cleanup(void)
+{
+    /* wake me after everyone is sure to be done with mm_track() */
+    synchronize_sched();
+
+    if (mm_tracking_struct.vector) {
+        vfree(mm_tracking_struct.vector);
+        mm_tracking_struct.vector = NULL;
+    }
+
+    if (pagesync_scratch_page)
+        free_pages((unsigned long)pagesync_scratch_page, 0);
+
+    kfree(pagesync_scratch_lock);
+
+    mm_tracking_struct.bitcnt = 0;
+
+    pagesync_syncd_cleanup();
+
+    return;
+}
+
+module_init(pagesync_harvest_init);
+module_exit(pagesync_harvest_cleanup);
+MODULE_LICENSE("GPL");
+
+#else /* CONFIG_TRACK_DIRTY_PAGES */
+
+
+int __init pagesync_harvest_init(void)
+{
+    return 0;
+}
+
+void __exit pagesync_harvest_cleanup(void)
+{
+    return;
+}
+
+
+#endif /* CONFIG_TRACK_DIRTY_PAGES */
diff -up linux-2.6-git-track/arch/x86/mm/pagesync_harvest.h.harvest 
linux-2.6-git-track/arch/x86/mm/pagesync_harvest.h
--- linux-2.6-git-track/arch/x86/mm/pagesync_harvest.h.harvest   
 2009-07-21 18:30:57.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/pagesync_harvest.h    2009-07-23 
22:46:56.000000000 -0400
@@ -0,0 +1,69 @@
+/*
+ * Definitions for memory mirroring/harvest.
+ *
+ * Copyright (C) 2006, 2009 Stratus Technologies Bermuda Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  
02111-1307  USA
+ */
+#ifndef __HARVEST_H__
+#define __HARVEST_H__
+
+enum {
+    PAGESYNC_ERR_OK = 0,
+    PAGESYNC_ERR_MERGE_FAIL,
+    PAGESYNC_ERR_COPY_FAIL,
+    PAGESYNC_ERR_SYNC_FAIL,
+};
+
+#define PAGESYNC_ERR_STRING(x)            \
+({                        \
+    char *retval;                \
+                        \
+    switch (x) {                \
+    case PAGESYNC_ERR_OK:            \
+        retval = "OK";            \
+        break;                \
+    case PAGESYNC_ERR_MERGE_FAIL:        \
+        retval = "Merge failed";    \
+        break;                \
+    case PAGESYNC_ERR_COPY_FAIL:        \
+        retval = "Copy failed";        \
+        break;                \
+    case PAGESYNC_ERR_SYNC_FAIL:        \
+        retval = "Sync failed";        \
+        break;                \
+    default:                \
+        retval = "Unknown error";    \
+    }                    \
+                        \
+    retval;                    \
+})
+
+struct pagesync_page_range {
+    unsigned int start;
+    unsigned int num;
+};
+
+typedef int (*copy_proc)(unsigned long start_pfn,
+             unsigned long count,
+             int blackout, void *context);
+typedef int (*sync_proc)(int max_range,
+             struct pagesync_page_range *copy_range,
+             void *context);
+
+int pagesync_synchronize_memory(copy_proc, sync_proc,
+                 unsigned int, unsigned int, void *);
+
+#endif /* __HARVEST_H__ */
diff -up linux-2.6-git-track/arch/x86/mm/pagesync.h.harvest 
linux-2.6-git-track/arch/x86/mm/pagesync.h
--- linux-2.6-git-track/arch/x86/mm/pagesync.h.harvest    2009-07-21 
18:30:57.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/pagesync.h    2009-07-22 
13:11:21.000000000 -0400
@@ -0,0 +1,66 @@
+/*
+ * pagesync global definitions, prototypes and macros
+ *
+ * All kernel header files needed by all components should be defined
+ * here.  Additional local needs will be in their respective
+ * components.
+ *
+ * Copyright (C) 2006, 2007, 2009 Stratus Technologies Bermuda Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  
02111-1307  USA
+ */
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/init.h>
+
+/***********************************************************************
+              Macro Definitions
+ ***********************************************************************/
+
+#define DBG(args...)                \
+({                        \
+    if (pagesync_debug)            \
+        printk(args);            \
+})
+
+#define HERE()    DBG(KERN_DEBUG "%s(%d)\n", __func__, __LINE__)
+
+/***********************************************************************
+               Module global variables
+ ***********************************************************************/
+
+/***********************************************************************
+        Initialization and Cleanup Prototypes
+ ***********************************************************************/
+
+#define INIT_CLEANUP_DECLS(NS, COMPONENT)            \
+        int NS ## _ ## COMPONENT ## _init(void);    \
+        void NS ## _ ## COMPONENT ## _cleanup(void)
+
+INIT_CLEANUP_DECLS(pagesync, harvest);
+INIT_CLEANUP_DECLS(pagesync, syncd);
+
+#undef INIT_CLEANUP_DECLS
+
+/***********************************************************************
+                  Prototypes
+ ***********************************************************************/
+void pagesync_syncd_sched(void);
+void pagesync_restart(void);
+
+extern unsigned int pagesync_debug;
+
+
diff -up linux-2.6-git-track/arch/x86/mm/pagesync_syncd.c.harvest 
linux-2.6-git-track/arch/x86/mm/pagesync_syncd.c
--- linux-2.6-git-track/arch/x86/mm/pagesync_syncd.c.harvest   
 2009-07-21 18:30:57.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/pagesync_syncd.c    2009-07-24 
14:48:15.000000000 -0400
@@ -0,0 +1,259 @@
+/*
+ * Synchronization threads.  Used when there is a need to run a function
+ * on one or more CPUs.  Typically used to capture all CPUs for blackout
+ * or other critical region processing where processors must be executing
+ * in a controlled manner.
+ *
+ * Copyright (C) 2006, 2009 Stratus Technologies Bermuda Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  
02111-1307  USA
+ */
+#ifdef CONFIG_TRACK_DIRTY_PAGES
+
+#include "pagesync.h"
+
+#include <linux/sched.h>
+#include <linux/version.h>
+#include <linux/preempt.h>
+
+#include "pagesync_syncd.h"
+
+struct syncd_struct {
+    int target_cpu;
+    sync_function_t func;
+    void *arg;
+    unsigned int num_procs;
+    struct semaphore ack;
+};
+
+static struct {
+    wait_queue_head_t wait;
+    unsigned long syncd_in_use;
+} syncd_event;
+
+static struct syncd_struct syncd[NR_CPUS];
+static struct thread_state syncd_state[NR_CPUS];
+static DECLARE_MUTEX(syncd_sem);
+static cpumask_t old_cpus_allowed;
+
+unsigned int pagesync_debug = 1;
+
+static int
+syncd_on_processor_mask(sync_function_t func, void *arg, cpumask_t mask,
+            unsigned int num_procs)
+{
+    int i;
+
+#ifdef DEBUG
+    {
+        char buf[40];
+
+        cpumask_scnprintf(buf, sizeof(buf), &mask);
+        DBG("%s: requesting from cpu %d mask %s\n",
+            __func__, smp_processor_id(), buf);
+    }
+#endif
+
+    preempt_disable();
+
+    for (i = 0; i < num_online_cpus(); i++) {
+        /* skip over cpu's not marked in the mask */
+        if (!cpu_isset(i, mask))
+            continue;
+
+        syncd[i].func = func;
+        syncd[i].arg = arg;
+        syncd[i].num_procs = num_procs;
+
+        /* wake syncd */
+        DBG("%s: waking syncd%d\n", __func__, i);
+        THREAD_WAKE(syncd_state[i]);
+    }
+
+    preempt_enable();
+
+    for (i = 0; i < num_online_cpus(); i++) {
+        /* skip over cpu's not marked in the mask */
+        if (!cpu_isset(i, mask))
+            continue;
+
+        /* wait here for syncd to check in */
+        down(&syncd[i].ack);
+    }
+
+    return 0;
+}
+
+static int
+syncd_on_all_processors(sync_function_t func, void *arg)
+{
+    int retval = 0;
+
+    DBG("%s: enter\n", __func__);
+
+    retval = syncd_on_processor_mask(func, arg,
+                     cpu_online_map, num_online_cpus());
+
+    DBG("%s: exit\n", __func__);
+
+    return retval;
+}
+
+
+atomic_t syncd_awake_count;        /* How many syncds not on wait q? */
+
+int
+pagesync_syncd_start(sync_function_t func, void *arg, int cpu)
+{
+    down(&syncd_sem);
+
+    atomic_set(&syncd_awake_count, num_online_cpus());
+    return syncd_on_all_processors(func, arg);
+}
+EXPORT_SYMBOL(pagesync_syncd_start);
+
+void
+pagesync_syncd_finish(void)
+{
+    wait_event(syncd_event.wait, (syncd_event.syncd_in_use == 0));
+    while (atomic_read(&syncd_awake_count))
+        schedule();
+    up(&syncd_sem);
+}
+EXPORT_SYMBOL(pagesync_syncd_finish);
+
+/*****************************************************************/
+
+static int syncd_thread(void *arg)
+{
+    struct thread_state *state = (struct thread_state *) arg;
+    struct syncd_struct *s = (struct syncd_struct *) state->data;
+    int target_cpu = s->target_cpu;
+    cpumask_t mask = CPU_MASK_NONE;
+    sync_function_t event_func = NULL;
+    void *event_arg = NULL;
+    unsigned int event_num_procs = 0;
+    int tries;
+
+    THREAD_INIT(state);
+
+    /* after we schedule, we should wake on the target cpu only */
+    cpu_set(target_cpu, mask);
+    set_cpus_allowed(current, mask);
+
+    /* raise our priority such that we get chosen to run 'next' */
+    current->policy = SCHED_RR;
+    current->rt_priority = 1;
+
+    while (!THREAD_SHOULD_STOP(state)) {
+
+        THREAD_WAIT(state);
+
+        if (THREAD_SHOULD_STOP(state))
+            break;
+
+        tries = 5;
+        while (target_cpu != smp_processor_id()) {
+            printk(KERN_ERR
+                   "syncd%d woke on cpu%d trying again\n",
+                   target_cpu, smp_processor_id());
+
+            yield();
+
+            if (tries-- == 0) {
+                printk(KERN_ERR "syncd%d woke on cpu%d "
+                       "trying again\n", target_cpu,
+                       smp_processor_id());
+                printk(KERN_ERR "syncd%d exiting\n",
+                       target_cpu);
+
+                /*
+                 * XXX should probably signal an event
+                 * to admin to have driver reloaded
+                 * in the short term
+                 */
+                goto exit;
+            }
+        }
+
+        event_func = s->func;
+        event_arg = s->arg;
+        event_num_procs = s->num_procs;
+        s->func = NULL;
+        s->arg = NULL;
+        s->num_procs = 0;
+
+        DBG("syncd%d responding on cpu %d\n",
+            target_cpu, smp_processor_id());
+        set_bit(target_cpu, &syncd_event.syncd_in_use);
+
+        /* ack we are processing the event */
+        up(&s->ack);
+
+        /* process the event */
+        if (event_func)
+            (*event_func)(event_arg, event_num_procs);
+
+        /* notify the event we have completed */
+        clear_bit(target_cpu, &syncd_event.syncd_in_use);
+        wake_up(&syncd_event.wait);
+    }
+ exit:
+    THREAD_EXIT(state)
+}
+
+int
+pagesync_syncd_init(void)
+{
+    int i;
+
+    init_waitqueue_head(&syncd_event.wait);
+    syncd_event.syncd_in_use = 0;
+
+    for (i = 0; i < num_online_cpus(); i++) {
+        char name[16];
+
+        if (!cpu_online(i))
+            continue;
+
+        syncd[i].target_cpu = i;
+        syncd[i].func = NULL;
+        syncd[i].arg = NULL;
+        init_MUTEX_LOCKED(&syncd[i].ack);
+
+        snprintf(name, 16, "syncd/%d", i);
+        THREAD_START(syncd_state[i], syncd_thread, &syncd[i], name);
+    }
+
+    return 0;
+}
+
+void
+pagesync_syncd_cleanup(void)
+{
+    int i;
+
+    for (i = 0; i < num_online_cpus(); i++)
+        THREAD_STOP(syncd_state[i]);
+}
+
+void
+pagesync_syncd_sched(void)
+{
+    synchronize_sched();
+}
+EXPORT_SYMBOL(pagesync_syncd_sched);
+
+#endif /* CONFIG_TRACK_DIRTY_PAGES */
diff -up linux-2.6-git-track/arch/x86/mm/pagesync_syncd.h.harvest 
linux-2.6-git-track/arch/x86/mm/pagesync_syncd.h
--- linux-2.6-git-track/arch/x86/mm/pagesync_syncd.h.harvest   
 2009-07-21 18:30:57.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/pagesync_syncd.h    2009-07-23 
22:41:59.000000000 -0400
@@ -0,0 +1,185 @@
+/*
+ * Definitions and prototypes for syncd.
+ *
+ * Copyright (C) 2005, 2007, 2009 Stratus Technologies Bermuda Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  
02111-1307  USA
+ */
+#ifndef __SYNCD_H__
+#define __SYNCD_H__
+
+#include <linux/sched.h>
+#include <linux/semaphore.h>
+
+struct thread_state {
+    int valid;
+
+    pid_t pid;
+
+    char *name;
+    void *data;
+
+    int should_stop;
+    wait_queue_head_t waitq;
+
+    struct completion started;
+    struct task_struct *result;
+    struct completion done;
+};
+
+#define THREAD_INIT(state)            \
+({                        \
+    daemonize(state->name);            \
+                        \
+    /* allow kernel thread to be reaped. */    \
+    current->exit_signal = SIGCHLD;        \
+                        \
+    complete(&state->started);        \
+})
+
+#define THREAD_EXIT(state)        complete_and_exit(&state->done, 0);
+
+#define THREAD_SHOULD_STOP(state)    (state->should_stop)
+
+#define THREAD_START(state, func, fndata, thrdname)        \
+({                                \
+    pid_t pid;                        \
+                                \
+    state.valid = 1;                    \
+    state.name = thrdname;                    \
+    state.data = fndata;                    \
+    init_completion(&state.started);            \
+    init_completion(&state.done);                \
+    init_waitqueue_head(&state.waitq);            \
+    state.should_stop = 0;                    \
+                                \
+    pid = kernel_thread(func, &state, 0);            \
+    if (pid < 0)                        \
+        return pid;                    \
+                                \
+    wait_for_completion(&state.started);            \
+                                \
+    state.pid = pid;                    \
+    state.result = pid_task(find_pid_ns(pid, &init_pid_ns), PIDTYPE_PID); \
+})
+
+#define THREAD_STOP(state)                \
+({                            \
+    if (state.valid) {                \
+        state.should_stop = 1;            \
+        wake_up_interruptible(&state.waitq);    \
+        wait_for_completion(&state.done);    \
+    }                        \
+})
+
+#define THREAD_WAKE(state)                \
+({                            \
+    if (state.valid)                \
+        wake_up_interruptible(&state.waitq);    \
+})
+
+#define THREAD_SLEEP_ON_EVENT(state, condition, timeout)        \
+({                                    \
+    int retval;                            \
+    retval = wait_event_interruptible_timeout(state->waitq,        \
+                          condition,        \
+                          timeout);        \
+    if (retval == -ERESTARTSYS) {    /* we were interrupted */    \
+        retval = 0;                        \
+    }                                \
+    if (retval == 0) {        /* timed out */            \
+        ;                            \
+    }                                \
+    if (retval >= 0) {        /* condition satisfied */    \
+        ;                            \
+    }                                \
+                                    \
+    retval;                                \
+})
+
+#define THREAD_SLEEP(state, timeout)                    \
+({                                    \
+    int retval;                            \
+    retval = THREAD_SLEEP_ON_EVENT(state,                \
+                       THREAD_SHOULD_STOP(state),    \
+                       timeout);            \
+    retval;                                \
+})
+
+extern atomic_t syncd_awake_count;
+
+#define THREAD_WAIT(state)                         \
+({                                     \
+    wait_queue_t __wait;                         \
+    init_waitqueue_entry(&__wait, current);                 \
+                                     \
+    add_wait_queue(&state->waitq, &__wait);                 \
+    set_current_state(TASK_INTERRUPTIBLE);                 \
+    atomic_dec(&syncd_awake_count);                     \
+    schedule();                             \
+    current->state = TASK_RUNNING;                     \
+    remove_wait_queue(&state->waitq, &__wait);             \
+})
+
+
+enum syncd_request_type {
+    SYNCD_ON_ALL_PROCESSORS = 1,
+    SYNCD_ON_OTHER_PROCESSORS,
+    SYNCD_ON_ONE_PROCESSOR,
+};
+
+typedef void (*sync_function_t)(void *, unsigned int);
+
+int  pagesync_syncd_start(sync_function_t func, void *arg, int cpu);
+void pagesync_syncd_finish(void);
+
+void pagesync_syncd_sched(void);
+
+int pagesync_syncd_init(void);
+void pagesync_syncd_cleanup(void);
+
+/***********************************************************************
+                  Rendezvous
+ ***********************************************************************/
+
+static inline void
+init_rendezvous(atomic_t *r)
+{
+    atomic_set(r, num_online_cpus());
+}
+
+/**
+ * Capture CPUs here, waiting for everyone to check in.  Once everyone has
+ * arrived all can leave.
+ */
+static inline void
+rendezvous(atomic_t *r)
+{
+    atomic_dec(r);
+
+    while (atomic_read(r) != 0)
+        barrier();
+}
+
+static inline void
+rendezvous_sched(atomic_t *r)
+{
+    atomic_dec(r);
+
+    while (atomic_read(r) != 0)
+        schedule();
+}
+
+#endif /* __SYNCD_H__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
