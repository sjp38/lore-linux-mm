Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA89AtSM004974
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 04:10:55 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA89AuBV147500
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 04:10:56 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA89AhY5005453
	for <linux-mm@kvack.org>; Sat, 8 Nov 2008 04:10:44 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sat, 08 Nov 2008 14:40:47 +0530
Message-Id: <20081108091047.32236.22994.sendpatchset@localhost.localdomain>
In-Reply-To: <20081108091009.32236.26177.sendpatchset@localhost.localdomain>
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain>
Subject: [RFC][mm] [PATCH 2/4] Memory cgroup resource counters for hierarchy (v2)
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
 mm/memcontrol.c             |    9 ++++++---
 3 files changed, 46 insertions(+), 13 deletions(-)

diff -puN include/linux/res_counter.h~resource-counters-hierarchy-support include/linux/res_counter.h
--- linux-2.6.28-rc2/include/linux/res_counter.h~resource-counters-hierarchy-support	2008-11-08 14:09:31.000000000 +0530
+++ linux-2.6.28-rc2-balbir/include/linux/res_counter.h	2008-11-08 14:09:31.000000000 +0530
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
--- linux-2.6.28-rc2/kernel/res_counter.c~resource-counters-hierarchy-support	2008-11-08 14:09:31.000000000 +0530
+++ linux-2.6.28-rc2-balbir/kernel/res_counter.c	2008-11-08 14:09:31.000000000 +0530
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
--- linux-2.6.28-rc2/mm/memcontrol.c~resource-counters-hierarchy-support	2008-11-08 14:09:31.000000000 +0530
+++ linux-2.6.28-rc2-balbir/mm/memcontrol.c	2008-11-08 14:09:31.000000000 +0530
@@ -485,6 +485,7 @@ int mem_cgroup_try_charge(struct mm_stru
 {
 	struct mem_cgroup *mem;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct res_counter *fail_res;
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -510,7 +511,7 @@ int mem_cgroup_try_charge(struct mm_stru
 	}
 
 
-	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
+	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE, &fail_res))) {
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
@@ -1175,18 +1176,20 @@ static void mem_cgroup_free(struct mem_c
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *parent;
 	int node;
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
+		parent = NULL;
 	} else {
 		mem = mem_cgroup_alloc();
+		parent = mem_cgroup_from_cont(cont->parent);
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
 	}
 
-	res_counter_init(&mem->res);
+	res_counter_init(&mem->res, parent ? &parent->res : NULL);
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
