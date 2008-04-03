From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [-mm] Make the memory controller more desktop responsive
Date: Thu, 03 Apr 2008 15:02:53 +0530
Message-ID: <20080403093253.8944.10168.sendpatchset@localhost.localdomain>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759593AbYDCJdf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org



This patch makes the memory controller more responsive on my desktop.

Here is what the patch does

1. Reduces the number of retries to 2. We had 5 earlier, since we
   were controlling swap cache as well. We pushed data from mappings
   to swap cache and we needed additional passes to clear out the cache.
2. It sets all cached pages as inactive. We were by default marking
   all pages as active, thus forcing us to go through two passes for
   reclaiming pages
3. Removes congestion_wait(), since we already have that logic in
   do_try_to_free_pages()

Comments? Flames?

The patch is against 2.6.25-rc8-mm1

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff -puN mm/memcontrol.c~memory-controller-improve-responsiveness mm/memcontrol.c
--- linux-2.6.25-rc8/mm/memcontrol.c~memory-controller-improve-responsiveness	2008-04-03 13:07:17.000000000 +0530
+++ linux-2.6.25-rc8-balbir/mm/memcontrol.c	2008-04-03 14:02:27.000000000 +0530
@@ -35,7 +35,7 @@
 #include <asm/uaccess.h>
 
 struct cgroup_subsys mem_cgroup_subsys;
-static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
+static const int MEM_CGROUP_RECLAIM_RETRIES = 2;
 static struct kmem_cache *page_cgroup_cache;
 
 /*
@@ -604,7 +604,6 @@ retry:
 			mem_cgroup_out_of_memory(mem, gfp_mask);
 			goto out;
 		}
-		congestion_wait(WRITE, HZ/10);
 	}
 
 	pc->ref_cnt = 1;
@@ -612,7 +611,7 @@ retry:
 	pc->page = page;
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
-		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+		pc->flags = PAGE_CGROUP_FLAG_CACHE;
 
 	lock_page_cgroup(page);
 	if (page_get_page_cgroup(page)) {
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
