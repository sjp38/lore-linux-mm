Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id D50A48D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:50:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 626453EE0C5
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:50:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C80245DE5B
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:50:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 236A345DE4E
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:50:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 182011DB8038
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:50:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8A721DB803F
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:50:08 +0900 (JST)
Message-ID: <4FACE05C.60608@jp.fujitsu.com>
Date: Fri, 11 May 2012 18:48:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v3 3/6] memcg: use res_counter_uncharge_until in move_parent()
References: <4FACDED0.3020400@jp.fujitsu.com>
In-Reply-To: <4FACDED0.3020400@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

By using res_counter_uncharge_until(), we can avoid race and
unnecessary charging.

Changelog since v2:
 - a coding style chanve in __mem_cgroup_cancel_local_charge()
 - fixed typos.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   63 ++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 42 insertions(+), 21 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 09109be..cb90be1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2446,6 +2446,24 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
 }
 
 /*
+ * Cancel chrages in this cgroup....doesn't propagate to parent cgroup.
+ * This is useful when moving usage to parent cgroup.
+ */
+static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
+					unsigned int nr_pages)
+{
+	unsigned long bytes = nr_pages * PAGE_SIZE;
+
+	if (mem_cgroup_is_root(memcg))
+		return;
+
+	res_counter_uncharge_until(&memcg->res, memcg->res.parent, bytes);
+	if (do_swap_account)
+		res_counter_uncharge_until(&memcg->memsw,
+						memcg->memsw.parent, bytes);
+}
+
+/*
  * A helper function to get mem_cgroup from ID. must be called under
  * rcu_read_lock(). The caller must check css_is_removed() or some if
  * it's concern. (dropping refcnt from swap can be called against removed
@@ -2711,16 +2729,28 @@ static int mem_cgroup_move_parent(struct page *page,
 	nr_pages = hpage_nr_pages(page);
 
 	parent = mem_cgroup_from_cont(pcg);
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages, &parent, false);
-	if (ret)
-		goto put_back;
+	if (!parent->use_hierarchy) {
+		ret = __mem_cgroup_try_charge(NULL,
+					gfp_mask, nr_pages, &parent, false);
+		if (ret)
+			goto put_back;
+	}
 
 	if (nr_pages > 1)
 		flags = compound_lock_irqsave(page);
 
-	ret = mem_cgroup_move_account(page, nr_pages, pc, child, parent, true);
-	if (ret)
-		__mem_cgroup_cancel_charge(parent, nr_pages);
+	if (parent->use_hierarchy) {
+		ret = mem_cgroup_move_account(page, nr_pages,
+					pc, child, parent, false);
+		if (!ret)
+			__mem_cgroup_cancel_local_charge(child, nr_pages);
+	} else {
+		ret = mem_cgroup_move_account(page, nr_pages,
+					pc, child, parent, true);
+
+		if (ret)
+			__mem_cgroup_cancel_charge(parent, nr_pages);
+	}
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
@@ -3324,6 +3354,7 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
 	struct cgroup *pcgrp = cgroup->parent;
 	struct mem_cgroup *parent = mem_cgroup_from_cont(pcgrp);
 	struct mem_cgroup *memcg  = mem_cgroup_from_cont(cgroup);
+	struct res_counter *counter;
 
 	if (!get_page_unless_zero(page))
 		goto out;
@@ -3334,28 +3365,18 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
 		goto err_out;
 
 	csize = PAGE_SIZE << compound_order(page);
-	/*
-	 * If we have use_hierarchy set we can never fail here. So instead of
-	 * using res_counter_uncharge use the open-coded variant which just
-	 * uncharge the child res_counter. The parent will retain the charge.
-	 */
-	if (parent->use_hierarchy) {
-		unsigned long flags;
-		struct res_counter *counter;
-
-		counter = &memcg->hugepage[idx];
-		spin_lock_irqsave(&counter->lock, flags);
-		res_counter_uncharge_locked(counter, csize);
-		spin_unlock_irqrestore(&counter->lock, flags);
-	} else {
+	/* If parent->use_hierarchy == 0, we need to charge parent */
+	if (!parent->use_hierarchy) {
 		ret = res_counter_charge(&parent->hugepage[idx],
 					 csize, &fail_res);
 		if (ret) {
 			ret = -EBUSY;
 			goto err_out;
 		}
-		res_counter_uncharge(&memcg->hugepage[idx], csize);
 	}
+	counter = &memcg->hugepage[idx];
+	res_counter_uncharge_until(counter, counter->parent, csize);
+
 	pc->mem_cgroup = parent;
 err_out:
 	unlock_page_cgroup(pc);
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
