Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 22E1D6B0101
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 07:30:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B4D7F3EE0AE
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:30:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AB9345DEB4
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:30:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8087F45DEB2
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:30:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DF131DB803C
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:30:37 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E98DFE08006
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:30:36 +0900 (JST)
Message-ID: <4F86BC71.9070403@jp.fujitsu.com>
Date: Thu, 12 Apr 2012 20:28:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 5/7] memcg: divide force_empty into 2 functions, avoid memory
 reclaim at rmdir
References: <4F86B9BE.8000105@jp.fujitsu.com>
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Now, at rmdir, memory cgroup's charge will be moved to
  - parent if use_hierarchy=1
  - root   if use_hierarchy=0

Then, we don't have to have memory reclaim code at destroying memcg.

This patch divides force_empty to 2 functions as

 - memory_cgroup_recharge() ... try to move all charges to ancestors.
 - memory_cgroup_force_empty().. try to reclaim all memory.

After this patch, memory.force_empty will _not_ move charges to ancestors
but just reclaim all pages. (This meets documenation.)

rmdir() will not reclaim any memory but moves charge to other cgroup,
parent or root.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   59 +++++++++++++++++++++++++++----------------------------
 1 files changed, 29 insertions(+), 30 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ac7984..22c8faa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3619,10 +3619,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 }
 
 /*
- * This routine traverse page_cgroup in given list and drop them all.
- * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
+ * This routine traverse page in given list and move them all.
  */
-static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
+static int mem_cgroup_recharge_lru(struct mem_cgroup *memcg,
 				int node, int zid, enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz;
@@ -3678,24 +3677,12 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 	return ret;
 }
 
-/*
- * make mem_cgroup's charge to be 0 if there is no task.
- * This enables deleting this mem_cgroup.
- */
-static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
+
+static int mem_cgroup_recharge(struct mem_cgroup *memcg)
 {
-	int ret;
-	int node, zid, shrink;
-	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	int ret, node, zid;
 	struct cgroup *cgrp = memcg->css.cgroup;
 
-	css_get(&memcg->css);
-
-	shrink = 0;
-	/* should free all ? */
-	if (free_all)
-		goto try_to_free;
-move_account:
 	do {
 		ret = -EBUSY;
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
@@ -3712,7 +3699,7 @@ move_account:
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
 				enum lru_list lru;
 				for_each_lru(lru) {
-					ret = mem_cgroup_force_empty_list(memcg,
+					ret = mem_cgroup_recharge_lru(memcg,
 							node, zid, lru);
 					if (ret)
 						break;
@@ -3722,24 +3709,33 @@ move_account:
 				break;
 		}
 		mem_cgroup_end_move(memcg);
-		memcg_oom_recover(memcg);
 		cond_resched();
 	/* "ret" should also be checked to ensure all lists are empty. */
 	} while (memcg->res.usage > 0 || ret);
 out:
-	css_put(&memcg->css);
 	return ret;
+}
+
+
+/*
+ * make mem_cgroup's charge to be 0 if there is no task. This is only called
+ * by memory.force_empty file, an user request.
+ */
+static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
+{
+	int ret = 0;
+	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct cgroup *cgrp = memcg->css.cgroup;
+
+	css_get(&memcg->css);
 
-try_to_free:
 	/* returns EBUSY if there is a task or if we come here twice. */
-	if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children) || shrink) {
+	if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children)) {
 		ret = -EBUSY;
 		goto out;
 	}
 	/* we call try-to-free pages for make this cgroup empty */
 	lru_add_drain_all();
-	/* try to free all pages in this cgroup */
-	shrink = 1;
 	while (nr_retries && memcg->res.usage > 0) {
 		int progress;
 
@@ -3754,16 +3750,19 @@ try_to_free:
 			/* maybe some writeback is necessary */
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 		}
-
 	}
-	lru_add_drain();
+	if (!nr_retries)
+		ret = -ENOMEM;
+out:
+	memcg_oom_recover(memcg);
+	css_put(&memcg->css);
 	/* try move_account...there may be some *locked* pages. */
-	goto move_account;
+	return ret;
 }
 
 int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
 {
-	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
+	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
 }
 
 
@@ -4987,7 +4986,7 @@ static int mem_cgroup_pre_destroy(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
-	return mem_cgroup_force_empty(memcg, false);
+	return mem_cgroup_recharge(memcg);
 }
 
 static void mem_cgroup_destroy(struct cgroup *cont)
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
