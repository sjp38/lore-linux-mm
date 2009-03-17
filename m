Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 57BAB6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 01:10:47 -0400 (EDT)
Date: Tue, 17 Mar 2009 13:57:02 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC] memcg: handle swapcache leak
Message-Id: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

There are (at least) 2 types(described later) of swapcache leak in current memcg.

I mean by "swapcache leak" a swapcache which:
  a. the process that used the page has already exited(or
     unmapped the page).
  b. is not linked to memcg's LRU because the page is !PageCgroupUsed.

So, only the global page reclaim or swapoff can free these leaked swapcaches.
This means memcg's memory pressure can use up all swap entries if
the memory size of the system is greater than that of swap.

1. race between exit and swap-in
  Assume processA is exitting and processB is doing swap-in.

  If some pages of processA has been swapped out, it calls free_swap_and_cache().
  And if at the same time, processB is calling read_swap_cache_async() about
  a swap entry *that is used by processA*, a race like below can happen.

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

  This type of leak can be avoided by setting /proc/sys/vm/page-cluster to 0.

  And this type of leaked swapcaches have been charged as swap,
  so swap entries of them have reference to the associated memcg
  and the refcnt of the memcg has been incremented.
  As a result this memcg cannot be free'ed until global page reclaim
  frees this swapcache or swapoff is executed.

  Actually, I saw "struct mem_cgroup leak"(checked by "grep kmalloc-1024 /proc/slabinfo")
  in my test, where I create a new directory, move all tasks to the new
  directory, and remove the old directory under memcg's memory pressure.
  And, this "struct mem_cgroup leak" didn't happen with setting
  /proc/sys/vm/page-cluster to 0.

2. race between exit and swap-out
  If page_remove_rmap() is called by the owner process about an anonymous
  page(not on swapchache, so uncharged here) before shrink_page_list() adds
  the page to swapcache, this page becomes a swapcache with !PageCgroupUsed.

  And if this swapcache is not free'ed by shrink_page_list(), it goes back
  to global LRU, but doesn't go back to memcg's LRU because the page is
  !PageCgroupUsed.

  This type of leak can be avoided by modifying shrink_page_list() like:

===
@@ -775,6 +776,21 @@ activate_locked:
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
+		if (!scanning_global_lru(sc) && PageSwapCache(page)) {
+			struct page_cgroup *pc;
+
+			pc = lookup_page_cgroup(page);
+			/*
+			 * Used bit of swapcache is solid under page lock.
+			 */
+			if (unlikely(!PageCgroupUsed(pc)))
+				/*
+				 * This can happen if the page is unmapped by
+				 * the owner process before it is added to
+				 * swapcache.
+				 */
+				try_to_free_swap(page);
+		}
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);
===


I've confirmed that no leak happens with this patch for shrink_page_list() applied
and setting /proc/sys/vm/page-cluster to 0 in a simple swap in/out test.
(I think I should check page migration and rmdir too.)

I think the root cause of these problem is that !PageCgroupUsed pages are not linked
to any memcg's LRU.
So, I'm tring to implement "dummy_memcg" to maintain !PageCgroupUsed pages now.

Any comments or suggestions would be welcome.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
