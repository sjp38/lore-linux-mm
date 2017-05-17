Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 803056B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 00:28:23 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 99so459053qku.9
        for <linux-mm@kvack.org>; Tue, 16 May 2017 21:28:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g35si921071qtg.213.2017.05.16.21.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 21:28:22 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4H4JcqW038966
	for <linux-mm@kvack.org>; Wed, 17 May 2017 00:28:22 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2agf3t8yr4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 17 May 2017 00:28:21 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 22:28:20 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v3 1/2] mm/hugetlb: Cleanup ARCH_HAS_GIGANTIC_PAGE
Date: Wed, 17 May 2017 09:58:11 +0530
Message-Id: <1494995292-4443-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This moves the #ifdef in C code to a Kconfig dependency. Also we move the
gigantic_page_supported() function to be arch specific. This gives arch to
conditionally enable runtime allocation of gigantic huge page. Architectures
like ppc64 supports different gigantic huge page size (16G and 1G) based on the
translation mode selected. This provides an opportunity for ppc64 to enable
runtime allocation only w.r.t 1G hugepage.

No functional change in this patch.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
Changes from V2:
* Fix build error with x86
* Update the Kconfig change to match the C #ifdef

 arch/arm64/Kconfig               | 2 +-
 arch/arm64/include/asm/hugetlb.h | 4 ++++
 arch/s390/Kconfig                | 2 +-
 arch/s390/include/asm/hugetlb.h  | 3 +++
 arch/x86/Kconfig                 | 2 +-
 arch/x86/include/asm/hugetlb.h   | 4 ++++
 mm/hugetlb.c                     | 7 ++-----
 7 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3741859765cf..87240dcb6a07 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -11,7 +11,7 @@ config ARM64
 	select ARCH_HAS_ACPI_TABLE_UPGRADE if ACPI
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index bbc1e35aa601..793bd73b0d07 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -83,4 +83,8 @@ extern void huge_ptep_set_wrprotect(struct mm_struct *mm,
 extern void huge_ptep_clear_flush(struct vm_area_struct *vma,
 				  unsigned long addr, pte_t *ptep);
 
+#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
+static inline bool gigantic_page_supported(void) { return true; }
+#endif
+
 #endif /* __ASM_HUGETLB_H */
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index a2dcef0aacc7..f3637b641d7e 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -67,7 +67,7 @@ config S390
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_SET_MEMORY
 	select ARCH_HAS_SG_CHAIN
diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index cd546a245c68..89057b2cc8fe 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -112,4 +112,7 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
 	return pte_modify(pte, newprot);
 }
 
+#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
+static inline bool gigantic_page_supported(void) { return true; }
+#endif
 #endif /* _ASM_S390_HUGETLB_H */
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cc98d5a294ee..e39b3b6b7d16 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -22,7 +22,7 @@ config X86_64
 	def_bool y
 	depends on 64BIT
 	# Options that are inherently 64-bit kernel only:
-	select ARCH_HAS_GIGANTIC_PAGE
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_SUPPORTS_INT128
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_SOFT_DIRTY
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 3a106165e03a..535af0f2d8ac 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -85,4 +85,8 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
+#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
+static inline bool gigantic_page_supported(void) { return true; }
+#endif
+
 #endif /* _ASM_X86_HUGETLB_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3d0aab9ee80d..ce090186b992 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1024,9 +1024,7 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
 		nr_nodes--)
 
-#if defined(CONFIG_ARCH_HAS_GIGANTIC_PAGE) && \
-	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
-	defined(CONFIG_CMA))
+#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
 static void destroy_compound_gigantic_page(struct page *page,
 					unsigned int order)
 {
@@ -1158,8 +1156,7 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 	return 0;
 }
 
-static inline bool gigantic_page_supported(void) { return true; }
-#else
+#else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
 static inline bool gigantic_page_supported(void) { return false; }
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
