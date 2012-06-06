Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CC40A6B00B4
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 14:24:07 -0400 (EDT)
Received: by vbbfd1 with SMTP id fd1so737422vbb.2
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 11:24:06 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 4/5] mm: memcg revert upstream all_unreclaimable() use zone->all_unreclaimable as a name
Date: Wed,  6 Jun 2012 11:24:05 -0700
Message-Id: <1339007045-10616-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

The upstream change reverts the other change as listed below:

commit d1908362ae0b97374eb8328fbb471576332f9fb1
Author: Minchan Kim <minchan.kim@gmail.com>
Date:   Wed Sep 22 13:05:01 2010 -0700

    vmscan: check all_unreclaimable in direct reclaim path

The zone->all_unreclaimable flag is set by kswapd by checking zone->pages_scanned in
zone_reclaimable(). It is possible to have zone->all_unreclaimable == false while
the zone is actually unreclaimable, and it will cause machine to stuck.

1. while kswapd in reclaim priority loop, someone frees a page on the zone. It
will end up resetting the pages_scanned.

2. kswapd is frozen for whatever reason. This happens in hibernation where we are
not interested in google.

Especially we need to keep Minchan's patch after the softlimit reclaim support.
On a system which over-commit the softlimit, it is easily to make the system hang
w/o it.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5d036f5..65febc1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2318,6 +2318,7 @@ static bool all_unreclaimable(struct zonelist *zonelist,
 {
 	struct zoneref *z;
 	struct zone *zone;
+	bool all_unreclaimable = true;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -2325,11 +2326,13 @@ static bool all_unreclaimable(struct zonelist *zonelist,
 			continue;
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
-		if (!zone->all_unreclaimable)
-			return false;
+		if (zone_reclaimable(zone)) {
+			all_unreclaimable = false;
+			break;
+		}
 	}
 
-	return true;
+	return all_unreclaimable;
 }
 
 /*
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
