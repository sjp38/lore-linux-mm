Date: Fri, 17 Oct 2008 20:04:53 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mm 4/5] memcg: mem+swap counter
Message-Id: <20081017200453.9cca0e78.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Add counter for swap accounting to memory resource controller.

This adds 2 counter and 1 limit.
res.swaps, res.disk_swaps and res.memsw_limit.
res.swaps is a counter for # of swap usage, and res.disk_swaps is
for # of swap on disk.

these counter works as

  res.pages + res.disk_swaps < res.memsw_limit.

This means the sum of on_memory_resource and on_swap_resource is limited.
So, a swap is accounted when an anonymous page is charged. By this, the
user can avoid unexpected massive use of swap and kswapd, the global LRU,
is not affected by swap resouce control feature when he try add_to_swap.
...swap is considered to be already accounted as page.

For avoiding too much #ifdefs, this patch uses "do_swap_account" macro.
If config=n, the compiler does good job and ignore some pieces of codes.

This patch doesn't includes swap_accounting infrastructure..then,
CONFIG_CGROUP_MEM_RES_CTLR_SWAP is still broken.

Changelog: v2 -> v3
  - trivial fix
  - rebase on memcg-update-v7
  - removed MEM_CGROUP_CHARGE_TYPE_SWAPOUT, mem_counter_recharge_swap,
    and mem_counter_uncharge_swap. They will be defined in later patch.
  - chaged counter "swaps" to "disk_swaps" and removed the I/F to read it.
  - added new counter "swaps", which means acutual usage of swap,
    and I/F to read it.
  - add I/F to read memswap_usage_in_bytes.
  - allow memsw_limit < pages_limit when pages_limit == ~0UL.
  - add arg "use_swap" to try_to_mem_cgroup_pages() and use it sc->may_swap.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

diff --git a/include/linux/swap.h b/include/linux/swap.h
index e958419..be0b575 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -213,7 +213,8 @@ static inline void lru_cache_add_active_file(struct page *page)
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-							gfp_t gfp_mask);
+							gfp_t gfp_mask,
+							int use_swap);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 023c7bc..d712547 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -127,6 +127,9 @@ struct mem_counter {
 	unsigned long	pages;
 	unsigned long	pages_limit;
 	unsigned long	max_pages;
+	unsigned long	swaps;
+	unsigned long	disk_swaps;
+	unsigned long	memsw_limit;
 	unsigned long	failcnt;
 	spinlock_t	lock;
 };
@@ -183,6 +186,9 @@ enum {
 	MEMCG_FILE_PAGE_LIMIT,
 	MEMCG_FILE_PAGE_USAGE,
 	MEMCG_FILE_PAGE_MAX_USAGE,
+	MEMCG_FILE_MEMSW_LIMIT,
+	MEMCG_FILE_MEMSW_USAGE,
+	MEMCG_FILE_SWAP_USAGE,
 	MEMCG_FILE_FAILCNT,
 };
 
@@ -272,6 +278,7 @@ static void mem_counter_init(struct mem_cgroup *mem)
 {
 	memset(&mem->res, 0, sizeof(mem->res));
 	mem->res.pages_limit = ~0UL;
+	mem->res.memsw_limit = ~0UL;
 	spin_lock_init(&mem->res.lock);
 }
 
@@ -282,6 +289,10 @@ static int mem_counter_charge(struct mem_cgroup *mem, long num)
 	spin_lock_irqsave(&mem->res.lock, flags);
 	if (mem->res.pages + num > mem->res.pages_limit)
 		goto busy_out;
+	if (do_swap_account &&
+	    (mem->res.pages + mem->res.disk_swaps + num > mem->res.memsw_limit))
+		goto busy_out;
+
 	mem->res.pages += num;
 	if (mem->res.pages > mem->res.max_pages)
 		mem->res.max_pages = mem->res.pages;
@@ -297,6 +308,8 @@ static void mem_counter_uncharge_page(struct mem_cgroup *mem, long num)
 {
 	unsigned long flags;
 	spin_lock_irqsave(&mem->res.lock, flags);
+	if (WARN_ON(mem->res.pages < num))
+		num = mem->res.pages;
 	mem->res.pages -= num;
 	spin_unlock_irqrestore(&mem->res.lock, flags);
 }
@@ -308,7 +321,9 @@ static int mem_counter_set_pages_limit(struct mem_cgroup *mem,
 	int ret = -EBUSY;
 
 	spin_lock_irqsave(&mem->res.lock, flags);
-	if (mem->res.pages < num) {
+	if (mem->res.memsw_limit < num) {
+		ret = -EINVAL;
+	} else if (mem->res.pages < num) {
 		mem->res.pages_limit = num;
 		ret = 0;
 	}
@@ -316,6 +331,23 @@ static int mem_counter_set_pages_limit(struct mem_cgroup *mem,
 	return ret;
 }
 
+static int
+mem_counter_set_memsw_limit(struct mem_cgroup *mem, unsigned long num)
+{
+	unsigned long flags;
+	int ret = -EBUSY;
+
+	spin_lock_irqsave(&mem->res.lock, flags);
+	if (mem->res.pages_limit != ~0UL && mem->res.pages_limit > num) {
+		ret = -EINVAL;
+	} else if (mem->res.disk_swaps + mem->res.pages < num) {
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
@@ -323,6 +355,15 @@ static int mem_counter_check_under_pages_limit(struct mem_cgroup *mem)
 	return 0;
 }
 
+static int mem_counter_check_under_memsw_limit(struct mem_cgroup *mem)
+{
+	if (!do_swap_account)
+		return 1;
+	if (mem->res.pages + mem->res.disk_swaps < mem->res.memsw_limit)
+		return 1;
+	return 0;
+}
+
 static void mem_counter_reset(struct mem_cgroup *mem, int member)
 {
 	unsigned long flags;
@@ -339,6 +380,16 @@ static void mem_counter_reset(struct mem_cgroup *mem, int member)
 	spin_unlock_irqrestore(&mem->res.lock, flags);
 }
 
+static int should_use_swap(struct mem_cgroup *mem)
+{
+	if (!do_swap_account)
+		return 1;
+	if (!mem_counter_check_under_pages_limit(mem) &&
+	    mem->res.pages_limit != mem->res.memsw_limit)
+		return 1;
+	return 0;
+}
+
 /*
  * private ID management for memcg.
  * set/clear bitmap is called by create/destroy and done under cgroup_mutex.
@@ -859,10 +910,18 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 
 	while (unlikely(mem_counter_charge(mem, 1))) {
+		int progress;
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
+		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask,
+							should_use_swap(mem));
+
+		/*
+		 * When we hit memsw limit, return value of "progress"
+		 * has no meaning. (some pages may just be changed to swap)
+		 */
+		if (mem_counter_check_under_memsw_limit(mem) && progress)
 			continue;
 
 		/*
@@ -872,7 +931,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		 * Check the limit again to see if the reclaim reduced the
 		 * current usage of the cgroup before giving up
 		 */
-		if (mem_counter_check_under_pages_limit(mem))
+		if (!do_swap_account
+		   && mem_counter_check_under_pages_limit(mem))
 			continue;
 
 		if (!nr_retries--) {
@@ -1339,8 +1399,10 @@ int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
 	rcu_read_unlock();
 
 	do {
-		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
-		progress += mem_counter_check_under_pages_limit(mem);
+		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask,
+							should_use_swap(mem));
+		progress += mem_counter_check_under_pages_limit(mem) &&
+			mem_counter_check_under_memsw_limit(mem);
 	} while (!progress && --retry);
 
 	css_put(&mem->css);
@@ -1349,7 +1411,9 @@ int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
 	return 0;
 }
 
-int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long val)
+int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
+			    unsigned long long val,
+			    bool memswap)
 {
 
 	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
@@ -1360,7 +1424,14 @@ int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long val)
 	if (val & (PAGE_SIZE-1))
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
@@ -1369,10 +1440,12 @@ int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long val)
 			ret = -EBUSY;
 			break;
 		}
-		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL);
+		progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL,
+							!memswap);
 		if (!progress)
 			retry_count--;
-	}
+	} while (1);
+
 	return ret;
 }
 
@@ -1489,7 +1562,7 @@ try_to_free:
 	while (nr_retries && mem->res.pages > 0) {
 		int progress;
 		progress = try_to_free_mem_cgroup_pages(mem,
-						  GFP_HIGHUSER_MOVABLE);
+						  GFP_HIGHUSER_MOVABLE, 1);
 		if (!progress)
 			nr_retries--;
 
@@ -1519,6 +1592,16 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 	case MEMCG_FILE_FAILCNT:
 		ret = (unsigned long long)mem->res.failcnt;
 		break;
+	case MEMCG_FILE_SWAP_USAGE:
+		ret = (unsigned long long)mem->res.swaps << PAGE_SHIFT;
+		break;
+	case MEMCG_FILE_MEMSW_LIMIT:
+		ret = (unsigned long long)mem->res.memsw_limit << PAGE_SHIFT;
+		break;
+	case MEMCG_FILE_MEMSW_USAGE:
+		ret = (unsigned long long)(mem->res.pages + mem->res.disk_swaps)
+					  << PAGE_SHIFT;
+		break;
 	default:
 		BUG();
 	}
@@ -1545,14 +1628,18 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
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
 		/* This function does all necessary parse...reuse it */
 		ret = call_memparse(buffer, &val);
 		if (!ret)
-			ret = mem_cgroup_resize_limit(memcg, val);
+			ret = mem_cgroup_resize_limit(memcg, val, memswap);
 		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
@@ -1665,6 +1752,24 @@ static struct cftype mem_cgroup_files[] = {
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
+		.name = "memswap_usage_in_bytes",
+		.private = MEMCG_FILE_MEMSW_USAGE,
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
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33e4319..4007c48 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1756,11 +1756,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
-						gfp_t gfp_mask)
+						gfp_t gfp_mask,
+						int use_swap)
 {
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
-		.may_swap = 1,
+		.may_swap = use_swap,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
 		.order = 0,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
