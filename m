Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id BC1346B0088
	for <linux-mm@kvack.org>; Wed,  8 May 2013 16:23:10 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v5 02/31] vmscan: take at least one pass with shrinkers
Date: Thu,  9 May 2013 00:22:50 +0400
Message-Id: <1368044599-3383-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1368044599-3383-1-git-send-email-glommer@openvz.org>
References: <1368044599-3383-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@openvz.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

In very low free kernel memory situations, it may be the case that we
have less objects to free than our initial batch size. If this is the
case, it is better to shrink those, and open space for the new workload
then to keep them and fail the new allocations. For the purpose of
defining what "very low memory" means, we will purposefuly exclude
kswapd runs.

More specifically, this happens because we encode this in a loop with
the condition: "while (total_scan >= batch_size)". So if we are in such
a case, we'll not even enter the loop.

This patch modifies turns it into a do () while {} loop, that will
guarantee that we scan it at least once, while keeping the behaviour
exactly the same for the cases in which total_scan > batch_size.

[ v5: differentiate no-scan case, don't do this for kswapd ]

Signed-off-by: Glauber Costa <glommer@openvz.org>
Reviewed-by: Dave Chinner <david@fromorbit.com>
Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
CC: "Theodore Ts'o" <tytso@mit.edu>
CC: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/vmscan.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..49691da 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -281,12 +281,30 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 					nr_pages_scanned, lru_pages,
 					max_pass, delta, total_scan);
 
-		while (total_scan >= batch_size) {
+		do {
 			int nr_before;
 
+			/*
+			 * When we are kswapd, there is no need for us to go
+			 * desperate and try to reclaim any number of objects
+			 * regardless of batch size. Direct reclaim, OTOH, may
+			 * benefit from freeing objects in any quantities. If
+			 * the workload is actually stressing those objects,
+			 * this may be the difference between succeeding or
+			 * failing an allocation.
+			 */
+			if ((total_scan < batch_size) && current_is_kswapd())
+				break;
+			/*
+			 * Differentiate between "few objects" and "no objects"
+			 * as returned by the count step.
+			 */
+			if (!total_scan)
+				break;
+
 			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
 			shrink_ret = do_shrinker_shrink(shrinker, shrink,
-							batch_size);
+						min(batch_size, total_scan));
 			if (shrink_ret == -1)
 				break;
 			if (shrink_ret < nr_before)
@@ -295,7 +313,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 			total_scan -= batch_size;
 
 			cond_resched();
-		}
+		} while (total_scan >= batch_size);
 
 		/*
 		 * move the unused scan count back into the shrinker in a
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
