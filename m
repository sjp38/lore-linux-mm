Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B72E6B02E1
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:18:06 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w131so61361089qka.5
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:18:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g51si13376868qtf.126.2017.05.16.02.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:18:05 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4G9DvGT122443
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:18:05 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2afr988gf4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:18:05 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 05:18:04 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 2/2] powerpc/mm/hugetlb: Add support for 1G huge pages
Date: Tue, 16 May 2017 14:47:44 +0530
In-Reply-To: <1494926264-22463-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494926264-22463-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1494926264-22463-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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
index 684e886eaae4..80175000042d 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -344,6 +344,7 @@ config PPC_STD_MMU_64
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
+	select ARCH_HAS_GIGANTIC_PAGE if MEMORY_ISOLATION && COMPACTION && CMA
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
