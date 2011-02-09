Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8B98D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 08:21:25 -0500 (EST)
Received: by gxk5 with SMTP id 5so63970gxk.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 05:21:23 -0800 (PST)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] mm: batch-free pcp list if possible
Date: Wed,  9 Feb 2011 22:21:17 +0900
Message-Id: <1297257677-12287-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

free_pcppages_bulk() frees pages from pcp lists in a round-robin
fashion by keeping batch_free counter. But it doesn't need to spin
if there is only one non-empty list. This can be checked by
batch_free == MIGRATE_PCPTYPES.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/page_alloc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a873e61e312e..470fb42e303c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -614,6 +614,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			list = &pcp->lists[migratetype];
 		} while (list_empty(list));
 
+		/* This is an only non-empty list. Free them all. */
+		if (batch_free == MIGRATE_PCPTYPES)
+			batch_free = to_free;
+
 		do {
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
-- 
1.7.3.4.600.g982838b0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
