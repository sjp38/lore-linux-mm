Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 615AF6B00EC
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:12 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:11 -0800 (PST)
Subject: [PATCH v2 09/22] mm: link lruvec with zone and node
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:09 +0400
Message-ID: <20120220172309.22196.76135.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch adds links from lruvec to its zone and node.
For CONFIG_CGROUP_MEM_RES_CTLR=n this is just container_of().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm.h     |   20 ++++++++++++++++++++
 include/linux/mmzone.h |    4 ++++
 mm/memcontrol.c        |    2 ++
 mm/page_alloc.c        |    4 ++++
 4 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e483f30..24c24f0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -734,6 +734,16 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
 
 extern struct lruvec *page_lruvec(struct page *lruvec);
 
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
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 
 /* Single lruvec in zone */
@@ -743,6 +753,16 @@ static inline struct lruvec *page_lruvec(struct page *page)
 	return &page_zone(page)->lruvec;
 }
 
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
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR */
 
 /*
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b39f230..bd2cae4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -297,6 +297,10 @@ struct zone_reclaim_stat {
 };
 
 struct lruvec {
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	struct pglist_data	*node;
+	struct zone		*zone;
+#endif
 	struct list_head	pages_lru[NR_LRU_LISTS];
 	unsigned long		pages_count[NR_LRU_LISTS];
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fa64817..e29420d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4673,6 +4673,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 			INIT_LIST_HEAD(&mz->lruvec.pages_lru[lru]);
 			mz->lruvec.pages_count[lru] = 0;
 		}
+		mz->lruvec.node = NODE_DATA(node);
+		mz->lruvec.zone = &NODE_DATA(node)->node_zones[zone];
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c7fcddc..c500084 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4366,6 +4366,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 			INIT_LIST_HEAD(&zone->lruvec.pages_lru[lru]);
 			zone->lruvec.pages_count[lru] = 0;
 		}
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+		zone->lruvec.node = pgdat;
+		zone->lruvec.zone = zone;
+#endif
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
