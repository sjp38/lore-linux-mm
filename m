Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8321A6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:52:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s74so752338pfe.10
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 06:52:02 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1si65803pgw.51.2017.06.14.06.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 06:52:01 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/3] mm, thp: Do not loose dirty bit in __split_huge_pmd_locked()
Date: Wed, 14 Jun 2017 16:51:43 +0300
Message-Id: <20170614135143.25068-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Until pmdp_invalidate() pmd entry is present and CPU can update it,
setting dirty. Currently, we tranfer dirty bit to page too early and
there is window when we can miss dirty bit.

Let's call SetPageDirty() after pmdp_invalidate().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a84909cf20d3..c4ee5c890910 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1928,7 +1928,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct page *page;
 	pgtable_t pgtable;
 	pmd_t _pmd;
-	bool young, write, dirty, soft_dirty;
+	bool young, write, soft_dirty;
 	unsigned long addr;
 	int i;
 
@@ -1965,7 +1965,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	page_ref_add(page, HPAGE_PMD_NR - 1);
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
-	dirty = pmd_dirty(*pmd);
 	soft_dirty = pmd_soft_dirty(*pmd);
 
 	pmdp_huge_split_prepare(vma, haddr, pmd);
@@ -1995,8 +1994,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			if (soft_dirty)
 				entry = pte_mksoft_dirty(entry);
 		}
-		if (dirty)
-			SetPageDirty(page + i);
 		pte = pte_offset_map(&_pmd, addr);
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, addr, pte, entry);
@@ -2046,6 +2043,14 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	 * pmd_populate.
 	 */
 	pmdp_invalidate(vma, haddr, pmd);
+
+	/*
+	 * Transfer dirty bit to page after pmd invalidated, so CPU would not
+	 * be able to set it under us.
+	 */
+	if (pmd_dirty(*pmd))
+		SetPageDirty(page);
+
 	pmd_populate(mm, pmd, pgtable);
 
 	if (freeze) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
