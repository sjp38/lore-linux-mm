Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 98B1C6B009C
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 00:17:44 -0400 (EDT)
Date: Mon, 23 Mar 2009 14:12:26 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [cleanup][PATCH mmotm] memcg: cleanup cache_charge
Message-Id: <20090323141226.68be59ec.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Current mem_cgroup_cache_charge is a bit complicated especially
in the case of shmem's swap-in.

This patch cleans it up by using try_charge_swapin and commit_charge_swapin.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   60 +++++++++++++++++++++---------------------------------
 1 files changed, 23 insertions(+), 37 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 55dea59..2fc6d6c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1238,6 +1238,10 @@ int mem_cgroup_newpage_charge(struct page *page,
 				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
+static void
+__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
+					enum charge_type ctype);
+
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
@@ -1274,16 +1278,6 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 		unlock_page_cgroup(pc);
 	}
 
-	if (do_swap_account && PageSwapCache(page)) {
-		mem = try_get_mem_cgroup_from_swapcache(page);
-		if (mem)
-			mm = NULL;
-		  else
-			mem = NULL;
-		/* SwapCache may be still linked to LRU now. */
-		mem_cgroup_lru_del_before_commit_swapcache(page);
-	}
-
 	if (unlikely(!mm && !mem))
 		mm = &init_mm;
 
@@ -1291,32 +1285,16 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 		return mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
 
-	ret = mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
-	if (mem)
-		css_put(&mem->css);
-	if (PageSwapCache(page))
-		mem_cgroup_lru_add_after_commit_swapcache(page);
+	/* shmem */
+	if (PageSwapCache(page)) {
+		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
+		if (!ret)
+			__mem_cgroup_commit_charge_swapin(page, mem,
+					MEM_CGROUP_CHARGE_TYPE_SHMEM);
+	} else
+		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
+					MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
 
-	if (do_swap_account && !ret && PageSwapCache(page)) {
-		swp_entry_t ent = {.val = page_private(page)};
-		unsigned short id;
-		/* avoid double counting */
-		id = swap_cgroup_record(ent, 0);
-		rcu_read_lock();
-		mem = mem_cgroup_lookup(id);
-		if (mem) {
-			/*
-			 * We did swap-in. Then, this entry is doubly counted
-			 * both in mem and memsw. We uncharge it, here.
-			 * Recorded ID can be obsolete. We avoid calling
-			 * css_tryget()
-			 */
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
-			mem_cgroup_put(mem);
-		}
-		rcu_read_unlock();
-	}
 	return ret;
 }
 
@@ -1359,7 +1337,9 @@ charge_cur_mm:
 	return __mem_cgroup_try_charge(mm, mask, ptr, true);
 }
 
-void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
+static void
+__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
+					enum charge_type ctype)
 {
 	struct page_cgroup *pc;
 
@@ -1369,7 +1349,7 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 		return;
 	pc = lookup_page_cgroup(page);
 	mem_cgroup_lru_del_before_commit_swapcache(page);
-	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
+	__mem_cgroup_commit_charge(ptr, pc, ctype);
 	mem_cgroup_lru_add_after_commit_swapcache(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
@@ -1400,6 +1380,12 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 
 }
 
+void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
+{
+	__mem_cgroup_commit_charge_swapin(page, ptr,
+					MEM_CGROUP_CHARGE_TYPE_MAPPED);
+}
+
 void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 {
 	if (mem_cgroup_disabled())

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
