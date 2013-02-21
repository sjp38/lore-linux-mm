Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 41CFE6B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 21:19:09 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fb11so4447061pad.28
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 18:19:08 -0800 (PST)
Date: Thu, 21 Feb 2013 10:18:58 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 4/4 v3]swap: make cluster allocation per-cpu
Message-ID: <20130221021858.GD32580@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org

swap cluster allocation is to get better request merge to improve performance.
But the cluster is shared globally, if multiple tasks are doing swap, this will
cause interleave disk access. While multiple tasks swap is quite common, for
example, each numa node has a kswapd thread doing swap or multiple
threads/processes do direct page reclaim.

We makes the cluster allocation per-cpu here. The interleave disk access issue
goes away. All tasks will do sequential swap.

If one CPU can't get its per-cpu cluster, it will fallback to scan swap_map.
The CPU can still continue swap. We don't need recycle free swap entries of
other CPUs.

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
 include/linux/swap.h |    6 +++
 mm/swapfile.c        |   93 ++++++++++++++++++++++++++++++++++++---------------
 2 files changed, 73 insertions(+), 26 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2013-02-19 14:44:08.873688932 +0800
+++ linux/include/linux/swap.h	2013-02-19 14:47:44.414979203 +0800
@@ -175,6 +175,11 @@ enum {
 #define COUNT_CONTINUED	0x80	/* See swap_map continuation for full count */
 #define SWAP_MAP_SHMEM	0xbf	/* Owned by shmem/tmpfs, in first swap_map */
 
+struct percpu_cluster {
+	unsigned int index; /* Current cluster index */
+	unsigned int next; /* Likely next allocation offset */
+};
+
 /*
  * The in-memory structure used to track swap areas.
  */
@@ -194,6 +199,7 @@ struct swap_info_struct {
 	unsigned int inuse_pages;	/* number of those currently in use */
 	unsigned int cluster_next;	/* likely index for next allocation */
 	unsigned int cluster_nr;	/* countdown to next cluster search */
+	struct percpu_cluster __percpu *percpu_cluster;
 	struct swap_extent *curr_swap_extent;
 	struct swap_extent first_swap_extent;
 	struct block_device *bdev;	/* swap device or bdev of swap file */
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2013-02-19 14:45:42.732507754 +0800
+++ linux/mm/swapfile.c	2013-02-19 14:50:21.925000381 +0800
@@ -325,6 +325,51 @@ static inline bool scan_swap_map_recheck
 		cluster_is_free(si->cluster_info[offset]);
 }
 
+static void scan_swap_map_try_cluster(struct swap_info_struct *si,
+	unsigned long *offset)
+{
+	struct percpu_cluster *cluster;
+	bool found_free;
+	unsigned long tmp;
+
+new_cluster:
+	cluster = this_cpu_ptr(si->percpu_cluster);
+	if (cluster->index == CLUSTER_NULL) {
+		if (si->free_cluster_head != CLUSTER_NULL) {
+			cluster->index = si->free_cluster_head;
+			cluster->next = cluster->index * SWAPFILE_CLUSTER;
+		} else if (si->discard_cluster_head != CLUSTER_NULL) {
+			spin_unlock(&si->lock);
+			schedule_work(&si->discard_work);
+			flush_work(&si->discard_work);
+			spin_lock(&si->lock);
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
+	while (tmp < si->max && tmp < (cluster->index + 1) * SWAPFILE_CLUSTER) {
+		if (!si->swap_map[tmp]) {
+			found_free = true;
+			break;
+		}
+		tmp++;
+	}
+	if (!found_free) {
+		cluster->index = CLUSTER_NULL;
+		goto new_cluster;
+	}
+	cluster->next = tmp + 1;
+	*offset = tmp;
+}
+
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -347,36 +392,18 @@ static unsigned long scan_swap_map(struc
 	si->flags += SWP_SCANNING;
 	scan_base = offset = si->cluster_next;
 
+check_cluster:
+	if (si->cluster_info) {
+		scan_swap_map_try_cluster(si, &offset);
+		scan_base = offset;
+		goto checks;
+	}
+
 	if (unlikely(!si->cluster_nr--)) {
 		if (si->pages - si->inuse_pages < SWAPFILE_CLUSTER) {
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto checks;
 		}
-check_cluster:
-		if (si->free_cluster_head != CLUSTER_NULL) {
-			offset = si->free_cluster_head * SWAPFILE_CLUSTER;
-			last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
-			si->cluster_next = offset;
-			si->cluster_nr = SWAPFILE_CLUSTER - 1;
-			goto checks;
-		} else if (si->cluster_info) {
-			if (si->discard_cluster_head != CLUSTER_NULL) {
-				spin_unlock(&si->lock);
-				schedule_work(&si->discard_work);
-				flush_work(&si->discard_work);
-
-				spin_lock(&si->lock);
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
-
 		spin_unlock(&si->lock);
 
 		/*
@@ -434,8 +461,12 @@ check_cluster:
 	}
 
 checks:
-	if (scan_swap_map_recheck_cluster(si, offset))
+	if (scan_swap_map_recheck_cluster(si, offset)) {
+		struct percpu_cluster *percpu_cluster;
+		percpu_cluster = this_cpu_ptr(si->percpu_cluster);
+		percpu_cluster->index = CLUSTER_NULL;
 		goto check_cluster;
+	}
 	if (!(si->flags & SWP_WRITEOK))
 		goto no_page;
 	if (!si->highest_bit)
@@ -1762,6 +1793,8 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
+	free_percpu(p->percpu_cluster);
+	p->percpu_cluster = NULL;
 	vfree(swap_map);
 	vfree(cluster_info);
 	vfree(frontswap_map_get(p));
@@ -2255,6 +2288,12 @@ SYSCALL_DEFINE2(swapon, const char __use
 			error = -ENOMEM;
 			goto bad_swap;
 		}
+		/* It's fine to initialize percpu_cluster to 0 */
+		p->percpu_cluster = alloc_percpu(struct percpu_cluster);
+		if (!p->percpu_cluster) {
+			error = -ENOMEM;
+			goto bad_swap;
+		}
 	}
 
 	error = swap_cgroup_swapon(p->type, maxpages);
@@ -2298,6 +2337,8 @@ SYSCALL_DEFINE2(swapon, const char __use
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
