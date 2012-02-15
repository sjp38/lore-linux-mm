Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id A43536B0082
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:57:15 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1903161bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:57:15 -0800 (PST)
Subject: [PATCH RFC 02/15] mm: memory bookkeeping core
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 16 Feb 2012 02:57:11 +0400
Message-ID: <20120215225711.22050.54656.stgit@zurg>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

core blueprint

TODO:
* add direct link from page to book in page->flags instead of zoneid and nodeid
* atomic switching page book-id in page->flags bits
  [ something like atomic_long_xor(&page->flags, old_book_id ^ new_book_id) ]
* move freed pages into root book (zone->book)
* don't free struct book, reuse them after rcu grace period to keep rcu-iterating

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm_inline.h |   36 ++++++++++++++++++++++++++++++++++
 include/linux/mmzone.h    |    8 ++++++++
 init/Kconfig              |    4 ++++
 mm/memcontrol.c           |   48 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c           |    6 ++++++
 5 files changed, 101 insertions(+), 1 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index e0b78ca..6f42819 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -3,6 +3,42 @@
 
 #include <linux/huge_mm.h>
 
+#ifdef CONFIG_MEMORY_BOOKKEEPING
+
+extern struct book *page_book(struct page *book);
+
+static inline struct zone *book_zone(struct book *book)
+{
+	return book->zone;
+}
+
+static inline struct pglist_data *book_node(struct book *book)
+{
+	return book->node;
+}
+
+#else /* CONFIG_MEMORY_BOOKKEEPING */
+
+static inline struct book *page_book(struct page *page)
+{
+	return &page_zone(page)->book;
+}
+
+static inline struct zone *book_zone(struct book *book)
+{
+	return container_of(book, struct zone, book);
+}
+
+static inline struct pglist_data *book_node(struct book *book)
+{
+	return book_zone(book)->zone_pgdat;
+}
+
+#endif /* CONFIG_MEMORY_BOOKKEEPING */
+
+#define for_each_book(book, zone) \
+	list_for_each_entry_rcu(book, &zone->book_list, list)
+
 /**
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
  * @page: the page to test
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0b6e5d4..e05b003 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -297,7 +297,12 @@ struct zone_reclaim_stat {
 };
 
 struct book {
+#ifdef CONFIG_MEMORY_BOOKKEEPING
+	struct pglist_data	*node;
+	struct zone		*zone;
+#endif
 	struct list_head	pages_lru[NR_LRU_LISTS];
+	struct list_head	list;	/* for zone->book_list */
 };
 
 struct zone {
@@ -442,6 +447,9 @@ struct zone {
 	unsigned long		spanned_pages;	/* total size, including holes */
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
+	/* RCU-protected list of all books in this zone */
+	struct list_head	book_list;
+
 	/*
 	 * rarely used fields:
 	 */
diff --git a/init/Kconfig b/init/Kconfig
index ab0d680..70c3cef 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -651,10 +651,14 @@ config RESOURCE_COUNTERS
 	  This option enables controller independent resource accounting
 	  infrastructure that works with cgroups.
 
+config MEMORY_BOOKKEEPING
+	bool
+
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
 	depends on RESOURCE_COUNTERS
 	select MM_OWNER
+	select MEMORY_BOOKKEEPING
 	help
 	  Provides a memory resource controller that manages both anonymous
 	  memory and page cache. (See Documentation/cgroups/memory.txt)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 578118b..06d946f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -152,6 +152,7 @@ struct mem_cgroup_per_zone {
 
 struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
+	struct rcu_head		rcu_head;
 };
 
 struct mem_cgroup_lru_info {
@@ -990,6 +991,32 @@ out:
 EXPORT_SYMBOL(mem_cgroup_count_vm_event);
 
 /**
+ * page_book - get the book there this page is located
+ * @page: the struct page pointer with stable reference
+ *
+ * Returns pointer to struct book.
+ *
+ * FIXME optimized this translation, add direct link from page to book.
+ */
+struct book *page_book(struct page *page)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_disabled())
+		return &page_zone(page)->book;
+
+	pc = lookup_page_cgroup(page);
+	if (!PageCgroupUsed(pc))
+		return &page_zone(page)->book;
+	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+	smp_rmb();
+	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
+			page_to_nid(page), page_zonenum(page));
+	return &mz->book;
+}
+
+/**
  * mem_cgroup_zone_book - get the lru list vector for a zone and memcg
  * @zone: zone of the wanted book
  * @mem: memcg of the wanted book
@@ -4740,6 +4767,11 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 		mz = &pn->zoneinfo[zone];
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->book.pages_lru[l]);
+		mz->book.node = NODE_DATA(node);
+		mz->book.zone = &NODE_DATA(node)->node_zones[zone];
+		spin_lock(&mz->book.zone->lock);
+		list_add_tail_rcu(&mz->book.list, &mz->book.zone->book_list);
+		spin_unlock(&mz->book.zone->lock);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = memcg;
@@ -4750,7 +4782,21 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
-	kfree(memcg->info.nodeinfo[node]);
+	struct mem_cgroup_per_node *pn;
+	struct mem_cgroup_per_zone *mz;
+	int zone;
+
+	pn = memcg->info.nodeinfo[node];
+	if (!pn)
+		return;
+
+	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
+		mz = mem_cgroup_zoneinfo(memcg, node, zone);
+		spin_lock(&mz->book.zone->lock);
+		list_del_rcu(&mz->book.list);
+		spin_unlock(&mz->book.zone->lock);
+	}
+	kfree_rcu(pn, rcu_head);
 }
 
 static struct mem_cgroup *mem_cgroup_alloc(void)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 08b4e4b..ead327b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4312,6 +4312,12 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_pcp_init(zone);
 		for_each_lru(lru)
 			INIT_LIST_HEAD(&zone->book.pages_lru[lru]);
+#ifdef CONFIG_MEMORY_BOOKKEEPING
+		zone->book.node = pgdat;
+		zone->book.zone = zone;
+#endif
+		INIT_LIST_HEAD(&zone->book_list);
+		list_add(&zone->book.list, &zone->book_list);
 		zone->reclaim_stat.recent_rotated[0] = 0;
 		zone->reclaim_stat.recent_rotated[1] = 0;
 		zone->reclaim_stat.recent_scanned[0] = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
