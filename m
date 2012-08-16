Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 385E16B006E
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 16:54:02 -0400 (EDT)
Received: by wibhm2 with SMTP id hm2so54290wib.2
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 13:54:00 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 3/6] memcg: restructure shrink_slab to walk memcg hierarchy
Date: Thu, 16 Aug 2012 13:53:59 -0700
Message-Id: <1345150439-31003-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

This patch moves the main slab shrinking to do_shrink_slab() and restructures
shrink_slab() to walk the memory cgroup hiearchy. The memcg context is embedded
inside the shrink_control. The underling shrinker will be respecting the new
field by only reclaiming slab objects charged to the memcg.

The hierarchy walk in shrink_slab() is slightly different than the walk in
shrink_zone(), where the latter one walks each memcg once for each priority
under concurrent reclaim threads. It makes less sense for slab since they are
spread out the system instead of per-zone. So here each shrink_slab() will
trigger a full walk of each memcg under the sub-tree.

One optimization is under global reclaim, where we skip walking the whole tree
but instead pass into shrinker w/ mem_cgroup=NULL. Then it will end up scanning
the full dentry lru list.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |   43 +++++++++++++++++++++++++++++++++++--------
 1 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6ffdff6..7a3a1a4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -204,7 +204,7 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
  *
  * Returns the number of slab objects which we shrunk.
  */
-unsigned long shrink_slab(struct shrink_control *shrink,
+static unsigned long do_shrink_slab(struct shrink_control *shrink,
 			  unsigned long nr_pages_scanned,
 			  unsigned long lru_pages)
 {
@@ -214,12 +214,6 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 	if (nr_pages_scanned == 0)
 		nr_pages_scanned = SWAP_CLUSTER_MAX;
 
-	if (!down_read_trylock(&shrinker_rwsem)) {
-		/* Assume we'll be able to shrink next time */
-		ret = 1;
-		goto out;
-	}
-
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
 		long total_scan;
@@ -309,8 +303,41 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 
 		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
 	}
+
+	return ret;
+}
+
+unsigned long shrink_slab(struct shrink_control *shrink,
+			  unsigned long nr_pages_scanned,
+			  unsigned long lru_pages)
+{
+	unsigned long ret = 0;
+	struct mem_cgroup *root = shrink->target_mem_cgroup;
+	struct mem_cgroup *memcg;
+
+	if (!down_read_trylock(&shrinker_rwsem))
+		/* Assume we'll be able to shrink next time */
+		return 1;
+
+	/*
+	 * In case of a global reclaim, skip walking through the hierarchy and
+	 * invoke the shrinker with mem_cgroup=NULL.
+	 */
+	if (!root) {
+		ret = do_shrink_slab(shrink, nr_pages_scanned, lru_pages);
+		goto done;
+	}
+
+	memcg = mem_cgroup_iter(root, NULL, NULL);
+	do {
+		shrink->mem_cgroup = memcg;
+		ret += do_shrink_slab(shrink, nr_pages_scanned, lru_pages);
+		memcg = mem_cgroup_iter(root, memcg, NULL);
+	} while (memcg);
+
+done:
 	up_read(&shrinker_rwsem);
-out:
+
 	cond_resched();
 	return ret;
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
