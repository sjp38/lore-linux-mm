Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2B6Iqr4002794
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 02:18:52 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2B6Ipfu198976
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 02:18:51 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2B6Ipk3018455
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 02:18:51 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 11 Mar 2008 11:48:36 +0530
Message-Id: <20080311061836.6664.5072.sendpatchset@localhost.localdomain>
Subject: [PATCH] Move memory controller allocations to their own slabs (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Move the memory controller data structure page_cgroup to its own slab cache.
It saves space on the system, allocations are not necessarily pushed to order
of 2 and should provide performance benefits. Users who disable the memory
controller can also double check that the memory controller is not allocating
page_cgroup's.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff -puN mm/memcontrol.c~memory-controller-move-to-own-slab mm/memcontrol.c
--- linux-2.6.25-rc4/mm/memcontrol.c~memory-controller-move-to-own-slab	2008-03-10 23:22:34.000000000 +0530
+++ linux-2.6.25-rc4-balbir/mm/memcontrol.c	2008-03-11 10:29:00.000000000 +0530
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
 
@@ -1020,6 +1022,8 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		init_mm.mem_cgroup = mem;
+		page_cgroup_cache = KMEM_CACHE(page_cgroup,
+					SLAB_HWCACHE_ALIGN | SLAB_PANIC);
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
