Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 399EA6B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 14:33:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u10-v6so4559856pgp.8
        for <linux-mm@kvack.org>; Fri, 04 May 2018 11:33:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i73si17274597pfe.27.2018.05.04.11.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 11:33:23 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 08/17] mm: Use page->deferred_list
Date: Fri,  4 May 2018 11:33:09 -0700
Message-Id: <20180504183318.14415-9-willy@infradead.org>
In-Reply-To: <20180504183318.14415-1-willy@infradead.org>
References: <20180504183318.14415-1-willy@infradead.org>
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
index da3eb2236ba1..1a0149c4f672 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -933,7 +933,7 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
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
