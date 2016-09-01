Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA6426B0261
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 11:18:21 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j129so62412512qkd.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 08:18:21 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h28si6132403pfk.146.2016.09.01.08.18.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 08:18:08 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v2 04/10] mm, THP, swap: Add swap cluster allocate/free functions
Date: Thu,  1 Sep 2016 08:16:57 -0700
Message-Id: <1472743023-4116-5-git-send-email-ying.huang@intel.com>
In-Reply-To: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
References: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
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
 mm/swapfile.c | 194 +++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 137 insertions(+), 57 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index c70ad52..9f30f46 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -322,6 +322,14 @@ static void swap_cluster_schedule_discard(struct swap_info_struct *si,
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
@@ -341,8 +349,7 @@ static void swap_do_scheduled_discard(struct swap_info_struct *si)
 				SWAPFILE_CLUSTER);
 
 		spin_lock(&si->lock);
-		cluster_set_flag(&info[idx], CLUSTER_FLAG_FREE);
-		cluster_list_add_tail(&si->free_clusters, info, idx);
+		__free_cluster(si, idx);
 		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
 				0, SWAPFILE_CLUSTER);
 	}
@@ -359,6 +366,34 @@ static void swap_discard_work(struct work_struct *work)
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
@@ -370,11 +405,8 @@ static void inc_cluster_info_page(struct swap_info_struct *p,
 
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
@@ -398,21 +430,8 @@ static void dec_cluster_info_page(struct swap_info_struct *p,
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
@@ -493,6 +512,68 @@ new_cluster:
 	*scan_base = tmp;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline unsigned int huge_cluster_nr_entries(bool huge)
+{
+	return huge ? SWAPFILE_CLUSTER : 1;
+}
+#else
+#define huge_cluster_nr_entries(huge)	1
+#endif
+
+static void __swap_entry_alloc(struct swap_info_struct *si, unsigned long offset,
+			       bool huge)
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
+		swap_slot_free_notify = si->bdev->bd_disk->fops->swap_slot_free_notify;
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
@@ -587,18 +668,7 @@ checks:
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
@@ -645,6 +715,38 @@ no_page:
 	return 0;
 }
 
+static void swap_free_huge_cluster(struct swap_info_struct *si, unsigned long idx)
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
+
 swp_entry_t get_swap_page(void)
 {
 	struct swap_info_struct *si, *next;
@@ -804,29 +906,7 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
