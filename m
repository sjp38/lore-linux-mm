Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C4D6D6B01EF
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:59:43 -0400 (EDT)
Received: by wwf26 with SMTP id 26so145384wwf.14
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 07:59:41 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] change alloc function in pcpu_alloc_pages
Date: Wed, 14 Apr 2010 23:58:35 +0900
Message-Id: <1271257119-30117-2-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1271257119-30117-1-git-send-email-minchan.kim@gmail.com>
References: <1271257119-30117-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

alloc_pages_node is called with cpu_to_node(cpu).
I think cpu_to_node(cpu) never returns -1.
(But I am not sure we need double check.)

So we can use alloc_pages_exact_node instead of alloc_pages_node.
It could avoid comparison and branch as 6484eb3e2a81807722 tried.

Cc: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/percpu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 768419d..ec3e671 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -720,7 +720,7 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
 		for (i = page_start; i < page_end; i++) {
 			struct page **pagep = &pages[pcpu_page_idx(cpu, i)];
 
-			*pagep = alloc_pages_node(cpu_to_node(cpu), gfp, 0);
+			*pagep = alloc_pages_exact_node(cpu_to_node(cpu), gfp, 0);
 			if (!*pagep) {
 				pcpu_free_pages(chunk, pages, populated,
 						page_start, page_end);
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
