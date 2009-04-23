Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCFC6B003D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 00:18:45 -0400 (EDT)
Date: Thu, 23 Apr 2009 13:14:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for mem+swap controller
Message-Id: <20090423131438.062cfb13.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> I'll dig and try more including another aproach..
> 
How about this patch ?

It seems to have been working fine for several hours.
I should add more and more comments and clean it up, of course :)
(I think it would be better to unify definitions of new functions to swapfile.c,
and checking page_mapped() might be enough for mem_cgroup_free_unused_swapcache().)

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/memcontrol.h |    5 +++
 include/linux/swap.h       |   11 ++++++++
 mm/memcontrol.c            |   62 ++++++++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c            |    8 +++++
 mm/swapfile.c              |   32 ++++++++++++++++++++++-
 mm/vmscan.c                |    8 +++++
 6 files changed, 125 insertions(+), 1 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 25b9ca9..8b674c2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -101,6 +101,7 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
+extern void mem_cgroup_free_unused_swapcache(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
@@ -259,6 +260,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return NULL;
 }
 
+static inline void mem_cgroup_free_unused_swapcache(struct page *page)
+{
+}
+
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 62d8143..cdfa982 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -336,11 +336,22 @@ static inline void disable_swap_token(void)
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern int mem_cgroup_fixup_swapin(struct page *page);
+extern void mem_cgroup_fixup_swapfree(struct page *page);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
 }
+static inline int
+mem_cgroup_fixup_swapin(struct page *page)
+{
+	return 0;
+}
+static inline void
+mem_cgroup_fixup_swapfree(struct page *page)
+{
+}
 #endif
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 79c32b8..f90967b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1536,6 +1536,68 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 }
 #endif
 
+struct mem_cgroup_swap_fixup_work {
+	struct work_struct work;
+	struct page *page;
+};
+
+static void mem_cgroup_fixup_swapfree_cb(struct work_struct *work)
+{
+	struct mem_cgroup_swap_fixup_work *my_work;
+	struct page *page;
+
+	my_work = container_of(work, struct mem_cgroup_swap_fixup_work, work);
+	page = my_work->page;
+
+	lock_page(page);
+	if (PageSwapCache(page))
+		mem_cgroup_free_unused_swapcache(page);
+	unlock_page(page);
+
+	kfree(my_work);
+	put_page(page);
+}
+
+void mem_cgroup_fixup_swapfree(struct page *page)
+{
+	struct mem_cgroup_swap_fixup_work *my_work;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	if (!PageSwapCache(page) || page_mapped(page))
+		return;
+
+	my_work = kmalloc(sizeof(*my_work), GFP_ATOMIC); /* cannot sleep */
+	if (my_work) {
+		get_page(page);	/* put_page will be called in callback */
+		my_work->page = page;
+		INIT_WORK(&my_work->work, mem_cgroup_fixup_swapfree_cb);
+		schedule_work(&my_work->work);
+	}
+
+	return;
+}
+
+/*
+ * called from shrink_page_list() and mem_cgroup_fixup_swapfree_cb() to free
+ * !PageCgroupUsed SwapCache, because memcg cannot handle these SwapCache well.
+ */
+void mem_cgroup_free_unused_swapcache(struct page *page)
+{
+		struct page_cgroup *pc;
+
+		VM_BUG_ON(!PageLocked(page));
+		VM_BUG_ON(!PageSwapCache(page));
+
+		pc = lookup_page_cgroup(page);
+		/*
+		 * Used bit of swapcache is solid under page lock.
+		 */
+		if (!PageCgroupUsed(pc))
+			try_to_free_swap(page);
+}
+
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3ecea98..57d9678 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -310,6 +310,14 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		SetPageSwapBacked(new_page);
 		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
 		if (likely(!err)) {
+			if (unlikely(mem_cgroup_fixup_swapin(new_page)))
+				/*
+				 * new_page is not used by anyone.
+				 * And it has been already removed from
+				 * SwapCache and freed.
+				 */
+				return NULL;
+
 			/*
 			 * Initiate read into locked page and return.
 			 */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 312fafe..1f6934c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -578,6 +578,7 @@ int free_swap_and_cache(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
 	struct page *page = NULL;
+	struct page *stale = NULL;
 
 	if (is_migration_entry(entry))
 		return 1;
@@ -587,7 +588,7 @@ int free_swap_and_cache(swp_entry_t entry)
 		if (swap_entry_free(p, entry) == 1) {
 			page = find_get_page(&swapper_space, entry.val);
 			if (page && !trylock_page(page)) {
-				page_cache_release(page);
+				stale = page;
 				page = NULL;
 			}
 		}
@@ -606,9 +607,38 @@ int free_swap_and_cache(swp_entry_t entry)
 		unlock_page(page);
 		page_cache_release(page);
 	}
+	if (stale) {
+		mem_cgroup_fixup_swapfree(stale);
+		page_cache_release(stale);
+	}
 	return p != NULL;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+int mem_cgroup_fixup_swapin(struct page *page)
+{
+	int ret = 0;
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageSwapCache(page));
+
+	if (mem_cgroup_disabled())
+		return 0;
+
+	/* Used only by SwapCache ? */
+	if (unlikely(!page_swapcount(page))) {
+		get_page(page);
+		ret = remove_mapping(&swapper_space, page);
+		if (ret)
+			/* should be unlocked before beeing freed */
+			unlock_page(page);
+		page_cache_release(page);
+	}
+
+	return ret;
+}
+#endif
+
 #ifdef CONFIG_HIBERNATION
 /*
  * Find the swap type that corresponds to given device (if any).
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eac9577..640bfb6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -785,6 +785,14 @@ activate_locked:
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
+		if (!scanning_global_lru(sc) && PageSwapCache(page))
+			/*
+			 * Free !PageCgroupUsed SwapCache here, because memcg
+			 * cannot handle these SwapCache well.
+			 * This can happen if the page is freed by the owner
+			 * process before it is added to SwapCache.
+			 */
+			mem_cgroup_free_unused_swapcache(page);
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
