Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DAF8E6B05C3
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 05:51:19 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l2so32945250pgu.2
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 02:51:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w33si20753534plb.451.2017.08.02.02.51.18
        for <linux-mm@kvack.org>;
        Wed, 02 Aug 2017 02:51:18 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v5 7/9] arm64: hugetlb: Override set_huge_swap_pte_at() to support contiguous hugepages
Date: Wed,  2 Aug 2017 10:49:02 +0100
Message-Id: <20170802094904.27749-8-punit.agrawal@arm.com>
In-Reply-To: <20170802094904.27749-1-punit.agrawal@arm.com>
References: <20170802094904.27749-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, steve.capper@arm.com, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>

The default implementation of set_huge_swap_pte_at() does not support
hugepages consisting of contiguous ptes. Override it to add support for
contiguous hugepages.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: David Woods <dwoods@mellanox.com>
---
 arch/arm64/include/asm/hugetlb.h |  3 +++
 arch/arm64/mm/hugetlbpage.c      | 12 ++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index df8c0aea0917..1dca41bea16a 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -84,6 +84,9 @@ extern void huge_ptep_clear_flush(struct vm_area_struct *vma,
 extern void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep, unsigned long sz);
 #define huge_pte_clear huge_pte_clear
+extern void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
+				 pte_t *ptep, pte_t pte, unsigned long sz);
+#define set_huge_swap_pte_at set_huge_swap_pte_at
 
 #include <asm-generic/hugetlb.h>
 
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 240b2fd53266..3e78673b1bcb 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -167,6 +167,18 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	}
 }
 
+void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
+			  pte_t *ptep, pte_t pte, unsigned long sz)
+{
+	int i, ncontig;
+	size_t pgsize;
+
+	ncontig = num_contig_ptes(sz, &pgsize);
+
+	for (i = 0; i < ncontig; i++, ptep++)
+		set_pte(ptep, pte);
+}
+
 pte_t *huge_pte_alloc(struct mm_struct *mm,
 		      unsigned long addr, unsigned long sz)
 {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
