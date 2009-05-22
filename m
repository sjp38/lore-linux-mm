Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2D6CF6B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 04:02:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4M82grl023162
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 May 2009 17:02:42 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A04E45DD79
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:02:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 211BC45DD75
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:02:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A19111DB8013
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:02:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E38D1DB8019
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:02:40 +0900 (JST)
Date: Fri, 22 May 2009 17:01:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/3] add SWAP_HAS_CACHE flag to swapmap.
Message-Id: <20090522170107.e2b8ed4d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090522165730.8791c2dd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090522165730.8791c2dd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Now, in reference counting at swap_map, there are 2 kinds of references.
 - reference from SwapCache.
 - reference from swap entry

Then, to find the swap_entry can be freed or not, following code is used.

  check swap's refcount == 1.
  find_get_page(swapper_space) -> NULL means there isn't any other reference.

On the other hand, swap-in code does following ops.

  swap_dupcate()
         ---------(*)
  add_to_swap()

Obviously, above (*) is race window. But even if above occurs, global LRU
will finally reclaim the page when memory shrlinking code runs.

It has been no problem ..but...when memcg used, this control of swap
reference is one of reason for leaking account information.
(You can say memcg desgin is bad but, IIUC, swap-cache itself includes
 tons of loose operations. It makes situation difficult.)
 
This patch modifies swap_map's reference counting
from
  SWAP_MAP_MAX=7fff
  SWAP_MAP_BAD=8000  (from Linux 2.4 age)
to
  SWAP_MAP_MAX=0x7ffe
  SWAP_MAP_BAD=0x7fff
and adds a bit of
  SWAP_HAS_CACHE=0x8000
to indicates that there is SwapCache.

This patch adds following new functions.
 - swapcache_prepare()  - called at swapin_readahead()
 - swapcache_free()     - called at freeing swp_entry for swapcache.

A fix for memcg will follow this.

Changelog: v1->v2.
 - modifed logic to use 0x8000 bit.
 - don't add new arguments to usual functions.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/swap.h |   12 ++-
 mm/shmem.c           |    2 
 mm/swap_state.c      |   15 ++-
 mm/swapfile.c        |  192 ++++++++++++++++++++++++++++++++++++++-------------
 mm/vmscan.c          |    2 
 5 files changed, 164 insertions(+), 59 deletions(-)

Index: mmotm-2.6.30-May17/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May17.orig/include/linux/swap.h
+++ mmotm-2.6.30-May17/include/linux/swap.h
@@ -129,8 +129,10 @@ enum {
 
 #define SWAP_CLUSTER_MAX 32
 
-#define SWAP_MAP_MAX	0x7fff
-#define SWAP_MAP_BAD	0x8000
+#define SWAP_MAP_MAX	0x7ffe
+#define SWAP_HAS_CACHE	0x8000
+#define SWAP_MAP_BAD	0x7fff
+#define SWAP_MAP_MASK	0x7fff
 
 /*
  * The in-memory structure used to track swap areas.
@@ -303,6 +305,8 @@ extern swp_entry_t get_swap_page_of_type
 extern int swap_duplicate(swp_entry_t);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t);
+extern void swapcache_free(swp_entry_t);
+extern int swapcache_prepare(swp_entry_t);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
@@ -376,6 +380,10 @@ static inline void swap_free(swp_entry_t
 {
 }
 
+static inline void swapcache_free(swp_entry_t swp)
+{
+}
+
 static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
Index: mmotm-2.6.30-May17/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swapfile.c
+++ mmotm-2.6.30-May17/mm/swapfile.c
@@ -60,6 +60,11 @@ static DEFINE_MUTEX(swapon_mutex);
  */
 static DECLARE_RWSEM(swap_unplug_sem);
 
+static inline int swap_has_ref(unsigned short count)
+{
+	return count & SWAP_MAP_MASK;
+}
+
 void swap_unplug_io_fn(struct backing_dev_info *unused_bdi, struct page *page)
 {
 	swp_entry_t entry;
@@ -167,7 +172,8 @@ static int wait_for_discard(void *word)
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
-static inline unsigned long scan_swap_map(struct swap_info_struct *si)
+static inline unsigned long
+scan_swap_map(struct swap_info_struct *si, int cache)
 {
 	unsigned long offset;
 	unsigned long scan_base;
@@ -285,7 +291,11 @@ checks:
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
 	}
-	si->swap_map[offset] = 1;
+	if (cache)
+		si->swap_map[offset] = SWAP_HAS_CACHE; /* via get_swap_page() */
+	else
+		si->swap_map[offset] = 1; /* via alloc_swap_block()  */
+
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
@@ -373,7 +383,11 @@ no_page:
 	si->flags -= SWP_SCANNING;
 	return 0;
 }
-
+/*
+ * Allocate swap entry and set SWAP_HAS_CACHE flag. Following logic after
+ * this functions should call add_to_swap_cache(). In general, when a swap
+ * entry is allocated, there is a page to be written out.
+ */
 swp_entry_t get_swap_page(void)
 {
 	struct swap_info_struct *si;
@@ -401,7 +415,7 @@ swp_entry_t get_swap_page(void)
 			continue;
 
 		swap_list.next = next;
-		offset = scan_swap_map(si);
+		offset = scan_swap_map(si, 1);
 		if (offset) {
 			spin_unlock(&swap_lock);
 			return swp_entry(type, offset);
@@ -415,6 +429,10 @@ noswap:
 	return (swp_entry_t) {0};
 }
 
+/*
+ * Allocate swap entry with swap's refcnt = 1. Not for allocating swap cache
+ * Used by kernel/power/....via alloc_swapdev_block().
+ */
 swp_entry_t get_swap_page_of_type(int type)
 {
 	struct swap_info_struct *si;
@@ -424,7 +442,7 @@ swp_entry_t get_swap_page_of_type(int ty
 	si = swap_info + type;
 	if (si->flags & SWP_WRITEOK) {
 		nr_swap_pages--;
-		offset = scan_swap_map(si);
+		offset = scan_swap_map(si, 0);
 		if (offset) {
 			spin_unlock(&swap_lock);
 			return swp_entry(type, offset);
@@ -470,26 +488,40 @@ bad_nofile:
 out:
 	return NULL;
 }
-
-static int swap_entry_free(struct swap_info_struct *p, swp_entry_t ent)
+/*
+ * Returns remaining refcnt for swap reference. A flag bit SWAP_HAS_CACHE
+ * is retuned, too. Then, if (return value == SWAP_HAS_CACHE), it's time to
+ * delete swap cache.
+ */
+static int swap_entry_free(struct swap_info_struct *p,
+			   swp_entry_t ent,
+			   int cache)
 {
 	unsigned long offset = swp_offset(ent);
 	int count = p->swap_map[offset];
 
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
+	if (!cache) {
+		if ((count & SWAP_MAP_MASK) >= SWAP_MAP_MAX)
+			return SWAP_MAP_BAD;
+		VM_BUG_ON(!(count & SWAP_MAP_MASK));
+		count -= 1;
+	} else {
+		/* Even if SWAP_MAP_BAD, we can drop swap cache. */
+		VM_BUG_ON(!(count & SWAP_HAS_CACHE));
+		count &= SWAP_MAP_MASK; /* Drops SWAP_HAS_CACHE bit */
+	}
+
+	p->swap_map[offset] = count;
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
@@ -504,7 +536,19 @@ void swap_free(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, entry);
+		swap_entry_free(p, entry, 0);
+		spin_unlock(&swap_lock);
+	}
+}
+
+/* called at freeing swap cache */
+void swapcache_free(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+
+	p = swap_info_get(entry);
+	if (p) {
+		swap_entry_free(p, entry, 1);
 		spin_unlock(&swap_lock);
 	}
 }
@@ -521,8 +565,8 @@ static inline int page_swapcount(struct 
 	entry.val = page_private(page);
 	p = swap_info_get(entry);
 	if (p) {
-		/* Subtract the 1 for the swap cache itself */
-		count = p->swap_map[swp_offset(entry)] - 1;
+		/* Ignore reference from swap cache. */
+		count = p->swap_map[swp_offset(entry)] & SWAP_MAP_MASK;
 		spin_unlock(&swap_lock);
 	}
 	return count;
@@ -584,7 +628,7 @@ int free_swap_and_cache(swp_entry_t entr
 
 	p = swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, entry) == 1) {
+		if (swap_entry_free(p, entry, 0) == SWAP_HAS_CACHE) {
 			page = find_get_page(&swapper_space, entry.val);
 			if (page && !trylock_page(page)) {
 				page_cache_release(page);
@@ -891,12 +935,13 @@ static unsigned int find_next_to_unuse(s
 			i = 1;
 		}
 		count = si->swap_map[i];
-		if (count && count != SWAP_MAP_BAD)
+		if (count && ((count & SWAP_MAP_MASK) != SWAP_MAP_BAD))
 			break;
 	}
 	return i;
 }
 
+
 /*
  * We completely avoid races by reading each swap page in advance,
  * and then search for the process using it.  All the necessary
@@ -995,13 +1040,13 @@ static int try_to_unuse(unsigned int typ
 		 */
 		shmem = 0;
 		swcount = *swap_map;
-		if (swcount > 1) {
+		if (swap_has_ref(swcount)) {
 			if (start_mm == &init_mm)
 				shmem = shmem_unuse(entry, page);
 			else
 				retval = unuse_mm(start_mm, entry, page);
 		}
-		if (*swap_map > 1) {
+		if (swap_has_ref(*swap_map)) {
 			int set_start_mm = (*swap_map >= swcount);
 			struct list_head *p = &start_mm->mmlist;
 			struct mm_struct *new_start_mm = start_mm;
@@ -1011,7 +1056,7 @@ static int try_to_unuse(unsigned int typ
 			atomic_inc(&new_start_mm->mm_users);
 			atomic_inc(&prev_mm->mm_users);
 			spin_lock(&mmlist_lock);
-			while (*swap_map > 1 && !retval && !shmem &&
+			while (swap_has_ref(*swap_map) && !retval && !shmem &&
 					(p = p->next) != &start_mm->mmlist) {
 				mm = list_entry(p, struct mm_struct, mmlist);
 				if (!atomic_inc_not_zero(&mm->mm_users))
@@ -1057,11 +1102,11 @@ static int try_to_unuse(unsigned int typ
 		}
 
 		/*
-		 * How could swap count reach 0x7fff when the maximum
-		 * pid is 0x7fff, and there's no way to repeat a swap
-		 * page within an mm (except in shmem, where it's the
-		 * shared object which takes the reference count)?
-		 * We believe SWAP_MAP_MAX cannot occur in Linux 2.4.
+		 * How could swap count reach 0x7ffe ? there's no way to
+		 * repeat a swap page within an mm (except in shmem,
+		 * where it's the shared object which takes the reference
+		 * count)?
+		 * We believe SWAP_MAP_MAX cannot occur in the most case..
 		 *
 		 * If that's wrong, then we should worry more about
 		 * exit_mmap() and do_munmap() cases described above:
@@ -1069,9 +1114,10 @@ static int try_to_unuse(unsigned int typ
 		 * We know "Undead"s can happen, they're okay, so don't
 		 * report them; but do report if we reset SWAP_MAP_MAX.
 		 */
-		if (*swap_map == SWAP_MAP_MAX) {
+		if ((*swap_map & SWAP_MAP_MASK) == SWAP_MAP_MAX) {
 			spin_lock(&swap_lock);
-			*swap_map = 1;
+			/* just remember we have cache...*/
+			*swap_map = SWAP_HAS_CACHE;
 			spin_unlock(&swap_lock);
 			reset_overflow = 1;
 		}
@@ -1089,7 +1135,8 @@ static int try_to_unuse(unsigned int typ
 		 * pages would be incorrect if swap supported "shared
 		 * private" pages, but they are handled by tmpfs files.
 		 */
-		if ((*swap_map > 1) && PageDirty(page) && PageSwapCache(page)) {
+		if (swap_has_ref(*swap_map) &&
+		    PageDirty(page) && PageSwapCache(page)) {
 			struct writeback_control wbc = {
 				.sync_mode = WB_SYNC_NONE,
 			};
@@ -1942,12 +1989,16 @@ void si_swapinfo(struct sysinfo *val)
  *
  * Note: if swap_map[] reaches SWAP_MAP_MAX the entries are treated as
  * "permanent", but will be reclaimed by the next swapoff.
+ *
+ * Returns 1 at success but this operation should never fails under usual
+ * conditions. If swap_duplicate() is called against freed entry, it's bug.
+ * (there may be swap cache but we ignore it.)
  */
 int swap_duplicate(swp_entry_t entry)
 {
 	struct swap_info_struct * p;
 	unsigned long offset, type;
-	int result = 0;
+	int count, result = 0;
 
 	if (is_migration_entry(entry))
 		return 1;
@@ -1959,17 +2010,21 @@ int swap_duplicate(swp_entry_t entry)
 	offset = swp_offset(entry);
 
 	spin_lock(&swap_lock);
-	if (offset < p->max && p->swap_map[offset]) {
-		if (p->swap_map[offset] < SWAP_MAP_MAX - 1) {
-			p->swap_map[offset]++;
-			result = 1;
-		} else if (p->swap_map[offset] <= SWAP_MAP_MAX) {
-			if (swap_overflow++ < 5)
-				printk(KERN_WARNING "swap_dup: swap entry overflow\n");
-			p->swap_map[offset] = SWAP_MAP_MAX;
-			result = 1;
-		}
+	if (offset >= p->max)
+		goto out_unlock;
+
+	count = p->swap_map[offset] & SWAP_MAP_MASK;
+	if (count < SWAP_MAP_MAX - 1) {
+		p->swap_map[offset] += 1;
+		result = 1;
+	} else if (count <= SWAP_MAP_MAX) {
+		if (swap_overflow++ < 5)
+			printk(KERN_WARNING "swap_dup: swap entry overflow\n");
+		/* don't overwrite SWAP_HAS_CACHE flag */
+		p->swap_map[offset] |= SWAP_MAP_MAX;
+		result = 1;
 	}
+out_unlock:
 	spin_unlock(&swap_lock);
 out:
 	return result;
@@ -1979,6 +2034,47 @@ bad_file:
 	goto out;
 }
 
+/*
+ * return only when there is no swapcache.
+ * difference from find_get_page(&swapper_space,...) is that find_get_page()
+ * cannot catch entries whic is now being added/deleted.
+ *
+ * Returns 0 if swap ifself is freed.
+ * Returns 1 if there is swap cache
+ * Returns -EAGAIN if swap cache operation is under racy condition.
+ */
+
+int swapcache_prepare(swp_entry_t entry)
+{
+	struct swap_info_struct * p;
+	unsigned long offset, type;
+	int result = 0;
+
+	VM_BUG_ON(is_migration_entry(entry));
+
+	type = swp_type(entry);
+	if (type >= nr_swapfiles)
+		goto bad_file;
+	p = type + swap_info;
+	offset = swp_offset(entry);
+
+	spin_lock(&swap_lock);
+	if (offset < p->max && p->swap_map[offset]) {
+		if (!(p->swap_map[offset] & SWAP_HAS_CACHE)) {
+			p->swap_map[offset] |= SWAP_HAS_CACHE;
+			result = 1;
+		} else
+			result = -EAGAIN;
+	}
+	spin_unlock(&swap_lock);
+out:
+	return result;
+bad_file:
+	printk(KERN_ERR "swapcache_prepare: %s%08lx\n", Bad_file, entry.val);
+	goto out;
+}
+
+
 struct swap_info_struct *
 get_swap_info_struct(unsigned type)
 {
Index: mmotm-2.6.30-May17/mm/swap_state.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swap_state.c
+++ mmotm-2.6.30-May17/mm/swap_state.c
@@ -162,11 +162,11 @@ int add_to_swap(struct page *page)
 			return 1;
 		case -EEXIST:
 			/* Raced with "speculative" read_swap_cache_async */
-			swap_free(entry);
+			swapcache_free(entry);
 			continue;
 		default:
 			/* -ENOMEM radix-tree allocation failure */
-			swap_free(entry);
+			swapcache_free(entry);
 			return 0;
 		}
 	}
@@ -188,8 +188,7 @@ void delete_from_swap_cache(struct page 
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&swapper_space.tree_lock);
 
-	mem_cgroup_uncharge_swapcache(page, entry);
-	swap_free(entry);
+	swapcache_free(entry);
 	page_cache_release(page);
 }
 
@@ -293,9 +292,11 @@ struct page *read_swap_cache_async(swp_e
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */
-		if (!swap_duplicate(entry))
+		err = swapcache_prepare(entry);
+		if (!err) /* this swap is freed */
 			break;
-
+		if (err == -EAGAIN)/* race with other swap ops, retry. */
+			continue;
 		/*
 		 * Associate the page with swap entry in the swap cache.
 		 * May fail (-EEXIST) if there is already a page associated
@@ -317,7 +318,7 @@ struct page *read_swap_cache_async(swp_e
 		}
 		ClearPageSwapBacked(new_page);
 		__clear_page_locked(new_page);
-		swap_free(entry);
+		swapcache_free(entry);
 	} while (err != -ENOMEM);
 
 	if (new_page)
Index: mmotm-2.6.30-May17/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/vmscan.c
+++ mmotm-2.6.30-May17/mm/vmscan.c
@@ -478,7 +478,7 @@ static int __remove_mapping(struct addre
 		__delete_from_swap_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_swapcache(page, swap);
-		swap_free(swap);
+		swapcache_free(swap);
 	} else {
 		__remove_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
Index: mmotm-2.6.30-May17/mm/shmem.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/shmem.c
+++ mmotm-2.6.30-May17/mm/shmem.c
@@ -1097,7 +1097,7 @@ static int shmem_writepage(struct page *
 	shmem_swp_unmap(entry);
 unlock:
 	spin_unlock(&info->lock);
-	swap_free(swap);
+	swapcache_free(swap);
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
