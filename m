Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2DE45n8013145
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 10:04:05 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DE3nYH117964
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 08:03:55 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DE3mBk028368
	for <linux-mm@kvack.org>; Thu, 13 Mar 2008 08:03:49 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 13 Mar 2008 19:33:07 +0530
Message-Id: <20080313140307.20133.30405.sendpatchset@localhost.localdomain>
Subject: [PATCH] Move memory controller allocations to their own slabs (v3)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Changelog v3

1. Remove HWCACHE_ALIGN

Changelog v2

1. Remove extra slab for mem_cgroup_per_zone

Move the memory controller data structure page_cgroup to its own slab cache.
It saves space on the system, allocations are not necessarily pushed to order
of 2 and should provide performance benefits. Users who disable the memory
controller can also double check that the memory controller is not allocating
page_cgroup's.

NOTE: Hugh Dickins brought up the issue of whether we want to mark page_cgroup
as __GFP_MOVABLE or __GFP_RECLAIMABLE. I don't think there is an easy
answer at the moment. page_cgroup's are associated with user pages,
they can be reclaimed once the user page has been reclaimed, so it might
make sense to mark them as __GFP_RECLAIMABLE. For now, I am leaving the
marking to default values that the slab allocator uses.

Comments?

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff -puN mm/memcontrol.c~memory-controller-move-to-own-slab mm/memcontrol.c
--- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-move-to-own-slab	2008-03-13 17:19:01.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-13 17:19:42.000000000 +0530
@@ -26,6 +26,7 @@
 #include <linux/backing-dev.h>
 #include <linux/bit_spinlock.h>
 #include <linux/rcupdate.h>
+#include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/spinlock.h>
 #include <linux/fs.h>
@@ -35,6 +36,7 @@
 
 struct cgroup_subsys mem_cgroup_subsys;
 static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
+static struct kmem_cache *page_cgroup_cache;
 
 /*
  * Statistics for memory cgroup.
@@ -560,7 +562,7 @@ retry:
 	}
 	unlock_page_cgroup(page);
 
-	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
+	pc = kmem_cache_zalloc(page_cgroup_cache, gfp_mask);
 	if (pc == NULL)
 		goto err;
 
@@ -622,7 +624,7 @@ retry:
 		 */
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
-		kfree(pc);
+		kmem_cache_free(page_cgroup_cache, pc);
 		goto retry;
 	}
 	page_assign_page_cgroup(page, pc);
@@ -637,7 +639,7 @@ done:
 	return 0;
 out:
 	css_put(&mem->css);
-	kfree(pc);
+	kmem_cache_free(page_cgroup_cache, pc);
 err:
 	return -ENOMEM;
 }
@@ -695,7 +697,7 @@ void mem_cgroup_uncharge_page(struct pag
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
 
-		kfree(pc);
+		kmem_cache_free(page_cgroup_cache, pc);
 		return;
 	}
 
@@ -989,6 +991,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		init_mm.mem_cgroup = mem;
+		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
 	} else
 		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
 
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
