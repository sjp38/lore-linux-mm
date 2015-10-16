Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id DF49782F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:07:25 -0400 (EDT)
Received: by wijp11 with SMTP id p11so7156308wij.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 05:07:25 -0700 (PDT)
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com. [195.75.94.103])
        by mx.google.com with ESMTPS id bx5si4734675wib.48.2015.10.16.05.07.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Oct 2015 05:07:24 -0700 (PDT)
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Oct 2015 13:07:24 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 665E4219004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:07:19 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9GC7LXb33947730
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 12:07:21 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9GC7GVZ010035
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 06:07:20 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 3/3] powerpc/mm: Add page soft dirty tracking
Date: Fri, 16 Oct 2015 14:07:08 +0200
Message-Id: <b1ae177b872e901b01a4071c92c4db23a3323be3.1444995096.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulus@samba.org
Cc: criu@openvz.org

User space checkpoint and restart tool (CRIU) needs the page's change
to be soft tracked. This allows to do a pre checkpoint and then dump
only touched pages.

This is done by using a newly assigned PTE bit (_PAGE_SOFT_DIRTY) when
the page is backed in memory, and a new _PAGE_SWP_SOFT_DIRTY bit when
the page is swapped out.

The _PAGE_SWP_SOFT_DIRTY bit is dynamically put after the swap type
in the swap pte. A check is added to ensure that the bit is not
overwritten by _PAGE_HPTEFLAGS.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig                     |  2 ++
 arch/powerpc/include/asm/pgtable-ppc64.h | 13 +++++++++--
 arch/powerpc/include/asm/pgtable.h       | 40 +++++++++++++++++++++++++++++++-
 arch/powerpc/include/asm/pte-book3e.h    |  1 +
 arch/powerpc/include/asm/pte-common.h    |  5 ++--
 arch/powerpc/include/asm/pte-hash64.h    |  1 +
 6 files changed, 57 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 9a7057ec2154..73a4a36a6b38 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -559,6 +559,7 @@ choice
 
 config PPC_4K_PAGES
 	bool "4k page size"
+	select HAVE_ARCH_SOFT_DIRTY if CHECKPOINT_RESTORE && PPC_BOOK3S
 
 config PPC_16K_PAGES
 	bool "16k page size"
@@ -567,6 +568,7 @@ config PPC_16K_PAGES
 config PPC_64K_PAGES
 	bool "64k page size"
 	depends on !PPC_FSL_BOOK3E && (44x || PPC_STD_MMU_64 || PPC_BOOK3E_64)
+	select HAVE_ARCH_SOFT_DIRTY if CHECKPOINT_RESTORE && PPC_BOOK3S
 
 config PPC_256K_PAGES
 	bool "256k page size"
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index fa1dfb7f7b48..2738bf4a8c55 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -315,7 +315,8 @@ static inline void pte_clear(struct mm_struct *mm, unsigned long addr,
 static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 {
 	unsigned long bits = pte_val(entry) &
-		(_PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_RW | _PAGE_EXEC);
+		(_PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_RW | _PAGE_EXEC |
+		 _PAGE_SOFT_DIRTY);
 
 #ifdef PTE_ATOMIC_UPDATES
 	unsigned long old, tmp;
@@ -354,6 +355,7 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 	 * We filter HPTEFLAGS on set_pte.			\
 	 */							\
 	BUILD_BUG_ON(_PAGE_HPTEFLAGS & (0x1f << _PAGE_BIT_SWAP_TYPE)); \
+	BUILD_BUG_ON(_PAGE_HPTEFLAGS & _PAGE_SWP_SOFT_DIRTY);	\
 	} while (0)
 /*
  * on pte we don't need handle RADIX_TREE_EXCEPTIONAL_SHIFT;
@@ -371,6 +373,8 @@ static inline void __ptep_set_access_flags(pte_t *ptep, pte_t entry)
 
 void pgtable_cache_add(unsigned shift, void (*ctor)(void *));
 void pgtable_cache_init(void);
+
+#define _PAGE_SWP_SOFT_DIRTY	(1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
 #endif /* __ASSEMBLY__ */
 
 /*
@@ -389,7 +393,7 @@ void pgtable_cache_init(void);
  */
 #define _HPAGE_CHG_MASK (PTE_RPN_MASK | _PAGE_HPTEFLAGS |		\
 			 _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_SPLITTING | \
-			 _PAGE_THP_HUGE)
+			 _PAGE_THP_HUGE | _PAGE_SOFT_DIRTY)
 
 #ifndef __ASSEMBLY__
 /*
@@ -513,6 +517,11 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
 #define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
 #define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
 
+#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
+#define pmd_soft_dirty(pmd)	pte_soft_dirty(pmd_pte(pmd))
+#define pmd_mksoft_dirty(pmd)	pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
+#endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
+
 #define __HAVE_ARCH_PMD_WRITE
 #define pmd_write(pmd)		pte_write(pmd_pte(pmd))
 
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 0717693c8428..88baad3d66e2 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -38,6 +38,44 @@ static inline int pte_special(pte_t pte)	{ return pte_val(pte) & _PAGE_SPECIAL;
 static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK) == 0; }
 static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
 
+#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
+static inline int pte_soft_dirty(pte_t pte)
+{
+	return pte_val(pte) & _PAGE_SOFT_DIRTY;
+}
+static inline pte_t pte_mksoft_dirty(pte_t pte)
+{
+	pte_val(pte) |= _PAGE_SOFT_DIRTY;
+	return pte;
+}
+
+static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
+{
+	pte_val(pte) |= _PAGE_SWP_SOFT_DIRTY;
+	return pte;
+}
+static inline int pte_swp_soft_dirty(pte_t pte)
+{
+	return pte_val(pte) & _PAGE_SWP_SOFT_DIRTY;
+}
+static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
+{
+	pte_val(pte) &= ~_PAGE_SWP_SOFT_DIRTY;
+	return pte;
+}
+
+static inline pte_t pte_clear_flags(pte_t pte, pte_basic_t clear)
+{
+	pte_val(pte) &= ~clear;
+	return pte;
+}
+static inline pmd_t pmd_clear_flags(pmd_t pmd, unsigned long clear)
+{
+	pmd_val(pmd) &= ~clear;
+	return pmd;
+}
+#endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * These work without NUMA balancing but the kernel does not care. See the
@@ -89,7 +127,7 @@ static inline pte_t pte_mkwrite(pte_t pte) {
 	pte_val(pte) &= ~_PAGE_RO;
 	pte_val(pte) |= _PAGE_RW; return pte; }
 static inline pte_t pte_mkdirty(pte_t pte) {
-	pte_val(pte) |= _PAGE_DIRTY; return pte; }
+	pte_val(pte) |= _PAGE_DIRTY | _PAGE_SOFT_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte) {
 	pte_val(pte) |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkspecial(pte_t pte) {
diff --git a/arch/powerpc/include/asm/pte-book3e.h b/arch/powerpc/include/asm/pte-book3e.h
index 8d8473278d91..df5581f817f6 100644
--- a/arch/powerpc/include/asm/pte-book3e.h
+++ b/arch/powerpc/include/asm/pte-book3e.h
@@ -57,6 +57,7 @@
 
 #define _PAGE_HASHPTE	0
 #define _PAGE_BUSY	0
+#define _PAGE_SOFT_DIRTY	0
 
 #define _PAGE_SPECIAL	_PAGE_SW0
 
diff --git a/arch/powerpc/include/asm/pte-common.h b/arch/powerpc/include/asm/pte-common.h
index 71537a319fc8..1bf670996df5 100644
--- a/arch/powerpc/include/asm/pte-common.h
+++ b/arch/powerpc/include/asm/pte-common.h
@@ -94,13 +94,14 @@ extern unsigned long bad_call_to_PMD_PAGE_SIZE(void);
  * pgprot changes
  */
 #define _PAGE_CHG_MASK	(PTE_RPN_MASK | _PAGE_HPTEFLAGS | _PAGE_DIRTY | \
-                         _PAGE_ACCESSED | _PAGE_SPECIAL)
+			 _PAGE_ACCESSED | _PAGE_SPECIAL | _PAGE_SOFT_DIRTY)
 
 /* Mask of bits returned by pte_pgprot() */
 #define PAGE_PROT_BITS	(_PAGE_GUARDED | _PAGE_COHERENT | _PAGE_NO_CACHE | \
 			 _PAGE_WRITETHRU | _PAGE_ENDIAN | _PAGE_4K_PFN | \
 			 _PAGE_USER | _PAGE_ACCESSED | _PAGE_RO | \
-			 _PAGE_RW | _PAGE_HWWRITE | _PAGE_DIRTY | _PAGE_EXEC)
+			 _PAGE_RW | _PAGE_HWWRITE | _PAGE_DIRTY | \
+			 _PAGE_EXEC | _PAGE_SOFT_DIRTY)
 
 /*
  * We define 2 sets of base prot bits, one for basic pages (ie,
diff --git a/arch/powerpc/include/asm/pte-hash64.h b/arch/powerpc/include/asm/pte-hash64.h
index ef612c160da7..19ffd150957f 100644
--- a/arch/powerpc/include/asm/pte-hash64.h
+++ b/arch/powerpc/include/asm/pte-hash64.h
@@ -19,6 +19,7 @@
 #define _PAGE_BIT_SWAP_TYPE	2
 #define _PAGE_EXEC		0x0004 /* No execute on POWER4 and newer (we invert) */
 #define _PAGE_GUARDED		0x0008
+#define _PAGE_SOFT_DIRTY	0x0010 /* software dirty tracking */
 /* We can derive Memory coherence from _PAGE_NO_CACHE */
 #define _PAGE_NO_CACHE		0x0020 /* I: cache inhibit */
 #define _PAGE_WRITETHRU		0x0040 /* W: cache write-through */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
