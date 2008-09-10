Subject: [PATCH][RFC] memory.min_usage again
In-Reply-To: Your message of "Tue,  4 Dec 2007 13:09:34 +0900 (JST)"
	<20071204040934.44AF41D0BA3@siro.lan>
References: <20071204040934.44AF41D0BA3@siro.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080910084443.8F7D85ACE@siro.lan>
Date: Wed, 10 Sep 2008 17:44:43 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: containers@lists.osdl.org, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

hi,

> hi,
> 
> here's a patch to implement memory.min_usage,
> which controls the minimum memory usage for a cgroup.
> 
> it works similarly to mlock;
> global memory reclamation doesn't reclaim memory from
> cgroups whose memory usage is below the value.
> setting it too high is a dangerous operation.
> 
> it's against 2.6.24-rc3-mm2 + memory.swappiness patch i posted here yesterday.
> but it's logically independent from the swappiness patch.
> 
> todo:
> - restrict non-root user's operation ragardless of owner of cgroupfs files?
> - make oom killer aware of this?
> 
> YAMAMOTO Takashi

here's a new version adapted to 2.6.27-rc5-mm1.

YAMAMOTO Takashi


Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
---

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee1b2fc..fdf35bf 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -72,6 +72,8 @@ extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
 extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru);
 
+extern int mem_cgroup_canreclaim(struct page *page, struct mem_cgroup *mem);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 static inline void page_reset_bad_cgroup(struct page *page)
 {
@@ -163,6 +165,13 @@ static inline long mem_cgroup_calc_reclaim(struct mem_cgroup *mem,
 {
 	return 0;
 }
+
+static inline int mem_cgroup_canreclaim(struct page *page,
+					struct mem_cgroup *mem)
+{
+	return 1;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2979d22..a567bdb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -129,6 +129,7 @@ struct mem_cgroup {
 	struct mem_cgroup_lru_info info;
 
 	int	prev_priority;	/* for recording reclaim priority */
+	unsigned long long min_usage; /* XXX should be a part of res_counter? */
 	/*
 	 * statistics.
 	 */
@@ -1004,6 +1005,28 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	return 0;
 }
 
+static int mem_cgroup_min_usage_write(struct cgroup *cg, struct cftype *cft,
+			    const char *buffer)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cg);
+	unsigned long long val;
+	int error;
+
+	error = res_counter_memparse_write_strategy(buffer, &val);
+	if (error)
+		return error;
+
+	mem->min_usage = val;
+	return 0;
+}
+
+static u64 mem_cgroup_min_usage_read(struct cgroup *cg, struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cg);
+
+	return mem->min_usage;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1036,8 +1059,43 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "min_usage_in_bytes",
+		.write_string = mem_cgroup_min_usage_write,
+		.read_u64 = mem_cgroup_min_usage_read,
+	},
 };
 
+int mem_cgroup_canreclaim(struct page *page, struct mem_cgroup *mem1)
+{
+	struct page_cgroup *pc;
+	int result = 1;
+
+	if (mem1 != NULL)
+		return 1;
+
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	if (pc) {
+		struct mem_cgroup *mem2 = pc->mem_cgroup;
+		unsigned long long min_usage;
+
+		BUG_ON(mem2 == NULL);
+		min_usage = mem2->min_usage;
+		if (min_usage != 0) {
+			unsigned long flags;
+
+			spin_lock_irqsave(&mem2->res.lock, flags);
+			if (mem2->res.usage <= min_usage)
+				result = 0;
+			spin_unlock_irqrestore(&mem2->res.lock, flags);
+		}
+	}
+	unlock_page_cgroup(page);
+
+	return result;
+}
+
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 {
 	struct mem_cgroup_per_node *pn;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33e4319..ef37968 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -673,6 +673,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					referenced && page_mapping_inuse(page))
 			goto activate_locked;
 
+		if (!mem_cgroup_canreclaim(page, sc->mem_cgroup))
+			goto activate_locked;
+
 #ifdef CONFIG_SWAP
 		/*
 		 * Anonymous process memory has backing store?
@@ -1294,7 +1297,9 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			continue;
 		}
 
-		if (page_referenced(page, 0, sc->mem_cgroup)) {
+		if (!mem_cgroup_canreclaim(page, sc->mem_cgroup)) {
+			list_add(&page->lru, &l_active);
+		} else if (page_referenced(page, 0, sc->mem_cgroup)) {
 			pgmoved++;
 			if (file) {
 				/* Referenced file pages stay active. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
