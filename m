Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9E86B0070
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 06:24:42 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so8016919wid.17
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 03:24:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si45384935wiy.55.2014.12.04.03.24.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 03:24:38 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/10] mm: Add p[te|md] protnone helpers for use by NUMA balancing
Date: Thu,  4 Dec 2014 11:24:25 +0000
Message-Id: <1417692273-27170-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1417692273-27170-1-git-send-email-mgorman@suse.de>
References: <1417692273-27170-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Mel Gorman <mgorman@suse.de>

This is a preparatory patch that introduces protnone helpers for automatic
NUMA balancing.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 arch/powerpc/include/asm/pgtable.h | 16 ++++++++++++++++
 arch/x86/include/asm/pgtable.h     | 16 ++++++++++++++++
 include/asm-generic/pgtable.h      | 20 ++++++++++++++++++++
 3 files changed, 52 insertions(+)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index a8805fe..7b889a3 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -39,6 +39,22 @@ static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK)
 static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
 
 #ifdef CONFIG_NUMA_BALANCING
+/*
+ * These work without NUMA balancing but the kernel does not care. See the
+ * comment in include/asm-generic/pgtable.h . On powerpc, this will only
+ * work for user pages and always return true for kernel pages.
+ */
+static inline int pte_protnone(pte_t pte)
+{
+	return (pte_val(pte) &
+		(_PAGE_PRESENT | _PAGE_USER)) == _PAGE_PRESENT;
+}
+
+static inline int pmd_protnone(pmd_t pmd)
+{
+	return pte_protnone(pmd_pte(pmd));
+}
+
 static inline int pte_present(pte_t pte)
 {
 	return pte_val(pte) & _PAGE_NUMA_MASK;
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 081d6f4..2e25780 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -502,6 +502,22 @@ static inline int pmd_present(pmd_t pmd)
 				 _PAGE_NUMA);
 }
 
+#ifdef CONFIG_NUMA_BALANCING
+/*
+ * These work without NUMA balancing but the kernel does not care. See the
+ * comment in include/asm-generic/pgtable.h
+ */
+static inline int pte_protnone(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_PROTNONE;
+}
+
+static inline int pmd_protnone(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_PROTNONE;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 static inline int pmd_none(pmd_t pmd)
 {
 	/* Only check low word on 32-bit platforms, since it might be
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 177d597..d497d08 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -688,6 +688,26 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
+#ifndef CONFIG_NUMA_BALANCING
+/*
+ * Technically a PTE can be PROTNONE even when not doing NUMA balancing but
+ * the only case the kernel cares is for NUMA balancing and is only ever set
+ * when the VMA is accessible. For PROT_NONE VMAs, the PTEs are not marked
+ * _PAGE_PROTNONE so by by default, implement the helper as "always no". It
+ * is the responsibility of the caller to distinguish between PROT_NONE
+ * protections and NUMA hinting fault protections.
+ */
+static inline int pte_protnone(pte_t pte)
+{
+	return 0;
+}
+
+static inline int pmd_protnone(pmd_t pmd)
+{
+	return 0;
+}
+#endif /* CONFIG_NUMA_BALANCING */
+
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * _PAGE_NUMA distinguishes between an unmapped page table entry, an entry that
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
