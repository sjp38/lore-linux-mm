Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB24KHaO017920
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 13:20:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4780045DE4F
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:20:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 21ABF45DE51
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:20:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E79431DB8037
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:20:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F9201DB8042
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:20:16 +0900 (JST)
Date: Tue, 2 Dec 2008 13:19:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH 2/4] replacement-for-memcg-handle-swap-caches.patch
Message-Id: <20081202131927.e93b779e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

SwapCache support for memory resource controller (memcg)

Before mem+swap controller, memcg itself should handle SwapCache in proper
way.  This is cut-out from it.

In current memcg, SwapCache is just leaked and the user can create tons of
SwapCache.  This is a leak of account and should be handled.

SwapCache accounting is done as following.

  charge (anon)
	- charged when it's mapped.
	  (because of readahead, charge at add_to_swap_cache() is not sane)
  uncharge (anon)
	- uncharged when it's dropped from swapcache and fully unmapped.
	  means it's not uncharged at unmap.
	  Note: delete from swap cache at swap-in is done after rmap information
	        is established.
  charge (shmem)
	- charged at swap-in. this prevents charge at add_to_page_cache().

  uncharge (shmem)
	- uncharged when it's dropped from swapcache and not on shmem's
	  radix-tree.

  at migration, check against 'old page' is modified to handle shmem.

Comparing to the old version discussed (and caused troubles), we have
advantages of
  - PCG_USED bit.
  - simple migrating handling.

So, situation is much easier than several months ago, maybe.

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
 Documentation/controllers/memory.txt |    5 ++
 include/linux/swap.h                 |   16 ++++++++
 mm/memcontrol.c                      |   67 +++++++++++++++++++++++++++++++----
 mm/shmem.c                           |   17 +++++++-
 mm/swap_state.c                      |    1 
 5 files changed, 98 insertions(+), 8 deletions(-)

Index: mmotm-2.6.28-Nov30/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.28-Nov30.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.28-Nov30/Documentation/controllers/memory.txt
@@ -137,6 +137,11 @@ behind this approach is that a cgroup th
 page will eventually get charged for it (once it is uncharged from
 the cgroup that brought it in -- this will happen on memory pressure).
 
+Exception: When you do swapoff and make swapped-out pages of shmem(tmpfs) to
+be backed into memory in force, charges for pages are accounted against the
+caller of swapoff rather than the users of shmem.
+
+
 2.4 Reclaim
 
 Each cgroup maintains a per cgroup LRU that consists of an active
Index: mmotm-2.6.28-Nov30/include/linux/swap.h
===================================================================
--- mmotm-2.6.28-Nov30.orig/include/linux/swap.h
+++ mmotm-2.6.28-Nov30/include/linux/swap.h
@@ -336,6 +336,22 @@ static inline void disable_swap_token(vo
 	put_swap_token(swap_token_mm);
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+extern int mem_cgroup_cache_charge_swapin(struct page *page,
+				struct mm_struct *mm, gfp_t mask, bool locked);
+extern void mem_cgroup_uncharge_swapcache(struct page *page);
+#else
+static inline
+int mem_cgroup_cache_charge_swapin(struct page *page,
+				struct mm_struct *mm, gfp_t mask, bool locked)
+{
+	return 0;
+}
+static inline void mem_cgroup_uncharge_swapcache(struct page *page)
+{
+}
+#endif
+
 #else /* CONFIG_SWAP */
 
 #define nr_swap_pages				0L
Index: mmotm-2.6.28-Nov30/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov30.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov30/mm/memcontrol.c
@@ -21,6 +21,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
+#include <linux/pagemap.h>
 #include <linux/smp.h>
 #include <linux/page-flags.h>
 #include <linux/backing-dev.h>
@@ -139,6 +140,7 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
+	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
 	NR_CHARGE_TYPE,
 };
 
@@ -780,6 +782,33 @@ int mem_cgroup_cache_charge(struct page 
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
+#ifdef CONFIG_SWAP
+int mem_cgroup_cache_charge_swapin(struct page *page,
+			struct mm_struct *mm, gfp_t mask, bool locked)
+{
+	int ret = 0;
+
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+	if (unlikely(!mm))
+		mm = &init_mm;
+	if (!locked)
+		lock_page(page);
+	/*
+	 * If not locked, the page can be dropped from SwapCache until
+	 * we reach here.
+	 */
+	if (PageSwapCache(page)) {
+		ret = mem_cgroup_charge_common(page, mm, mask,
+				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
+	}
+	if (!locked)
+		unlock_page(page);
+
+	return ret;
+}
+#endif
+
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 {
 	struct page_cgroup *pc;
@@ -817,6 +846,9 @@ __mem_cgroup_uncharge_common(struct page
 	if (mem_cgroup_subsys.disabled)
 		return;
 
+	if (PageSwapCache(page))
+		return;
+
 	/*
 	 * Check if our page_cgroup is valid
 	 */
@@ -825,12 +857,26 @@ __mem_cgroup_uncharge_common(struct page
 		return;
 
 	lock_page_cgroup(pc);
-	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED && page_mapped(page))
-	     || !PageCgroupUsed(pc)) {
-		/* This happens at race in zap_pte_range() and do_swap_page()*/
-		unlock_page_cgroup(pc);
-		return;
+
+	if (!PageCgroupUsed(pc))
+		goto unlock_out;
+
+	switch (ctype) {
+	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
+		if (page_mapped(page))
+			goto unlock_out;
+		break;
+	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
+		if (!PageAnon(page)) {	/* Shared memory */
+			if (page->mapping && !page_is_file_cache(page))
+				goto unlock_out;
+		} else if (page_mapped(page)) /* Anon */
+				goto unlock_out;
+		break;
+	default:
+		break;
 	}
+
 	ClearPageCgroupUsed(pc);
 	mem = pc->mem_cgroup;
 
@@ -844,6 +890,10 @@ __mem_cgroup_uncharge_common(struct page
 	css_put(&mem->css);
 
 	return;
+
+unlock_out:
+	unlock_page_cgroup(pc);
+	return;
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -863,6 +913,11 @@ void mem_cgroup_uncharge_cache_page(stru
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
+void mem_cgroup_uncharge_swapcache(struct page *page)
+{
+	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
+}
+
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
@@ -920,7 +975,7 @@ void mem_cgroup_end_migration(struct mem
 		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
 
 	/* unused page is not on radix-tree now. */
-	if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)
+	if (unused)
 		__mem_cgroup_uncharge_common(unused, ctype);
 
 	pc = lookup_page_cgroup(target);
Index: mmotm-2.6.28-Nov30/mm/shmem.c
===================================================================
--- mmotm-2.6.28-Nov30.orig/mm/shmem.c
+++ mmotm-2.6.28-Nov30/mm/shmem.c
@@ -920,8 +920,11 @@ found:
 	error = 1;
 	if (!inode)
 		goto out;
-	/* Precharge page using GFP_KERNEL while we can wait */
-	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
+	/*
+	 * Charged back to the user(not to caller) when swap account is used.
+	 */
+	error = mem_cgroup_cache_charge_swapin(page,
+			current->mm, GFP_KERNEL, true);
 	if (error)
 		goto out;
 	error = radix_tree_preload(GFP_KERNEL);
@@ -1258,6 +1261,16 @@ repeat:
 				goto repeat;
 			}
 			wait_on_page_locked(swappage);
+			/*
+			 * We want to avoid charge at add_to_page_cache().
+			 * charge against this swap cache here.
+			 */
+			if (mem_cgroup_cache_charge_swapin(swappage,
+						current->mm, gfp, false)) {
+				page_cache_release(swappage);
+				error = -ENOMEM;
+				goto failed;
+			}
 			page_cache_release(swappage);
 			goto repeat;
 		}
Index: mmotm-2.6.28-Nov30/mm/swap_state.c
===================================================================
--- mmotm-2.6.28-Nov30.orig/mm/swap_state.c
+++ mmotm-2.6.28-Nov30/mm/swap_state.c
@@ -118,6 +118,7 @@ void __delete_from_swap_cache(struct pag
 	total_swapcache_pages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
+	mem_cgroup_uncharge_swapcache(page);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
