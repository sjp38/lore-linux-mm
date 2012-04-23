Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id A1CB16B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 16:56:06 -0400 (EDT)
Received: by qcse1 with SMTP id e1so1391389qcs.2
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 13:56:05 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
Date: Mon, 23 Apr 2012 13:56:04 -0700
Message-Id: <1335214564-17619-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

This is not a patch targeted to be merged at all, but trying to understand
a logic in global direct reclaim.

There is a logic in global direct reclaim where reclaim fails on priority 0
and zone->all_unreclaimable is not set, it will cause the direct to start over
from DEF_PRIORITY. In some extreme cases, we've seen the system hang which is
very likely caused by direct reclaim enters infinite loop.

There have been serious patches trying to fix similar issue and the latest
patch has good summary of all the efforts:

commit 929bea7c714220fc76ce3f75bef9056477c28e74
Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date:   Thu Apr 14 15:22:12 2011 -0700

    vmscan: all_unreclaimable() use zone->all_unreclaimable as a name

Kosaki explained the problem triggered by async zone->all_unreclaimable and
zone->pages_scanned where the later one was being checked by direct reclaim.
However, after the patch, the problem remains where the setting of
zone->all_unreclaimable is asynchronous with zone is actually reclaimable or not.

The zone->all_unreclaimable flag is set by kswapd by checking zone->pages_scanned in
zone_reclaimable(). Is that possible to have zone->all_unreclaimable == false while
the zone is actually unreclaimable?

1. while kswapd in reclaim priority loop, someone frees a page on the zone. It
will end up resetting the pages_scanned.

2. kswapd is frozen for whatever reason. I noticed Kosaki's covered the
hibernation case by checking oom_killer_disabled, but not sure if that is
everything we need to worry about. The key point here is that direct reclaim
relies on a flag which is set by kswapd asynchronously, that doesn't sound safe.

Instead of keep fixing the problem, I am wondering why we have the logic
"not oom but keep trying reclaim w/ priority 0 reclaim failure" at the first place:

Here is the patch introduced the logic initially:

commit 408d85441cd5a9bd6bc851d677a10c605ed8db5f
Author: Nick Piggin <npiggin@suse.de>
Date:   Mon Sep 25 23:31:27 2006 -0700

    [PATCH] oom: use unreclaimable info

However, I didn't find detailed description of what problem the commit trying
to fix and wondering if the problem still exist after 5 years. I would be happy
to see the later case where we can consider to revert the initial patch.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1a51868..c7de242 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2420,8 +2420,8 @@ out:
 		return 1;
 
 	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
-		return 1;
+//	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
+//		return 1;
 
 	return 0;
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
