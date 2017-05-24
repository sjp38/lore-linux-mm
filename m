Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 962406B0317
	for <linux-mm@kvack.org>; Wed, 24 May 2017 09:12:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so194127737pfd.11
        for <linux-mm@kvack.org>; Wed, 24 May 2017 06:12:17 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 84si24523551pfs.144.2017.05.24.06.12.16
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 06:12:16 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v4 7/9] arm64: hugetlb: Override set_huge_swap_pte_at() to support contiguous hugepages
Date: Wed, 24 May 2017 14:11:20 +0100
Message-Id: <20170524131122.5309-8-punit.agrawal@arm.com>
In-Reply-To: <20170524131122.5309-1-punit.agrawal@arm.com>
References: <20170524131122.5309-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-arm-kernel@lists.infradead.org, steve.capper@arm.com, mark.rutland@arm.com, linux-mm@kvack.org, David Woods <dwoods@mellanox.com>

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
index bb86f0741863..e5f6210d1321 100644
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
