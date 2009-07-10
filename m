Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B1A446B005A
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 08:36:02 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n6AD0R5u010268
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 18:30:27 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6AD0HWh3375226
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 18:30:17 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n6AD0HKJ026379
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 23:00:17 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 10 Jul 2009 18:30:16 +0530
Message-Id: <20090710130016.5610.10636.sendpatchset@balbir-laptop>
In-Reply-To: <20090710125950.5610.99139.sendpatchset@balbir-laptop>
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop>
Subject: [RFC][PATCH 4/5] Memory controller soft limit refactor reclaim flags (v9)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Impact: Refactor mem_cgroup_hierarchical_reclaim()

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch refactors the arguments passed to
mem_cgroup_hierarchical_reclaim() into flags, so that new parameters don't
have to be passed as we make the reclaim routine more flexible

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 219b060..1421576 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -252,6 +252,14 @@ enum charge_type {
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
@@ -1031,11 +1039,14 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
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
 
 	/* If memsw_is_minimum==1, swap-out is of-no-use. */
 	if (root_mem->memsw_is_minimum)
@@ -1173,7 +1184,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 	while (1) {
 		int ret;
-		bool noswap = false;
+		unsigned long flags = 0;
 
 		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
 						&soft_fail_res);
@@ -1186,7 +1197,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				break;
 			/* mem+swap counter fails */
 			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
-			noswap = true;
+			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
 		} else
@@ -1198,7 +1209,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			goto nomem;
 
 		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
-							noswap, false);
+							flags);
 		if (ret)
 			continue;
 
@@ -1993,7 +2004,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			break;
 
 		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
-						   false, true);
+						   MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -2045,7 +2056,9 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
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
