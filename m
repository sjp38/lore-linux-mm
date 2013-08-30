Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 5250F6B0044
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 08:41:57 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 13:41:56 +0100
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 7913AC90044
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 08:41:53 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UCfr9t16253092
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 12:41:53 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UCfpul007845
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:41:53 -0300
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 11/35] mm: Add an optimized version of
 del_from_freelist to keep page allocation fast
Date: Fri, 30 Aug 2013 18:07:55 +0530
Message-ID: <20130830123743.24352.27969.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830123303.24352.18732.stgit@srivatsabhat.in.ibm.com>
References: <20130830123303.24352.18732.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
index 52329d1..156d7db 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -747,6 +747,20 @@ static inline int page_zone_region_id(const struct page *page)
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
index 201ab42..932e71f 100644
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
index 07ac019..52b6655 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -548,6 +548,15 @@ static void add_to_freelist(struct page *page, struct free_list *free_list)
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
 
@@ -555,6 +564,47 @@ out:
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
@@ -562,6 +612,11 @@ static void del_from_freelist(struct page *page, struct free_list *free_list)
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
@@ -597,6 +652,11 @@ page_found:
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
@@ -1022,7 +1082,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 
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
