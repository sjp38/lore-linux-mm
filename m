Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3F376B0679
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:46:55 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x32-v6so5612506pld.16
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:46:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l11-v6si5170602pgp.426.2018.05.18.12.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 12:45:24 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 12/17] mm: Add pt_mm to struct page
Date: Fri, 18 May 2018 12:45:14 -0700
Message-Id: <20180518194519.3820-13-willy@infradead.org>
In-Reply-To: <20180518194519.3820-1-willy@infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

For pgd page table pages, x86 overloads the page->index field to store
a pointer to the mm_struct.  Rename this to pt_mm so it's visible to
other users.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 arch/x86/mm/pgtable.c    | 5 ++---
 include/linux/mm_types.h | 2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index ffc8c13c50e4..938dbcd46b97 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -114,13 +114,12 @@ static inline void pgd_list_del(pgd_t *pgd)
 
 static void pgd_set_mm(pgd_t *pgd, struct mm_struct *mm)
 {
-	BUILD_BUG_ON(sizeof(virt_to_page(pgd)->index) < sizeof(mm));
-	virt_to_page(pgd)->index = (pgoff_t)mm;
+	virt_to_page(pgd)->pt_mm = mm;
 }
 
 struct mm_struct *pgd_page_get_mm(struct page *page)
 {
-	return (struct mm_struct *)page->index;
+	return page->pt_mm;
 }
 
 static void pgd_ctor(struct mm_struct *mm, pgd_t *pgd)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 90a6dbeeef11..7eb7092424b7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -139,7 +139,7 @@ struct page {
 			unsigned long _pt_pad_1;	/* compound_head */
 			pgtable_t pmd_huge_pte; /* protected by page->ptl */
 			unsigned long _pt_pad_2;	/* mapping */
-			unsigned long _pt_pad_3;
+			struct mm_struct *pt_mm;	/* x86 pgds only */
 #if ALLOC_SPLIT_PTLOCKS
 			spinlock_t *ptl;
 #else
-- 
2.17.0
