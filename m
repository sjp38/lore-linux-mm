Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 2F3A06B0033
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 06:07:20 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id 10so6656471pdc.19
        for <linux-mm@kvack.org>; Mon, 22 Jul 2013 03:07:19 -0700 (PDT)
Date: Mon, 22 Jul 2013 18:06:54 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 4/4 v6]swap: make cluster allocation per-cpu
Message-ID: <20130722100654.GD17386@kernel.org>
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
example, each numa node has a kswapd thread doing swap and multiple
threads/processes doing direct page reclaim.

ioscheduler can't help too much here, because tasks don't send swapout IO down
to block layer in the meantime. Block layer does merge some IOs, but a lot not,
depending on how many tasks are doing swapout concurrently. In practice, I've
seen a lot of small size IO in swapout workloads.

We makes the cluster allocation per-cpu here. The interleave disk access issue
goes away. All tasks swapout to their own cluster, so swapout will become
sequential, which can be easily merged to big size IO. If one CPU can't get its
per-cpu cluster (for example, there is no free cluster anymore in the swap), it
will fallback to scan swap_map. The CPU can still continue swap. We don't need
recycle free swap entries of other CPUs.

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

Alternative solution is organizing swap layout to be per-mm instead of this
per-cpu approach. In the per-mm layout, we allocate a disk range for each mm,
so pages of one mm live in swap disk adjacently. per-mm layout has potential
issues of lock contention if multiple reclaimers are swap pages from one mm.
For a sequential workload, per-mm layout is better to implement swap readahead,
because pages from the mm are adjacent in disk. But per-cpu layout isn't very
bad in this workload, as page reclaim always isolates and swaps several pages
one time, such pages will still live in disk sequentially and readahead can
utilize this. For a random workload, per-mm layout isn't beneficial of request
merge, because it's quite possible pages from different mm are swapout in the
meantime and IO can't be merged in per-mm layout. while with per-cpu layout we
can merge requests from any mm. Considering random workload is more popular in
workloads with swap (and per-cpu approach isn't too bad for sequential workload
too), I'm choosing per-cpu layout.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/swap.h |   11 ++++
 mm/swapfile.c        |  126 +++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 103 insertions(+), 34 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2013-07-22 09:42:07.287148443 +0800
+++ linux/include/linux/swap.h	2013-07-22 10:11:13.097202127 +0800
@@ -199,6 +199,16 @@ struct swap_cluster_info {
 #define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
 
 /*
+ * We assign a cluster to each CPU, so each CPU can allocate swap entry from
+ * its own cluster and swapout sequentially. The purpose is to optimize swapout
+ * throughput.
+ */
+struct percpu_cluster {
+	struct swap_cluster_info index; /* Current cluster index */
+	unsigned int next; /* Likely next allocation offset */
+};
+
+/*
  * The in-memory structure used to track swap areas.
  */
 struct swap_info_struct {
@@ -217,6 +227,7 @@ struct swap_info_struct {
 	unsigned int inuse_pages;	/* number of those currently in use */
 	unsigned int cluster_next;	/* likely index for next allocation */
 	unsigned int cluster_nr;	/* countdown to next cluster search */
+	struct percpu_cluster __percpu *percpu_cluster; /* per cpu's swap location */
 	struct swap_extent *curr_swap_extent;
 	struct swap_extent first_swap_extent;
 	struct block_device *bdev;	/* swap device or bdev of swap file */
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2013-07-22 10:07:27.484038790 +0800
+++ linux/mm/swapfile.c	2013-07-22 10:21:24.961508367 +0800
@@ -392,13 +392,78 @@ static void dec_cluster_info_page(struct
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
+/*
+ * Try to get a swap entry from current cpu's swap entry pool (a cluster). This
+ * might involve allocating a new cluster for current CPU too.
+ */
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
+			*scan_base = *offset = si->cluster_next;
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
@@ -423,41 +488,17 @@ static unsigned long scan_swap_map(struc
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
-				si->cluster_nr = 0;
-				swap_do_scheduled_discard(si);
-				scan_base = offset = si->cluster_next;
-				if (!si->cluster_nr)
-					goto check_cluster;
-				si->cluster_nr --;
-				goto checks;
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
 
@@ -516,8 +557,11 @@ check_cluster:
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
@@ -1869,6 +1913,8 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	spin_unlock(&swap_lock);
 	frontswap_invalidate_area(type);
 	mutex_unlock(&swapon_mutex);
+	free_percpu(p->percpu_cluster);
+	p->percpu_cluster = NULL;
 	vfree(swap_map);
 	vfree(cluster_info);
 	vfree(frontswap_map);
@@ -2388,6 +2434,16 @@ SYSCALL_DEFINE2(swapon, const char __use
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
@@ -2460,6 +2516,8 @@ SYSCALL_DEFINE2(swapon, const char __use
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
