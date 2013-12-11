Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id D87B26B0039
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:36:39 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so10812176pbb.4
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:36:39 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 8si14737637pbe.40.2013.12.11.14.36.38
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:36:38 -0800 (PST)
Subject: [PATCH 2/2] mm: blk-mq: uses page->list incorrectly
From: Dave Hansen <dave@sr71.net>
Date: Wed, 11 Dec 2013 14:36:32 -0800
References: <20131211223631.51094A3D@viggo.jf.intel.com>
In-Reply-To: <20131211223631.51094A3D@viggo.jf.intel.com>
Message-Id: <20131211223632.8B2DFD41@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

'struct page' has two list_head fields: 'lru' and 'list'.
Conveniently, they are unioned together.  This means that code
can use them interchangably, which gets horribly confusing.

The blk-mq made the logical decision to try to use page->list.
But, that field was actually introduced just for the slub code.
->lru is the right field to use outside of slab/slub.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/block/blk-mq.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN block/blk-mq.c~blk-mq-uses-page-list-incorrectly block/blk-mq.c
--- linux.git/block/blk-mq.c~blk-mq-uses-page-list-incorrectly	2013-12-11 14:34:51.735196799 -0800
+++ linux.git-davehans/block/blk-mq.c	2013-12-11 14:34:51.739196977 -0800
@@ -1087,8 +1087,8 @@ static void blk_mq_free_rq_map(struct bl
 	struct page *page;
 
 	while (!list_empty(&hctx->page_list)) {
-		page = list_first_entry(&hctx->page_list, struct page, list);
-		list_del_init(&page->list);
+		page = list_first_entry(&hctx->page_list, struct page, lru);
+		list_del_init(&page->lru);
 		__free_pages(page, page->private);
 	}
 
@@ -1152,7 +1152,7 @@ static int blk_mq_init_rq_map(struct blk
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
