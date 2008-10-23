Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9N9Geds031999
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Oct 2008 18:16:40 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C3212AC026
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:16:40 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3ED412C049
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:16:39 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id C40521DB8038
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:16:39 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A5F81DB8037
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 18:16:39 +0900 (JST)
Date: Thu, 23 Oct 2008 18:16:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 11/11] memcg: mem+swap controler core
Message-Id: <20081023181611.367d9f07.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
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
    This cannot be recovered in general.
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
(It was lacked(ignored) feature in current memcg but must be
 handled.)

There are people work under never-swap environments and consider swap as
something bad. For such people, this mem+swap controller extension is just an
overhead.  This overhead is avoided by config or boot option.
(see Kconfig. detail is not in this patch.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/memcontrol.h |    3 
 include/linux/swap.h       |   17 ++
 mm/memcontrol.c            |  356 +++++++++++++++++++++++++++++++++++++++++----
 mm/swap_state.c            |    4 
 mm/swapfile.c              |    8 -
 5 files changed, 359 insertions(+), 29 deletions(-)

Index: mmotm-2.6.27+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27+.orig/mm/memcontrol.c
+++ mmotm-2.6.27+/mm/memcontrol.c
@@ -130,6 +130,10 @@ struct mem_cgroup {
 	 */
 	struct res_counter res;
 	/*
+	 * the coutner to accoaunt for mem+swap usage.
+	 */
+	struct res_counter memsw;
+	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
 	 */
@@ -140,6 +144,12 @@ struct mem_cgroup {
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
 
@@ -148,6 +158,7 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
+	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* used by force_empty */
 	NR_CHARGE_TYPE,
 };
 
@@ -165,6 +176,16 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
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
@@ -698,8 +719,19 @@ static int __mem_cgroup_try_charge(struc
 		css_get(&mem->css);
 	}
 
+	while (1) {
+		int ret;
 
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
+		}
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
@@ -712,8 +744,13 @@ static int __mem_cgroup_try_charge(struc
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
@@ -770,6 +807,8 @@ static void __mem_cgroup_commit_charge(s
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		if (do_swap_account)
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 		css_put(&mem->css);
 		return;
 	}
@@ -851,6 +890,8 @@ static int mem_cgroup_move_account(struc
 	if (spin_trylock(&to_mz->lru_lock)) {
 		__mem_cgroup_remove_list(from_mz, pc);
 		res_counter_uncharge(&from->res, PAGE_SIZE);
+		if (do_swap_account)
+			res_counter_uncharge(&from->memsw, PAGE_SIZE);
 		pc->mem_cgroup = to;
 		__mem_cgroup_add_list(to_mz, pc, false);
 		ret = 0;
@@ -896,8 +937,11 @@ static int mem_cgroup_move_parent(struct
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
@@ -972,7 +1016,6 @@ int mem_cgroup_cache_charge(struct page 
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
 
-
 		pc = lookup_page_cgroup(page);
 		if (!pc)
 			return 0;
@@ -998,15 +1041,74 @@ int mem_cgroup_cache_charge(struct page 
 int mem_cgroup_cache_charge_swapin(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
+	struct mem_cgroup *mem;
+	swp_entry_t ent;
+	int ret;
+
 	if (mem_cgroup_subsys.disabled)
 		return 0;
-	if (unlikely(!mm))
-		mm = &init_mm;
-	return mem_cgroup_charge_common(page, mm, gfp_mask,
+
+	ent.val = page_private(page);
+	if (do_swap_account) {
+		mem = lookup_swap_cgroup(ent);
+		if (!mem || mem->obsolete)
+			goto charge_cur_mm;
+		ret = mem_cgroup_charge_common(page, NULL, gfp_mask,
+				       MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
+	} else {
+charge_cur_mm:
+		if (unlikely(!mm))
+			mm = &init_mm;
+		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
+	}
+	if (do_swap_account && !ret) {
+		/*
+		 * At this point, we successfully charge both for mem and swap.
+		 * fix this double counting, here.
+		 */
+		mem = swap_cgroup_record(ent, NULL);
+		if (mem) {
+			/* If memcg is obsolete, memcg can be != ptr */
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+			mem_cgroup_forget_swapref(mem);
+		}
+	}
+	return ret;
+}
+
+/*
+ * look into swap_cgroup and charge against mem_cgroup which does swapout
+ * if we can. If not, charge against current mm.
+ */
+
+int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
+		struct page *page, gfp_t mask, struct mem_cgroup **ptr)
+{
+	struct mem_cgroup *mem;
+	swp_entry_t	ent;
+
+	if (mem_cgroup_subsys.disabled)
+		return 0;
 
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
 }
 
+
+
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 {
 	struct page_cgroup *pc;
@@ -1017,6 +1119,23 @@ void mem_cgroup_commit_charge_swapin(str
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
@@ -1026,35 +1145,50 @@ void mem_cgroup_cancel_charge_swapin(str
 	if (!mem)
 		return;
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 	css_put(&mem->css);
 }
 
-
 /*
  * uncharge if !page_mapped(page)
+ * returns memcg at success.
  */
-static void
+static struct mem_cgroup *
 __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
 
 	if (mem_cgroup_subsys.disabled)
-		return;
+		return NULL;
 
+	if (PageSwapCache(page))
+		return NULL;
 	/*
 	 * Check if our page_cgroup is valid
 	 */
 	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc || !PageCgroupUsed(pc)))
-		return;
+		return NULL;
 
 	lock_page_cgroup(pc);
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
+		if (PageAnon(page)) {
+			if (page_mapped(page)) {
+				unlock_page_cgroup(pc);
+				return NULL;
+			}
+		} else if (page->mapping && !page_is_file_cache(page)) {
+			/* This is on radix-tree. */
+			unlock_page_cgroup(pc);
+			return NULL;
+		}
+	}
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED && page_mapped(page))
 	     || !PageCgroupUsed(pc)) {
 		/* This happens at race in zap_pte_range() and do_swap_page()*/
 		unlock_page_cgroup(pc);
-		return;
+		return NULL;
 	}
 	ClearPageCgroupUsed(pc);
 	mem = pc->mem_cgroup;
@@ -1063,9 +1197,11 @@ __mem_cgroup_uncharge_common(struct page
 	 * unlock this.
 	 */
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	if (do_swap_account && ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
+		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 	unlock_page_cgroup(pc);
 	release_page_cgroup(pc);
-	return;
+	return mem;
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
@@ -1086,6 +1222,41 @@ void mem_cgroup_uncharge_cache_page(stru
 }
 
 /*
+ * called from __delete_from_swap_cache() and drop "page" account.
+ * memcg information is recorded to swap_cgroup of "ent"
+ */
+void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = __mem_cgroup_uncharge_common(page,
+					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
+	/* record memcg information */
+	if (do_swap_account && memcg) {
+		swap_cgroup_record(ent, memcg);
+		atomic_inc(&memcg->swapref);
+	}
+}
+
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
+
+/*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
  */
@@ -1219,13 +1390,56 @@ int mem_cgroup_resize_limit(struct mem_c
 			ret = -EBUSY;
 			break;
 		}
-		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL);
+		progress = try_to_free_mem_cgroup_pages(memcg,
+				GFP_KERNEL);
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
+		 * open coded mannaer. You see what this really does.
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
+		try_to_free_mem_cgroup_pages(memcg, GFP_HIGHUSER_MOVABLE);
+		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
+		if (curusage >= oldusage)
+			retry_count--;
+	}
+	return ret;
+}
+
 
 /*
  * This routine traverse page_cgroup in given list and drop them all.
@@ -1353,8 +1567,25 @@ try_to_free:
 
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
@@ -1364,15 +1595,22 @@ static int mem_cgroup_write(struct cgrou
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
@@ -1384,14 +1622,23 @@ static int mem_cgroup_write(struct cgrou
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
@@ -1445,30 +1692,33 @@ static int mem_control_stat_show(struct 
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
@@ -1476,6 +1726,31 @@ static struct cftype mem_cgroup_files[] 
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
+		.name = "failcnt",
+		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_FAILCNT),
+		.trigger = mem_cgroup_reset,
+		.read_u64 = mem_cgroup_read,
+	},
+#endif
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -1529,14 +1804,43 @@ static struct mem_cgroup *mem_cgroup_all
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
 static void mem_cgroup_init_pcp(int cpu)
 {
 	page_cgroup_start_cache_cpu(cpu);
@@ -1589,6 +1893,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	}
 
 	res_counter_init(&mem->res);
+	res_counter_init(&mem->memsw);
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
@@ -1607,6 +1912,7 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	mem->obsolete = 1;
 	mem_cgroup_force_empty(mem);
 }
 
Index: mmotm-2.6.27+/mm/swapfile.c
===================================================================
--- mmotm-2.6.27+.orig/mm/swapfile.c
+++ mmotm-2.6.27+/mm/swapfile.c
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
Index: mmotm-2.6.27+/mm/swap_state.c
===================================================================
--- mmotm-2.6.27+.orig/mm/swap_state.c
+++ mmotm-2.6.27+/mm/swap_state.c
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
@@ -119,6 +122,7 @@ void __delete_from_swap_cache(struct pag
 	total_swapcache_pages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
+	mem_cgroup_uncharge_swapcache(page, ent);
 }
 
 /**
Index: mmotm-2.6.27+/include/linux/swap.h
===================================================================
--- mmotm-2.6.27+.orig/include/linux/swap.h
+++ mmotm-2.6.27+/include/linux/swap.h
@@ -332,6 +332,23 @@ static inline void disable_swap_token(vo
 	put_swap_token(swap_token_mm);
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/* This function requires swp_entry_t definition. see memcontrol.c */
+extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+#else
+static inline void
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+{
+}
+#endif
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
+#else
+static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
+{
+}
+#endif
+
 #else /* CONFIG_SWAP */
 
 #define total_swap_pages			0
Index: mmotm-2.6.27+/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.27+.orig/include/linux/memcontrol.h
+++ mmotm-2.6.27+/include/linux/memcontrol.h
@@ -32,6 +32,8 @@ extern int mem_cgroup_newpage_charge(str
 /* for swap handling */
 extern int mem_cgroup_try_charge(struct mm_struct *mm,
 		gfp_t gfp_mask, struct mem_cgroup **ptr);
+extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
+		struct page *page, gfp_t mask, struct mem_cgroup **ptr);
 extern void mem_cgroup_commit_charge_swapin(struct page *page,
 					struct mem_cgroup *ptr);
 extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *ptr);
@@ -83,7 +85,6 @@ extern long mem_cgroup_calc_reclaim(stru
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
-
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
