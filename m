Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E35A16B0010
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:28:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a127so1796238wmh.6
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:28:54 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id l7si3726270edq.20.2018.04.26.07.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:28:52 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 6/9] powerpc: mm: migrate: add pmd swap entry to support thp migration.
Date: Thu, 26 Apr 2018 10:28:01 -0400
Message-Id: <20180426142804.180152-7-zi.yan@sent.com>
In-Reply-To: <20180426142804.180152-1-zi.yan@sent.com>
References: <20180426142804.180152-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ram Pai <linuxram@us.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linuxppc-dev@lists.ozlabs.org

From: Zi Yan <zi.yan@cs.rutgers.edu>

pmd swap soft dirty support is added, too.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org
---
 arch/powerpc/include/asm/book3s/32/pgtable.h |  2 ++
 arch/powerpc/include/asm/book3s/64/pgtable.h | 17 +++++++++++++++++
 arch/powerpc/include/asm/nohash/32/pgtable.h |  2 ++
 arch/powerpc/include/asm/nohash/64/pgtable.h |  2 ++
 4 files changed, 23 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/32/pgtable.h b/arch/powerpc/include/asm/book3s/32/pgtable.h
index c615abdce119..866b67a8abf0 100644
--- a/arch/powerpc/include/asm/book3s/32/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/32/pgtable.h
@@ -294,7 +294,9 @@ static inline void __ptep_set_access_flags(struct mm_struct *mm,
 #define __swp_offset(entry)		((entry).val >> 5)
 #define __swp_entry(type, offset)	((swp_entry_t) { (type) | ((offset) << 5) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 3 })
+#define __pmd_to_swp_entry(pmd)		((swp_entry_t) { pmd_val(pmd) >> 3 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 3 })
+#define __swp_entry_to_pmd(x)		((pmd_t) { (x).val << 3 })
 
 int map_kernel_page(unsigned long va, phys_addr_t pa, int flags);
 
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index a6b9f1d74600..6b3c6492071d 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -726,7 +726,9 @@ static inline bool pte_user(pte_t pte)
  * Clear bits not found in swap entries here.
  */
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val((pte)) & ~_PAGE_PTE })
+#define __pmd_to_swp_entry(pmd)	((swp_entry_t) { pmd_val((pmd)) & ~_PAGE_PTE })
 #define __swp_entry_to_pte(x)	__pte((x).val | _PAGE_PTE)
+#define __swp_entry_to_pmd(x)	__pmd((x).val | _PAGE_PTE)
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
@@ -749,6 +751,21 @@ static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 {
 	return __pte(pte_val(pte) & ~_PAGE_SWP_SOFT_DIRTY);
 }
+
+static inline pmd_t pmd_swp_mksoft_dirty(pmd_t pmd)
+{
+	return __pmd(pmd_val(pmd) | _PAGE_SWP_SOFT_DIRTY);
+}
+
+static inline bool pmd_swp_soft_dirty(pmd_t pmd)
+{
+	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_SWP_SOFT_DIRTY));
+}
+
+static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
+{
+	return __pmd(pmd_val(pmd) & ~_PAGE_SWP_SOFT_DIRTY);
+}
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
 static inline bool check_pte_access(unsigned long access, unsigned long ptev)
diff --git a/arch/powerpc/include/asm/nohash/32/pgtable.h b/arch/powerpc/include/asm/nohash/32/pgtable.h
index 03bbd1149530..f6b0534a02d4 100644
--- a/arch/powerpc/include/asm/nohash/32/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/32/pgtable.h
@@ -337,7 +337,9 @@ static inline void __ptep_set_access_flags(struct mm_struct *mm,
 #define __swp_offset(entry)		((entry).val >> 5)
 #define __swp_entry(type, offset)	((swp_entry_t) { (type) | ((offset) << 5) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) >> 3 })
+#define __pmd_to_swp_entry(pmd)		((swp_entry_t) { pmd_val(pte) >> 3 })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val << 3 })
+#define __swp_entry_to_pmd(x)		((pmd_t) { (x).val << 3 })
 
 int map_kernel_page(unsigned long va, phys_addr_t pa, int flags);
 
diff --git a/arch/powerpc/include/asm/nohash/64/pgtable.h b/arch/powerpc/include/asm/nohash/64/pgtable.h
index 5c5f75d005ad..5790763c07df 100644
--- a/arch/powerpc/include/asm/nohash/64/pgtable.h
+++ b/arch/powerpc/include/asm/nohash/64/pgtable.h
@@ -342,7 +342,9 @@ static inline void __ptep_set_access_flags(struct mm_struct *mm,
 					| ((offset) << PTE_RPN_SHIFT) })
 
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
+#define __pmd_to_swp_entry(pmd)		((swp_entry_t) { pmd_val((pmd)) })
 #define __swp_entry_to_pte(x)		__pte((x).val)
+#define __swp_entry_to_pmd(x)		__pmd((x).val)
 
 extern int map_kernel_page(unsigned long ea, unsigned long pa,
 			   unsigned long flags);
-- 
2.17.0
