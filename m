Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 231D56B0025
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q22so1392688pfh.20
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n2si1538471pga.202.2018.04.18.11.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:23 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 09/14] mm: Use page->deferred_list
Date: Wed, 18 Apr 2018 11:49:07 -0700
Message-Id: <20180418184912.2851-10-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

Now that we can represent the location of 'deferred_list' in C instead
of comments, make use of that ability.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/huge_memory.c | 7 ++-----
 mm/page_alloc.c  | 2 +-
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 14ed6ee5e02f..55ad852fbf17 100644
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
