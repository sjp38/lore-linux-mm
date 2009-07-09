Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 95C686B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:57:11 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n69GP1O7026449
	for <linux-mm@kvack.org>; Thu, 9 Jul 2009 21:55:01 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69HF86U2638040
	for <linux-mm@kvack.org>; Thu, 9 Jul 2009 22:45:08 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n69HF7l9007544
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:15:07 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 09 Jul 2009 22:45:07 +0530
Message-Id: <20090709171507.8080.62086.sendpatchset@balbir-laptop>
In-Reply-To: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
Subject: [RFC][PATCH 4/5] Memory controller soft limit refactor reclaim flags (v8)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
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
index 13a7696..ca9c257 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -240,6 +240,14 @@ enum charge_type {
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
@@ -1030,11 +1038,14 @@ mem_cgroup_select_victim(struct mem_cgroup *root_mem)
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
@@ -1172,7 +1183,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 
 	while (1) {
 		int ret;
-		bool noswap = false;
+		unsigned long flags = 0;
 
 		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
 						&soft_fail_res);
@@ -1185,7 +1196,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 				break;
 			/* mem+swap counter fails */
 			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
-			noswap = true;
+			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									memsw);
 		} else
@@ -1197,7 +1208,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 			goto nomem;
 
 		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
-							noswap, false);
+							flags);
 		if (ret)
 			continue;
 
@@ -1992,7 +2003,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			break;
 
 		progress = mem_cgroup_hierarchical_reclaim(memcg, GFP_KERNEL,
-						   false, true);
+						   MEM_CGROUP_RECLAIM_SHRINK);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -2044,7 +2055,9 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
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
