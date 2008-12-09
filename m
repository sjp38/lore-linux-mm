Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB9BBIcK023442
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Dec 2008 20:11:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3842C45DE59
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:11:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1230945DE53
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:11:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C136D1DB8046
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:11:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 59ADA1DB8043
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:11:17 +0900 (JST)
Date: Tue, 9 Dec 2008 20:10:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/6] fix inactive_ratio under hierarchy
Message-Id: <20081209201023.65bb98e6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

After lru updates for memcg, followint test easily see OOM.
and memory-reclaim speed was very bad.

	mkdir /opt/cgroup/xxx
	echo 1 > /opt/cgroup/xxx/memory.use_hierarchy
	mkdir /opt/cgroup/xxx/01
	mkdir /opt/cgroup/xxx/02
	echo 40M > /opt/cgroup/xxx/memory.limit_in_bytes
	
	Run task under group 01 or 02.

This is because calclation of inactive_ratio doesn't handle hierarchy.
In above, 01 and 02's inactive_ratio = 65535 and inactive list will be
empty.

This patch tries to set 01 and 02 's inactive ration to appropriate value
under hierarchy. inactive_ratio is adjusted to the minimum limit found in
upwards in hierarchy.


ex)In following tree,
	/opt/cgroup/01		limit=1G
	/opt/cgroup/01/A	limit=500M
	/opt/cgroup/01/A/B	limit=unlimited
	/opt/cgroup/01/A/C	limit=50M
	/opt/cgroup/01/Z	limit=700M


	/opt/cgroup/01's inactive_ratio is calculated by limit of 1G.
	/opt/cgroup/01/A's inactive_ratio is calculated by limit of 500M 
	/opt/cgroup/01/A/B's inactive_ratio is calculated by limit of 500M.
	/opt/cgroup/01/A/C's inactive_ratio is calculated by limit of 50M.
	/opt/cgroup/01's inactive_ratio is calculated by limit of 700M.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>

 mm/memcontrol.c |   71 ++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 64 insertions(+), 7 deletions(-)

---
Index: mmotm-2.6.28-Dec08/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec08.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec08/mm/memcontrol.c
@@ -1382,20 +1382,73 @@ int mem_cgroup_shrink_usage(struct mm_st
  * page_alloc.c::setup_per_zone_inactive_ratio().
  * it describe more detail.
  */
-static void mem_cgroup_set_inactive_ratio(struct mem_cgroup *memcg)
+static int __mem_cgroup_inactive_ratio(unsigned long long gb)
 {
-	unsigned int gb, ratio;
+	unsigned int ratio;
 
-	gb = res_counter_read_u64(&memcg->res, RES_LIMIT) >> 30;
+	gb = gb >> 30;
 	if (gb)
 		ratio = int_sqrt(10 * gb);
 	else
 		ratio = 1;
 
-	memcg->inactive_ratio = ratio;
+	return ratio;
+}
+
+
+static void mem_cgroup_update_inactive_ratio(struct mem_cgroup *memcg)
+{
+	struct cgroup *cur;
+	struct mem_cgroup *root_memcg, *tmp;
+	unsigned long long min_limit, limit;
+	int depth, nextid, rootid, found, ratio;
+
+	if (!memcg->use_hierarchy) {
+		limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
+		memcg->inactive_ratio = __mem_cgroup_inactive_ratio(limit);
+		return;
+	}
 
+	cur = memcg->css.cgroup;
+	min_limit = res_counter_read_u64(&tmp->res, RES_LIMIT);
+
+	/* go up to root cgroup and find min limit.*/
+	while (cur->parent != NULL) {
+		tmp = mem_cgroup_from_cont(cur);
+		if (!tmp->use_hierarchy)
+			break;
+		limit = res_counter_read_u64(&tmp->res, RES_LIMIT);
+		if (limit < min_limit)
+			limit = min_limit;
+		cur = cur->parent;
+	}
+	/* new inactive ratio for this hierarchy */
+	ratio = __mem_cgroup_inactive_ratio(min_limit);
+
+	/*
+	 * update inactive ratio under this.
+	 * all children's inactive_ratio will be updated.
+	 */
+	cur = memcg->css.cgroup;
+	rootid = cgroup_id(cur);
+	depth = cgroup_depth(cur);
+	nextid = 0;
+	rcu_read_lock();
+	while (1) {
+		cur = cgroup_get_next(nextid, rootid, depth, &found);
+		if (!cur)
+			break;
+		if (!cgroup_is_removed(cur)) {
+			tmp = mem_cgroup_from_cont(cur);
+			tmp->inactive_ratio = ratio;
+		}
+		nextid = found + 1;
+	}
+	rcu_read_unlock();
 }
 
+
+
 static DEFINE_MUTEX(set_limit_mutex);
 
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
@@ -1435,8 +1488,11 @@ static int mem_cgroup_resize_limit(struc
   		if (!progress)			retry_count--;
 	}
 
-	if (!ret)
-		mem_cgroup_set_inactive_ratio(memcg);
+	if (!ret) {
+		mutex_lock(&set_limit_mutex);
+		mem_cgroup_update_inactive_ratio(memcg);
+		mutex_unlock(&set_limit_mutex);
+	}
 
 	return ret;
 }
@@ -2081,11 +2137,12 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (parent && parent->use_hierarchy) {
 		res_counter_init(&mem->res, &parent->res);
 		res_counter_init(&mem->memsw, &parent->memsw);
+		/* min_limit under hierarchy is unchanged.*/
+		mem->inactive_ratio = parent->inactive_ratio;
 	} else {
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
 	}
-	mem_cgroup_set_inactive_ratio(mem);
 	mem->last_scanned_child = 0;
 	mem->scan_age = 0;
 	spin_lock_init(&mem->reclaim_param_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
