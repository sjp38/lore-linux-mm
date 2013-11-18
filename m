Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id AD8996B0037
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 04:28:37 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so1981416pdj.29
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 01:28:37 -0800 (PST)
Received: from psmtp.com ([74.125.245.116])
        by mx.google.com with SMTP id sw1si9176011pbc.42.2013.11.18.01.28.35
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 01:28:36 -0800 (PST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 18 Nov 2013 19:28:33 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E136B2BB0054
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:29 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAI9AjpH4391268
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:10:45 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAI9STiB019803
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:29 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 5/5] powerpc: mm: book3s: Enable _PAGE_NUMA for book3s
Date: Mon, 18 Nov 2013 14:58:13 +0530
Message-Id: <1384766893-10189-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We steal the _PAGE_COHERENCE bit and use that for indicating NUMA ptes.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable.h     | 66 +++++++++++++++++++++++++++++++++-
 arch/powerpc/include/asm/pte-hash64.h  |  6 ++++
 arch/powerpc/platforms/Kconfig.cputype |  1 +
 3 files changed, 72 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 7d6eacf249cf..b999ca318985 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -3,6 +3,7 @@
 #ifdef __KERNEL__
 
 #ifndef __ASSEMBLY__
+#include <linux/mmdebug.h>
 #include <asm/processor.h>		/* For TASK_SIZE */
 #include <asm/mmu.h>
 #include <asm/page.h>
@@ -33,10 +34,73 @@ static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_special(pte_t pte)	{ return pte_val(pte) & _PAGE_SPECIAL; }
-static inline int pte_present(pte_t pte)	{ return pte_val(pte) & _PAGE_PRESENT; }
 static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK) == 0; }
 static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
 
+#ifdef CONFIG_NUMA_BALANCING
+
+static inline int pte_present(pte_t pte)
+{
+	return pte_val(pte) & (_PAGE_PRESENT | _PAGE_NUMA);
+}
+
+#define pte_numa pte_numa
+static inline int pte_numa(pte_t pte)
+{
+	return (pte_val(pte) &
+		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+}
+
+#define pte_mknonnuma pte_mknonnuma
+static inline pte_t pte_mknonnuma(pte_t pte)
+{
+	pte_val(pte) &= ~_PAGE_NUMA;
+	pte_val(pte) |=  _PAGE_PRESENT | _PAGE_ACCESSED;
+	return pte;
+}
+
+#define pte_mknuma pte_mknuma
+static inline pte_t pte_mknuma(pte_t pte)
+{
+	/*
+	 * We should not set _PAGE_NUMA on non present ptes. Also clear the
+	 * present bit so that hash_page will return 1 and we collect this
+	 * as numa fault.
+	 */
+	if (pte_present(pte)) {
+		pte_val(pte) |= _PAGE_NUMA;
+		pte_val(pte) &= ~_PAGE_PRESENT;
+	} else
+		VM_BUG_ON(1);
+	return pte;
+}
+
+#define pmd_numa pmd_numa
+static inline int pmd_numa(pmd_t pmd)
+{
+	return pte_numa(pmd_pte(pmd));
+}
+
+#define pmd_mknonnuma pmd_mknonnuma
+static inline pmd_t pmd_mknonnuma(pmd_t pmd)
+{
+	return pte_pmd(pte_mknonnuma(pmd_pte(pmd)));
+}
+
+#define pmd_mknuma pmd_mknuma
+static inline pmd_t pmd_mknuma(pmd_t pmd)
+{
+	return pte_pmd(pte_mknuma(pmd_pte(pmd)));
+}
+
+# else
+
+static inline int pte_present(pte_t pte)
+{
+	return pte_val(pte) & _PAGE_PRESENT;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 /* Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
  *
diff --git a/arch/powerpc/include/asm/pte-hash64.h b/arch/powerpc/include/asm/pte-hash64.h
index 55aea0caf95e..2505d8eab15c 100644
--- a/arch/powerpc/include/asm/pte-hash64.h
+++ b/arch/powerpc/include/asm/pte-hash64.h
@@ -27,6 +27,12 @@
 #define _PAGE_RW		0x0200 /* software: user write access allowed */
 #define _PAGE_BUSY		0x0800 /* software: PTE & hash are busy */
 
+/*
+ * Used for tracking numa faults
+ */
+#define _PAGE_NUMA	0x00000010 /* Gather numa placement stats */
+
+
 /* No separate kernel read-only */
 #define _PAGE_KERNEL_RW		(_PAGE_RW | _PAGE_DIRTY) /* user access blocked by key */
 #define _PAGE_KERNEL_RO		 _PAGE_KERNEL_RW
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index c2a566fb8bb8..2048655d8ec4 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -72,6 +72,7 @@ config PPC_BOOK3S_64
 	select PPC_HAVE_PMU_SUPPORT
 	select SYS_SUPPORTS_HUGETLBFS
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE if PPC_64K_PAGES
+	select ARCH_SUPPORTS_NUMA_BALANCING
 
 config PPC_BOOK3E_64
 	bool "Embedded processors"
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
