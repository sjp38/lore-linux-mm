Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 192116B0055
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:53:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p12so4696276pfn.13
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:53:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x21si1739280pge.803.2018.04.10.05.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 05:53:54 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 2/2] page cache: Mask off unwanted GFP flags
Date: Tue, 10 Apr 2018 05:53:51 -0700
Message-Id: <20180410125351.15837-2-willy@infradead.org>
In-Reply-To: <20180410125351.15837-1-willy@infradead.org>
References: <20180410125351.15837-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

The page cache has used the mapping's GFP flags for allocating
radix tree nodes for a long time.  It took care to always mask off the
__GFP_HIGHMEM flag, and masked off other flags in other paths, but the
__GFP_ZERO flag was still able to sneak through.  The __GFP_DMA and
__GFP_DMA32 flags would also have been able to sneak through if they
were ever used.  Fix them all by using GFP_RECLAIM_MASK at the innermost
location, and remove it from earlier in the callchain.

Fixes: 19f99cee206c ("f2fs: add core inode operations")
Reported-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Cc: stable@vger.kernel.org
---
 mm/filemap.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c2147682f4c3..1a4bfc5ed3dc 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -785,7 +785,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 	VM_BUG_ON_PAGE(!PageLocked(new), new);
 	VM_BUG_ON_PAGE(new->mapping, new);
 
-	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	error = radix_tree_preload(gfp_mask & GFP_RECLAIM_MASK);
 	if (!error) {
 		struct address_space *mapping = old->mapping;
 		void (*freepage)(struct page *);
@@ -841,7 +841,7 @@ static int __add_to_page_cache_locked(struct page *page,
 			return error;
 	}
 
-	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
+	error = radix_tree_maybe_preload(gfp_mask & GFP_RECLAIM_MASK);
 	if (error) {
 		if (!huge)
 			mem_cgroup_cancel_charge(page, memcg, false);
@@ -1574,8 +1574,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		if (fgp_flags & FGP_ACCESSED)
 			__SetPageReferenced(page);
 
-		err = add_to_page_cache_lru(page, mapping, offset,
-				gfp_mask & GFP_RECLAIM_MASK);
+		err = add_to_page_cache_lru(page, mapping, offset, gfp_mask);
 		if (unlikely(err)) {
 			put_page(page);
 			page = NULL;
@@ -2378,7 +2377,7 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
 		if (!page)
 			return -ENOMEM;
 
-		ret = add_to_page_cache_lru(page, mapping, offset, gfp_mask & GFP_KERNEL);
+		ret = add_to_page_cache_lru(page, mapping, offset, gfp_mask);
 		if (ret == 0)
 			ret = mapping->a_ops->readpage(file, page);
 		else if (ret == -EEXIST)
-- 
2.16.3
