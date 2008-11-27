Date: Thu, 27 Nov 2008 10:34:01 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/2] mm: pagecache allocation gfp fixes
Message-ID: <20081127093401.GE28285@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: npiggin@suse.de
List-ID: <linux-mm.kvack.org>


Frustratingly, gfp_t is really divided into two classes of flags. One are the
context dependent ones (can we sleep? can we enter filesystem? block subsystem?
should we use some extra reserves, etc.). The other ones are the type of memory
required and depend on how the algorithm is implemented rather than the point
at which the memory is allocated (highmem? dma memory? etc).

Some of functions which allocate a page and add it to page cache take a gfp_t,
but sometimes those functions or their callers aren't really doing the right
thing: when allocating pagecache page, the memory type should be
mapping_gfp_mask(mapping). When allocating radix tree nodes, the memory type
should be kernel mapped (not highmem) memory. The gfp_t argument should only
really be needed for context dependent options.

This patch doesn't really solve that tangle in a nice way, but it does attempt
to fix a couple of bugs. find_or_create_page changes its radix-tree allocation
to only include the main context dependent flags in order so the pagecache
page may be allocated from arbitrary types of memory without affecting the
radix-tree. Then grab_cache_page_nowait() is changed to allocate radix-tree
nodes with GFP_NOFS, because it is not supposed to reenter the filesystem.

Filesystems should be careful about exactly what semantics they want and what
they get when fiddling with gfp_t masks to allocate pagecache. One should be
as liberal as possible with the type of memory that can be used, and same
for the the context specific flags.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -741,7 +741,8 @@ repeat:
 		page = __page_cache_alloc(gfp_mask);
 		if (!page)
 			return NULL;
-		err = add_to_page_cache_lru(page, mapping, index, gfp_mask);
+		err = add_to_page_cache_lru(page, mapping, index,
+			(gfp_mask & (__GFP_FS|__GFP_IO|__GFP_WAIT|__GFP_HIGH)));
 		if (unlikely(err)) {
 			page_cache_release(page);
 			page = NULL;
@@ -950,7 +951,7 @@ grab_cache_page_nowait(struct address_sp
 		return NULL;
 	}
 	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
-	if (page && add_to_page_cache_lru(page, mapping, index, GFP_KERNEL)) {
+	if (page && add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
 		page_cache_release(page);
 		page = NULL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
