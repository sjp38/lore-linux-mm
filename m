Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ED5CE6B00C2
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 03:40:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n297eS4s029067
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 16:40:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B0C6545DD7F
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:40:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 714AE45DD70
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:40:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EDF9A1DB8021
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:40:26 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6762D1DB801E
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:40:26 +0900 (JST)
Date: Mon, 9 Mar 2009 16:39:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/4] memcg: add softlimit interface and utilitiy
 function.
Message-Id: <20090309163907.a3cee183.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Adds an interface for defining sotlimit per memcg. (no handler in this patch.)
softlimit.priority and queue for softlimit is added in the next patch.


Changelog v1->v2:
 - For refactoring, divided a patch into 2 part and this patch just
   involves memory.softlimit interface.
 - Removed governor-detect routine, it was buggy in design.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 60 insertions(+), 2 deletions(-)

Index: develop/mm/memcontrol.c
===================================================================
--- develop.orig/mm/memcontrol.c
+++ develop/mm/memcontrol.c
@@ -175,7 +175,10 @@ struct mem_cgroup {
 	atomic_t	refcnt;
 
 	unsigned int	swappiness;
-
+	/*
+	 * Softlimit Params.
+	 */
+	u64		softlimit;
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -210,6 +213,8 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
+#define _MEM_SOFTLIMIT		(0x10)
+
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -1900,6 +1905,39 @@ int mem_cgroup_force_empty_write(struct 
 	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
 }
 
+/*
+ * Softlimit Handling.
+ */
+
+/*
+ * A group under hierarchy has to check all ancestors.
+ * css's refcnt of "mem" should be in caller.
+ */
+static bool mem_cgroup_hit_softlimit(struct mem_cgroup *mem, void *data)
+{
+	struct mem_cgroup *tmp = mem;
+	struct cgroup *cg;
+	u64 usage;
+
+	do {
+		usage = res_counter_read_u64(&tmp->res, RES_USAGE);
+		if (tmp->res.usage > tmp->softlimit)
+			return true;
+		cg = tmp->css.cgroup;
+		if (!cg->parent)
+			break;
+		tmp = mem_cgroup_from_cont(cg);
+	} while (!tmp->use_hierarchy);
+
+	return false;
+}
+
+static int mem_cgroup_resize_softlimit(struct mem_cgroup *mem, u64 val)
+{
+	mem->softlimit = val;
+	return 0;
+}
+
 
 static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
 {
@@ -1949,7 +1987,14 @@ static u64 mem_cgroup_read(struct cgroup
 	name = MEMFILE_ATTR(cft->private);
 	switch (type) {
 	case _MEM:
-		val = res_counter_read_u64(&mem->res, name);
+		switch (name) {
+		case _MEM_SOFTLIMIT:
+			val = mem->softlimit;
+			break;
+		default:
+			val = res_counter_read_u64(&mem->res, name);
+			break;
+		}
 		break;
 	case _MEMSWAP:
 		if (do_swap_account)
@@ -1986,6 +2031,12 @@ static int mem_cgroup_write(struct cgrou
 		else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
+	case _MEM_SOFTLIMIT:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		ret = mem_cgroup_resize_softlimit(memcg, val);
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -2235,6 +2286,12 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "softlimit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, _MEM_SOFTLIMIT),
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
@@ -2460,6 +2517,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	}
 	mem->last_scanned_child = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
+	mem->softlimit = ULLONG_MAX;
 
 	if (parent)
 		mem->swappiness = get_swappiness(parent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
