Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 1B6076B006C
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 20:25:19 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1030855dak.14
        for <linux-mm@kvack.org>; Sun, 09 Dec 2012 17:25:17 -0800 (PST)
Date: Mon, 10 Dec 2012 09:25:10 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 2/2]swap: add per-partition lock for swapfile
Message-ID: <20121210012510.GB18570@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, minchan@kernel.org

swap_lock is heavily contended when I test swap to 3 fast SSD (even slightly
slower than swap to 2 such SSD). The main contention comes from
swap_info_get(). This patch tries to fix the gap with adding a new
per-partition lock.

global data like nr_swapfiles, total_swap_pages, least_priority and swap_list are
still protected by swap_lock.

nr_swap_pages is an atomic now, it can be changed without swap_lock. In theory,
it's possible get_swap_page() finds no swap pages but actually there are free
swap pages. But sounds not a big problem.

accessing partition specific data (like scan_swap_map and so on) is only
protected by swap_info_struct.lock.

Changing swap_info_struct.flags need hold swap_lock and swap_info_struct.lock,
because scan_scan_map() will check it. read the flags is ok with either the
locks hold.

If both swap_lock and swap_info_struct.lock must be hold, we always hold the
former first to avoid deadlock.

swap_entry_free() can change swap_list. To delete that code, we add a new
highest_priority_index. Whenever get_swap_page() is called, we check it. If
it's valid, we use it.

It's a pitty get_swap_page() still holds swap_lock(). But in practice,
swap_lock() isn't heavily contended in my test with this patch (or I can say
there are other much more heavier bottlenecks like TLB flush). And BTW, looks
get_swap_page() doesn't really need the lock. We never free swap_info[] and we
check SWAP_WRITEOK flag. The only risk without the lock is we could swapout to
some low priority swap, but we can quickly recover after several rounds of
swap, so sounds not a big deal to me. But I'd prefer to fix this if it's a real
problem.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 drivers/staging/zcache/zcache-main.c |   23 ++++-
 include/linux/swap.h                 |    6 +
 mm/mmap.c                            |    2 
 mm/swap_state.c                      |    3 
 mm/swapfile.c                        |  138 +++++++++++++++++++++++------------
 mm/vmscan.c                          |    8 +-
 6 files changed, 122 insertions(+), 58 deletions(-)

Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2012-12-10 09:02:45.029330611 +0800
+++ linux/include/linux/swap.h	2012-12-10 09:02:56.101191464 +0800
@@ -252,6 +252,7 @@ struct swap_info_struct {
 	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
 	atomic_t frontswap_pages;	/* frontswap pages in-use counter */
 #endif
+	spinlock_t lock;
 };
 
 struct swap_list_t {
@@ -260,7 +261,8 @@ struct swap_list_t {
 };
 
 /* Swap 50% full? Release swapcache more aggressively.. */
-#define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
+#define vm_swap_full() \
+	(atomic_long_read(&nr_swap_pages)*2 < total_swap_pages)
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
@@ -397,7 +399,7 @@ extern struct page *swapin_readahead(swp
 			struct vm_area_struct *vma, unsigned long addr);
 
 /* linux/mm/swapfile.c */
-extern long nr_swap_pages;
+extern atomic_long_t nr_swap_pages;
 extern long total_swap_pages;
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2012-12-10 09:02:45.037330401 +0800
+++ linux/mm/swapfile.c	2012-12-10 09:02:56.101191464 +0800
@@ -47,9 +47,11 @@ static sector_t map_swap_entry(swp_entry
 
 DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
-long nr_swap_pages;
+atomic_long_t nr_swap_pages;
+/* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
 long total_swap_pages;
 static int least_priority;
+static atomic_t highest_priority_index = ATOMIC_INIT(-1);
 
 static const char Bad_file[] = "Bad swap file entry ";
 static const char Unused_file[] = "Unused swap file entry ";
@@ -223,7 +225,7 @@ static unsigned long scan_swap_map(struc
 			si->lowest_alloc = si->max;
 			si->highest_alloc = 0;
 		}
-		spin_unlock(&swap_lock);
+		spin_unlock(&si->lock);
 
 		/*
 		 * If seek is expensive, start searching for new cluster from
@@ -242,7 +244,7 @@ static unsigned long scan_swap_map(struc
 			if (si->swap_map[offset])
 				last_in_cluster = offset + SWAPFILE_CLUSTER;
 			else if (offset == last_in_cluster) {
-				spin_lock(&swap_lock);
+				spin_lock(&si->lock);
 				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
@@ -263,7 +265,7 @@ static unsigned long scan_swap_map(struc
 			if (si->swap_map[offset])
 				last_in_cluster = offset + SWAPFILE_CLUSTER;
 			else if (offset == last_in_cluster) {
-				spin_lock(&swap_lock);
+				spin_lock(&si->lock);
 				offset -= SWAPFILE_CLUSTER - 1;
 				si->cluster_next = offset;
 				si->cluster_nr = SWAPFILE_CLUSTER - 1;
@@ -277,7 +279,7 @@ static unsigned long scan_swap_map(struc
 		}
 
 		offset = scan_base;
-		spin_lock(&swap_lock);
+		spin_lock(&si->lock);
 		si->cluster_nr = SWAPFILE_CLUSTER - 1;
 		si->lowest_alloc = 0;
 	}
@@ -293,9 +295,9 @@ checks:
 	/* reuse swap entry of cache-only swap if not busy. */
 	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
 		int swap_was_freed;
-		spin_unlock(&swap_lock);
+		spin_unlock(&si->lock);
 		swap_was_freed = __try_to_reclaim_swap(si, offset);
-		spin_lock(&swap_lock);
+		spin_lock(&si->lock);
 		/* entry was freed successfully, try to use this again */
 		if (swap_was_freed)
 			goto checks;
@@ -335,13 +337,13 @@ checks:
 			    si->lowest_alloc <= last_in_cluster)
 				last_in_cluster = si->lowest_alloc - 1;
 			si->flags |= SWP_DISCARDING;
-			spin_unlock(&swap_lock);
+			spin_unlock(&si->lock);
 
 			if (offset < last_in_cluster)
 				discard_swap_cluster(si, offset,
 					last_in_cluster - offset + 1);
 
-			spin_lock(&swap_lock);
+			spin_lock(&si->lock);
 			si->lowest_alloc = 0;
 			si->flags &= ~SWP_DISCARDING;
 
@@ -355,10 +357,10 @@ checks:
 			 * could defer that delay until swap_writepage,
 			 * but it's easier to keep this self-contained.
 			 */
-			spin_unlock(&swap_lock);
+			spin_unlock(&si->lock);
 			wait_on_bit(&si->flags, ilog2(SWP_DISCARDING),
 				wait_for_discard, TASK_UNINTERRUPTIBLE);
-			spin_lock(&swap_lock);
+			spin_lock(&si->lock);
 		} else {
 			/*
 			 * Note pages allocated by racing tasks while
@@ -374,14 +376,14 @@ checks:
 	return offset;
 
 scan:
-	spin_unlock(&swap_lock);
+	spin_unlock(&si->lock);
 	while (++offset <= si->highest_bit) {
 		if (!si->swap_map[offset]) {
-			spin_lock(&swap_lock);
+			spin_lock(&si->lock);
 			goto checks;
 		}
 		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
-			spin_lock(&swap_lock);
+			spin_lock(&si->lock);
 			goto checks;
 		}
 		if (unlikely(--latency_ration < 0)) {
@@ -392,11 +394,11 @@ scan:
 	offset = si->lowest_bit;
 	while (++offset < scan_base) {
 		if (!si->swap_map[offset]) {
-			spin_lock(&swap_lock);
+			spin_lock(&si->lock);
 			goto checks;
 		}
 		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
-			spin_lock(&swap_lock);
+			spin_lock(&si->lock);
 			goto checks;
 		}
 		if (unlikely(--latency_ration < 0)) {
@@ -404,7 +406,7 @@ scan:
 			latency_ration = LATENCY_LIMIT;
 		}
 	}
-	spin_lock(&swap_lock);
+	spin_lock(&si->lock);
 
 no_page:
 	si->flags -= SWP_SCANNING;
@@ -417,13 +419,31 @@ swp_entry_t get_swap_page(void)
 	pgoff_t offset;
 	int type, next;
 	int wrapped = 0;
+	int hp_index;
 
 	spin_lock(&swap_lock);
-	if (nr_swap_pages <= 0)
+	if (atomic_long_read(&nr_swap_pages) <= 0)
 		goto noswap;
-	nr_swap_pages--;
+	atomic_long_dec(&nr_swap_pages);
 
 	for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
+		hp_index = atomic_xchg(&highest_priority_index, -1);
+		/*
+		 * highest_priority_index isn't protected by swap_lock, so it
+		 * can be an invalid value if the corresponding swap is
+		 * swapoff. We double check the flags here. It's even possible
+		 * the swap is swapoff and swapon again and its priority is
+		 * changed. In such rare case, low prority swap might be used,
+		 * but eventually high priority swap will be used after several
+		 * rounds of swap.
+		 */
+		if (hp_index != -1 && hp_index != type &&
+		    swap_info[type]->prio < swap_info[hp_index]->prio &&
+		    (swap_info[hp_index]->flags & SWP_WRITEOK)) {
+			type = hp_index;
+			swap_list.next = type;
+		}
+
 		si = swap_info[type];
 		next = si->next;
 		if (next < 0 ||
@@ -432,22 +452,30 @@ swp_entry_t get_swap_page(void)
 			wrapped++;
 		}
 
-		if (!si->highest_bit)
+		spin_lock(&si->lock);
+		if (!si->highest_bit) {
+			spin_unlock(&si->lock);
 			continue;
-		if (!(si->flags & SWP_WRITEOK))
+		}
+		if (!(si->flags & SWP_WRITEOK)) {
+			spin_unlock(&si->lock);
 			continue;
+		}
 
 		swap_list.next = next;
+
+		spin_unlock(&swap_lock);
 		/* This is called for allocating swap entry for cache */
 		offset = scan_swap_map(si, SWAP_HAS_CACHE);
 		if (offset) {
-			spin_unlock(&swap_lock);
+			spin_unlock(&si->lock);
 			return swp_entry(type, offset);
 		}
+		spin_lock(&swap_lock);
 		next = swap_list.next;
 	}
 
-	nr_swap_pages++;
+	atomic_long_inc(&nr_swap_pages);
 noswap:
 	spin_unlock(&swap_lock);
 	return (swp_entry_t) {0};
@@ -459,19 +487,19 @@ swp_entry_t get_swap_page_of_type(int ty
 	struct swap_info_struct *si;
 	pgoff_t offset;
 
-	spin_lock(&swap_lock);
 	si = swap_info[type];
+	spin_lock(&si->lock);
 	if (si && (si->flags & SWP_WRITEOK)) {
-		nr_swap_pages--;
+		atomic_long_dec(&nr_swap_pages);
 		/* This is called for allocating swap entry, not cache */
 		offset = scan_swap_map(si, 1);
 		if (offset) {
-			spin_unlock(&swap_lock);
+			spin_unlock(&si->lock);
 			return swp_entry(type, offset);
 		}
-		nr_swap_pages++;
+		atomic_long_inc(&nr_swap_pages);
 	}
-	spin_unlock(&swap_lock);
+	spin_unlock(&si->lock);
 	return (swp_entry_t) {0};
 }
 
@@ -493,7 +521,7 @@ static struct swap_info_struct *swap_inf
 		goto bad_offset;
 	if (!p->swap_map[offset])
 		goto bad_free;
-	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
 	return p;
 
 bad_free:
@@ -511,6 +539,20 @@ out:
 	return NULL;
 }
 
+static void set_highest_priority_index(int type)
+{
+	int old_hp_index, new_hp_index;
+
+	do {
+		old_hp_index = atomic_read(&highest_priority_index);
+		if (old_hp_index != -1 &&
+			swap_info[old_hp_index]->prio >= swap_info[type]->prio)
+			break;
+		new_hp_index = type;
+	} while (atomic_cmpxchg(&highest_priority_index,
+		old_hp_index, new_hp_index) != old_hp_index);
+}
+
 static unsigned char swap_entry_free(struct swap_info_struct *p,
 				     swp_entry_t entry, unsigned char usage)
 {
@@ -553,10 +595,8 @@ static unsigned char swap_entry_free(str
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
 			p->highest_bit = offset;
-		if (swap_list.next >= 0 &&
-		    p->prio > swap_info[swap_list.next]->prio)
-			swap_list.next = p->type;
-		nr_swap_pages++;
+		set_highest_priority_index(p->type);
+		atomic_long_inc(&nr_swap_pages);
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
 		if (p->flags & SWP_BLKDEV) {
@@ -581,7 +621,7 @@ void swap_free(swp_entry_t entry)
 	p = swap_info_get(entry);
 	if (p) {
 		swap_entry_free(p, entry, 1);
-		spin_unlock(&swap_lock);
+		spin_unlock(&p->lock);
 	}
 }
 
@@ -598,7 +638,7 @@ void swapcache_free(swp_entry_t entry, s
 		count = swap_entry_free(p, entry, SWAP_HAS_CACHE);
 		if (page)
 			mem_cgroup_uncharge_swapcache(page, entry, count != 0);
-		spin_unlock(&swap_lock);
+		spin_unlock(&p->lock);
 	}
 }
 
@@ -617,7 +657,7 @@ int page_swapcount(struct page *page)
 	p = swap_info_get(entry);
 	if (p) {
 		count = swap_count(p->swap_map[swp_offset(entry)]);
-		spin_unlock(&swap_lock);
+		spin_unlock(&p->lock);
 	}
 	return count;
 }
@@ -706,7 +746,7 @@ int free_swap_and_cache(swp_entry_t entr
 				page = NULL;
 			}
 		}
-		spin_unlock(&swap_lock);
+		spin_unlock(&p->lock);
 	}
 	if (page) {
 		/*
@@ -804,11 +844,13 @@ unsigned int count_swap_pages(int type,
 	if ((unsigned int)type < nr_swapfiles) {
 		struct swap_info_struct *sis = swap_info[type];
 
+		spin_lock(&sis->lock);
 		if (sis->flags & SWP_WRITEOK) {
 			n = sis->pages;
 			if (free)
 				n -= sis->inuse_pages;
 		}
+		spin_unlock(&sis->lock);
 	}
 	spin_unlock(&swap_lock);
 	return n;
@@ -1451,6 +1493,7 @@ static void enable_swap_info(struct swap
 	int i, prev;
 
 	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
 	if (prio >= 0)
 		p->prio = prio;
 	else
@@ -1458,7 +1501,7 @@ static void enable_swap_info(struct swap
 	p->swap_map = swap_map;
 	frontswap_map_set(p, frontswap_map);
 	p->flags |= SWP_WRITEOK;
-	nr_swap_pages += p->pages;
+	atomic_long_add(p->pages, &nr_swap_pages);
 	total_swap_pages += p->pages;
 
 	/* insert swap space into swap_list: */
@@ -1474,6 +1517,7 @@ static void enable_swap_info(struct swap
 	else
 		swap_info[prev]->next = p->type;
 	frontswap_init(p->type);
+	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
 
@@ -1534,14 +1578,16 @@ SYSCALL_DEFINE1(swapoff, const char __us
 		/* just pick something that's safe... */
 		swap_list.next = swap_list.head;
 	}
+	spin_lock(&p->lock);
 	if (p->prio < 0) {
 		for (i = p->next; i >= 0; i = swap_info[i]->next)
 			swap_info[i]->prio = p->prio--;
 		least_priority++;
 	}
-	nr_swap_pages -= p->pages;
+	atomic_long_sub(p->pages, &nr_swap_pages);
 	total_swap_pages -= p->pages;
 	p->flags &= ~SWP_WRITEOK;
+	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 
 	oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
@@ -1566,14 +1612,17 @@ SYSCALL_DEFINE1(swapoff, const char __us
 
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
 	drain_mmlist();
 
 	/* wait for anyone still in scan_swap_map */
 	p->highest_bit = 0;		/* cuts scans short */
 	while (p->flags >= SWP_SCANNING) {
+		spin_unlock(&p->lock);
 		spin_unlock(&swap_lock);
 		schedule_timeout_uninterruptible(1);
 		spin_lock(&swap_lock);
+		spin_lock(&p->lock);
 	}
 
 	swap_file = p->swap_file;
@@ -1583,6 +1632,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	p->swap_map = NULL;
 	p->flags = 0;
 	frontswap_invalidate_area(type);
+	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
@@ -2110,7 +2160,7 @@ void si_swapinfo(struct sysinfo *val)
 		if ((si->flags & SWP_USED) && !(si->flags & SWP_WRITEOK))
 			nr_to_be_unused += si->inuse_pages;
 	}
-	val->freeswap = nr_swap_pages + nr_to_be_unused;
+	val->freeswap = atomic_long_read(&nr_swap_pages) + nr_to_be_unused;
 	val->totalswap = total_swap_pages + nr_to_be_unused;
 	spin_unlock(&swap_lock);
 }
@@ -2143,7 +2193,7 @@ static int __swap_duplicate(swp_entry_t
 	p = swap_info[type];
 	offset = swp_offset(entry);
 
-	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
 	if (unlikely(offset >= p->max))
 		goto unlock_out;
 
@@ -2178,7 +2228,7 @@ static int __swap_duplicate(swp_entry_t
 	p->swap_map[offset] = count | has_cache;
 
 unlock_out:
-	spin_unlock(&swap_lock);
+	spin_unlock(&p->lock);
 out:
 	return err;
 
@@ -2303,7 +2353,7 @@ int add_swap_count_continuation(swp_entr
 	}
 
 	if (!page) {
-		spin_unlock(&swap_lock);
+		spin_unlock(&si->lock);
 		return -ENOMEM;
 	}
 
@@ -2351,7 +2401,7 @@ int add_swap_count_continuation(swp_entr
 	list_add_tail(&page->lru, &head->lru);
 	page = NULL;			/* now it's attached, don't free it */
 out:
-	spin_unlock(&swap_lock);
+	spin_unlock(&si->lock);
 outer:
 	if (page)
 		__free_page(page);
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2012-12-10 08:51:31.057803500 +0800
+++ linux/mm/vmscan.c	2012-12-10 09:02:56.101191464 +0800
@@ -1664,7 +1664,7 @@ static void get_scan_count(struct lruvec
 		force_scan = true;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (nr_swap_pages <= 0)) {
+	if (!sc->may_swap || (atomic_long_read(&nr_swap_pages) <= 0)) {
 		noswap = 1;
 		fraction[0] = 0;
 		fraction[1] = 1;
@@ -1808,7 +1808,7 @@ static inline bool should_continue_recla
 	 */
 	pages_for_compaction = (2UL << sc->order);
 	inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
-	if (nr_swap_pages > 0)
+	if (atomic_long_read(&nr_swap_pages) > 0)
 		inactive_lru_pages += get_lru_size(lruvec, LRU_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
@@ -3044,7 +3044,7 @@ unsigned long global_reclaimable_pages(v
 	nr = global_page_state(NR_ACTIVE_FILE) +
 	     global_page_state(NR_INACTIVE_FILE);
 
-	if (nr_swap_pages > 0)
+	if (atomic_long_read(&nr_swap_pages) > 0)
 		nr += global_page_state(NR_ACTIVE_ANON) +
 		      global_page_state(NR_INACTIVE_ANON);
 
@@ -3058,7 +3058,7 @@ unsigned long zone_reclaimable_pages(str
 	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
 	     zone_page_state(zone, NR_INACTIVE_FILE);
 
-	if (nr_swap_pages > 0)
+	if (atomic_long_read(&nr_swap_pages) > 0)
 		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
 		      zone_page_state(zone, NR_INACTIVE_ANON);
 
Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2012-12-10 08:51:21.557922930 +0800
+++ linux/mm/mmap.c	2012-12-10 09:02:56.101191464 +0800
@@ -128,7 +128,7 @@ int __vm_enough_memory(struct mm_struct
 		 */
 		free -= global_page_state(NR_SHMEM);
 
-		free += nr_swap_pages;
+		free += atomic_long_read(&nr_swap_pages);
 
 		/*
 		 * Any slabs which are created with the
Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2012-12-10 09:02:45.037330401 +0800
+++ linux/mm/swap_state.c	2012-12-10 09:02:56.101191464 +0800
@@ -69,7 +69,8 @@ void show_swap_cache_info(void)
 	printk("Swap cache stats: add %lu, delete %lu, find %lu/%lu\n",
 		swap_cache_info.add_total, swap_cache_info.del_total,
 		swap_cache_info.find_success, swap_cache_info.find_total);
-	printk("Free swap  = %ldkB\n", nr_swap_pages << (PAGE_SHIFT - 10));
+	printk("Free swap  = %ldkB\n",
+		atomic_long_read(&nr_swap_pages) << (PAGE_SHIFT - 10));
 	printk("Total swap = %lukB\n", total_swap_pages << (PAGE_SHIFT - 10));
 }
 
Index: linux/drivers/staging/zcache/zcache-main.c
===================================================================
--- linux.orig/drivers/staging/zcache/zcache-main.c	2012-12-10 08:51:21.589922528 +0800
+++ linux/drivers/staging/zcache/zcache-main.c	2012-12-10 09:18:52.061173456 +0800
@@ -927,8 +927,8 @@ static struct kobj_attribute zcache_zv_p
  */
 
 /* useful stats not collected by cleancache or frontswap */
-static unsigned long zcache_flush_total;
-static unsigned long zcache_flush_found;
+static atomic_long_t zcache_flush_total;
+static atomic_long_t zcache_flush_found;
 static unsigned long zcache_flobj_total;
 static unsigned long zcache_flobj_found;
 static unsigned long zcache_failed_eph_puts;
@@ -1428,6 +1428,17 @@ static struct notifier_block zcache_cpu_
 		.show = zcache_##_name##_show, \
 	}
 
+#define ZCACHE_SYSFS_RO_ATOMIC_LONG(_name) \
+	static ssize_t zcache_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+	    return sprintf(buf, "%lu\n", atomic_long_read(&zcache_##_name)); \
+	} \
+	static struct kobj_attribute zcache_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = zcache_##_name##_show, \
+	}
+
 #define ZCACHE_SYSFS_RO_CUSTOM(_name, _func) \
 	static ssize_t zcache_##_name##_show(struct kobject *kobj, \
 				struct kobj_attribute *attr, char *buf) \
@@ -1441,8 +1452,8 @@ static struct notifier_block zcache_cpu_
 
 ZCACHE_SYSFS_RO(curr_obj_count_max);
 ZCACHE_SYSFS_RO(curr_objnode_count_max);
-ZCACHE_SYSFS_RO(flush_total);
-ZCACHE_SYSFS_RO(flush_found);
+ZCACHE_SYSFS_RO_ATOMIC_LONG(flush_total);
+ZCACHE_SYSFS_RO_ATOMIC_LONG(flush_found);
 ZCACHE_SYSFS_RO(flobj_total);
 ZCACHE_SYSFS_RO(flobj_found);
 ZCACHE_SYSFS_RO(failed_eph_puts);
@@ -1614,7 +1625,7 @@ static int zcache_flush_page(int cli_id,
 	unsigned long flags;
 
 	local_irq_save(flags);
-	zcache_flush_total++;
+	atomic_long_inc(&zcache_flush_total);
 	pool = zcache_get_pool_by_id(cli_id, pool_id);
 	if (likely(pool != NULL)) {
 		if (atomic_read(&pool->obj_count) > 0)
@@ -1622,7 +1633,7 @@ static int zcache_flush_page(int cli_id,
 		zcache_put_pool(pool);
 	}
 	if (ret >= 0)
-		zcache_flush_found++;
+		atomic_long_inc(&zcache_flush_found);
 	local_irq_restore(flags);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
