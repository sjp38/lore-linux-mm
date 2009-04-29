Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 688886B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 11:46:42 -0400 (EDT)
Date: Wed, 29 Apr 2009 11:47:08 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] vmscan: evict use-once pages first (v2)
Message-ID: <20090429114708.66114c03@cuia.bos.redhat.com>
In-Reply-To: <1240987349.4512.18.camel@laptop>
References: <20090428044426.GA5035@eskimo.com>
	<20090428192907.556f3a34@bree.surriel.com>
	<1240987349.4512.18.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When the file LRU lists are dominated by streaming IO pages,
evict those pages first, before considering evicting other
pages.

This should be safe from deadlocks or performance problems
because only three things can happen to an inactive file page:
1) referenced twice and promoted to the active list
2) evicted by the pageout code
3) under IO, after which it will get evicted or promoted

The pages freed in this way can either be reused for streaming
IO, or allocated for something else. If the pages are used for
streaming IO, this pageout pattern continues. Otherwise, we will
fall back to the normal pageout pattern.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
On Wed, 29 Apr 2009 08:42:29 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Isn't there a hole where LRU_*_FILE << LRU_*_ANON and we now stop
> shrinking INACTIVE_ANON even though it makes sense to.

Peter, after looking at this again, I believe that the get_scan_ratio
logic should take care of protecting the anonymous pages, so we can
get away with this following, less intrusive patch.

Elladan, does this smaller patch still work as expected?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eac9577..4471dcb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1489,6 +1489,18 @@ static void shrink_zone(int priority, struct zone *zone,
 			nr[l] = scan;
 	}
 
+	/*
+	 * When the system is doing streaming IO, memory pressure here
+	 * ensures that active file pages get deactivated, until more
+	 * than half of the file pages are on the inactive list.
+	 *
+	 * Once we get to that situation, protect the system's working
+	 * set from being evicted by disabling active file page aging.
+	 * The logic in get_scan_ratio protects anonymous pages.
+	 */
+	if (nr[LRU_INACTIVE_FILE] > nr[LRU_ACTIVE_FILE])
+		nr[LRU_ACTIVE_FILE] = 0;
+
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
