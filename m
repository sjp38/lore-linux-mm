Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id DD17F6B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 14:25:42 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id b8so3943186lan.5
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 11:25:42 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 2si6965587laz.89.2014.01.17.11.25.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 11:25:41 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 3/3] mm: vmscan: shrink_slab: do not skip caches with < batch_size objects
Date: Fri, 17 Jan 2014 23:25:31 +0400
Message-ID: <461628a5763b31bb36cc3dd7f6b89b06a907234f.1389982079.git.vdavydov@parallels.com>
In-Reply-To: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com>
References: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

In its current implementation, shrink_slab() won't scan caches that have
less than batch_size objects. If there are only a few shrinkers
available, such a behavior won't cause any problems, because the
batch_size is usually small, but if we have a lot of slab shrinkers,
which is perfectly possible since FS shrinkers are now per-superblock,
we can end up with hundreds of megabytes of practically unreclaimable
kmem objects. For instance, mounting a thousand of ext2 FS images with a
hundred of files in each and iterating over all the files using du(1)
will result in about 200 Mb of FS caches that cannot be dropped even
with the aid of the vm.drop_caches sysctl! Fix this.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Glauber Costa <glommer@gmail.com>
---
 mm/vmscan.c |   25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f6d716d..2e710d4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -275,7 +275,7 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	 * a large delta change is calculated directly.
 	 */
 	if (delta < freeable / 4)
-		total_scan = min(total_scan, freeable / 2);
+		total_scan = min(total_scan, max(freeable / 2, batch_size));
 
 	/*
 	 * Avoid risking looping forever due to too large nr value:
@@ -289,21 +289,34 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 				nr_pages_scanned, lru_pages,
 				freeable, delta, total_scan);
 
-	while (total_scan >= batch_size) {
+	/*
+	 * To avoid CPU cache thrashing, we should not scan less than
+	 * batch_size objects in one pass, but if the cache has less
+	 * than batch_size objects in total, and we really want to
+	 * shrink them all, go ahead and scan what we have, otherwise
+	 * last batch_size objects will never get reclaimed.
+	 */
+	if (total_scan < batch_size &&
+	    !(freeable < batch_size && total_scan >= freeable))
+		goto out;
+
+	do {
 		unsigned long ret;
+		unsigned long nr_to_scan = min(total_scan, batch_size);
 
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
 
+out:
 	/*
 	 * move the unused scan count back into the shrinker in a
 	 * manner that handles concurrent updates. If we exhausted the
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
