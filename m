Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAG8AoAg002063
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 13:40:50 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAG8ApfN3535050
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 13:40:51 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAG8An0m011445
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 13:40:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 16 Nov 2008 13:40:47 +0530
Message-Id: <20081116081047.25166.44602.sendpatchset@balbir-laptop>
In-Reply-To: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
Subject: [mm] [PATCH 2/4] Memory cgroup resource counters for hierarchy (v4)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add support for building hierarchies in resource counters. Cgroups allows us
to build a deep hierarchy, but we currently don't link the resource counters
belonging to the memory controller control groups, in the same fashion
as the corresponding cgroup entries in the cgroup hierarchy. This patch
provides the infrastructure for resource counters that have the same hiearchy
as their cgroup counter parts.

These set of patches are based on the resource counter hiearchy patches posted
by Pavel Emelianov.

NOTE: Building hiearchies is expensive, deeper hierarchies imply charging
the all the way up to the root. It is known that hiearchies are expensive,
so the user needs to be careful and aware of the trade-offs before creating
very deep ones.


Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/res_counter.h |    8 ++++++--
 kernel/res_counter.c        |   42 ++++++++++++++++++++++++++++++++++--------
 mm/memcontrol.c             |   20 +++++++++++++-------
 3 files changed, 53 insertions(+), 17 deletions(-)

diff -puN include/linux/res_counter.h~resource-counters-hierarchy-support include/linux/res_counter.h
--- linux-2.6.28-rc4/include/linux/res_counter.h~resource-counters-hierarchy-support	2008-11-16 13:14:43.000000000 +0530
+++ linux-2.6.28-rc4-balbir/include/linux/res_counter.h	2008-11-16 13:14:43.000000000 +0530
@@ -43,6 +43,10 @@ struct res_counter {
 	 * the routines below consider this to be IRQ-safe
 	 */
 	spinlock_t lock;
+	/*
+	 * Parent counter, used for hierarchial resource accounting
+	 */
+	struct res_counter *parent;
 };
 
 /**
@@ -87,7 +91,7 @@ enum {
  * helpers for accounting
  */
 
-void res_counter_init(struct res_counter *counter);
+void res_counter_init(struct res_counter *counter, struct res_counter *parent);
 
 /*
  * charge - try to consume more resource.
@@ -103,7 +107,7 @@ void res_counter_init(struct res_counter
 int __must_check res_counter_charge_locked(struct res_counter *counter,
 		unsigned long val);
 int __must_check res_counter_charge(struct res_counter *counter,
-		unsigned long val);
+		unsigned long val, struct res_counter **limit_fail_at);
 
 /*
  * uncharge - tell that some portion of the resource is released
diff -puN kernel/res_counter.c~resource-counters-hierarchy-support kernel/res_counter.c
--- linux-2.6.28-rc4/kernel/res_counter.c~resource-counters-hierarchy-support	2008-11-16 13:14:43.000000000 +0530
+++ linux-2.6.28-rc4-balbir/kernel/res_counter.c	2008-11-16 13:14:43.000000000 +0530
@@ -15,10 +15,11 @@
 #include <linux/uaccess.h>
 #include <linux/mm.h>
 
-void res_counter_init(struct res_counter *counter)
+void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = (unsigned long long)LLONG_MAX;
+	counter->parent = parent;
 }
 
 int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
@@ -34,14 +35,34 @@ int res_counter_charge_locked(struct res
 	return 0;
 }
 
-int res_counter_charge(struct res_counter *counter, unsigned long val)
+int res_counter_charge(struct res_counter *counter, unsigned long val,
+			struct res_counter **limit_fail_at)
 {
 	int ret;
 	unsigned long flags;
+	struct res_counter *c, *u;
 
-	spin_lock_irqsave(&counter->lock, flags);
-	ret = res_counter_charge_locked(counter, val);
-	spin_unlock_irqrestore(&counter->lock, flags);
+	*limit_fail_at = NULL;
+	local_irq_save(flags);
+	for (c = counter; c != NULL; c = c->parent) {
+		spin_lock(&c->lock);
+		ret = res_counter_charge_locked(c, val);
+		spin_unlock(&c->lock);
+		if (ret < 0) {
+			*limit_fail_at = c;
+			goto undo;
+		}
+	}
+	ret = 0;
+	goto done;
+undo:
+	for (u = counter; u != c; u = u->parent) {
+		spin_lock(&u->lock);
+		res_counter_uncharge_locked(u, val);
+		spin_unlock(&u->lock);
+	}
+done:
+	local_irq_restore(flags);
 	return ret;
 }
 
@@ -56,10 +77,15 @@ void res_counter_uncharge_locked(struct 
 void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 {
 	unsigned long flags;
+	struct res_counter *c;
 
-	spin_lock_irqsave(&counter->lock, flags);
-	res_counter_uncharge_locked(counter, val);
-	spin_unlock_irqrestore(&counter->lock, flags);
+	local_irq_save(flags);
+	for (c = counter; c != NULL; c = c->parent) {
+		spin_lock(&c->lock);
+		res_counter_uncharge_locked(c, val);
+		spin_unlock(&c->lock);
+	}
+	local_irq_restore(flags);
 }
 
 
diff -puN mm/memcontrol.c~resource-counters-hierarchy-support mm/memcontrol.c
--- linux-2.6.28-rc4/mm/memcontrol.c~resource-counters-hierarchy-support	2008-11-16 13:14:43.000000000 +0530
+++ linux-2.6.28-rc4-balbir/mm/memcontrol.c	2008-11-16 13:14:43.000000000 +0530
@@ -470,6 +470,7 @@ static int __mem_cgroup_try_charge(struc
 {
 	struct mem_cgroup *mem;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct res_counter *fail_res;
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -498,11 +499,12 @@ static int __mem_cgroup_try_charge(struc
 		int ret;
 		bool noswap = false;
 
-		ret = res_counter_charge(&mem->res, PAGE_SIZE);
+		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
 		if (likely(!ret)) {
 			if (!do_swap_account)
 				break;
-			ret = res_counter_charge(&mem->memsw, PAGE_SIZE);
+			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
+							&fail_res);
 			if (likely(!ret))
 				break;
 			/* mem+swap counter fails */
@@ -1687,22 +1689,26 @@ static void __init enable_swap_cgroup(vo
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *parent;
 	int node;
 
 	mem = mem_cgroup_alloc();
 	if (!mem)
 		return ERR_PTR(-ENOMEM);
 
-	res_counter_init(&mem->res);
-	res_counter_init(&mem->memsw);
-
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
 	/* root ? */
-	if (cont->parent == NULL)
+	if (cont->parent == NULL) {
 		enable_swap_cgroup();
+		parent = NULL;
+	} else
+		parent = mem_cgroup_from_cont(cont->parent);
+
+ 	res_counter_init(&mem->res, parent ? &parent->res : NULL);
+	res_counter_init(&mem->memsw, parent ? &parent->memsw : NULL);
+
 
 	return &mem->css;
 free_out:
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
