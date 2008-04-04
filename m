From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [-mm] Make the memory controller more desktop responsive (v2)
Date: Fri, 04 Apr 2008 18:51:16 +0530
Message-ID: <20080404132116.5217.14401.sendpatchset@localhost.localdomain>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759444AbYDDNWN@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org



Changelog v1
------------
Move back the retries to 5 (KAMEZAWA)

This patch makes the memory controller more responsive on my desktop.

Here is what the patch does

1. It sets all cached pages as inactive. We were by default marking
   all pages as active, thus forcing us to go through two passes for
   reclaiming pages
2. Removes congestion_wait(), since we already have that logic in
   do_try_to_free_pages()

Comments? Flames?

The patch is against 2.6.25-rc8-mm1

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN mm/memcontrol.c~memory-controller-improve-responsiveness mm/memcontrol.c
--- linux-2.6.25-rc8/mm/memcontrol.c~memory-controller-improve-responsiveness	2008-04-04 18:29:57.000000000 +0530
+++ linux-2.6.25-rc8-balbir/mm/memcontrol.c	2008-04-04 18:30:08.000000000 +0530
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
