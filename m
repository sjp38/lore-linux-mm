Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50C486B0261
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 18:33:30 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e4so38528476pfg.4
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:30 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b4si26797642plb.157.2017.02.03.15.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 15:33:29 -0800 (PST)
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v13NWZDS015221
	for <linux-mm@kvack.org>; Fri, 3 Feb 2017 15:33:28 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 28d16krb74-7
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:28 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 28869cb4ea6911e69caa24be05956610-f1dfaa50 for <linux-mm@kvack.org>;	Fri, 03
 Feb 2017 15:33:25 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V2 5/7] mm: add vmstat account for MADV_FREE pages
Date: Fri, 3 Feb 2017 15:33:21 -0800
Message-ID: <d12c1b4b571817c0f05a57cc062d91d1a336fce5.1486163864.git.shli@fb.com>
In-Reply-To: <cover.1486163864.git.shli@fb.com>
References: <cover.1486163864.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Show MADV_FREE pages info in proc/sysfs files.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 drivers/base/node.c       |  2 ++
 fs/proc/meminfo.c         |  1 +
 include/linux/mm_inline.h | 31 ++++++++++++++++++++++++++++---
 include/linux/mmzone.h    |  2 ++
 mm/page_alloc.c           |  7 +++++--
 mm/vmscan.c               |  9 +++++++--
 mm/vmstat.c               |  2 ++
 7 files changed, 47 insertions(+), 7 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f96..9138db8 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -71,6 +71,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
 		       "Node %d Unevictable:    %8lu kB\n"
+		       "Node %d LazyFree:       %8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
@@ -84,6 +85,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_ACTIVE_FILE)),
 		       nid, K(node_page_state(pgdat, NR_INACTIVE_FILE)),
 		       nid, K(node_page_state(pgdat, NR_UNEVICTABLE)),
+		       nid, K(node_page_state(pgdat, NR_LAZYFREE)),
 		       nid, K(sum_zone_node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 8a42849..b2e7b31 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -80,6 +80,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Active(file):   ", pages[LRU_ACTIVE_FILE]);
 	show_val_kb(m, "Inactive(file): ", pages[LRU_INACTIVE_FILE]);
 	show_val_kb(m, "Unevictable:    ", pages[LRU_UNEVICTABLE]);
+	show_val_kb(m, "LazyFree:       ", global_node_page_state(NR_LAZYFREE));
 	show_val_kb(m, "Mlocked:        ", global_page_state(NR_MLOCK));
 
 #ifdef CONFIG_HIGHMEM
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index fdded06..3e496de 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -48,25 +48,50 @@ static __always_inline void update_lru_size(struct lruvec *lruvec,
 #endif
 }
 
+static __always_inline void __update_lazyfree_size(struct lruvec *lruvec,
+				enum zone_type zid, int nr_pages)
+{
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+
+	__mod_node_page_state(pgdat, NR_LAZYFREE, nr_pages);
+	__mod_zone_page_state(&pgdat->node_zones[zid], NR_ZONE_LAZYFREE,
+				nr_pages);
+}
+
 static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
-	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
+	enum zone_type zid = page_zonenum(page);
+	int nr_pages = hpage_nr_pages(page);
+
+	if (lru == LRU_INACTIVE_FILE && page_is_lazyfree(page))
+		__update_lazyfree_size(lruvec, zid, nr_pages);
+	update_lru_size(lruvec, lru, zid, nr_pages);
 	list_add(&page->lru, &lruvec->lists[lru]);
 }
 
 static __always_inline void add_page_to_lru_list_tail(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
-	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
+	enum zone_type zid = page_zonenum(page);
+	int nr_pages = hpage_nr_pages(page);
+
+	if (lru == LRU_INACTIVE_FILE && page_is_lazyfree(page))
+		__update_lazyfree_size(lruvec, zid, nr_pages);
+	update_lru_size(lruvec, lru, zid, nr_pages);
 	list_add_tail(&page->lru, &lruvec->lists[lru]);
 }
 
 static __always_inline void del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
+	enum zone_type zid = page_zonenum(page);
+	int nr_pages = hpage_nr_pages(page);
+
 	list_del(&page->lru);
-	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
+	if (lru == LRU_INACTIVE_FILE && page_is_lazyfree(page))
+		__update_lazyfree_size(lruvec, zid, -nr_pages);
+	update_lru_size(lruvec, lru, zid, -nr_pages);
 }
 
 /**
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 338a786a..78985f1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -118,6 +118,7 @@ enum zone_stat_item {
 	NR_ZONE_INACTIVE_FILE,
 	NR_ZONE_ACTIVE_FILE,
 	NR_ZONE_UNEVICTABLE,
+	NR_ZONE_LAZYFREE,
 	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_SLAB_RECLAIMABLE,
@@ -147,6 +148,7 @@ enum node_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
+	NR_LAZYFREE,		/*  "     "     "   "       "         */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 11b4cd4..d0ff8c2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4453,7 +4453,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free:%lu free_pcp:%lu free_cma:%lu\n",
+		" free:%lu free_pcp:%lu free_cma:%lu lazy_free:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
 		global_node_page_state(NR_INACTIVE_ANON),
 		global_node_page_state(NR_ISOLATED_ANON),
@@ -4472,7 +4472,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_page_state(NR_BOUNCE),
 		global_page_state(NR_FREE_PAGES),
 		free_pcp,
-		global_page_state(NR_FREE_CMA_PAGES));
+		global_page_state(NR_FREE_CMA_PAGES),
+		global_node_page_state(NR_LAZYFREE));
 
 	for_each_online_pgdat(pgdat) {
 		if (show_mem_node_skip(filter, pgdat->node_id, nodemask))
@@ -4484,6 +4485,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" active_file:%lukB"
 			" inactive_file:%lukB"
 			" unevictable:%lukB"
+			" lazy_free:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
 			" mapped:%lukB"
@@ -4506,6 +4508,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(node_page_state(pgdat, NR_ACTIVE_FILE)),
 			K(node_page_state(pgdat, NR_INACTIVE_FILE)),
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
+			K(node_page_state(pgdat, NR_LAZYFREE)),
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b304a84..1a98467 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1442,7 +1442,8 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
  * be complete before mem_cgroup_update_lru_size due to a santity check.
  */
 static __always_inline void update_lru_sizes(struct lruvec *lruvec,
-			enum lru_list lru, unsigned long *nr_zone_taken)
+			enum lru_list lru, unsigned long *nr_zone_taken,
+			unsigned long *nr_zone_lazyfree)
 {
 	int zid;
 
@@ -1450,6 +1451,7 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
 		if (!nr_zone_taken[zid])
 			continue;
 
+		__update_lazyfree_size(lruvec, zid, -nr_zone_lazyfree[zid]);
 		__update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
 #ifdef CONFIG_MEMCG
 		mem_cgroup_update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
@@ -1486,6 +1488,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	struct list_head *src = &lruvec->lists[lru];
 	unsigned long nr_taken = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
+	unsigned long nr_zone_lazyfree[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	unsigned long skipped = 0, total_skipped = 0;
 	unsigned long scan, nr_pages;
@@ -1517,6 +1520,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			nr_pages = hpage_nr_pages(page);
 			nr_taken += nr_pages;
 			nr_zone_taken[page_zonenum(page)] += nr_pages;
+			if (page_is_lazyfree(page))
+				nr_zone_lazyfree[page_zonenum(page)] += nr_pages;
 			list_move(&page->lru, dst);
 			break;
 
@@ -1560,7 +1565,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	*nr_scanned = scan + total_skipped;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
 				    scan, skipped, nr_taken, mode, lru);
-	update_lru_sizes(lruvec, lru, nr_zone_taken);
+	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_zone_lazyfree);
 	return nr_taken;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7774196..a70b52d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -926,6 +926,7 @@ const char * const vmstat_text[] = {
 	"nr_zone_inactive_file",
 	"nr_zone_active_file",
 	"nr_zone_unevictable",
+	"nr_zone_lazyfree",
 	"nr_zone_write_pending",
 	"nr_mlock",
 	"nr_slab_reclaimable",
@@ -952,6 +953,7 @@ const char * const vmstat_text[] = {
 	"nr_inactive_file",
 	"nr_active_file",
 	"nr_unevictable",
+	"nr_lazyfree",
 	"nr_isolated_anon",
 	"nr_isolated_file",
 	"nr_pages_scanned",
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
