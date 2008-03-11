Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2B4V1NT018753
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 00:31:01 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2B4VwM6205066
	for <linux-mm@kvack.org>; Mon, 10 Mar 2008 22:31:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2B4VvgM004444
	for <linux-mm@kvack.org>; Mon, 10 Mar 2008 22:31:58 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 11 Mar 2008 10:01:49 +0530
Message-Id: <20080311043149.20251.50059.sendpatchset@localhost.localdomain>
Subject: [PATCH] Move memory controller allocations to their own slabs
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Move the memory controller data structures page_cgroup and
mem_cgroup_per_zone to their own slab caches. It saves space on the system,
allocations are not necessarily pushed to order of 2 and should provide
performance benefits. Users who disable the memory controller can also double
check that the memory controller is not allocating page_cgroup's.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 linux/memcontrol.h |    0 
 mm/memcontrol.c    |   21 ++++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff -puN mm/memcontrol.c~memory-controller-move-to-own-slab mm/memcontrol.c
--- linux-2.6.25-rc4/mm/memcontrol.c~memory-controller-move-to-own-slab	2008-03-10 23:22:34.000000000 +0530
+++ linux-2.6.25-rc4-balbir/mm/memcontrol.c	2008-03-10 23:34:42.000000000 +0530
@@ -26,6 +26,7 @@
 #include <linux/backing-dev.h>
 #include <linux/bit_spinlock.h>
 #include <linux/rcupdate.h>
+#include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/spinlock.h>
 #include <linux/fs.h>
@@ -35,6 +36,8 @@
 
 struct cgroup_subsys mem_cgroup_subsys;
 static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
+static struct kmem_cache *page_cgroup_cache;
+static struct kmem_cache *mem_cgroup_per_zone_cache;
 
 /*
  * Statistics for memory cgroup.
@@ -560,7 +563,7 @@ retry:
 	}
 	unlock_page_cgroup(page);
 
-	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
+	pc = kmem_cache_zalloc(page_cgroup_cache, gfp_mask);
 	if (pc == NULL)
 		goto err;
 
@@ -622,7 +625,7 @@ retry:
 		 */
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
-		kfree(pc);
+		kmem_cache_free(page_cgroup_cache, pc);
 		goto retry;
 	}
 	page_assign_page_cgroup(page, pc);
@@ -637,7 +640,7 @@ done:
 	return 0;
 out:
 	css_put(&mem->css);
-	kfree(pc);
+	kmem_cache_free(page_cgroup_cache, pc);
 err:
 	return -ENOMEM;
 }
@@ -695,7 +698,7 @@ void mem_cgroup_uncharge_page(struct pag
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
 
-		kfree(pc);
+		kmem_cache_free(page_cgroup_cache, pc);
 		return;
 	}
 
@@ -988,9 +991,10 @@ static int alloc_mem_cgroup_per_zone_inf
 	 *       function.
 	 */
 	if (node_state(node, N_HIGH_MEMORY))
-		pn = kmalloc_node(sizeof(*pn), GFP_KERNEL, node);
+		pn = kmem_cache_alloc_node(mem_cgroup_per_zone_cache,
+						GFP_KERNEL, node);
 	else
-		pn = kmalloc(sizeof(*pn), GFP_KERNEL);
+		pn = kmem_cache_alloc(mem_cgroup_per_zone_cache, GFP_KERNEL);
 	if (!pn)
 		return 1;
 
@@ -1008,7 +1012,7 @@ static int alloc_mem_cgroup_per_zone_inf
 
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 {
-	kfree(mem->info.nodeinfo[node]);
+	kmem_cache_free(mem_cgroup_per_zone_cache, mem->info.nodeinfo[node]);
 }
 
 static struct cgroup_subsys_state *
@@ -1020,6 +1024,9 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		init_mm.mem_cgroup = mem;
+		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
+		mem_cgroup_per_zone_cache = KMEM_CACHE(mem_cgroup_per_zone,
+							SLAB_PANIC);
 	} else
 		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
 
diff -puN include/linux/memcontrol.h~memory-controller-move-to-own-slab include/linux/memcontrol.h
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
