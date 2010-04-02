Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4118E62008F
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 20:46:27 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 31 of 41] memcg compound
Message-Id: <1bc2a33b3bbea7bf2082.1270168918@v2.random>
In-Reply-To: <patchbomb.1270168887@v2.random>
References: <patchbomb.1270168887@v2.random>
Date: Fri, 02 Apr 2010 02:41:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Teach memcg to charge/uncharge compound pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -4,6 +4,10 @@ NOTE: The Memory Resource Controller has
 to as the memory controller in this document. Do not confuse memory controller
 used here with the memory controller that is used in hardware.
 
+NOTE: When in this documentation we refer to PAGE_SIZE, we actually
+mean the real page size of the page being accounted which is bigger than
+PAGE_SIZE for compound pages.
+
 Salient features
 
 a. Enable control of Anonymous, Page Cache (mapped and unmapped) and
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1577,12 +1577,14 @@ static int __cpuinit memcg_stock_cpu_cal
  * oom-killer can be invoked.
  */
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
-			gfp_t gfp_mask, struct mem_cgroup **memcg, bool oom)
+				   gfp_t gfp_mask,
+				   struct mem_cgroup **memcg, bool oom,
+				   int page_size)
 {
 	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct res_counter *fail_res;
-	int csize = CHARGE_SIZE;
+	int csize = max(CHARGE_SIZE, (unsigned long) page_size);
 
 	/*
 	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
@@ -1617,8 +1619,9 @@ static int __mem_cgroup_try_charge(struc
 		int ret = 0;
 		unsigned long flags = 0;
 
-		if (consume_stock(mem))
-			goto done;
+		if (page_size == PAGE_SIZE)
+			if (consume_stock(mem))
+				goto done;
 
 		ret = res_counter_charge(&mem->res, csize, &fail_res);
 		if (likely(!ret)) {
@@ -1638,8 +1641,8 @@ static int __mem_cgroup_try_charge(struc
 									res);
 
 		/* reduce request size and retry */
-		if (csize > PAGE_SIZE) {
-			csize = PAGE_SIZE;
+		if (csize > page_size) {
+			csize = page_size;
 			continue;
 		}
 		if (!(gfp_mask & __GFP_WAIT))
@@ -1715,8 +1718,10 @@ static int __mem_cgroup_try_charge(struc
 			goto bypass;
 		}
 	}
-	if (csize > PAGE_SIZE)
-		refill_stock(mem, csize - PAGE_SIZE);
+	if (csize > page_size)
+		refill_stock(mem, csize - page_size);
+	if (page_size != PAGE_SIZE)
+		__css_get(&mem->css, page_size);
 done:
 	return 0;
 nomem:
@@ -1746,9 +1751,10 @@ static void __mem_cgroup_cancel_charge(s
 	/* we don't need css_put for root */
 }
 
-static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
+static void mem_cgroup_cancel_charge(struct mem_cgroup *mem,
+				     int page_size)
 {
-	__mem_cgroup_cancel_charge(mem, 1);
+	__mem_cgroup_cancel_charge(mem, page_size >> PAGE_SHIFT);
 }
 
 /*
@@ -1804,8 +1810,9 @@ struct mem_cgroup *try_get_mem_cgroup_fr
  */
 
 static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
-				     struct page_cgroup *pc,
-				     enum charge_type ctype)
+				       struct page_cgroup *pc,
+				       enum charge_type ctype,
+				       int page_size)
 {
 	/* try_charge() can return NULL to *memcg, taking care of it. */
 	if (!mem)
@@ -1814,7 +1821,7 @@ static void __mem_cgroup_commit_charge(s
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		mem_cgroup_cancel_charge(mem);
+		mem_cgroup_cancel_charge(mem, page_size);
 		return;
 	}
 
@@ -1891,7 +1898,7 @@ static void __mem_cgroup_move_account(st
 	mem_cgroup_charge_statistics(from, pc, false);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
-		mem_cgroup_cancel_charge(from);
+		mem_cgroup_cancel_charge(from, PAGE_SIZE);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
@@ -1952,13 +1959,14 @@ static int mem_cgroup_move_parent(struct
 		goto put;
 
 	parent = mem_cgroup_from_cont(pcg);
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false,
+				      PAGE_SIZE);
 	if (ret || !parent)
 		goto put_back;
 
 	ret = mem_cgroup_move_account(pc, child, parent, true);
 	if (ret)
-		mem_cgroup_cancel_charge(parent);
+		mem_cgroup_cancel_charge(parent, PAGE_SIZE);
 put_back:
 	putback_lru_page(page);
 put:
@@ -1980,6 +1988,10 @@ static int mem_cgroup_charge_common(stru
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
 	int ret;
+	int page_size = PAGE_SIZE;
+
+	if (PageTransHuge(page))
+		page_size <<= compound_order(page);
 
 	pc = lookup_page_cgroup(page);
 	/* can happen at boot */
@@ -1988,11 +2000,11 @@ static int mem_cgroup_charge_common(stru
 	prefetchw(pc);
 
 	mem = memcg;
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true, page_size);
 	if (ret || !mem)
 		return ret;
 
-	__mem_cgroup_commit_charge(mem, pc, ctype);
+	__mem_cgroup_commit_charge(mem, pc, ctype, page_size);
 	return 0;
 }
 
@@ -2001,8 +2013,6 @@ int mem_cgroup_newpage_charge(struct pag
 {
 	if (mem_cgroup_disabled())
 		return 0;
-	if (PageCompound(page))
-		return 0;
 	/*
 	 * If already mapped, we don't have to account.
 	 * If page cache, page->mapping has address_space.
@@ -2015,7 +2025,7 @@ int mem_cgroup_newpage_charge(struct pag
 	if (unlikely(!mm))
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
+					MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
 static void
@@ -2108,14 +2118,14 @@ int mem_cgroup_try_charge_swapin(struct 
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true, PAGE_SIZE);
 	/* drop extra refcnt from tryget */
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
-	return __mem_cgroup_try_charge(mm, mask, ptr, true);
+	return __mem_cgroup_try_charge(mm, mask, ptr, true, PAGE_SIZE);
 }
 
 static void
@@ -2131,7 +2141,7 @@ __mem_cgroup_commit_charge_swapin(struct
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
 	mem_cgroup_lru_del_before_commit_swapcache(page);
-	__mem_cgroup_commit_charge(ptr, pc, ctype);
+	__mem_cgroup_commit_charge(ptr, pc, ctype, PAGE_SIZE);
 	mem_cgroup_lru_add_after_commit_swapcache(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
@@ -2180,11 +2190,12 @@ void mem_cgroup_cancel_charge_swapin(str
 		return;
 	if (!mem)
 		return;
-	mem_cgroup_cancel_charge(mem);
+	mem_cgroup_cancel_charge(mem, PAGE_SIZE);
 }
 
 static void
-__do_uncharge(struct mem_cgroup *mem, const enum charge_type ctype)
+__do_uncharge(struct mem_cgroup *mem, const enum charge_type ctype,
+	      int page_size)
 {
 	struct memcg_batch_info *batch = NULL;
 	bool uncharge_memsw = true;
@@ -2219,14 +2230,14 @@ __do_uncharge(struct mem_cgroup *mem, co
 	if (batch->memcg != mem)
 		goto direct_uncharge;
 	/* remember freed charge and uncharge it later */
-	batch->bytes += PAGE_SIZE;
+	batch->bytes += page_size;
 	if (uncharge_memsw)
-		batch->memsw_bytes += PAGE_SIZE;
+		batch->memsw_bytes += page_size;
 	return;
 direct_uncharge:
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	res_counter_uncharge(&mem->res, page_size);
 	if (uncharge_memsw)
-		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+		res_counter_uncharge(&mem->memsw, page_size);
 	if (unlikely(batch->memcg != mem))
 		memcg_oom_recover(mem);
 	return;
@@ -2241,6 +2252,10 @@ __mem_cgroup_uncharge_common(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
+	int page_size = PAGE_SIZE;
+
+	if (PageTransHuge(page))
+		page_size <<= compound_order(page);
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2280,7 +2295,7 @@ __mem_cgroup_uncharge_common(struct page
 	}
 
 	if (!mem_cgroup_is_root(mem))
-		__do_uncharge(mem, ctype);
+		__do_uncharge(mem, ctype, page_size);
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		mem_cgroup_swap_statistics(mem, true);
 	mem_cgroup_charge_statistics(mem, pc, false);
@@ -2506,7 +2521,8 @@ int mem_cgroup_prepare_migration(struct 
 	unlock_page_cgroup(pc);
 
 	if (mem) {
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false,
+					      PAGE_SIZE);
 		css_put(&mem->css);
 	}
 	*ptr = mem;
@@ -2549,7 +2565,7 @@ void mem_cgroup_end_migration(struct mem
 	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
 	 * So, double-counting is effectively avoided.
 	 */
-	__mem_cgroup_commit_charge(mem, pc, ctype);
+	__mem_cgroup_commit_charge(mem, pc, ctype, PAGE_SIZE);
 
 	/*
 	 * Both of oldpage and newpage are still under lock_page().
@@ -4144,7 +4160,8 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false,
+					      PAGE_SIZE);
 		if (ret || !mem)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return -ENOMEM;
@@ -4259,6 +4276,7 @@ static int mem_cgroup_count_precharge_pt
 	pte_t *pte;
 	spinlock_t *ptl;
 
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
 		if (is_target_pte_for_mc(vma, addr, *pte, NULL))
@@ -4407,6 +4425,7 @@ static int mem_cgroup_move_charge_pte_ra
 	spinlock_t *ptl;
 
 retry:
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; addr += PAGE_SIZE) {
 		pte_t ptent = *(pte++);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
