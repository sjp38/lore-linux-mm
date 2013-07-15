Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 49DC16B0033
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 16:43:45 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y14so11095025pdi.16
        for <linux-mm@kvack.org>; Mon, 15 Jul 2013 13:43:44 -0700 (PDT)
Date: Tue, 16 Jul 2013 04:43:41 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 2/4 v6]swap: make swap discard async
Message-ID: <20130715204341.GB7925@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

swap can do cluster discard for SSD, which is good, but there are some problems
here:
1. swap do the discard just before page reclaim gets a swap entry and writes
the disk sectors. This is useless for high end SSD, because an overwrite to a
sector implies a discard to original sector too. A discard + overwrite ==
overwrite.
2. the purpose of doing discard is to improve SSD firmware garbage collection.
Idealy we should send discard as early as possible, so firmware can do
something smart. Sending discard just after swap entry is freed is considered
early compared to sending discard before write. Of course, if workload is
already bound to gc speed, sending discard earlier or later doesn't make
difference.
3. block discard is a sync API, which will delay scan_swap_map() significantly.
4. Write and discard command can be executed parallel in PCIe SSD. Making
swap discard async can make execution more efficiently.

This patch makes swap discard async and move discard to where swap entry is
freed. Discard and write have no dependence now, so above issues can be avoided.
Idealy we should do discard for any freed sectors, but some SSD discard is very
slow. This patch still does discard for a whole cluster. 

My test does a several round of 'mmap, write, unmap', which will trigger a lot
of swap discard. In a fusionio card, with this patch, the test runtime is
reduced to 18% of the time without it, so around 5.5x faster.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/swap.h |    5 -
 mm/swapfile.c        |  183 +++++++++++++++++++++++++++++----------------------
 2 files changed, 108 insertions(+), 80 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2013-07-11 19:14:38.657887654 +0800
+++ linux/include/linux/swap.h	2013-07-11 19:14:44.121818963 +0800
@@ -211,8 +211,6 @@ struct swap_info_struct {
 	unsigned int inuse_pages;	/* number of those currently in use */
 	unsigned int cluster_next;	/* likely index for next allocation */
 	unsigned int cluster_nr;	/* countdown to next cluster search */
-	unsigned int lowest_alloc;	/* while preparing discard cluster */
-	unsigned int highest_alloc;	/* while preparing discard cluster */
 	struct swap_extent *curr_swap_extent;
 	struct swap_extent first_swap_extent;
 	struct block_device *bdev;	/* swap device or bdev of swap file */
@@ -234,6 +232,9 @@ struct swap_info_struct {
 					 * swap_lock. If both locks need hold,
 					 * hold swap_lock first.
 					 */
+	struct work_struct discard_work; /* discard worker */
+	struct swap_cluster_info discard_cluster_head; /* list head of discard clusters */
+	struct swap_cluster_info discard_cluster_tail; /* list tail of discard clusters */
 };
 
 struct swap_list_t {
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2013-07-11 19:14:38.657887654 +0800
+++ linux/mm/swapfile.c	2013-07-11 19:14:44.121818963 +0800
@@ -175,12 +175,6 @@ static void discard_swap_cluster(struct
 	}
 }
 
-static int wait_for_discard(void *word)
-{
-	schedule();
-	return 0;
-}
-
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
@@ -242,6 +236,86 @@ static inline void cluster_set_null(stru
 	info->data = 0;
 }
 
+static void swap_cluster_schedule_discard(struct swap_info_struct *si,
+		unsigned int idx)
+{
+	/*
+	 * If scan_swap_map() can't find a free cluster, it will check
+	 * si->swap_map directly. To make sure the discarding cluster isn't
+	 * taken by scan_swap_map(), mark the swap entries bad (occupied). It
+	 * will be cleared after discard
+	 */
+	memset(si->swap_map + idx * SWAPFILE_CLUSTER,
+			SWAP_MAP_BAD, SWAPFILE_CLUSTER);
+
+	if (cluster_is_null(&si->discard_cluster_head)) {
+		cluster_set_next_flag(&si->discard_cluster_head,
+						idx, 0);
+		cluster_set_next_flag(&si->discard_cluster_tail,
+						idx, 0);
+	} else {
+		unsigned int next = cluster_next(&si->discard_cluster_tail);
+		cluster_set_next(&si->cluster_info[next], idx);
+		cluster_set_next_flag(&si->discard_cluster_tail,
+						idx, 0);
+	}
+
+	schedule_work(&si->discard_work);
+}
+
+/* caller should hold si->lock */
+static void swap_do_scheduled_discard(struct swap_info_struct *si)
+{
+	struct swap_cluster_info *info;
+	unsigned int idx;
+
+	info = si->cluster_info;
+
+	while (!cluster_is_null(&si->discard_cluster_head)) {
+		idx = cluster_next(&si->discard_cluster_head);
+
+		cluster_set_next_flag(&si->discard_cluster_head,
+						cluster_next(&info[idx]), 0);
+		if (cluster_next(&si->discard_cluster_tail) == idx) {
+			cluster_set_null(&si->discard_cluster_head);
+			cluster_set_null(&si->discard_cluster_tail);
+		}
+		spin_unlock(&si->lock);
+
+		discard_swap_cluster(si, idx * SWAPFILE_CLUSTER,
+				SWAPFILE_CLUSTER);
+
+		spin_lock(&si->lock);
+		cluster_set_flag(&info[idx], CLUSTER_FLAG_FREE);
+		if (cluster_is_null(&si->free_cluster_head)) {
+			cluster_set_next_flag(&si->free_cluster_head,
+						idx, 0);
+			cluster_set_next_flag(&si->free_cluster_tail,
+						idx, 0);
+		} else {
+			unsigned int next;
+
+			next = cluster_next(&si->free_cluster_tail);
+			cluster_set_next(&info[next], idx);
+			cluster_set_next_flag(&si->free_cluster_tail,
+						idx, 0);
+		}
+		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
+				0, SWAPFILE_CLUSTER);
+	}
+}
+
+static void swap_discard_work(struct work_struct *work)
+{
+	struct swap_info_struct *si;
+
+	si = container_of(work, struct swap_info_struct, discard_work);
+
+	spin_lock(&si->lock);
+	swap_do_scheduled_discard(si);
+	spin_unlock(&si->lock);
+}
+
 static void inc_cluster_info_page(struct swap_info_struct *p,
 	struct swap_cluster_info *cluster_info, unsigned long page_nr)
 {
@@ -278,6 +352,16 @@ static void dec_cluster_info_page(struct
 		cluster_count(&cluster_info[idx]) - 1);
 
 	if (cluster_count(&cluster_info[idx]) == 0) {
+		/*
+		 * If the swap is discardable, prepare discard the cluster
+		 * instead of free it immediately. The cluster will be freed
+		 * after discard.
+		 */
+		if (p->flags & SWP_PAGE_DISCARD) {
+			swap_cluster_schedule_discard(p, idx);
+			return;
+		}
+
 		cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
 		if (cluster_is_null(&p->free_cluster_head)) {
 			cluster_set_next_flag(&p->free_cluster_head, idx, 0);
@@ -310,7 +394,6 @@ static unsigned long scan_swap_map(struc
 	unsigned long scan_base;
 	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
-	int found_free_cluster = 0;
 
 	/*
 	 * We try to cluster swap pages by allocating them sequentially
@@ -331,19 +414,6 @@ static unsigned long scan_swap_map(struc
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto checks;
 		}
-		if (si->flags & SWP_PAGE_DISCARD) {
-			/*
-			 * Start range check on racing allocations, in case
-			 * they overlap the cluster we eventually decide on
-			 * (we scan without swap_lock to allow preemption).
-			 * It's hardly conceivable that cluster_nr could be
-			 * wrapped during our scan, but don't depend on it.
-			 */
-			if (si->lowest_alloc)
-				goto checks;
-			si->lowest_alloc = si->max;
-			si->highest_alloc = 0;
-		}
 check_cluster:
 		if (!cluster_is_null(&si->free_cluster_head)) {
 			offset = cluster_next(&si->free_cluster_head) *
@@ -351,15 +421,22 @@ check_cluster:
 			last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 			si->cluster_next = offset;
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
-			found_free_cluster = 1;
 			goto checks;
 		} else if (si->cluster_info) {
 			/*
+			 * we don't have free cluster but have some clusters in
+			 * discarding, do discard now and reclaim them
+			 */
+			if (!cluster_is_null(&si->discard_cluster_head)) {
+				swap_do_scheduled_discard(si);
+				goto check_cluster;
+			}
+
+			/*
 			 * Checking free cluster is fast enough, we can do the
 			 * check every time
 			 */
 			si->cluster_nr = 0;
-			si->lowest_alloc = 0;
 			goto checks;
 		}
 
@@ -386,7 +463,6 @@ check_cluster:
 				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
-				found_free_cluster = 1;
 				goto checks;
 			}
 			if (unlikely(--latency_ration < 0)) {
@@ -407,7 +483,6 @@ check_cluster:
 				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
-				found_free_cluster = 1;
 				goto checks;
 			}
 			if (unlikely(--latency_ration < 0)) {
@@ -419,7 +494,6 @@ check_cluster:
 		offset = scan_base;
 		spin_lock(&si->lock);
 		si->cluster_nr = SWAPFILE_CLUSTER - 1;
-		si->lowest_alloc = 0;
 	}
 
 checks:
@@ -461,59 +535,6 @@ checks:
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
-	if (si->lowest_alloc) {
-		/*
-		 * Only set when SWP_PAGE_DISCARD, and there's a scan
-		 * for a free cluster in progress or just completed.
-		 */
-		if (found_free_cluster) {
-			/*
-			 * To optimize wear-levelling, discard the
-			 * old data of the cluster, taking care not to
-			 * discard any of its pages that have already
-			 * been allocated by racing tasks (offset has
-			 * already stepped over any at the beginning).
-			 */
-			if (offset < si->highest_alloc &&
-			    si->lowest_alloc <= last_in_cluster)
-				last_in_cluster = si->lowest_alloc - 1;
-			si->flags |= SWP_DISCARDING;
-			spin_unlock(&si->lock);
-
-			if (offset < last_in_cluster)
-				discard_swap_cluster(si, offset,
-					last_in_cluster - offset + 1);
-
-			spin_lock(&si->lock);
-			si->lowest_alloc = 0;
-			si->flags &= ~SWP_DISCARDING;
-
-			smp_mb();	/* wake_up_bit advises this */
-			wake_up_bit(&si->flags, ilog2(SWP_DISCARDING));
-
-		} else if (si->flags & SWP_DISCARDING) {
-			/*
-			 * Delay using pages allocated by racing tasks
-			 * until the whole discard has been issued. We
-			 * could defer that delay until swap_writepage,
-			 * but it's easier to keep this self-contained.
-			 */
-			spin_unlock(&si->lock);
-			wait_on_bit(&si->flags, ilog2(SWP_DISCARDING),
-				wait_for_discard, TASK_UNINTERRUPTIBLE);
-			spin_lock(&si->lock);
-		} else {
-			/*
-			 * Note pages allocated by racing tasks while
-			 * scan for a free cluster is in progress, so
-			 * that its final discard can exclude them.
-			 */
-			if (offset < si->lowest_alloc)
-				si->lowest_alloc = offset;
-			if (offset > si->highest_alloc)
-				si->highest_alloc = offset;
-		}
-	}
 	return offset;
 
 scan:
@@ -1782,6 +1803,8 @@ SYSCALL_DEFINE1(swapoff, const char __us
 		goto out_dput;
 	}
 
+	flush_work(&p->discard_work);
+
 	destroy_swap_extents(p);
 	if (p->flags & SWP_CONTINUED)
 		free_swap_count_continuations(p);
@@ -2143,6 +2166,8 @@ static int setup_swap_map_and_extents(st
 
 	cluster_set_null(&p->free_cluster_head);
 	cluster_set_null(&p->free_cluster_tail);
+	cluster_set_null(&p->discard_cluster_head);
+	cluster_set_null(&p->discard_cluster_tail);
 
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
 		unsigned int page_nr = swap_header->info.badpages[i];
@@ -2252,6 +2277,8 @@ SYSCALL_DEFINE2(swapon, const char __use
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
+	INIT_WORK(&p->discard_work, swap_discard_work);
+
 	name = getname(specialfile);
 	if (IS_ERR(name)) {
 		error = PTR_ERR(name);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
