Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id AF4796B0062
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:28 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id v20so3152102lbc.17
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:26 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 11/16] vmscan: take at least one pass with shrinkers
Date: Sun,  7 Jul 2013 11:56:51 -0400
Message-Id: <1373212616-11713-12-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Carlos Maiolino <cmaiolino@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

In very low free kernel memory situations, it may be the case that we
have less objects to free than our initial batch size. If this is the
case, it is better to shrink those, and open space for the new workload
then to keep them and fail the new allocations.

In particular, we are concerned with the direct reclaim case for memcg.
Although this same technique can be applied to other situations just as well,
we will start conservative and apply it for that case, which is the one
that matters the most.

[ v6: only do it per memcg ]
[ v5: differentiate no-scan case, don't do this for kswapd ]

Signed-off-by: Glauber Costa <glommer@openvz.org>
CC: Dave Chinner <david@fromorbit.com>
CC: Carlos Maiolino <cmaiolino@redhat.com>
CC: "Theodore Ts'o" <tytso@mit.edu>
CC: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/vmscan.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f1ff892..7b8ea36 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -291,20 +291,33 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 				nr_pages_scanned, lru_pages,
 				max_pass, delta, total_scan);
 
-	while (total_scan >= batch_size) {
+	do {
 		unsigned long ret;
+		unsigned long nr_to_scan = min(batch_size, total_scan);
+		struct mem_cgroup *memcg = shrinkctl->target_mem_cgroup;
+
+		/*
+		 * Differentiate between "few objects" and "no objects"
+		 * as returned by the count step.
+		 */
+		if (!total_scan)
+			break;
+
+		if ((total_scan < batch_size) &&
+		   !(memcg && memcg_kmem_is_active(memcg)))
+			break;
 
-		shrinkctl->nr_to_scan = batch_size;
+		shrinkctl->nr_to_scan = nr_to_scan;
 		ret = shrinker->scan_objects(shrinker, shrinkctl);
 		if (ret == SHRINK_STOP)
 			break;
 		freed += ret;
 
-		count_vm_events(SLABS_SCANNED, batch_size);
-		total_scan -= batch_size;
+		count_vm_events(SLABS_SCANNED, nr_to_scan);
+		total_scan -= nr_to_scan;
 
 		cond_resched();
-	}
+	} while (total_scan >= batch_size);
 
 	/*
 	 * move the unused scan count back into the shrinker in a
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
