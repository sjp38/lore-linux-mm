Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26D566B026A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:40 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t138-v6so7947216oih.5
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:19:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d188-v6si10359281oih.266.2018.07.25.09.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 09:19:39 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6PGE3gf097769
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:38 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kevhe89b5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:19:38 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 25 Jul 2018 12:19:37 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V2 6/6] powerpc/mm:book3s: Enable THP migration support
Date: Wed, 25 Jul 2018 21:49:03 +0530
In-Reply-To: <20180725161903.31257-1-aneesh.kumar@linux.ibm.com>
References: <20180725161903.31257-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20180725161903.31257-6-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 8 ++++++++
 arch/powerpc/platforms/Kconfig.cputype       | 1 +
 2 files changed, 9 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 8b80c5e16896..2f12732952f0 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -734,6 +734,8 @@ static inline bool pte_user(pte_t pte)
  */
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val((pte)) & ~_PAGE_PTE })
 #define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
+#define __pmd_to_swp_entry(pmd)	(__pte_to_swp_entry(pmd_pte(pmd)))
+#define __swp_entry_to_pmd(x)	(pte_pmd(__swp_entry_to_pte(x)))
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
@@ -1084,6 +1086,12 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
 #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
 #define pmd_mksoft_dirty(pmd)  pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
 #define pmd_clear_soft_dirty(pmd) pte_pmd(pte_clear_soft_dirty(pmd_pte(pmd)))
+
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#define pmd_swp_mksoft_dirty(pmd)	pte_pmd(pte_swp_mksoft_dirty(pmd_pte(pmd)))
+#define pmd_swp_soft_dirty(pmd)		pte_swp_soft_dirty(pmd_pte(pmd))
+#define pmd_swp_clear_soft_dirty(pmd)	pte_pmd(pte_swp_clear_soft_dirty(pmd_pte(pmd)))
+#endif
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index e93d6186de6e..f83ca0ca3bd8 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -72,6 +72,7 @@ config PPC_BOOK3S_64
 	select PPC_HAVE_PMU_SUPPORT
 	select SYS_SUPPORTS_HUGETLBFS
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	select ARCH_ENABLE_THP_MIGRATION if TRANSPARENT_HUGEPAGE
 	select ARCH_SUPPORTS_NUMA_BALANCING
 	select IRQ_WORK
 
-- 
2.17.1
