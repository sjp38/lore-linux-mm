Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 51AA58309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:01 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id xk3so144717190obc.2
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:01 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id dh4si15271133oec.96.2016.02.08.01.21.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:00 -0800 (PST)
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:00 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2254A3E4003F
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:20:58 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189Kw8I24903730
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:20:58 -0700
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189KvfG030672
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:20:57 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 02/29] powerpc/mm: Split pgtable types to separate header
Date: Mon,  8 Feb 2016 14:50:14 +0530
Message-Id: <1454923241-6681-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We remove real_pte_t out of STRICT_MM_TYPESCHECK. We will later add
a radix variant that is big endian

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h |   5 --
 arch/powerpc/include/asm/page.h              | 104 +--------------------------
 arch/powerpc/include/asm/pgtable-types.h     | 100 ++++++++++++++++++++++++++
 3 files changed, 101 insertions(+), 108 deletions(-)
 create mode 100644 arch/powerpc/include/asm/pgtable-types.h

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 0415856941e0..682958f85052 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -43,13 +43,8 @@
  */
 #ifndef __real_pte
 
-#ifdef CONFIG_STRICT_MM_TYPECHECKS
 #define __real_pte(e,p)		((real_pte_t){(e)})
 #define __rpte_to_pte(r)	((r).pte)
-#else
-#define __real_pte(e,p)		(e)
-#define __rpte_to_pte(r)	(__pte(r))
-#endif
 #define __rpte_to_hidx(r,index)	(pte_val(__rpte_to_pte(r)) >>_PAGE_F_GIX_SHIFT)
 
 #define pte_iterate_hashed_subpages(rpte, psize, va, index, shift)       \
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index e34124f6fbf2..3a3f073f7222 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -281,109 +281,7 @@ extern long long virt_phys_offset;
 
 #ifndef __ASSEMBLY__
 
-#ifdef CONFIG_STRICT_MM_TYPECHECKS
-/* These are used to make use of C type-checking. */
-
-/* PTE level */
-typedef struct { pte_basic_t pte; } pte_t;
-#define __pte(x)	((pte_t) { (x) })
-static inline pte_basic_t pte_val(pte_t x)
-{
-	return x.pte;
-}
-
-/* 64k pages additionally define a bigger "real PTE" type that gathers
- * the "second half" part of the PTE for pseudo 64k pages
- */
-#if defined(CONFIG_PPC_64K_PAGES) && defined(CONFIG_PPC_STD_MMU_64)
-typedef struct { pte_t pte; unsigned long hidx; } real_pte_t;
-#else
-typedef struct { pte_t pte; } real_pte_t;
-#endif
-
-/* PMD level */
-#ifdef CONFIG_PPC64
-typedef struct { unsigned long pmd; } pmd_t;
-#define __pmd(x)	((pmd_t) { (x) })
-static inline unsigned long pmd_val(pmd_t x)
-{
-	return x.pmd;
-}
-
-/* PUD level exusts only on 4k pages */
-#ifndef CONFIG_PPC_64K_PAGES
-typedef struct { unsigned long pud; } pud_t;
-#define __pud(x)	((pud_t) { (x) })
-static inline unsigned long pud_val(pud_t x)
-{
-	return x.pud;
-}
-#endif /* !CONFIG_PPC_64K_PAGES */
-#endif /* CONFIG_PPC64 */
-
-/* PGD level */
-typedef struct { unsigned long pgd; } pgd_t;
-#define __pgd(x)	((pgd_t) { (x) })
-static inline unsigned long pgd_val(pgd_t x)
-{
-	return x.pgd;
-}
-
-/* Page protection bits */
-typedef struct { unsigned long pgprot; } pgprot_t;
-#define pgprot_val(x)	((x).pgprot)
-#define __pgprot(x)	((pgprot_t) { (x) })
-
-#else
-
-/*
- * .. while these make it easier on the compiler
- */
-
-typedef pte_basic_t pte_t;
-#define __pte(x)	(x)
-static inline pte_basic_t pte_val(pte_t pte)
-{
-	return pte;
-}
-
-#if defined(CONFIG_PPC_64K_PAGES) && defined(CONFIG_PPC_STD_MMU_64)
-typedef struct { pte_t pte; unsigned long hidx; } real_pte_t;
-#else
-typedef pte_t real_pte_t;
-#endif
-
-
-#ifdef CONFIG_PPC64
-typedef unsigned long pmd_t;
-#define __pmd(x)	(x)
-static inline unsigned long pmd_val(pmd_t pmd)
-{
-	return pmd;
-}
-
-#ifndef CONFIG_PPC_64K_PAGES
-typedef unsigned long pud_t;
-#define __pud(x)	(x)
-static inline unsigned long pud_val(pud_t pud)
-{
-	return pud;
-}
-#endif /* !CONFIG_PPC_64K_PAGES */
-#endif /* CONFIG_PPC64 */
-
-typedef unsigned long pgd_t;
-#define __pgd(x)	(x)
-static inline unsigned long pgd_val(pgd_t pgd)
-{
-	return pgd;
-}
-
-typedef unsigned long pgprot_t;
-#define pgprot_val(x)	(x)
-#define __pgprot(x)	(x)
-
-#endif
+#include <asm/pgtable-types.h>
 
 typedef struct { signed long pd; } hugepd_t;
 
diff --git a/arch/powerpc/include/asm/pgtable-types.h b/arch/powerpc/include/asm/pgtable-types.h
new file mode 100644
index 000000000000..71487e1ca638
--- /dev/null
+++ b/arch/powerpc/include/asm/pgtable-types.h
@@ -0,0 +1,100 @@
+#ifndef _ASM_POWERPC_PGTABLE_TYPES_H
+#define _ASM_POWERPC_PGTABLE_TYPES_H
+
+#ifdef CONFIG_STRICT_MM_TYPECHECKS
+/* These are used to make use of C type-checking. */
+
+/* PTE level */
+typedef struct { pte_basic_t pte; } pte_t;
+#define __pte(x)	((pte_t) { (x) })
+static inline pte_basic_t pte_val(pte_t x)
+{
+	return x.pte;
+}
+
+/* PMD level */
+#ifdef CONFIG_PPC64
+typedef struct { unsigned long pmd; } pmd_t;
+#define __pmd(x)	((pmd_t) { (x) })
+static inline unsigned long pmd_val(pmd_t x)
+{
+	return x.pmd;
+}
+
+/* PUD level exusts only on 4k pages */
+#ifndef CONFIG_PPC_64K_PAGES
+typedef struct { unsigned long pud; } pud_t;
+#define __pud(x)	((pud_t) { (x) })
+static inline unsigned long pud_val(pud_t x)
+{
+	return x.pud;
+}
+#endif /* !CONFIG_PPC_64K_PAGES */
+#endif /* CONFIG_PPC64 */
+
+/* PGD level */
+typedef struct { unsigned long pgd; } pgd_t;
+#define __pgd(x)	((pgd_t) { (x) })
+static inline unsigned long pgd_val(pgd_t x)
+{
+	return x.pgd;
+}
+
+/* Page protection bits */
+typedef struct { unsigned long pgprot; } pgprot_t;
+#define pgprot_val(x)	((x).pgprot)
+#define __pgprot(x)	((pgprot_t) { (x) })
+
+#else
+
+/*
+ * .. while these make it easier on the compiler
+ */
+
+typedef pte_basic_t pte_t;
+#define __pte(x)	(x)
+static inline pte_basic_t pte_val(pte_t pte)
+{
+	return pte;
+}
+
+#ifdef CONFIG_PPC64
+typedef unsigned long pmd_t;
+#define __pmd(x)	(x)
+static inline unsigned long pmd_val(pmd_t pmd)
+{
+	return pmd;
+}
+
+#ifndef CONFIG_PPC_64K_PAGES
+typedef unsigned long pud_t;
+#define __pud(x)	(x)
+static inline unsigned long pud_val(pud_t pud)
+{
+	return pud;
+}
+#endif /* !CONFIG_PPC_64K_PAGES */
+#endif /* CONFIG_PPC64 */
+
+typedef unsigned long pgd_t;
+#define __pgd(x)	(x)
+static inline unsigned long pgd_val(pgd_t pgd)
+{
+	return pgd;
+}
+
+typedef unsigned long pgprot_t;
+#define pgprot_val(x)	(x)
+#define __pgprot(x)	(x)
+
+#endif /* CONFIG_STRICT_MM_TYPECHECKS */
+/*
+ * With hash config 64k pages additionally define a bigger "real PTE" type that
+ * gathers the "second half" part of the PTE for pseudo 64k pages
+ */
+#if defined(CONFIG_PPC_64K_PAGES) && defined(CONFIG_PPC_STD_MMU_64)
+typedef struct { pte_t pte; unsigned long hidx; } real_pte_t;
+#else
+typedef struct { pte_t pte; } real_pte_t;
+#endif
+#endif /* _ASM_POWERPC_PGTABLE_TYPES_H */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
