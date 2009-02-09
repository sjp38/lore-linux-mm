Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 238D56B003D
	for <linux-mm@kvack.org>; Mon,  9 Feb 2009 17:24:52 -0500 (EST)
Date: Mon, 9 Feb 2009 23:24:16 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [RFC] vmscan: initialize sc->nr_reclaimed in do_try_to_free_pages()
Message-ID: <20090209222416.GA9758@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: William Lee Irwin III <wli@movementarian.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Commit a79311c14eae4bb946a97af25f3e1b17d625985d "vmscan: bail out of
direct reclaim after swap_cluster_max pages" moved the nr_reclaimed
counter into the scan control to accumulate the number of all
reclaimed pages in one direct reclaim invocation.

The commit missed to actually adjust do_try_to_free_pages() which now
does not initialize sc.nr_reclaimed and makes shrink_zone() make
assumptions on whether to bail out of the reclaim cycle based on an
uninitialized value.

Fix it up by initializing the counter to zero before entering the
priority loop.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |    1 +
 1 file changed, 1 insertion(+)

The comment of the .nr_reclaimed field says it accumulates the reclaim
counter over ONE shrink_zones() call.  This means, we should break out
if ONE shrink_zones() call alone does more than swap_cluster_max.

OTOH, the patch title suggests that we break out if ALL shrink_zones()
calls in the priority loop have reclaimed that much.  I.e.
accumulating the reclaimed number over the prio loop, not just over
one zones iteration.

>From the patch description I couldn't really make sure what the
intended behaviour was.

So, should the sc.nr_reclaimed be reset before the prio loop or in
each iteration of the prio loop?

Either this patch is wrong or the comment above .nr_reclaimed is.

And why didn't this have any observable effects?  Do I miss something
really obvious here?

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1618,6 +1618,7 @@ static unsigned long do_try_to_free_page
 		}
 	}
 
+	sc->nr_reclaimed = 0;
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
 		if (!priority)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
