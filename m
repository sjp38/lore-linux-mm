Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 360406B0069
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 12:21:32 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v91so1047673wrc.11
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:21:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si3760570wrh.108.2017.10.17.09.21.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 09:21:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 5/7] mm: Move clearing of page->mapping to page_cache_tree_delete()
Date: Tue, 17 Oct 2017 18:21:18 +0200
Message-Id: <20171017162120.30990-6-jack@suse.cz>
In-Reply-To: <20171017162120.30990-1-jack@suse.cz>
References: <20171017162120.30990-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Clearing of page->mapping makes sense in page_cache_tree_delete() as
well and it will help us with batching things this way.

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c58ccd26bbe6..c866a84bd45c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -165,6 +165,9 @@ static void page_cache_tree_delete(struct address_space *mapping,
 				     workingset_update_node, mapping);
 	}
 
+	page->mapping = NULL;
+	/* Leave page->index set: truncation lookup relies upon it */
+
 	if (shadow) {
 		mapping->nrexceptional += nr;
 		/*
@@ -250,9 +253,6 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 					     inode_to_wb(mapping->host));
 	}
 	page_cache_tree_delete(mapping, page, shadow);
-
-	page->mapping = NULL;
-	/* Leave page->index set: truncation lookup relies upon it */
 }
 
 static void page_cache_free_page(struct address_space *mapping,
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
