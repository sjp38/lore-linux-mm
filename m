Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3036B01E7
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:02:24 -0400 (EDT)
Date: Tue, 16 Mar 2010 02:02:18 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] fix mapping_gfp_mask usage
Message-ID: <20100315150218.GD2869@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


mapping_gfp_mask is not supposed to store allocation contex details, only page
location details. So mapping_gfp_mask should be applied to the pagecache page
allocation, wheras normal (kernel mapped) memory should be used for surrounding
allocations such as radix-tree nodes allocated by add_to_page_cache. Context
modifiers should be applied on a per-callsite basis.

So change splice to follow this convention (which is followed in similar
code patterns in core code).

Signed-off-by: Nick Piggin <npiggin@suse.de>
--
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -320,7 +320,7 @@ __generic_file_splice_read(struct file *
 				break;
 
 			error = add_to_page_cache_lru(page, mapping, index,
-						mapping_gfp_mask(mapping));
+						GFP_KERNEL);
 			if (unlikely(error)) {
 				page_cache_release(page);
 				if (error == -EEXIST)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
