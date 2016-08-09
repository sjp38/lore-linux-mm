Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62BCB6B025E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:38:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so33116125pfg.1
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:38:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id r71si1655316pfb.169.2016.08.09.09.38.11
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 09:38:12 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [RFC 01/11] swap: Add swap_cluster_list
Date: Tue,  9 Aug 2016 09:37:43 -0700
Message-Id: <1470760673-12420-2-git-send-email-ying.huang@intel.com>
In-Reply-To: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

This is a code clean up patch without functionality changes.  The
swap_cluster_list data structure and its operations is introduced to
provide some better encapsulation for free cluster and discard cluster
list operations.  This avoid some code duplication, improved the code
readability, and reduced the total line number.

Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |  11 +++--
 mm/swapfile.c        | 132 ++++++++++++++++++++++++---------------------------
 2 files changed, 69 insertions(+), 74 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index b17cc48..ed41bec 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -191,6 +191,11 @@ struct percpu_cluster {
 	unsigned int next; /* Likely next allocation offset */
 };
 
+struct swap_cluster_list {
+	struct swap_cluster_info head;
+	struct swap_cluster_info tail;
+};
+
 /*
  * The in-memory structure used to track swap areas.
  */
@@ -203,8 +208,7 @@ struct swap_info_struct {
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
 	struct swap_cluster_info *cluster_info; /* cluster info. Only for SSD */
-	struct swap_cluster_info free_cluster_head; /* free cluster list head */
-	struct swap_cluster_info free_cluster_tail; /* free cluster list tail */
+	struct swap_cluster_list free_clusters; /* free clusters list */
 	unsigned int lowest_bit;	/* index of first free in swap_map */
 	unsigned int highest_bit;	/* index of last free in swap_map */
 	unsigned int pages;		/* total of usable pages of swap */
@@ -235,8 +239,7 @@ struct swap_info_struct {
 					 * first.
 					 */
 	struct work_struct discard_work; /* discard worker */
-	struct swap_cluster_info discard_cluster_head; /* list head of discard clusters */
-	struct swap_cluster_info discard_cluster_tail; /* list tail of discard clusters */
+	struct swap_cluster_list discard_clusters; /* discard clusters list */
 };
 
 /* linux/mm/workingset.c */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 78cfa29..09e3877 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -257,6 +257,53 @@ static inline void cluster_set_null(struct swap_cluster_info *info)
 	info->data = 0;
 }
 
+static inline bool cluster_list_empty(struct swap_cluster_list *list)
+{
+	return cluster_is_null(&list->head);
+}
+
+static inline unsigned int cluster_list_first(struct swap_cluster_list *list)
+{
+	return cluster_next(&list->head);
+}
+
+static void cluster_list_init(struct swap_cluster_list *list)
+{
+	cluster_set_null(&list->head);
+	cluster_set_null(&list->tail);
+}
+
+static void cluster_list_add_tail(struct swap_cluster_list *list,
+				  struct swap_cluster_info *ci,
+				  unsigned int idx)
+{
+	if (cluster_list_empty(list)) {
+		cluster_set_next_flag(&list->head, idx, 0);
+		cluster_set_next_flag(&list->tail, idx, 0);
+	} else {
+		unsigned int tail = cluster_next(&list->tail);
+
+		cluster_set_next(&ci[tail], idx);
+		cluster_set_next_flag(&list->tail, idx, 0);
+	}
+}
+
+static unsigned int cluster_list_del_first(struct swap_cluster_list *list,
+					   struct swap_cluster_info *ci)
+{
+	unsigned int idx;
+
+	idx = cluster_next(&list->head);
+	if (cluster_next(&list->tail) == idx) {
+		cluster_set_null(&list->head);
+		cluster_set_null(&list->tail);
+	} else
+		cluster_set_next_flag(&list->head,
+				      cluster_next(&ci[idx]), 0);
+
+	return idx;
+}
+
 /* Add a cluster to discard list and schedule it to do discard */
 static void swap_cluster_schedule_discard(struct swap_info_struct *si,
 		unsigned int idx)
@@ -270,17 +317,7 @@ static void swap_cluster_schedule_discard(struct swap_info_struct *si,
 	memset(si->swap_map + idx * SWAPFILE_CLUSTER,
 			SWAP_MAP_BAD, SWAPFILE_CLUSTER);
 
-	if (cluster_is_null(&si->discard_cluster_head)) {
-		cluster_set_next_flag(&si->discard_cluster_head,
-						idx, 0);
-		cluster_set_next_flag(&si->discard_cluster_tail,
-						idx, 0);
-	} else {
-		unsigned int tail = cluster_next(&si->discard_cluster_tail);
-		cluster_set_next(&si->cluster_info[tail], idx);
-		cluster_set_next_flag(&si->discard_cluster_tail,
-						idx, 0);
-	}
+	cluster_list_add_tail(&si->discard_clusters, si->cluster_info, idx);
 
 	schedule_work(&si->discard_work);
 }
@@ -296,15 +333,8 @@ static void swap_do_scheduled_discard(struct swap_info_struct *si)
 
 	info = si->cluster_info;
 
-	while (!cluster_is_null(&si->discard_cluster_head)) {
-		idx = cluster_next(&si->discard_cluster_head);
-
-		cluster_set_next_flag(&si->discard_cluster_head,
-						cluster_next(&info[idx]), 0);
-		if (cluster_next(&si->discard_cluster_tail) == idx) {
-			cluster_set_null(&si->discard_cluster_head);
-			cluster_set_null(&si->discard_cluster_tail);
-		}
+	while (!cluster_list_empty(&si->discard_clusters)) {
+		idx = cluster_list_del_first(&si->discard_clusters, info);
 		spin_unlock(&si->lock);
 
 		discard_swap_cluster(si, idx * SWAPFILE_CLUSTER,
@@ -312,19 +342,7 @@ static void swap_do_scheduled_discard(struct swap_info_struct *si)
 
 		spin_lock(&si->lock);
 		cluster_set_flag(&info[idx], CLUSTER_FLAG_FREE);
-		if (cluster_is_null(&si->free_cluster_head)) {
-			cluster_set_next_flag(&si->free_cluster_head,
-						idx, 0);
-			cluster_set_next_flag(&si->free_cluster_tail,
-						idx, 0);
-		} else {
-			unsigned int tail;
-
-			tail = cluster_next(&si->free_cluster_tail);
-			cluster_set_next(&info[tail], idx);
-			cluster_set_next_flag(&si->free_cluster_tail,
-						idx, 0);
-		}
+		cluster_list_add_tail(&si->free_clusters, info, idx);
 		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
 				0, SWAPFILE_CLUSTER);
 	}
@@ -353,13 +371,8 @@ static void inc_cluster_info_page(struct swap_info_struct *p,
 	if (!cluster_info)
 		return;
 	if (cluster_is_free(&cluster_info[idx])) {
-		VM_BUG_ON(cluster_next(&p->free_cluster_head) != idx);
-		cluster_set_next_flag(&p->free_cluster_head,
-			cluster_next(&cluster_info[idx]), 0);
-		if (cluster_next(&p->free_cluster_tail) == idx) {
-			cluster_set_null(&p->free_cluster_tail);
-			cluster_set_null(&p->free_cluster_head);
-		}
+		VM_BUG_ON(cluster_list_first(&p->free_clusters) != idx);
+		cluster_list_del_first(&p->free_clusters, cluster_info);
 		cluster_set_count_flag(&cluster_info[idx], 0, 0);
 	}
 
@@ -398,14 +411,7 @@ static void dec_cluster_info_page(struct swap_info_struct *p,
 		}
 
 		cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
-		if (cluster_is_null(&p->free_cluster_head)) {
-			cluster_set_next_flag(&p->free_cluster_head, idx, 0);
-			cluster_set_next_flag(&p->free_cluster_tail, idx, 0);
-		} else {
-			unsigned int tail = cluster_next(&p->free_cluster_tail);
-			cluster_set_next(&cluster_info[tail], idx);
-			cluster_set_next_flag(&p->free_cluster_tail, idx, 0);
-		}
+		cluster_list_add_tail(&p->free_clusters, cluster_info, idx);
 	}
 }
 
@@ -421,8 +427,8 @@ scan_swap_map_ssd_cluster_conflict(struct swap_info_struct *si,
 	bool conflict;
 
 	offset /= SWAPFILE_CLUSTER;
-	conflict = !cluster_is_null(&si->free_cluster_head) &&
-		offset != cluster_next(&si->free_cluster_head) &&
+	conflict = !cluster_list_empty(&si->free_clusters) &&
+		offset != cluster_list_first(&si->free_clusters) &&
 		cluster_is_free(&si->cluster_info[offset]);
 
 	if (!conflict)
@@ -447,11 +453,11 @@ static void scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
 new_cluster:
 	cluster = this_cpu_ptr(si->percpu_cluster);
 	if (cluster_is_null(&cluster->index)) {
-		if (!cluster_is_null(&si->free_cluster_head)) {
-			cluster->index = si->free_cluster_head;
+		if (!cluster_list_empty(&si->free_clusters)) {
+			cluster->index = si->free_clusters.head;
 			cluster->next = cluster_next(&cluster->index) *
 					SWAPFILE_CLUSTER;
-		} else if (!cluster_is_null(&si->discard_cluster_head)) {
+		} else if (!cluster_list_empty(&si->discard_clusters)) {
 			/*
 			 * we don't have free cluster but have some clusters in
 			 * discarding, do discard now and reclaim them
@@ -2292,10 +2298,8 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 
 	nr_good_pages = maxpages - 1;	/* omit header page */
 
-	cluster_set_null(&p->free_cluster_head);
-	cluster_set_null(&p->free_cluster_tail);
-	cluster_set_null(&p->discard_cluster_head);
-	cluster_set_null(&p->discard_cluster_tail);
+	cluster_list_init(&p->free_clusters);
+	cluster_list_init(&p->discard_clusters);
 
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
 		unsigned int page_nr = swap_header->info.badpages[i];
@@ -2341,19 +2345,7 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 	for (i = 0; i < nr_clusters; i++) {
 		if (!cluster_count(&cluster_info[idx])) {
 			cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
-			if (cluster_is_null(&p->free_cluster_head)) {
-				cluster_set_next_flag(&p->free_cluster_head,
-								idx, 0);
-				cluster_set_next_flag(&p->free_cluster_tail,
-								idx, 0);
-			} else {
-				unsigned int tail;
-
-				tail = cluster_next(&p->free_cluster_tail);
-				cluster_set_next(&cluster_info[tail], idx);
-				cluster_set_next_flag(&p->free_cluster_tail,
-								idx, 0);
-			}
+			cluster_list_add_tail(&p->free_clusters, cluster_info, idx);
 		}
 		idx++;
 		if (idx == nr_clusters)
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
