Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 97F316B0037
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 19:19:11 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v4 02/31] vmscan: take at least one pass with shrinkers
Date: Sat, 27 Apr 2013 03:18:58 +0400
Message-Id: <1367018367-11278-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1367018367-11278-1-git-send-email-glommer@openvz.org>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@openvz.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

In very low free kernel memory situations, it may be the case that we
have less objects to free than our initial batch size. If this is the
case, it is better to shrink those, and open space for the new workload
then to keep them and fail the new allocations.

More specifically, this happens because we encode this in a loop with
the condition: "while (total_scan >= batch_size)". So if we are in such
a case, we'll not even enter the loop.

This patch modifies turns it into a do () while {} loop, that will
guarantee that we scan it at least once, while keeping the behaviour
exactly the same for the cases in which total_scan > batch_size.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Reviewed-by: Dave Chinner <david@fromorbit.com>
Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
CC: "Theodore Ts'o" <tytso@mit.edu>
CC: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/vmscan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..f9d2fba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -281,7 +281,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 					nr_pages_scanned, lru_pages,
 					max_pass, delta, total_scan);
 
-		while (total_scan >= batch_size) {
+		do {
 			int nr_before;
 
 			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
@@ -295,7 +295,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
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
