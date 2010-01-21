Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A01D36B007D
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 01:51:28 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 27 of 30] memcg compound
Message-Id: <2f3ecb53039bd9ae8c7a.1264054851@v2.random>
In-Reply-To: <patchbomb.1264054824@v2.random>
References: <patchbomb.1264054824@v2.random>
Date: Thu, 21 Jan 2010 07:20:51 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Teach memcg to charge/uncharge compound pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1288,15 +1288,20 @@ static atomic_t memcg_drain_count;
  * cgroup which is not current target, returns false. This stock will be
  * refilled.
  */
-static bool consume_stock(struct mem_cgroup *mem)
+static bool consume_stock(struct mem_cgroup *mem, int *page_size)
 {
 	struct memcg_stock_pcp *stock;
 	bool ret = true;
 
 	stock = &get_cpu_var(memcg_stock);
-	if (mem == stock->cached && stock->charge)
-		stock->charge -= PAGE_SIZE;
-	else /* need to call res_counter_charge */
+	if (mem == stock->cached && stock->charge) {
+		if (*page_size > stock->charge) {
+			*page_size -= stock->charge;
+			stock->charge = 0;
+			ret = false;
+		} else
+			stock->charge -= *page_size;
+	} else /* need to call res_counter_charge */
 		ret = false;
 	put_cpu_var(memcg_stock);
 	return ret;
@@ -1401,13 +1406,13 @@ static int __cpuinit memcg_stock_cpu_cal
  * oom-killer can be invoked.
  */
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
-			gfp_t gfp_mask, struct mem_cgroup **memcg,
-			bool oom, struct page *page)
+				   gfp_t gfp_mask, struct mem_cgroup **memcg,
+				   bool oom, struct page *page, int page_size)
 {
 	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct res_counter *fail_res;
-	int csize = CHARGE_SIZE;
+	int csize = max(page_size, (int) CHARGE_SIZE);
 
 	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
 		/* Don't account this! */
@@ -1439,7 +1444,7 @@ static int __mem_cgroup_try_charge(struc
 		int ret = 0;
 		unsigned long flags = 0;
 
-		if (consume_stock(mem))
+		if (consume_stock(mem, &page_size))
 			goto charged;
 
 		ret = res_counter_charge(&mem->res, csize, &fail_res);
@@ -1460,8 +1465,8 @@ static int __mem_cgroup_try_charge(struc
 									res);
 
 		/* reduce request size and retry */
-		if (csize > PAGE_SIZE) {
-			csize = PAGE_SIZE;
+		if (csize > page_size) {
+			csize = page_size;
 			continue;
 		}
 		if (!(gfp_mask & __GFP_WAIT))
@@ -1491,8 +1496,8 @@ static int __mem_cgroup_try_charge(struc
 			goto nomem;
 		}
 	}
-	if (csize > PAGE_SIZE)
-		refill_stock(mem, csize - PAGE_SIZE);
+	if (csize > page_size)
+		refill_stock(mem, csize - page_size);
 charged:
 	/*
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
@@ -1512,12 +1517,12 @@ nomem:
  * This function is for that and do uncharge, put css's refcnt.
  * gotten by try_charge().
  */
-static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
+static void mem_cgroup_cancel_charge(struct mem_cgroup *mem, int page_size)
 {
 	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		res_counter_uncharge(&mem->res, page_size);
 		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			res_counter_uncharge(&mem->memsw, page_size);
 	}
 	css_put(&mem->css);
 }
@@ -1575,8 +1580,9 @@ struct mem_cgroup *try_get_mem_cgroup_fr
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
@@ -1585,7 +1591,7 @@ static void __mem_cgroup_commit_charge(s
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		mem_cgroup_cancel_charge(mem);
+		mem_cgroup_cancel_charge(mem, page_size);
 		return;
 	}
 
@@ -1722,7 +1728,8 @@ static int mem_cgroup_move_parent(struct
 		goto put;
 
 	parent = mem_cgroup_from_cont(pcg);
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page,
+		PAGE_SIZE);
 	if (ret || !parent)
 		goto put_back;
 
@@ -1730,7 +1737,7 @@ static int mem_cgroup_move_parent(struct
 	if (!ret)
 		css_put(&parent->css);	/* drop extra refcnt by try_charge() */
 	else
-		mem_cgroup_cancel_charge(parent);	/* does css_put */
+		mem_cgroup_cancel_charge(parent, PAGE_SIZE); /* does css_put */
 put_back:
 	putback_lru_page(page);
 put:
@@ -1752,6 +1759,11 @@ static int mem_cgroup_charge_common(stru
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
 	int ret;
+	int page_size = PAGE_SIZE;
+
+	VM_BUG_ON(PageTail(page));
+	if (PageHead(page))
+		page_size <<= compound_order(page);
 
 	pc = lookup_page_cgroup(page);
 	/* can happen at boot */
@@ -1760,11 +1772,12 @@ static int mem_cgroup_charge_common(stru
 	prefetchw(pc);
 
 	mem = memcg;
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true, page);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true, page,
+				      page_size);
 	if (ret || !mem)
 		return ret;
 
-	__mem_cgroup_commit_charge(mem, pc, ctype);
+	__mem_cgroup_commit_charge(mem, pc, ctype, page_size);
 	return 0;
 }
 
@@ -1773,8 +1786,6 @@ int mem_cgroup_newpage_charge(struct pag
 {
 	if (mem_cgroup_disabled())
 		return 0;
-	if (PageCompound(page))
-		return 0;
 	/*
 	 * If already mapped, we don't have to account.
 	 * If page cache, page->mapping has address_space.
@@ -1787,7 +1798,7 @@ int mem_cgroup_newpage_charge(struct pag
 	if (unlikely(!mm))
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
+					MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
 static void
@@ -1880,14 +1891,14 @@ int mem_cgroup_try_charge_swapin(struct 
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true, page);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true, page, PAGE_SIZE);
 	/* drop extra refcnt from tryget */
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
-	return __mem_cgroup_try_charge(mm, mask, ptr, true, page);
+	return __mem_cgroup_try_charge(mm, mask, ptr, true, page, PAGE_SIZE);
 }
 
 static void
@@ -1903,7 +1914,7 @@ __mem_cgroup_commit_charge_swapin(struct
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
 	mem_cgroup_lru_del_before_commit_swapcache(page);
-	__mem_cgroup_commit_charge(ptr, pc, ctype);
+	__mem_cgroup_commit_charge(ptr, pc, ctype, PAGE_SIZE);
 	mem_cgroup_lru_add_after_commit_swapcache(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
@@ -1952,11 +1963,12 @@ void mem_cgroup_cancel_charge_swapin(str
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
@@ -1989,14 +2001,14 @@ __do_uncharge(struct mem_cgroup *mem, co
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
 	return;
 }
 
@@ -2009,6 +2021,11 @@ __mem_cgroup_uncharge_common(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
+	int page_size = PAGE_SIZE;
+
+	VM_BUG_ON(PageTail(page));
+	if (PageHead(page))
+		page_size <<= compound_order(page);
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2016,6 +2033,8 @@ __mem_cgroup_uncharge_common(struct page
 	if (PageSwapCache(page))
 		return NULL;
 
+	VM_BUG_ON(PageTail(page));
+
 	/*
 	 * Check if our page_cgroup is valid
 	 */
@@ -2048,7 +2067,7 @@ __mem_cgroup_uncharge_common(struct page
 	}
 
 	if (!mem_cgroup_is_root(mem))
-		__do_uncharge(mem, ctype);
+		__do_uncharge(mem, ctype, page_size);
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		mem_cgroup_swap_statistics(mem, true);
 	mem_cgroup_charge_statistics(mem, pc, false);
@@ -2217,7 +2236,7 @@ int mem_cgroup_prepare_migration(struct 
 
 	if (mem) {
 		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false,
-						page);
+					      page, PAGE_SIZE);
 		css_put(&mem->css);
 	}
 	*ptr = mem;
@@ -2260,7 +2279,7 @@ void mem_cgroup_end_migration(struct mem
 	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
 	 * So, double-counting is effectively avoided.
 	 */
-	__mem_cgroup_commit_charge(mem, pc, ctype);
+	__mem_cgroup_commit_charge(mem, pc, ctype, PAGE_SIZE);
 
 	/*
 	 * Both of oldpage and newpage are still under lock_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
