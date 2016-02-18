Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id BEAED828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:51:28 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id y9so41765193qgd.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 08:51:28 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id x83si8805660qhc.68.2016.02.18.08.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 08:51:28 -0800 (PST)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 18 Feb 2016 09:51:26 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3FE9819D8042
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:39:21 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1IGpNSY22020124
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:51:23 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1IGpN39015173
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:51:23 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3 04/30] powerpc/mm: Split pgtable types to separate header
Date: Thu, 18 Feb 2016 22:20:28 +0530
Message-Id: <1455814254-10226-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We move the page table accessors into a separate header. We will
later add a big endian variant of the table which is needed for radix.
No functionality change only code movement.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/page.h          | 104 +----------------------------
 arch/powerpc/include/asm/pgtable-types.h | 108 +++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+), 103 deletions(-)
 create mode 100644 arch/powerpc/include/asm/pgtable-types.h

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
index 000000000000..2fac0c4acfa4
--- /dev/null
+++ b/arch/powerpc/include/asm/pgtable-types.h
@@ -0,0 +1,108 @@
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
+/* 64k pages additionally define a bigger "real PTE" type that gathers
+ * the "second half" part of the PTE for pseudo 64k pages
+ */
+#if defined(CONFIG_PPC_64K_PAGES) && defined(CONFIG_PPC_STD_MMU_64)
+typedef struct { pte_t pte; unsigned long hidx; } real_pte_t;
+#else
+typedef struct { pte_t pte; } real_pte_t;
+#endif
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
+#if defined(CONFIG_PPC_64K_PAGES) && defined(CONFIG_PPC_STD_MMU_64)
+typedef struct { pte_t pte; unsigned long hidx; } real_pte_t;
+#else
+typedef pte_t real_pte_t;
+#endif
+
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
+#endif
+
+#endif /* _ASM_POWERPC_PGTABLE_TYPES_H */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
