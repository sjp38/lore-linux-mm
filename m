Message-ID: <41C9456A.9040107@yahoo.com.au>
Date: Wed, 22 Dec 2004 20:59:06 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 8/11] introduce fallback header
References: <41C94361.6070909@yahoo.com.au> <41C943F0.4090006@yahoo.com.au> <41C94427.9020601@yahoo.com.au> <41C94449.20004@yahoo.com.au> <41C94473.7050804@yahoo.com.au> <41C9449A.4020607@yahoo.com.au> <41C944CC.4040801@yahoo.com.au> <41C944F3.1060208@yahoo.com.au>
In-Reply-To: <41C944F3.1060208@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------090006000804090203080401"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090006000804090203080401
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

8/11

--------------090006000804090203080401
Content-Type: text/plain;
 name="4level-fallback.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-fallback.patch"



Add a temporary "fallback" header so architectures can run with the 4level
patgetables patch without modification. All architectures should be
converted to use the folding headers (include/asm-generic/pgtable-nop?d.h)
as soon as possible, and the fallback header removed.

Make all architectures include the fallback header, except i386, because that
architecture has earlier been converted to use pgtable-nopmd.h under the 3
level system, which is not compatible with the fallback header.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/asm-alpha/pgtable.h        |    2 +
 linux-2.6-npiggin/include/asm-arm/pgtable.h          |    2 +
 linux-2.6-npiggin/include/asm-arm26/pgtable.h        |    2 +
 linux-2.6-npiggin/include/asm-cris/pgtable.h         |    2 +
 linux-2.6-npiggin/include/asm-generic/4level-fixup.h |   34 +++++++++++++++++++
 linux-2.6-npiggin/include/asm-generic/tlb.h          |    2 +
 linux-2.6-npiggin/include/asm-h8300/pgtable.h        |    2 +
 linux-2.6-npiggin/include/asm-ia64/pgtable.h         |    2 +
 linux-2.6-npiggin/include/asm-m32r/pgtable.h         |    2 +
 linux-2.6-npiggin/include/asm-m68k/pgtable.h         |    2 +
 linux-2.6-npiggin/include/asm-m68knommu/pgtable.h    |    2 +
 linux-2.6-npiggin/include/asm-mips/pgtable.h         |    2 +
 linux-2.6-npiggin/include/asm-parisc/pgtable.h       |    2 +
 linux-2.6-npiggin/include/asm-ppc/pgtable.h          |    2 +
 linux-2.6-npiggin/include/asm-ppc64/pgtable.h        |    2 +
 linux-2.6-npiggin/include/asm-s390/pgtable.h         |    2 +
 linux-2.6-npiggin/include/asm-sh/pgtable.h           |    2 +
 linux-2.6-npiggin/include/asm-sh64/pgtable.h         |    2 +
 linux-2.6-npiggin/include/asm-sparc/pgtable.h        |    2 +
 linux-2.6-npiggin/include/asm-sparc64/pgtable.h      |    2 +
 linux-2.6-npiggin/include/asm-um/pgtable.h           |    2 +
 linux-2.6-npiggin/include/asm-v850/pgtable.h         |    2 +
 linux-2.6-npiggin/include/asm-x86_64/pgtable.h       |    2 +
 linux-2.6-npiggin/include/linux/mm.h                 |    6 +++
 linux-2.6-npiggin/mm/memory.c                        |   25 +++++++++++++
 25 files changed, 109 insertions(+)

diff -puN /dev/null include/asm-generic/4level-fixup.h
--- /dev/null	2004-09-06 19:38:39.000000000 +1000
+++ linux-2.6-npiggin/include/asm-generic/4level-fixup.h	2004-12-22 20:38:01.000000000 +1100
@@ -0,0 +1,34 @@
+#ifndef _4LEVEL_FIXUP_H
+#define _4LEVEL_FIXUP_H
+
+#define __ARCH_HAS_4LEVEL_HACK
+
+#define PUD_SIZE			PGDIR_SIZE
+#define PUD_MASK			PGDIR_MASK
+#define PTRS_PER_PUD			1
+
+#define pud_t				pgd_t
+
+#define pmd_alloc(mm, pud, address)			\
+({	pmd_t *ret;					\
+	if (pgd_none(*pud))				\
+ 		ret = __pmd_alloc(mm, pud, address);	\
+ 	else						\
+		ret = pmd_offset(pud, address);		\
+ 	ret;						\
+})
+
+#define pud_alloc(mm, pgd, address)	(pgd)
+#define pud_offset(pgd, start)		(pgd)
+#define pud_none(pud)			0
+#define pud_bad(pud)			0
+#define pud_present(pud)		1
+#define pud_ERROR(pud)			do { } while (0)
+#define pud_clear(pud)			do { } while (0)
+
+#undef pud_free_tlb
+#define pud_free_tlb(tlb, x)            do { } while (0)
+#define pud_free(x)			do { } while (0)
+#define __pud_free_tlb(tlb, x)		do { } while (0)
+
+#endif
diff -puN include/linux/mm.h~4level-fallback include/linux/mm.h
--- linux-2.6/include/linux/mm.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/linux/mm.h	2004-12-22 20:36:07.000000000 +1100
@@ -631,6 +631,11 @@ extern void remove_shrinker(struct shrin
  * the inlining and the symmetry break with pte_alloc_map() that does all
  * of this out-of-line.
  */
+/*
+ * The following ifdef needed to get the 4level-fixup.h header to work.
+ * Remove it when 4level-fixup.h has been removed.
+ */
+#ifndef __ARCH_HAS_4LEVEL_HACK 
 static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
 	if (pgd_none(*pgd))
@@ -644,6 +649,7 @@ static inline pmd_t *pmd_alloc(struct mm
 		return __pmd_alloc(mm, pud, address);
 	return pmd_offset(pud, address);
 }
+#endif
 
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
diff -puN mm/memory.c~4level-fallback mm/memory.c
--- linux-2.6/mm/memory.c~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/mm/memory.c	2004-12-22 20:36:07.000000000 +1100
@@ -1940,6 +1940,7 @@ int handle_mm_fault(struct mm_struct *mm
 	return VM_FAULT_OOM;
 }
 
+#ifndef __ARCH_HAS_4LEVEL_HACK
 #if (PTRS_PER_PGD > 1)
 /*
  * Allocate page upper directory.
@@ -2007,6 +2008,30 @@ out:
 	return pmd_offset(pud, address);
 }
 #endif
+#else
+pmd_t fastcall *__pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+{
+	pmd_t *new;
+
+	spin_unlock(&mm->page_table_lock);
+	new = pmd_alloc_one(mm, address);
+	spin_lock(&mm->page_table_lock);
+	if (!new)
+		return NULL;
+
+	/*
+	 * Because we dropped the lock, we should re-check the
+	 * entry, as somebody else could have populated it..
+	 */
+	if (pgd_present(*pud)) {
+		pmd_free(new);
+		goto out;
+	}
+	pgd_populate(mm, pud, new);
+out:
+	return pmd_offset(pud, address);
+}
+#endif
 
 int make_pages_present(unsigned long addr, unsigned long end)
 {
diff -puN include/asm-alpha/pgtable.h~4level-fallback include/asm-alpha/pgtable.h
--- linux-2.6/include/asm-alpha/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-alpha/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _ALPHA_PGTABLE_H
 #define _ALPHA_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /*
  * This file contains the functions and defines necessary to modify and use
  * the Alpha page table tree.
diff -puN include/asm-arm/pgtable.h~4level-fallback include/asm-arm/pgtable.h
--- linux-2.6/include/asm-arm/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-arm/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -10,6 +10,8 @@
 #ifndef _ASMARM_PGTABLE_H
 #define _ASMARM_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #include <asm/memory.h>
 #include <asm/proc-fns.h>
 #include <asm/arch/vmalloc.h>
diff -puN include/asm-arm26/pgtable.h~4level-fallback include/asm-arm26/pgtable.h
--- linux-2.6/include/asm-arm26/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-arm26/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -11,6 +11,8 @@
 #ifndef _ASMARM_PGTABLE_H
 #define _ASMARM_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 #include <asm/memory.h>
 
diff -puN include/asm-cris/pgtable.h~4level-fallback include/asm-cris/pgtable.h
--- linux-2.6/include/asm-cris/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-cris/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -5,6 +5,8 @@
 #ifndef _CRIS_PGTABLE_H
 #define _CRIS_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #ifndef __ASSEMBLY__
 #include <linux/config.h>
 #include <linux/sched.h>
diff -puN include/asm-generic/pgtable.h~4level-fallback include/asm-generic/pgtable.h
diff -puN include/asm-h8300/pgtable.h~4level-fallback include/asm-h8300/pgtable.h
--- linux-2.6/include/asm-h8300/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-h8300/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _H8300_PGTABLE_H
 #define _H8300_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 #include <linux/slab.h>
 #include <asm/processor.h>
diff -puN include/asm-i386/pgtable.h~4level-fallback include/asm-i386/pgtable.h
diff -puN include/asm-ia64/pgtable.h~4level-fallback include/asm-ia64/pgtable.h
--- linux-2.6/include/asm-ia64/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ia64/pgtable.h	2004-12-22 20:38:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _ASM_IA64_PGTABLE_H
 #define _ASM_IA64_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /*
  * This file contains the functions and defines necessary to modify and use
  * the IA-64 page table tree.
diff -puN include/asm-m32r/pgtable.h~4level-fallback include/asm-m32r/pgtable.h
--- linux-2.6/include/asm-m32r/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-m32r/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _ASM_M32R_PGTABLE_H
 #define _ASM_M32R_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /* $Id$ */
 
 /*
diff -puN include/asm-m68k/pgtable.h~4level-fallback include/asm-m68k/pgtable.h
--- linux-2.6/include/asm-m68k/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-m68k/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _M68K_PGTABLE_H
 #define _M68K_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 #include <asm/setup.h>
 
diff -puN include/asm-m68knommu/pgtable.h~4level-fallback include/asm-m68knommu/pgtable.h
--- linux-2.6/include/asm-m68knommu/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-m68knommu/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _M68KNOMMU_PGTABLE_H
 #define _M68KNOMMU_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /*
  * (C) Copyright 2000-2002, Greg Ungerer <gerg@snapgear.com>
  */
diff -puN include/asm-mips/pgtable.h~4level-fallback include/asm-mips/pgtable.h
--- linux-2.6/include/asm-mips/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-mips/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -8,6 +8,8 @@
 #ifndef _ASM_PGTABLE_H
 #define _ASM_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 #ifdef CONFIG_MIPS32
 #include <asm/pgtable-32.h>
diff -puN include/asm-parisc/pgtable.h~4level-fallback include/asm-parisc/pgtable.h
--- linux-2.6/include/asm-parisc/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-parisc/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _PARISC_PGTABLE_H
 #define _PARISC_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 #include <asm/fixmap.h>
 
diff -puN include/asm-ppc/pgtable.h~4level-fallback include/asm-ppc/pgtable.h
--- linux-2.6/include/asm-ppc/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ppc/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -2,6 +2,8 @@
 #ifndef _PPC_PGTABLE_H
 #define _PPC_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 
 #ifndef __ASSEMBLY__
diff -puN include/asm-ppc64/pgtable.h~4level-fallback include/asm-ppc64/pgtable.h
--- linux-2.6/include/asm-ppc64/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ppc64/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _PPC64_PGTABLE_H
 #define _PPC64_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /*
  * This file contains the functions and defines necessary to modify and use
  * the ppc64 hashed page table.
diff -puN include/asm-s390/pgtable.h~4level-fallback include/asm-s390/pgtable.h
--- linux-2.6/include/asm-s390/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-s390/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -13,6 +13,8 @@
 #ifndef _ASM_S390_PGTABLE_H
 #define _ASM_S390_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /*
  * The Linux memory management assumes a three-level page table setup. For
  * s390 31 bit we "fold" the mid level into the top-level page table, so
diff -puN include/asm-sh/pgtable.h~4level-fallback include/asm-sh/pgtable.h
--- linux-2.6/include/asm-sh/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-sh/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef __ASM_SH_PGTABLE_H
 #define __ASM_SH_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /*
  * Copyright (C) 1999 Niibe Yutaka
  * Copyright (C) 2002, 2003, 2004 Paul Mundt
diff -puN include/asm-sh64/pgtable.h~4level-fallback include/asm-sh64/pgtable.h
--- linux-2.6/include/asm-sh64/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-sh64/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef __ASM_SH64_PGTABLE_H
 #define __ASM_SH64_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /*
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
diff -puN include/asm-sparc/pgtable.h~4level-fallback include/asm-sparc/pgtable.h
--- linux-2.6/include/asm-sparc/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-sparc/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -9,6 +9,8 @@
  *  Copyright (C) 1998 Jakub Jelinek (jj@sunsite.mff.cuni.cz)
  */
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 #include <linux/spinlock.h>
 #include <linux/swap.h>
diff -puN include/asm-sparc64/pgtable.h~4level-fallback include/asm-sparc64/pgtable.h
--- linux-2.6/include/asm-sparc64/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-sparc64/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -12,6 +12,8 @@
  * the SpitFire page tables.
  */
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 #include <asm/spitfire.h>
 #include <asm/asi.h>
diff -puN include/asm-um/pgtable.h~4level-fallback include/asm-um/pgtable.h
--- linux-2.6/include/asm-um/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-um/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -7,6 +7,8 @@
 #ifndef __UM_PGTABLE_H
 #define __UM_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 #include "linux/sched.h"
 #include "asm/processor.h"
 #include "asm/page.h"
diff -puN include/asm-v850/pgtable.h~4level-fallback include/asm-v850/pgtable.h
--- linux-2.6/include/asm-v850/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-v850/pgtable.h	2004-12-22 20:36:07.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef __V850_PGTABLE_H__
 #define __V850_PGTABLE_H__
 
+#include <asm-generic/4level-fixup.h>
+
 #include <linux/config.h>
 #include <asm/page.h>
 
diff -puN include/asm-x86_64/pgtable.h~4level-fallback include/asm-x86_64/pgtable.h
--- linux-2.6/include/asm-x86_64/pgtable.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-x86_64/pgtable.h	2004-12-22 20:38:06.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _X86_64_PGTABLE_H
 #define _X86_64_PGTABLE_H
 
+#include <asm-generic/4level-fixup.h>
+
 /*
  * This file contains the functions and defines necessary to modify and use
  * the x86-64 page table tree.
diff -puN include/asm-generic/tlb.h~4level-fallback include/asm-generic/tlb.h
--- linux-2.6/include/asm-generic/tlb.h~4level-fallback	2004-12-22 20:36:07.000000000 +1100
+++ linux-2.6-npiggin/include/asm-generic/tlb.h	2004-12-22 20:36:07.000000000 +1100
@@ -141,11 +141,13 @@ static inline void tlb_remove_page(struc
 		__pte_free_tlb(tlb, ptep);			\
 	} while (0)
 
+#ifndef __ARCH_HAS_4LEVEL_HACK
 #define pud_free_tlb(tlb, pudp)					\
 	do {							\
 		tlb->need_flush = 1;				\
 		__pud_free_tlb(tlb, pudp);			\
 	} while (0)
+#endif
 
 #define pmd_free_tlb(tlb, pmdp)					\
 	do {							\

_

--------------090006000804090203080401--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
