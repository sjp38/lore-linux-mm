Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3CA4C6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 19:29:09 -0400 (EDT)
Date: Tue, 28 Apr 2009 19:29:07 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] vmscan: evict use-once pages first
Message-ID: <20090428192907.556f3a34@bree.surriel.com>
In-Reply-To: <20090428044426.GA5035@eskimo.com>
References: <20090428044426.GA5035@eskimo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Elladan <elladan@eskimo.com>
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
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
Elladan, does this patch fix the issue you are seeing?

Peter, Kosaki, Ted, does this patch look good to you?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eac9577..4c0304e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1489,6 +1489,21 @@ static void shrink_zone(int priority, struct zone *zone,
 			nr[l] = scan;
 	}
 
+	/*
+	 * When the system is doing streaming IO, memory pressure here
+	 * ensures that active file pages get deactivated, until more
+	 * than half of the file pages are on the inactive list.
+	 *
+	 * Once we get to that situation, protect the system's working
+	 * set from being evicted by disabling active file page aging
+	 * and swapping of swap backed pages.  We still do background
+	 * aging of anonymous pages.
+	 */
+	if (nr[LRU_INACTIVE_FILE] > nr[LRU_ACTIVE_FILE]) {
+		nr[LRU_ACTIVE_FILE] = 0;
+		nr[LRU_INACTIVE_ANON] = 0;
+	}
+
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
