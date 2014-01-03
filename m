Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 72E1B6B0039
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 13:02:10 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id lf10so16064126pab.14
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 10:02:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yy4si32290808pbc.219.2014.01.03.10.02.08
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 10:02:09 -0800 (PST)
Subject: [PATCH 2/9] mm: blk-mq: uses page->list incorrectly
From: Dave Hansen <dave@sr71.net>
Date: Fri, 03 Jan 2014 10:01:51 -0800
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
In-Reply-To: <20140103180147.6566F7C1@viggo.jf.intel.com>
Message-Id: <20140103180151.CBAD7BEA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

'struct page' has two list_head fields: 'lru' and 'list'.
Conveniently, they are unioned together.  This means that code
can use them interchangably, which gets horribly confusing.

The blk-mq made the logical decision to try to use page->list.
But, that field was actually introduced just for the slub code.
->lru is the right field to use outside of slab/slub.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---

 linux.git-davehans/block/blk-mq.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN block/blk-mq.c~blk-mq-uses-page-list-incorrectly block/blk-mq.c
--- linux.git/block/blk-mq.c~blk-mq-uses-page-list-incorrectly	2014-01-02 13:40:29.388270304 -0800
+++ linux.git-davehans/block/blk-mq.c	2014-01-02 13:40:29.392270484 -0800
@@ -1091,8 +1091,8 @@ static void blk_mq_free_rq_map(struct bl
 	struct page *page;
 
 	while (!list_empty(&hctx->page_list)) {
-		page = list_first_entry(&hctx->page_list, struct page, list);
-		list_del_init(&page->list);
+		page = list_first_entry(&hctx->page_list, struct page, lru);
+		list_del_init(&page->lru);
 		__free_pages(page, page->private);
 	}
 
@@ -1156,7 +1156,7 @@ static int blk_mq_init_rq_map(struct blk
 			break;
 
 		page->private = this_order;
-		list_add_tail(&page->list, &hctx->page_list);
+		list_add_tail(&page->lru, &hctx->page_list);
 
 		p = page_address(page);
 		entries_per_page = order_to_size(this_order) / rq_size;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
