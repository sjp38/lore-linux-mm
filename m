Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ABA318D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 06:44:21 -0500 (EST)
From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
Date: Sat,  5 Mar 2011 14:44:16 +0300
Message-Id: <1299325456-2687-1-git-send-email-avagin@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, avagin@openvz.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Check zone->all_unreclaimable in all_unreclaimable(), otherwise the
kernel may hang up, because shrink_zones() will do nothing, but
all_unreclaimable() will say, that zone has reclaimable pages.

do_try_to_free_pages()
	shrink_zones()
		 for_each_zone
			if (zone->all_unreclaimable)
				continue
	if !all_unreclaimable(zonelist, sc)
		return 1

__alloc_pages_slowpath()
retry:
	did_some_progress = do_try_to_free_pages(page)
	...
	if (!page && did_some_progress)
		retry;

Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 mm/vmscan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6771ea7..1c056f7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2002,6 +2002,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			gfp_zone(sc->gfp_mask), sc->nodemask) {
+		if (zone->all_unreclaimable)
+			continue;
 		if (!populated_zone(zone))
 			continue;
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
