Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2916B0055
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:08:34 -0400 (EDT)
Date: Thu, 17 Sep 2009 11:24:00 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH 1/8] memcg: introduce mem_cgroup_cancel_charge()
Message-Id: <20090917112400.2d90c60d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

There are some places calling both res_counter_uncharge() and css_put()
to cancel the charge and the refcnt we have got by mem_cgroup_tyr_charge().

This patch introduces mem_cgroup_cancel_charge() and call it in those places.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   35 ++++++++++++++---------------------
 1 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2b98a6..00f3f97 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1370,6 +1370,17 @@ nomem:
 	return -ENOMEM;
 }
 
+/* A helper function to cancel the charge and refcnt by try_charge */
+static inline void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
+{
+	if (!mem_cgroup_is_root(mem)) {
+		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
+		if (do_swap_account)
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
+	}
+	css_put(&mem->css);
+}
+
 /*
  * A helper function to get mem_cgroup from ID. must be called under
  * rcu_read_lock(). The caller must check css_is_removed() or some if
@@ -1436,13 +1447,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		if (!mem_cgroup_is_root(mem)) {
-			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
-			if (do_swap_account)
-				res_counter_uncharge(&mem->memsw, PAGE_SIZE,
-							NULL);
-		}
-		css_put(&mem->css);
+		mem_cgroup_cancel_charge(mem);
 		return;
 	}
 
@@ -1606,14 +1611,7 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 cancel:
 	put_page(page);
 uncharge:
-	/* drop extra refcnt by try_charge() */
-	css_put(&parent->css);
-	/* uncharge if move fails */
-	if (!mem_cgroup_is_root(parent)) {
-		res_counter_uncharge(&parent->res, PAGE_SIZE, NULL);
-		if (do_swap_account)
-			res_counter_uncharge(&parent->memsw, PAGE_SIZE, NULL);
-	}
+	mem_cgroup_cancel_charge(parent);
 	return ret;
 }
 
@@ -1830,12 +1828,7 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 		return;
 	if (!mem)
 		return;
-	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
-		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
-	}
-	css_put(&mem->css);
+	mem_cgroup_cancel_charge(mem);
 }
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
