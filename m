Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A19806B0071
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:37 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so12454860pdb.4
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:37 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id aa3si8591863pbc.163.2015.02.26.03.35.34
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 01/17] mm: add missing __PAGETABLE_{PUD,PMD}_FOLDED defines
Date: Thu, 26 Feb 2015 13:35:04 +0200
Message-Id: <1424950520-90188-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Aaro Koskinen <aaro.koskinen@iki.fi>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded. Usually, these defines are provided by
<asm-generic/pgtable-nopmd.h> and <asm-generic/pgtable-nopud.h>.

But some architectures fold page table levels in a custom way. They need
to define these macros themself. This patch adds missing defines.

The patch fixes mm->nr_pmds underflow and eliminates dead __pmd_alloc()
and __pud_alloc() on architectures without these page table levels.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: David Howells <dhowells@redhat.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Helge Deller <deller@gmx.de>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/frv/include/asm/pgtable.h         | 2 ++
 arch/m32r/include/asm/pgtable-2level.h | 1 +
 arch/m68k/include/asm/pgtable_mm.h     | 2 ++
 arch/mn10300/include/asm/pgtable.h     | 2 ++
 arch/parisc/include/asm/pgtable.h      | 1 +
 arch/s390/include/asm/pgtable.h        | 2 ++
 6 files changed, 10 insertions(+)

diff --git a/arch/frv/include/asm/pgtable.h b/arch/frv/include/asm/pgtable.h
index 93bcf2abd1a1..07d7a7ef8bd5 100644
--- a/arch/frv/include/asm/pgtable.h
+++ b/arch/frv/include/asm/pgtable.h
@@ -123,12 +123,14 @@ extern unsigned long empty_zero_page;
 #define PGDIR_MASK		(~(PGDIR_SIZE - 1))
 #define PTRS_PER_PGD		64
 
+#define __PAGETABLE_PUD_FOLDED
 #define PUD_SHIFT		26
 #define PTRS_PER_PUD		1
 #define PUD_SIZE		(1UL << PUD_SHIFT)
 #define PUD_MASK		(~(PUD_SIZE - 1))
 #define PUE_SIZE		256
 
+#define __PAGETABLE_PMD_FOLDED
 #define PMD_SHIFT		26
 #define PMD_SIZE		(1UL << PMD_SHIFT)
 #define PMD_MASK		(~(PMD_SIZE - 1))
diff --git a/arch/m32r/include/asm/pgtable-2level.h b/arch/m32r/include/asm/pgtable-2level.h
index 8fd8ee70266a..421e6ba3a173 100644
--- a/arch/m32r/include/asm/pgtable-2level.h
+++ b/arch/m32r/include/asm/pgtable-2level.h
@@ -13,6 +13,7 @@
  * the M32R is two-level, so we don't really have any
  * PMD directory physically.
  */
+#define __PAGETABLE_PMD_FOLDED
 #define PMD_SHIFT	22
 #define PTRS_PER_PMD	1
 
diff --git a/arch/m68k/include/asm/pgtable_mm.h b/arch/m68k/include/asm/pgtable_mm.h
index 28a145bfbb71..35ed4a9981ae 100644
--- a/arch/m68k/include/asm/pgtable_mm.h
+++ b/arch/m68k/include/asm/pgtable_mm.h
@@ -54,10 +54,12 @@
  */
 #ifdef CONFIG_SUN3
 #define PTRS_PER_PTE   16
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PMD   1
 #define PTRS_PER_PGD   2048
 #elif defined(CONFIG_COLDFIRE)
 #define PTRS_PER_PTE	512
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PMD	1
 #define PTRS_PER_PGD	1024
 #else
diff --git a/arch/mn10300/include/asm/pgtable.h b/arch/mn10300/include/asm/pgtable.h
index afab728ab65e..96d3f9deb59c 100644
--- a/arch/mn10300/include/asm/pgtable.h
+++ b/arch/mn10300/include/asm/pgtable.h
@@ -56,7 +56,9 @@ extern void paging_init(void);
 #define PGDIR_SHIFT	22
 #define PTRS_PER_PGD	1024
 #define PTRS_PER_PUD	1	/* we don't really have any PUD physically */
+#define __PAGETABLE_PUD_FOLDED
 #define PTRS_PER_PMD	1	/* we don't really have any PMD physically */
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PTE	1024
 
 #define PGD_SIZE	PAGE_SIZE
diff --git a/arch/parisc/include/asm/pgtable.h b/arch/parisc/include/asm/pgtable.h
index 8c966b2270aa..15207b9362bf 100644
--- a/arch/parisc/include/asm/pgtable.h
+++ b/arch/parisc/include/asm/pgtable.h
@@ -96,6 +96,7 @@ extern void purge_tlb_entries(struct mm_struct *, unsigned long);
 #if PT_NLEVELS == 3
 #define BITS_PER_PMD	(PAGE_SHIFT + PMD_ORDER - BITS_PER_PMD_ENTRY)
 #else
+#define __PAGETABLE_PMD_FOLDED
 #define BITS_PER_PMD	0
 #endif
 #define PTRS_PER_PMD    (1UL << BITS_PER_PMD)
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index fbb5ee3ae57c..e08ec38f8c6e 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -91,7 +91,9 @@ extern unsigned long zero_page_mask;
  */
 #define PTRS_PER_PTE	256
 #ifndef CONFIG_64BIT
+#define __PAGETABLE_PUD_FOLDED
 #define PTRS_PER_PMD	1
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PUD	1
 #else /* CONFIG_64BIT */
 #define PTRS_PER_PMD	2048
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
