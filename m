Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id B278F6B0038
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:50:06 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 03:16:14 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 5371E1258051
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:21:26 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39LnuIr50659446
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:19:56 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39LnxuE016303
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:50:00 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 07/15] mm: Add an optimized version of
 del_from_freelist to keep page allocation fast
Date: Wed, 10 Apr 2013 03:17:19 +0530
Message-ID: <20130409214717.4500.34638.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
index dff478b..cb0d898 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -741,6 +741,20 @@ static inline int page_zone_region_id(const struct page *page)
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
index 76667bf..d8d67fc 100644
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
index 7fb4254..a68174c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -539,6 +539,15 @@ static void add_to_freelist(struct page *page, struct free_list *free_list)
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
 
@@ -546,6 +555,47 @@ out:
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
@@ -553,6 +603,11 @@ static void del_from_freelist(struct page *page, struct free_list *free_list)
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
@@ -588,6 +643,11 @@ page_found:
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
@@ -1013,7 +1073,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 
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
