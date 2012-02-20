Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id E64FC6B010A
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:36:02 -0500 (EST)
Received: by dadv6 with SMTP id v6so7620960dad.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:36:02 -0800 (PST)
Date: Mon, 20 Feb 2012 15:35:38 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 7/10] mm/memcg: remove mem_cgroup_reset_owner
In-Reply-To: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202201534340.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With mem_cgroup_reset_uncharged_to_root() now making sure that freed
pages point to root_mem_cgroup (instead of to a stale and perhaps
long-deleted memcg), we no longer need to initialize page memcg to
root in those odd places which put a page on lru before charging. 
Delete mem_cgroup_reset_owner().

But: we have no init_page_cgroup() nowadays (and even when we had,
it was called before root_mem_cgroup had been allocated); so until
a struct page has once entered the memcg lru cycle, its page_cgroup
->mem_cgroup will be NULL instead of root_mem_cgroup.

That could be fixed by reintroducing init_page_cgroup(), and ordering
properly: in future we shall probably want root_mem_cgroup in kernel
bss or data like swapper_space; but let's not get into that right now.

Instead allow for this in page_relock_lruvec(): treating NULL as
root_mem_cgroup, and correcting pc->mem_cgroup before going further.

What?  Before even taking the zone->lru_lock?  Is that safe?
Yes, because compaction and lumpy reclaim use __isolate_lru_page(),
which refuses unless it sees PageLRU - which may be cleared at any
instant, but we only need it to have been set once in the past for
pc->mem_cgroup to be initialized properly.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    5 -----
 mm/ksm.c                   |   11 -----------
 mm/memcontrol.c            |   23 ++++++-----------------
 mm/migrate.c               |    2 --
 mm/swap_state.c            |   10 ----------
 5 files changed, 6 insertions(+), 45 deletions(-)

--- mmotm.orig/include/linux/memcontrol.h	2012-02-18 11:57:49.103524745 -0800
+++ mmotm/include/linux/memcontrol.h	2012-02-18 11:57:55.551524898 -0800
@@ -120,7 +120,6 @@ extern void mem_cgroup_print_oom_info(st
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
 					struct page *newpage);
 
-extern void mem_cgroup_reset_owner(struct page *page);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -383,10 +382,6 @@ static inline void mem_cgroup_replace_pa
 				struct page *newpage)
 {
 }
-
-static inline void mem_cgroup_reset_owner(struct page *page)
-{
-}
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
--- mmotm.orig/mm/ksm.c	2012-02-18 11:56:23.435522709 -0800
+++ mmotm/mm/ksm.c	2012-02-18 11:57:55.551524898 -0800
@@ -28,7 +28,6 @@
 #include <linux/kthread.h>
 #include <linux/wait.h>
 #include <linux/slab.h>
-#include <linux/memcontrol.h>
 #include <linux/rbtree.h>
 #include <linux/memory.h>
 #include <linux/mmu_notifier.h>
@@ -1572,16 +1571,6 @@ struct page *ksm_does_need_to_copy(struc
 
 	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 	if (new_page) {
-		/*
-		 * The memcg-specific accounting when moving
-		 * pages around the LRU lists relies on the
-		 * page's owner (memcg) to be valid.  Usually,
-		 * pages are assigned to a new owner before
-		 * being put on the LRU list, but since this
-		 * is not the case here, the stale owner from
-		 * a previous allocation cycle must be reset.
-		 */
-		mem_cgroup_reset_owner(new_page);
 		copy_user_highpage(new_page, page, address, vma);
 
 		SetPageDirty(new_page);
--- mmotm.orig/mm/memcontrol.c	2012-02-18 11:57:49.107524745 -0800
+++ mmotm/mm/memcontrol.c	2012-02-18 11:57:55.551524898 -0800
@@ -1053,6 +1053,12 @@ void page_relock_lruvec(struct page *pag
 	else {
 		pc = lookup_page_cgroup(page);
 		memcg = pc->mem_cgroup;
+		/*
+		 * At present we start up with all page_cgroups initialized
+		 * to zero: correct that to root_mem_cgroup once we see it.
+		 */
+		if (unlikely(!memcg))
+			memcg = pc->mem_cgroup = root_mem_cgroup;
 		mz = page_cgroup_zoneinfo(memcg, page);
 		lruvec = &mz->lruvec;
 	}
@@ -3038,23 +3044,6 @@ void mem_cgroup_uncharge_end(void)
 	batch->memcg = NULL;
 }
 
-/*
- * A function for resetting pc->mem_cgroup for newly allocated pages.
- * This function should be called if the newpage will be added to LRU
- * before start accounting.
- */
-void mem_cgroup_reset_owner(struct page *newpage)
-{
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(newpage);
-	VM_BUG_ON(PageCgroupUsed(pc));
-	pc->mem_cgroup = root_mem_cgroup;
-}
-
 #ifdef CONFIG_SWAP
 /*
  * called after __delete_from_swap_cache() and drop "page" account.
--- mmotm.orig/mm/migrate.c	2012-02-18 11:56:23.435522709 -0800
+++ mmotm/mm/migrate.c	2012-02-18 11:57:55.551524898 -0800
@@ -839,8 +839,6 @@ static int unmap_and_move(new_page_t get
 	if (!newpage)
 		return -ENOMEM;
 
-	mem_cgroup_reset_owner(newpage);
-
 	if (page_count(page) == 1) {
 		/* page was freed from under us. So we are done. */
 		goto out;
--- mmotm.orig/mm/swap_state.c	2012-02-18 11:56:23.435522709 -0800
+++ mmotm/mm/swap_state.c	2012-02-18 11:57:55.551524898 -0800
@@ -300,16 +300,6 @@ struct page *read_swap_cache_async(swp_e
 			new_page = alloc_page_vma(gfp_mask, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
-			/*
-			 * The memcg-specific accounting when moving
-			 * pages around the LRU lists relies on the
-			 * page's owner (memcg) to be valid.  Usually,
-			 * pages are assigned to a new owner before
-			 * being put on the LRU list, but since this
-			 * is not the case here, the stale owner from
-			 * a previous allocation cycle must be reset.
-			 */
-			mem_cgroup_reset_owner(new_page);
 		}
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
