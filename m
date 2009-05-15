Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2B5F16B005A
	for <linux-mm@kvack.org>; Fri, 15 May 2009 06:02:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4FA1xo3007803
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 15 May 2009 19:02:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 978C645DD7D
	for <linux-mm@kvack.org>; Fri, 15 May 2009 19:01:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D9B645DD78
	for <linux-mm@kvack.org>; Fri, 15 May 2009 19:01:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DBF71DB803F
	for <linux-mm@kvack.org>; Fri, 15 May 2009 19:01:59 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 01F9D1DB803B
	for <linux-mm@kvack.org>; Fri, 15 May 2009 19:01:59 +0900 (JST)
Date: Fri, 15 May 2009 19:00:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: handle accounting race in swapin-readahead and
 zap_pte
Message-Id: <20090515190027.e7d48d7a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, hannes@cmpxchg.org, "mingo@elte.hu" <mingo@elte.hu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Similar to previous series but this version is a bit claerer, I think.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When a process exits, zap_pte() is called and free_swap_and_cache()
is called for freeing swp_entry. But free_swap_and_cache() uses trylock()
and entries may not be freed. (Later, global LRU will handle this.)


           processA                   |           processB
  -------------------------------------+-------------------------------------
    (free_swap_and_cache())            |  (read_swap_cache_async())
                                       |    swap_duplicate()
                                       |    __set_page_locked()
                                       |    add_to_swap_cache()
      swap_entry_free() == 0           |
      find_get_page() -> found         |
      try_lock_page() -> fail & return |
                                       |    lru_cache_add_anon()
                                       |      doesn't link this page to memcg's
                                       |      LRU, because of !PageCgroupUsed.

At using memcg, above path is terrible because not freed swapcache will
never be freed until global LRU runs. This can be leak of swap entry
and cause OOM (as Nishimura reported)

To fix this, one easy way is not to permit swapin-readahead. But it causes
unpleasant peformance penalty in case that swapin-readahead hits.

This patch tries to fix above race by adding an private LRU, swapin-buffer.
This works as following.
 1. add swap-cache to swapin-buffer at readahead()
 2. check SwapCache in swapin-buffer again in delayed work.
 3. finally pages in swapin-buffer are moved to INACTIVE_ANON list.

This patch uses delayed_work and moves pages from buffer to anon in
proportional number to the number of pages in swapin-buffer.


Changelog:
 - redesigned again.
 - A main difference from previous trials is PG_lru is not set until
   we confirm the entry. We can avoid races and contention of zone's LRU.
 - # of calls to schedule_work() is reduced.
 - access to zone->lru is batched.
 - don't handle races in writeback (handled by other patch)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    8 +++
 mm/memcontrol.c      |  120 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c      |   10 +++-
 3 files changed, 136 insertions(+), 2 deletions(-)

Index: mmotm-2.6.30-May13/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-May13.orig/mm/memcontrol.c	2009-05-15 17:44:14.000000000 +0900
+++ mmotm-2.6.30-May13/mm/memcontrol.c	2009-05-15 18:46:35.000000000 +0900
@@ -834,6 +834,123 @@
 	return num;
 }
 
+#ifdef CONFIG_SWAP
+
+struct swapin_buffer {
+	spinlock_t		lock;
+	struct list_head	list;
+	int			nr;
+	struct delayed_work	work;
+} memcg_swapin_buffer;
+
+/* Used at swapoff */
+#define ENOUGH_LARGE_SWAPIN_BUFFER	(1024)
+
+/* Hide swapin page from LRU for a while */
+
+static int __check_swapin_buffer(struct page *page)
+{
+	/* Fast path (PG_writeback never be set.) */
+	if (!PageSwapCache(page) || page_mapped(page))
+		return 1;
+
+	if (PageUptodate(page) && trylock_page(page)) {
+		try_to_free_swap(page);
+		unlock_page(page);
+		return 1;
+	}
+	return 0;
+}
+
+static void mem_cgroup_drain_swapin_buffer(struct work_struct *work)
+{
+	struct page *page, *tmp;
+	LIST_HEAD(scan);
+	int nr, fail;
+
+	if (!memcg_swapin_buffer.nr)
+		return;
+
+	/*
+	 * When swapin_buffer increasing rapidly, swapped-in pages tend to be
+	 * in use. Because page faulted thread should continue its own work
+	 * to cause large swapin, swapin-readahead should _hit_ if nr is large.
+	 * In that case, __check_swapin_buffer() will use fast-path.
+	 * Then, making _nr_ to be propotional to the total size.
+	 */
+	nr = memcg_swapin_buffer.nr/8 + 1;
+
+	spin_lock(&memcg_swapin_buffer.lock);
+	while (nr-- && !list_empty(&memcg_swapin_buffer.list)) {
+		list_move(memcg_swapin_buffer.list.next, &scan);
+		memcg_swapin_buffer.nr--;
+	}
+	spin_unlock(&memcg_swapin_buffer.lock);
+
+	fail = 0;
+	list_for_each_entry_safe(page, tmp, &scan, lru) {
+		if (__check_swapin_buffer(page)) {
+			list_del(&page->lru);
+			lru_cache_add_anon(page);
+			put_page(page);
+		} else
+			fail++;
+	}
+	if (!list_empty(&scan)) {
+		spin_lock(&memcg_swapin_buffer.lock);
+		list_splice_tail(&scan, &memcg_swapin_buffer.list);
+		memcg_swapin_buffer.nr += fail;
+		spin_unlock(&memcg_swapin_buffer.lock);
+	}
+
+	if (memcg_swapin_buffer.nr)
+		schedule_delayed_work(&memcg_swapin_buffer.work, HZ/10);
+}
+
+static void mem_cgroup_force_drain_swapin_buffer(void)
+{
+	int swapin_buffer_thresh;
+
+	swapin_buffer_thresh = (num_online_cpus() + 1) * (1 << page_cluster);
+	if (memcg_swapin_buffer.nr > swapin_buffer_thresh)
+		mem_cgroup_drain_swapin_buffer(NULL);
+}
+
+void mem_cgroup_lazy_drain_swapin_buffer(void)
+{
+	schedule_delayed_work(&memcg_swapin_buffer.work, HZ/10);
+}
+
+void mem_cgroup_add_swapin_buffer(struct page *page)
+{
+	get_page(page);
+	spin_lock(&memcg_swapin_buffer.lock);
+	list_add_tail(&page->lru, &memcg_swapin_buffer.list);
+	memcg_swapin_buffer.nr++;
+	spin_unlock(&memcg_swapin_buffer.lock);
+	/*
+	 * Usually, this will not hit. At swapoff, we have to
+	 * drain ents manually.
+	 */
+	if (memcg_swapin_buffer.nr > ENOUGH_LARGE_SWAPIN_BUFFER)
+		mem_cgroup_drain_swapin_buffer(NULL);
+}
+
+static __init int init_swapin_buffer(void)
+{
+	spin_lock_init(&memcg_swapin_buffer.lock);
+	INIT_LIST_HEAD(&memcg_swapin_buffer.list);
+	INIT_DELAYED_WORK(&memcg_swapin_buffer.work,
+			mem_cgroup_drain_swapin_buffer);
+	return 0;
+}
+late_initcall(init_swapin_buffer);
+#else
+static void mem_cgroup_force_drain_swain_buffer(void)
+{
+}
+#endif /* CONFIG_SWAP */
+
 /*
  * Visit the first child (need not be the first child as per the ordering
  * of the cgroup list, since we track last_scanned_child) of @mem and use
@@ -892,6 +1009,8 @@
 	int ret, total = 0;
 	int loop = 0;
 
+	mem_cgroup_force_drain_swapin_buffer();
+
 	while (loop < 2) {
 		victim = mem_cgroup_select_victim(root_mem);
 		if (victim == root_mem)
@@ -1560,6 +1679,7 @@
 }
 
 #ifdef CONFIG_SWAP
+
 /*
  * called after __delete_from_swap_cache() and drop "page" account.
  * memcg information is recorded to swap_cgroup of "ent"
Index: mmotm-2.6.30-May13/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May13.orig/include/linux/swap.h	2009-05-15 17:44:14.000000000 +0900
+++ mmotm-2.6.30-May13/include/linux/swap.h	2009-05-15 18:01:43.000000000 +0900
@@ -336,11 +336,19 @@
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern void mem_cgroup_add_swapin_buffer(struct page *page);
+extern void mem_cgroup_lazy_drain_swapin_buffer(void);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
 }
+static inline void mem_cgroup_add_swapin_buffer(struct page *page)
+{
+}
+static inline void  mem_cgroup_lazy_drain_swapin_buffer(void)
+{
+}
 #endif
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
Index: mmotm-2.6.30-May13/mm/swap_state.c
===================================================================
--- mmotm-2.6.30-May13.orig/mm/swap_state.c	2009-05-15 17:44:14.000000000 +0900
+++ mmotm-2.6.30-May13/mm/swap_state.c	2009-05-15 18:01:43.000000000 +0900
@@ -311,7 +311,10 @@
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_anon(new_page);
+			if (mem_cgroup_disabled())
+				lru_cache_add_anon(new_page);
+			else
+				mem_cgroup_add_swapin_buffer(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
@@ -368,6 +371,9 @@
 			break;
 		page_cache_release(page);
 	}
-	lru_add_drain();	/* Push any new pages onto the LRU now */
+	if (mem_cgroup_disabled())
+		lru_add_drain();/* Push any new pages onto the LRU now */
+	else
+		mem_cgroup_lazy_drain_swapin_buffer();
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
