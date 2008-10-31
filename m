Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9V2sk4H022554
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 31 Oct 2008 11:54:46 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CE4953C128
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:54:46 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EB9AD240060
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:54:45 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id D34E81DB803C
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:54:45 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BCA91DB803B
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:54:45 +0900 (JST)
Date: Fri, 31 Oct 2008 11:54:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/5] memcg : handle swap cache
Message-Id: <20081031115411.25478878.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

SwapCache support for memory resource controller (memcg)

Before mem+swap controller, memcg itself should handle SwapCache in proper way.

In current memcg, SwapCache is just leaked and the user can create tons of
SwapCache. This is leak of account and should be handled.

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

  at migartion, check against 'old page' is modified to handle shmem.

Compareing to the old version discussed (and caused troubles), we have
advanteges of
  - PCG_USED bit.
  - simple migraton handling.

So, situation is much easier than several months ago, maybe.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/controllers/memory.txt |    5 ++
 include/linux/swap.h                 |   16 ++++++++
 mm/memcontrol.c                      |   66 +++++++++++++++++++++++++++++++----
 mm/shmem.c                           |   18 ++++++++-
 mm/swap_state.c                      |    1 
 5 files changed, 98 insertions(+), 8 deletions(-)

Index: mmotm-2.6.28-rc2+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/memcontrol.c
+++ mmotm-2.6.28-rc2+/mm/memcontrol.c
@@ -21,6 +21,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
+#include <linux/pagemap.h>
 #include <linux/smp.h>
 #include <linux/page-flags.h>
 #include <linux/backing-dev.h>
@@ -140,6 +141,7 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
+	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
 	NR_CHARGE_TYPE,
 };
 
@@ -781,6 +783,32 @@ int mem_cgroup_cache_charge(struct page 
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
+#ifdef CONFIG_SWAP
+int mem_cgroup_cache_charge_swapin(struct page *page,
+			struct mm_struct *mm, gfp_t mask)
+{
+	int ret = 0;
+
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+	if (unlikely(!mm))
+		mm = &init_mm;
+
+	ret = mem_cgroup_charge_common(page, mm, mask,
+			MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
+	/*
+	 * The page may be dropped from SwapCache because we don't have
+	 * lock_page().This may cause charge-after-uncharge trouble.
+	 * Fix it up here. (the caller have refcnt to this page and
+	 * page itself is guaranteed not to be freed.)
+	 */
+	if (ret && !PageSwapCache(page))
+		mem_cgroup_uncharge_swapcache(page);
+
+	return ret;
+}
+#endif
+
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 {
 	struct page_cgroup *pc;
@@ -818,6 +846,9 @@ __mem_cgroup_uncharge_common(struct page
 	if (mem_cgroup_subsys.disabled)
 		return;
 
+	if (PageSwapCache(page))
+		return;
+
 	/*
 	 * Check if our page_cgroup is valid
 	 */
@@ -826,12 +857,26 @@ __mem_cgroup_uncharge_common(struct page
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
+	switch(ctype) {
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
 
@@ -845,6 +890,10 @@ __mem_cgroup_uncharge_common(struct page
 	css_put(&mem->css);
 
 	return;
+
+unlock_out:
+	unlock_page_cgroup(pc);
+	return;
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -864,6 +913,11 @@ void mem_cgroup_uncharge_cache_page(stru
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
@@ -921,7 +975,7 @@ void mem_cgroup_end_migration(struct mem
 		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
 
 	/* unused page is not on radix-tree now. */
-	if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)
+	if (unused)
 		__mem_cgroup_uncharge_common(unused, ctype);
 
 	pc = lookup_page_cgroup(target);
Index: mmotm-2.6.28-rc2+/mm/swap_state.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/swap_state.c
+++ mmotm-2.6.28-rc2+/mm/swap_state.c
@@ -119,6 +119,7 @@ void __delete_from_swap_cache(struct pag
 	total_swapcache_pages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
+	mem_cgroup_uncharge_swapcache(page);
 }
 
 /**
Index: mmotm-2.6.28-rc2+/include/linux/swap.h
===================================================================
--- mmotm-2.6.28-rc2+.orig/include/linux/swap.h
+++ mmotm-2.6.28-rc2+/include/linux/swap.h
@@ -332,6 +332,22 @@ static inline void disable_swap_token(vo
 	put_swap_token(swap_token_mm);
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+extern int mem_cgroup_cache_charge_swapin(struct page *page,
+				struct mm_struct *mm, gfp_t mask);
+extern void mem_cgroup_uncharge_swapcache(struct page *page);
+#else
+static inline
+int mem_cgroup_cache_charge_swapin(struct page *page,
+				    struct mm_struct *mm, gfp_t mask)
+{
+	return 0;
+}
+static inline void mem_cgroup_uncharge_swapcache(struct page *page)
+{
+}
+#endif
+
 #else /* CONFIG_SWAP */
 
 #define total_swap_pages			0
Index: mmotm-2.6.28-rc2+/mm/shmem.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/shmem.c
+++ mmotm-2.6.28-rc2+/mm/shmem.c
@@ -920,8 +920,12 @@ found:
 	error = 1;
 	if (!inode)
 		goto out;
-	/* Charge page using GFP_HIGHUSER_MOVABLE while we can wait */
-	error = mem_cgroup_cache_charge(page, current->mm, GFP_HIGHUSER_MOVABLE);
+	/*
+         * Charge page using GFP_HIGHUSER_MOVABLE while we can wait.
+         * charged back to the user(not to caller) when swap account is used.
+         */
+	error = mem_cgroup_cache_charge_swapin(page,
+			current->mm, GFP_HIGHUSER_MOVABLE);
 	if (error)
 		goto out;
 	error = radix_tree_preload(GFP_KERNEL);
@@ -1258,6 +1262,16 @@ repeat:
 				goto repeat;
 			}
 			wait_on_page_locked(swappage);
+			/*
+			 * We want to avoid charge at add_to_page_cache().
+			 * charge against this swap cache here.
+			 */
+			if (mem_cgroup_cache_charge_swapin(swappage,
+						current->mm, gfp)) {
+				page_cache_release(swappage);
+				error = -ENOMEM;
+				goto failed;
+			}
 			page_cache_release(swappage);
 			goto repeat;
 		}
Index: mmotm-2.6.28-rc2+/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.28-rc2+.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.28-rc2+/Documentation/controllers/memory.txt
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
