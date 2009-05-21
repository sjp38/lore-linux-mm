Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6B4606B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 03:43:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4L7iaej011546
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 May 2009 16:44:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4441945DD78
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:44:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F306045DD76
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:44:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E041B1DB801E
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:44:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 871F91DB8016
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:44:32 +0900 (JST)
Date: Thu, 21 May 2009 16:43:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/2] change swapcount handling
Message-Id: <20090521164300.af56ff42.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, there are 2types of reference to swap entry. One is reference from
page tables (and shmem, etc..) and another is SwapCache.

At freeing swap, we cannot know there is still reference or there is
just a swap cache. This changes swap entry refcnt to be
  - account by 2 at new reference (SWAP_MAP)
  - account by 1 at swap cache.   (SWAP_CACHE)

To do this, adds a new argument to swap alloc/free functions.

After this, if swap_entry_free() returns 1, it means "no reference but
swap cache" state. And this makes
  get_swap_page/swap_duplicate()->add_to_swap_cache()
to be an atomic operation. (means no confilcts in add_to_swap_cache())

Consideration:
This makes SWAP_MAX_MAP to be half. If this is bad, can't we
increase SWAP_MAX_MAP ? (makes SWAP_MAP_BAD to be 0xfff0)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h  |   20 +++++++++---
 kernel/power/swsusp.c |    6 +--
 mm/memory.c           |    4 +-
 mm/rmap.c             |    2 -
 mm/shmem.c            |   12 +++----
 mm/swap_state.c       |   14 ++++----
 mm/swapfile.c         |   81 +++++++++++++++++++++++++++++++++++---------------
 mm/vmscan.c           |    2 -
 8 files changed, 93 insertions(+), 48 deletions(-)

Index: mmotm-2.6.30-May17/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May17.orig/include/linux/swap.h
+++ mmotm-2.6.30-May17/include/linux/swap.h
@@ -129,7 +129,12 @@ enum {
 
 #define SWAP_CLUSTER_MAX 32
 
-#define SWAP_MAP_MAX	0x7fff
+/*
+ * Reference to swap is incremented by 2 when new reference comes.
+ * incremented by 1 when swap cache is newly added.
+ * This means the lowest bit of swap_map indicates there is swapcache or not.
+ */
+#define SWAP_MAP_MAX	0x7ffe
 #define SWAP_MAP_BAD	0x8000
 
 /*
@@ -298,11 +303,16 @@ extern struct page *swapin_readahead(swp
 extern long nr_swap_pages;
 extern long total_swap_pages;
 extern void si_swapinfo(struct sysinfo *);
-extern swp_entry_t get_swap_page(void);
-extern swp_entry_t get_swap_page_of_type(int);
-extern int swap_duplicate(swp_entry_t);
+extern swp_entry_t get_swap_page(int);
+extern swp_entry_t get_swap_page_of_type(int, int);
+
+enum {
+	SWAP_MAP,
+	SWAP_CACHE,
+};
+extern int swap_duplicate(swp_entry_t, int);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
-extern void swap_free(swp_entry_t);
+extern void swap_free(swp_entry_t, int);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
Index: mmotm-2.6.30-May17/mm/memory.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/memory.c
+++ mmotm-2.6.30-May17/mm/memory.c
@@ -552,7 +552,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 		if (!pte_file(pte)) {
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
-			swap_duplicate(entry);
+			swap_duplicate(entry, SWAP_MAP);
 			/* make sure dst_mm is on swapoff's mmlist. */
 			if (unlikely(list_empty(&dst_mm->mmlist))) {
 				spin_lock(&mmlist_lock);
@@ -2670,7 +2670,7 @@ static int do_swap_page(struct mm_struct
 	/* It's better to call commit-charge after rmap is established */
 	mem_cgroup_commit_charge_swapin(page, ptr);
 
-	swap_free(entry);
+	swap_free(entry, SWAP_MAP);
 	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
Index: mmotm-2.6.30-May17/mm/rmap.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/rmap.c
+++ mmotm-2.6.30-May17/mm/rmap.c
@@ -949,7 +949,7 @@ static int try_to_unmap_one(struct page 
 			 * Store the swap location in the pte.
 			 * See handle_pte_fault() ...
 			 */
-			swap_duplicate(entry);
+			swap_duplicate(entry, SWAP_MAP);
 			if (list_empty(&mm->mmlist)) {
 				spin_lock(&mmlist_lock);
 				if (list_empty(&mm->mmlist))
Index: mmotm-2.6.30-May17/mm/shmem.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/shmem.c
+++ mmotm-2.6.30-May17/mm/shmem.c
@@ -986,7 +986,7 @@ found:
 		set_page_dirty(page);
 		info->flags |= SHMEM_PAGEIN;
 		shmem_swp_set(info, ptr, 0);
-		swap_free(entry);
+		swap_free(entry, SWAP_MAP);
 		error = 1;	/* not an error, but entry was found */
 	}
 	if (ptr)
@@ -1051,7 +1051,7 @@ static int shmem_writepage(struct page *
 	 * want to check if there's a redundant swappage to be discarded.
 	 */
 	if (wbc->for_reclaim)
-		swap = get_swap_page();
+		swap = get_swap_page(SWAP_CACHE);
 	else
 		swap.val = 0;
 
@@ -1080,7 +1080,7 @@ static int shmem_writepage(struct page *
 		else
 			inode = NULL;
 		spin_unlock(&info->lock);
-		swap_duplicate(swap);
+		swap_duplicate(swap, SWAP_MAP);
 		BUG_ON(page_mapped(page));
 		page_cache_release(page);	/* pagecache ref */
 		swap_writepage(page, wbc);
@@ -1097,7 +1097,7 @@ static int shmem_writepage(struct page *
 	shmem_swp_unmap(entry);
 unlock:
 	spin_unlock(&info->lock);
-	swap_free(swap);
+	swap_free(swap, SWAP_CACHE);
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)
@@ -1325,7 +1325,7 @@ repeat:
 			flush_dcache_page(filepage);
 			SetPageUptodate(filepage);
 			set_page_dirty(filepage);
-			swap_free(swap);
+			swap_free(swap, SWAP_MAP);
 		} else if (!(error = add_to_page_cache_locked(swappage, mapping,
 					idx, GFP_NOWAIT))) {
 			info->flags |= SHMEM_PAGEIN;
@@ -1335,7 +1335,7 @@ repeat:
 			spin_unlock(&info->lock);
 			filepage = swappage;
 			set_page_dirty(filepage);
-			swap_free(swap);
+			swap_free(swap, SWAP_MAP);
 		} else {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
Index: mmotm-2.6.30-May17/mm/swap_state.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swap_state.c
+++ mmotm-2.6.30-May17/mm/swap_state.c
@@ -138,7 +138,7 @@ int add_to_swap(struct page *page)
 	VM_BUG_ON(!PageUptodate(page));
 
 	for (;;) {
-		entry = get_swap_page();
+		entry = get_swap_page(SWAP_CACHE);
 		if (!entry.val)
 			return 0;
 
@@ -161,12 +161,12 @@ int add_to_swap(struct page *page)
 			SetPageDirty(page);
 			return 1;
 		case -EEXIST:
-			/* Raced with "speculative" read_swap_cache_async */
-			swap_free(entry);
+			/* Raced with "speculative" read_swap_cache_async ? */
+			swap_free(entry, SWAP_CACHE);
 			continue;
 		default:
 			/* -ENOMEM radix-tree allocation failure */
-			swap_free(entry);
+			swap_free(entry, SWAP_CACHE);
 			return 0;
 		}
 	}
@@ -189,7 +189,7 @@ void delete_from_swap_cache(struct page 
 	spin_unlock_irq(&swapper_space.tree_lock);
 
 	mem_cgroup_uncharge_swapcache(page, entry);
-	swap_free(entry);
+	swap_free(entry, SWAP_CACHE);
 	page_cache_release(page);
 }
 
@@ -293,7 +293,7 @@ struct page *read_swap_cache_async(swp_e
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */
-		if (!swap_duplicate(entry))
+		if (!swap_duplicate(entry, SWAP_CACHE))
 			break;
 
 		/*
@@ -317,7 +317,7 @@ struct page *read_swap_cache_async(swp_e
 		}
 		ClearPageSwapBacked(new_page);
 		__clear_page_locked(new_page);
-		swap_free(entry);
+		swap_free(entry, SWAP_CACHE);
 	} while (err != -ENOMEM);
 
 	if (new_page)
Index: mmotm-2.6.30-May17/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swapfile.c
+++ mmotm-2.6.30-May17/mm/swapfile.c
@@ -167,7 +167,7 @@ static int wait_for_discard(void *word)
 #define SWAPFILE_CLUSTER	256
 #define LATENCY_LIMIT		256
 
-static inline unsigned long scan_swap_map(struct swap_info_struct *si)
+static inline unsigned long scan_swap_map(struct swap_info_struct *si, int ops)
 {
 	unsigned long offset;
 	unsigned long scan_base;
@@ -285,7 +285,12 @@ checks:
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
 	}
-	si->swap_map[offset] = 1;
+
+	if (ops == SWAP_CACHE)
+		si->swap_map[offset] = 1; /* usually start from swap-cache */
+	else
+		si->swap_map[offset] = 2; /* swsusp does this. */
+
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
@@ -374,7 +379,7 @@ no_page:
 	return 0;
 }
 
-swp_entry_t get_swap_page(void)
+swp_entry_t get_swap_page(int ops)
 {
 	struct swap_info_struct *si;
 	pgoff_t offset;
@@ -401,7 +406,7 @@ swp_entry_t get_swap_page(void)
 			continue;
 
 		swap_list.next = next;
-		offset = scan_swap_map(si);
+		offset = scan_swap_map(si, ops);
 		if (offset) {
 			spin_unlock(&swap_lock);
 			return swp_entry(type, offset);
@@ -415,7 +420,7 @@ noswap:
 	return (swp_entry_t) {0};
 }
 
-swp_entry_t get_swap_page_of_type(int type)
+swp_entry_t get_swap_page_of_type(int type, int ops)
 {
 	struct swap_info_struct *si;
 	pgoff_t offset;
@@ -424,7 +429,7 @@ swp_entry_t get_swap_page_of_type(int ty
 	si = swap_info + type;
 	if (si->flags & SWP_WRITEOK) {
 		nr_swap_pages--;
-		offset = scan_swap_map(si);
+		offset = scan_swap_map(si, ops);
 		if (offset) {
 			spin_unlock(&swap_lock);
 			return swp_entry(type, offset);
@@ -471,13 +476,17 @@ out:
 	return NULL;
 }
 
-static int swap_entry_free(struct swap_info_struct *p, swp_entry_t ent)
+static int
+swap_entry_free(struct swap_info_struct *p, swp_entry_t ent, int ops)
 {
 	unsigned long offset = swp_offset(ent);
 	int count = p->swap_map[offset];
 
 	if (count < SWAP_MAP_MAX) {
-		count--;
+		if (ops == SWAP_CACHE)
+			count -= 1;
+		else
+			count -= 2;
 		p->swap_map[offset] = count;
 		if (!count) {
 			if (offset < p->lowest_bit)
@@ -498,13 +507,13 @@ static int swap_entry_free(struct swap_i
  * Caller has made sure that the swapdevice corresponding to entry
  * is still around or has not been recycled.
  */
-void swap_free(swp_entry_t entry)
+void swap_free(swp_entry_t entry, int ops)
 {
 	struct swap_info_struct * p;
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, entry);
+		swap_entry_free(p, entry, ops);
 		spin_unlock(&swap_lock);
 	}
 }
@@ -584,7 +593,7 @@ int free_swap_and_cache(swp_entry_t entr
 
 	p = swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, entry) == 1) {
+		if (swap_entry_free(p, entry, SWAP_MAP) == 1) {
 			page = find_get_page(&swapper_space, entry.val);
 			if (page && !trylock_page(page)) {
 				page_cache_release(page);
@@ -717,7 +726,7 @@ static int unuse_pte(struct vm_area_stru
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	page_add_anon_rmap(page, vma, addr);
 	mem_cgroup_commit_charge_swapin(page, ptr);
-	swap_free(entry);
+	swap_free(entry, SWAP_MAP);
 	/*
 	 * Move the page to the active list so it is not
 	 * immediately swapped out again after swapon.
@@ -1069,9 +1078,13 @@ static int try_to_unuse(unsigned int typ
 		 * We know "Undead"s can happen, they're okay, so don't
 		 * report them; but do report if we reset SWAP_MAP_MAX.
 		 */
-		if (*swap_map == SWAP_MAP_MAX) {
+		if ((*swap_map == SWAP_MAP_MAX) ||
+		    (*swap_map == SWAP_MAP_MAX+1)) {
 			spin_lock(&swap_lock);
-			*swap_map = 1;
+			if (*swap_map == SWAP_MAP_MAX)
+				*swap_map = 2; /* there isn't a swap cache */
+			else
+				*swap_map = 3; /* there is a swap cache */
 			spin_unlock(&swap_lock);
 			reset_overflow = 1;
 		}
@@ -1939,11 +1952,13 @@ void si_swapinfo(struct sysinfo *val)
 
 /*
  * Verify that a swap entry is valid and increment its swap map count.
- *
+ * If new reference is for new map, increment by 2.(type=SWAP_MAP)
+ * If new reference is for swap cache, increment by 1 (type = SWAP_CACHE)
  * Note: if swap_map[] reaches SWAP_MAP_MAX the entries are treated as
  * "permanent", but will be reclaimed by the next swapoff.
+ *
  */
-int swap_duplicate(swp_entry_t entry)
+int swap_duplicate(swp_entry_t entry, int ops)
 {
 	struct swap_info_struct * p;
 	unsigned long offset, type;
@@ -1959,15 +1974,35 @@ int swap_duplicate(swp_entry_t entry)
 	offset = swp_offset(entry);
 
 	spin_lock(&swap_lock);
-	if (offset < p->max && p->swap_map[offset]) {
-		if (p->swap_map[offset] < SWAP_MAP_MAX - 1) {
-			p->swap_map[offset]++;
-			result = 1;
-		} else if (p->swap_map[offset] <= SWAP_MAP_MAX) {
+	/*
+	 * When we tries to create new SwapCache, increment count by 1.
+	 * When we adds new reference to swap entry, increment count by 2.
+	 * If type==SWAP_CACHE and swap_map[] shows there is a swap cache,
+	 * it means racy swapin. The caller should cancel his work.
+	 */
+	if (offset < p->max && (p->swap_map[offset])) {
+		if (p->swap_map[offset] < SWAP_MAP_MAX - 2) {
+			if (ops == SWAP_CACHE) {
+				if (!(p->swap_map[offset] & 0x1)) {
+					p->swap_map[offset] += 1;
+					result = 1;
+				}
+			} else {
+				p->swap_map[offset] += 2;
+				result = 1;
+			}
+		} else if (p->swap_map[offset] <= SWAP_MAP_MAX - 1) {
 			if (swap_overflow++ < 5)
 				printk(KERN_WARNING "swap_dup: swap entry overflow\n");
-			p->swap_map[offset] = SWAP_MAP_MAX;
-			result = 1;
+			if (ops == SWAP_CACHE) {
+				if (!(p->swap_map[offset] & 0x1)) {
+					p->swap_map[offset] += 1;
+					result = 1;
+				}
+			} else {
+				p->swap_map[offset] += 2;
+				result = 1;
+			}
 		}
 	}
 	spin_unlock(&swap_lock);
Index: mmotm-2.6.30-May17/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/vmscan.c
+++ mmotm-2.6.30-May17/mm/vmscan.c
@@ -478,7 +478,7 @@ static int __remove_mapping(struct addre
 		__delete_from_swap_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_swapcache(page, swap);
-		swap_free(swap);
+		swap_free(swap, SWAP_CACHE);
 	} else {
 		__remove_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
Index: mmotm-2.6.30-May17/kernel/power/swsusp.c
===================================================================
--- mmotm-2.6.30-May17.orig/kernel/power/swsusp.c
+++ mmotm-2.6.30-May17/kernel/power/swsusp.c
@@ -120,10 +120,10 @@ sector_t alloc_swapdev_block(int swap)
 {
 	unsigned long offset;
 
-	offset = swp_offset(get_swap_page_of_type(swap));
+	offset = swp_offset(get_swap_page_of_type(swap, SWAP_MAP));
 	if (offset) {
 		if (swsusp_extents_insert(offset))
-			swap_free(swp_entry(swap, offset));
+			swap_free(swp_entry(swap, offset), SWAP_MAP);
 		else
 			return swapdev_block(swap, offset);
 	}
@@ -147,7 +147,7 @@ void free_all_swap_pages(int swap)
 		ext = container_of(node, struct swsusp_extent, node);
 		rb_erase(node, &swsusp_extents);
 		for (offset = ext->start; offset <= ext->end; offset++)
-			swap_free(swp_entry(swap, offset));
+			swap_free(swp_entry(swap, offset), SWAP_MAP);
 
 		kfree(ext);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
