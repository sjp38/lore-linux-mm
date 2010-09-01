Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 952D36B007E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 02:48:07 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o816m4vg022358
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Sep 2010 15:48:04 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 135D045DE79
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:48:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DEE3B45DE6F
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:48:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A13FE1DB803F
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:48:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D5302E38003
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 15:48:02 +0900 (JST)
Date: Wed, 1 Sep 2010 15:42:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/5] memcg: more use of css ID in memcg.
Message-Id: <20100901154259.5b17bb87.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, gthelen@google.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, menage@google.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, memory cgroup has an ID per cgroup and make use of it at
 - hierarchy walk,
 - swap recording.

This patch is for making more use of it. The final purpose is
to replace page_cgroup->mem_cgroup's pointer to an unsigned short.

This patch caches a pointer of memcg in an array. By this, we
don't have to call css_lookup() which requires radix-hash walk.
This saves some amount of memory footprint at lookup memcg via id.

Changelog: 20100901
 - added unregster_memcg_id() and did some clean up.
 - removed ->valid.
 - fixed mem_cgroup_num counter handling.

Changelog: 20100825
 - applied comments.

Changelog: 20100811
 - adjusted onto mmotm-2010-08-11
 - fixed RCU related parts.
 - use attach_id() callback.

Changelog: 20100804
 - fixed description in init/Kconfig

Changelog: 20100730
 - fixed rcu_read_unlock() placement.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 init/Kconfig    |   10 +++++++
 mm/memcontrol.c |   71 ++++++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 61 insertions(+), 20 deletions(-)

Index: mmotm-0827/mm/memcontrol.c
===================================================================
--- mmotm-0827.orig/mm/memcontrol.c
+++ mmotm-0827/mm/memcontrol.c
@@ -294,6 +294,33 @@ static bool move_file(void)
 					&mc.to->move_charge_at_immigrate);
 }
 
+/* 0 is unused */
+static atomic_t mem_cgroup_num;
+#define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
+static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
+
+/* Must be called under rcu_read_lock */
+static struct mem_cgroup *id_to_memcg(unsigned short id)
+{
+	struct mem_cgroup *mem;
+	mem = rcu_dereference_check(mem_cgroups[id], rcu_read_lock_held());
+	return mem;
+}
+
+static void register_memcg_id(struct mem_cgroup *mem)
+{
+	int id = css_id(&mem->css);
+	rcu_assign_pointer(mem_cgroups[id], mem);
+}
+
+static void unregister_memcg_id(struct mem_cgroup *mem)
+{
+	int id = css_id(&mem->css);
+	rcu_assign_pointer(mem_cgroups[id], NULL);
+	/* Wait until all references goes. */
+	synchronize_rcu();
+}
+
 /*
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
  * limit reclaim to prevent infinite loops, if they ever occur.
@@ -1847,18 +1874,7 @@ static void mem_cgroup_cancel_charge(str
  * it's concern. (dropping refcnt from swap can be called against removed
  * memcg.)
  */
-static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
-{
-	struct cgroup_subsys_state *css;
 
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
@@ -1879,7 +1895,7 @@ struct mem_cgroup *try_get_mem_cgroup_fr
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup(ent);
 		rcu_read_lock();
-		mem = mem_cgroup_lookup(id);
+		mem = id_to_memcg(id);
 		if (mem && !css_tryget(&mem->css))
 			mem = NULL;
 		rcu_read_unlock();
@@ -2231,7 +2247,7 @@ __mem_cgroup_commit_charge_swapin(struct
 
 		id = swap_cgroup_record(ent, 0);
 		rcu_read_lock();
-		memcg = mem_cgroup_lookup(id);
+		memcg = id_to_memcg(id);
 		if (memcg) {
 			/*
 			 * This recorded memcg can be obsolete one. So, avoid
@@ -2240,9 +2256,10 @@ __mem_cgroup_commit_charge_swapin(struct
 			if (!mem_cgroup_is_root(memcg))
 				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 			mem_cgroup_swap_statistics(memcg, false);
+			rcu_read_unlock();
 			mem_cgroup_put(memcg);
-		}
-		rcu_read_unlock();
+		} else
+			rcu_read_unlock();
 	}
 	/*
 	 * At swapin, we may charge account against cgroup which has no tasks.
@@ -2495,7 +2512,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 
 	id = swap_cgroup_record(ent, 0);
 	rcu_read_lock();
-	memcg = mem_cgroup_lookup(id);
+	memcg = id_to_memcg(id);
 	if (memcg) {
 		/*
 		 * We uncharge this because swap is freed.
@@ -2504,9 +2521,10 @@ void mem_cgroup_uncharge_swap(swp_entry_
 		if (!mem_cgroup_is_root(memcg))
 			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 		mem_cgroup_swap_statistics(memcg, false);
+		rcu_read_unlock();
 		mem_cgroup_put(memcg);
-	}
-	rcu_read_unlock();
+	} else
+		rcu_read_unlock();
 }
 
 /**
@@ -4010,6 +4028,9 @@ static struct mem_cgroup *mem_cgroup_all
 	struct mem_cgroup *mem;
 	int size = sizeof(struct mem_cgroup);
 
+	if (atomic_read(&mem_cgroup_num) == NR_MEMCG_GROUPS)
+		return NULL;
+
 	/* Can be very big if MAX_NUMNODES is very big */
 	if (size < PAGE_SIZE)
 		mem = kmalloc(size, GFP_KERNEL);
@@ -4028,6 +4049,8 @@ static struct mem_cgroup *mem_cgroup_all
 			vfree(mem);
 		mem = NULL;
 	}
+	if (mem)
+		atomic_inc(&mem_cgroup_num);
 	return mem;
 }
 
@@ -4049,6 +4072,7 @@ static void __mem_cgroup_free(struct mem
 	mem_cgroup_remove_from_trees(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
+	atomic_dec(&mem_cgroup_num);
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
@@ -4059,6 +4083,12 @@ static void __mem_cgroup_free(struct mem
 		vfree(mem);
 }
 
+static void mem_cgroup_free(struct mem_cgroup *mem)
+{
+	unregister_memcg_id(mem);
+	__mem_cgroup_free(mem);
+}
+
 static void mem_cgroup_get(struct mem_cgroup *mem)
 {
 	atomic_inc(&mem->refcnt);
@@ -4068,7 +4098,7 @@ static void __mem_cgroup_put(struct mem_
 {
 	if (atomic_sub_and_test(count, &mem->refcnt)) {
 		struct mem_cgroup *parent = parent_mem_cgroup(mem);
-		__mem_cgroup_free(mem);
+		mem_cgroup_free(mem);
 		if (parent)
 			mem_cgroup_put(parent);
 	}
@@ -4189,9 +4219,10 @@ mem_cgroup_create(struct cgroup_subsys *
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
+	register_memcg_id(mem);
 	return &mem->css;
 free_out:
-	__mem_cgroup_free(mem);
+	mem_cgroup_free(mem);
 	root_mem_cgroup = NULL;
 	return ERR_PTR(error);
 }
Index: mmotm-0827/init/Kconfig
===================================================================
--- mmotm-0827.orig/init/Kconfig
+++ mmotm-0827/init/Kconfig
@@ -612,6 +612,16 @@ config CGROUP_MEM_RES_CTLR_SWAP
 	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
 	  size is 4096bytes, 512k per 1Gbytes of swap.
 
+config MEM_CGROUP_MAX_GROUPS
+	int "Maximum number of memory cgroups on a system"
+	range 1 65535
+	default 8192 if 64BIT
+	default 2048 if 32BIT
+	help
+	  Memory cgroup has limitation of the number of groups created.
+	  Please select your favorite value. The more you allow, the more
+	  memory(a pointer per group) will be consumed.
+
 menuconfig CGROUP_SCHED
 	bool "Group CPU scheduler"
 	depends on EXPERIMENTAL && CGROUPS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
