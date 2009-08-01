Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B8616B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 20:49:40 -0400 (EDT)
Message-ID: <4A7390F6.6080207@redhat.com>
Date: Fri, 31 Jul 2009 20:48:54 -0400
From: Jim Paradis <jparadis@redhat.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] Dirty Page Tracking & on-the-fly memory mirroring
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch implements dirty page tracking and re-dirty detection.  We 
use one
of the programmer bits in the PTE to implement a "soft dirty" bit.  In the
VM subsystem, all tests for dirty pages check the logical OR of the 
hardware
dirty bit and the "soft dirty" bit; if either one is set the page is
considered "dirty" for VM purposes.  To speed up the scanning passes this
patch also implements a bitmapped side-list of dirty physical pages.



 Kconfig                      |   11 ++
 include/asm/hugetlb.h        |    3
 include/asm/mm_track.h       |   98 ++++++++++++++++++++++++
 include/asm/pgtable-2level.h |    4
 include/asm/pgtable-3level.h |   12 ++
 include/asm/pgtable.h        |    4
 include/asm/pgtable_32.h     |    1
 include/asm/pgtable_64.h     |    7 +
 include/asm/pgtable_types.h  |    5 -
 mm/Makefile                  |    1
 mm/track.c                   |  174 
+++++++++++++++++++++++++++++++++++++++++++
 11 files changed, 317 insertions(+), 3 deletions(-)

Signed-off-by: jparadis@redhat.com

diff -up linux-2.6-git-track/arch/x86/include/asm/hugetlb.h.track 
linux-2.6-git-track/arch/x86/include/asm/hugetlb.h
--- linux-2.6-git-track/arch/x86/include/asm/hugetlb.h.track   
 2009-07-21 13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/include/asm/hugetlb.h    2009-07-21 
13:52:56.000000000 -0400
@@ -2,6 +2,7 @@
 #define _ASM_X86_HUGETLB_H
 
 #include <asm/page.h>
+#include <asm/mm_track.h>
 
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
@@ -39,12 +40,14 @@ static inline void hugetlb_free_pgd_rang
 static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long 
addr,
                    pte_t *ptep, pte_t pte)
 {
+    mm_track_pmd((pmd_t *)ptep);
     set_pte_at(mm, addr, ptep, pte);
 }
 
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
                         unsigned long addr, pte_t *ptep)
 {
+    mm_track_pmd((pmd_t *)ptep);
     return ptep_get_and_clear(mm, addr, ptep);
 }
 
diff -up linux-2.6-git-track/arch/x86/include/asm/mm_track.h.track 
linux-2.6-git-track/arch/x86/include/asm/mm_track.h
--- linux-2.6-git-track/arch/x86/include/asm/mm_track.h.track   
 2009-07-21 13:52:56.000000000 -0400
+++ linux-2.6-git-track/arch/x86/include/asm/mm_track.h    2009-07-21 
13:52:56.000000000 -0400
@@ -0,0 +1,98 @@
+/*
+ * Routines and structures for building a bitmap of
+ * dirty pages in a live system.  For use in memory mirroring
+ * or migration applications.
+ *
+ * Copyright (C) 2006,2009 Stratus Technologies Bermuda Ltd.
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
+#ifndef __X86_64_MMTRACK_H__
+#define __X86_64_MMTRACK_H__
+
+#ifndef CONFIG_TRACK_DIRTY_PAGES
+
+static inline void mm_track_pte(pte_t *ptep)    {}
+static inline void mm_track_pmd(pmd_t *pmdp)    {}
+static inline void mm_track_pud(pud_t *pudp)    {}
+static inline void mm_track_pgd(pgd_t *pgdp)     {}
+static inline void mm_track_phys(void *physp)    {}
+
+#else
+
+#include <asm/page.h>
+#include <asm/atomic.h>
+ /*
+  * For memory-tracking purposes, if active is true (non-zero), the other
+  * elements of the structure are available for use.  Each time 
mm_track_pte
+  * is called, it increments count and sets a bit in the bitvector table.
+  * Each bit in the bitvector represents a physical page in memory.
+  *
+  * This is declared in arch/x86_64/mm/track.c.
+  *
+  * The in_use element is used in the code which drives the memory tracking
+  * environment.  When tracking is complete, the vector may be freed, but
+  * only after the active flag is set to zero and the in_use count goes to
+  * zero.
+  *
+  * The count element indicates how many pages have been stored in the
+  * bitvector.  This is an optimization to avoid counting the bits in the
+  * vector between harvest operations.
+  */
+struct mm_tracker {
+    int active;        /* non-zero if this structure in use */
+    atomic_t count;        /* number of pages tracked by mm_track() */
+    unsigned long *vector;    /* bit vector of modified pages */
+    unsigned long bitcnt;    /* number of bits in vector */
+};
+extern struct mm_tracker mm_tracking_struct;
+
+extern void do_mm_track_pte(void *);
+extern void do_mm_track_pmd(void *);
+extern void do_mm_track_pud(void *);
+extern void do_mm_track_pgd(void *);
+extern void do_mm_track_phys(void *);
+
+/*
+ * The mm_track routine is needed by macros in pgtable.h
+ */
+static inline void mm_track_pte(pte_t *ptep)
+{
+    if (unlikely(mm_tracking_struct.active))
+        do_mm_track_pte(ptep);
+}
+static inline void mm_track_pmd(pmd_t *pmdp)
+{
+    if (unlikely(mm_tracking_struct.active))
+        do_mm_track_pmd(pmdp);
+}
+static inline void mm_track_pud(pud_t *pudp)
+{
+    if (unlikely(mm_tracking_struct.active))
+        do_mm_track_pud(pudp);
+}
+static inline void mm_track_pgd(pgd_t *pgdp)
+{
+    if (unlikely(mm_tracking_struct.active))
+        do_mm_track_pgd(pgdp);
+}
+static inline void mm_track_phys(void *physp)
+{
+    if (unlikely(mm_tracking_struct.active))
+        do_mm_track_phys(physp);
+}
+#endif /* CONFIG_TRACK_DIRTY_PAGES */
+
+#endif /* __X86_64_MMTRACK_H__ */
diff -up linux-2.6-git-track/arch/x86/include/asm/pgtable-2level.h.track 
linux-2.6-git-track/arch/x86/include/asm/pgtable-2level.h
--- linux-2.6-git-track/arch/x86/include/asm/pgtable-2level.h.track   
 2009-07-21 13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/include/asm/pgtable-2level.h   
 2009-07-21 13:52:56.000000000 -0400
@@ -13,11 +13,13 @@
  */
 static inline void native_set_pte(pte_t *ptep , pte_t pte)
 {
+    mm_track_pte(ptep);
     *ptep = pte;
 }
 
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
+    mm_track_pmd(pmdp);
     *pmdp = pmd;
 }
 
@@ -34,12 +36,14 @@ static inline void native_pmd_clear(pmd_
 static inline void native_pte_clear(struct mm_struct *mm,
                     unsigned long addr, pte_t *xp)
 {
+    mm_track_pte(xp);
     *xp = native_make_pte(0);
 }
 
 #ifdef CONFIG_SMP
 static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 {
+    mm_track_pte(xp);
     return __pte(xchg(&xp->pte_low, 0));
 }
 #else
diff -up linux-2.6-git-track/arch/x86/include/asm/pgtable_32.h.track 
linux-2.6-git-track/arch/x86/include/asm/pgtable_32.h
--- linux-2.6-git-track/arch/x86/include/asm/pgtable_32.h.track   
 2009-07-21 13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/include/asm/pgtable_32.h    2009-07-21 
13:52:56.000000000 -0400
@@ -22,6 +22,7 @@
 #include <linux/slab.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <asm/mm_track.h>
 
 struct mm_struct;
 struct vm_area_struct;
diff -up linux-2.6-git-track/arch/x86/include/asm/pgtable-3level.h.track 
linux-2.6-git-track/arch/x86/include/asm/pgtable-3level.h
--- linux-2.6-git-track/arch/x86/include/asm/pgtable-3level.h.track   
 2009-07-21 13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/include/asm/pgtable-3level.h   
 2009-07-21 13:52:56.000000000 -0400
@@ -26,6 +26,7 @@
  */
 static inline void native_set_pte(pte_t *ptep, pte_t pte)
 {
+    mm_track_pte(ptep);
     ptep->pte_high = pte.pte_high;
     smp_wmb();
     ptep->pte_low = pte.pte_low;
@@ -33,16 +34,19 @@ static inline void native_set_pte(pte_t
 
 static inline void native_set_pte_atomic(pte_t *ptep, pte_t pte)
 {
+    mm_track_pte(ptep);
     set_64bit((unsigned long long *)(ptep), native_pte_val(pte));
 }
 
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
+    mm_track_pmd(pmdp);
     set_64bit((unsigned long long *)(pmdp), native_pmd_val(pmd));
 }
 
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
 {
+    mm_track_pud(pudp);
     set_64bit((unsigned long long *)(pudp), native_pud_val(pud));
 }
 
@@ -54,6 +58,7 @@ static inline void native_set_pud(pud_t
 static inline void native_pte_clear(struct mm_struct *mm, unsigned long 
addr,
                     pte_t *ptep)
 {
+    mm_track_pte(ptep);
     ptep->pte_low = 0;
     smp_wmb();
     ptep->pte_high = 0;
@@ -62,6 +67,9 @@ static inline void native_pte_clear(stru
 static inline void native_pmd_clear(pmd_t *pmd)
 {
     u32 *tmp = (u32 *)pmd;
+
+    mm_track_pmd(pmd);
+
     *tmp = 0;
     smp_wmb();
     *(tmp + 1) = 0;
@@ -71,6 +79,8 @@ static inline void pud_clear(pud_t *pudp
 {
     unsigned long pgd;
 
+    mm_track_pud(pudp);
+
     set_pud(pudp, __pud(0));
 
     /*
@@ -93,6 +103,8 @@ static inline pte_t native_ptep_get_and_
 {
     pte_t res;
 
+    mm_track_pte(ptep);
+
     /* xchg acts as a barrier before the setting of the high bits */
     res.pte_low = xchg(&ptep->pte_low, 0);
     res.pte_high = ptep->pte_high;
diff -up linux-2.6-git-track/arch/x86/include/asm/pgtable_64.h.track 
linux-2.6-git-track/arch/x86/include/asm/pgtable_64.h
--- linux-2.6-git-track/arch/x86/include/asm/pgtable_64.h.track   
 2009-07-21 13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/include/asm/pgtable_64.h    2009-07-21 
13:52:56.000000000 -0400
@@ -13,6 +13,7 @@
 #include <asm/processor.h>
 #include <linux/bitops.h>
 #include <linux/threads.h>
+#include <asm/mm_track.h>
 
 extern pud_t level3_kernel_pgt[512];
 extern pud_t level3_ident_pgt[512];
@@ -46,11 +47,13 @@ void set_pte_vaddr_pud(pud_t *pud_page,
 static inline void native_pte_clear(struct mm_struct *mm, unsigned long 
addr,
                     pte_t *ptep)
 {
+    mm_track_pte(ptep);
     *ptep = native_make_pte(0);
 }
 
 static inline void native_set_pte(pte_t *ptep, pte_t pte)
 {
+    mm_track_pte(ptep);
     *ptep = pte;
 }
 
@@ -61,6 +64,7 @@ static inline void native_set_pte_atomic
 
 static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 {
+    mm_track_pte(xp);
 #ifdef CONFIG_SMP
     return native_make_pte(xchg(&xp->pte, 0));
 #else
@@ -74,6 +78,7 @@ static inline pte_t native_ptep_get_and_
 
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
+    mm_track_pmd(pmdp);
     *pmdp = pmd;
 }
 
@@ -84,6 +89,7 @@ static inline void native_pmd_clear(pmd_
 
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
 {
+    mm_track_pud(pudp);
     *pudp = pud;
 }
 
@@ -94,6 +100,7 @@ static inline void native_pud_clear(pud_
 
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
+    mm_track_pgd(pgdp);
     *pgdp = pgd;
 }
 
diff -up linux-2.6-git-track/arch/x86/include/asm/pgtable.h.track 
linux-2.6-git-track/arch/x86/include/asm/pgtable.h
--- linux-2.6-git-track/arch/x86/include/asm/pgtable.h.track   
 2009-07-21 13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/include/asm/pgtable.h    2009-07-21 
13:52:56.000000000 -0400
@@ -91,7 +91,7 @@ static inline void __init paravirt_paget
  */
 static inline int pte_dirty(pte_t pte)
 {
-    return pte_flags(pte) & _PAGE_DIRTY;
+    return pte_flags(pte) & (_PAGE_DIRTY | _PAGE_SOFTDIRTY);
 }
 
 static inline int pte_young(pte_t pte)
@@ -158,7 +158,7 @@ static inline pte_t pte_clear_flags(pte_
 
 static inline pte_t pte_mkclean(pte_t pte)
 {
-    return pte_clear_flags(pte, _PAGE_DIRTY);
+    return pte_clear_flags(pte, (_PAGE_DIRTY | _PAGE_SOFTDIRTY));
 }
 
 static inline pte_t pte_mkold(pte_t pte)
diff -up linux-2.6-git-track/arch/x86/include/asm/pgtable_types.h.track 
linux-2.6-git-track/arch/x86/include/asm/pgtable_types.h
--- linux-2.6-git-track/arch/x86/include/asm/pgtable_types.h.track   
 2009-07-21 13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/include/asm/pgtable_types.h   
 2009-07-24 18:48:31.000000000 -0400
@@ -22,6 +22,7 @@
 #define _PAGE_BIT_PAT_LARGE    12    /* On 2MB or 1GB pages */
 #define _PAGE_BIT_SPECIAL    _PAGE_BIT_UNUSED1
 #define _PAGE_BIT_CPA_TEST    _PAGE_BIT_UNUSED1
+#define _PAGE_BIT_SOFTDIRTY    _PAGE_BIT_HIDDEN
 #define _PAGE_BIT_NX           63       /* No execute: only valid after 
cpuid check */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
@@ -45,6 +46,7 @@
 #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
 #define _PAGE_SPECIAL    (_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
 #define _PAGE_CPA_TEST    (_AT(pteval_t, 1) << _PAGE_BIT_CPA_TEST)
+#define _PAGE_SOFTDIRTY    (_AT(pteval_t, 1) << _PAGE_BIT_SOFTDIRTY)
 #define __HAVE_ARCH_PTE_SPECIAL
 
 #ifdef CONFIG_KMEMCHECK
@@ -69,7 +71,8 @@
 
 /* Set of bits not changed in pte_modify */
 #define _PAGE_CHG_MASK    (PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |        \
-             _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY)
+             _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY | \
+             _PAGE_SOFTDIRTY)
 
 #define _PAGE_CACHE_MASK    (_PAGE_PCD | _PAGE_PWT)
 #define _PAGE_CACHE_WB        (0)
diff -up linux-2.6-git-track/arch/x86/Kconfig.track 
linux-2.6-git-track/arch/x86/Kconfig
--- linux-2.6-git-track/arch/x86/Kconfig.track    2009-07-21 
13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/Kconfig    2009-07-28 
16:54:36.000000000 -0400
@@ -1128,6 +1128,17 @@ config DIRECT_GBPAGES
       support it. This can improve the kernel's performance a tiny bit by
       reducing TLB pressure. If in doubt, say "Y".
 
+config TRACK_DIRTY_PAGES
+    bool "Enable dirty page tracking"
+    default n
+    depends on !KMEMCHECK
+    ---help---
+      Turning this on allows third party modules to use a
+      kernel interface that can track dirty page generation
+      in the system.  This can be used to copy/mirror live
+      memory to another system or node.  Most users will
+      say n here.
+
 # Common NUMA Features
 config NUMA
     bool "Numa Memory Allocation and Scheduler Support"
diff -up linux-2.6-git-track/arch/x86/mm/Makefile.track 
linux-2.6-git-track/arch/x86/mm/Makefile
--- linux-2.6-git-track/arch/x86/mm/Makefile.track    2009-07-21 
13:46:54.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/Makefile    2009-07-21 
18:37:41.000000000 -0400
@@ -19,5 +19,6 @@ obj-$(CONFIG_MMIOTRACE_TEST)    += testmmio
 obj-$(CONFIG_NUMA)        += numa.o numa_$(BITS).o
 obj-$(CONFIG_K8_NUMA)        += k8topology_64.o
 obj-$(CONFIG_ACPI_NUMA)        += srat_$(BITS).o
+obj-$(CONFIG_TRACK_DIRTY_PAGES)    += track.o
 
 obj-$(CONFIG_MEMTEST)        += memtest.o
diff -up linux-2.6-git-track/arch/x86/mm/track.c.track 
linux-2.6-git-track/arch/x86/mm/track.c
--- linux-2.6-git-track/arch/x86/mm/track.c.track    2009-07-21 
13:52:56.000000000 -0400
+++ linux-2.6-git-track/arch/x86/mm/track.c    2009-07-21 
18:28:38.000000000 -0400
@@ -0,0 +1,174 @@
+/*
+ * Low-level routines for marking dirty pages of a running system in a
+ * bitmap.  Allows memory mirror or migration strategies to be implemented.
+ *
+ * Copyright (C) 2006,2009 Stratus Technologies Bermuda Ltd.
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
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+#include <asm/atomic.h>
+#include <asm/mm_track.h>
+#include <asm/pgtable.h>
+
+/*
+ * For memory-tracking purposes, see mm_track.h for details.
+ */
+struct mm_tracker mm_tracking_struct = {0, ATOMIC_INIT(0), 0, 0};
+EXPORT_SYMBOL(mm_tracking_struct);
+
+void do_mm_track_pte(void *val)
+{
+    pte_t *ptep = (pte_t *)val;
+    unsigned long pfn;
+
+    if (!pte_present(*ptep))
+        return;
+
+    if (!pte_val(*ptep) & _PAGE_DIRTY)
+        return;
+
+    pfn = pte_pfn(*ptep);
+
+    if (pfn >= mm_tracking_struct.bitcnt)
+        return;
+
+#ifdef CONFIG_XEN
+    pfn = pfn_to_mfn(pfn);
+#endif
+
+    if (!test_and_set_bit(pfn, mm_tracking_struct.vector))
+        atomic_inc(&mm_tracking_struct.count);
+}
+EXPORT_SYMBOL(do_mm_track_pte);
+
+#define LARGE_PMD_SIZE    (1 << PMD_SHIFT)
+
+void do_mm_track_pmd(void *val)
+{
+    int i;
+    pte_t *pte;
+    pmd_t *pmd = (pmd_t *)val;
+
+    if (!pmd_present(*pmd))
+        return;
+
+    if (unlikely(pmd_large(*pmd))) {
+        unsigned long addr, end;
+
+        if (!pte_val(*(pte_t *)val) & _PAGE_DIRTY)
+            return;
+
+        addr = pte_pfn(*(pte_t *)val) << PAGE_SHIFT;
+        end = addr + LARGE_PMD_SIZE;
+
+        while (addr < end) {
+            do_mm_track_phys((void *)addr);
+            addr +=  PAGE_SIZE;
+        }
+        return;
+    }
+
+    pte = pte_offset_kernel(pmd, 0);
+
+    for (i = 0; i < PTRS_PER_PTE; i++, pte++)
+        do_mm_track_pte(pte);
+}
+EXPORT_SYMBOL(do_mm_track_pmd);
+
+static inline void track_as_pte(void *val)
+{
+    unsigned long pfn = pte_pfn(*(pte_t *)val);
+    if (pfn >= mm_tracking_struct.bitcnt)
+        return;
+
+#ifdef CONFIG_XEN
+    pfn = pfn_to_mfn(pfn);
+#endif
+
+    if (!test_and_set_bit(pfn, mm_tracking_struct.vector))
+        atomic_inc(&mm_tracking_struct.count);
+}
+
+void do_mm_track_pud(void *val)
+{
+    track_as_pte(val);
+}
+EXPORT_SYMBOL(do_mm_track_pud);
+
+void do_mm_track_pgd(void *val)
+{
+    track_as_pte(val);
+}
+EXPORT_SYMBOL(do_mm_track_pgd);
+
+void do_mm_track_phys(void *val)
+{
+    unsigned long pfn;
+
+    pfn = (unsigned long)val >> PAGE_SHIFT;
+
+    if (pfn >= mm_tracking_struct.bitcnt)
+        return;
+
+#ifdef CONFIG_XEN
+    pfn = pfn_to_mfn(pfn);
+#endif
+
+    if (!test_and_set_bit(pfn, mm_tracking_struct.vector))
+        atomic_inc(&mm_tracking_struct.count);
+}
+EXPORT_SYMBOL(do_mm_track_phys);
+
+
+/*
+ * Allocate enough space for the bit vector in the
+ * mm_tracking_struct.
+ */
+int mm_track_init(long num_pages)
+{
+    mm_tracking_struct.vector = vmalloc((num_pages + 7)/8);
+    if (mm_tracking_struct.vector == NULL) {
+        printk(KERN_WARNING
+               "%s: failed to allocate bit vector\n", __func__);
+        return -ENOMEM;
+    }
+
+    mm_tracking_struct.bitcnt = num_pages;
+
+    return 0;
+}
+EXPORT_SYMBOL(mm_track_init);
+
+/*
+ * Turn off tracking, free the bit vector memory.
+ */
+void mm_track_exit(void)
+{
+    /*
+     * Inhibit the use of the tracking functions.
+     * This should have already been done, but just in case.
+     */
+    mm_tracking_struct.active = 0;
+    mm_tracking_struct.bitcnt = 0;
+
+    if (mm_tracking_struct.vector != NULL)
+        vfree(mm_tracking_struct.vector);
+}
+EXPORT_SYMBOL(mm_track_exit);
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
