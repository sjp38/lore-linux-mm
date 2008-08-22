Date: Fri, 22 Aug 2008 20:39:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 10/14] memcg: replace res_counter
Message-Id: <20080822203919.1aee02fc.kamezawa.hiroyu@jp.fujitsu.com>
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

For mem+swap controller, we'll use special counter which has 2 values and
2 limit. Before doing that, replace current res_counter with new mem_counter.

This patch doen't have much meaning other than for clean up before mem+swap
controller. New mem_counter's counter is "unsigned long" and account resource by
# of pages. (I think "unsigned long" is safe under 32bit machines when we count
resource by # of pages rather than bytes.) No changes in user interface.
User interface is in "bytes".

Using "unsigned long long", we have to be nervous to read to temporal value
without lock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  177 +++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 151 insertions(+), 26 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -17,10 +17,9 @@
  * GNU General Public License for more details.
  */
 
-#include <linux/res_counter.h>
+#include <linux/mm.h>
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
-#include <linux/mm.h>
 #include <linux/smp.h>
 #include <linux/page-flags.h>
 #include <linux/backing-dev.h>
@@ -118,12 +117,21 @@ struct mem_cgroup_lru_info {
  * no reclaim occurs from a cgroup at it's low water mark, this is
  * a feature that will be implemented much later in the future.
  */
+struct mem_counter {
+	unsigned long	pages;
+	unsigned long	pages_limit;
+	unsigned long	max_pages;
+	unsigned long	failcnt;
+	spinlock_t	lock;
+};
+
+
 struct mem_cgroup {
 	struct cgroup_subsys_state css;
 	/*
 	 * the counter to account for memory usage
 	 */
-	struct res_counter res;
+	struct mem_counter res;
 	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
@@ -161,6 +169,14 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 };
 
+/* Private File ID for memory resource controller's interface */
+enum {
+	MEMCG_FILE_PAGE_LIMIT,
+	MEMCG_FILE_PAGE_USAGE,
+	MEMCG_FILE_PAGE_MAX_USAGE,
+	MEMCG_FILE_FAILCNT,
+};
+
 /*
  * Always modified under lru lock. Then, not necessary to preempt_disable()
  */
@@ -234,6 +250,81 @@ static void page_assign_page_cgroup(stru
 	rcu_assign_pointer(page->page_cgroup, pc);
 }
 
+/*
+ * counter for memory resource accounting.
+ */
+static void mem_counter_init(struct mem_cgroup *mem)
+{
+	memset(&mem->res, 0, sizeof(mem->res));
+	mem->res.pages_limit = ~0UL;
+	spin_lock_init(&mem->res.lock);
+}
+
+static int mem_counter_charge(struct mem_cgroup *mem, long num)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mem->res.lock, flags);
+	if (mem->res.pages + num > mem->res.pages_limit)
+		goto busy_out;
+	mem->res.pages += num;
+	if (mem->res.pages > mem->res.max_pages)
+		mem->res.max_pages = mem->res.pages;
+	spin_unlock_irqrestore(&mem->res.lock, flags);
+	return 0;
+busy_out:
+	mem->res.failcnt++;
+	spin_unlock_irqrestore(&mem->res.lock, flags);
+	return -EBUSY;
+}
+
+static void mem_counter_uncharge_page(struct mem_cgroup *mem, long num)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&mem->res.lock, flags);
+	mem->res.pages -= num;
+	spin_unlock_irqrestore(&mem->res.lock, flags);
+}
+
+static int mem_counter_set_pages_limit(struct mem_cgroup *mem,
+					unsigned long num)
+{
+	unsigned long flags;
+	int ret = -EBUSY;
+
+	spin_lock_irqsave(&mem->res.lock, flags);
+	if (mem->res.pages < num) {
+		mem->res.pages_limit = num;
+		ret = 0;
+	}
+	spin_unlock_irqrestore(&mem->res.lock, flags);
+	return ret;
+}
+
+static int mem_counter_check_under_pages_limit(struct mem_cgroup *mem)
+{
+	if (mem->res.pages < mem->res.pages_limit)
+		return 1;
+	return 0;
+}
+
+static void mem_counter_reset(struct mem_cgroup *mem, int member)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mem->res.lock, flags);
+	switch (member) {
+	case MEMCG_FILE_PAGE_MAX_USAGE:
+		mem->res.max_pages = 0;
+		break;
+	case MEMCG_FILE_FAILCNT:
+		mem->res.failcnt = 0;
+		break;
+	}
+	spin_unlock_irqrestore(&mem->res.lock, flags);
+}
+
+
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
 {
@@ -356,7 +447,7 @@ int mem_cgroup_calc_mapped_ratio(struct 
 	 * usage is recorded in bytes. But, here, we assume the number of
 	 * physical pages can be represented by "long" on any arch.
 	 */
-	total = (long) (mem->res.usage >> PAGE_SHIFT) + 1L;
+	total = (long) (mem->res.pages >> PAGE_SHIFT) + 1L;
 	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
 	return (int)((rss * 100L) / total);
 }
@@ -605,7 +696,7 @@ static int mem_cgroup_charge_common(stru
 		css_get(&memcg->css);
 	}
 
-	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
+	while (mem_counter_charge(mem, 1)) {
 		if (!(gfp_mask & __GFP_WAIT))
 			goto out;
 
@@ -619,7 +710,7 @@ static int mem_cgroup_charge_common(stru
 		 * Check the limit again to see if the reclaim reduced the
 		 * current usage of the cgroup before giving up
 		 */
-		if (res_counter_check_under_limit(&mem->res))
+		if (mem_counter_check_under_pages_limit(mem))
 			continue;
 
 		if (!nr_retries--) {
@@ -772,7 +863,7 @@ __mem_cgroup_uncharge_common(struct page
 	SetPcgObsolete(pc);
 	page_assign_page_cgroup(page, NULL);
 
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	mem_counter_uncharge_page(mem, 1);
 	free_obsolete_page_cgroup(pc);
 
 out:
@@ -880,8 +971,12 @@ int mem_cgroup_resize_limit(struct mem_c
 	int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
 	int progress;
 	int ret = 0;
+	unsigned long new_lim = (unsigned long)(val >> PAGE_SHIFT);
 
-	while (res_counter_set_limit(&memcg->res, val)) {
+	if (val & PAGE_SIZE)
+		new_lim += 1;
+
+	while (mem_counter_set_pages_limit(memcg, new_lim)) {
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
@@ -913,7 +1008,7 @@ int mem_cgroup_move_account(struct page 
 	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
 	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
 
-	if (res_counter_charge(&to->res, PAGE_SIZE)) {
+	if (mem_counter_charge(to, 1)) {
 		/* Now, we assume no_limit...no failure here. */
 		return ret;
 	}
@@ -921,14 +1016,14 @@ int mem_cgroup_move_account(struct page 
 	if (spin_trylock(&to_mz->lru_lock)) {
 		__mem_cgroup_remove_list(from_mz, pc);
 		css_put(&from->css);
-		res_counter_uncharge(&from->res, PAGE_SIZE);
+		mem_counter_uncharge_page(from, 1);
 		pc->mem_cgroup = to;
 		css_get(&to->css);
 		__mem_cgroup_add_list(to_mz, pc);
 		ret = 0;
 		spin_unlock(&to_mz->lru_lock);
 	} else {
-		res_counter_uncharge(&to->res, PAGE_SIZE);
+		mem_counter_uncharge_page(to, 1);
 	}
 
 	return ret;
@@ -1008,7 +1103,7 @@ static int mem_cgroup_force_empty(struct
 	 * active_list <-> inactive_list while we don't take a lock.
 	 * So, we have to do loop here until all lists are empty.
 	 */
-	while (mem->res.usage > 0) {
+	while (mem->res.pages > 0) {
 		if (atomic_read(&mem->css.cgroup->count) > 0)
 			goto out;
 		for_each_node_state(node, N_POSSIBLE)
@@ -1028,13 +1123,43 @@ out:
 
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
-	return res_counter_read_u64(&mem_cgroup_from_cont(cont)->res,
-				    cft->private);
+	unsigned long long ret;
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+
+	switch (cft->private) {
+	case MEMCG_FILE_PAGE_LIMIT:
+		ret = (unsigned long long)mem->res.pages_limit << PAGE_SHIFT;
+		break;
+	case MEMCG_FILE_PAGE_USAGE:
+		ret = (unsigned long long)mem->res.pages << PAGE_SHIFT;
+		break;
+	case MEMCG_FILE_PAGE_MAX_USAGE:
+		ret = (unsigned long long)mem->res.max_pages << PAGE_SHIFT;
+		break;
+	case MEMCG_FILE_FAILCNT:
+		ret = (unsigned long long)mem->res.failcnt;
+		break;
+	default:
+		BUG();
+	}
+	return ret;
 }
 /*
  * The user of this function is...
  * RES_LIMIT.
  */
+static int call_memparse(const char *buf, unsigned long long *val)
+{
+	char *end;
+
+	*val = memparse((char *)buf, &end);
+	if (*end != '\0')
+		return -EINVAL;
+	*val = PAGE_ALIGN(*val);
+	return 0;
+}
+
+
 static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			    const char *buffer)
 {
@@ -1043,13 +1168,13 @@ static int mem_cgroup_write(struct cgrou
 	int ret;
 
 	switch (cft->private) {
-	case RES_LIMIT:
+	case MEMCG_FILE_PAGE_LIMIT:
 		if (memcg->no_limit == 1) {
 			ret = -EINVAL;
 			break;
 		}
 		/* This function does all necessary parse...reuse it */
-		ret = res_counter_memparse_write_strategy(buffer, &val);
+		ret = call_memparse(buffer, &val);
 		if (!ret)
 			ret = mem_cgroup_resize_limit(memcg, val);
 		break;
@@ -1066,12 +1191,12 @@ static int mem_cgroup_reset(struct cgrou
 
 	mem = mem_cgroup_from_cont(cont);
 	switch (event) {
-	case RES_MAX_USAGE:
-		res_counter_reset_max(&mem->res);
-		break;
-	case RES_FAILCNT:
-		res_counter_reset_failcnt(&mem->res);
+	case MEMCG_FILE_PAGE_MAX_USAGE:
+	case MEMCG_FILE_FAILCNT:
+		mem_counter_reset(mem, event);
 		break;
+	default:
+		BUG();
 	}
 	return 0;
 }
@@ -1135,24 +1260,24 @@ static int mem_control_stat_show(struct 
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
-		.private = RES_USAGE,
+		.private = MEMCG_FILE_PAGE_USAGE,
 		.read_u64 = mem_cgroup_read,
 	},
 	{
 		.name = "max_usage_in_bytes",
-		.private = RES_MAX_USAGE,
+		.private = MEMCG_FILE_PAGE_MAX_USAGE,
 		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
 	{
 		.name = "limit_in_bytes",
-		.private = RES_LIMIT,
+		.private = MEMCG_FILE_PAGE_LIMIT,
 		.write_string = mem_cgroup_write,
 		.read_u64 = mem_cgroup_read,
 	},
 	{
 		.name = "failcnt",
-		.private = RES_FAILCNT,
+		.private = MEMCG_FILE_FAILCNT,
 		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
@@ -1241,7 +1366,7 @@ mem_cgroup_create(struct cgroup_subsys *
 			return ERR_PTR(-ENOMEM);
 	}
 
-	res_counter_init(&mem->res);
+	mem_counter_init(mem);
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
