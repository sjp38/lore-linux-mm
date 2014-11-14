Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1CB6B00CD
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 08:33:13 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id k14so129040wgh.10
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 05:33:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jq2si2286379wjc.53.2014.11.14.05.33.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 05:33:09 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/7] mm: Add p[te|md] protnone helpers for use by NUMA balancing
Date: Fri, 14 Nov 2014 13:33:00 +0000
Message-Id: <1415971986-16143-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1415971986-16143-1-git-send-email-mgorman@suse.de>
References: <1415971986-16143-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

This is a preparatory patch that introduces protnone helpers for automatic
NUMA balancing.

Needs-signed-off: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Needs-signed-off: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/powerpc/include/asm/pgtable.h | 11 +++++++++++
 arch/x86/include/asm/pgtable.h     | 16 ++++++++++++++++
 include/asm-generic/pgtable.h      | 19 +++++++++++++++++++
 3 files changed, 46 insertions(+)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 316f9a5..452c3b4 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -39,6 +39,17 @@ static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK)
 static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
 
 #ifdef CONFIG_NUMA_BALANCING
+static inline int pte_protnone_numa(pte_t pte)
+{
+	return (pte_val(pte) &
+		(_PAGE_PRESENT | _PAGE_USER)) == _PAGE_PRESENT;
+}
+
+static inline int pmd_protnone_numa(pmd_t pmd)
+{
+	return pte_protnone_numa(pmd_pte(pmd));
+}
+
 static inline int pte_present(pte_t pte)
 {
 	return pte_val(pte) & _PAGE_NUMA_MASK;
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index aa97a07..613cd00 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -497,6 +497,22 @@ static inline int pmd_present(pmd_t pmd)
 				 _PAGE_NUMA);
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+/*
+ * These work without NUMA balancing but the kernel does not care. See the
+ * comment in include/asm-generic/pgtable.h
+ */
+static inline int pte_protnone_numa(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_PROTNONE;
+}
+
+static inline int pmd_protnone_numa(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_PROTNONE;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 static inline int pmd_none(pmd_t pmd)
 {
 	/* Only check low word on 32-bit platforms, since it might be
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 752e30d..7e74122 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -677,6 +677,25 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
+#ifndef CONFIG_NUMA_BALANCING
+/*
+ * Technically a PTE can be PROTNONE even when not doing NUMA balancing but
+ * the only case the kernel cares is for NUMA balancing. By default,
+ * implement the helper as "always no". Note that this does not check VMA
+ * protection bits meaning that it is up to the caller to distinguish between
+ * PROT_NONE protections and NUMA hinting fault protections.
+ */
+static inline int pte_protnone_numa(pte_t pte)
+{
+	return 0;
+}
+
+static inline int pmd_protnone_numa(pmd_t pmd)
+{
+	return 0;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * _PAGE_NUMA distinguishes between an unmapped page table entry, an entry that
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
