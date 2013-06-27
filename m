Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx111.postini.com [74.125.246.211])
	by kanga.kvack.org (Postfix) with SMTP id 6A04E6B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 19:59:31 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [patch 2/4 v5]swap: make swap discard async
Date: Thu, 27 Jun 2013 20:58:54 -0300
Message-Id: <eb7abfe2074fbc9e2b88f97be5fa1e0fb3799af4.1372376365.git.aquini@redhat.com>
In-Reply-To: <20130624110348.GB15796@kernel.org>
References: <20130624110348.GB15796@kernel.org>
In-Reply-To: <20130624110348.GB15796@kernel.org>
References: <20130624110348.GB15796@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shli@kernel.org
Cc: akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, linux-mm@kvack.org

Hi Shaohua,

If you take the patch from my reply to 
[patch 1/4 v5]swap: change block allocation algorithm for SSD

The following changes are just to make your merge easier

Thanks in advance!
Rafael

---
 include/linux/swap.h |   5 +-
 mm/swapfile.c        | 172 ++++++++++++++++++++++++++++-----------------------
 2 files changed, 97 insertions(+), 80 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index aaea27e..95d1747 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -200,8 +200,6 @@ struct swap_info_struct {
 	unsigned int inuse_pages;	/* number of those currently in use */
 	unsigned int cluster_next;	/* likely index for next allocation */
 	unsigned int cluster_nr;	/* countdown to next cluster search */
-	unsigned int lowest_alloc;	/* while preparing discard cluster */
-	unsigned int highest_alloc;	/* while preparing discard cluster */
 	struct swap_extent *curr_swap_extent;
 	struct swap_extent first_swap_extent;
 	struct block_device *bdev;	/* swap device or bdev of swap file */
@@ -223,6 +221,9 @@ struct swap_info_struct {
 					 * swap_lock. If both locks need hold,
 					 * hold swap_lock first.
 					 */
+	struct work_struct discard_work;
+	unsigned int discard_cluster_head;
+	unsigned int discard_cluster_tail;
 };
 
 struct swap_list_t {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5d0a7d0..fe63846 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -175,12 +175,6 @@ static void discard_swap_cluster(struct swap_info_struct *si,
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
 
@@ -255,6 +249,75 @@ static inline bool swap_cluster_is_free(unsigned int info)
 	return !(!(__swap_cluster_get_flags(info) & SWP_CLUSTER_FLAG_FREE));
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
+	if (si->discard_cluster_head == SWP_CLUSTER_NULL) {
+		si->discard_cluster_head = idx;
+		si->discard_cluster_tail = idx;
+	} else {
+		swap_cluster_set_next(&si->cluster_info[si->discard_cluster_tail], idx);
+		si->discard_cluster_tail = idx;
+	}
+
+	schedule_work(&si->discard_work);
+}
+
+/* caller should hold si->lock */
+static void swap_do_scheduled_discard(struct swap_info_struct *si)
+{
+	unsigned int *info;
+	unsigned int idx;
+
+	info = si->cluster_info;
+
+	while (si->discard_cluster_head != SWP_CLUSTER_NULL) {
+		idx = si->discard_cluster_head;
+
+		si->discard_cluster_head = swap_cluster_next(info[idx]);
+		if (si->discard_cluster_tail == idx) {
+			si->discard_cluster_tail = SWP_CLUSTER_NULL;
+			si->discard_cluster_head = SWP_CLUSTER_NULL;
+		}
+		spin_unlock(&si->lock);
+
+		discard_swap_cluster(si, idx * SWAPFILE_CLUSTER,
+				SWAPFILE_CLUSTER);
+
+		spin_lock(&si->lock);
+		swap_cluster_set_flag(&info[idx], SWP_CLUSTER_FLAG_FREE);
+		if (si->free_cluster_head == SWP_CLUSTER_NULL) {
+			si->free_cluster_head = idx;
+			si->free_cluster_tail = idx;
+		} else {
+			swap_cluster_set_next(&info[si->free_cluster_tail], idx);
+			si->free_cluster_tail = idx;
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
 static void swap_cluster_info_inc_page(struct swap_info_struct *p,
 					     unsigned int *cluster_info,
 					     unsigned long page_nr)
@@ -293,6 +356,16 @@ static void swap_cluster_info_dec_page(struct swap_info_struct *p,
 			      swap_cluster_count(cluster_info[idx]) - 1);
 
 	if (swap_cluster_count(cluster_info[idx]) == 0) {
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
 		swap_cluster_set_flag(&cluster_info[idx], SWP_CLUSTER_FLAG_FREE);
 		if (p->free_cluster_head == SWP_CLUSTER_NULL) {
 			p->free_cluster_head = idx;
@@ -326,7 +399,6 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 	unsigned long scan_base;
 	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
-	int found_free_cluster = 0;
 
 	/*
 	 * We try to cluster swap pages by allocating them sequentially
@@ -347,34 +419,28 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
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
 		if (si->free_cluster_head != SWP_CLUSTER_NULL) {
 			offset = si->free_cluster_head * SWAPFILE_CLUSTER;
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
+			if (si->discard_cluster_head != SWP_CLUSTER_NULL) {
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
 
@@ -401,7 +467,6 @@ check_cluster:
 				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
-				found_free_cluster = 1;
 				goto checks;
 			}
 			if (unlikely(--latency_ration < 0)) {
@@ -422,7 +487,6 @@ check_cluster:
 				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
-				found_free_cluster = 1;
 				goto checks;
 			}
 			if (unlikely(--latency_ration < 0)) {
@@ -434,7 +498,6 @@ check_cluster:
 		offset = scan_base;
 		spin_lock(&si->lock);
 		si->cluster_nr = SWAPFILE_CLUSTER - 1;
-		si->lowest_alloc = 0;
 	}
 
 checks:
@@ -476,59 +539,6 @@ checks:
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
@@ -1797,6 +1807,8 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		goto out_dput;
 	}
 
+	flush_work(&p->discard_work);
+
 	destroy_swap_extents(p);
 	if (p->flags & SWP_CONTINUED)
 		free_swap_count_continuations(p);
@@ -2158,6 +2170,8 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 
 	p->free_cluster_head = SWP_CLUSTER_NULL;
 	p->free_cluster_tail = SWP_CLUSTER_NULL;
+	p->discard_cluster_head = SWP_CLUSTER_NULL;
+	p->discard_cluster_tail = SWP_CLUSTER_NULL;
 
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
 		unsigned int page_nr = swap_header->info.badpages[i];
@@ -2265,6 +2279,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
+	INIT_WORK(&p->discard_work, swap_discard_work);
+
 	name = getname(specialfile);
 	if (IS_ERR(name)) {
 		error = PTR_ERR(name);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
