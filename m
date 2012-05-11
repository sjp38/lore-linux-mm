Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 169FA8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:51:20 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AA4E63EE0BD
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:51:18 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CE8145DE54
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:51:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72DA445DE55
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:51:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 612D21DB8048
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:51:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A0B9E08006
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:51:18 +0900 (JST)
Message-ID: <4FACE0A2.30608@jp.fujitsu.com>
Date: Fri, 11 May 2012 18:49:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v3 4/6] memcg: move charges to root cgroup if use_hierarchy=0.
References: <4FACDED0.3020400@jp.fujitsu.com>
In-Reply-To: <4FACDED0.3020400@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

Now, at removal of cgroup, ->pre_destroy() is called and move charges
to the parent cgroup. A major reason of -EBUSY returned by ->pre_destroy()
is that the 'moving' hits parent's resource limitation. It happens only
when use_hierarchy=0.

Considering use_hierarchy=0, all cgroups should be flat. So, no one
cannot justify moving charges to parent...parent and children are in
flat configuration, not hierarchical.

This patch modifes to move charges to root cgroup at rmdir/force_empty
if use_hierarchy==0. This will much simplify rmdir() and reduce error
in ->pre_destroy.

Changelog since v2:
  - use parent_mem_cgroup()
  - updated Documenation

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   13 ++++++----
 mm/memcontrol.c                  |   49 +++++++++++++------------------------
 2 files changed, 25 insertions(+), 37 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 730e222a..8d0de70 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -393,14 +393,15 @@ cgroup might have some charge associated with it, even though all
 tasks have migrated away from it. (because we charge against pages, not
 against tasks.)
 
-Such charges are freed or moved to their parent. At moving, both of RSS
-and CACHES are moved to parent.
-rmdir() may return -EBUSY if freeing/moving fails. See 5.1 also.
+We move the stats to root (if use_hierarchy==0) or parent (if
+use_hierarchy==1), and no change on the charge except uncharging
+from the child.
 
 Charges recorded in swap information is not updated at removal of cgroup.
 Recorded information is discarded and a cgroup which uses swap (swapcache)
 will be charged as a new owner of it.
 
+About use_hierarchy, see Section 6.
 
 5. Misc. interfaces.
 
@@ -413,13 +414,15 @@ will be charged as a new owner of it.
 
   Almost all pages tracked by this memory cgroup will be unmapped and freed.
   Some pages cannot be freed because they are locked or in-use. Such pages are
-  moved to parent and this cgroup will be empty. This may return -EBUSY if
-  VM is too busy to free/move all pages immediately.
+  moved to parent(if use_hierarchy==1) or root (if use_hierarchy==0) and this
+  cgroup will be empty.
 
   Typical use case of this interface is that calling this before rmdir().
   Because rmdir() moves all pages to parent, some out-of-use page caches can be
   moved to the parent. If you want to avoid that, force_empty will be useful.
 
+  About use_hierarchy, see Section 6.
+
 5.2 stat file
 
 memory.stat file includes following statistics
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cb90be1..f007c17 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2709,15 +2709,13 @@ static int mem_cgroup_move_parent(struct page *page,
 				  struct mem_cgroup *child,
 				  gfp_t gfp_mask)
 {
-	struct cgroup *cg = child->css.cgroup;
-	struct cgroup *pcg = cg->parent;
 	struct mem_cgroup *parent;
 	unsigned int nr_pages;
 	unsigned long uninitialized_var(flags);
 	int ret;
 
 	/* Is ROOT ? */
-	if (!pcg)
+	if (mem_cgroup_is_root(child))
 		return -EINVAL;
 
 	ret = -EBUSY;
@@ -2728,33 +2726,23 @@ static int mem_cgroup_move_parent(struct page *page,
 
 	nr_pages = hpage_nr_pages(page);
 
-	parent = mem_cgroup_from_cont(pcg);
-	if (!parent->use_hierarchy) {
-		ret = __mem_cgroup_try_charge(NULL,
-					gfp_mask, nr_pages, &parent, false);
-		if (ret)
-			goto put_back;
-	}
+	parent = parent_mem_cgroup(child);
+	/*
+	 * If no parent, move charges to root cgroup.
+	 */
+	if (!parent)
+		parent = root_mem_cgroup;
 
 	if (nr_pages > 1)
 		flags = compound_lock_irqsave(page);
 
-	if (parent->use_hierarchy) {
-		ret = mem_cgroup_move_account(page, nr_pages,
-					pc, child, parent, false);
-		if (!ret)
-			__mem_cgroup_cancel_local_charge(child, nr_pages);
-	} else {
-		ret = mem_cgroup_move_account(page, nr_pages,
-					pc, child, parent, true);
-
-		if (ret)
-			__mem_cgroup_cancel_charge(parent, nr_pages);
-	}
+	ret = mem_cgroup_move_account(page, nr_pages,
+				pc, child, parent, false);
+	if (!ret)
+		__mem_cgroup_cancel_local_charge(child, nr_pages);
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
-put_back:
 	putback_lru_page(page);
 put:
 	put_page(page);
@@ -3351,9 +3339,8 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
 	struct page_cgroup *pc;
 	int csize,  ret = 0;
 	struct res_counter *fail_res;
-	struct cgroup *pcgrp = cgroup->parent;
-	struct mem_cgroup *parent = mem_cgroup_from_cont(pcgrp);
 	struct mem_cgroup *memcg  = mem_cgroup_from_cont(cgroup);
+	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
 	struct res_counter *counter;
 
 	if (!get_page_unless_zero(page))
@@ -3366,13 +3353,11 @@ int mem_cgroup_move_hugetlb_parent(int idx, struct cgroup *cgroup,
 
 	csize = PAGE_SIZE << compound_order(page);
 	/* If parent->use_hierarchy == 0, we need to charge parent */
-	if (!parent->use_hierarchy) {
-		ret = res_counter_charge(&parent->hugepage[idx],
-					 csize, &fail_res);
-		if (ret) {
-			ret = -EBUSY;
-			goto err_out;
-		}
+	if (!parent) {
+		parent = root_mem_cgroup;
+		/* root has no limit */
+		res_counter_charge_nofail(&parent->hugepage[idx],
+				 csize, &fail_res);
 	}
 	counter = &memcg->hugepage[idx];
 	res_counter_uncharge_until(counter, counter->parent, csize);
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
