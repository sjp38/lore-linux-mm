Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B13516B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:28:24 -0400 (EDT)
Received: by bwz23 with SMTP id 23so3241847bwz.6
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 08:28:21 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 3/6] change alloc function in alloc_slab_page
Date: Wed, 14 Apr 2010 00:25:00 +0900
Message-Id: <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

alloc_slab_page never calls alloc_pages_node with -1.
It means node's validity check is unnecessary.
So we can use alloc_pages_exact_node instead of alloc_pages_node.
It could avoid comparison and branch as 6484eb3e2a81807722 tried.

Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
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
