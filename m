Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 403BF6B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 00:28:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o25so1156314pgc.1
        for <linux-mm@kvack.org>; Tue, 16 May 2017 21:28:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b21si957228pgn.66.2017.05.16.21.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 21:28:29 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4H4JDNw143800
	for <linux-mm@kvack.org>; Wed, 17 May 2017 00:28:29 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2agf2615mx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 17 May 2017 00:28:28 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 22:28:27 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v3 2/2] powerpc/mm/hugetlb: Add support for 1G huge pages
Date: Wed, 17 May 2017 09:58:12 +0530
In-Reply-To: <1494995292-4443-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494995292-4443-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1494995292-4443-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

POWER9 supports hugepages of size 2M and 1G in radix MMU mode. This patch
enables the usage of 1G page size for hugetlbfs. This also update the helper
such we can do 1G page allocation at runtime.

We still don't enable 1G page size on DD1 version. This is to avoid doing
workaround mentioned in commit: 6d3a0379ebdc8 (powerpc/mm: Add
radix__tlb_flush_pte_p9_dd1()

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hugetlb.h | 10 ++++++++++
 arch/powerpc/mm/hugetlbpage.c                |  7 +++++--
 arch/powerpc/platforms/Kconfig.cputype       |  1 +
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index 6666cd366596..5c28bd6f2ae1 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -50,4 +50,14 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 	else
 		return entry;
 }
+
+#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
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
index 684e886eaae4..b76ef6637016 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -344,6 +344,7 @@ config PPC_STD_MMU_64
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	default y
 	help
 	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
