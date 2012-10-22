Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A9BAD6B0069
	for <linux-mm@kvack.org>; Sun, 21 Oct 2012 22:31:30 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1755486pbb.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 19:31:29 -0700 (PDT)
Date: Mon, 22 Oct 2012 10:31:13 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC 2/2]swap: make swap discard async
Message-ID: <20121022023113.GB20255@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

swap can do cluster discard for SSD, which is good, but there are some problems
here:
1. swap do the discard just before page reclaim gets a swap entry and writes
the disk sectors. This is useless for high end SSD, because an overwrite to a
sector implies a discard to original nand flash too. A discard + overwrite ==
overwrite.
2. the purpose of doing discard is to improve SSD firmware garbage collection.
Doing discard just before write doesn't help, because the interval between
discard and write is too short. Doing discard async and just after a swap entry
is freed can make the interval longer, so SSD firmware has more time to do gc.
3. block discard is a sync API, which will delay scan_swap_map() significantly.
4. Write and discard command can be executed parallel in PCIe SSD. Making
swap discard async can make execution more efficiently.

This patch makes swap discard async, and move discard to where swap entry is
freed. Idealy we should do discard for any freed sectors, but some SSD discard
is very slow. This patch still does discard for a whole cluster. 

My test does a several round of 'mmap, write, unmap', which will trigger a lot
of swap discard. In a fusionio card, with this patch, the test runtime is
reduced to 18% of the time without it, so around 5.5x faster.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 include/linux/swap.h |    3 
 mm/swapfile.c        |  177 +++++++++++++++++++++++++++------------------------
 2 files changed, 98 insertions(+), 82 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2012-10-22 09:20:50.462043746 +0800
+++ linux/include/linux/swap.h	2012-10-22 09:23:27.720066736 +0800
@@ -192,8 +192,6 @@ struct swap_info_struct {
 	unsigned int inuse_pages;	/* number of those currently in use */
 	unsigned int cluster_next;	/* likely index for next allocation */
 	unsigned int cluster_nr;	/* countdown to next cluster search */
-	unsigned int lowest_alloc;	/* while preparing discard cluster */
-	unsigned int highest_alloc;	/* while preparing discard cluster */
 	struct swap_extent *curr_swap_extent;
 	struct swap_extent first_swap_extent;
 	struct block_device *bdev;	/* swap device or bdev of swap file */
@@ -203,6 +201,7 @@ struct swap_info_struct {
 	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
 	atomic_t frontswap_pages;	/* frontswap pages in-use counter */
 #endif
+	struct work_struct discard_work;
 };
 
 struct swap_list_t {
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2012-10-22 09:21:34.317493506 +0800
+++ linux/mm/swapfile.c	2012-10-22 09:56:17.379304667 +0800
@@ -173,15 +173,82 @@ static void discard_swap_cluster(struct
 	}
 }
 
-static int wait_for_discard(void *word)
-{
-	schedule();
-	return 0;
-}
-
-#define SWAPFILE_CLUSTER	256
+#define SWAPFILE_CLUSTER_SHIFT	8
+#define SWAPFILE_CLUSTER	(1<<SWAPFILE_CLUSTER_SHIFT)
 #define LATENCY_LIMIT		256
 
+/* magic number to indicate the cluster is discardable */
+#define CLUSTER_COUNT_DISCARDABLE (SWAPFILE_CLUSTER * 2)
+#define CLUSTER_COUNT_DISCARDING (SWAPFILE_CLUSTER * 2 + 1)
+static void swap_cluster_check_discard(struct swap_info_struct *si,
+		unsigned long offset)
+{
+	unsigned long cluster = offset/SWAPFILE_CLUSTER;
+
+	if (!(si->flags & SWP_DISCARDABLE))
+		return;
+	if (si->swap_cluster_count[cluster] > 0)
+		return;
+	si->swap_cluster_count[cluster] = CLUSTER_COUNT_DISCARDABLE;
+	/* Just mark the swap entries occupied */
+	memset(si->swap_map + (cluster << SWAPFILE_CLUSTER_SHIFT),
+			SWAP_MAP_BAD, SWAPFILE_CLUSTER);
+	schedule_work(&si->discard_work);
+}
+
+static void swap_discard_work(struct work_struct *work)
+{
+	struct swap_info_struct *si = container_of(work,
+		struct swap_info_struct, discard_work);
+	unsigned int *counter = si->swap_cluster_count;
+	int i;
+
+	for (i = round_up(si->cluster_next, SWAPFILE_CLUSTER) /
+	     SWAPFILE_CLUSTER; i < round_down(si->highest_bit,
+	     SWAPFILE_CLUSTER) / SWAPFILE_CLUSTER; i++) {
+		if (counter[i] == CLUSTER_COUNT_DISCARDABLE) {
+			spin_lock(&swap_lock);
+			if (counter[i] != CLUSTER_COUNT_DISCARDABLE) {
+				spin_unlock(&swap_lock);
+				continue;
+			}
+			counter[i] = CLUSTER_COUNT_DISCARDING;
+			spin_unlock(&swap_lock);
+
+			discard_swap_cluster(si, i << SWAPFILE_CLUSTER_SHIFT,
+				SWAPFILE_CLUSTER);
+
+			spin_lock(&swap_lock);
+			counter[i] = 0;
+			memset(si->swap_map + (i << SWAPFILE_CLUSTER_SHIFT),
+					0, SWAPFILE_CLUSTER);
+			spin_unlock(&swap_lock);
+		}
+	}
+	for (i = round_up(si->lowest_bit, SWAPFILE_CLUSTER) /
+	     SWAPFILE_CLUSTER; i < round_down(si->cluster_next,
+	     SWAPFILE_CLUSTER) / SWAPFILE_CLUSTER; i++) {
+		if (counter[i] == CLUSTER_COUNT_DISCARDABLE) {
+			spin_lock(&swap_lock);
+			if (counter[i] != CLUSTER_COUNT_DISCARDABLE) {
+				spin_unlock(&swap_lock);
+				continue;
+			}
+			counter[i] = CLUSTER_COUNT_DISCARDING;
+			spin_unlock(&swap_lock);
+
+			discard_swap_cluster(si, i << SWAPFILE_CLUSTER_SHIFT,
+				SWAPFILE_CLUSTER);
+
+			spin_lock(&swap_lock);
+			counter[i] = 0;
+			memset(si->swap_map + (i << SWAPFILE_CLUSTER_SHIFT),
+					0, SWAPFILE_CLUSTER);
+			spin_unlock(&swap_lock);
+		}
+	}
+}
+
 static inline void inc_swap_cluster_count(unsigned int *swap_cluster_count,
 					unsigned long page_nr)
 {
@@ -203,9 +270,8 @@ static unsigned long scan_swap_map(struc
 {
 	unsigned long offset;
 	unsigned long scan_base;
-	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
-	int found_free_cluster = 0;
+	bool has_discardable_cluster = false;
 
 	/*
 	 * We try to cluster swap pages by allocating them sequentially
@@ -228,21 +294,9 @@ static unsigned long scan_swap_map(struc
 			si->cluster_nr = SWAPFILE_CLUSTER - 1;
 			goto checks;
 		}
-		if (si->flags & SWP_DISCARDABLE) {
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
 		spin_unlock(&swap_lock);
 
+search_cluster:
 		/*
 		 * If seek is expensive, start searching for new cluster from
 		 * start of partition, to minimize the span of allocated swap.
@@ -259,13 +313,16 @@ static unsigned long scan_swap_map(struc
 		     base <= si->highest_bit; base += SWAPFILE_CLUSTER) {
 			if (!si->swap_cluster_count[base/SWAPFILE_CLUSTER]) {
 				offset = base;
-				last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 				spin_lock(&swap_lock);
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
-				found_free_cluster = 1;
 				goto checks;
 			}
+			if (si->swap_cluster_count[base/SWAPFILE_CLUSTER] >=
+			    CLUSTER_COUNT_DISCARDABLE) {
+				has_discardable_cluster = true;
+				schedule_work(&si->discard_work);
+			}
 			if (unlikely(--latency_ration < 0)) {
 				cond_resched();
 				latency_ration = LATENCY_LIMIT;
@@ -279,13 +336,16 @@ static unsigned long scan_swap_map(struc
 		     base < scan_base; base += SWAPFILE_CLUSTER) {
 			if (!si->swap_cluster_count[base/SWAPFILE_CLUSTER]) {
 				offset = base;
-				last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
 				spin_lock(&swap_lock);
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
-				found_free_cluster = 1;
 				goto checks;
 			}
+			if (si->swap_cluster_count[base/SWAPFILE_CLUSTER] >=
+			    CLUSTER_COUNT_DISCARDABLE) {
+				has_discardable_cluster = true;
+				schedule_work(&si->discard_work);
+			}
 			if (unlikely(--latency_ration < 0)) {
 				cond_resched();
 				latency_ration = LATENCY_LIMIT;
@@ -293,9 +353,14 @@ static unsigned long scan_swap_map(struc
 		}
 
 		offset = scan_base;
+
+		if (has_discardable_cluster) {
+			flush_work(&si->discard_work);
+			goto search_cluster;
+		}
+
 		spin_lock(&swap_lock);
 		si->cluster_nr = SWAPFILE_CLUSTER - 1;
-		si->lowest_alloc = 0;
 	}
 
 checks:
@@ -335,59 +400,6 @@ checks:
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
-	if (si->lowest_alloc) {
-		/*
-		 * Only set when SWP_DISCARDABLE, and there's a scan
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
-			spin_unlock(&swap_lock);
-
-			if (offset < last_in_cluster)
-				discard_swap_cluster(si, offset,
-					last_in_cluster - offset + 1);
-
-			spin_lock(&swap_lock);
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
-			spin_unlock(&swap_lock);
-			wait_on_bit(&si->flags, ilog2(SWP_DISCARDING),
-				wait_for_discard, TASK_UNINTERRUPTIBLE);
-			spin_lock(&swap_lock);
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
@@ -583,6 +595,7 @@ static unsigned char swap_entry_free(str
 				disk->fops->swap_slot_free_notify(p->bdev,
 								  offset);
 		}
+		swap_cluster_check_discard(p, offset);
 	}
 
 	return usage;
@@ -1582,6 +1595,8 @@ SYSCALL_DEFINE1(swapoff, const char __us
 		goto out_dput;
 	}
 
+	flush_work(&p->discard_work);
+
 	destroy_swap_extents(p);
 	if (p->flags & SWP_CONTINUED)
 		free_swap_count_continuations(p);
@@ -1992,6 +2007,8 @@ SYSCALL_DEFINE2(swapon, const char __use
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
