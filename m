Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB34nbjV015315
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 13:49:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB82D45DE50
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:49:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9237F45DD77
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:49:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 72A3C1DB803B
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:49:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D1BB1DB803F
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:49:37 +0900 (JST)
Date: Wed, 3 Dec 2008 13:48:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  1/21] memcg-revert-gfp-mask-fix.patch
Message-Id: <20081203134848.04b7bac6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

My patch, memcg-fix-gfp_mask-of-callers-of-charge.patch changed gfp_mask
of callers of charge to be GFP_HIGHUSER_MOVABLE for showing what will happen
at memory reclaim.

But in recent discussion, it's NACKed because it sounds ugly.

This patch is for reverting it and add some clean up to gfp_mask of callers
of charge. No behavior change but need review before generating HUNK in deep
queue.

This patch also adds explanation to meaning of gfp_mask passed to charge
functions in memcontrol.h.

Singned-off-by:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/memcontrol.h |   10 ++++++++++
 mm/filemap.c               |    2 +-
 mm/memcontrol.c            |   10 +++++-----
 mm/memory.c                |   10 ++++------
 mm/shmem.c                 |    8 ++++----
 mm/swapfile.c              |    3 +--
 6 files changed, 25 insertions(+), 18 deletions(-)

Index: mmotm-2.6.28-Dec02/mm/filemap.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/filemap.c
+++ mmotm-2.6.28-Dec02/mm/filemap.c
@@ -461,7 +461,7 @@ int add_to_page_cache_locked(struct page
 	VM_BUG_ON(!PageLocked(page));
 
 	error = mem_cgroup_cache_charge(page, current->mm,
-					gfp_mask & ~__GFP_HIGHMEM);
+					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
 		goto out;
 
Index: mmotm-2.6.28-Dec02/mm/memory.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memory.c
+++ mmotm-2.6.28-Dec02/mm/memory.c
@@ -1967,7 +1967,7 @@ gotten:
 	cow_user_page(new_page, old_page, address, vma);
 	__SetPageUptodate(new_page);
 
-	if (mem_cgroup_newpage_charge(new_page, mm, GFP_HIGHUSER_MOVABLE))
+	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
 	/*
@@ -2398,8 +2398,7 @@ static int do_swap_page(struct mm_struct
 	lock_page(page);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
-	if (mem_cgroup_try_charge_swapin(mm, page,
-				GFP_HIGHUSER_MOVABLE, &ptr) == -ENOMEM) {
+	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
 		ret = VM_FAULT_OOM;
 		unlock_page(page);
 		goto out;
@@ -2491,7 +2490,7 @@ static int do_anonymous_page(struct mm_s
 		goto oom;
 	__SetPageUptodate(page);
 
-	if (mem_cgroup_newpage_charge(page, mm, GFP_HIGHUSER_MOVABLE))
+	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))
 		goto oom_free_page;
 
 	entry = mk_pte(page, vma->vm_page_prot);
@@ -2582,8 +2581,7 @@ static int __do_fault(struct mm_struct *
 				ret = VM_FAULT_OOM;
 				goto out;
 			}
-			if (mem_cgroup_newpage_charge(page,
-						mm, GFP_HIGHUSER_MOVABLE)) {
+			if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
 				ret = VM_FAULT_OOM;
 				page_cache_release(page);
 				goto out;
Index: mmotm-2.6.28-Dec02/mm/swapfile.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/swapfile.c
+++ mmotm-2.6.28-Dec02/mm/swapfile.c
@@ -698,8 +698,7 @@ static int unuse_pte(struct vm_area_stru
 	pte_t *pte;
 	int ret = 1;
 
-	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page,
-					GFP_HIGHUSER_MOVABLE, &ptr))
+	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL, &ptr))
 		ret = -ENOMEM;
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
Index: mmotm-2.6.28-Dec02/mm/shmem.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/shmem.c
+++ mmotm-2.6.28-Dec02/mm/shmem.c
@@ -924,8 +924,8 @@ found:
 	 * Charge page using GFP_HIGHUSER_MOVABLE while we can wait.
 	 * charged back to the user(not to caller) when swap account is used.
 	 */
-	error = mem_cgroup_cache_charge_swapin(page,
-			current->mm, GFP_HIGHUSER_MOVABLE, true);
+	error = mem_cgroup_cache_charge_swapin(page, current->mm, GFP_KERNEL,
+					true);
 	if (error)
 		goto out;
 	error = radix_tree_preload(GFP_KERNEL);
@@ -1267,7 +1267,7 @@ repeat:
 			 * charge against this swap cache here.
 			 */
 			if (mem_cgroup_cache_charge_swapin(swappage,
-						current->mm, gfp, false)) {
+				current->mm, gfp & GFP_RECLAIM_MASK, false)) {
 				page_cache_release(swappage);
 				error = -ENOMEM;
 				goto failed;
@@ -1385,7 +1385,7 @@ repeat:
 
 			/* Precharge page while we can wait, compensate after */
 			error = mem_cgroup_cache_charge(filepage, current->mm,
-					GFP_HIGHUSER_MOVABLE);
+					GFP_KERNEL);
 			if (error) {
 				page_cache_release(filepage);
 				shmem_unacct_blocks(info->flags, 1);
Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -1248,7 +1248,7 @@ int mem_cgroup_prepare_migration(struct 
 	unlock_page_cgroup(pc);
 
 	if (mem) {
-		ret = mem_cgroup_try_charge(NULL, GFP_HIGHUSER_MOVABLE, &mem);
+		ret = mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem);
 		css_put(&mem->css);
 	}
 	*ptr = mem;
@@ -1378,7 +1378,7 @@ static int mem_cgroup_resize_limit(struc
 			break;
 
 		progress = try_to_free_mem_cgroup_pages(memcg,
-				GFP_HIGHUSER_MOVABLE, false);
+				GFP_KERNEL, false);
   		if (!progress)			retry_count--;
 	}
 	return ret;
@@ -1418,7 +1418,7 @@ int mem_cgroup_resize_memsw_limit(struct
 			break;
 
 		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
-		try_to_free_mem_cgroup_pages(memcg, GFP_HIGHUSER_MOVABLE, true);
+		try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL, true);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		if (curusage >= oldusage)
 			retry_count--;
@@ -1464,7 +1464,7 @@ static int mem_cgroup_force_empty_list(s
 		}
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-		ret = mem_cgroup_move_parent(pc, mem, GFP_HIGHUSER_MOVABLE);
+		ret = mem_cgroup_move_parent(pc, mem, GFP_KERNEL);
 		if (ret == -ENOMEM)
 			break;
 
@@ -1550,7 +1550,7 @@ try_to_free:
 			goto out;
 		}
 		progress = try_to_free_mem_cgroup_pages(mem,
-						  GFP_HIGHUSER_MOVABLE, false);
+						  GFP_KERNEL, false);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
Index: mmotm-2.6.28-Dec02/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Dec02.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Dec02/include/linux/memcontrol.h
@@ -26,6 +26,16 @@ struct page;
 struct mm_struct;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/*
+ * All "charge" functions with gfp_mask should use GFP_KERNEL or
+ * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
+ * alloc memory but reclaims memory from all available zones. So, "where I want
+ * memory from" bits of gfp_mask has no meaning. So any bits of that field is
+ * available but adding a rule is better. charge functions' gfp_mask should
+ * be set to GFP_KERNEL or gfp_mask & GFP_RECLAIM_MASK for avoiding ambiguous
+ * codes.
+ * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
+ */
 
 extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
