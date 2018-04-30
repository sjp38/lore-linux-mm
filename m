Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08C7C6B0011
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:23:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y12so410234pfe.8
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 13:23:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t4-v6si1595481pgr.690.2018.04.30.13.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 13:23:14 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 09/16] mm: Use page->deferred_list
Date: Mon, 30 Apr 2018 13:22:40 -0700
Message-Id: <20180430202247.25220-10-willy@infradead.org>
In-Reply-To: <20180430202247.25220-1-willy@infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Now that we can represent the location of 'deferred_list' in C instead
of comments, make use of that ability.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 7 ++-----
 mm/page_alloc.c  | 2 +-
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a3a1815f8e11..cb0954a6de88 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -483,11 +483,8 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 
 static inline struct list_head *page_deferred_list(struct page *page)
 {
-	/*
-	 * ->lru in the tail pages is occupied by compound_head.
-	 * Let's use ->mapping + ->index in the second tail page as list_head.
-	 */
-	return (struct list_head *)&page[2].mapping;
+	/* ->lru in the tail pages is occupied by compound_head. */
+	return &page[2].deferred_list;
 }
 
 void prep_transhuge_page(struct page *page)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 88e817d7ccef..18720eccbce1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -953,7 +953,7 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 	case 2:
 		/*
 		 * the second tail page: ->mapping is
-		 * page_deferred_list().next -- ignore value.
+		 * deferred_list.next -- ignore value.
 		 */
 		break;
 	default:
-- 
2.17.0
