Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 24B5E6B009D
	for <linux-mm@kvack.org>; Fri, 15 May 2009 00:21:56 -0400 (EDT)
Date: Fri, 15 May 2009 13:09:59 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH] memcg: fix stale swapcache at swapout
Message-Id: <20090515130959.330dbd56.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch is split out from Kamezawa-san's fix stale swap cache account leak
patch set(v7).

  http://lkml.org/lkml/2009/5/11/688

I moved the definition of memcg_free_unused_swapcache() back to memcontrol.c
(as I did in my original version) to avoid confilict with
Kosaki-san's remove CONFIG_UNEVICTABLE_LRU config option patch.
(it's not on mmotm yet though).
And IMHO, this function might not be appropriate for "vmscan".

This patch is based on mmotm-2009-05-13-16-34.
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Reclaiming anonymous memory in vmscan.c does following 2 steps.
  1. add to swap and unmap.
  2. pageout
But above 2 steps doesn't occur at once. There are many chances
to avoid pageout, and _really_ unused pages are swapped out by
visit-and-check-again logic of LRU rotation.

But this behavior has troubles with memcg because memcg doesn't put
!PageCgroupUsed swapcache back to its LRU.
These swapcache cannot be freed in memcg's LRU scanning, so swp_entry cannot
be freed properly as a result.

These swapcaches can be created by a race like below:

    Assume processA is exiting and pte points to a page(!PageSwapCache).
    And processB is trying reclaim the page.

              processA                   |           processB
    -------------------------------------+-------------------------------------
      (page_remove_rmap())               |  (shrink_page_list())
         mem_cgroup_uncharge_page()      |
            ->uncharged because it's not |
              PageSwapCache yet.         |
              So, both mem/memsw.usage   |
              are decremented.           |
                                         |    add_to_swap() -> added to swapcache.

    If this page goes thorough without being freed for some reason, this page
    doesn't goes back to memcg's LRU because of !PageCgroupUsed.

This patch adds a hook after add_to_swap() to check the page is mapped by a
process or not, and frees it if it has been unmapped already.

If a page has been on swap cache already when the owner process calls
page_remove_rmap() -> mem_cgroup_uncharge_page(), the page is not uncharged.
It goes back to memcg's LRU even if it goes through shrink_page_list()
without being freed, so this patch ignores these case.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/swap.h |   12 ++++++++++++
 mm/memcontrol.c      |   14 +++++++++++++-
 mm/vmscan.c          |    8 ++++++++
 3 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 6ea541d..00d8066 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -336,11 +336,17 @@ static inline void disable_swap_token(void)
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern int memcg_free_unused_swapcache(struct page *page);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
 }
+static inline int
+memcg_free_unused_swapcache(struct page *page)
+{
+	return 0;
+}
 #endif
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
@@ -436,6 +442,12 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
 }
 
+static inline int
+memcg_free_unused_swapcache(struct page *page)
+{
+	return 0;
+}
+
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0c90345..63844cd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1578,7 +1578,19 @@ void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 	if (memcg)
 		css_put(&memcg->css);
 }
-#endif
+
+int memcg_free_unused_swapcache(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageSwapCache(page));
+
+	if (mem_cgroup_disabled())
+		return 0;
+	if (!PageAnon(page) || page_mapped(page))
+		return 0;
+	return try_to_free_swap(page);	/* checks page_swapcount */
+}
+#endif /* CONFIG_SWAP */
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2f9d555..1fd0e43 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -665,6 +665,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			if (!add_to_swap(page))
 				goto activate_locked;
+			/*
+			 * The owner process might have uncharged the page
+			 * (by page_remove_rmap()) before it has been added
+			 * to swap cache.
+			 * Check it here to avoid making it stale.
+			 */
+			if (memcg_free_unused_swapcache(page))
+				goto keep_locked;
 			may_enter_fs = 1;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
