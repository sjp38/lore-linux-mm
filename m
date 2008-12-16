Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4729A6B0074
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 01:01:31 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBG62xAu027643
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Dec 2008 15:03:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B673B45DD7F
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 15:02:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 93BB045DD7B
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 15:02:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C0881DB803F
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 15:02:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 21D481DB803B
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 15:02:59 +0900 (JST)
Date: Tue, 16 Dec 2008 15:02:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][RFT][PATCH] memcg: fix double free in error route
Message-Id: <20081216150202.bf6408ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Could you test this ?
This includes a fix and a cleanup.

After this, the kernel will panic if handling of refcnt is bad.
This is against mmotom-dec-15.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 1. Fix double-free BUG in error route of mem_cgroup_create().
    mem_cgroup_free() itself frees per-zone-info.
 2. Making refcnt of memcg simple.
    Add 1 refcnt at creation and call free when refcnt goes down to 0.

Singed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.28-Dec15/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec15.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec15/mm/memcontrol.c
@@ -2087,14 +2087,10 @@ static struct mem_cgroup *mem_cgroup_all
  * Removal of cgroup itself succeeds regardless of refs from swap.
  */
 
-static void mem_cgroup_free(struct mem_cgroup *mem)
+static void __mem_cgroup_free(struct mem_cgroup *mem)
 {
 	int node;
 
-	if (atomic_read(&mem->refcnt) > 0)
-		return;
-
-
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
@@ -2111,11 +2107,8 @@ static void mem_cgroup_get(struct mem_cg
 
 static void mem_cgroup_put(struct mem_cgroup *mem)
 {
-	if (atomic_dec_and_test(&mem->refcnt)) {
-		if (!mem->obsolete)
-			return;
-		mem_cgroup_free(mem);
-	}
+	if (atomic_dec_and_test(&mem->refcnt))
+		__mem_cgroup_free(mem);
 }
 
 
@@ -2165,12 +2158,10 @@ mem_cgroup_create(struct cgroup_subsys *
 
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
-
+	atomic_set(&mem->refcnt, 1);
 	return &mem->css;
 free_out:
-	for_each_node_state(node, N_POSSIBLE)
-		free_mem_cgroup_per_zone_info(mem, node);
-	mem_cgroup_free(mem);
+	__mem_cgroup_free(mem);
 	return ERR_PTR(-ENOMEM);
 }
 
@@ -2185,7 +2176,7 @@ static void mem_cgroup_pre_destroy(struc
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	mem_cgroup_free(mem_cgroup_from_cont(cont));
+	mem_cgroup_put(mem_cgroup_from_cont(cont));
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
