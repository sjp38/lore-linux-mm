Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id E4C746B00FD
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 07:24:34 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0907A3EE081
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:24:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E0B7E45DE4E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:24:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C466345DD74
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:24:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B6BCB1DB803A
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:24:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FE661DB802C
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:24:32 +0900 (JST)
Message-ID: <4F86BB02.2060607@jp.fujitsu.com>
Date: Thu, 12 Apr 2012 20:22:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/7] memcg: move charges to root at rmdir()
References: <4F86B9BE.8000105@jp.fujitsu.com>
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

As recently discussed, Tejun Heo, the cgroup maintainer, tries to
remove ->pre_destroy() and cgroup will never return -EBUSY at rmdir().

To do that, in memcg, handling case of use_hierarchy==false is a problem.

We move memcg's charges to its parent at rmdir(). If use_hierarchy==true,
it's already accounted in the parent, no problem. If use_hierarchy==false,
we cannot guarantee we can move all charges to the parent.

This patch changes the behavior to move all charges to root_mem_cgroup
if use_hierarchy=false. It seems this matches semantics of use_hierarchy==false,which means parent and child has no hierarchical relationship.

With this, we can remove -ENOMEM error check at pre_destroy(), called at rmdir.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |    6 ++++--
 mm/memcontrol.c                  |   38 ++++++++++++--------------------------
 2 files changed, 16 insertions(+), 28 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 84d4f00..f717f6a 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -377,8 +377,10 @@ cgroup might have some charge associated with it, even though all
 tasks have migrated away from it. (because we charge against pages, not
 against tasks.)
 
-Such charges are freed or moved to their parent. At moving, both of RSS
-and CACHES are moved to parent.
+Such charges are freed or moved to their parent if use_hierarchy==true.
+If use_hierarchy==false, charges are moved to root memory cgroup.
+
+At moving, both of RSS and CACHES are moved to parent.
 rmdir() may return -EBUSY if freeing/moving fails. See 5.1 also.
 
 Charges recorded in swap information is not updated at removal of cgroup.
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3215880..8246418 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2662,15 +2662,14 @@ static int mem_cgroup_move_parent(struct page *page,
 				  struct mem_cgroup *child,
 				  gfp_t gfp_mask)
 {
-	struct cgroup *cg = child->css.cgroup;
-	struct cgroup *pcg = cg->parent;
 	struct mem_cgroup *parent;
 	unsigned int nr_pages;
 	unsigned long uninitialized_var(flags);
+	bool need_cancel = false;
 	int ret;
 
 	/* Is ROOT ? */
-	if (!pcg)
+	if (mem_cgroup_is_root(child))
 		return -EINVAL;
 
 	ret = -EBUSY;
@@ -2680,33 +2679,23 @@ static int mem_cgroup_move_parent(struct page *page,
 		goto put;
 
 	nr_pages = hpage_nr_pages(page);
-	parent = mem_cgroup_from_cont(pcg);
-
-	if (!parent->use_hierarchy) {
-		ret = __mem_cgroup_try_charge(NULL, gfp_mask,
-					nr_pages, &parent, false);
-		if (ret)
-			goto put_back;
+	parent = parent_mem_cgroup(child);
+	if (!parent) {
+		parent = root_mem_cgroup;
+		need_cancel = true;
 	}
 
 	if (nr_pages > 1)
 		flags = compound_lock_irqsave(page);
 
-	if (!parent->use_hierarchy) {
-		ret = mem_cgroup_move_account(page, nr_pages, pc,
-					child, parent, true);
-		if (ret)
-			__mem_cgroup_cancel_charge(parent, nr_pages);
-	} else {
-		ret = mem_cgroup_move_account(page, nr_pages, pc,
-					child, parent, false);
-		if (!ret)
-			__mem_cgroup_move_charge_parent(child, nr_pages);
-	}
+	ret = mem_cgroup_move_account(page, nr_pages, pc, child, parent,
+					need_cancel);
+	if (!need_cancel && !ret)
+		__mem_cgroup_move_charge_parent(child, nr_pages);
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
-put_back:
+
 	putback_lru_page(page);
 put:
 	put_page(page);
@@ -3677,7 +3666,7 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 		pc = lookup_page_cgroup(page);
 
 		ret = mem_cgroup_move_parent(page, pc, memcg, GFP_KERNEL);
-		if (ret == -ENOMEM || ret == -EINTR)
+		if (ret == -EINTR)
 			break;
 
 		if (ret == -EBUSY || ret == -EINVAL) {
@@ -3738,9 +3727,6 @@ move_account:
 		}
 		mem_cgroup_end_move(memcg);
 		memcg_oom_recover(memcg);
-		/* it seems parent cgroup doesn't have enough mem */
-		if (ret == -ENOMEM)
-			goto try_to_free;
 		cond_resched();
 	/* "ret" should also be checked to ensure all lists are empty. */
 	} while (memcg->res.usage > 0 || ret);
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
