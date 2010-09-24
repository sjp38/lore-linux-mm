Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 278216B004A
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 05:21:00 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8O9Kwb0010486
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 24 Sep 2010 18:20:58 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1386A45DE70
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:20:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DA4D345DE60
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:20:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B1BBC1DB8046
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:20:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DA991DB803E
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 18:20:57 +0900 (JST)
Date: Fri, 24 Sep 2010 18:15:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/2] memcg: special ID lookup routine
Message-Id: <20100924181550.d1757901.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100924181302.7d764e0d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

It seems previous patches are not welcomed, this is a revised one.
My purpose is to replace pc->mem_cgroup to be pc->mem_cgroup_id and to prevent
using more memory when pc->blkio_cgroup_id is added.

As 1st step, this patch implements a lookup table from ID.
For usual lookup, css_lookup() will work enough well but it may have to
access several level of idr radix-tree. Memory cgroup's limit is 65536 and
as far as I here, there are a user who uses 2000+ memory cgroup on a system.
And with generic rcu based lookup routine, the caller has to

Type A:
	rcu_read_lock()
	obj = obj_lookup()
	atomic_inc(obj->refcnt)
	rcu_read_unlock()
	/* do jobs */
Type B:
	rcu_read_lock()
	obj = rcu_lookup()
	/* do jobs */
	rcu_read_unlock()

Under some spinlock in many case.
(Type A is very bad in busy routine and even type B has to check the
 object is alive or not. It's not no cost)
This is complicated.

Because page_cgroup -> mem_cgroup information is required at every LRU
operatons, I think it's worth to add a special lookup routine for reducing
cache footprint and, with some limitaton, lookup routine can be RCU free.

Note:
 - memcg_lookup() is defined but not used. it's called in other patch.

Changelog:
 - no hooks to cgroup.
 - no limitation of the number of memcg.
 - delay table allocation until memory cgroup is really used.
 - No RCU routine. (depends on the limitation to callers newly added.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

Index: mmotm-0922/mm/memcontrol.c
===================================================================
--- mmotm-0922.orig/mm/memcontrol.c
+++ mmotm-0922/mm/memcontrol.c
@@ -198,6 +198,7 @@ static void mem_cgroup_oom_notify(struct
  */
 struct mem_cgroup {
 	struct cgroup_subsys_state css;
+	bool	cached;
 	/*
 	 * the counter to account for memory usage
 	 */
@@ -352,6 +353,65 @@ static void mem_cgroup_put(struct mem_cg
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
 
+#define MEMCG_ARRAY_SIZE	(sizeof(struct mem_cgroup *) *(65536))
+struct mem_cgroup **memcg_array __read_mostly;
+DEFINE_SPINLOCK(memcg_array_lock);
+
+/*
+ * A quick lookup routine for memory cgroup via ID. This can be used
+ * until destroy() is called against memory cgroup. Then, in most case,
+ * there must be page_cgroups or tasks which points to memcg.
+ * So, cannot be used for swap_cgroup reference.
+ */
+static struct mem_cgroup *memcg_lookup(int id)
+{
+	if (id == 0)
+		return NULL;
+	if (id == 1)
+		return root_mem_cgroup;
+	return *(memcg_array + id);
+}
+
+static void memcg_lookup_set(struct mem_cgroup *mem)
+{
+	int id;
+
+	if (likely(mem->cached) || mem == root_mem_cgroup)
+		return;
+	id = css_id(&mem->css);
+	/* There are race with other "set" entry. need to avoid double refcnt */
+	spin_lock(&memcg_array_lock);
+	if (!(*(memcg_array + id))) {
+		mem_cgroup_get(mem);
+		*(memcg_array + id) = mem;
+		mem->cached = true;
+	}
+	spin_unlock(&memcg_array_lock);
+}
+
+static void memcg_lookup_clear(struct mem_cgroup *mem)
+{
+	int id = css_id(&mem->css);
+	/* No race with other look up/set/unset entry */
+	*(memcg_array + id) = NULL;
+	mem_cgroup_put(mem);
+}
+
+static int init_mem_cgroup_lookup_array(void)
+{
+	int size;
+
+	if (memcg_array)
+		return 0;
+
+	size = MEMCG_ARRAY_SIZE;
+	memcg_array = __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
+				PAGE_KERNEL);
+	if (!memcg_array)
+		return -ENOMEM;
+
+	return 0;
+}
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -2096,6 +2156,7 @@ static void __mem_cgroup_commit_charge(s
 		mem_cgroup_cancel_charge(mem);
 		return;
 	}
+	memcg_lookup_set(mem);
 
 	pc->mem_cgroup = mem;
 	/*
@@ -4341,6 +4402,10 @@ mem_cgroup_create(struct cgroup_subsys *
 		}
 		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
 	} else {
+		/* Allocation of lookup array is delayd until creat cgroup */
+		error = init_mem_cgroup_lookup_array();
+		if (error == -ENOMEM)
+			goto free_out;
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
 		mem->oom_kill_disable = parent->oom_kill_disable;
@@ -4389,6 +4454,8 @@ static void mem_cgroup_destroy(struct cg
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	memcg_lookup_clear(mem);
+
 	mem_cgroup_put(mem);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
