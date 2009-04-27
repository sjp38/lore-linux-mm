Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BA8756B00A6
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 05:14:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3R9EXYJ019013
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Apr 2009 18:14:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C1DAF45DE64
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 18:14:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9346945DE55
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 18:14:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 75AB5E38004
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 18:14:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 078B61DB803C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 18:14:32 +0900 (JST)
Date: Mon, 27 Apr 2009 18:12:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] fix leak of swap accounting as stale swap cache under memcg
Message-Id: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Works very well under my test as following.
  prepare a program which does malloc, touch pages repeatedly.

  # echo 2M > /cgroup/A/memory.limit_in_bytes  # set limit to 2M.
  # echo 0 > /cgroup/A/tasks.                  # add shell to the group. 
 
  while true; do
    malloc_and_touch 1M &                       # run malloc and touch program.
    malloc_and_touch 1M &
    malloc_and_touch 1M &
    sleep 3
    pkill malloc_and_touch                      # kill them
  done

Then, you can see memory.memsw.usage_in_bytes increase gradually and exceeds 3M bytes.
This means account for swp_entry is not reclaimed at kill -> exit-> zap_pte()
because of race with swap-ops and zap_pte() under memcg.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Because free_swap_and_cache() function is called under spinlocks,
it can't sleep and use trylock_page() instead of lock_page().
By this, swp_entry which is not used after zap_xx can exists as
SwapCache, which will be never used.
This kind of SwapCache is reclaimed by global LRU when it's found
at LRU rotation. Typical case is following.

       (CPU0 zap_pte)      (CPU1 swapin-readahead)
     zap_pte()                swap_duplicate()
     swap_entry_free()
     -> nothing to do 
                              swap will be read in.

(This race window is wider than expected because of readahead)

When memory cgroup is used, the global LRU will not be kicked and
stale Swap Caches will not be reclaimed. Newly read-in swap cache is
not accounted and not added to memcg's LRU until it's mapped.
So, memcg itself cant reclaim it but swp_entry is freed until
global LRU finds it.

This is problematic because memcg's swap entry accounting is leaked
memcg can't know it. To catch this stale SwapCache, we have to chase it
and check the swap is alive or not again.

For chasing all swap entry, we need amount of memory but we don't
have enough space and it seems overkill. But, because stale-swap-cache
can be short-lived if we free it in proper way, we can check them
and sweep them out in lazy way with (small) static size buffer.

This patch adds a function to chase stale swap cache and reclaim it.
When zap_xxx fails to remove swap ent, it will be recoreded into buffer
and memcg's sweep routine will reclaim it later.
No sleep, no memory allocation under free_swap_and_cache().

This patch also adds stale-swap-cache-congestion logic and try to avoid to
have too much stale swap caches at once.

Implementation is naive but maybe the cost meets trade-off.

How to test:
  1. set limit of memory to very small (1-2M?). 
  2. run some amount of program and run page reclaim/swap-in.
  3. kill programs by SIGKILL etc....then, Stale Swap Cache will
     be increased. After this patch, stale swap caches are reclaimed
     and mem+swap controller will not go to OOM.

Changelog:v3->v4
 - replace lookup_swap_cache() with find_get_page().
 - clean up.
 - added put_page().
 - fixed compilation under various CONFIG.
 V3 was completely new.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |   20 +++++++
 mm/memcontrol.c      |  129 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c      |   11 +++-
 mm/swapfile.c        |   11 ++++
 mm/vmscan.c          |    3 +
 5 files changed, 173 insertions(+), 1 deletion(-)

Index: mmotm-2.6.30-Apr24/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-Apr24.orig/include/linux/swap.h
+++ mmotm-2.6.30-Apr24/include/linux/swap.h
@@ -336,11 +336,27 @@ static inline void disable_swap_token(vo
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern void memcg_mark_swapent_stale(swp_entry_t ent);
+extern void memcg_sanity_check_swapin(struct page *page, swp_entry_t ent);
+extern int memcg_stale_swap_congestion(void);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
 }
+
+static inline void memcg_mark_swapent_stale(swp_entry_t ent)
+{
+}
+
+static inline void memcg_sanity_check_swapin(struct page *page, swp_entry_t ent)
+{
+}
+
+static inline int memcg_stale_swap_congestion(void)
+{
+	return 0;
+}
 #endif
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
@@ -436,6 +452,10 @@ static inline int mem_cgroup_cache_charg
 {
 	return 0;
 }
+static inline int memcg_stale_swap_congestion(void)
+{
+	return 0;
+}
 
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
Index: mmotm-2.6.30-Apr24/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-Apr24.orig/mm/memcontrol.c
+++ mmotm-2.6.30-Apr24/mm/memcontrol.c
@@ -1702,6 +1702,132 @@ int mem_cgroup_shmem_charge_fallback(str
 	return ret;
 }
 
+#ifdef CONFIG_SWAP
+/*
+ * Stale Swap Cache Handler.
+ * Stale Swap Cache is a Swap Cache which will never be used. In general,
+ * Swap Cache is zapped by free_swap_and_cache() (via zap_pte_range() etc.).
+ * But in racy case, free_swap_and_cache() doesn't free swap entries and
+ * it's expected that Swap Cache will be freed by global LRU rotation.
+ *
+ * But if memory cgroup is used, global lru rotation may not happen and
+ * Stale Swap Cache (and unused swap entry) will never be reclaimed. In bad
+ * case, this can cause OOM (under memcg) and other problems.
+ *
+ * Following is GC code for stale swap caches.
+ */
+
+#define STALE_ENTS (512)
+#define STALE_ENTS_MAP (STALE_ENTS/BITS_PER_LONG)
+
+static struct stale_swap_control {
+	spinlock_t lock;
+	int num;
+	int congestion;
+	unsigned long usemap[STALE_ENTS_MAP];
+	swp_entry_t ents[STALE_ENTS];
+	struct delayed_work gc_work;
+} ssc;
+
+static void schedule_ssc_gc(void)
+{
+	/* 10ms margin to wait for a page unlocked */
+	schedule_delayed_work(&ssc.gc_work, HZ/10);
+}
+
+static void memcg_fixup_stale_swapcache(struct work_struct *work)
+{
+	int pos = 0;
+	swp_entry_t entry;
+	struct page *page;
+	int forget, ret;
+
+	while (ssc.num) {
+		spin_lock(&ssc.lock);
+		pos = find_next_bit(ssc.usemap, STALE_ENTS, pos);
+		spin_unlock(&ssc.lock);
+
+		if (pos >= STALE_ENTS)
+			break;
+
+		entry = ssc.ents[pos];
+
+		forget = 1;
+		/*
+		 * Because lookup_swap_cache() increases statistics,
+		 * call find_get_page() directly.
+		 */
+		page = find_get_page(&swapper_space, entry.val);
+		if (page) {
+			lock_page(page);
+			ret = try_to_free_swap(page);
+			/* If it's still under I/O, don't forget it */
+			if (!ret && PageWriteback(page))
+				forget = 0;
+			unlock_page(page);
+			put_page(page);
+		}
+		if (forget) {
+			spin_lock(&ssc.lock);
+			clear_bit(pos, ssc.usemap);
+			ssc.num--;
+			if (ssc.num < STALE_ENTS/2)
+				ssc.congestion = 0;
+			spin_unlock(&ssc.lock);
+		}
+		pos++;
+	}
+	if (ssc.num) /* schedule me again */
+		schedule_ssc_gc();
+	return;
+}
+
+
+/* We found lock_page() contention at zap_page. then revisit this later */
+void memcg_mark_swapent_stale(swp_entry_t ent)
+{
+	int pos;
+
+	spin_lock(&ssc.lock);
+	WARN_ON(ssc.num >= STALE_ENTS);
+	if (ssc.num < STALE_ENTS) {
+		pos = find_first_zero_bit(ssc.usemap, STALE_ENTS);
+		ssc.ents[pos] = ent;
+		set_bit(pos, ssc.usemap);
+		ssc.num++;
+		if (ssc.num > STALE_ENTS/2)
+			ssc.congestion = 1;
+	}
+	spin_unlock(&ssc.lock);
+	schedule_ssc_gc();
+}
+
+/* If too many stale swap caches, avoid too much swap I/O */
+int memcg_stale_swap_congestion(void)
+{
+	smp_mb();
+	if (ssc.congestion) {
+		schedule_ssc_gc();
+		return 1;
+	}
+	return 0;
+}
+
+static void setup_stale_swapcache_control(void)
+{
+	memset(&ssc, 0, sizeof(ssc));
+	spin_lock_init(&ssc.lock);
+	INIT_DELAYED_WORK(&ssc.gc_work, memcg_fixup_stale_swapcache);
+}
+
+#else
+
+static void setup_stale_swapcache_control(void)
+{
+}
+
+#endif /* CONFIG_SWAP */
+
 static DEFINE_MUTEX(set_limit_mutex);
 
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
@@ -2464,6 +2590,7 @@ static struct mem_cgroup *parent_mem_cgr
 	return mem_cgroup_from_res_counter(mem->res.parent, res);
 }
 
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 static void __init enable_swap_cgroup(void)
 {
@@ -2493,6 +2620,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	/* root ? */
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
+		setup_stale_swapcache_control();
 		parent = NULL;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
@@ -2588,3 +2716,4 @@ static int __init disable_swap_account(c
 }
 __setup("noswapaccount", disable_swap_account);
 #endif
+
Index: mmotm-2.6.30-Apr24/mm/swap_state.c
===================================================================
--- mmotm-2.6.30-Apr24.orig/mm/swap_state.c
+++ mmotm-2.6.30-Apr24/mm/swap_state.c
@@ -313,6 +313,7 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
+			memcg_sanity_check_swapin(new_page, entry);
 			lru_cache_add_anon(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
@@ -360,8 +361,16 @@ struct page *swapin_readahead(swp_entry_
 	 * No, it's very unlikely that swap layout would follow vma layout,
 	 * more likely that neighbouring swap pages came from the same node:
 	 * so use the same "addr" to choose the same node for each swap read.
+	 *
+	 * If memory cgroup is used, Stale Swap Cache congestion check is
+	 * done and no readahed if there are too much stale swap caches.
 	 */
-	nr_pages = valid_swaphandles(entry, &offset);
+	if (memcg_stale_swap_congestion()) {
+		offset = swp_offset(entry);
+		nr_pages = 1;
+	} else
+		nr_pages = valid_swaphandles(entry, &offset);
+
 	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
 		/* Ok, do the async read-ahead now */
 		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
Index: mmotm-2.6.30-Apr24/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-Apr24.orig/mm/swapfile.c
+++ mmotm-2.6.30-Apr24/mm/swapfile.c
@@ -570,6 +570,16 @@ int try_to_free_swap(struct page *page)
 	return 1;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+void memcg_sanity_check_swapin(struct page *page, swp_entry_t entry)
+{
+	VM_BUG_ON(!PageSwapCache(page));
+	VM_BUG_ON(!PageLocked(page));
+	/* This page is Locked */
+	if (!page_swapcount(page))
+		memcg_mark_swapent_stale(entry);
+}
+#endif
 /*
  * Free the swap entry like above, but also try to
  * free the page cache entry if it is the last user.
@@ -589,6 +599,7 @@ int free_swap_and_cache(swp_entry_t entr
 			if (page && !trylock_page(page)) {
 				page_cache_release(page);
 				page = NULL;
+				memcg_mark_swapent_stale(entry);
 			}
 		}
 		spin_unlock(&swap_lock);
Index: mmotm-2.6.30-Apr24/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-Apr24.orig/mm/vmscan.c
+++ mmotm-2.6.30-Apr24/mm/vmscan.c
@@ -661,6 +661,9 @@ static unsigned long shrink_page_list(st
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
+			/* avoid making more stale swap caches */
+			if (memcg_stale_swap_congestion())
+				goto keep_locked;
 			if (!add_to_swap(page))
 				goto activate_locked;
 			may_enter_fs = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
