Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id EE4746B0255
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 07:09:55 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so23414658pfb.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 04:09:55 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fn1si1728669pab.117.2016.01.21.04.09.55
        for <linux-mm@kvack.org>;
        Thu, 21 Jan 2016 04:09:55 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/3] thp: make split_queue per-node
Date: Thu, 21 Jan 2016 15:09:21 +0300
Message-Id: <1453378163-133609-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20160121012237.GE7119@redhat.com>
 <1453378163-133609-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Andrea Arcangeli suggested to make split queue per-node to improve
scalability. Let's do it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mmzone.h |  6 ++++++
 mm/huge_memory.c       | 49 ++++++++++++++++++++++++++-----------------------
 mm/page_alloc.c        |  5 +++++
 3 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 33bb1b19273e..7b6c2cfee390 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -682,6 +682,12 @@ typedef struct pglist_data {
 	 */
 	unsigned long first_deferred_pfn;
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	spinlock_t split_queue_lock;
+	struct list_head split_queue;
+	unsigned long split_queue_len;
+#endif
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2d1ffe9d0e26..769ea8db5771 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -138,9 +138,6 @@ static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
 
-static DEFINE_SPINLOCK(split_queue_lock);
-static LIST_HEAD(split_queue);
-static unsigned long split_queue_len;
 static struct shrinker deferred_split_shrinker;
 
 static void set_recommended_min_free_kbytes(void)
@@ -3358,6 +3355,7 @@ int total_mapcount(struct page *page)
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct page *head = compound_head(page);
+	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
 	struct anon_vma *anon_vma;
 	int count, mapcount, ret;
 	bool mlocked;
@@ -3401,19 +3399,19 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		lru_add_drain();
 
 	/* Prevent deferred_split_scan() touching ->_count */
-	spin_lock_irqsave(&split_queue_lock, flags);
+	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
 	count = page_count(head);
 	mapcount = total_mapcount(head);
 	if (!mapcount && count == 1) {
 		if (!list_empty(page_deferred_list(head))) {
-			split_queue_len--;
+			pgdata->split_queue_len--;
 			list_del(page_deferred_list(head));
 		}
-		spin_unlock_irqrestore(&split_queue_lock, flags);
+		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 		__split_huge_page(page, list);
 		ret = 0;
 	} else if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
-		spin_unlock_irqrestore(&split_queue_lock, flags);
+		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 		pr_alert("total_mapcount: %u, page_count(): %u\n",
 				mapcount, count);
 		if (PageTail(page))
@@ -3421,7 +3419,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		dump_page(page, "total_mapcount(head) > 0");
 		BUG();
 	} else {
-		spin_unlock_irqrestore(&split_queue_lock, flags);
+		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 		unfreeze_page(anon_vma, head);
 		ret = -EBUSY;
 	}
@@ -3436,52 +3434,56 @@ out:
 
 void free_transhuge_page(struct page *page)
 {
+	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
 	unsigned long flags;
 
-	spin_lock_irqsave(&split_queue_lock, flags);
+	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
 	if (!list_empty(page_deferred_list(page))) {
-		split_queue_len--;
+		pgdata->split_queue_len--;
 		list_del(page_deferred_list(page));
 	}
-	spin_unlock_irqrestore(&split_queue_lock, flags);
+	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 	free_compound_page(page);
 }
 
 void deferred_split_huge_page(struct page *page)
 {
+	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
 	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 
-	spin_lock_irqsave(&split_queue_lock, flags);
+	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
 	if (list_empty(page_deferred_list(page))) {
-		list_add_tail(page_deferred_list(page), &split_queue);
-		split_queue_len++;
+		list_add_tail(page_deferred_list(page), &pgdata->split_queue);
+		pgdata->split_queue_len++;
 	}
-	spin_unlock_irqrestore(&split_queue_lock, flags);
+	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 }
 
 static unsigned long deferred_split_count(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
+	struct pglist_data *pgdata = NODE_DATA(sc->nid);
 	/*
 	 * Split a page from split_queue will free up at least one page,
 	 * at most HPAGE_PMD_NR - 1. We don't track exact number.
 	 * Let's use HPAGE_PMD_NR / 2 as ballpark.
 	 */
-	return ACCESS_ONCE(split_queue_len) * HPAGE_PMD_NR / 2;
+	return ACCESS_ONCE(pgdata->split_queue_len) * HPAGE_PMD_NR / 2;
 }
 
 static unsigned long deferred_split_scan(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
+	struct pglist_data *pgdata = NODE_DATA(sc->nid);
 	unsigned long flags;
 	LIST_HEAD(list), *pos, *next;
 	struct page *page;
 	int split = 0;
 
-	spin_lock_irqsave(&split_queue_lock, flags);
-	list_splice_init(&split_queue, &list);
+	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	list_splice_init(&pgdata->split_queue, &list);
 
 	/* Take pin on all head pages to avoid freeing them under us */
 	list_for_each_safe(pos, next, &list) {
@@ -3490,10 +3492,10 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		/* race with put_compound_page() */
 		if (!get_page_unless_zero(page)) {
 			list_del_init(page_deferred_list(page));
-			split_queue_len--;
+			pgdata->split_queue_len--;
 		}
 	}
-	spin_unlock_irqrestore(&split_queue_lock, flags);
+	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 
 	list_for_each_safe(pos, next, &list) {
 		page = list_entry((void *)pos, struct page, mapping);
@@ -3505,9 +3507,9 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		put_page(page);
 	}
 
-	spin_lock_irqsave(&split_queue_lock, flags);
-	list_splice_tail(&list, &split_queue);
-	spin_unlock_irqrestore(&split_queue_lock, flags);
+	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	list_splice_tail(&list, &pgdata->split_queue);
+	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
 
 	return split * HPAGE_PMD_NR / 2;
 }
@@ -3516,6 +3518,7 @@ static struct shrinker deferred_split_shrinker = {
 	.count_objects = deferred_split_count,
 	.scan_objects = deferred_split_scan,
 	.seeks = DEFAULT_SEEKS,
+	.flags = SHRINKER_NUMA_AWARE,
 };
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63358d9f9aa9..ea2c4d3e0c03 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5210,6 +5210,11 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	pgdat->numabalancing_migrate_nr_pages = 0;
 	pgdat->numabalancing_migrate_next_window = jiffies;
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	spin_lock_init(&pgdat->split_queue_lock);
+	INIT_LIST_HEAD(&pgdat->split_queue);
+	pgdat->split_queue_len = 0;
+#endif
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat_page_ext_init(pgdat);
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
