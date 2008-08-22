Date: Fri, 22 Aug 2008 20:41:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 13/14] memcg: mem+swap counter
Message-Id: <20080822204157.15423d84.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Add counter for swap accounting to memory resource controller.

This adds 1 counter and 1 limit.
res.swaps and res.memsw_limit. res.swaps is a counter for # of swap usage.
(Later, you'll see res.swaps shows the number of swap _on_ disk)

these counter works as

  res.pages + res.swaps < res.memsw_limit.

This means the sum of on_memory_resource and on_swap_resource is limited.
So, a swap is accounted when an anonymous page is charged. By this, the
user can avoid unexpected massive use of swap and kswapd, the global LRU,
is not affected by swap resouce control feature when he try add_to_swap.
...swap is considered to be already accounted as page.

For avoiding too much #ifdefs, this patch uses "do_swap_account" macro.
If config=n, the compiler does good job and ignore some pieces of codes.

This patch doesn't includes swap_accounting infrastructure..then, 
CONFIG_CGROUP_MEM_RES_CTLR_SWAP is still broken.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |  121 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 112 insertions(+), 9 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -129,6 +129,8 @@ struct mem_counter {
 	unsigned long	pages;
 	unsigned long	pages_limit;
 	unsigned long	max_pages;
+	unsigned long	swaps;
+	unsigned long	memsw_limit;
 	unsigned long	failcnt;
 	spinlock_t	lock;
 };
@@ -178,6 +180,7 @@ DEFINE_PER_CPU(struct mem_cgroup_sink_li
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
+	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 };
 
@@ -186,6 +189,8 @@ enum {
 	MEMCG_FILE_PAGE_LIMIT,
 	MEMCG_FILE_PAGE_USAGE,
 	MEMCG_FILE_PAGE_MAX_USAGE,
+	MEMCG_FILE_SWAP_USAGE,
+	MEMCG_FILE_MEMSW_LIMIT,
 	MEMCG_FILE_FAILCNT,
 };
 
@@ -269,6 +274,7 @@ static void mem_counter_init(struct mem_
 {
 	memset(&mem->res, 0, sizeof(mem->res));
 	mem->res.pages_limit = ~0UL;
+	mem->res.memsw_limit = ~0UL;
 	spin_lock_init(&mem->res.lock);
 }
 
@@ -279,6 +285,10 @@ static int mem_counter_charge(struct mem
 	spin_lock_irqsave(&mem->res.lock, flags);
 	if (mem->res.pages + num > mem->res.pages_limit)
 		goto busy_out;
+	if (do_swap_account &&
+	    (mem->res.pages + mem->res.swaps > mem->res.memsw_limit))
+		goto busy_out;
+
 	mem->res.pages += num;
 	if (mem->res.pages > mem->res.max_pages)
 		mem->res.max_pages = mem->res.pages;
@@ -298,6 +308,27 @@ static void mem_counter_uncharge_page(st
 	spin_unlock_irqrestore(&mem->res.lock, flags);
 }
 
+static void mem_counter_recharge_swap(struct mem_cgroup *mem)
+{
+        unsigned long flags;
+	if (do_swap_account) {
+        	spin_lock_irqsave(&mem->res.lock, flags);
+		mem->res.pages -= 1;
+        	mem->res.swaps += 1;
+        	spin_unlock_irqrestore(&mem->res.lock, flags);
+	}
+}
+
+static void mem_counter_uncharge_swap(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	if (do_swap_account) {
+		spin_lock_irqsave(&mem->res.lock, flags);
+		mem->res.swaps -= 1;
+		spin_unlock_irqrestore(&mem->res.lock, flags);
+	}
+}
+
 static int mem_counter_set_pages_limit(struct mem_cgroup *mem,
 					unsigned long num)
 {
@@ -305,7 +336,9 @@ static int mem_counter_set_pages_limit(s
 	int ret = -EBUSY;
 
 	spin_lock_irqsave(&mem->res.lock, flags);
-	if (mem->res.pages < num) {
+	if (mem->res.memsw_limit < num) {
+		ret = -EINVAL;
+	} else if (mem->res.pages < num) {
 		mem->res.pages_limit = num;
 		ret = 0;
 	}
@@ -313,6 +346,23 @@ static int mem_counter_set_pages_limit(s
 	return ret;
 }
 
+static int
+mem_counter_set_memsw_limit(struct mem_cgroup *mem, unsigned long num)
+{
+	unsigned long flags;
+	int ret = -EBUSY;
+
+	spin_lock_irqsave(&mem->res.lock, flags);
+	if (mem->res.pages_limit > num) {
+		ret = -EINVAL;
+	} else if (mem->res.swaps + mem->res.pages < num) {
+		mem->res.memsw_limit = num;
+		ret = 0;
+	}
+	spin_unlock_irqrestore(&mem->res.lock, flags);
+	return ret;
+}
+
 static int mem_counter_check_under_pages_limit(struct mem_cgroup *mem)
 {
 	if (mem->res.pages < mem->res.pages_limit)
@@ -320,6 +370,15 @@ static int mem_counter_check_under_pages
 	return 0;
 }
 
+static int mem_counter_check_under_memsw_limit(struct mem_cgroup *mem)
+{
+	if (!do_swap_account)
+		return 1;
+	if (mem->res.pages + mem->res.swaps < mem->res.memsw_limit)
+		return 1;
+	return 0;
+}
+
 static void mem_counter_reset(struct mem_cgroup *mem, int member)
 {
 	unsigned long flags;
@@ -772,20 +831,28 @@ static int mem_cgroup_charge_common(stru
 	}
 
 	while (mem_counter_charge(mem, 1)) {
+		int progress;
 		if (!(gfp_mask & __GFP_WAIT))
 			goto out;
 
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
-			continue;
+		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
 
 		/*
+		 * When we hit memsw limit, return value of "progress"
+		 * has no meaning. (some pages may just be changed to swap)
+		 */
+		if (mem_counter_check_under_memsw_limit(mem) && progress)
+			continue;
+		/*
 		 * try_to_free_mem_cgroup_pages() might not give us a full
 		 * picture of reclaim. Some pages are reclaimed and might be
 		 * moved to swap cache or just unmapped from the cgroup.
 		 * Check the limit again to see if the reclaim reduced the
 		 * current usage of the cgroup before giving up
 		 */
-		if (mem_counter_check_under_pages_limit(mem))
+
+		if (!do_swap_account
+		   && mem_counter_check_under_pages_limit(mem))
 			continue;
 
 		if (!nr_retries--) {
@@ -938,7 +1005,10 @@ __mem_cgroup_uncharge_common(struct page
 	SetPcgObsolete(pc);
 	page_assign_page_cgroup(page, NULL);
 
-	mem_counter_uncharge_page(mem, 1);
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
+		mem_counter_recharge_swap(mem);
+	else
+		mem_counter_uncharge_page(mem, 1);
 	free_obsolete_page_cgroup(pc);
 
 out:
@@ -1040,7 +1110,9 @@ int mem_cgroup_shrink_usage(struct mm_st
 	return 0;
 }
 
-int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long val)
+int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
+			    unsigned long long val,
+			    bool memswap)
 {
 
 	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
@@ -1051,7 +1123,14 @@ int mem_cgroup_resize_limit(struct mem_c
 	if (val & PAGE_SIZE)
 		new_lim += 1;
 
-	while (mem_counter_set_pages_limit(memcg, new_lim)) {
+	do {
+		if (memswap)
+			ret = mem_counter_set_memsw_limit(memcg, new_lim);
+		else
+			ret = mem_counter_set_pages_limit(memcg, new_lim);
+
+		if (!ret || ret == -EINVAL)
+			break;
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
@@ -1063,7 +1142,8 @@ int mem_cgroup_resize_limit(struct mem_c
 		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL);
 		if (!progress)
 			retry_count--;
-	}
+	} while (1);
+
 	return ret;
 }
 
@@ -1214,6 +1294,12 @@ static u64 mem_cgroup_read(struct cgroup
 	case MEMCG_FILE_FAILCNT:
 		ret = (unsigned long long)mem->res.failcnt;
 		break;
+	case MEMCG_FILE_SWAP_USAGE:
+		ret = (unsigned long long)mem->res.swaps << PAGE_SHIFT;
+		break;
+	case MEMCG_FILE_MEMSW_LIMIT:
+		ret = (unsigned long long)mem->res.memsw_limit << PAGE_SHIFT;
+		break;
 	default:
 		BUG();
 	}
@@ -1240,9 +1326,13 @@ static int mem_cgroup_write(struct cgrou
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	unsigned long long val;
+	bool memswap = false;
 	int ret;
 
 	switch (cft->private) {
+	case MEMCG_FILE_MEMSW_LIMIT:
+		memswap = true;
+		/* Fall through */
 	case MEMCG_FILE_PAGE_LIMIT:
 		if (memcg->no_limit == 1) {
 			ret = -EINVAL;
@@ -1251,7 +1341,7 @@ static int mem_cgroup_write(struct cgrou
 		/* This function does all necessary parse...reuse it */
 		ret = call_memparse(buffer, &val);
 		if (!ret)
-			ret = mem_cgroup_resize_limit(memcg, val);
+			ret = mem_cgroup_resize_limit(memcg, val, memswap);
 		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
@@ -1364,6 +1454,19 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+	{
+		.name = "swap_in_bytes",
+		.private = MEMCG_FILE_SWAP_USAGE,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
+		.name = "memswap_limit_in_bytes",
+		.private = MEMCG_FILE_MEMSW_LIMIT,
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	}
+#endif
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
