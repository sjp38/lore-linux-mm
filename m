Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 686436B00A6
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:10:56 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n523ArGc007203
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Jun 2009 12:10:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8654E45DE4F
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:10:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D92745DD72
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:10:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6405D1DB8040
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:10:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 15B091DB803A
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:10:53 +0900 (JST)
Date: Tue, 2 Jun 2009 12:09:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/4] modify swap map and add swap has cache flag
Message-Id: <20090602120919.c45af844.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090602120425.0bcff554.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090602120425.0bcff554.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Replacement for 
 mm-modify-swap_map-and-add-swap_has_cache-flag.patch in mmotm.
Several style fix are done....maybe easier to read.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is a part of patches for fixing memcg's swap account leak. But, IMHO,
not a bad patch even if no memcg.

Now, reference to swap is counted by swap_map[], an array of unsigned short.
There are 2 kinds of references to swap.
 - reference from swap entry
 - reference from swap cache
Then, 
 - If there is swap cache && swap's refcnt is 1, there is only swap cache.
  (*) swapcount(entry) == 1 && find_get_page(swapper_space, entry) != NULL

This counting logic have worked well for a long time. But considering that
we cannot know there is a _real_ reference or not by swap_map[], current usage
of counter is not very good.

This patch adds a flag SWAP_HAS_CACHE and recorded information that a swap entry
has a cache or not. This will remove -1 magic used in swapfile.c and be a help
to avoid unnecessary find_get_page().

Changelog: v2->v3
 - modified names/types of functions and their arguments.
Changelog: v1->v2
 - fixed swapcache_prepare()'s return code.
 - changed swap_duplicate() be void function.
 - fixed racy case in swapoff().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |   14 ++-
 mm/swap_state.c      |    5 -
 mm/swapfile.c        |  216 +++++++++++++++++++++++++++++++++++++--------------
 3 files changed, 173 insertions(+), 62 deletions(-)

Index: mmotm-2.6.30-May28/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May28.orig/include/linux/swap.h
+++ mmotm-2.6.30-May28/include/linux/swap.h
@@ -129,9 +129,10 @@ enum {
 
 #define SWAP_CLUSTER_MAX 32
 
-#define SWAP_MAP_MAX	0x7fff
-#define SWAP_MAP_BAD	0x8000
-
+#define SWAP_MAP_MAX	0x7ffe
+#define SWAP_MAP_BAD	0x7fff
+#define SWAP_HAS_CACHE  0x8000		/* There is a swap cache of entry. */
+#define SWAP_COUNT_MASK (~SWAP_HAS_CACHE)
 /*
  * The in-memory structure used to track swap areas.
  */
@@ -281,7 +282,7 @@ extern long total_swap_pages;
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
-extern int swap_duplicate(swp_entry_t);
+extern void swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t);
@@ -353,9 +354,12 @@ static inline void show_swap_cache_info(
 }
 
 #define free_swap_and_cache(swp)	is_migration_entry(swp)
-#define swap_duplicate(swp)		is_migration_entry(swp)
 #define swapcache_prepare(swp)		is_migration_entry(swp)
 
+static inline void swap_duplicate(swp_entry_t swp)
+{
+}
+
 static inline void swap_free(swp_entry_t swp)
 {
 }
Index: mmotm-2.6.30-May28/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/swapfile.c
+++ mmotm-2.6.30-May28/mm/swapfile.c
@@ -53,6 +53,33 @@ static struct swap_info_struct swap_info
 
 static DEFINE_MUTEX(swapon_mutex);
 
+/* For reference count accounting in swap_map */
+/* enum for swap_map[] handling. internal use only */
+enum {
+	SWAP_MAP = 0,	/* ops for reference from swap users */
+	SWAP_CACHE,	/* ops for reference from swap cache */
+};
+
+static inline int swap_count(unsigned short ent)
+{
+	return ent & SWAP_COUNT_MASK;
+}
+
+static inline bool swap_has_cache(unsigned short ent)
+{
+	return !!(ent & SWAP_HAS_CACHE);
+}
+
+static inline unsigned short encode_swapmap(int count, bool has_cache)
+{
+	unsigned short ret = count;
+
+	if (has_cache)
+		return SWAP_HAS_CACHE | ret;
+	return ret;
+}
+
+
 /*
  * We need this because the bdev->unplug_fn can sleep and we cannot
  * hold swap_lock while calling the unplug_fn. And swap_lock
@@ -167,7 +194,8 @@ static int wait_for_discard(void *word)
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
-static inline unsigned long scan_swap_map(struct swap_info_struct *si)
+static inline unsigned long scan_swap_map(struct swap_info_struct *si,
+					  int cache)
 {
 	unsigned long offset;
 	unsigned long scan_base;
@@ -285,7 +313,10 @@ checks:
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
 	}
-	si->swap_map[offset] = 1;
+	if (cache == SWAP_CACHE) /* at usual swap-out via vmscan.c */
+		si->swap_map[offset] = encode_swapmap(0, true);
+	else /* at suspend */
+		si->swap_map[offset] = encode_swapmap(1, false);
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
@@ -401,7 +432,8 @@ swp_entry_t get_swap_page(void)
 			continue;
 
 		swap_list.next = next;
-		offset = scan_swap_map(si);
+		/* This is called for allocating swap entry for cache */
+		offset = scan_swap_map(si, SWAP_CACHE);
 		if (offset) {
 			spin_unlock(&swap_lock);
 			return swp_entry(type, offset);
@@ -415,6 +447,7 @@ noswap:
 	return (swp_entry_t) {0};
 }
 
+/* The only caller of this function is now susupend routine */
 swp_entry_t get_swap_page_of_type(int type)
 {
 	struct swap_info_struct *si;
@@ -424,7 +457,8 @@ swp_entry_t get_swap_page_of_type(int ty
 	si = swap_info + type;
 	if (si->flags & SWP_WRITEOK) {
 		nr_swap_pages--;
-		offset = scan_swap_map(si);
+		/* This is called for allocating swap entry, not cache */
+		offset = scan_swap_map(si, SWAP_MAP);
 		if (offset) {
 			spin_unlock(&swap_lock);
 			return swp_entry(type, offset);
@@ -471,25 +505,38 @@ out:
 	return NULL;
 }
 
-static int swap_entry_free(struct swap_info_struct *p, swp_entry_t ent)
+static int swap_entry_free(struct swap_info_struct *p,
+			   swp_entry_t ent, int cache)
 {
 	unsigned long offset = swp_offset(ent);
-	int count = p->swap_map[offset];
+	int count = swap_count(p->swap_map[offset]);
+	bool has_cache;
 
-	if (count < SWAP_MAP_MAX) {
-		count--;
-		p->swap_map[offset] = count;
-		if (!count) {
-			if (offset < p->lowest_bit)
-				p->lowest_bit = offset;
-			if (offset > p->highest_bit)
-				p->highest_bit = offset;
-			if (p->prio > swap_info[swap_list.next].prio)
-				swap_list.next = p - swap_info;
-			nr_swap_pages++;
-			p->inuse_pages--;
-			mem_cgroup_uncharge_swap(ent);
-		}
+	has_cache = swap_has_cache(p->swap_map[offset]);
+
+	if (cache == SWAP_MAP) { /* dropping usage count of swap */
+		if (count < SWAP_MAP_MAX) {
+			count--;
+			p->swap_map[offset] = encode_swapmap(count, has_cache);
+		}
+	} else { /* dropping swap cache flag */
+		VM_BUG_ON(!has_cache);
+		p->swap_map[offset] = encode_swapmap(count, false);
+
+	}
+	/* return code. */
+	count = p->swap_map[offset];
+	/* free if no reference */
+	if (!count) {
+		if (offset < p->lowest_bit)
+			p->lowest_bit = offset;
+		if (offset > p->highest_bit)
+			p->highest_bit = offset;
+		if (p->prio > swap_info[swap_list.next].prio)
+			swap_list.next = p - swap_info;
+		nr_swap_pages++;
+		p->inuse_pages--;
+		mem_cgroup_uncharge_swap(ent);
 	}
 	return count;
 }
@@ -504,7 +551,7 @@ void swap_free(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, entry);
+		swap_entry_free(p, entry, SWAP_MAP);
 		spin_unlock(&swap_lock);
 	}
 }
@@ -514,9 +561,16 @@ void swap_free(swp_entry_t entry)
  */
 void swapcache_free(swp_entry_t entry, struct page *page)
 {
+	struct swap_info_struct *p;
+
 	if (page)
 		mem_cgroup_uncharge_swapcache(page, entry);
-	return swap_free(entry);
+	p = swap_info_get(entry);
+	if (p) {
+		swap_entry_free(p, entry, SWAP_CACHE);
+		spin_unlock(&swap_lock);
+	}
+	return;
 }
 
 /*
@@ -531,8 +585,7 @@ static inline int page_swapcount(struct 
 	entry.val = page_private(page);
 	p = swap_info_get(entry);
 	if (p) {
-		/* Subtract the 1 for the swap cache itself */
-		count = p->swap_map[swp_offset(entry)] - 1;
+		count = swap_count(p->swap_map[swp_offset(entry)]);
 		spin_unlock(&swap_lock);
 	}
 	return count;
@@ -594,7 +647,7 @@ int free_swap_and_cache(swp_entry_t entr
 
 	p = swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, entry) == 1) {
+		if (swap_entry_free(p, entry, SWAP_MAP) == SWAP_HAS_CACHE) {
 			page = find_get_page(&swapper_space, entry.val);
 			if (page && !trylock_page(page)) {
 				page_cache_release(page);
@@ -901,7 +954,7 @@ static unsigned int find_next_to_unuse(s
 			i = 1;
 		}
 		count = si->swap_map[i];
-		if (count && count != SWAP_MAP_BAD)
+		if (count && swap_count(count) != SWAP_MAP_BAD)
 			break;
 	}
 	return i;
@@ -1005,13 +1058,13 @@ static int try_to_unuse(unsigned int typ
 		 */
 		shmem = 0;
 		swcount = *swap_map;
-		if (swcount > 1) {
+		if (swap_count(swcount)) {
 			if (start_mm == &init_mm)
 				shmem = shmem_unuse(entry, page);
 			else
 				retval = unuse_mm(start_mm, entry, page);
 		}
-		if (*swap_map > 1) {
+		if (swap_count(*swap_map)) {
 			int set_start_mm = (*swap_map >= swcount);
 			struct list_head *p = &start_mm->mmlist;
 			struct mm_struct *new_start_mm = start_mm;
@@ -1021,7 +1074,7 @@ static int try_to_unuse(unsigned int typ
 			atomic_inc(&new_start_mm->mm_users);
 			atomic_inc(&prev_mm->mm_users);
 			spin_lock(&mmlist_lock);
-			while (*swap_map > 1 && !retval && !shmem &&
+			while (swap_count(*swap_map) && !retval && !shmem &&
 					(p = p->next) != &start_mm->mmlist) {
 				mm = list_entry(p, struct mm_struct, mmlist);
 				if (!atomic_inc_not_zero(&mm->mm_users))
@@ -1033,14 +1086,16 @@ static int try_to_unuse(unsigned int typ
 				cond_resched();
 
 				swcount = *swap_map;
-				if (swcount <= 1)
+				if (!swap_count(swcount)) /* any usage ? */
 					;
 				else if (mm == &init_mm) {
 					set_start_mm = 1;
 					shmem = shmem_unuse(entry, page);
 				} else
 					retval = unuse_mm(mm, entry, page);
-				if (set_start_mm && *swap_map < swcount) {
+
+				if (set_start_mm &&
+				    swap_count(*swap_map) < swcount) {
 					mmput(new_start_mm);
 					atomic_inc(&mm->mm_users);
 					new_start_mm = mm;
@@ -1067,21 +1122,25 @@ static int try_to_unuse(unsigned int typ
 		}
 
 		/*
-		 * How could swap count reach 0x7fff when the maximum
-		 * pid is 0x7fff, and there's no way to repeat a swap
-		 * page within an mm (except in shmem, where it's the
-		 * shared object which takes the reference count)?
-		 * We believe SWAP_MAP_MAX cannot occur in Linux 2.4.
-		 *
+		 * How could swap count reach 0x7ffe ?
+		 * There's no way to repeat a swap page within an mm
+		 * (except in shmem, where it's the shared object which takes
+		 * the reference count)?
+		 * We believe SWAP_MAP_MAX cannot occur.(if occur, unsigned
+		 * short is too small....)
 		 * If that's wrong, then we should worry more about
 		 * exit_mmap() and do_munmap() cases described above:
 		 * we might be resetting SWAP_MAP_MAX too early here.
 		 * We know "Undead"s can happen, they're okay, so don't
 		 * report them; but do report if we reset SWAP_MAP_MAX.
 		 */
-		if (*swap_map == SWAP_MAP_MAX) {
+		/* We might release the lock_page() in unuse_mm(). */
+		if (!PageSwapCache(page) || page_private(page) != entry.val)
+			goto retry;
+
+		if (swap_count(*swap_map) == SWAP_MAP_MAX) {
 			spin_lock(&swap_lock);
-			*swap_map = 1;
+			*swap_map = encode_swapmap(0, true);
 			spin_unlock(&swap_lock);
 			reset_overflow = 1;
 		}
@@ -1099,7 +1158,8 @@ static int try_to_unuse(unsigned int typ
 		 * pages would be incorrect if swap supported "shared
 		 * private" pages, but they are handled by tmpfs files.
 		 */
-		if ((*swap_map > 1) && PageDirty(page) && PageSwapCache(page)) {
+		if (swap_count(*swap_map) &&
+		     PageDirty(page) && PageSwapCache(page)) {
 			struct writeback_control wbc = {
 				.sync_mode = WB_SYNC_NONE,
 			};
@@ -1126,6 +1186,7 @@ static int try_to_unuse(unsigned int typ
 		 * mark page dirty so shrink_page_list will preserve it.
 		 */
 		SetPageDirty(page);
+retry:
 		unlock_page(page);
 		page_cache_release(page);
 
@@ -1952,15 +2013,23 @@ void si_swapinfo(struct sysinfo *val)
  *
  * Note: if swap_map[] reaches SWAP_MAP_MAX the entries are treated as
  * "permanent", but will be reclaimed by the next swapoff.
+ * Returns error code in following case.
+ * - success -> 0
+ * - swp_entry is invalid -> EINVAL
+ * - swp_entry is migration entry -> EINVAL
+ * - swap-cache reference is requested but there is already one. -> EEXIST
+ * - swap-cache reference is requested but the entry is not used. -> ENOENT
  */
-int swap_duplicate(swp_entry_t entry)
+static int __swap_duplicate(swp_entry_t entry, bool cache)
 {
 	struct swap_info_struct * p;
 	unsigned long offset, type;
-	int result = 0;
+	int result = -EINVAL;
+	int count;
+	bool has_cache;
 
 	if (is_migration_entry(entry))
-		return 1;
+		return -EINVAL;
 
 	type = swp_type(entry);
 	if (type >= nr_swapfiles)
@@ -1969,17 +2038,40 @@ int swap_duplicate(swp_entry_t entry)
 	offset = swp_offset(entry);
 
 	spin_lock(&swap_lock);
-	if (offset < p->max && p->swap_map[offset]) {
-		if (p->swap_map[offset] < SWAP_MAP_MAX - 1) {
-			p->swap_map[offset]++;
-			result = 1;
-		} else if (p->swap_map[offset] <= SWAP_MAP_MAX) {
+
+	if (unlikely(offset >= p->max))
+		goto unlock_out;
+
+	count = swap_count(p->swap_map[offset]);
+	has_cache = swap_has_cache(p->swap_map[offset]);
+
+	if (cache == SWAP_CACHE) { /* called for swapcache/swapin-readahead */
+
+		/* set SWAP_HAS_CACHE if there is no cache and entry is used */
+		if (!has_cache && count) {
+			p->swap_map[offset] = encode_swapmap(count, true);
+			result = 0;
+		} else if (has_cache) /* someone added cache */
+			result = -EEXIST;
+		else if (!count) /* no users */
+			result = -ENOENT;
+
+	} else if (count || has_cache) {
+		if (count < SWAP_MAP_MAX - 1) {
+			p->swap_map[offset] = encode_swapmap(count + 1,
+							     has_cache);
+			result = 0;
+		} else if (count <= SWAP_MAP_MAX) {
 			if (swap_overflow++ < 5)
-				printk(KERN_WARNING "swap_dup: swap entry overflow\n");
-			p->swap_map[offset] = SWAP_MAP_MAX;
-			result = 1;
-		}
-	}
+				printk(KERN_WARNING
+				       "swap_dup: swap entry overflow\n");
+			p->swap_map[offset] = encode_swapmap(SWAP_MAP_MAX,
+							      has_cache);
+			result = 0;
+		}
+	} else
+		result = -ENOENT; /* unused swap entry */
+unlock_out:
 	spin_unlock(&swap_lock);
 out:
 	return result;
@@ -1988,13 +2080,25 @@ bad_file:
 	printk(KERN_ERR "swap_dup: %s%08lx\n", Bad_file, entry.val);
 	goto out;
 }
+/*
+ * increase reference count of swap entry by 1.
+ */
+void swap_duplicate(swp_entry_t entry)
+{
+	__swap_duplicate(entry, SWAP_MAP);
+}
 
 /*
+ * @entry: swap entry for which we allocate swap cache.
+ *
  * Called when allocating swap cache for exising swap entry,
+ * This can return error codes. Returns 0 at success.
+ * -EBUSY means there is a swap cache.
+ * Note: return code is different from swap_duplicate().
  */
 int swapcache_prepare(swp_entry_t entry)
 {
-	return swap_duplicate(entry);
+	return __swap_duplicate(entry, SWAP_CACHE);
 }
 
 
@@ -2035,7 +2139,7 @@ int valid_swaphandles(swp_entry_t entry,
 		/* Don't read in free or bad pages */
 		if (!si->swap_map[toff])
 			break;
-		if (si->swap_map[toff] == SWAP_MAP_BAD)
+		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
 			break;
 	}
 	/* Count contiguous allocated slots below our target */
@@ -2043,7 +2147,7 @@ int valid_swaphandles(swp_entry_t entry,
 		/* Don't read in free or bad pages */
 		if (!si->swap_map[toff])
 			break;
-		if (si->swap_map[toff] == SWAP_MAP_BAD)
+		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
 			break;
 	}
 	spin_unlock(&swap_lock);
Index: mmotm-2.6.30-May28/mm/swap_state.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/swap_state.c
+++ mmotm-2.6.30-May28/mm/swap_state.c
@@ -292,7 +292,10 @@ struct page *read_swap_cache_async(swp_e
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */
-		if (!swapcache_prepare(entry))
+		err = swapcache_prepare(entry);
+		if (err == -EEXIST) /* seems racy */
+			continue;
+		if (err)           /* swp entry is obsolete ? */
 			break;
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
