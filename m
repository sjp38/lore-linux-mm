Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id C0CC56B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:55:27 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:54:29 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6Jj9ET64880640
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:45:09 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6JtMME012120
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:55:23 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 7/8] mm: Add an optimized version of del_from_freelist to
 keep page allocation fast
Date: Wed, 07 Nov 2012 01:24:16 +0530
Message-ID: <20121106195407.6941.90203.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
fast as it would be without memory regions.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h     |   11 ++++++++++
 include/linux/mmzone.h |    6 ++++++
 mm/page_alloc.c        |   51 ++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a817b16..cab8709 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -725,6 +725,17 @@ static inline int page_zone_region_id(const struct page *page)
 	return pgdat->node_regions[node_region_idx].zone_region_idx[z_num];
 }
 
+static inline void set_next_region_in_freelist(struct free_list *free_list)
+{
+	if (list_empty(&free_list->list))
+		free_list->next_region = NULL;
+	else {
+		do {
+			free_list->next_region++;
+		} while (free_list->next_region->nr_free == 0);
+	}
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 static inline void set_page_section(struct page *page, unsigned long section)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index aba4d68..1d20aa1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -91,6 +91,12 @@ struct free_list {
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
index 52ff914..05c1fcf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -532,6 +532,11 @@ static void add_to_freelist(struct page *page, struct list_head *lru,
 	/* This is the first region, so add to the head of the list */
 	prev_region_list = &free_list->list;
 
+	/*
+	 * Set 'next_region' to this region, since this is the first region now
+	 */
+	free_list->next_region = region;
+
 out:
 	list_add(lru, prev_region_list);
 
@@ -539,6 +544,38 @@ out:
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
+static void rmqueue_del_from_freelist(struct list_head *lru,
+				      struct free_list *free_list)
+{
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	WARN_ON(free_list->list.next != lru);
+#endif
+
+	list_del(lru);
+
+	/* Fastpath */
+	if (--(free_list->next_region->nr_free))
+		return;
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
 static void del_from_freelist(struct page *page, struct list_head *lru,
 			      struct free_list *free_list)
 {
@@ -546,6 +583,11 @@ static void del_from_freelist(struct page *page, struct list_head *lru,
 	struct list_head *prev_page_lru;
 	int region_id;
 
+
+	/* Try to fastpath, if deleting from the head of the list */
+	if (lru == free_list->list.next)
+		return rmqueue_del_from_freelist(lru, free_list);
+
 	region_id = page_zone_region_id(page);
 	region = &free_list->mr_list[region_id];
 	region->nr_free--;
@@ -558,6 +600,11 @@ static void del_from_freelist(struct page *page, struct list_head *lru,
 	prev_page_lru = lru->prev;
 	list_del(lru);
 
+	/*
+	 * Since we are not deleting from the head of the list, the
+	 * 'next_region' pointer doesn't have to change.
+	 */
+
 	if (region->nr_free == 0)
 		region->page_block = NULL;
 	else
@@ -965,8 +1012,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 
 		page = list_entry(area->free_list[migratetype].list.next,
 							struct page, lru);
-		del_from_freelist(page, &page->lru,
-				  &area->free_list[migratetype]);
+		rmqueue_del_from_freelist(&page->lru,
+					  &area->free_list[migratetype]);
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
