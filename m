Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 3211E6B005A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:21:55 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:21:54 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 4EB581FF001D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:21:52 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDLqcw185066
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:21:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDLoZH013992
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:21:52 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 13/35] mm: A new optimized O(log n) sorting algo to
 speed up buddy-sorting
Date: Fri, 30 Aug 2013 18:47:54 +0530
Message-ID: <20130830131746.4947.94934.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The sorted-buddy design for memory power management depends on
keeping the buddy freelists region-sorted. And this sorting operation
has been pushed to the free() logic, keeping the alloc() path fast.

However, we would like to also keep the free() path as fast as possible,
since it holds the zone->lock, which will indirectly affect alloc() also.

So replace the existing O(n) sorting logic used in the free-path, with
a new special-case sorting algorithm of time complexity O(log n), in order
to optimize the free() path further. This algorithm uses a bitmap-based
radix tree to help speed up the sorting.

One of the other main advantages of this O(log n) design is that it can
support large amounts of RAM (upto 2 TB and beyond) quite effortlessly.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |    2 +
 mm/page_alloc.c        |  144 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 139 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 932e71f..b35020f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -102,6 +102,8 @@ struct free_list {
 	 * this freelist.
 	 */
 	struct mem_region_list	mr_list[MAX_NR_ZONE_REGIONS];
+	DECLARE_BITMAP(region_root_mask, BITS_PER_LONG);
+	DECLARE_BITMAP(region_leaf_mask, MAX_NR_ZONE_REGIONS);
 };
 
 struct free_area {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 52b6655..4da02fc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -514,11 +514,131 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
+/**
+ *
+ * An example should help illustrate the bitmap representation of memory
+ * regions easily. So consider the following scenario:
+ *
+ * MAX_NR_ZONE_REGIONS = 256
+ * DECLARE_BITMAP(region_leaf_mask, MAX_NR_ZONE_REGIONS);
+ * DECLARE_BITMAP(region_root_mask, BITS_PER_LONG);
+ *
+ * Here region_leaf_mask is an array of unsigned longs. And region_root_mask
+ * is a single unsigned long. The tree notion is constructed like this:
+ * Each bit in the region_root_mask will correspond to an array element of
+ * region_leaf_mask, as shown below. (The elements of the region_leaf_mask
+ * array are shown as being discontiguous, only to help illustrate the
+ * concept easily).
+ *
+ *                    Region Root Mask
+ *                   ___________________
+ *                  |____|____|____|____|
+ *                    /    |     \     \
+ *                   /     |      \     \
+ *             ________    |   ________  \
+ *            |________|   |  |________|  \
+ *                         |               \
+ *                      ________        ________
+ *                     |________|      |________|   <--- Region Leaf Mask
+ *                                                         array elements
+ *
+ * If an array element in the leaf mask is non-zero, the corresponding bit
+ * for that array element will be set in the root mask. Every bit in the
+ * region_leaf_mask will correspond to a memory region; it is set if that
+ * region is present in that free list, cleared otherwise.
+ *
+ * This arrangement helps us find the previous set bit in region_leaf_mask
+ * using at most 2 bitmask-searches (each bitmask of size BITS_PER_LONG),
+ * one at the root-level, and one at the leaf level. Thus, this design of
+ * an optimized access structure reduces the search-complexity when dealing
+ * with large amounts of memory. The worst-case time-complexity of buddy
+ * sorting comes to O(log n) using this algorithm, where 'n' is the no. of
+ * memory regions in the zone.
+ *
+ * For example, with MEM_REGION_SIZE = 512 MB, on 64-bit machines, we can
+ * deal with upto 2TB of RAM (MAX_NR_ZONE_REGIONS = 4096) efficiently (just
+ * 12 ops in the worst case, as opposed to 4096 in an O(n) algo) with such
+ * an arrangement, without even needing to extend this 2-level hierarchy
+ * any further.
+ */
+
+static void set_region_bit(int region_id, struct free_list *free_list)
+{
+	set_bit(region_id, free_list->region_leaf_mask);
+	set_bit(BIT_WORD(region_id), free_list->region_root_mask);
+}
+
+static void clear_region_bit(int region_id, struct free_list *free_list)
+{
+	clear_bit(region_id, free_list->region_leaf_mask);
+
+	if (!(free_list->region_leaf_mask[BIT_WORD(region_id)]))
+		clear_bit(BIT_WORD(region_id), free_list->region_root_mask);
+
+}
+
+/* Note that Region 0 corresponds to bit position 1 (0x1) and so on */
+static int find_prev_region(int region_id, struct free_list *free_list)
+{
+	int leaf_word, prev_region_id;
+	unsigned long *region_root_mask, *region_leaf_mask;
+	unsigned long tmp_root_mask, tmp_leaf_mask;
+
+	if (!region_id)
+		return -1; /* No previous region */
+
+	leaf_word = BIT_WORD(region_id);
+
+	region_root_mask = free_list->region_root_mask;
+	region_leaf_mask = free_list->region_leaf_mask;
+
+
+	/*
+	 * Try to get the prev region id without going to the root mask.
+	 * Note that region_id itself might not be set yet.
+	 */
+	if (region_leaf_mask[leaf_word]) {
+		tmp_leaf_mask = region_leaf_mask[leaf_word] &
+							(BIT_MASK(region_id) - 1);
+
+		if (tmp_leaf_mask) {
+			/* Prev region is in this leaf mask itself. Find it. */
+			prev_region_id = leaf_word * BITS_PER_LONG +
+							__fls(tmp_leaf_mask);
+			goto out;
+		}
+	}
+
+	/* Search the root mask for the leaf mask having prev region */
+	tmp_root_mask = *region_root_mask & (BIT(leaf_word) - 1);
+	if (tmp_root_mask) {
+		leaf_word = __fls(tmp_root_mask);
+
+		/* Get the prev region id from the leaf mask */
+		prev_region_id = leaf_word * BITS_PER_LONG +
+					__fls(region_leaf_mask[leaf_word]);
+	} else {
+		/*
+		 * This itself is the first populated region in this
+		 * freelist, so previous region doesn't exist.
+		 */
+		prev_region_id = -1;
+	}
+
+out:
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	WARN(prev_region_id >= region_id, "%s: bitmap logic messed up\n",
+								__func__);
+#endif
+	return prev_region_id;
+}
+
 static void add_to_freelist(struct page *page, struct free_list *free_list)
 {
 	struct list_head *prev_region_list, *lru;
 	struct mem_region_list *region;
-	int region_id, i;
+	int region_id, prev_region_id;
 
 	lru = &page->lru;
 	region_id = page_zone_region_id(page);
@@ -536,12 +656,17 @@ static void add_to_freelist(struct page *page, struct free_list *free_list)
 #endif
 
 	if (!list_empty(&free_list->list)) {
-		for (i = region_id - 1; i >= 0; i--) {
-			if (free_list->mr_list[i].page_block) {
-				prev_region_list =
-					free_list->mr_list[i].page_block;
-				goto out;
-			}
+		prev_region_id = find_prev_region(region_id, free_list);
+		if (prev_region_id >= 0) {
+			prev_region_list =
+				free_list->mr_list[prev_region_id].page_block;
+#ifdef CONFIG_DEBUG_PAGEALLOC
+			WARN(prev_region_list == NULL,
+				"%s: prev_region_list is NULL\n"
+				"region_id=%d, prev_region_id=%d\n", __func__,
+				 region_id, prev_region_id);
+#endif
+			goto out;
 		}
 	}
 
@@ -562,6 +687,7 @@ out:
 
 	/* Save pointer to page block of this region */
 	region->page_block = lru;
+	set_region_bit(region_id, free_list);
 }
 
 /**
@@ -576,6 +702,7 @@ static void rmqueue_del_from_freelist(struct page *page,
 				      struct free_list *free_list)
 {
 	struct list_head *lru = &page->lru;
+	int region_id;
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 	WARN((free_list->list.next != lru),
@@ -599,6 +726,8 @@ static void rmqueue_del_from_freelist(struct page *page,
 	 * in this freelist.
 	 */
 	free_list->next_region->page_block = NULL;
+	region_id = free_list->next_region - free_list->mr_list;
+	clear_region_bit(region_id, free_list);
 
 	/* Set 'next_region' to the new first region in the freelist. */
 	set_next_region_in_freelist(free_list);
@@ -659,6 +788,7 @@ page_found:
 
 	if (region->nr_free == 0) {
 		region->page_block = NULL;
+		clear_region_bit(region_id, free_list);
 	} else {
 		region->page_block = prev_page_lru;
 #ifdef CONFIG_DEBUG_PAGEALLOC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
