Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0DE6B0062
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:01 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id u14so8240662lbd.4
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:00 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a4si23960114laf.113.2013.12.02.03.19.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:19:59 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 06/18] vmscan: rename shrink_slab() args to make it more generic
Date: Mon, 2 Dec 2013 15:19:41 +0400
Message-ID: <6fbe648a707331e0716cc7a4fc6366ca83a97f6a.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

Currently in addition to a shrink_control struct shrink_slab() takes two
arguments, nr_pages_scanned and lru_pages, which are used for balancing
slab reclaim versus page reclaim - roughly speaking, shrink_slab() will
try to scan nr_pages_scanned/lru_pages fraction of all slab objects.
However, shrink_slab() is not always called after page cache reclaim.
For example, drop_slab() uses shrink_slab() to drop as many slab objects
as possible and thus has to pass phony values 1000/1000 to it, which do
not make sense for nr_pages_scanned/lru_pages. Moreover, as soon as
kmemcg reclaim is introduced, we will have to make up phony values for
nr_pages_scanned and lru_pages again when doing kmem-only reclaim for a
memory cgroup, which is possible if the cgroup has its kmem limit less
than the total memory limit.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/mm.h            |    3 +--
 include/trace/events/vmscan.h |   20 ++++++++++----------
 mm/vmscan.c                   |   26 +++++++++++++-------------
 3 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd00..71c7f50 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1926,8 +1926,7 @@ int drop_caches_sysctl_handler(struct ctl_table *, int,
 #endif
 
 unsigned long shrink_slab(struct shrink_control *shrink,
-			  unsigned long nr_pages_scanned,
-			  unsigned long lru_pages);
+			  unsigned long fraction, unsigned long denominator);
 
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 132a985..6bed4ab 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -181,11 +181,11 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_re
 
 TRACE_EVENT(mm_shrink_slab_start,
 	TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
-		long nr_objects_to_shrink, unsigned long pgs_scanned,
-		unsigned long lru_pgs, unsigned long cache_items,
+		long nr_objects_to_shrink, unsigned long frac,
+		unsigned long denom, unsigned long cache_items,
 		unsigned long long delta, unsigned long total_scan),
 
-	TP_ARGS(shr, sc, nr_objects_to_shrink, pgs_scanned, lru_pgs,
+	TP_ARGS(shr, sc, nr_objects_to_shrink, frac, denom,
 		cache_items, delta, total_scan),
 
 	TP_STRUCT__entry(
@@ -193,8 +193,8 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__field(void *, shrink)
 		__field(long, nr_objects_to_shrink)
 		__field(gfp_t, gfp_flags)
-		__field(unsigned long, pgs_scanned)
-		__field(unsigned long, lru_pgs)
+		__field(unsigned long, frac)
+		__field(unsigned long, denom)
 		__field(unsigned long, cache_items)
 		__field(unsigned long long, delta)
 		__field(unsigned long, total_scan)
@@ -205,20 +205,20 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__entry->shrink = shr->scan_objects;
 		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
 		__entry->gfp_flags = sc->gfp_mask;
-		__entry->pgs_scanned = pgs_scanned;
-		__entry->lru_pgs = lru_pgs;
+		__entry->frac = frac;
+		__entry->denom = denom;
 		__entry->cache_items = cache_items;
 		__entry->delta = delta;
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("%pF %p: objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+	TP_printk("%pF %p: objects to shrink %ld gfp_flags %s frac %ld denom %ld cache items %ld delta %lld total_scan %ld",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nr_objects_to_shrink,
 		show_gfp_flags(__entry->gfp_flags),
-		__entry->pgs_scanned,
-		__entry->lru_pgs,
+		__entry->frac,
+		__entry->denom,
 		__entry->cache_items,
 		__entry->delta,
 		__entry->total_scan)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eea668d..6946997 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -219,7 +219,7 @@ EXPORT_SYMBOL(unregister_shrinker);
 
 static unsigned long
 shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
-		 unsigned long nr_pages_scanned, unsigned long lru_pages)
+		 unsigned long fraction, unsigned long denominator)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -243,9 +243,9 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
 
 	total_scan = nr;
-	delta = (4 * nr_pages_scanned) / shrinker->seeks;
+	delta = (4 * fraction) / shrinker->seeks;
 	delta *= max_pass;
-	do_div(delta, lru_pages + 1);
+	do_div(delta, denominator + 1);
 	total_scan += delta;
 	if (total_scan < 0) {
 		printk(KERN_ERR
@@ -278,7 +278,7 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 		total_scan = max_pass * 2;
 
 	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
-				nr_pages_scanned, lru_pages,
+				fraction, denominator,
 				max_pass, delta, total_scan);
 
 	while (total_scan >= batch_size) {
@@ -322,23 +322,23 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
  * If the vm encountered mapped pages on the LRU it increase the pressure on
  * slab to avoid swapping.
  *
- * We do weird things to avoid (scanned*seeks*entries) overflowing 32 bits.
+ * We do weird things to avoid (fraction*seeks*entries) overflowing 32 bits.
  *
- * `lru_pages' represents the number of on-LRU pages in all the zones which
- * are eligible for the caller's allocation attempt.  It is used for balancing
- * slab reclaim versus page reclaim.
+ * `fraction' and `denominator' are used for balancing slab reclaim versus page
+ * reclaim. To scan slab objects proportionally to page cache, pass the number
+ * of pages scanned and the total number of on-LRU pages in all the zones which
+ * are eligible for the caller's allocation attempt respectively.
  *
  * Returns the number of slab objects which we shrunk.
  */
 unsigned long shrink_slab(struct shrink_control *shrinkctl,
-			  unsigned long nr_pages_scanned,
-			  unsigned long lru_pages)
+			  unsigned long fraction, unsigned long denominator)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
-	if (nr_pages_scanned == 0)
-		nr_pages_scanned = SWAP_CLUSTER_MAX;
+	if (fraction == 0)
+		fraction = SWAP_CLUSTER_MAX;
 
 	if (!down_read_trylock(&shrinker_rwsem)) {
 		/*
@@ -361,7 +361,7 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 				break;
 
 			freed += shrink_slab_node(shrinkctl, shrinker,
-				 nr_pages_scanned, lru_pages);
+						  fraction, denominator);
 
 		}
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
