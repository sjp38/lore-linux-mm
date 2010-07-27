Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3267E600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:00:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R80LDU027061
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Jul 2010 17:00:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8893545DE55
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:00:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6447C45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:00:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CF84E38002
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:00:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 010BBEF8001
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:00:21 +0900 (JST)
Date: Tue, 27 Jul 2010 16:55:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/7][memcg] memcg on virt array for quick access via
 ID.
Message-Id: <20100727165532.24a07473.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, memory cgroup has an ID(1-65535) per a group and use it for
walking hierarchy, recording it for swapped-out resources etc...

This patch tries to make use of it more. Allocating memory cgroup
into an (virtual) array. This allows to access a memory cgroup by
  mem = mem_cgroup_base + id.

By this, we don't have to use css_lookup() and will have a chance to
replace a pointer to mem_cgroup(8bytes on 64bit) to an ID (2bytes).

Thought:
 - Although I added CONFIG in this patch, I wonder I should remove it..

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 init/Kconfig    |   14 +++++++-
 mm/memcontrol.c |   93 ++++++++++++++++++++++++++++++--------------------------
 2 files changed, 63 insertions(+), 44 deletions(-)

Index: mmotm-0719/init/Kconfig
===================================================================
--- mmotm-0719.orig/init/Kconfig
+++ mmotm-0719/init/Kconfig
@@ -555,7 +555,7 @@ config RESOURCE_COUNTERS
 
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
-	depends on CGROUPS && RESOURCE_COUNTERS
+	depends on CGROUPS && RESOURCE_COUNTERS && MMU
 	select MM_OWNER
 	help
 	  Provides a memory resource controller that manages both anonymous
@@ -594,6 +594,18 @@ config CGROUP_MEM_RES_CTLR_SWAP
 	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
 	  size is 4096bytes, 512k per 1Gbytes of swap.
 
+config MEM_CGROUP_MAX_GROUPS
+	int "Maximum number of memory cgroups on a system"
+	range 1 65535 if 64BIT
+	default 8192 if 64BIT
+	range 1 4096 if 32BIT
+	default 2048 if 32BIT
+	help
+	  Memory cgroup has limitation of the number of groups created.
+	  Please select your favorite value. The more you allow, the more
+	  memory will be consumed. This consumes vmalloc() area, so,
+	  this should be small on 32bit arch.
+
 menuconfig CGROUP_SCHED
 	bool "Group CPU scheduler"
 	depends on EXPERIMENTAL && CGROUPS
Index: mmotm-0719/mm/memcontrol.c
===================================================================
--- mmotm-0719.orig/mm/memcontrol.c
+++ mmotm-0719/mm/memcontrol.c
@@ -48,6 +48,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/virt-array.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -242,7 +243,8 @@ struct mem_cgroup {
 
 	/* For oom notifier event fd */
 	struct list_head oom_notify;
-
+	/* Used when varray is used */
+	int custom_id;
 	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
@@ -254,6 +256,8 @@ struct mem_cgroup {
 	struct mem_cgroup_stat_cpu *stat;
 };
 
+static struct mem_cgroup *mem_cgroup_base __read_mostly;
+
 /* Stuffs for move charges at task migration. */
 /*
  * Types of charges to be moved. "move_charge_at_immitgrate" is treated as a
@@ -341,6 +345,19 @@ static void mem_cgroup_put(struct mem_cg
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
 
+/*
+ * A helper function to get mem_cgroup from ID. must be called under
+ * rcu_read_lock(). The caller must check css_is_removed() or some if
+ * it's concern. (dropping refcnt from swap can be called against removed
+ * memcg.)
+ */
+static struct mem_cgroup *id_to_mem(unsigned short id)
+{
+	if (id)
+		return mem_cgroup_base + id;
+	return NULL;
+}
+
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
@@ -1818,24 +1835,6 @@ static void mem_cgroup_cancel_charge(str
 	__mem_cgroup_cancel_charge(mem, 1);
 }
 
-/*
- * A helper function to get mem_cgroup from ID. must be called under
- * rcu_read_lock(). The caller must check css_is_removed() or some if
- * it's concern. (dropping refcnt from swap can be called against removed
- * memcg.)
- */
-static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
-{
-	struct cgroup_subsys_state *css;
-
-	/* ID 0 is unused ID */
-	if (!id)
-		return NULL;
-	css = css_lookup(&mem_cgroup_subsys, id);
-	if (!css)
-		return NULL;
-	return container_of(css, struct mem_cgroup, css);
-}
 
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
@@ -1856,7 +1855,7 @@ struct mem_cgroup *try_get_mem_cgroup_fr
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup(ent);
 		rcu_read_lock();
-		mem = mem_cgroup_lookup(id);
+		mem = id_to_mem(id);
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
 		rcu_read_unlock();
@@ -2208,7 +2207,7 @@ __mem_cgroup_commit_charge_swapin(struct
 
 		id = swap_cgroup_record(ent, 0);
 		rcu_read_lock();
-		memcg = mem_cgroup_lookup(id);
+		memcg = id_to_mem(id);
 		if (memcg) {
 			/*
 			 * This recorded memcg can be obsolete one. So, avoid
@@ -2472,7 +2471,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 
 	id = swap_cgroup_record(ent, 0);
 	rcu_read_lock();
-	memcg = mem_cgroup_lookup(id);
+	memcg = id_to_mem(id);
 	if (memcg) {
 		/*
 		 * We uncharge this because swap is freed.
@@ -3983,32 +3982,42 @@ static void free_mem_cgroup_per_zone_inf
 	kfree(mem->info.nodeinfo[node]);
 }
 
-static struct mem_cgroup *mem_cgroup_alloc(void)
+struct virt_array memcg_varray;
+
+static int mem_cgroup_custom_id(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem;
-	int size = sizeof(struct mem_cgroup);
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	return mem->custom_id;
+}
 
-	/* Can be very big if MAX_NUMNODES is very big */
-	if (size < PAGE_SIZE)
-		mem = kmalloc(size, GFP_KERNEL);
-	else
-		mem = vmalloc(size);
+static struct mem_cgroup *mem_cgroup_alloc(struct cgroup *cgroup)
+{
+	struct mem_cgroup *mem;
+	int idx;
 
-	if (!mem)
+	if (cgroup->parent == NULL) {
+		mem_cgroup_base = create_varray(&memcg_varray, sizeof(*mem),
+			CONFIG_MEM_CGROUP_MAX_GROUPS);
+		BUG_ON(IS_ERR_OR_NULL(mem_cgroup_base));
+	}
+	/* 0 is unused ID.(see css_id's spec). */
+	idx = varray_find_free_index(&memcg_varray, 1);
+	if (idx == memcg_varray.nelem)
 		return NULL;
-
-	memset(mem, 0, size);
+	mem = alloc_varray_item(&memcg_varray, idx);
+	if (IS_ERR_OR_NULL(mem))
+		return NULL;
+	memset(mem, 0, sizeof(*mem));
 	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!mem->stat) {
-		if (size < PAGE_SIZE)
-			kfree(mem);
-		else
-			vfree(mem);
+		free_varray_item(&memcg_varray, idx);
 		mem = NULL;
-	}
+	} else
+		mem->custom_id = idx;
 	return mem;
 }
 
+
 /*
  * At destroying mem_cgroup, references from swap_cgroup can remain.
  * (scanning all at force_empty is too costly...)
@@ -4031,10 +4040,7 @@ static void __mem_cgroup_free(struct mem
 		free_mem_cgroup_per_zone_info(mem, node);
 
 	free_percpu(mem->stat);
-	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
-		kfree(mem);
-	else
-		vfree(mem);
+	free_varray_item(&memcg_varray, mem->custom_id);
 }
 
 static void mem_cgroup_get(struct mem_cgroup *mem)
@@ -4111,7 +4117,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	long error = -ENOMEM;
 	int node;
 
-	mem = mem_cgroup_alloc();
+	mem = mem_cgroup_alloc(cont);
 	if (!mem)
 		return ERR_PTR(error);
 
@@ -4692,6 +4698,7 @@ struct cgroup_subsys mem_cgroup_subsys =
 	.can_attach = mem_cgroup_can_attach,
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
+	.custom_id = mem_cgroup_custom_id,
 	.early_init = 0,
 	.use_id = 1,
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
