Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id D271D6B00FB
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 07:23:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5C1A33EE0B5
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:23:12 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4002445DE52
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:23:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 24F5F45DE4F
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:23:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 16366E08002
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:23:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF2561DB802F
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:23:11 +0900 (JST)
Message-ID: <4F86BAB0.5030809@jp.fujitsu.com>
Date: Thu, 12 Apr 2012 20:21:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/7] memcg: move charge to parent only when necessary.
References: <4F86B9BE.8000105@jp.fujitsu.com>
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>


When memcg->use_hierarchy==true, the parent res_counter includes
the usage in child's usage. So, it's not necessary to call try_charge()
in the parent.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   39 ++++++++++++++++++++++++++++++++-------
 1 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fa01106..3215880 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2409,6 +2409,20 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
 			res_counter_uncharge(&memcg->memsw, bytes);
 	}
 }
+/*
+ * Moving usage between a child to its parent if use_hierarchy==true.
+ */
+static void __mem_cgroup_move_charge_parent(struct mem_cgroup *memcg,
+					unsigned int nr_pages)
+{
+	if (!mem_cgroup_is_root(memcg)) {
+		unsigned long bytes = nr_pages * PAGE_SIZE;
+
+		res_counter_move_parent(&memcg->res, bytes);
+		if (do_swap_account)
+			res_counter_move_parent(&memcg->memsw, bytes);
+	}
+}
 
 /*
  * A helper function to get mem_cgroup from ID. must be called under
@@ -2666,18 +2680,29 @@ static int mem_cgroup_move_parent(struct page *page,
 		goto put;
 
 	nr_pages = hpage_nr_pages(page);
-
 	parent = mem_cgroup_from_cont(pcg);
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages, &parent, false);
-	if (ret)
-		goto put_back;
+
+	if (!parent->use_hierarchy) {
+		ret = __mem_cgroup_try_charge(NULL, gfp_mask,
+					nr_pages, &parent, false);
+		if (ret)
+			goto put_back;
+	}
 
 	if (nr_pages > 1)
 		flags = compound_lock_irqsave(page);
 
-	ret = mem_cgroup_move_account(page, nr_pages, pc, child, parent, true);
-	if (ret)
-		__mem_cgroup_cancel_charge(parent, nr_pages);
+	if (!parent->use_hierarchy) {
+		ret = mem_cgroup_move_account(page, nr_pages, pc,
+					child, parent, true);
+		if (ret)
+			__mem_cgroup_cancel_charge(parent, nr_pages);
+	} else {
+		ret = mem_cgroup_move_account(page, nr_pages, pc,
+					child, parent, false);
+		if (!ret)
+			__mem_cgroup_move_charge_parent(child, nr_pages);
+	}
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
