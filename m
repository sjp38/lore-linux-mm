Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0676B0062
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 00:31:23 -0500 (EST)
Date: Fri, 6 Nov 2009 14:12:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 3/8] memcg: add mem_cgroup_cancel_charge()
Message-Id: <20091106141219.25f83e6f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

There are some places calling both res_counter_uncharge() and css_put()
to cancel the charge and the refcnt we have got by mem_cgroup_tyr_charge().

This patch introduces mem_cgroup_cancel_charge() and call it in those places.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   38 ++++++++++++++++++--------------------
 1 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d3b2ac0..05e837c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1500,6 +1500,21 @@ nomem:
 }
 
 /*
+ * Somemtimes we have to undo a charge we got by try_charge().
+ * This function is for that and do uncharge, put css's refcnt.
+ * gotten by try_charge().
+ */
+static void mem_cgroup_cancel_charge(struct mem_cgroup *mem)
+{
+	if (!mem_cgroup_is_root(mem)) {
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		if (do_swap_account)
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+	}
+	css_put(&mem->css);
+}
+
+/*
  * A helper function to get mem_cgroup from ID. must be called under
  * rcu_read_lock(). The caller must check css_is_removed() or some if
  * it's concern. (dropping refcnt from swap can be called against removed
@@ -1565,12 +1580,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		if (!mem_cgroup_is_root(mem)) {
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			if (do_swap_account)
-				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
-		}
-		css_put(&mem->css);
+		mem_cgroup_cancel_charge(mem);
 		return;
 	}
 
@@ -1734,14 +1744,7 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 cancel:
 	put_page(page);
 uncharge:
-	/* drop extra refcnt by try_charge() */
-	css_put(&parent->css);
-	/* uncharge if move fails */
-	if (!mem_cgroup_is_root(parent)) {
-		res_counter_uncharge(&parent->res, PAGE_SIZE);
-		if (do_swap_account)
-			res_counter_uncharge(&parent->memsw, PAGE_SIZE);
-	}
+	mem_cgroup_cancel_charge(parent);
 	return ret;
 }
 
@@ -1957,12 +1960,7 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 		return;
 	if (!mem)
 		return;
-	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
-	}
-	css_put(&mem->css);
+	mem_cgroup_cancel_charge(mem);
 }
 
 static void
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
