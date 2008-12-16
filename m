Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0FD606B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 05:59:23 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBG9EFo6025534
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Dec 2008 18:14:15 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 956E345DE55
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:14:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 408A045DE4D
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:14:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D78A81DB8044
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:14:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CF951DB8040
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:14:11 +0900 (JST)
Date: Tue, 16 Dec 2008 18:13:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/9] use hierarchy mutex in memcg
Message-Id: <20081216181315.b990206b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This was RFC from Paul Menage, just for base of my series.
==
From:	menage@google.com

This patch updates the memory controller to use its hierarchy_mutex
rather than calling cgroup_lock() to protected against
cgroup_mkdir()/cgroup_rmdir() from occurring in its hierarchy.

Signed-off-by: Paul Menage <menage@google.com>

---
Index: mmotm-2.6.28-Dec12/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec12.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec12/mm/memcontrol.c
@@ -154,7 +154,7 @@ struct mem_cgroup {
 
 	/*
 	 * While reclaiming in a hiearchy, we cache the last child we
-	 * reclaimed from. Protected by cgroup_lock()
+	 * reclaimed from. Protected by hierarchy_mutex
 	 */
 	struct mem_cgroup *last_scanned_child;
 	/*
@@ -554,7 +554,7 @@ unsigned long mem_cgroup_isolate_pages(u
 
 /*
  * This routine finds the DFS walk successor. This routine should be
- * called with cgroup_mutex held
+ * called with hierarchy_mutex held
  */
 static struct mem_cgroup *
 mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
@@ -623,7 +623,7 @@ mem_cgroup_get_first_node(struct mem_cgr
 	/*
 	 * Scan all children under the mem_cgroup mem
 	 */
-	cgroup_lock();
+	mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
 	if (list_empty(&root_mem->css.cgroup->children)) {
 		ret = root_mem;
 		goto done;
@@ -644,7 +644,7 @@ mem_cgroup_get_first_node(struct mem_cgr
 
 done:
 	root_mem->last_scanned_child = ret;
-	cgroup_unlock();
+	mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
 	return ret;
 }
 
@@ -708,18 +708,16 @@ static int mem_cgroup_hierarchical_recla
 	while (next_mem != root_mem) {
 		if (next_mem->obsolete) {
 			mem_cgroup_put(next_mem);
-			cgroup_lock();
 			next_mem = mem_cgroup_get_first_node(root_mem);
-			cgroup_unlock();
 			continue;
 		}
 		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
 						   get_swappiness(next_mem));
 		if (mem_cgroup_check_under_limit(root_mem))
 			return 0;
-		cgroup_lock();
+		mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
 		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
-		cgroup_unlock();
+		mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
 	}
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
