Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 528DE8D000D
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:29:55 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 36 of 66] memcg compound
Message-Id: <495ffee2d60adab4d18b.1288798091@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Teach memcg to charge/uncharge compound pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1019,6 +1019,10 @@ mem_cgroup_get_reclaim_stat_from_page(st
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
+	int page_size = PAGE_SIZE;
+
+	if (PageTransHuge(page))
+		page_size <<= compound_order(page);
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1879,12 +1883,14 @@ static int __mem_cgroup_do_charge(struct
  * oom-killer can be invoked.
  */
 static int __mem_cgroup_try_charge(struct mm_struct *mm,
-		gfp_t gfp_mask, struct mem_cgroup **memcg, bool oom)
+				   gfp_t gfp_mask,
+				   struct mem_cgroup **memcg, bool oom,
+				   int page_size)
 {
 	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem = NULL;
 	int ret;
-	int csize = CHARGE_SIZE;
+	int csize = max(CHARGE_SIZE, (unsigned long) page_size);
 
 	/*
 	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
@@ -1909,7 +1915,7 @@ again:
 		VM_BUG_ON(css_is_removed(&mem->css));
 		if (mem_cgroup_is_root(mem))
 			goto done;
-		if (consume_stock(mem))
+		if (page_size == PAGE_SIZE && consume_stock(mem))
 			goto done;
 		css_get(&mem->css);
 	} else {
@@ -1933,7 +1939,7 @@ again:
 			rcu_read_unlock();
 			goto done;
 		}
-		if (consume_stock(mem)) {
+		if (page_size == PAGE_SIZE && consume_stock(mem)) {
 			/*
 			 * It seems dagerous to access memcg without css_get().
 			 * But considering how consume_stok works, it's not
@@ -1974,7 +1980,7 @@ again:
 		case CHARGE_OK:
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
-			csize = PAGE_SIZE;
+			csize = page_size;
 			css_put(&mem->css);
 			mem = NULL;
 			goto again;
@@ -1995,8 +2001,8 @@ again:
 		}
 	} while (ret != CHARGE_OK);
 
-	if (csize > PAGE_SIZE)
-		refill_stock(mem, csize - PAGE_SIZE);
+	if (csize > page_size)
+		refill_stock(mem, csize - page_size);
 	css_put(&mem->css);
 done:
 	*memcg = mem;
@@ -2024,9 +2030,10 @@ static void __mem_cgroup_cancel_charge(s
 	}
 }
 
-static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
+static void mem_cgroup_cancel_charge(struct mem_cgroup *mem,
+				     int page_size)
 {
-	__mem_cgroup_cancel_charge(mem, 1);
+	__mem_cgroup_cancel_charge(mem, page_size >> PAGE_SHIFT);
 }
 
 /*
@@ -2082,8 +2089,9 @@ struct mem_cgroup *try_get_mem_cgroup_fr
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
@@ -2092,7 +2100,7 @@ static void __mem_cgroup_commit_charge(s
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		mem_cgroup_cancel_charge(mem);
+		mem_cgroup_cancel_charge(mem, page_size);
 		return;
 	}
 
@@ -2166,7 +2174,7 @@ static void __mem_cgroup_move_account(st
 	mem_cgroup_charge_statistics(from, pc, false);
 	if (uncharge)
 		/* This is not "cancel", but cancel_charge does all we need. */
-		mem_cgroup_cancel_charge(from);
+		mem_cgroup_cancel_charge(from, PAGE_SIZE);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
@@ -2227,13 +2235,14 @@ static int mem_cgroup_move_parent(struct
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
@@ -2254,6 +2263,10 @@ static int mem_cgroup_charge_common(stru
 	struct mem_cgroup *mem = NULL;
 	struct page_cgroup *pc;
 	int ret;
+	int page_size = PAGE_SIZE;
+
+	if (PageTransHuge(page))
+		page_size <<= compound_order(page);
 
 	pc = lookup_page_cgroup(page);
 	/* can happen at boot */
@@ -2261,11 +2274,11 @@ static int mem_cgroup_charge_common(stru
 		return 0;
 	prefetchw(pc);
 
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true, page_size);
 	if (ret || !mem)
 		return ret;
 
-	__mem_cgroup_commit_charge(mem, pc, ctype);
+	__mem_cgroup_commit_charge(mem, pc, ctype, page_size);
 	return 0;
 }
 
@@ -2274,8 +2287,6 @@ int mem_cgroup_newpage_charge(struct pag
 {
 	if (mem_cgroup_disabled())
 		return 0;
-	if (PageCompound(page))
-		return 0;
 	/*
 	 * If already mapped, we don't have to account.
 	 * If page cache, page->mapping has address_space.
@@ -2381,13 +2392,13 @@ int mem_cgroup_try_charge_swapin(struct 
 	if (!mem)
 		goto charge_cur_mm;
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true);
+	ret = __mem_cgroup_try_charge(NULL, mask, ptr, true, PAGE_SIZE);
 	css_put(&mem->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
-	return __mem_cgroup_try_charge(mm, mask, ptr, true);
+	return __mem_cgroup_try_charge(mm, mask, ptr, true, PAGE_SIZE);
 }
 
 static void
@@ -2403,7 +2414,7 @@ __mem_cgroup_commit_charge_swapin(struct
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
 	mem_cgroup_lru_del_before_commit_swapcache(page);
-	__mem_cgroup_commit_charge(ptr, pc, ctype);
+	__mem_cgroup_commit_charge(ptr, pc, ctype, PAGE_SIZE);
 	mem_cgroup_lru_add_after_commit_swapcache(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
@@ -2452,11 +2463,12 @@ void mem_cgroup_cancel_charge_swapin(str
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
@@ -2491,14 +2503,14 @@ __do_uncharge(struct mem_cgroup *mem, co
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
@@ -2512,6 +2524,7 @@ __mem_cgroup_uncharge_common(struct page
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
+	int page_size = PAGE_SIZE;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2519,6 +2532,9 @@ __mem_cgroup_uncharge_common(struct page
 	if (PageSwapCache(page))
 		return NULL;
 
+	if (PageTransHuge(page))
+		page_size <<= compound_order(page);
+
 	/*
 	 * Check if our page_cgroup is valid
 	 */
@@ -2572,7 +2588,7 @@ __mem_cgroup_uncharge_common(struct page
 		mem_cgroup_get(mem);
 	}
 	if (!mem_cgroup_is_root(mem))
-		__do_uncharge(mem, ctype);
+		__do_uncharge(mem, ctype, page_size);
 
 	return mem;
 
@@ -2767,6 +2783,7 @@ int mem_cgroup_prepare_migration(struct 
 	enum charge_type ctype;
 	int ret = 0;
 
+	VM_BUG_ON(PageTransHuge(page));
 	if (mem_cgroup_disabled())
 		return 0;
 
@@ -2816,7 +2833,7 @@ int mem_cgroup_prepare_migration(struct 
 		return 0;
 
 	*ptr = mem;
-	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
+	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false, PAGE_SIZE);
 	css_put(&mem->css);/* drop extra refcnt */
 	if (ret || *ptr == NULL) {
 		if (PageAnon(page)) {
@@ -2843,7 +2860,7 @@ int mem_cgroup_prepare_migration(struct 
 		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	else
 		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-	__mem_cgroup_commit_charge(mem, pc, ctype);
+	__mem_cgroup_commit_charge(mem, pc, ctype, PAGE_SIZE);
 	return ret;
 }
 
@@ -4452,7 +4469,8 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
+		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false,
+					      PAGE_SIZE);
 		if (ret || !mem)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return -ENOMEM;
@@ -4614,6 +4632,7 @@ static int mem_cgroup_count_precharge_pt
 	pte_t *pte;
 	spinlock_t *ptl;
 
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
 		if (is_target_pte_for_mc(vma, addr, *pte, NULL))
@@ -4765,6 +4784,7 @@ static int mem_cgroup_move_charge_pte_ra
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
