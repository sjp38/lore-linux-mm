Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9V301qq030433
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 31 Oct 2008 12:00:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C24E53C126
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 12:00:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E7B0C240061
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 12:00:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AAE91DB803E
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 12:00:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 328381DB8041
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 12:00:00 +0900 (JST)
Date: Fri, 31 Oct 2008 11:59:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/5] memcg : mem+swap controller
Message-Id: <20081031115929.4209749f.kamezawa.hiroyu@jp.fujitsu.com>
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

Mem+Swap controller core.

This patch implements per cgroup limit for usage of memory+swap.
However there are SwapCache, double counting of swap-cache and
swap-entry is avoided.

Mem+Swap controller works as following.
  - memory usage is limited by memory.limit_in_bytes.
  - memory + swap usage is limited by memory.memsw_limit_in_bytes.


This has following benefits.
  - A user can limit total resource usage of mem+swap.

    Without this, because memory resource controller doesn't take care of
    usage of swap, a process can exhaust all the swap (by memory leak.)
    We can avoid this case.

    And Swap is shared resource but it cannot be reclaimed (goes back to memory)
    until it's used. This characteristic can be trouble when the memory
    is divided into some parts by cpuset or memcg.
    Assume group A and group B.
    After some application executes, the system can be..
    
    Group A -- very large free memory space but occupy 99% of swap.
    Group B -- under memory shortage but cannot use swap...it's nearly full.

    Ability to set appropriate swap limit for each group is required.
      
Maybe someone wonder "why not swap but mem+swap ?"

  - The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
    to move account from memory to swap...there is no change in usage of
    mem+swap.

    In other words, when we want to limit the usage of swap without affecting
    global LRU, mem+swap limit is better than just limiting swap.


Accounting target information is stored in swap_cgroup which is
per swap entry record.

Charge is done as following.
  map
    - charge  page and memsw.

  unmap
    - uncharge page/memsw if not SwapCache.

  swap-out (__delete_from_swap_cache)
    - uncharge page
    - record mem_cgroup information to swap_cgroup.

  swap-in (do_swap_page)
    - charged as page and memsw.
      record in swap_cgroup is cleared.
      memsw accounting is decremented.

  swap-free (swap_free())
    - if swap entry is freed, memsw is uncharged by PAGE_SIZE.


After this, usual memory resource controller handles SwapCache.
(It was lacked(ignored) feature in current memcg but must be handled.)

There are people work under never-swap environments and consider swap as
something bad. For such people, this mem+swap controller extension is just an
overhead.  This overhead is avoided by config or boot option.
(see Kconfig. detail is not in this patch.)

Changelog: v1 -> v2
 - fixed typos
 - fixed migration of anon pages.
 - fixed uncharge to check USED bit always.
 - code for swapcache is moved to another patch.
 - added "noswap" argument to try_to_free_mem_cgroup_pages
 - fixed lock_page around mem_cgroup_charge_cache_swap()
 - fixed "failcnt" file.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 Documentation/controllers/memory.txt |   29 ++
 include/linux/memcontrol.h           |   11 -
 include/linux/swap.h                 |   18 +
 mm/memcontrol.c                      |  361 +++++++++++++++++++++++++++++++----
 mm/memory.c                          |    3 
 mm/shmem.c                           |    4 
 mm/swap_state.c                      |    5 
 mm/swapfile.c                        |   11 -
 mm/vmscan.c                          |    6 
 9 files changed, 391 insertions(+), 57 deletions(-)

Index: mmotm-2.6.28-rc2+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/memcontrol.c
+++ mmotm-2.6.28-rc2+/mm/memcontrol.c
@@ -132,6 +132,10 @@ struct mem_cgroup {
 	 */
 	struct res_counter res;
 	/*
+	 * the counter to account for mem+swap usage.
+	 */
+	struct res_counter memsw;
+	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
 	 */
@@ -142,6 +146,12 @@ struct mem_cgroup {
 	 * statistics.
 	 */
 	struct mem_cgroup_stat stat;
+
+	/*
+	 * used for counting reference from swap_cgroup.
+	 */
+	int		obsolete;
+	atomic_t	swapref;
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -168,6 +178,16 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 	0, /* FORCE */
 };
 
+
+/* for encoding cft->private value on file */
+#define _MEM			(0)
+#define _MEMSWAP		(1)
+#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
+#define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
+#define MEMFILE_ATTR(val)	((val) & 0xffff)
+
+static void mem_cgroup_forget_swapref(struct mem_cgroup *mem);
+
 /*
  * Always modified under lru lock. Then, not necessary to preempt_disable()
  */
@@ -514,12 +534,25 @@ static int __mem_cgroup_try_charge(struc
 		css_get(&mem->css);
 	}
 
+	while (1) {
+		int ret;
+		bool noswap = false;
 
-	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
+		ret = res_counter_charge(&mem->res, PAGE_SIZE);
+		if (likely(!ret)) {
+			if (!do_swap_account)
+				break;
+			ret = res_counter_charge(&mem->memsw, PAGE_SIZE);
+			if (likely(!ret))
+				break;
+			/* mem+swap counter fails */
+			res_counter_uncharge(&mem->res, PAGE_SIZE);
+			noswap = true;
+		}
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
+		if (try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap))
 			continue;
 
 		/*
@@ -528,8 +561,13 @@ static int __mem_cgroup_try_charge(struc
 		 * moved to swap cache or just unmapped from the cgroup.
 		 * Check the limit again to see if the reclaim reduced the
 		 * current usage of the cgroup before giving up
+		 *
 		 */
-		if (res_counter_check_under_limit(&mem->res))
+		if (!do_swap_account &&
+			res_counter_check_under_limit(&mem->res))
+			continue;
+		if (do_swap_account &&
+			res_counter_check_under_limit(&mem->memsw))
 			continue;
 
 		if (!nr_retries--) {
@@ -583,6 +621,8 @@ static void __mem_cgroup_commit_charge(s
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		if (do_swap_account)
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 		css_put(&mem->css);
 		return;
 	}
@@ -647,6 +687,8 @@ static int mem_cgroup_move_account(struc
 		__mem_cgroup_remove_list(from_mz, pc);
 		css_put(&from->css);
 		res_counter_uncharge(&from->res, PAGE_SIZE);
+		if (do_swap_account)
+			res_counter_uncharge(&from->memsw, PAGE_SIZE);
 		pc->mem_cgroup = to;
 		css_get(&to->css);
 		__mem_cgroup_add_list(to_mz, pc, false);
@@ -693,8 +735,11 @@ static int mem_cgroup_move_parent(struct
 	/* drop extra refcnt */
 	css_put(&parent->css);
 	/* uncharge if move fails */
-	if (ret)
+	if (ret) {
 		res_counter_uncharge(&parent->res, PAGE_SIZE);
+		if (do_swap_account)
+			res_counter_uncharge(&parent->memsw, PAGE_SIZE);
+	}
 
 	return ret;
 }
@@ -792,27 +837,77 @@ int mem_cgroup_cache_charge(struct page 
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
+int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
+	struct page *page, gfp_t mask, struct mem_cgroup **ptr)
+{
+	struct mem_cgroup *mem;
+	swp_entry_t     ent;
+
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+
+	if (!do_swap_account)
+		goto charge_cur_mm;
+
+	ent.val = page_private(page);
+
+	mem = lookup_swap_cgroup(ent);
+	if (!mem || mem->obsolete)
+		goto charge_cur_mm;
+	*ptr = mem;
+	return __mem_cgroup_try_charge(NULL, mask, ptr, true);
+charge_cur_mm:
+	if (unlikely(!mm))
+		mm = &init_mm;
+	return __mem_cgroup_try_charge(mm, mask, ptr, true);
+}
+
+
+
 #ifdef CONFIG_SWAP
 int mem_cgroup_cache_charge_swapin(struct page *page,
-			struct mm_struct *mm, gfp_t mask)
+			struct mm_struct *mm, gfp_t mask, bool locked)
 {
 	int ret = 0;
+	swp_entry_t ent;
+	struct mem_cgroup *mem = NULL;
 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
+
 	if (unlikely(!mm))
 		mm = &init_mm;
 
+	if (!locked) {
+		lock_page(page);
+		if (!PageSwapCache(page))
+			goto unlock_out;
+	}
+	ent.val = page_private(page);
+
+	if (do_swap_account) {
+		mem = lookup_swap_cgroup(ent);
+		if (mem && mem->obsolete)
+			mem = NULL;
+		if (mem)
+			mm = NULL;
+	}
 	ret = mem_cgroup_charge_common(page, mm, mask,
-			MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
-	/*
-	 * The page may be dropped from SwapCache because we don't have
-	 * lock_page().This may cause charge-after-uncharge trouble.
-	 * Fix it up here. (the caller have refcnt to this page and
-	 * page itself is guaranteed not to be freed.)
-	 */
-	if (ret && !PageSwapCache(page))
-		mem_cgroup_uncharge_swapcache(page);
+			MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
+	if (!ret && do_swap_account) {
+		/*
+		 * At this point, we successfully charge both for mem and swap.
+		 * fix this double counting, here.
+		 */
+		mem = swap_cgroup_record(ent, NULL);
+		if (mem) {
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			mem_cgroup_forget_swapref(mem);
+		}
+	}
+unlock_out:
+	if (!locked)
+		unlock_page(page);
 
 	return ret;
 }
@@ -828,6 +923,23 @@ void mem_cgroup_commit_charge_swapin(str
 		return;
 	pc = lookup_page_cgroup(page);
 	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
+	/*
+	 * Now swap is on-memory. This means this page may be
+	 * counted both as mem and swap....double count.
+	 * Fix it by uncharging from memsw. This SwapCache is stable
+	 * because we're still under lock_page().
+	 */
+	if (do_swap_account) {
+		swp_entry_t ent = {.val = page_private(page)};
+		struct mem_cgroup *memcg;
+		memcg = swap_cgroup_record(ent, NULL);
+		if (memcg) {
+			/* If memcg is obsolete, memcg can be != ptr */
+			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			mem_cgroup_forget_swapref(memcg);
+		}
+
+	}
 }
 
 void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
@@ -837,6 +949,7 @@ void mem_cgroup_cancel_charge_swapin(str
 	if (!mem)
 		return;
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 	css_put(&mem->css);
 }
 
@@ -844,29 +957,31 @@ void mem_cgroup_cancel_charge_swapin(str
 /*
  * uncharge if !page_mapped(page)
  */
-static void
+static struct mem_cgroup *
 __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 {
 	struct page_cgroup *pc;
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
 	if (mem_cgroup_subsys.disabled)
-		return;
+		return NULL;
 
 	if (PageSwapCache(page))
-		return;
+		return NULL;
 
 	/*
 	 * Check if our page_cgroup is valid
 	 */
 	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc || !PageCgroupUsed(pc)))
-		return;
+		return NULL;
 
 	lock_page_cgroup(pc);
 
+	mem = pc->mem_cgroup;
+
 	if (!PageCgroupUsed(pc))
 		goto unlock_out;
 
@@ -886,8 +1001,11 @@ __mem_cgroup_uncharge_common(struct page
 		break;
 	}
 
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
+		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+
 	ClearPageCgroupUsed(pc);
-	mem = pc->mem_cgroup;
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
@@ -895,14 +1013,13 @@ __mem_cgroup_uncharge_common(struct page
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 	unlock_page_cgroup(pc);
 
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
 	css_put(&mem->css);
 
-	return;
+	return mem;
 
 unlock_out:
 	unlock_page_cgroup(pc);
-	return;
+	return NULL;
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -922,11 +1039,43 @@ void mem_cgroup_uncharge_cache_page(stru
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
-void mem_cgroup_uncharge_swapcache(struct page *page)
+/*
+ * called from __delete_from_swap_cache() and drop "page" account.
+ * memcg information is recorded to swap_cgroup of "ent"
+ */
+void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
+	struct mem_cgroup *memcg;
+
+	memcg = __mem_cgroup_uncharge_common(page,
+					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
+	/* record memcg information */
+	if (do_swap_account && memcg) {
+		swap_cgroup_record(ent, memcg);
+		atomic_inc(&memcg->swapref);
+	}
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+/*
+ * called from swap_entry_free(). remove record in swap_cgroup and
+ * uncharge "memsw" account.
+ */
+void mem_cgroup_uncharge_swap(swp_entry_t ent)
+{
+	struct mem_cgroup *memcg;
+
+	if (!do_swap_account)
+		return;
+
+	memcg = swap_cgroup_record(ent, NULL);
+	if (memcg) {
+		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+		mem_cgroup_forget_swapref(memcg);
+	}
+}
+#endif
+
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
@@ -1034,7 +1183,7 @@ int mem_cgroup_shrink_usage(struct mm_st
 	rcu_read_unlock();
 
 	do {
-		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
+		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask, true);
 		progress += res_counter_check_under_limit(&mem->res);
 	} while (!progress && --retry);
 
@@ -1061,13 +1210,55 @@ int mem_cgroup_resize_limit(struct mem_c
 			break;
 		}
 		progress = try_to_free_mem_cgroup_pages(memcg,
-				GFP_HIGHUSER_MOVABLE);
+				GFP_HIGHUSER_MOVABLE, false);
 		if (!progress)
 			retry_count--;
 	}
 	return ret;
 }
 
+int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
+				unsigned long long val)
+{
+	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
+	unsigned long flags;
+	u64 memlimit, oldusage, curusage;
+	int ret;
+
+	if (!do_swap_account)
+		return -EINVAL;
+
+	while (retry_count) {
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			break;
+		}
+		/*
+		 * Rather than hide all in some function, I do this in
+		 * open coded manner. You see what this really does.
+		 * We have to guarantee mem->res.limit < mem->memsw.limit.
+		 */
+		spin_lock_irqsave(&memcg->res.lock, flags);
+		memlimit = memcg->res.limit;
+		if (memlimit > val) {
+			spin_unlock_irqrestore(&memcg->res.lock, flags);
+			ret = -EINVAL;
+			break;
+		}
+		ret = res_counter_set_limit(&memcg->memsw, val);
+		oldusage = memcg->memsw.usage;
+		spin_unlock_irqrestore(&memcg->res.lock, flags);
+
+		if (!ret)
+			break;
+		try_to_free_mem_cgroup_pages(memcg, GFP_HIGHUSER_MOVABLE, true);
+		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
+		if (curusage >= oldusage)
+			retry_count--;
+	}
+	return ret;
+}
+
 
 /*
  * This routine traverse page_cgroup in given list and drop them all.
@@ -1179,7 +1370,7 @@ try_to_free:
 	while (nr_retries && mem->res.usage > 0) {
 		int progress;
 		progress = try_to_free_mem_cgroup_pages(mem,
-						  GFP_HIGHUSER_MOVABLE);
+						  GFP_HIGHUSER_MOVABLE, false);
 		if (!progress)
 			nr_retries--;
 
@@ -1193,8 +1384,25 @@ try_to_free:
 
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
-	return res_counter_read_u64(&mem_cgroup_from_cont(cont)->res,
-				    cft->private);
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	u64 val = 0;
+	int type, name;
+
+	type = MEMFILE_TYPE(cft->private);
+	name = MEMFILE_ATTR(cft->private);
+	switch (type) {
+	case _MEM:
+		val = res_counter_read_u64(&mem->res, name);
+		break;
+	case _MEMSWAP:
+		if (do_swap_account)
+			val = res_counter_read_u64(&mem->memsw, name);
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return val;
 }
 /*
  * The user of this function is...
@@ -1204,15 +1412,22 @@ static int mem_cgroup_write(struct cgrou
 			    const char *buffer)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	int type, name;
 	unsigned long long val;
 	int ret;
 
-	switch (cft->private) {
+	type = MEMFILE_TYPE(cft->private);
+	name = MEMFILE_ATTR(cft->private);
+	switch (name) {
 	case RES_LIMIT:
 		/* This function does all necessary parse...reuse it */
 		ret = res_counter_memparse_write_strategy(buffer, &val);
-		if (!ret)
+		if (ret)
+			break;
+		if (type == _MEM)
 			ret = mem_cgroup_resize_limit(memcg, val);
+		else
+			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
@@ -1224,14 +1439,23 @@ static int mem_cgroup_write(struct cgrou
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 {
 	struct mem_cgroup *mem;
+	int type, name;
 
 	mem = mem_cgroup_from_cont(cont);
-	switch (event) {
+	type = MEMFILE_TYPE(event);
+	name = MEMFILE_ATTR(event);
+	switch (name) {
 	case RES_MAX_USAGE:
-		res_counter_reset_max(&mem->res);
+		if (type == _MEM)
+			res_counter_reset_max(&mem->res);
+		else
+			res_counter_reset_max(&mem->memsw);
 		break;
 	case RES_FAILCNT:
-		res_counter_reset_failcnt(&mem->res);
+		if (type == _MEM)
+			res_counter_reset_failcnt(&mem->res);
+		else
+			res_counter_reset_failcnt(&mem->memsw);
 		break;
 	}
 	return 0;
@@ -1285,30 +1509,33 @@ static int mem_control_stat_show(struct 
 		cb->fill(cb, "unevictable", unevictable * PAGE_SIZE);
 
 	}
+	/* showing refs from disk-swap */
+	cb->fill(cb, "swap_on_disk", atomic_read(&mem_cont->swapref)
+					* PAGE_SIZE);
 	return 0;
 }
 
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
-		.private = RES_USAGE,
+		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
 		.read_u64 = mem_cgroup_read,
 	},
 	{
 		.name = "max_usage_in_bytes",
-		.private = RES_MAX_USAGE,
+		.private = MEMFILE_PRIVATE(_MEM, RES_MAX_USAGE),
 		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
 	{
 		.name = "limit_in_bytes",
-		.private = RES_LIMIT,
+		.private = MEMFILE_PRIVATE(_MEM, RES_LIMIT),
 		.write_string = mem_cgroup_write,
 		.read_u64 = mem_cgroup_read,
 	},
 	{
 		.name = "failcnt",
-		.private = RES_FAILCNT,
+		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
@@ -1316,6 +1543,31 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+	{
+		.name = "memsw.usage_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
+		.read_u64 = mem_cgroup_read,
+	},
+	{
+		.name = "memsw.max_usage_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_MAX_USAGE),
+		.trigger = mem_cgroup_reset,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
+		.name = "memsw.limit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_LIMIT),
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
+		.name = "memsw.failcnt",
+		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_FAILCNT),
+		.trigger = mem_cgroup_reset,
+		.read_u64 = mem_cgroup_read,
+	},
+#endif
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -1369,14 +1621,43 @@ static struct mem_cgroup *mem_cgroup_all
 	return mem;
 }
 
+/*
+ * At destroying mem_cgroup, references from swap_cgroup can remain.
+ * (scanning all at force_empty is too costly...)
+ *
+ * Instead of clearing all references at force_empty, we remember
+ * the number of reference from swap_cgroup and free mem_cgroup when
+ * it goes down to 0.
+ *
+ * When mem_cgroup is destroyed, mem->obsolete will be set to 0 and
+ * entry which points to this memcg will be ignore at swapin.
+ *
+ * Removal of cgroup itself succeeds regardless of refs from swap.
+ */
+
 static void mem_cgroup_free(struct mem_cgroup *mem)
 {
+	if (do_swap_account) {
+		if (atomic_read(&mem->swapref) > 0)
+			return;
+	}
 	if (sizeof(*mem) < PAGE_SIZE)
 		kfree(mem);
 	else
 		vfree(mem);
 }
 
+static void mem_cgroup_forget_swapref(struct mem_cgroup *mem)
+{
+	if (!do_swap_account)
+		return;
+	if (atomic_dec_and_test(&mem->swapref)) {
+		if (!mem->obsolete)
+			return;
+		mem_cgroup_free(mem);
+	}
+}
+
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 static void __init enable_swap_cgroup(void)
@@ -1406,6 +1687,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	}
 
 	res_counter_init(&mem->res);
+	res_counter_init(&mem->memsw);
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
@@ -1424,6 +1706,7 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	mem->obsolete = 1;
 	mem_cgroup_force_empty(mem);
 }
 
Index: mmotm-2.6.28-rc2+/mm/swapfile.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/swapfile.c
+++ mmotm-2.6.28-rc2+/mm/swapfile.c
@@ -271,8 +271,9 @@ out:
 	return NULL;
 }	
 
-static int swap_entry_free(struct swap_info_struct *p, unsigned long offset)
+static int swap_entry_free(struct swap_info_struct *p, swp_entry_t ent)
 {
+	unsigned long offset = swp_offset(ent);
 	int count = p->swap_map[offset];
 
 	if (count < SWAP_MAP_MAX) {
@@ -287,6 +288,7 @@ static int swap_entry_free(struct swap_i
 				swap_list.next = p - swap_info;
 			nr_swap_pages++;
 			p->inuse_pages--;
+			mem_cgroup_uncharge_swap(ent);
 		}
 	}
 	return count;
@@ -302,7 +304,7 @@ void swap_free(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, swp_offset(entry));
+		swap_entry_free(p, entry);
 		spin_unlock(&swap_lock);
 	}
 }
@@ -421,7 +423,7 @@ void free_swap_and_cache(swp_entry_t ent
 
 	p = swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, swp_offset(entry)) == 1) {
+		if (swap_entry_free(p, entry) == 1) {
 			page = find_get_page(&swapper_space, entry.val);
 			if (page && !trylock_page(page)) {
 				page_cache_release(page);
@@ -536,7 +538,8 @@ static int unuse_pte(struct vm_area_stru
 	pte_t *pte;
 	int ret = 1;
 
-	if (mem_cgroup_try_charge(vma->vm_mm, GFP_HIGHUSER_MOVABLE, &ptr))
+	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page,
+					GFP_HIGHUSER_MOVABLE, &ptr))
 		ret = -ENOMEM;
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
Index: mmotm-2.6.28-rc2+/mm/swap_state.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/swap_state.c
+++ mmotm-2.6.28-rc2+/mm/swap_state.c
@@ -17,6 +17,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/pgtable.h>
 
@@ -108,6 +109,8 @@ int add_to_swap_cache(struct page *page,
  */
 void __delete_from_swap_cache(struct page *page)
 {
+	swp_entry_t ent = {.val = page_private(page)};
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!PageSwapCache(page));
 	BUG_ON(PageWriteback(page));
@@ -119,7 +122,7 @@ void __delete_from_swap_cache(struct pag
 	total_swapcache_pages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
-	mem_cgroup_uncharge_swapcache(page);
+	mem_cgroup_uncharge_swapcache(page, ent);
 }
 
 /**
Index: mmotm-2.6.28-rc2+/include/linux/swap.h
===================================================================
--- mmotm-2.6.28-rc2+.orig/include/linux/swap.h
+++ mmotm-2.6.28-rc2+/include/linux/swap.h
@@ -213,7 +213,7 @@ static inline void lru_cache_add_active_
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-							gfp_t gfp_mask);
+						gfp_t gfp_mask, bool noswap);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
@@ -334,16 +334,24 @@ static inline void disable_swap_token(vo
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern int mem_cgroup_cache_charge_swapin(struct page *page,
-				struct mm_struct *mm, gfp_t mask);
-extern void mem_cgroup_uncharge_swapcache(struct page *page);
+				struct mm_struct *mm, gfp_t mask, bool locked);
+extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
 #else
 static inline
 int mem_cgroup_cache_charge_swapin(struct page *page,
-				    struct mm_struct *mm, gfp_t mask)
+				struct mm_struct *mm, gfp_t mask, bool locked)
 {
 	return 0;
 }
-static inline void mem_cgroup_uncharge_swapcache(struct page *page)
+static inline void
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+{
+}
+#endif
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
+#else
+static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
 {
 }
 #endif
Index: mmotm-2.6.28-rc2+/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-rc2+.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-rc2+/include/linux/memcontrol.h
@@ -32,6 +32,8 @@ extern int mem_cgroup_newpage_charge(str
 /* for swap handling */
 extern int mem_cgroup_try_charge(struct mm_struct *mm,
 		gfp_t gfp_mask, struct mem_cgroup **ptr);
+extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
+		struct page *page, gfp_t mask, struct mem_cgroup **ptr);
 extern void mem_cgroup_commit_charge_swapin(struct page *page,
 					struct mem_cgroup *ptr);
 extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
@@ -80,7 +82,6 @@ extern long mem_cgroup_calc_reclaim(stru
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
-
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -97,7 +98,13 @@ static inline int mem_cgroup_cache_charg
 }
 
 static inline int mem_cgroup_try_charge(struct mm_struct *mm,
-				gfp_t gfp_mask, struct mem_cgroup **ptr)
+			gfp_t gfp_mask, struct mem_cgroup **ptr)
+{
+	return 0;
+}
+
+static inline int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
+		struct page *page, gfp_t gfp_mask, struct mem_cgroup **ptr)
 {
 	return 0;
 }
Index: mmotm-2.6.28-rc2+/mm/memory.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/memory.c
+++ mmotm-2.6.28-rc2+/mm/memory.c
@@ -2324,7 +2324,8 @@ static int do_swap_page(struct mm_struct
 	lock_page(page);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
-	if (mem_cgroup_try_charge(mm, GFP_HIGHUSER_MOVABLE, &ptr) == -ENOMEM) {
+	if (mem_cgroup_try_charge_swapin(mm, page,
+				GFP_HIGHUSER_MOVABLE, &ptr) == -ENOMEM) {
 		ret = VM_FAULT_OOM;
 		unlock_page(page);
 		goto out;
Index: mmotm-2.6.28-rc2+/mm/vmscan.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/vmscan.c
+++ mmotm-2.6.28-rc2+/mm/vmscan.c
@@ -1669,7 +1669,8 @@ unsigned long try_to_free_pages(struct z
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
-						gfp_t gfp_mask)
+						gfp_t gfp_mask,
+					   bool noswap)
 {
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
@@ -1682,6 +1683,9 @@ unsigned long try_to_free_mem_cgroup_pag
 	};
 	struct zonelist *zonelist;
 
+	if (noswap)
+		sc.may_swap = 0;
+
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
Index: mmotm-2.6.28-rc2+/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.28-rc2+.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.28-rc2+/Documentation/controllers/memory.txt
@@ -137,12 +137,32 @@ behind this approach is that a cgroup th
 page will eventually get charged for it (once it is uncharged from
 the cgroup that brought it in -- this will happen on memory pressure).
 
-Exception: When you do swapoff and make swapped-out pages of shmem(tmpfs) to
+Exception: If CONFIG_CGROUP_CGROUP_MEM_RES_CTLR_SWAP is not used..
+When you do swapoff and make swapped-out pages of shmem(tmpfs) to
 be backed into memory in force, charges for pages are accounted against the
 caller of swapoff rather than the users of shmem.
 
 
-2.4 Reclaim
+2.4 Swap Extension (CONFIG_CGROUP_MEM_RES_CTLR_SWAP)
+Swap Extension allows you to record charge for swap. A swapped-in page is
+charged back to original page allocator if possible.
+
+When swap is accounted, following files are added.
+ - memory.memsw.usage_in_bytes.
+ - memory.memsw.limit_in_bytes.
+
+usage of mem+swap is limited by memsw.limit_in_bytes.
+
+Note: why 'mem+swap' rather than swap.
+The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
+to move account from memory to swap...there is no change in usage of
+mem+swap.
+
+In other words, when we want to limit the usage of swap without affecting
+global LRU, mem+swap limit is better than just limiting swap from OS point
+of view.
+
+2.5 Reclaim
 
 Each cgroup maintains a per cgroup LRU that consists of an active
 and inactive list. When a cgroup goes over its limit, we first try
@@ -246,6 +266,11 @@ Such charges are moved to its parent as 
 is full.
 If both of them are busy, rmdir() returns -EBUSY.
 
+Charges recorded in swap information is not updated at removal of cgroup.
+Recorded information is effectively discarded and a cgroup which uses swap
+(swapcache) will be charged as a new owner of it.
+
+
 5. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
Index: mmotm-2.6.28-rc2+/mm/shmem.c
===================================================================
--- mmotm-2.6.28-rc2+.orig/mm/shmem.c
+++ mmotm-2.6.28-rc2+/mm/shmem.c
@@ -925,7 +925,7 @@ found:
          * charged back to the user(not to caller) when swap account is used.
          */
 	error = mem_cgroup_cache_charge_swapin(page,
-			current->mm, GFP_HIGHUSER_MOVABLE);
+			current->mm, GFP_HIGHUSER_MOVABLE, true);
 	if (error)
 		goto out;
 	error = radix_tree_preload(GFP_KERNEL);
@@ -1267,7 +1267,7 @@ repeat:
 			 * charge against this swap cache here.
 			 */
 			if (mem_cgroup_cache_charge_swapin(swappage,
-						current->mm, gfp)) {
+						current->mm, gfp, false)) {
 				page_cache_release(swappage);
 				error = -ENOMEM;
 				goto failed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
