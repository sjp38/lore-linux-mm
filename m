Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B79616B0095
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:24:49 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P8Otr7022104
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 17:24:55 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0105045DE50
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:24:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CAF4D45DE4F
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:24:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B5DE41DB8037
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:24:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C32EE38003
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:24:54 +0900 (JST)
Date: Fri, 25 Sep 2009 17:22:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/10] memcg: add memcg charge cancel
Message-Id: <20090925172245.ac761f9a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

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
 mm/memcontrol.c |   38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

Index: temp-mmotm/mm/memcontrol.c
===================================================================
--- temp-mmotm.orig/mm/memcontrol.c
+++ temp-mmotm/mm/memcontrol.c
@@ -1489,6 +1489,21 @@ nomem:
 	return -ENOMEM;
 }
 
+/*
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
 
 static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 {
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
+		mem_cgroup_cancel_charge(mem);
 		return;
 	}
 
@@ -1786,12 +1796,7 @@ void mem_cgroup_cancel_charge_swapin(str
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
 
 
@@ -2196,14 +2201,7 @@ static int mem_cgroup_move_parent(struct
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
