Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 501FD6B0256
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 11:22:25 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so116966916wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:22:24 -0700 (PDT)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id lk14si17841638wic.120.2015.09.21.08.22.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Sep 2015 08:22:23 -0700 (PDT)
Received: from /spool/local
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 21 Sep 2015 16:22:22 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id D334E1B08067
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:24:04 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8LFMLFi32833642
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 15:22:21 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8LEML5F009190
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:22:22 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 2/2] s390/mm: implement soft-dirty bits for user memory change tracking
Date: Mon, 21 Sep 2015 17:22:20 +0200
Message-Id: <1442848940-22108-3-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1442848940-22108-1-git-send-email-schwidefsky@de.ibm.com>
References: <1442848940-22108-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

Use bit 2**1 of the pte and bit 2**14 of the pmd for the soft dirty
bit. The fault mechanism to do dirty tracking is already in place.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/Kconfig               |  1 +
 arch/s390/include/asm/pgtable.h | 59 ++++++++++++++++++++++++++++++++++++++---
 arch/s390/mm/hugetlbpage.c      |  2 ++
 3 files changed, 58 insertions(+), 4 deletions(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 1d57000..44cb7de 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -118,6 +118,7 @@ config S390
 	select HAVE_ARCH_EARLY_PFN_TO_NID
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_SECCOMP_FILTER
+	select HAVE_ARCH_SOFT_DIRTY
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select HAVE_BPF_JIT if PACK_STACK && HAVE_MARCH_Z196_FEATURES
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index bdb2f51..4d7e2e9 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -193,9 +193,15 @@ static inline int is_module_addr(void *addr)
 #define _PAGE_UNUSED	0x080		/* SW bit for pgste usage state */
 #define __HAVE_ARCH_PTE_SPECIAL
 
+#ifdef CONFIG_MEM_SOFT_DIRTY
+#define _PAGE_SOFT_DIRTY 0x002		/* SW pte soft dirty bit */
+#else
+#define _PAGE_SOFT_DIRTY 0x000
+#endif
+
 /* Set of bits not changed in pte_modify */
 #define _PAGE_CHG_MASK		(PAGE_MASK | _PAGE_SPECIAL | _PAGE_DIRTY | \
-				 _PAGE_YOUNG)
+				 _PAGE_YOUNG | _PAGE_SOFT_DIRTY)
 
 /*
  * handle_pte_fault uses pte_present and pte_none to find out the pte type
@@ -285,6 +291,12 @@ static inline int is_module_addr(void *addr)
 #define _SEGMENT_ENTRY_READ	0x0002	/* SW segment read bit */
 #define _SEGMENT_ENTRY_WRITE	0x0001	/* SW segment write bit */
 
+#ifdef CONFIG_MEM_SOFT_DIRTY
+#define _SEGMENT_ENTRY_SOFT_DIRTY 0x4000 /* SW segment soft dirty bit */
+#else
+#define _SEGMENT_ENTRY_SOFT_DIRTY 0x0000 /* SW segment soft dirty bit */
+#endif
+
 /*
  * Segment table entry encoding (R = read-only, I = invalid, y = young bit):
  *				dy..R...I...wr
@@ -589,6 +601,43 @@ static inline int pmd_protnone(pmd_t pmd)
 }
 #endif
 
+static inline int pte_soft_dirty(pte_t pte)
+{
+	return pte_val(pte) & _PAGE_SOFT_DIRTY;
+}
+#define pte_swp_soft_dirty pte_soft_dirty
+
+static inline pte_t pte_mksoft_dirty(pte_t pte)
+{
+	pte_val(pte) |= _PAGE_SOFT_DIRTY;
+	return pte;
+}
+#define pte_swp_mksoft_dirty pte_mksoft_dirty
+
+static inline pte_t pte_clear_soft_dirty(pte_t pte)
+{
+	pte_val(pte) &= ~_PAGE_SOFT_DIRTY;
+	return pte;
+}
+#define pte_swp_clear_soft_dirty pte_clear_soft_dirty
+
+static inline int pmd_soft_dirty(pmd_t pmd)
+{
+	return pmd_val(pmd) & _SEGMENT_ENTRY_SOFT_DIRTY;
+}
+
+static inline pmd_t pmd_mksoft_dirty(pmd_t pmd)
+{
+	pmd_val(pmd) |= _SEGMENT_ENTRY_SOFT_DIRTY;
+	return pmd;
+}
+
+static inline pmd_t pmd_clear_soft_dirty(pmd_t pmd)
+{
+	pmd_val(pmd) &= ~_SEGMENT_ENTRY_SOFT_DIRTY;
+	return pmd;
+}
+
 static inline pgste_t pgste_get_lock(pte_t *ptep)
 {
 	unsigned long new = 0;
@@ -889,7 +938,7 @@ static inline pte_t pte_mkclean(pte_t pte)
 
 static inline pte_t pte_mkdirty(pte_t pte)
 {
-	pte_val(pte) |= _PAGE_DIRTY;
+	pte_val(pte) |= _PAGE_DIRTY | _PAGE_SOFT_DIRTY;
 	if (pte_val(pte) & _PAGE_WRITE)
 		pte_val(pte) &= ~_PAGE_PROTECT;
 	return pte;
@@ -1340,7 +1389,8 @@ static inline pmd_t pmd_mkclean(pmd_t pmd)
 static inline pmd_t pmd_mkdirty(pmd_t pmd)
 {
 	if (pmd_large(pmd)) {
-		pmd_val(pmd) |= _SEGMENT_ENTRY_DIRTY;
+		pmd_val(pmd) |= _SEGMENT_ENTRY_DIRTY |
+				_SEGMENT_ENTRY_SOFT_DIRTY;
 		if (pmd_val(pmd) & _SEGMENT_ENTRY_WRITE)
 			pmd_val(pmd) &= ~_SEGMENT_ENTRY_PROTECT;
 	}
@@ -1371,7 +1421,8 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 	if (pmd_large(pmd)) {
 		pmd_val(pmd) &= _SEGMENT_ENTRY_ORIGIN_LARGE |
 			_SEGMENT_ENTRY_DIRTY | _SEGMENT_ENTRY_YOUNG |
-			_SEGMENT_ENTRY_LARGE | _SEGMENT_ENTRY_SPLIT;
+			_SEGMENT_ENTRY_LARGE | _SEGMENT_ENTRY_SPLIT |
+			_SEGMENT_ENTRY_SOFT_DIRTY;
 		pmd_val(pmd) |= massage_pgprot_pmd(newprot);
 		if (!(pmd_val(pmd) & _SEGMENT_ENTRY_DIRTY))
 			pmd_val(pmd) |= _SEGMENT_ENTRY_PROTECT;
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index fb4bf2c..f81096b 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -40,6 +40,7 @@ static inline pmd_t __pte_to_pmd(pte_t pte)
 		pmd_val(pmd) |= (pte_val(pte) & _PAGE_PROTECT);
 		pmd_val(pmd) |= (pte_val(pte) & _PAGE_DIRTY) << 10;
 		pmd_val(pmd) |= (pte_val(pte) & _PAGE_YOUNG) << 10;
+		pmd_val(pmd) |= (pte_val(pte) & _PAGE_SOFT_DIRTY) << 13;
 	} else
 		pmd_val(pmd) = _SEGMENT_ENTRY_INVALID;
 	return pmd;
@@ -78,6 +79,7 @@ static inline pte_t __pmd_to_pte(pmd_t pmd)
 		pte_val(pte) |= (pmd_val(pmd) & _SEGMENT_ENTRY_PROTECT);
 		pte_val(pte) |= (pmd_val(pmd) & _SEGMENT_ENTRY_DIRTY) >> 10;
 		pte_val(pte) |= (pmd_val(pmd) & _SEGMENT_ENTRY_YOUNG) >> 10;
+		pte_val(pte) |= (pmd_val(pmd) & _SEGMENT_ENTRY_SOFT_DIRTY) >> 13;
 	} else
 		pte_val(pte) = _PAGE_INVALID;
 	return pte;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
