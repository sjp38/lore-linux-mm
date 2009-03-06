Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 801F46B0115
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 05:37:46 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n26AbhKc015792
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Mar 2009 19:37:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F06B45DE54
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:37:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 71A9B45DE53
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:37:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A77AE08003
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:37:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DC6761DB803C
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:37:42 +0900 (JST)
Date: Fri, 6 Mar 2009 19:36:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/3]  soft limit interface (Yet Another One)
Message-Id: <20090306193623.cc28f37a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090306193438.8084837d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
	<20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>
	<20090306193438.8084837d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is a part of softlimit patch series for memcg.(1/3)

An interface for softlimit of memcg
This adds following params to memcg.

  - softlimit -- local softlimit of the memcg. exported as
		memory.softlimit file

  - softlimit_priority -- local softlimit priority of the memcg. exported as
	        memory.softlimit_priority
		high number is low priority...0 means "don't use soft limit"

  - min_softlimit_governor -- A memcg which has min softlimit in ancestors.

By this patch, following customization of memcg tree can be done (by users)
Example A)
    groupA softlimit = unlimited,prio=0    governor is group A.
     |- groupB softlimit = 1G,prio=1   governor is group B.
	  |- group C softlimit = unlimited,prio=3   governor is group B.
	  |- group D softlimit = unlimited,prio=2   governor is group B.
	  |- group E softlimit = unlimited,prio=3   governor is group B.

In above, group C and D,E 's its own softlimit is not set but under hierarchy,
it's dominated by groupB's one. Because Group C and E's priority is  lower
than GroupD's, they will be the first victim. (selection between C and E is
done by round-robin.)

Documentation will be added by following patches.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  146 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 143 insertions(+), 3 deletions(-)

Index: mmotm-2.6.29-Mar3/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar3.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar3/mm/memcontrol.c
@@ -175,7 +175,13 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
-
+	/*
+	 * softlimit
+	 */
+	u64 softlimit;
+	struct mem_cgroup *min_softlimit_governor;
+	int softlimit_priority;
+	struct list_head softlimit_list;
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -210,6 +216,10 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
+#define MEM_SOFTLIMIT           (0x10)
+#define MEM_SOFTLIMIT_PRIO      (0x11)
+
+
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -1537,6 +1547,44 @@ void mem_cgroup_uncharge_swap(swp_entry_
 #endif
 
 /*
+ * For softlimit handling.
+ */
+
+static DECLARE_RWSEM(softlimit_sem);
+#define SOFTLIMIT_MAX_PRIO  (4)
+
+struct {
+	struct list_head list[SOFTLIMIT_MAX_PRIO];
+} softlimit_head;
+
+static void __init init_softlimit(void)
+{
+	int i;
+	for (i = 0; i < SOFTLIMIT_MAX_PRIO; i++)
+		INIT_LIST_HEAD(&softlimit_head.list[i]);
+}
+
+static void softlimit_add_list_locked(struct mem_cgroup *mem)
+{
+	int level = mem->softlimit_priority;
+	list_add(&mem->softlimit_list, &softlimit_head.list[level]);
+}
+
+static void softlimit_del_list_locked(struct mem_cgroup *mem)
+{
+	if (!list_empty(&mem->softlimit_list))
+		list_del_init(&mem->softlimit_list);
+}
+
+static void softlimit_del_list(struct mem_cgroup *mem)
+{
+	down_write(&softlimit_sem);
+	softlimit_del_list_locked(mem);
+	up_write(&softlimit_sem);
+}
+
+
+/*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
  */
@@ -1939,6 +1987,56 @@ static int mem_cgroup_hierarchy_write(st
 	return retval;
 }
 
+static int __memcg_update_softlimit(struct mem_cgroup *mem, void *val)
+{
+	struct mem_cgroup *tmp = mem;
+	struct mem_cgroup *governor = NULL;
+	u64 min_softlimit = ULLONG_MAX;
+	struct cgroup *cg;
+
+	do {
+		if (min_softlimit > tmp->softlimit) {
+			min_softlimit = tmp->softlimit;
+			governor = tmp;
+		}
+
+		cg = tmp->css.cgroup;
+		if (!cg->parent)
+			break;
+		tmp = mem_cgroup_from_cont(cg->parent);
+	} while (tmp->use_hierarchy);
+
+	mem->min_softlimit_governor = governor;
+	return 0;
+}
+
+static int mem_cgroup_resize_softlimit(struct mem_cgroup *memcg,
+				       u64 val)
+{
+
+	down_write(&softlimit_sem);
+	memcg->softlimit = val;
+	/* Updates all children's governor information */
+	mem_cgroup_walk_tree(memcg, NULL, __memcg_update_softlimit);
+	up_write(&softlimit_sem);
+	return 0;
+}
+
+static int mem_cgroup_set_softlimit_prio(struct mem_cgroup *memcg,
+					 int prio)
+{
+	if ((prio < 0) || (prio >= SOFTLIMIT_MAX_PRIO))
+		return -EINVAL;
+
+	down_write(&softlimit_sem);
+	softlimit_del_list_locked(memcg);
+	memcg->softlimit_priority = prio;
+	if (prio)
+		softlimit_add_list_locked(memcg);
+	up_write(&softlimit_sem);
+	return 0;
+}
+
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
@@ -1949,7 +2047,12 @@ static u64 mem_cgroup_read(struct cgroup
 	name = MEMFILE_ATTR(cft->private);
 	switch (type) {
 	case _MEM:
-		val = res_counter_read_u64(&mem->res, name);
+		if (name == MEM_SOFTLIMIT)
+			val = mem->softlimit;
+		else if (name == MEM_SOFTLIMIT_PRIO)
+			val = mem->softlimit_priority;
+		else
+			val = res_counter_read_u64(&mem->res, name);
 		break;
 	case _MEMSWAP:
 		if (do_swap_account)
@@ -1986,6 +2089,12 @@ static int mem_cgroup_write(struct cgrou
 		else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
+	case MEM_SOFTLIMIT:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		ret = mem_cgroup_resize_softlimit(memcg, val);
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -2176,6 +2285,14 @@ static int mem_control_stat_show(struct 
 	return 0;
 }
 
+static int mem_cgroup_write_softlimit_priority(struct cgroup *cgrp,
+					       struct cftype *cft,
+					       u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	return mem_cgroup_set_softlimit_prio(memcg, (int)val);
+}
+
 static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
@@ -2235,6 +2352,18 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "softlimit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, MEM_SOFTLIMIT),
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
+		.name = "softlimit_priority",
+		.private = MEMFILE_PRIVATE(_MEM, MEM_SOFTLIMIT_PRIO),
+		.write_u64 = mem_cgroup_write_softlimit_priority,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
@@ -2438,12 +2567,16 @@ mem_cgroup_create(struct cgroup_subsys *
 	/* root ? */
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
+		init_softlimit();
 		parent = NULL;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
 	}
-
+	INIT_LIST_HEAD(&mem->softlimit_list);
+	mem->softlimit = ULLONG_MAX;
+	/* This mutex is against softlimit */
+	down_write(&softlimit_sem);
 	if (parent && parent->use_hierarchy) {
 		res_counter_init(&mem->res, &parent->res);
 		res_counter_init(&mem->memsw, &parent->memsw);
@@ -2454,10 +2587,16 @@ mem_cgroup_create(struct cgroup_subsys *
 		 * mem_cgroup(see mem_cgroup_put).
 		 */
 		mem_cgroup_get(parent);
+		/* Inherit softlimit governor */
+		mem->min_softlimit_governor = parent->min_softlimit_governor;
+		mem->softlimit_priority = parent->softlimit_priority;
+		softlimit_add_list_locked(mem);
 	} else {
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
 	}
+	up_write(&softlimit_sem);
+
 	mem->last_scanned_child = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
 
@@ -2483,6 +2622,7 @@ static void mem_cgroup_destroy(struct cg
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	softlimit_del_list(mem);
 	mem_cgroup_put(mem);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
