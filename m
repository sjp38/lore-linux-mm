Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 25ED36B00B5
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 04:57:57 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8I8w3QS003418
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Sep 2009 17:58:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BF50845DE4E
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:58:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C66445DE4F
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:58:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47F14E08003
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:58:02 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5800E1DB803C
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:58:00 +0900 (JST)
Date: Fri, 18 Sep 2009 17:55:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/11] memcg: clean up cancel charge
Message-Id: <20090918175555.d380ad11.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

>From Nishimra-san's set.

==
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

There are some places calling both res_counter_uncharge() and css_put()
to cancel the charge and the refcnt we have got by mem_cgroup_tyr_charge().

This patch introduces mem_cgroup_cancel_charge() and call it in those places.

Modification from Nishimura's 
 - removed 'inline'
 - adjusted for a change in res_counter_uncharge.
 - added comment

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

---
 mm/memcontrol.c |   37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

Index: mmotm-2.6.31-Sep17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep17.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep17/mm/memcontrol.c
@@ -1472,6 +1472,21 @@ nomem:
 }
 
 /*
+ * Somemtimes we have to undo a charge we got by try_charge().
+ * This function is for that and do uncharge, put css's refcnt.
+ * gotten by try_charge().
+ */
+static void __mem_cgroup_cancel_charge(struct mem_cgroup *mem)
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
@@ -1537,12 +1552,7 @@ static void __mem_cgroup_commit_charge(s
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-		if (!mem_cgroup_is_root(mem)) {
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			if (do_swap_account)
-				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
-		}
-		css_put(&mem->css);
+		__mem_cgroup_cancel_charge(mem);
 		return;
 	}
 
@@ -1707,13 +1717,7 @@ cancel:
 	put_page(page);
 uncharge:
 	/* drop extra refcnt by try_charge() */
-	css_put(&parent->css);
-	/* uncharge if move fails */
-	if (!mem_cgroup_is_root(parent)) {
-		res_counter_uncharge(&parent->res, PAGE_SIZE);
-		if (do_swap_account)
-			res_counter_uncharge(&parent->memsw, PAGE_SIZE);
-	}
+	__mem_cgroup_cancel_charge(parent);
 	return ret;
 }
 
@@ -1929,12 +1933,7 @@ void mem_cgroup_cancel_charge_swapin(str
 		return;
 	if (!mem)
 		return;
-	if (!mem_cgroup_is_root(mem)) {
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		if (do_swap_account)
-			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
-	}
-	css_put(&mem->css);
+	__mem_cgroup_cancel_charge(mem);
 }
 
 static void

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
