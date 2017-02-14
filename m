Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1D4680FCF
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:36:18 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id w144so205269392oiw.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:18 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 128si1335974pgg.245.2017.02.14.11.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:36:17 -0800 (PST)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EJYr4U013696
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:17 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28m6rbgent-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:17 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 d9177eb4f2ec11e6ac6824be05956610-341e2a00 for <linux-mm@kvack.org>;	Tue, 14
 Feb 2017 11:36:15 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V3 5/7] mm: add vmstat account for MADV_FREE pages
Date: Tue, 14 Feb 2017 11:36:11 -0800
Message-ID: <8479e425796207433c6a2cba1d20be506cd62efd.1487100204.git.shli@fb.com>
In-Reply-To: <cover.1487100204.git.shli@fb.com>
References: <cover.1487100204.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Show MADV_FREE pages info in proc/sysfs files. Like other vm stat info
kernel exported, the MADV_FREE info will help us know how many memory
are MADV_FREE pages in a node/zone. This is useful for diagnoses and
monitoring in userspace.

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
 include/linux/mm_inline.h |  9 +++++++++
 include/linux/mmzone.h    |  2 ++
 mm/page_alloc.c           | 13 ++++++++++---
 mm/vmstat.c               |  2 ++
 6 files changed, 26 insertions(+), 3 deletions(-)

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
index e6e3af1..0de5cb6 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -126,6 +126,13 @@ static __always_inline enum lru_list page_lru(struct page *page)
 
 #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
 
+static inline void __update_lazyfree_page_stat(struct page *page,
+						int nr_pages)
+{
+	mod_node_page_state(page_pgdat(page), NR_LAZYFREE, nr_pages);
+	mod_zone_page_state(page_zone(page), NR_ZONE_LAZYFREE, nr_pages);
+}
+
 /*
  * lazyfree pages are clean anonymous pages. They have SwapBacked flag cleared
  * to destinguish normal anonymous pages.
@@ -134,12 +141,14 @@ static inline void set_page_lazyfree(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageAnon(page) || !PageSwapBacked(page), page);
 	ClearPageSwapBacked(page);
+	__update_lazyfree_page_stat(page, hpage_nr_pages(page));
 }
 
 static inline void clear_page_lazyfree(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageAnon(page) || PageSwapBacked(page), page);
 	SetPageSwapBacked(page);
+	__update_lazyfree_page_stat(page, -hpage_nr_pages(page));
 }
 
 static inline bool page_is_lazyfree(struct page *page)
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
index 19f438a..aa04d5c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1023,8 +1023,12 @@ static __always_inline bool free_pages_prepare(struct page *page,
 			(page + i)->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 		}
 	}
-	if (PageMappingFlags(page))
+	if (PageMappingFlags(page)) {
+		if (page_is_lazyfree(page))
+			__update_lazyfree_page_stat(page,
+						-hpage_nr_pages(page));
 		page->mapping = NULL;
+	}
 	if (memcg_kmem_enabled() && PageKmemcg(page))
 		memcg_kmem_uncharge(page, order);
 	if (check_free)
@@ -4459,7 +4463,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free:%lu free_pcp:%lu free_cma:%lu\n",
+		" free:%lu free_pcp:%lu free_cma:%lu lazy_free:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
 		global_node_page_state(NR_INACTIVE_ANON),
 		global_node_page_state(NR_ISOLATED_ANON),
@@ -4478,7 +4482,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_page_state(NR_BOUNCE),
 		global_page_state(NR_FREE_PAGES),
 		free_pcp,
-		global_page_state(NR_FREE_CMA_PAGES));
+		global_page_state(NR_FREE_CMA_PAGES),
+		global_node_page_state(NR_LAZYFREE));
 
 	for_each_online_pgdat(pgdat) {
 		if (show_mem_node_skip(filter, pgdat->node_id, nodemask))
@@ -4490,6 +4495,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" active_file:%lukB"
 			" inactive_file:%lukB"
 			" unevictable:%lukB"
+			" lazy_free:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
 			" mapped:%lukB"
@@ -4512,6 +4518,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(node_page_state(pgdat, NR_ACTIVE_FILE)),
 			K(node_page_state(pgdat, NR_INACTIVE_FILE)),
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
+			K(node_page_state(pgdat, NR_LAZYFREE)),
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
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
