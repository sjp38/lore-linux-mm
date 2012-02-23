Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 4F7A16B00EA
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:52:08 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:52:07 -0800 (PST)
Subject: [PATCH v3 06/21] mm: lruvec linking functions
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:52:04 +0400
Message-ID: <20120223135204.12988.75350.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

This patch adds links from page to its lruvec and from lruvec to its zone and node.
If CONFIG_CGROUP_MEM_RES_CTLR=n they just page_zone() and container_of().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm.h     |   37 +++++++++++++++++++++++++++++++++++++
 include/linux/mmzone.h |   12 ++++++++----
 mm/internal.h          |    1 +
 mm/memcontrol.c        |   27 ++++++++++++++++++++++++---
 mm/page_alloc.c        |   17 ++++++++++++++---
 5 files changed, 84 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ee3ebc1..c6dc4ab 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -728,6 +728,43 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
 #endif
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+
+/* Multiple lruvecs in zone */
+
+extern struct lruvec *page_lruvec(struct page *page);
+
+static inline struct zone *lruvec_zone(struct lruvec *lruvec)
+{
+	return lruvec->zone;
+}
+
+static inline struct pglist_data *lruvec_node(struct lruvec *lruvec)
+{
+	return lruvec->node;
+}
+
+#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+
+/* Single lruvec in zone */
+
+static inline struct lruvec *page_lruvec(struct page *page)
+{
+	return &page_zone(page)->lruvec;
+}
+
+static inline struct zone *lruvec_zone(struct lruvec *lruvec)
+{
+	return container_of(lruvec, struct zone, lruvec);
+}
+
+static inline struct pglist_data *lruvec_node(struct lruvec *lruvec)
+{
+	return lruvec_zone(lruvec)->zone_pgdat;
+}
+
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
+
 /*
  * Some inline functions in vmstat.h depend on page_zone()
  */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ddd0fd2..be8873a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -159,10 +159,6 @@ static inline int is_unevictable_lru(enum lru_list lru)
 	return (lru == LRU_UNEVICTABLE);
 }
 
-struct lruvec {
-	struct list_head pages_lru[NR_LRU_LISTS];
-};
-
 /* Mask used at gathering information at once (see memcontrol.c) */
 #define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
@@ -300,6 +296,14 @@ struct zone_reclaim_stat {
 	unsigned long		recent_scanned[2];
 };
 
+struct lruvec {
+	struct list_head	pages_lru[NR_LRU_LISTS];
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	struct zone		*zone;
+	struct pglist_data	*node;
+#endif
+};
+
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 
diff --git a/mm/internal.h b/mm/internal.h
index 2189af4..ef49dbf 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -100,6 +100,7 @@ extern void prep_compound_page(struct page *page, unsigned long order);
 extern bool is_free_buddy_page(struct page *page);
 #endif
 
+extern void init_zone_lruvec(struct zone *zone, struct lruvec *lruvec);
 
 /*
  * function for dealing with page's order in buddy system.
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8f8c7c4..8b53150 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1026,6 +1026,28 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 	return &mz->lruvec;
 }
 
+/**
+ * page_lruvec - get the lruvec there this page is located
+ * @page: the struct page pointer with stable reference
+ *
+ * page_cgroup->mem_cgroup pointer validity guaranteed by caller.
+ *
+ * Returns pointer to struct lruvec.
+ */
+struct lruvec *page_lruvec(struct page *page)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_disabled())
+		return &page_zone(page)->lruvec;
+
+	pc = lookup_page_cgroup(page);
+	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
+			page_to_nid(page), page_zonenum(page));
+	return &mz->lruvec;
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -4697,7 +4719,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
-	enum lru_list lru;
 	int zone, tmp = node;
 	/*
 	 * This routine is called against possible nodes.
@@ -4715,8 +4736,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		for_each_lru(lru)
-			INIT_LIST_HEAD(&mz->lruvec.pages_lru[lru]);
+		init_zone_lruvec(&NODE_DATA(node)->node_zones[zone],
+				 &mz->lruvec);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5f19392..1cc3afe 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4289,6 +4289,19 @@ static inline int pageblock_default_order(unsigned int order)
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
+void init_zone_lruvec(struct zone *zone, struct lruvec *lruvec)
+{
+	enum lru_list lru;
+
+	memset(lruvec, 0, sizeof(struct lruvec));
+	for_each_lru(lru)
+		INIT_LIST_HEAD(&lruvec->pages_lru[lru]);
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	lruvec->node = zone->zone_pgdat;
+	lruvec->zone = zone;
+#endif
+}
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -4312,7 +4325,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, memmap_pages;
-		enum lru_list lru;
 
 		size = zone_spanned_pages_in_node(nid, j, zones_size);
 		realsize = size - zone_absent_pages_in_node(nid, j,
@@ -4362,8 +4374,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->zone_pgdat = pgdat;
 
 		zone_pcp_init(zone);
-		for_each_lru(lru)
-			INIT_LIST_HEAD(&zone->lruvec.pages_lru[lru]);
+		init_zone_lruvec(zone, &zone->lruvec);
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
