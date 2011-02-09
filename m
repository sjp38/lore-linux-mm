Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D7FB48D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 06:02:29 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/4] memcg: unify charge/uncharge quantities to units of pages
Date: Wed,  9 Feb 2011 12:01:53 +0100
Message-Id: <1297249313-23746-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
References: <1297249313-23746-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is no clear pattern when we pass a page count and when we pass a
byte count that is a multiple of PAGE_SIZE.

We never charge or uncharge subpage quantities, so convert it all to
page counts.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |  117 +++++++++++++++++++++++++-----------------------------
 1 files changed, 54 insertions(+), 63 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab5cd3b..bc03f56 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1083,16 +1083,16 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
  * @mem: the memory cgroup
  *
  * Returns the maximum amount of memory @mem can be charged with, in
- * bytes.
+ * pages.
  */
-static unsigned long long mem_cgroup_margin(struct mem_cgroup *mem)
+static unsigned long mem_cgroup_margin(struct mem_cgroup *mem)
 {
 	unsigned long long margin;
 
 	margin = res_counter_margin(&mem->res);
 	if (do_swap_account)
 		margin = min(margin, res_counter_margin(&mem->memsw));
-	return margin;
+	return margin >> PAGE_SHIFT;
 }
 
 static unsigned int get_swappiness(struct mem_cgroup *memcg)
@@ -1621,7 +1621,7 @@ EXPORT_SYMBOL(mem_cgroup_update_page_stat);
  * size of first charge trial. "32" comes from vmscan.c's magic value.
  * TODO: maybe necessary to use big numbers in big irons.
  */
-#define CHARGE_SIZE	(32 * PAGE_SIZE)
+#define CHARGE_BATCH	32U
 struct memcg_stock_pcp {
 	struct mem_cgroup *cached; /* this never be root cgroup */
 	unsigned int nr_pages;
@@ -1797,8 +1797,9 @@ enum {
 };
 
 static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
-				int csize, bool oom_check)
+				  unsigned int nr_pages, bool oom_check)
 {
+	unsigned long csize = nr_pages * PAGE_SIZE;
 	struct mem_cgroup *mem_over_limit;
 	struct res_counter *fail_res;
 	unsigned long flags = 0;
@@ -1819,14 +1820,13 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	} else
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
 	/*
-	 * csize can be either a huge page (HPAGE_SIZE), a batch of
-	 * regular pages (CHARGE_SIZE), or a single regular page
-	 * (PAGE_SIZE).
+	 * nr_pages can be either a huge page (HPAGE_PMD_NR), a batch
+	 * of regular pages (CHARGE_BATCH), or a single regular page (1).
 	 *
 	 * Never reclaim on behalf of optional batching, retry with a
 	 * single page instead.
 	 */
-	if (csize == CHARGE_SIZE)
+	if (nr_pages == CHARGE_BATCH)
 		return CHARGE_RETRY;
 
 	if (!(gfp_mask & __GFP_WAIT))
@@ -1834,7 +1834,7 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 
 	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
 					      gfp_mask, flags);
-	if (mem_cgroup_margin(mem_over_limit) >= csize)
+	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		return CHARGE_RETRY;
 	/*
 	 * Even though the limit is exceeded at this point, reclaim
@@ -1845,7 +1845,7 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	 * unlikely to succeed so close to the limit, and we fall back
 	 * to regular pages anyway in case of failure.
 	 */
-	if (csize == PAGE_SIZE && ret)
+	if (nr_pages == 1 && ret)
 		return CHARGE_RETRY;
 
 	/*
@@ -1872,12 +1872,12 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				   gfp_t gfp_mask,
 				   struct mem_cgroup **memcg, bool oom,
-				   int page_size)
+				   unsigned int nr_pages)
 {
+	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem = NULL;
 	int ret;
-	int csize = max(CHARGE_SIZE, (unsigned long) page_size);
 
 	/*
 	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
@@ -1902,7 +1902,7 @@ again:
 		VM_BUG_ON(css_is_removed(&mem->css));
 		if (mem_cgroup_is_root(mem))
 			goto done;
-		if (page_size == PAGE_SIZE && consume_stock(mem))
+		if (nr_pages == 1 && consume_stock(mem))
 			goto done;
 		css_get(&mem->css);
 	} else {
@@ -1925,7 +1925,7 @@ again:
 			rcu_read_unlock();
 			goto done;
 		}
-		if (page_size == PAGE_SIZE && consume_stock(mem)) {
+		if (nr_pages == 1 && consume_stock(mem)) {
 			/*
 			 * It seems dagerous to access memcg without css_get().
 			 * But considering how consume_stok works, it's not
@@ -1960,13 +1960,12 @@ again:
 			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
 		}
 
-		ret = __mem_cgroup_do_charge(mem, gfp_mask, csize, oom_check);
-
+		ret = __mem_cgroup_do_charge(mem, gfp_mask, batch, oom_check);
 		switch (ret) {
 		case CHARGE_OK:
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
-			csize = page_size;
+			batch = nr_pages;
 			css_put(&mem->css);
 			mem = NULL;
 			goto again;
@@ -1987,8 +1986,8 @@ again:
 		}
 	} while (ret != CHARGE_OK);
 
-	if (csize > page_size)
-		refill_stock(mem, (csize - page_size) >> PAGE_SHIFT);
+	if (batch > nr_pages)
+		refill_stock(mem, batch - nr_pages);
 	css_put(&mem->css);
 done:
 	*memcg = mem;
@@ -2069,10 +2068,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 				       struct page *page,
 				       struct page_cgroup *pc,
 				       enum charge_type ctype,
-				       int page_size)
+				       unsigned int nr_pages)
 {
-	int nr_pages = page_size >> PAGE_SHIFT;
-
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
@@ -2165,11 +2162,11 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
  * @uncharge: whether we should call uncharge and css_put against @from.
- * @charge_size: number of bytes to charge (regular or huge page)
+ * @nr_pages: number of regular pages (>1 for huge pages)
  *
  * The caller must confirm following.
  * - page is not on LRU (isolate_page() is useful.)
- * - compound_lock is held when charge_size > PAGE_SIZE
+ * - compound_lock is held when nr_pages > 1
  *
  * This function doesn't do "charge" nor css_get to new cgroup. It should be
  * done by a caller(__mem_cgroup_try_charge would be usefull). If @uncharge is
@@ -2178,9 +2175,8 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
  */
 static int mem_cgroup_move_account(struct page *page, struct page_cgroup *pc,
 				   struct mem_cgroup *from, struct mem_cgroup *to,
-				   bool uncharge, int charge_size)
+				   bool uncharge, unsigned int nr_pages)
 {
-	int nr_pages = charge_size >> PAGE_SHIFT;
 	unsigned long flags;
 	int ret;
 
@@ -2193,7 +2189,7 @@ static int mem_cgroup_move_account(struct page *page, struct page_cgroup *pc,
 	 * hold it.
 	 */
 	ret = -EBUSY;
-	if (charge_size > PAGE_SIZE && !PageTransHuge(page))
+	if (nr_pages > 1 && !PageTransHuge(page))
 		goto out;
 
 	lock_page_cgroup(pc);
@@ -2251,7 +2247,7 @@ static int mem_cgroup_move_parent(struct page *page,
 	struct cgroup *cg = child->css.cgroup;
 	struct cgroup *pcg = cg->parent;
 	struct mem_cgroup *parent;
-	int page_size = PAGE_SIZE;
+	unsigned int nr_pages;
 	unsigned long flags;
 	int ret;
 
@@ -2265,23 +2261,21 @@ static int mem_cgroup_move_parent(struct page *page,
 	if (isolate_lru_page(page))
 		goto put;
 
-	if (PageTransHuge(page))
-		page_size = HPAGE_SIZE;
+	nr_pages = hpage_nr_pages(page);
 
 	parent = mem_cgroup_from_cont(pcg);
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask,
-				&parent, false, page_size);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, nr_pages);
 	if (ret || !parent)
 		goto put_back;
 
-	if (page_size > PAGE_SIZE)
+	if (nr_pages > 1)
 		flags = compound_lock_irqsave(page);
 
-	ret = mem_cgroup_move_account(page, pc, child, parent, true, page_size);
+	ret = mem_cgroup_move_account(page, pc, child, parent, true, nr_pages);
 	if (ret)
-		mem_cgroup_cancel_charge(parent, page_size >> PAGE_SHIFT);
+		mem_cgroup_cancel_charge(parent, nr_pages);
 
-	if (page_size > PAGE_SIZE)
+	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
 put_back:
 	putback_lru_page(page);
@@ -2301,13 +2295,13 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask, enum charge_type ctype)
 {
 	struct mem_cgroup *mem = NULL;
-	int page_size = PAGE_SIZE;
+	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
 	bool oom = true;
 	int ret;
 
 	if (PageTransHuge(page)) {
-		page_size <<= compound_order(page);
+		nr_pages <<= compound_order(page);
 		VM_BUG_ON(!PageTransHuge(page));
 		/*
 		 * Never OOM-kill a process for a huge page.  The
@@ -2319,11 +2313,11 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 	pc = lookup_page_cgroup(page);
 	BUG_ON(!pc); /* XXX: remove this and move pc lookup into commit */
 
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, oom, page_size);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, oom, nr_pages);
 	if (ret || !mem)
 		return ret;
 
-	__mem_cgroup_commit_charge(mem, page, pc, ctype, page_size);
+	__mem_cgroup_commit_charge(mem, page, pc, ctype, nr_pages);
 	return 0;
 }
 
@@ -2439,13 +2433,13 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true, PAGE_SIZE);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true, 1);
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
-	return __mem_cgroup_try_charge(mm, mask, ptr, true, PAGE_SIZE);
+	return __mem_cgroup_try_charge(mm, mask, ptr, true, 1);
 }
 
 static void
@@ -2461,7 +2455,7 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
 	mem_cgroup_lru_del_before_commit_swapcache(page);
-	__mem_cgroup_commit_charge(ptr, page, pc, ctype, PAGE_SIZE);
+	__mem_cgroup_commit_charge(ptr, page, pc, ctype, 1);
 	mem_cgroup_lru_add_after_commit_swapcache(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
@@ -2515,10 +2509,11 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 
 static void
 __do_uncharge(struct mem_cgroup *mem, const enum charge_type ctype,
-	      int page_size)
+	      unsigned int nr_pages)
 {
 	struct memcg_batch_info *batch = NULL;
 	bool uncharge_memsw = true;
+
 	/* If swapout, usage of swap doesn't decrease */
 	if (!do_swap_account || ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		uncharge_memsw = false;
@@ -2542,7 +2537,7 @@ __do_uncharge(struct mem_cgroup *mem, const enum charge_type ctype,
 	if (!batch->do_batch || test_thread_flag(TIF_MEMDIE))
 		goto direct_uncharge;
 
-	if (page_size != PAGE_SIZE)
+	if (nr_pages > 1)
 		goto direct_uncharge;
 
 	/*
@@ -2558,9 +2553,9 @@ __do_uncharge(struct mem_cgroup *mem, const enum charge_type ctype,
 		batch->memsw_nr_pages++;
 	return;
 direct_uncharge:
-	res_counter_uncharge(&mem->res, page_size);
+	res_counter_uncharge(&mem->res, nr_pages * PAGE_SIZE);
 	if (uncharge_memsw)
-		res_counter_uncharge(&mem->memsw, page_size);
+		res_counter_uncharge(&mem->memsw, nr_pages * PAGE_SIZE);
 	if (unlikely(batch->memcg != mem))
 		memcg_oom_recover(mem);
 	return;
@@ -2572,10 +2567,9 @@ direct_uncharge:
 static struct mem_cgroup *
 __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 {
-	int count;
-	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
-	int page_size = PAGE_SIZE;
+	unsigned int nr_pages = 1;
+	struct page_cgroup *pc;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2584,11 +2578,9 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		return NULL;
 
 	if (PageTransHuge(page)) {
-		page_size <<= compound_order(page);
+		nr_pages <<= compound_order(page);
 		VM_BUG_ON(!PageTransHuge(page));
 	}
-
-	count = page_size >> PAGE_SHIFT;
 	/*
 	 * Check if our page_cgroup is valid
 	 */
@@ -2621,7 +2613,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		break;
 	}
 
-	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), -count);
+	mem_cgroup_charge_statistics(mem, PageCgroupCache(pc), -nr_pages);
 
 	ClearPageCgroupUsed(pc);
 	/*
@@ -2642,7 +2634,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		mem_cgroup_get(mem);
 	}
 	if (!mem_cgroup_is_root(mem))
-		__do_uncharge(mem, ctype, page_size);
+		__do_uncharge(mem, ctype, nr_pages);
 
 	return mem;
 
@@ -2834,8 +2826,8 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 int mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask)
 {
-	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
+	struct page_cgroup *pc;
 	enum charge_type ctype;
 	int ret = 0;
 
@@ -2891,7 +2883,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 		return 0;
 
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, ptr, false, PAGE_SIZE);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask, ptr, false, 1);
 	css_put(&mem->css);/* drop extra refcnt */
 	if (ret || *ptr == NULL) {
 		if (PageAnon(page)) {
@@ -2918,7 +2910,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	else
 		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-	__mem_cgroup_commit_charge(mem, page, pc, ctype, PAGE_SIZE);
+	__mem_cgroup_commit_charge(mem, page, pc, ctype, 1);
 	return ret;
 }
 
@@ -4572,8 +4564,7 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false,
-					      PAGE_SIZE);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false, 1);
 		if (ret || !mem)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return -ENOMEM;
@@ -4918,8 +4909,8 @@ retry:
 			if (isolate_lru_page(page))
 				goto put;
 			pc = lookup_page_cgroup(page);
-			if (!mem_cgroup_move_account(page, pc,
-					mc.from, mc.to, false, PAGE_SIZE)) {
+			if (!mem_cgroup_move_account(page, pc, mc.from,
+						     mc.to, false, 1)) {
 				mc.precharge--;
 				/* we uncharge from mc.from later. */
 				mc.moved_charge++;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
