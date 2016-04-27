Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 998E76B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:01:37 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so34822423lfc.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:01:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si4006576wjz.199.2016.04.27.05.01.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 05:01:25 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/3] mm, page_alloc: pull out side effects from free_pages_check
Date: Wed, 27 Apr 2016 14:01:15 +0200
Message-Id: <1461758476-450-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1461758476-450-1-git-send-email-vbabka@suse.cz>
References: <5720A987.7060507@suse.cz>
 <1461758476-450-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Check without side-effects should be easier to maintain. It also removes the
duplicated cpupid and flags reset done in !DEBUG_VM variant of both
free_pcp_prepare() and then bulkfree_pcp_prepare(). Finally, it enables
the next patch.

It shouldn't result in new branches, thanks to inlining of the check.

!DEBUG_VM bloat-o-meter:

add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-27 (-27)
function                                     old     new   delta
__free_pages_ok                              748     739      -9
free_pcppages_bulk                          1403    1385     -18

DEBUG_VM:

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-28 (-28)
function                                     old     new   delta
free_pages_prepare                           806     778     -28

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 12c03a8509a0..163d08ea43f0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -932,11 +932,8 @@ static void free_pages_check_bad(struct page *page)
 }
 static inline int free_pages_check(struct page *page)
 {
-	if (likely(page_expected_state(page, PAGE_FLAGS_CHECK_AT_FREE))) {
-		page_cpupid_reset_last(page);
-		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	if (likely(page_expected_state(page, PAGE_FLAGS_CHECK_AT_FREE)))
 		return 0;
-	}
 
 	/* Something has gone sideways, find it */
 	free_pages_check_bad(page);
@@ -1016,12 +1013,22 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 		for (i = 1; i < (1 << order); i++) {
 			if (compound)
 				bad += free_tail_pages_check(page, page + i);
-			bad += free_pages_check(page + i);
+			if (free_pages_check(page + i)) {
+				bad++;
+			} else {
+				page_cpupid_reset_last(page + i);
+				(page + i)->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+			}
 		}
 	}
 	if (PageAnonHead(page))
 		page->mapping = NULL;
-	bad += free_pages_check(page);
+	if (free_pages_check(page)) {
+		bad++;
+	} else {
+		page_cpupid_reset_last(page);
+		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	}
 	if (bad)
 		return false;
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
