Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F13746B01F2
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:28:54 -0400 (EDT)
Received: by wwf26 with SMTP id 26so2982174wwf.14
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 08:28:52 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 5/6] change alloc function in __vmalloc_area_node
Date: Wed, 14 Apr 2010 00:25:02 +0900
Message-Id: <2cb77846a9523201588c5dbf94b23d6ea737ce65.1271171877.git.minchan.kim@gmail.com>
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

__vmalloc_area_node never pass -1 to alloc_pages_node.
It means node's validity check is unnecessary.
So we can use alloc_pages_exact_node instead of alloc_pages_node.
It could avoid comparison and branch as 6484eb3e2a81807722 tried.

Cc: Nick Piggin <npiggin@suse.de>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmalloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ae00746..7abf423 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1499,7 +1499,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		if (node < 0)
 			page = alloc_page(gfp_mask);
 		else
-			page = alloc_pages_node(node, gfp_mask, 0);
+			page = alloc_pages_exact_node(node, gfp_mask, 0);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
