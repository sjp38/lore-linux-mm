Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7574B6B0039
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:15 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id mc6so1023200lab.26
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:14 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id yf5si3274618lab.107.2013.12.09.00.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:14 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 13/16] vmscan: take at least one pass with shrinkers
Date: Mon, 9 Dec 2013 12:05:54 +0400
Message-ID: <5287164773f8aade33ce17f3c91546c6e1afaf85.1386571280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com, Glauber Costa <gloomer@openvz.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

From: Glauber Costa <glommer@openvz.org>

In very low free kernel memory situations, it may be the case that we
have less objects to free than our initial batch size. If this is the
case, it is better to shrink those, and open space for the new workload
then to keep them and fail the new allocations.

In particular, we are concerned with the direct reclaim case for memcg.
Although this same technique can be applied to other situations just as
well, we will start conservative and apply it for that case, which is
the one that matters the most.

Signed-off-by: Glauber Costa <gloomer@openvz.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1997813..b2a5be9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -281,17 +281,22 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 				nr_pages_scanned, lru_pages,
 				max_pass, delta, total_scan);
 
-	while (total_scan >= batch_size) {
+	while (total_scan > 0) {
 		unsigned long ret;
+		unsigned long nr_to_scan = min(batch_size, total_scan);
 
-		shrinkctl->nr_to_scan = batch_size;
+		if (!shrinkctl->target_mem_cgroup &&
+		    total_scan < batch_size)
+			break;
+
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
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
