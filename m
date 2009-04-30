Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 77A496B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 03:17:45 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3U7HxJV022533
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Apr 2009 16:17:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 218E345DE52
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 16:17:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F15F945DE4D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 16:17:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CE6521DB803F
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 16:17:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 681E7E08001
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 16:17:58 +0900 (JST)
Date: Thu, 30 Apr 2009 16:16:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: fix stale swap cache leak v5
Message-Id: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is v5 but all codes are rewritten.

After this patch, when memcg is used,
 1. page's swapcount is checked after I/O (without locks). If the page is
    stale swap cache, freeing routine will be scheduled.
 2. vmscan.c calls try_to_free_swap() when __remove_mapping() fails.

Works well for me. no extra resources and no races.

Because my office will be closed until May/7, I'll not be able to make a
response. Posting this for showing what I think of now.

This should be fixed before posting softlimit etc...
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In general, Linux's swp_entry handling is done by combination of lazy techniques
and global LRU. It works well but when we use mem+swap controller, some more
strict cotroll is appropriate. Otherwise, swp_entry used by a cgroup will be
never freed until global LRU works. In a system where memcg is well-configured,
global LRU doesn't work frequently.

  Example A) Assume a swap cache which is not mapped.
              CPU0                            CPU1
	   zap_pte()....                  shrink_page_list()
	    free_swap_and_cache()           lock_page()
		page seems busy.

  Example B) Assume swapin-readahed.
	      CPU0			      CPU1
	   zap_pte()			  read_swap_cache_async()
					  swap_duplicate().
           swap_entry_free() = 1
	   find_get_page()=> NULL.
					  add_to_swap_cache().
					  issue swap I/O. 

There are many patterns of this kind of race (but no problems).

free_swap_and_cache() is called for freeing swp_entry. But it is a best-effort
function. If the swp_entry/page seems busy, swp_entry is not freed.
This is not a problem because global-LRU will find SwapCache at page reclaim.
But...

If memcg is used, on the other hand, global LRU may not work. Then, above
unused SwapCache will not be freed.
(unmapped SwapCache occupy swp_entry but never be freed if not on memcg's LRU)

So, even if there are no tasks in a cgroup, swp_entry usage still remains.
In bad case, OOM by mem+swap controller is triggerred by this "leak" of
swp_entry as Nishimura repoted.

This patch tries to fix racy case of free_swap_and_cache() and I/O by checking
swap's refnct again after I/O. And add a hook to vmscan.c.
After this patch applied, follwoing test works well.

  # echo 1-2M > ../memory.limit_in_bytes
  # run tasks under memcg.
  # kill all tasks and make memory.tasks empty
  # check memory.memsw.usage_in_bytes == memory.usage_in_bytes and
    there is no _used_ swp_entry.

Changelog: v4->v5
 - completely new design.
 - added nolock page_swapcount.
 - checks all swap I/O.

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    1 
 mm/page_io.c         |  120 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c        |   37 +++++++++++++++
 mm/vmscan.c          |   31 ++++++++++++-
 4 files changed, 187 insertions(+), 2 deletions(-)

Index: mmotm-2.6.30-Apr24/mm/page_io.c
===================================================================
--- mmotm-2.6.30-Apr24.orig/mm/page_io.c
+++ mmotm-2.6.30-Apr24/mm/page_io.c
@@ -19,6 +19,123 @@
 #include <linux/writeback.h>
 #include <asm/pgtable.h>
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/*
+ * When memory cgroup is used, race between read/write-swap and zap-swap can
+ * be a leak of swp_entry accounted. So we have to check the status at
+ * the end of swap-io. If memory cgroup is not used, Global LRU will find
+ * unused swap-cache finally. (But this is too lazy for memcg.)
+ */
+
+struct swapio_check {
+	spinlock_t	lock;
+	void		*swap_bio_list;
+	struct delayed_work work;
+} stale_swap_check;
+
+
+static void mem_cgroup_check_stale_swap(struct work_struct *work)
+{
+	struct bio *bio;
+	struct page *page;
+	struct swapio_check *sc;
+	int nr = SWAP_CLUSTER_MAX;
+	swp_entry_t entry;
+
+	sc = &stale_swap_check;
+
+	while (nr--) {
+		cond_resched();
+		spin_lock_irq(&sc->lock);
+		bio = sc->swap_bio_list;
+		if (bio)
+			sc->swap_bio_list = bio->bi_next;
+		spin_unlock_irq(&sc->lock);
+		if (!bio)
+			break;
+		entry.val = (unsigned long)bio->bi_private;
+		bio_put(bio);
+
+		page = find_get_page(&swapper_space, entry.val);
+		if (!page || page_mapped(page))
+			continue;
+		lock_page(page);
+		/*
+		 * When it's mapped, this page passed checks in do_swap_page()
+		 * and we don't have to do any more. All other necessary checks
+		 * will be done in try_to_free_swap().
+		 */
+		if (!page_mapped(page))
+			try_to_free_swap(page);
+		unlock_page(page);
+		put_page(page);
+	}
+	if (sc->swap_bio_list)
+		schedule_delayed_work(&sc->work, HZ/10);
+}
+
+/*
+ * We can't call try_to_free_swap directly here because of caller's context.
+ */
+static void mem_cgroup_swapio_check_again(struct bio *bio, struct page *page)
+{
+	unsigned long flags;
+	struct swapio_check *sc;
+	swp_entry_t entry;
+	int ret;
+
+	/* check swap count here. If swp_entry is stable, nothing to do.*/
+	if (likely(mem_cgroup_staleswap_hint(page)))
+		return;
+	/* reuse bio if this bio is ready to be freed. */
+	ret = atomic_inc_return(&bio->bi_cnt);
+	/* Any other reference other than us ? */
+	if (unlikely(ret > 2)) {
+		bio_put(bio);
+		return;
+	}
+	/*
+	 * We don't want to grab this page....record swp_entry instead of page.
+	 */
+	entry.val = page_private(page);
+	bio->bi_private = (void *)entry.val;
+
+	sc = &stale_swap_check;
+	spin_lock_irqsave(&sc->lock, flags);
+	/* link bio */
+	bio->bi_next = sc->swap_bio_list;
+	sc->swap_bio_list = bio;
+	spin_unlock_irqrestore(&sc->lock, flags);
+	/*
+	 * Swap I/O is tend to be countinous. Do check in batched manner.
+	 */
+	if (!delayed_work_pending(&sc->work))
+		schedule_delayed_work(&sc->work, HZ/10);
+}
+
+static int __init setup_stale_swap_check(void)
+{
+	struct swapio_check *sc;
+
+	sc = &stale_swap_check;
+	spin_lock_init(&sc->lock);
+	sc->swap_bio_list = NULL;
+	INIT_DELAYED_WORK(&sc->work, mem_cgroup_check_stale_swap);
+	return 0;
+}
+late_initcall(setup_stale_swap_check);
+
+
+#else /* CONFIG_CGROUP_MEM_RES_CTRL */
+
+static inline
+void mem_cgroup_swapio_check_again(struct bio *bio, struct page *page)
+{
+}
+#endif
+
+
+
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
 				struct page *page, bio_end_io_t end_io)
 {
@@ -66,6 +183,8 @@ static void end_swap_bio_write(struct bi
 				(unsigned long long)bio->bi_sector);
 		ClearPageReclaim(page);
 	}
+	/* While PG_writeback, this page is stable ...then, call this here */
+	mem_cgroup_swapio_check_again(bio, page);
 	end_page_writeback(page);
 	bio_put(bio);
 }
@@ -85,6 +204,7 @@ void end_swap_bio_read(struct bio *bio, 
 	} else {
 		SetPageUptodate(page);
 	}
+	mem_cgroup_swapio_check_again(bio, page);
 	unlock_page(page);
 	bio_put(bio);
 }
Index: mmotm-2.6.30-Apr24/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-Apr24.orig/mm/vmscan.c
+++ mmotm-2.6.30-Apr24/mm/vmscan.c
@@ -586,6 +586,30 @@ void putback_lru_page(struct page *page)
 }
 #endif /* CONFIG_UNEVICTABLE_LRU */
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTRL
+/*
+ * Even if we don't call this, global LRU will finally find this SwapCache and
+ * free swap entry in the next loop. But, when memcg is used, we may have
+ * smaller chance to call global LRU's memory reclaim code.
+ * Freeing unused swap entry in aggresive way is good for avoid "leak" of swap
+ * entry accounting.
+ */
+static inline void unuse_swapcache_check_again(struct page *page)
+{
+	/*
+	 * The page is locked, but have extra reference from somewhere.
+	 * In typical case, rotate_reclaimable_page()'s extra refcnt makes
+	 * __remove_mapping fail. (see mm/swap.c)
+	 */
+	if (PageSwapCache(page))
+		try_to_free_swap(page);
+}
+#else
+static inline void unuse_swapcache_check_again(struct page *page)
+{
+}
+#endif
+
 
 /*
  * shrink_page_list() returns the number of reclaimed pages
@@ -758,9 +782,12 @@ static unsigned long shrink_page_list(st
 			}
 		}
 
-		if (!mapping || !__remove_mapping(mapping, page))
+		if (!mapping)
 			goto keep_locked;
-
+		if (!__remove_mapping(mapping, page)) {
+			unuse_swapcache_check_again(page);
+			goto keep_locked;
+		}
 		/*
 		 * At this point, we have no other references and there is
 		 * no way to pick any more up (removed from LRU, removed
Index: mmotm-2.6.30-Apr24/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-Apr24.orig/mm/swapfile.c
+++ mmotm-2.6.30-Apr24/mm/swapfile.c
@@ -528,6 +528,43 @@ static inline int page_swapcount(struct 
 	return count;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+static inline int page_swapused_nolock(struct page *page)
+{
+	swp_entry_t entry;
+	unsigned long type, offset;
+	struct swap_info_struct *p;
+
+	entry.val = page_private(page);
+	type = swp_type(entry);
+	VM_BUG_ON(type >= nr_swapfiles);
+
+	offset = swp_offset(entry);
+	p = &swap_info[type];
+	VM_BUG_ON(!(p->flags & SWP_USED));
+	VM_BUG_ON(!(p->swap_map[offset]));
+
+	smp_rmb();
+	return p->swap_map[offset] != 1;
+}
+/*
+ * Use a lapping function not to allow reuse this function other than memcg.
+ */
+int mem_cgroup_staleswap_hint(struct page *page)
+{
+	/*
+	 * The page may not under lock_page() but Writeback is set in that case.
+	 * Then, swap_map is stable when this is called.
+	 * Very terrible troube will not occur even if page_swapused_nolock()
+	 * returns wrong value.
+	 * Because this can be called via interrupt context, we use nolock
+	 * version of swap's refcnt check.
+	 */
+	if (!PageSwapCache(page) || page_mapped(page))
+		return 1;
+	return page_swapused_nolock(page);
+}
+#endif
 /*
  * We can write to an anon page without COW if there are no other references
  * to it.  And as a side-effect, free up its swap: because the old content
Index: mmotm-2.6.30-Apr24/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-Apr24.orig/include/linux/swap.h
+++ mmotm-2.6.30-Apr24/include/linux/swap.h
@@ -336,6 +336,7 @@ static inline void disable_swap_token(vo
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern int mem_cgroup_staleswap_hint(struct page *page);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
