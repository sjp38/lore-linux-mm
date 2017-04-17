Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDC92806CB
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:14:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m1so95537125pgd.13
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 10:14:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 44si11763737pla.332.2017.04.17.10.14.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 10:14:37 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HHE3lw129519
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:14:37 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29ug1cm5f6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:14:37 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 17 Apr 2017 13:14:35 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] powerpc/mm/hugetlb: Add support for 1G huge pages
Date: Mon, 17 Apr 2017 22:44:15 +0530
Message-Id: <1492449255-29062-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

POWER9 supports hugepages of size 2M and 1G in radix MMU mode. This patch
enables the usage of 1G page size for hugetlbfs. This also update the helper
such we can do 1G page allocation at runtime.

Since we can do this only when radix translation mode is enabled, we can't use
the generic gigantic_page_supported helper. Hence provide a way for architecture
to override gigantic_page_supported helper.

We still don't enable 1G page size on DD1 version. This is to avoid doing
workaround mentioned in commit: 6d3a0379ebdc8 (powerpc/mm: Add
radix__tlb_flush_pte_p9_dd1()

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hugetlb.h | 13 +++++++++++++
 arch/powerpc/mm/hugetlbpage.c                |  7 +++++--
 arch/powerpc/platforms/Kconfig.cputype       |  1 +
 mm/hugetlb.c                                 |  4 ++++
 4 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index 6666cd366596..86f27cc8ec61 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -50,4 +50,17 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 	else
 		return entry;
 }
+
+#if defined(CONFIG_ARCH_HAS_GIGANTIC_PAGE) &&				\
+	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
+	 defined(CONFIG_CMA))
+#define gigantic_page_supported gigantic_page_supported
+static inline bool gigantic_page_supported(void)
+{
+	if (radix_enabled())
+		return true;
+	return false;
+}
+#endif
+
 #endif
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index a4f33de4008e..80f6d2ed551a 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -763,8 +763,11 @@ static int __init add_huge_page_size(unsigned long long size)
 	 * Hash: 16M and 16G
 	 */
 	if (radix_enabled()) {
-		if (mmu_psize != MMU_PAGE_2M)
-			return -EINVAL;
+		if (mmu_psize != MMU_PAGE_2M) {
+			if (cpu_has_feature(CPU_FTR_POWER9_DD1) ||
+			    (mmu_psize != MMU_PAGE_1G))
+				return -EINVAL;
+		}
 	} else {
 		if (mmu_psize != MMU_PAGE_16M && mmu_psize != MMU_PAGE_16G)
 			return -EINVAL;
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index ef4c4b8fc547..f4ba4bf0d762 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -343,6 +343,7 @@ config PPC_STD_MMU_64
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
+	select ARCH_HAS_GIGANTIC_PAGE
 	default y
 	help
 	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3d0aab9ee80d..2c090189f314 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1158,7 +1158,11 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 	return 0;
 }
 
+#ifndef gigantic_page_supported
 static inline bool gigantic_page_supported(void) { return true; }
+#define gigantic_page_supported gigantic_page_supported
+#endif
+
 #else
 static inline bool gigantic_page_supported(void) { return false; }
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
