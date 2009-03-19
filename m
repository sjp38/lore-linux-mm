Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 05D676B005A
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 12:58:01 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2JGu1oY005778
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 03:56:01 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2JGwFr5978970
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 03:58:15 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2JGvvsO002801
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 03:57:57 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 19 Mar 2009 22:27:44 +0530
Message-Id: <20090319165744.27274.6335.sendpatchset@localhost.localdomain>
In-Reply-To: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/5] Memory controller soft limit refactor reclaim flags (v7)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Impact: Refactor mem_cgroup_hierarchical_reclaim()

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch refactors the arguments passed to
mem_cgroup_hierarchical_reclaim() into flags, so that new parameters don't
have to be passed as we make the reclaim routine more flexible


Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f5b61b8..992aac8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -227,6 +227,14 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 
+/*
+ * Reclaim flags for mem_cgroup_hierarchical_reclaim
+ */
+#define MEM_CGROUP_RECLAIM_NOSWAP_BIT	0x0
+#define MEM_CGROUP_RECLAIM_NOSWAP	(1 << MEM_CGROUP_RECLAIM_NOSWAP_BIT)
+#define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
+#define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
+
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -889,11 +897,14 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
  * If shrink==true, for avoiding to free too much, this returns immedieately.
  */
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
-				   gfp_t gfp_mask, bool noswap, bool shrink)
+						gfp_t gfp_mask,
+						unsigned long reclaim_options)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
 	int loop = 0;
+	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
+	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 
 	while (loop < 2) {
 		victim = mem_cgroup_select_victim(root_mem);
@@ -1029,7 +1040,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 	while (1) {
 		int ret;
-		bool noswap = false;
+		unsigned long flags = 0;
 
 		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
 						&soft_fail_res);
@@ -1042,7 +1053,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				break;
 			/* mem+swap counter fails */
 			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
-			noswap = true;
+			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
 		} else
@@ -1054,7 +1065,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			goto nomem;
 
 		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
-							noswap, false);
+							flags);
 		if (ret)
 			continue;
 
@@ -1766,7 +1777,7 @@ int mem_cgroup_shrink_usage(struct page *page,
 
 	do {
 		progress = mem_cgroup_hierarchical_reclaim(mem,
-					gfp_mask, true, false);
+					gfp_mask, MEM_CGROUP_RECLAIM_NOSWAP);
 		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
 
@@ -1821,7 +1832,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			break;
 
 		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
-						   false, true);
+						   MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -1869,7 +1880,9 @@ int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		if (!ret)
 			break;
 
-		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL, true, true);
+		mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
+						MEM_CGROUP_RECLAIM_NOSWAP |
+						MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
