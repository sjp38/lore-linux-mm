Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86CEA6B03B4
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:38:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e1so6708134pfd.9
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:38:24 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 1si20680078plh.210.2017.04.05.06.38.22
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 06:38:23 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v2 7/9] arm64: hugetlb: Override set_huge_swap_pte_at() to support contiguous hugepages
Date: Wed,  5 Apr 2017 14:37:20 +0100
Message-Id: <20170405133722.6406-8-punit.agrawal@arm.com>
In-Reply-To: <20170405133722.6406-1-punit.agrawal@arm.com>
References: <20170405133722.6406-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, mark.rutland@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, steve.capper@arm.com, David Woods <dwoods@mellanox.com>

The default implementation of set_huge_swap_pte_at() does not support
hugepages consisting of contiguous ptes. Override it to add support for
contiguous hugepages.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Cc: David Woods <dwoods@mellanox.com>
---
 arch/arm64/mm/hugetlbpage.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 53bda26c6e8f..6d3857f41b8d 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -143,6 +143,23 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	}
 }
 
+void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
+			  pte_t *ptep, pte_t pte, unsigned long sz)
+{
+	size_t pgsize;
+	int i;
+	int ncontig;
+
+	if (sz == PUD_SIZE || sz == PMD_SIZE) {
+		set_pte(ptep, pte);
+		return;
+	}
+
+	ncontig = find_num_contig(mm, addr, ptep, &pgsize);
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
