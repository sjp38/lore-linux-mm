Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 6A0EF6B0075
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 07:04:56 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id v19so10620777obq.35
        for <linux-mm@kvack.org>; Mon, 24 Jun 2013 04:04:55 -0700 (PDT)
Date: Mon, 24 Jun 2013 19:04:44 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 4/4 v5]swap: make cluster allocation per-cpu
Message-ID: <20130624110444.GD15796@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com


swap cluster allocation is to get better request merge to improve performance.
But the cluster is shared globally, if multiple tasks are doing swap, this will
cause interleave disk access. While multiple tasks swap is quite common, for
example, each numa node has a kswapd thread doing swap or multiple
threads/processes do direct page reclaim.

We makes the cluster allocation per-cpu here. The interleave disk access issue
goes away. All tasks will do sequential swap.

If one CPU can't get its per-cpu cluster (for example, there is no free cluster
anymore in the swap), it will fallback to scan swap_map.  The CPU can still
continue swap. We don't need recycle free swap entries of other CPUs.

In my test (swap to a 2-disk raid0 partition), this improves around 10%
swapout throughput, and request size is increased significantly.

How does this impact swap readahead is uncertain though. On one side, page
reclaim always isolates and swaps several adjancent pages, this will make page
reclaim write the pages sequentially and benefit readahead. On the other side,
several CPU write pages interleave means the pages don't live _sequentially_
but relatively _near_. In the per-cpu allocation case, if adjancent pages are
written by different cpus, they will live relatively _far_.  So how this
impacts swap readahead depends on how many pages page reclaim isolates and
swaps one time. If the number is big, this patch will benefit swap readahead.
Of course, this is about sequential access pattern. The patch has no impact for
random access pattern, because the new cluster allocation algorithm is just for
SSD.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/swap.h |    6 ++
 mm/swapfile.c        |  116 ++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 93 insertions(+), 29 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2013-06-20 08:07:50.000000000 +0800
+++ linux/include/linux/swap.h	2013-06-20 08:15:41.825465714 +0800
@@ -186,6 +186,11 @@ struct swap_cluster_info {
 #define CLUSTER_FLAG_FREE 1 /* This cluster is free */
 #define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
 
+struct percpu_cluster {
+	struct swap_cluster_info index; /* Current cluster index */
+	unsigned int next; /* Likely next allocation offset */
+};
+
 /*
  * The in-memory structure used to track swap areas.
  */
@@ -205,6 +210,7 @@ struct swap_info_struct {
 	unsigned int inuse_pages;	/* number of those currently in use */
 	unsigned int cluster_next;	/* likely index for next allocation */
 	unsigned int cluster_nr;	/* countdown to next cluster search */
+	struct percpu_cluster __percpu *percpu_cluster;
 	struct swap_extent *curr_swap_extent;
 	struct swap_extent first_swap_extent;
 	struct block_device *bdev;	/* swap device or bdev of swap file */
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2013-06-20 08:14:40.000000000 +0800
+++ linux/mm/swapfile.c	2013-06-20 08:15:41.825465714 +0800
@@ -379,13 +379,73 @@ static void dec_cluster_info_page(struct
  * It's possible scan_swap_map() uses a free cluster in the middle of free
  * cluster list. Avoiding such abuse to avoid list corruption.
  */
-static inline bool scan_swap_map_recheck_cluster(struct swap_info_struct *si,
+static bool
+scan_swap_map_ssd_cluster_conflict(struct swap_info_struct *si,
 	unsigned long offset)
 {
+	struct percpu_cluster *percpu_cluster;
+	bool conflict;
+
 	offset /= SWAPFILE_CLUSTER;
-	return !cluster_is_null(&si->free_cluster_head) &&
+	conflict = !cluster_is_null(&si->free_cluster_head) &&
 		offset != cluster_next(&si->free_cluster_head) &&
 		cluster_is_free(&si->cluster_info[offset]);
+
+	if (!conflict)
+		return false;
+
+	percpu_cluster = this_cpu_ptr(si->percpu_cluster);
+	cluster_set_null(&percpu_cluster->index);
+	return true;
+}
+
+static void scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
+	unsigned long *offset, unsigned long *scan_base)
+{
+	struct percpu_cluster *cluster;
+	bool found_free;
+	unsigned long tmp;
+
+new_cluster:
+	cluster = this_cpu_ptr(si->percpu_cluster);
+	if (cluster_is_null(&cluster->index)) {
+		if (!cluster_is_null(&si->free_cluster_head)) {
+			cluster->index = si->free_cluster_head;
+			cluster->next = cluster_next(&cluster->index) *
+					SWAPFILE_CLUSTER;
+		} else if (!cluster_is_null(&si->discard_cluster_head)) {
+			/*
+			 * we don't have free cluster but have some clusters in
+			 * discarding, do discard now and reclaim them
+			 */
+			swap_do_scheduled_discard(si);
+			goto new_cluster;
+		} else
+			return;
+	}
+
+	found_free = false;
+
+	/*
+	 * Other CPUs can use our cluster if they can't find a free cluster,
+	 * check if there is still free entry in the cluster
+	 */
+	tmp = cluster->next;
+	while (tmp < si->max && tmp < (cluster_next(&cluster->index) + 1) *
+	       SWAPFILE_CLUSTER) {
+		if (!si->swap_map[tmp]) {
+			found_free = true;
+			break;
+		}
+		tmp++;
+	}
+	if (!found_free) {
+		cluster_set_null(&cluster->index);
+		goto new_cluster;
+	}
+	cluster->next = tmp + 1;
+	*offset = tmp;
+	*scan_base = tmp;
 }
 
 static unsigned long scan_swap_map(struct swap_info_struct *si,
@@ -410,36 +470,17 @@ static unsigned long scan_swap_map(struc
 	si->flags += SWP_SCANNING;
 	scan_base = offset = si->cluster_next;
 
+	/* SSD algorithm */
+	if (si->cluster_info) {
+		scan_swap_map_try_ssd_cluster(si, &offset, &scan_base);
+		goto checks;
+	}
+
 	if (unlikely(!si->cluster_nr--)) {
 		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER) {
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto checks;
 		}
-check_cluster:
-		if (!cluster_is_null(&si->free_cluster_head)) {
-			offset = cluster_next(&si->free_cluster_head) *
-						SWAPFILE_CLUSTER;
-			last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
-			si->cluster_next = offset;
-			si->cluster_nr = SWAPFILE_CLUSTER - 1;
-			goto checks;
-		} else if (si->cluster_info) {
-			/*
-			 * we don't have free cluster but have some clusters in
-			 * discarding, do discard now and reclaim them
-			 */
-			if (!cluster_is_null(&si->discard_cluster_head)) {
-				swap_do_scheduled_discard(si);
-				goto check_cluster;
-			}
-
-			/*
-			 * Checking free cluster is fast enough, we can do the
-			 * check every time
-			 */
-			si->cluster_nr = 0;
-			goto checks;
-		}
 
 		spin_unlock(&si->lock);
 
@@ -498,8 +539,11 @@ check_cluster:
 	}
 
 checks:
-	if (scan_swap_map_recheck_cluster(si, offset))
-		goto check_cluster;
+	if (si->cluster_info) {
+		while (scan_swap_map_ssd_cluster_conflict(si, offset)) {
+			scan_swap_map_try_ssd_cluster(si, &offset, &scan_base);
+		}
+	}
 	if (!(si->flags & SWP_WRITEOK))
 		goto no_page;
 	if (!si->highest_bit)
@@ -1840,6 +1884,8 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	spin_unlock(&swap_lock);
 	frontswap_invalidate_area(type);
 	mutex_unlock(&swapon_mutex);
+	free_percpu(p->percpu_cluster);
+	p->percpu_cluster = NULL;
 	vfree(swap_map);
 	vfree(cluster_info);
 	vfree(frontswap_map);
@@ -2340,6 +2386,16 @@ SYSCALL_DEFINE2(swapon, const char __use
 			error = -ENOMEM;
 			goto bad_swap;
 		}
+		p->percpu_cluster = alloc_percpu(struct percpu_cluster);
+		if (!p->percpu_cluster) {
+			error = -ENOMEM;
+			goto bad_swap;
+		}
+		for_each_possible_cpu(i) {
+			struct percpu_cluster *cluster;
+			cluster = per_cpu_ptr(p->percpu_cluster, i);
+			cluster_set_null(&cluster->index);
+		}
 	}
 
 	error = swap_cgroup_swapon(p->type, maxpages);
@@ -2383,6 +2439,8 @@ SYSCALL_DEFINE2(swapon, const char __use
 	error = 0;
 	goto out;
 bad_swap:
+	free_percpu(p->percpu_cluster);
+	p->percpu_cluster = NULL;
 	if (inode && S_ISBLK(inode->i_mode) && p->bdev) {
 		set_blocksize(p->bdev, p->old_block_size);
 		blkdev_put(p->bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
