Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 7F5BF6B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 01:52:49 -0400 (EDT)
Received: by lagz14 with SMTP id z14so243004lag.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 22:52:47 -0700 (PDT)
Subject: [PATCH v2 02/12] mm: add link from struct lruvec to struct zone
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 02 May 2012 09:52:35 +0400
Message-ID: <20120502055235.28244.86363.stgit@zurg>
In-Reply-To: <20120426075356.18961.40318.stgit@zurg>
References: <20120426075356.18961.40318.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

This is first stage of struct mem_cgroup_zone removal, further patches replaces
struct mem_cgroup_zone with pointer to struct lruvec.

If CONFIG_CGROUP_MEM_RES_CTLR=n lruvec_zone() is just container_of().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---

v2: fix comment
---
 include/linux/mmzone.h |   14 ++++++++++++++
 mm/memcontrol.c        |    4 +---
 mm/mmzone.c            |   14 ++++++++++++++
 mm/page_alloc.c        |    8 +-------
 4 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5c4880b..2427706 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -201,6 +201,9 @@ struct zone_reclaim_stat {
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	struct zone *zone;
+#endif
 };
 
 /* Mask used at gathering information at once (see memcontrol.c) */
@@ -729,6 +732,17 @@ extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
 				     unsigned long size,
 				     enum memmap_context context);
 
+extern void lruvec_init(struct lruvec *lruvec, struct zone *zone);
+
+static inline struct zone *lruvec_zone(struct lruvec *lruvec)
+{
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	return lruvec->zone;
+#else
+	return container_of(lruvec, struct zone, lruvec);
+#endif
+}
+
 #ifdef CONFIG_HAVE_MEMORY_PRESENT
 void memory_present(int nid, unsigned long start, unsigned long end);
 #else
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a2184a2..3e7b91c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4934,7 +4934,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
-	enum lru_list lru;
 	int zone, tmp = node;
 	/*
 	 * This routine is called against possible nodes.
@@ -4952,8 +4951,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		for_each_lru(lru)
-			INIT_LIST_HEAD(&mz->lruvec.lists[lru]);
+		lruvec_init(&mz->lruvec, &NODE_DATA(node)->node_zones[zone]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 7cf7b7d..6830eab 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -86,3 +86,17 @@ int memmap_valid_within(unsigned long pfn,
 	return 1;
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
+
+void lruvec_init(struct lruvec *lruvec, struct zone *zone)
+{
+	enum lru_list lru;
+
+	memset(lruvec, 0, sizeof(struct lruvec));
+
+	for_each_lru(lru)
+		INIT_LIST_HEAD(&lruvec->lists[lru]);
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	lruvec->zone = zone;
+#endif
+}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b951de..35478bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4361,7 +4361,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, memmap_pages;
-		enum lru_list lru;
 
 		size = zone_spanned_pages_in_node(nid, j, zones_size);
 		realsize = size - zone_absent_pages_in_node(nid, j,
@@ -4411,12 +4410,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
-		for_each_lru(lru)
-			INIT_LIST_HEAD(&zone->lruvec.lists[lru]);
-		zone->lruvec.reclaim_stat.recent_rotated[0] = 0;
-		zone->lruvec.reclaim_stat.recent_rotated[1] = 0;
-		zone->lruvec.reclaim_stat.recent_scanned[0] = 0;
-		zone->lruvec.reclaim_stat.recent_scanned[1] = 0;
+		lruvec_init(&zone->lruvec, zone);
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
