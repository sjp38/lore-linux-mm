Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC4346B0318
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 22:12:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so129258199pgc.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:12:28 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 23si29455179pgb.38.2016.11.15.19.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 19:12:28 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v5 3/9] mm, THP, swap: Add swap cluster allocate/free functions
Date: Wed, 16 Nov 2016 11:10:51 +0800
Message-Id: <20161116031057.12977-4-ying.huang@intel.com>
In-Reply-To: <20161116031057.12977-1-ying.huang@intel.com>
References: <20161116031057.12977-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

The swap cluster allocation/free functions are added based on the
existing swap cluster management mechanism for SSD.  These functions
don't work for the rotating hard disks because the existing swap cluster
management mechanism doesn't work for them.  The hard disks support may
be added if someone really need it.  But that needn't be included in
this patchset.

This will be used for the THP (Transparent Huge Page) swap support.
Where one swap cluster will hold the contents of each THP swapped out.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swapfile.c | 203 +++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 146 insertions(+), 57 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index fe0a559..15c89f8 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -326,6 +326,14 @@ static void swap_cluster_schedule_discard(struct swap_info_struct *si,
 	schedule_work(&si->discard_work);
 }
 
+static void __free_cluster(struct swap_info_struct *si, unsigned long idx)
+{
+	struct swap_cluster_info *ci = si->cluster_info;
+
+	cluster_set_flag(ci + idx, CLUSTER_FLAG_FREE);
+	cluster_list_add_tail(&si->free_clusters, ci, idx);
+}
+
 /*
  * Doing discard actually. After a cluster discard is finished, the cluster
  * will be added to free cluster list. caller should hold si->lock.
@@ -345,8 +353,7 @@ static void swap_do_scheduled_discard(struct swap_info_struct *si)
 				SWAPFILE_CLUSTER);
 
 		spin_lock(&si->lock);
-		cluster_set_flag(&info[idx], CLUSTER_FLAG_FREE);
-		cluster_list_add_tail(&si->free_clusters, info, idx);
+		__free_cluster(si, idx);
 		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
 				0, SWAPFILE_CLUSTER);
 	}
@@ -363,6 +370,34 @@ static void swap_discard_work(struct work_struct *work)
 	spin_unlock(&si->lock);
 }
 
+static void alloc_cluster(struct swap_info_struct *si, unsigned long idx)
+{
+	struct swap_cluster_info *ci = si->cluster_info;
+
+	VM_BUG_ON(cluster_list_first(&si->free_clusters) != idx);
+	cluster_list_del_first(&si->free_clusters, ci);
+	cluster_set_count_flag(ci + idx, 0, 0);
+}
+
+static void free_cluster(struct swap_info_struct *si, unsigned long idx)
+{
+	struct swap_cluster_info *ci = si->cluster_info + idx;
+
+	VM_BUG_ON(cluster_count(ci) != 0);
+	/*
+	 * If the swap is discardable, prepare discard the cluster
+	 * instead of free it immediately. The cluster will be freed
+	 * after discard.
+	 */
+	if ((si->flags & (SWP_WRITEOK | SWP_PAGE_DISCARD)) ==
+	    (SWP_WRITEOK | SWP_PAGE_DISCARD)) {
+		swap_cluster_schedule_discard(si, idx);
+		return;
+	}
+
+	__free_cluster(si, idx);
+}
+
 /*
  * The cluster corresponding to page_nr will be used. The cluster will be
  * removed from free cluster list and its usage counter will be increased.
@@ -374,11 +409,8 @@ static void inc_cluster_info_page(struct swap_info_struct *p,
 
 	if (!cluster_info)
 		return;
-	if (cluster_is_free(&cluster_info[idx])) {
-		VM_BUG_ON(cluster_list_first(&p->free_clusters) != idx);
-		cluster_list_del_first(&p->free_clusters, cluster_info);
-		cluster_set_count_flag(&cluster_info[idx], 0, 0);
-	}
+	if (cluster_is_free(&cluster_info[idx]))
+		alloc_cluster(p, idx);
 
 	VM_BUG_ON(cluster_count(&cluster_info[idx]) >= SWAPFILE_CLUSTER);
 	cluster_set_count(&cluster_info[idx],
@@ -402,21 +434,8 @@ static void dec_cluster_info_page(struct swap_info_struct *p,
 	cluster_set_count(&cluster_info[idx],
 		cluster_count(&cluster_info[idx]) - 1);
 
-	if (cluster_count(&cluster_info[idx]) == 0) {
-		/*
-		 * If the swap is discardable, prepare discard the cluster
-		 * instead of free it immediately. The cluster will be freed
-		 * after discard.
-		 */
-		if ((p->flags & (SWP_WRITEOK | SWP_PAGE_DISCARD)) ==
-				 (SWP_WRITEOK | SWP_PAGE_DISCARD)) {
-			swap_cluster_schedule_discard(p, idx);
-			return;
-		}
-
-		cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
-		cluster_list_add_tail(&p->free_clusters, cluster_info, idx);
-	}
+	if (cluster_count(&cluster_info[idx]) == 0)
+		free_cluster(p, idx);
 }
 
 /*
@@ -497,6 +516,69 @@ static void scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
 	*scan_base = tmp;
 }
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+static inline unsigned int huge_cluster_nr_entries(bool huge)
+{
+	return huge ? SWAPFILE_CLUSTER : 1;
+}
+#else
+#define huge_cluster_nr_entries(huge)	1
+#endif
+
+static void __swap_entry_alloc(struct swap_info_struct *si,
+			       unsigned long offset, bool huge)
+{
+	unsigned int nr_entries = huge_cluster_nr_entries(huge);
+	unsigned int end = offset + nr_entries - 1;
+
+	if (offset == si->lowest_bit)
+		si->lowest_bit += nr_entries;
+	if (end == si->highest_bit)
+		si->highest_bit -= nr_entries;
+	si->inuse_pages += nr_entries;
+	if (si->inuse_pages == si->pages) {
+		si->lowest_bit = si->max;
+		si->highest_bit = 0;
+		spin_lock(&swap_avail_lock);
+		plist_del(&si->avail_list, &swap_avail_head);
+		spin_unlock(&swap_avail_lock);
+	}
+}
+
+static void __swap_entry_free(struct swap_info_struct *si, unsigned long offset,
+			      bool huge)
+{
+	unsigned int nr_entries = huge_cluster_nr_entries(huge);
+	unsigned long end = offset + nr_entries - 1;
+	void (*swap_slot_free_notify)(struct block_device *, unsigned long);
+
+	if (offset < si->lowest_bit)
+		si->lowest_bit = offset;
+	if (end > si->highest_bit) {
+		bool was_full = !si->highest_bit;
+
+		si->highest_bit = end;
+		if (was_full && (si->flags & SWP_WRITEOK)) {
+			spin_lock(&swap_avail_lock);
+			WARN_ON(!plist_node_empty(&si->avail_list));
+			if (plist_node_empty(&si->avail_list))
+				plist_add(&si->avail_list, &swap_avail_head);
+			spin_unlock(&swap_avail_lock);
+		}
+	}
+	atomic_long_add(nr_entries, &nr_swap_pages);
+	si->inuse_pages -= nr_entries;
+	if (si->flags & SWP_BLKDEV)
+		swap_slot_free_notify =
+			si->bdev->bd_disk->fops->swap_slot_free_notify;
+	while (offset <= end) {
+		frontswap_invalidate_page(si->type, offset);
+		if (swap_slot_free_notify)
+			swap_slot_free_notify(si->bdev, offset);
+		offset++;
+	}
+}
+
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -591,18 +673,7 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 	if (si->swap_map[offset])
 		goto scan;
 
-	if (offset == si->lowest_bit)
-		si->lowest_bit++;
-	if (offset == si->highest_bit)
-		si->highest_bit--;
-	si->inuse_pages++;
-	if (si->inuse_pages == si->pages) {
-		si->lowest_bit = si->max;
-		si->highest_bit = 0;
-		spin_lock(&swap_avail_lock);
-		plist_del(&si->avail_list, &swap_avail_head);
-		spin_unlock(&swap_avail_lock);
-	}
+	__swap_entry_alloc(si, offset, false);
 	si->swap_map[offset] = usage;
 	inc_cluster_info_page(si, si->cluster_info, offset);
 	si->cluster_next = offset + 1;
@@ -649,6 +720,46 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 	return 0;
 }
 
+#ifdef CONFIG_THP_SWAP_CLUSTER
+static void swap_free_huge_cluster(struct swap_info_struct *si,
+				   unsigned long idx)
+{
+	struct swap_cluster_info *ci = si->cluster_info + idx;
+	unsigned long offset = idx * SWAPFILE_CLUSTER;
+
+	cluster_set_count_flag(ci, 0, 0);
+	free_cluster(si, idx);
+	__swap_entry_free(si, offset, true);
+}
+
+static unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
+{
+	unsigned long idx;
+	struct swap_cluster_info *ci;
+	unsigned long offset, i;
+	unsigned char *map;
+
+	if (cluster_list_empty(&si->free_clusters))
+		return 0;
+	idx = cluster_list_first(&si->free_clusters);
+	alloc_cluster(si, idx);
+	ci = si->cluster_info + idx;
+	cluster_set_count_flag(ci, SWAPFILE_CLUSTER, 0);
+
+	offset = idx * SWAPFILE_CLUSTER;
+	__swap_entry_alloc(si, offset, true);
+	map = si->swap_map + offset;
+	for (i = 0; i < SWAPFILE_CLUSTER; i++)
+		map[i] = SWAP_HAS_CACHE;
+	return offset;
+}
+#else
+static inline unsigned long swap_alloc_huge_cluster(struct swap_info_struct *si)
+{
+	return 0;
+}
+#endif
+
 swp_entry_t get_swap_page(void)
 {
 	struct swap_info_struct *si, *next;
@@ -808,29 +919,7 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 	if (!usage) {
 		mem_cgroup_uncharge_swap(entry, 1);
 		dec_cluster_info_page(p, p->cluster_info, offset);
-		if (offset < p->lowest_bit)
-			p->lowest_bit = offset;
-		if (offset > p->highest_bit) {
-			bool was_full = !p->highest_bit;
-			p->highest_bit = offset;
-			if (was_full && (p->flags & SWP_WRITEOK)) {
-				spin_lock(&swap_avail_lock);
-				WARN_ON(!plist_node_empty(&p->avail_list));
-				if (plist_node_empty(&p->avail_list))
-					plist_add(&p->avail_list,
-						  &swap_avail_head);
-				spin_unlock(&swap_avail_lock);
-			}
-		}
-		atomic_long_inc(&nr_swap_pages);
-		p->inuse_pages--;
-		frontswap_invalidate_page(p->type, offset);
-		if (p->flags & SWP_BLKDEV) {
-			struct gendisk *disk = p->bdev->bd_disk;
-			if (disk->fops->swap_slot_free_notify)
-				disk->fops->swap_slot_free_notify(p->bdev,
-								  offset);
-		}
+		__swap_entry_free(p, offset, false);
 	}
 
 	return usage;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
