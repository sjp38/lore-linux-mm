Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 34A086B01F0
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 11:00:02 -0400 (EDT)
Received: by bwz2 with SMTP id 2so245676bwz.10
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 07:59:58 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2] change alloc function in alloc_slab_page
Date: Wed, 14 Apr 2010 23:58:36 +0900
Message-Id: <1271257119-30117-3-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1271257119-30117-1-git-send-email-minchan.kim@gmail.com>
References: <1271257119-30117-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

V2
* change changelog
* Add some reviewed-by 

alloc_slab_page always checks nid == -1, so alloc_page_node can't be
called with -1. 
It means node's validity check in alloc_pages_node is unnecessary. 
So we can use alloc_pages_exact_node instead of alloc_pages_node. 
It could avoid comparison and branch as 6484eb3e2a81807722 tried.

Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b364844..9984165 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1084,7 +1084,7 @@ static inline struct page *alloc_slab_page(gfp_t flags, int node,
 	if (node == -1)
 		return alloc_pages(flags, order);
 	else
-		return alloc_pages_node(node, flags, order);
+		return alloc_pages_exact_node(node, flags, order);
 }
 
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
