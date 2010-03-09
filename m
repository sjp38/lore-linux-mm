Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 91D836B00A1
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:44:33 -0500 (EST)
Message-Id: <20100309194316.921051285@redhat.com>
Date: Tue, 09 Mar 2010 20:39:33 +0100
From: aarcange@redhat.com
Subject: [patch 32/35] memcg compound
References: <20100309193901.207868642@redhat.com>
Content-Disposition: inline; filename=memcg_compound
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Teach memcg to charge/uncharge compound pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 Documentation/cgroups/memory.txt |    4 ++
 mm/memcontrol.c                  |   76 +++++++++++++++++++++++----------------
 2 files changed, 49 insertions(+), 31 deletions(-)

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
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1401,8 +1401,8 @@ static int __cpuinit memcg_stock_cpu_cal
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
@@ -1415,6 +1415,9 @@ static int __mem_cgroup_try_charge(struc
 		return 0;
 	}
 
+	if (PageTransHuge(page))
+		csize = page_size;
+
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -1439,8 +1442,9 @@ static int __mem_cgroup_try_charge(struc
 		int ret = 0;
 		unsigned long flags = 0;
 
-		if (consume_stock(mem))
-			goto charged;
+		if (!PageTransHuge(page))
+			if (consume_stock(mem))
+				goto charged;
 
 		ret = res_counter_charge(&mem->res, csize, &fail_res);
 		if (likely(!ret)) {
@@ -1460,7 +1464,7 @@ static int __mem_cgroup_try_charge(struc
 									res);
 
 		/* reduce request size and retry */
-		if (csize > PAGE_SIZE) {
+		if (csize > page_size) {
 			csize = PAGE_SIZE;
 			continue;
 		}
@@ -1491,7 +1495,7 @@ static int __mem_cgroup_try_charge(struc
 			goto nomem;
 		}
 	}
-	if (csize > PAGE_SIZE)
+	if (csize > page_size)
 		refill_stock(mem, csize - PAGE_SIZE);
 charged:
 	/*
@@ -1512,12 +1516,12 @@ nomem:
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
@@ -1575,8 +1579,9 @@ struct mem_cgroup *try_get_mem_cgroup_fr
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
@@ -1585,7 +1590,7 @@ static void __mem_cgroup_commit_charge(s
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		mem_cgroup_cancel_charge(mem);
+		mem_cgroup_cancel_charge(mem, page_size);
 		return;
 	}
 
@@ -1722,7 +1727,8 @@ static int mem_cgroup_move_parent(struct
 		goto put;
 
 	parent = mem_cgroup_from_cont(pcg);
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page,
+		PAGE_SIZE);
 	if (ret || !parent)
 		goto put_back;
 
@@ -1730,7 +1736,7 @@ static int mem_cgroup_move_parent(struct
 	if (!ret)
 		css_put(&parent->css);	/* drop extra refcnt by try_charge() */
 	else
-		mem_cgroup_cancel_charge(parent);	/* does css_put */
+		mem_cgroup_cancel_charge(parent, PAGE_SIZE); /* does css_put */
 put_back:
 	putback_lru_page(page);
 put:
@@ -1752,6 +1758,10 @@ static int mem_cgroup_charge_common(stru
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
 	int ret;
+	int page_size = PAGE_SIZE;
+
+	if (PageTransHuge(page))
+		page_size <<= compound_order(page);
 
 	pc = lookup_page_cgroup(page);
 	/* can happen at boot */
@@ -1760,11 +1770,12 @@ static int mem_cgroup_charge_common(stru
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
 
@@ -1773,8 +1784,6 @@ int mem_cgroup_newpage_charge(struct pag
 {
 	if (mem_cgroup_disabled())
 		return 0;
-	if (PageCompound(page))
-		return 0;
 	/*
 	 * If already mapped, we don't have to account.
 	 * If page cache, page->mapping has address_space.
@@ -1787,7 +1796,7 @@ int mem_cgroup_newpage_charge(struct pag
 	if (unlikely(!mm))
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
+					MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
 static void
@@ -1880,14 +1889,14 @@ int mem_cgroup_try_charge_swapin(struct 
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
@@ -1903,7 +1912,7 @@ __mem_cgroup_commit_charge_swapin(struct
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
 	mem_cgroup_lru_del_before_commit_swapcache(page);
-	__mem_cgroup_commit_charge(ptr, pc, ctype);
+	__mem_cgroup_commit_charge(ptr, pc, ctype, PAGE_SIZE);
 	mem_cgroup_lru_add_after_commit_swapcache(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
@@ -1952,11 +1961,12 @@ void mem_cgroup_cancel_charge_swapin(str
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
@@ -1989,14 +1999,14 @@ __do_uncharge(struct mem_cgroup *mem, co
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
 
@@ -2009,6 +2019,10 @@ __mem_cgroup_uncharge_common(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
+	int page_size = PAGE_SIZE;
+
+	if (PageTransHuge(page))
+		page_size <<= compound_order(page);
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2048,7 +2062,7 @@ __mem_cgroup_uncharge_common(struct page
 	}
 
 	if (!mem_cgroup_is_root(mem))
-		__do_uncharge(mem, ctype);
+		__do_uncharge(mem, ctype, page_size);
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		mem_cgroup_swap_statistics(mem, true);
 	mem_cgroup_charge_statistics(mem, pc, false);
@@ -2217,7 +2231,7 @@ int mem_cgroup_prepare_migration(struct 
 
 	if (mem) {
 		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false,
-						page);
+					      page, PAGE_SIZE);
 		css_put(&mem->css);
 	}
 	*ptr = mem;
@@ -2260,7 +2274,7 @@ void mem_cgroup_end_migration(struct mem
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
