Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 59C7A6B005A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 01:58:10 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n825wHBS023965
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 2 Sep 2009 14:58:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B07545DE4F
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 14:58:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E0B945DE4E
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 14:58:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EA9FCE1800C
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 14:58:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 95A661DB8040
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 14:58:16 +0900 (JST)
Date: Wed, 2 Sep 2009 14:56:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH 2/2 v2] memcg: reduce calls for soft limit excess
Message-Id: <20090902145621.83c8a79c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090902093551.c8b171fb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902093551.c8b171fb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

In charge/uncharge/reclaim path, usage_in_excess is calculated repeatedly and
it takes res_counter's spin_lock every time.

This patch removes unnecessary calls for res_count_soft_limit_excess.

Changelog:
 - fixed description.
 - fixed unsigned long to be unsigned long long (Thanks, Nishimura)

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

Index: mmotm-2.6.31-Aug27/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Aug27.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Aug27/mm/memcontrol.c
@@ -313,7 +313,8 @@ soft_limit_tree_from_page(struct page *p
 static void
 __mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
 				struct mem_cgroup_per_zone *mz,
-				struct mem_cgroup_tree_per_zone *mctz)
+				struct mem_cgroup_tree_per_zone *mctz,
+				unsigned long long new_usage_in_excess)
 {
 	struct rb_node **p = &mctz->rb_root.rb_node;
 	struct rb_node *parent = NULL;
@@ -322,7 +323,9 @@ __mem_cgroup_insert_exceeded(struct mem_
 	if (mz->on_tree)
 		return;
 
-	mz->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
+	mz->usage_in_excess = new_usage_in_excess;
+	if (!mz->usage_in_excess)
+		return;
 	while (*p) {
 		parent = *p;
 		mz_node = rb_entry(parent, struct mem_cgroup_per_zone,
@@ -382,7 +385,7 @@ static bool mem_cgroup_soft_limit_check(
 
 static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
 {
-	unsigned long long new_usage_in_excess;
+	unsigned long long excess;
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup_tree_per_zone *mctz;
 	int nid = page_to_nid(page);
@@ -395,25 +398,21 @@ static void mem_cgroup_update_tree(struc
 	 */
 	for (; mem; mem = parent_mem_cgroup(mem)) {
 		mz = mem_cgroup_zoneinfo(mem, nid, zid);
-		new_usage_in_excess =
-			res_counter_soft_limit_excess(&mem->res);
+		excess = res_counter_soft_limit_excess(&mem->res);
 		/*
 		 * We have to update the tree if mz is on RB-tree or
 		 * mem is over its softlimit.
 		 */
-		if (new_usage_in_excess || mz->on_tree) {
+		if (excess || mz->on_tree) {
 			spin_lock(&mctz->lock);
 			/* if on-tree, remove it */
 			if (mz->on_tree)
 				__mem_cgroup_remove_exceeded(mem, mz, mctz);
 			/*
-			 * if over soft limit, insert again. mz->usage_in_excess
-			 * will be updated properly.
+			 * Insert again. mz->usage_in_excess will be updated.
+			 * If excess is 0, no tree ops.
 			 */
-			if (new_usage_in_excess)
-				__mem_cgroup_insert_exceeded(mem, mz, mctz);
-			else
-				mz->usage_in_excess = 0;
+			__mem_cgroup_insert_exceeded(mem, mz, mctz, excess);
 			spin_unlock(&mctz->lock);
 		}
 	}
@@ -2216,6 +2215,7 @@ unsigned long mem_cgroup_soft_limit_recl
 	unsigned long reclaimed;
 	int loop = 0;
 	struct mem_cgroup_tree_per_zone *mctz;
+	unsigned long long excess;
 
 	if (order > 0)
 		return 0;
@@ -2260,9 +2260,8 @@ unsigned long mem_cgroup_soft_limit_recl
 				__mem_cgroup_largest_soft_limit_node(mctz);
 			} while (next_mz == mz);
 		}
-		mz->usage_in_excess =
-			res_counter_soft_limit_excess(&mz->mem->res);
 		__mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
+		excess = res_counter_soft_limit_excess(&mz->mem->res);
 		/*
 		 * One school of thought says that we should not add
 		 * back the node to the tree if reclaim returns 0.
@@ -2271,8 +2270,8 @@ unsigned long mem_cgroup_soft_limit_recl
 		 * memory to reclaim from. Consider this as a longer
 		 * term TODO.
 		 */
-		if (mz->usage_in_excess)
-			__mem_cgroup_insert_exceeded(mz->mem, mz, mctz);
+		/* If excess == 0, no tree ops */
+		__mem_cgroup_insert_exceeded(mz->mem, mz, mctz, excess);
 		spin_unlock(&mctz->lock);
 		css_put(&mz->mem->css);
 		loop++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
