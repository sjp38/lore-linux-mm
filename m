Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 076B26B0036
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:19:58 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so324156pdj.1
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:19:58 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:49:54 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id EFD60E005B
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:50:56 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNJoc345875298
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:49:50 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNJoOk010215
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:49:51 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 09/40] mm: Add an optimized version of
 del_from_freelist to keep page allocation fast
Date: Thu, 26 Sep 2013 04:45:44 +0530
Message-ID: <20130925231542.26184.50035.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

One of the main advantages of this design of memory regions is that page
allocations can potentially be extremely fast - almost with no extra
overhead from memory regions.

To exploit that, introduce an optimized version of del_from_freelist(), which
utilizes the fact that we always delete items from the head of the list
during page allocation.

Basically, we want to keep a note of the region from which we are allocating
in a given freelist, to avoid having to compute the page-to-zone-region for
every page allocation. So introduce a 'next_region' pointer in every freelist
to achieve that, and use it to keep the fastpath of page allocation almost as
fast as it would have been without memory regions.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h     |   14 +++++++++++
 include/linux/mmzone.h |    6 +++++
 mm/page_alloc.c        |   62 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 81 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 307f375..4286a75 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -740,6 +740,20 @@ static inline int page_zone_region_id(const struct page *page)
 	return pgdat->node_regions[node_region_idx].zone_region_idx[z_num];
 }
 
+static inline void set_next_region_in_freelist(struct free_list *free_list)
+{
+	struct page *page;
+	int region_id;
+
+	if (unlikely(list_empty(&free_list->list))) {
+		free_list->next_region = NULL;
+	} else {
+		page = list_entry(free_list->list.next, struct page, lru);
+		region_id = page_zone_region_id(page);
+		free_list->next_region = &free_list->mr_list[region_id];
+	}
+}
+
 #ifdef SECTION_IN_PAGE_FLAGS
 static inline void set_page_section(struct page *page, unsigned long section)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2ac8025..4721a22 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -92,6 +92,12 @@ struct free_list {
 	struct list_head	list;
 
 	/*
+	 * Pointer to the region from which the next allocation will be
+	 * satisfied. (Same as the freelist's first pageblock's region.)
+	 */
+	struct mem_region_list	*next_region; /* for fast page allocation */
+
+	/*
 	 * Demarcates pageblocks belonging to different regions within
 	 * this freelist.
 	 */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c40715c..fe812e0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -551,6 +551,15 @@ static void add_to_freelist(struct page *page, struct free_list *free_list)
 	/* This is the first region, so add to the head of the list */
 	prev_region_list = &free_list->list;
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	WARN((list_empty(&free_list->list) && free_list->next_region != NULL),
+					"%s: next_region not NULL\n", __func__);
+#endif
+	/*
+	 * Set 'next_region' to this region, since this is the first region now
+	 */
+	free_list->next_region = region;
+
 out:
 	list_add(lru, prev_region_list);
 
@@ -558,6 +567,47 @@ out:
 	region->page_block = lru;
 }
 
+/**
+ * __rmqueue_smallest() *always* deletes elements from the head of the
+ * list. Use this knowledge to keep page allocation fast, despite being
+ * region-aware.
+ *
+ * Do *NOT* call this function if you are deleting from somewhere deep
+ * inside the freelist.
+ */
+static void rmqueue_del_from_freelist(struct page *page,
+				      struct free_list *free_list)
+{
+	struct list_head *lru = &page->lru;
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	WARN((free_list->list.next != lru),
+				"%s: page not at head of list", __func__);
+#endif
+
+	list_del(lru);
+
+	/* Fastpath */
+	if (--(free_list->next_region->nr_free)) {
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+		WARN(free_list->next_region->nr_free < 0,
+				"%s: nr_free is negative\n", __func__);
+#endif
+		return;
+	}
+
+	/*
+	 * Slowpath, when this is the last pageblock of this region
+	 * in this freelist.
+	 */
+	free_list->next_region->page_block = NULL;
+
+	/* Set 'next_region' to the new first region in the freelist. */
+	set_next_region_in_freelist(free_list);
+}
+
+/* Generic delete function for region-aware buddy allocator. */
 static void del_from_freelist(struct page *page, struct free_list *free_list)
 {
 	struct list_head *prev_page_lru, *lru, *p;
@@ -565,6 +615,11 @@ static void del_from_freelist(struct page *page, struct free_list *free_list)
 	int region_id;
 
 	lru = &page->lru;
+
+	/* Try to fastpath, if deleting from the head of the list */
+	if (lru == free_list->list.next)
+		return rmqueue_del_from_freelist(page, free_list);
+
 	region_id = page_zone_region_id(page);
 	region = &free_list->mr_list[region_id];
 	region->nr_free--;
@@ -600,6 +655,11 @@ page_found:
 	prev_page_lru = lru->prev;
 	list_del(lru);
 
+	/*
+	 * Since we are not deleting from the head of the freelist, the
+	 * 'next_region' pointer doesn't have to change.
+	 */
+
 	if (region->nr_free == 0) {
 		region->page_block = NULL;
 	} else {
@@ -1025,7 +1085,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 
 		page = list_entry(area->free_list[migratetype].list.next,
 							struct page, lru);
-		del_from_freelist(page, &area->free_list[migratetype]);
+		rmqueue_del_from_freelist(page, &area->free_list[migratetype]);
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
