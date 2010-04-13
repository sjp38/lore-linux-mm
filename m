Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 72E196B01EF
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:28:40 -0400 (EDT)
Received: by mail-bw0-f223.google.com with SMTP id 23so3241847bwz.6
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 08:28:37 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 4/6] change alloc function in vmemmap_alloc_block
Date: Wed, 14 Apr 2010 00:25:01 +0900
Message-Id: <3108a367a27c55392904c3f046aa0b5420efe261.1271171877.git.minchan.kim@gmail.com>
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

if node_state is N_HIGH_MEMORY, node doesn't have -1.
It means node's validity check is unnecessary.
So we can use alloc_pages_exact_node instead of alloc_pages_node.
It could avoid comparison and branch as 6484eb3e2a81807722 tried.

Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/sparse-vmemmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 392b9bb..7710ebc 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -53,7 +53,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 		struct page *page;
 
 		if (node_state(node, N_HIGH_MEMORY))
-			page = alloc_pages_node(node,
+			page = alloc_pages_exact_node(node,
 				GFP_KERNEL | __GFP_ZERO, get_order(size));
 		else
 			page = alloc_pages(GFP_KERNEL | __GFP_ZERO,
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
