Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E98CE6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 22:37:57 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so8107148pac.2
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 19:37:57 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id qn10si4864524pbc.109.2015.08.19.19.37.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 19:37:57 -0700 (PDT)
Received: by paccq16 with SMTP id cq16so16452104pac.1
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 19:37:56 -0700 (PDT)
Date: Wed, 19 Aug 2015 19:36:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm, vmscan: unlock page while waiting on writeback
Message-ID: <alpine.LSU.2.11.1508191930390.2073@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org

This is merely a politeness: I've not found that shrink_page_list() leads
to deadlock with the page it holds locked across wait_on_page_writeback();
but nevertheless, why hold others off by keeping the page locked there?

And while we're at it: remove the mistaken "not " from the commentary
on this Case 3 (and a distracting blank line from Case 2, if I may).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
I remembered this old patch when we were discussing the more important
ecf5fc6e9654 "mm, vmscan: Do not wait for page writeback for GFP_NOFS
allocations", and now retested it against mmotm.

 mm/vmscan.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- mmotm/mm/vmscan.c	2015-08-17 18:46:26.601521575 -0700
+++ linux/mm/vmscan.c	2015-08-17 18:53:41.335108240 -0700
@@ -991,7 +991,7 @@ static unsigned long shrink_page_list(st
 		 *    __GFP_IO|__GFP_FS for this reason); but more thought
 		 *    would probably show more reasons.
 		 *
-		 * 3) Legacy memcg encounters a page that is not already marked
+		 * 3) Legacy memcg encounters a page that is already marked
 		 *    PageReclaim. memcg does not have any dirty pages
 		 *    throttling so we could easily OOM just because too many
 		 *    pages are in writeback and there is nothing else to
@@ -1021,12 +1021,15 @@ static unsigned long shrink_page_list(st
 				 */
 				SetPageReclaim(page);
 				nr_writeback++;
-
 				goto keep_locked;
 
 			/* Case 3 above */
 			} else {
+				unlock_page(page);
 				wait_on_page_writeback(page);
+				/* then go back and try same page again */
+				list_add_tail(&page->lru, page_list);
+				continue;
 			}
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
