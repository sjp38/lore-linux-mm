Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CD5236B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 04:36:34 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n089aW8U015383
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 18:36:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FB1845DE4F
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:36:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 24E1C45DE51
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:36:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 05AA7E18001
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:36:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 934681DB8041
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:36:31 +0900 (JST)
Date: Thu, 8 Jan 2009 18:35:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir
Message-Id: <20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Experimental. you may think of better fix.

When trying following test under memcg.

	create memcg under
		/cgroup/A/  use_hierarchy=1, limit=20M
			 /B some tasks
			 /C empty
			 /D empty

And run make kernel under /B (for example). This will hit limit of 20M and
hierarchical memory reclaim will scan A->B->C->D.
(C,D have to be scanned because it may have some page caches.)

	Here, run following scipt.

	while true; do
		rmdir /cgroup/A/C
		mkdir /cgroup/A/C
	done

You'll see -EBUSY at rmdir very often. This is because of temporal refcnt of
memory reclaim for safe scanning under hierarchy.

In usual, considering shell script,
	"please try again if you see -EBUSY at rmdir.
	 You may see -EBUSY at rmdir even if it seems you can do it."
is very unuseful.

This patch tries to fix -EBUSY behavior. memcg's pre_destroy() works pretty
fine and retrying rmdir() is O.K.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/cgroup.h |    5 +++++
 kernel/cgroup.c        |   32 +++++++++++++++++++++++++-------
 mm/memcontrol.c        |    9 ++++++---
 3 files changed, 36 insertions(+), 10 deletions(-)

Index: mmotm-2.6.28-Jan7/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Jan7.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Jan7/include/linux/cgroup.h
@@ -368,6 +368,11 @@ struct cgroup_subsys {
 	int disabled;
 	int early_init;
 	/*
+	 * set if subsys may retrun EBUSY while there are no tasks and
+	 * subsys knows it's very temporal reference.
+ 	 */
+	int retry_at_rmdir_failure;
+	/*
 	 * True if this subsys uses ID. ID is not available before cgroup_init()
 	 * (not available in early_init time.)
 	 */
Index: mmotm-2.6.28-Jan7/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Jan7.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Jan7/kernel/cgroup.c
@@ -2503,15 +2503,17 @@ static int cgroup_has_css_refs(struct cg
 
 /*
  * Atomically mark all (or else none) of the cgroup's CSS objects as
- * CSS_REMOVED. Return true on success, or false if the cgroup has
+ * CSS_REMOVED. Return 0 on success, or false error code if the cgroup has
  * busy subsystems. Call with cgroup_mutex held
  */
 
 static int cgroup_clear_css_refs(struct cgroup *cgrp)
 {
-	struct cgroup_subsys *ss;
+	struct cgroup_subsys *ss, *failedhere;
 	unsigned long flags;
 	bool failed = false;
+	int err = -EBUSY;
+
 	local_irq_save(flags);
 	for_each_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
@@ -2521,6 +2523,7 @@ static int cgroup_clear_css_refs(struct 
 			refcnt = atomic_read(&css->refcnt);
 			if (refcnt > 1) {
 				failed = true;
+				failedhere = ss;
 				goto done;
 			}
 			BUG_ON(!refcnt);
@@ -2548,7 +2551,13 @@ static int cgroup_clear_css_refs(struct 
 		}
 	}
 	local_irq_restore(flags);
-	return !failed;
+
+	if (failed) {
+		if (failedhere->retry_at_rmdir_failure)
+			err = -EAGAIN;
+	} else
+		err = 0;
+	return err;
 }
 
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
@@ -2556,9 +2565,10 @@ static int cgroup_rmdir(struct inode *un
 	struct cgroup *cgrp = dentry->d_fsdata;
 	struct dentry *d;
 	struct cgroup *parent;
+	int ret;
 
 	/* the vfs holds both inode->i_mutex already */
-
+retry:
 	mutex_lock(&cgroup_mutex);
 	if (atomic_read(&cgrp->count) != 0) {
 		mutex_unlock(&cgroup_mutex);
@@ -2579,12 +2589,20 @@ static int cgroup_rmdir(struct inode *un
 	mutex_lock(&cgroup_mutex);
 	parent = cgrp->parent;
 
-	if (atomic_read(&cgrp->count)
-	    || !list_empty(&cgrp->children)
-	    || !cgroup_clear_css_refs(cgrp)) {
+	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
+	ret = cgroup_clear_css_refs(cgrp);
+	if (ret == -EBUSY) { /* really busy */
+		mutex_unlock(&cgroup_mutex);
+		return ret;
+	}
+	if (ret == -EAGAIN) { /* subsys asks us to retry later */
+		mutex_unlock(&cgroup_mutex);
+		cond_resched();
+		goto retry;
+	}
 
 	spin_lock(&release_list_lock);
 	set_bit(CGRP_REMOVED, &cgrp->flags);
Index: mmotm-2.6.28-Jan7/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Jan7.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Jan7/mm/memcontrol.c
@@ -723,7 +723,8 @@ static int mem_cgroup_hierarchical_recla
 {
 	struct mem_cgroup *victim;
 	unsigned long start_age;
-	int ret, total = 0;
+	int ret = 0;
+	int total = 0;
 	/*
 	 * Reclaim memory from cgroups under root_mem in round robin.
 	 */
@@ -732,8 +733,9 @@ static int mem_cgroup_hierarchical_recla
 	while (time_after((start_age + 2UL), root_mem->scan_age)) {
 		victim = mem_cgroup_select_victim(root_mem);
 		/* we use swappiness of local cgroup */
-		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
-						   get_swappiness(victim));
+		if (victim->res.usage)
+			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
+					noswap, get_swappiness(victim));
 		css_put(&victim->css);
 		total += ret;
 		if (mem_cgroup_check_under_limit(root_mem))
@@ -2261,6 +2263,7 @@ struct cgroup_subsys mem_cgroup_subsys =
 	.populate = mem_cgroup_populate,
 	.attach = mem_cgroup_move_task,
 	.early_init = 0,
+	.retry_at_rmdir_failure = 1,
 	.use_id = 1,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
