Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6E776B0260
	for <linux-mm@kvack.org>; Tue,  3 May 2016 17:02:08 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gw7so43448331pac.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 14:02:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 81si310845pfq.221.2016.05.03.14.02.06
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 14:02:07 -0700 (PDT)
Message-ID: <1462309326.21143.10.camel@linux.intel.com>
Subject: [PATCH 3/7] mm: Add new functions to allocate swap slots in batches
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 03 May 2016 14:02:06 -0700
In-Reply-To: <cover.1462306228.git.tim.c.chen@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Currently, the swap slots have to be allocated one page at a time,
causing contention to the swap_info lock protecting the swap partition
on every page being swapped.

This patch adds new functions get_swap_pages and scan_swap_map_slots to
request multiple swap slots at once. This will reduce the lock contention
on the swap_info lock as we only need to acquire the lock once to get
multiple slots.A A Also scan_swap_map_slots can operate more efficiently
as swap slots often occurs in clusters close to each other on a swap
device and it is quicker to allocate them together.

Multiple swap slots can also be freed in one shot with new function
swapcache_free_entries, that further reduce contention on the swap_info
lock.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
A include/linux/swap.h |A A 27 +++++--
A mm/swap_state.cA A A A A A |A A 23 +++---
A mm/swapfile.cA A A A A A A A | 215 +++++++++++++++++++++++++++++++++++++++++++++------
A mm/vmscan.cA A A A A A A A A A |A A A 2 +-
A 4 files changed, 228 insertions(+), 39 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2b83359..da6d994 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -23,6 +23,7 @@ struct bio;
A #define SWAP_FLAG_DISCARD	0x10000 /* enable discard for swap */
A #define SWAP_FLAG_DISCARD_ONCE	0x20000 /* discard swap area at swapon-time */
A #define SWAP_FLAG_DISCARD_PAGES 0x40000 /* discard page-clusters after use */
+#define SWAP_BATCH 64
A 
A #define SWAP_FLAGS_VALID	(SWAP_FLAG_PRIO_MASK | SWAP_FLAG_PREFER | \
A 				A SWAP_FLAG_DISCARD | SWAP_FLAG_DISCARD_ONCE | \
@@ -370,7 +371,8 @@ extern struct address_space swapper_spaces[];
A #define swap_address_space(entry) (&swapper_spaces[swp_type(entry)])
A extern unsigned long total_swapcache_pages(void);
A extern void show_swap_cache_info(void);
-extern int add_to_swap(struct page *, struct list_head *list);
+extern int add_to_swap(struct page *, struct list_head *list,
+			swp_entry_t *entry);
A extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
A extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
A extern void __delete_from_swap_cache(struct page *);
@@ -403,6 +405,7 @@ static inline long get_nr_swap_pages(void)
A 
A extern void si_swapinfo(struct sysinfo *);
A extern swp_entry_t get_swap_page(void);
+extern int get_swap_pages(int n, swp_entry_t swp_entries[]);
A extern swp_entry_t get_swap_page_of_type(int);
A extern int add_swap_count_continuation(swp_entry_t, gfp_t);
A extern void swap_shmem_alloc(swp_entry_t);
@@ -410,6 +413,7 @@ extern int swap_duplicate(swp_entry_t);
A extern int swapcache_prepare(swp_entry_t);
A extern void swap_free(swp_entry_t);
A extern void swapcache_free(swp_entry_t);
+extern void swapcache_free_entries(swp_entry_t *entries, int n);
A extern int free_swap_and_cache(swp_entry_t);
A extern int swap_type_of(dev_t, sector_t, struct block_device **);
A extern unsigned int count_swap_pages(int, int);
@@ -429,7 +433,6 @@ struct backing_dev_info;
A #define total_swap_pages			0L
A #define total_swapcache_pages()			0UL
A #define vm_swap_full()				0
-
A #define si_swapinfo(val) \
A 	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
A /* only sparc can not include linux/pagemap.h in this file
@@ -451,6 +454,21 @@ static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
A 	return 0;
A }
A 
+static inline int add_to_swap(struct page *page, struct list_head *list,
+				swp_entry_t *entry)
+{
+	return 0;
+}
+
+static inline int get_swap_pages(int n, swp_entry_t swp_entries[])
+{
+	return 0;
+}
+
+static inline void swapcache_free_entries(swp_entry_t *entries, int n)
+{
+}
+
A static inline void swap_shmem_alloc(swp_entry_t swp)
A {
A }
@@ -484,11 +502,6 @@ static inline struct page *lookup_swap_cache(swp_entry_t swp)
A 	return NULL;
A }
A 
-static inline int add_to_swap(struct page *page, struct list_head *list)
-{
-	return 0;
-}
-
A static inline int add_to_swap_cache(struct page *page, swp_entry_t entry,
A 							gfp_t gfp_mask)
A {
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 366ce35..bad02c1 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -154,30 +154,35 @@ void __delete_from_swap_cache(struct page *page)
A /**
A  * add_to_swap - allocate swap space for a page
A  * @page: page we want to move to swap
+ * @entry: swap entry that we have pre-allocated
A  *
A  * Allocate swap space for the page and add the page to the
A  * swap cache.A A Caller needs to hold the page lock.A 
A  */
-int add_to_swap(struct page *page, struct list_head *list)
+int add_to_swap(struct page *page, struct list_head *list, swp_entry_t *entry)
A {
-	swp_entry_t entry;
A 	int err;
+	swp_entry_t ent;
A 
A 	VM_BUG_ON_PAGE(!PageLocked(page), page);
A 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
A 
-	entry = get_swap_page();
-	if (!entry.val)
+	if (!entry) {
+		ent = get_swap_page();
+		entry = &ent;
+	}
+
+	if (entry && !entry->val)
A 		return 0;
A 
-	if (mem_cgroup_try_charge_swap(page, entry)) {
-		swapcache_free(entry);
+	if (mem_cgroup_try_charge_swap(page, *entry)) {
+		swapcache_free(*entry);
A 		return 0;
A 	}
A 
A 	if (unlikely(PageTransHuge(page)))
A 		if (unlikely(split_huge_page_to_list(page, list))) {
-			swapcache_free(entry);
+			swapcache_free(*entry);
A 			return 0;
A 		}
A 
@@ -192,7 +197,7 @@ int add_to_swap(struct page *page, struct list_head *list)
A 	/*
A 	A * Add it to the swap cache.
A 	A */
-	err = add_to_swap_cache(page, entry,
+	err = add_to_swap_cache(page, *entry,
A 			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
A 
A 	if (!err) {
@@ -202,7 +207,7 @@ int add_to_swap(struct page *page, struct list_head *list)
A 		A * add_to_swap_cache() doesn't return -EEXIST, so we can safely
A 		A * clear SWAP_HAS_CACHE flag.
A 		A */
-		swapcache_free(entry);
+		swapcache_free(*entry);
A 		return 0;
A 	}
A }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 83874ec..2c294a6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -437,7 +437,7 @@ scan_swap_map_ssd_cluster_conflict(struct swap_info_struct *si,
A  * Try to get a swap entry from current cpu's swap entry pool (a cluster). This
A  * might involve allocating a new cluster for current CPU too.
A  */
-static void scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
+static bool scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
A 	unsigned long *offset, unsigned long *scan_base)
A {
A 	struct percpu_cluster *cluster;
@@ -460,7 +460,7 @@ new_cluster:
A 			*scan_base = *offset = si->cluster_next;
A 			goto new_cluster;
A 		} else
-			return;
+			return false;
A 	}
A 
A 	found_free = false;
@@ -485,15 +485,21 @@ new_cluster:
A 	cluster->next = tmp + 1;
A 	*offset = tmp;
A 	*scan_base = tmp;
+	return found_free;
A }
A 
-static unsigned long scan_swap_map(struct swap_info_struct *si,
-				A A A unsigned char usage)
+static int scan_swap_map_slots(struct swap_info_struct *si,
+				A A A unsigned char usage, int nr,
+				A A A unsigned long slots[])
A {
A 	unsigned long offset;
A 	unsigned long scan_base;
A 	unsigned long last_in_cluster = 0;
A 	int latency_ration = LATENCY_LIMIT;
+	int n_ret = 0;
+
+	if (nr > SWAP_BATCH)
+		nr = SWAP_BATCH;
A 
A 	/*
A 	A * We try to cluster swap pages by allocating them sequentially
@@ -511,8 +517,10 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
A 
A 	/* SSD algorithm */
A 	if (si->cluster_info) {
-		scan_swap_map_try_ssd_cluster(si, &offset, &scan_base);
-		goto checks;
+		if (scan_swap_map_try_ssd_cluster(si, &offset, &scan_base))
+			goto checks;
+		else
+			goto done;
A 	}
A 
A 	if (unlikely(!si->cluster_nr--)) {
@@ -556,8 +564,14 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
A 
A checks:
A 	if (si->cluster_info) {
-		while (scan_swap_map_ssd_cluster_conflict(si, offset))
-			scan_swap_map_try_ssd_cluster(si, &offset, &scan_base);
+		while (scan_swap_map_ssd_cluster_conflict(si, offset)) {
+		/* take a break if we already got some slots */
+			if (n_ret)
+				goto done;
+			if (!scan_swap_map_try_ssd_cluster(si, &offset,
+							&scan_base))
+				goto done;
+		}
A 	}
A 	if (!(si->flags & SWP_WRITEOK))
A 		goto no_page;
@@ -578,8 +592,12 @@ checks:
A 		goto scan; /* check next one */
A 	}
A 
-	if (si->swap_map[offset])
-		goto scan;
+	if (si->swap_map[offset]) {
+		if (!n_ret)
+			goto scan;
+		else
+			goto done;
+	}
A 
A 	if (offset == si->lowest_bit)
A 		si->lowest_bit++;
@@ -596,9 +614,42 @@ checks:
A 	si->swap_map[offset] = usage;
A 	inc_cluster_info_page(si, si->cluster_info, offset);
A 	si->cluster_next = offset + 1;
-	si->flags -= SWP_SCANNING;
+	slots[n_ret] = offset;
+	++n_ret;
A 
-	return offset;
+	/* got enough slots or reach max slots? */
+	if ((n_ret == nr) || (offset >= si->highest_bit))
+		goto done;
+
+	/* search for next available slot */
+
+	/* time to take a break? */
+	if (unlikely(--latency_ration < 0)) {
+		spin_unlock(&si->lock);
+		cond_resched();
+		spin_lock(&si->lock);
+		latency_ration = LATENCY_LIMIT;
+	}
+
+	/* try to get more slots in cluster */
+	if (si->cluster_info) {
+		if (scan_swap_map_try_ssd_cluster(si, &offset, &scan_base))
+			goto checks;
+		else
+			goto done;
+	}
+	/* non-ssd case */
+	++offset;
+
+	/* non-ssd case, still more slots in cluster? */
+	if (si->cluster_nr && !si->swap_map[offset]) {
+		--si->cluster_nr;
+		goto checks;
+	}
+
+done:
+	si->flags -= SWP_SCANNING;
+	return n_ret;
A 
A scan:
A 	spin_unlock(&si->lock);
@@ -636,17 +687,44 @@ scan:
A 
A no_page:
A 	si->flags -= SWP_SCANNING;
-	return 0;
+	return n_ret;
A }
A 
-swp_entry_t get_swap_page(void)
+static unsigned long scan_swap_map(struct swap_info_struct *si,
+				A A A unsigned char usage)
+{
+	unsigned long slots[1];
+	int n_ret;
+
+	n_ret = scan_swap_map_slots(si, usage, 1, slots);
+
+	if (n_ret)
+		return slots[0];
+	else
+		return 0;
+
+}
+
+int get_swap_pages(int n, swp_entry_t swp_entries[])
A {
A 	struct swap_info_struct *si, *next;
-	pgoff_t offset;
+	long avail_pgs, n_ret, n_goal;
A 
-	if (atomic_long_read(&nr_swap_pages) <= 0)
+	n_ret = 0;
+	avail_pgs = atomic_long_read(&nr_swap_pages);
+	if (avail_pgs <= 0)
A 		goto noswap;
-	atomic_long_dec(&nr_swap_pages);
+
+	n_goal = n;
+	swp_entries[0] = (swp_entry_t) {0};
+
+	if (n_goal > SWAP_BATCH)
+		n_goal = SWAP_BATCH;
+
+	if (n_goal > avail_pgs)
+		n_goal = avail_pgs;
+
+	atomic_long_sub(n_goal, &nr_swap_pages);
A 
A 	spin_lock(&swap_avail_lock);
A 
@@ -674,10 +752,26 @@ start_over:
A 		}
A 
A 		/* This is called for allocating swap entry for cache */
-		offset = scan_swap_map(si, SWAP_HAS_CACHE);
+		while (n_ret < n_goal) {
+			unsigned long slots[SWAP_BATCH];
+			int ret, i;
+
+			ret = scan_swap_map_slots(si, SWAP_HAS_CACHE,
+							n_goal-n_ret, slots);
+			if (!ret)
+				break;
+
+			for (i = 0; i < ret; ++i)
+				swp_entries[n_ret+i] = swp_entry(si->type,
+								slots[i]);
+
+			n_ret += ret;
+		}
+
A 		spin_unlock(&si->lock);
-		if (offset)
-			return swp_entry(si->type, offset);
+		if (n_ret == n_goal)
+			return n_ret;
+
A 		pr_debug("scan_swap_map of si %d failed to find offset\n",
A 		A A A A A A A si->type);
A 		spin_lock(&swap_avail_lock);
@@ -698,9 +792,23 @@ nextsi:
A 
A 	spin_unlock(&swap_avail_lock);
A 
-	atomic_long_inc(&nr_swap_pages);
+	if (n_ret < n_goal)
+		atomic_long_add((long) (n_goal-n_ret), &nr_swap_pages);
A noswap:
-	return (swp_entry_t) {0};
+	return n_ret;
+}
+
+swp_entry_t get_swap_page(void)
+{
+	swp_entry_t swp_entries[1];
+	long n_ret;
+
+	n_ret = get_swap_pages(1, swp_entries);
+
+	if (n_ret)
+		return swp_entries[0];
+	else
+		return (swp_entry_t) {0};
A }
A 
A /* The only caller of this function is now suspend routine */
@@ -761,6 +869,47 @@ out:
A 	return NULL;
A }
A 
+static struct swap_info_struct *swap_info_get_cont(swp_entry_t entry,
+					struct swap_info_struct *q)
+{
+	struct swap_info_struct *p;
+	unsigned long offset, type;
+
+	if (!entry.val)
+		goto out;
+	type = swp_type(entry);
+	if (type >= nr_swapfiles)
+		goto bad_nofile;
+	p = swap_info[type];
+	if (!(p->flags & SWP_USED))
+		goto bad_device;
+	offset = swp_offset(entry);
+	if (offset >= p->max)
+		goto bad_offset;
+	if (!p->swap_map[offset])
+		goto bad_free;
+	if (p != q) {
+		if (q != NULL)
+			spin_unlock(&q->lock);
+		spin_lock(&p->lock);
+	}
+	return p;
+
+bad_free:
+	pr_err("swap_free: %s%08lx\n", Unused_offset, entry.val);
+	goto out;
+bad_offset:
+	pr_err("swap_free: %s%08lx\n", Bad_offset, entry.val);
+	goto out;
+bad_device:
+	pr_err("swap_free: %s%08lx\n", Unused_file, entry.val);
+	goto out;
+bad_nofile:
+	pr_err("swap_free: %s%08lx\n", Bad_file, entry.val);
+out:
+	return NULL;
+}
+
A static unsigned char swap_entry_free(struct swap_info_struct *p,
A 				A A A A A swp_entry_t entry, unsigned char usage)
A {
@@ -855,6 +1004,28 @@ void swapcache_free(swp_entry_t entry)
A 	}
A }
A 
+void swapcache_free_entries(swp_entry_t *entries, int n)
+{
+	struct swap_info_struct *p, *prev;
+	int i;
+
+	if (n <= 0)
+		return;
+
+	prev = NULL;
+	p = NULL;
+	for (i = 0; i < n; ++i) {
+		p = swap_info_get_cont(entries[i], prev);
+		if (p)
+			swap_entry_free(p, entries[i], SWAP_HAS_CACHE);
+		else
+			break;
+		prev = p;
+	}
+	if (p)
+		spin_unlock(&p->lock);
+}
+
A /*
A  * How many references to page are currently swapped out?
A  * This does not give an exact answer when swap count is continued,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 132ba02..e36d8a7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1114,7 +1114,7 @@ static unsigned long shrink_anon_page_list(struct list_head *page_list,
A 		* Try to allocate it some swap space here.
A 		*/
A 
-		if (!add_to_swap(page, page_list)) {
+		if (!add_to_swap(page, page_list, NULL)) {
A 			pg_finish(page, PG_ACTIVATE_LOCKED, swap_ret, &nr_reclaimed,
A 					pgactivate, ret_pages, free_pages);
A 			continue;
--A 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
