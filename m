Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 85D246B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 05:05:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5U95JLS014280
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Jun 2009 18:05:19 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E42A645DE4E
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:05:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BEF5A45DE4D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:05:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 715371DB803A
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:05:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E26D5E08008
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:05:17 +0900 (JST)
Date: Tue, 30 Jun 2009 18:03:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] cgroup: exlclude release rmdir
Message-Id: <20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Paul Menage pointed out that css_get()/put() only for avoiding race with
rmdir() is complicated and these should be treated as it is for.

This adds
   - cgroup_exclude_rmdir() ....prevent rmdir() for a while.
   - cgroup_release_rmdir() ....rerun rmdir() if necessary.
And hides cgroup_wakeup_rmdir_waiter() into kernel/cgroup.c, again.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/cgroup.h |   21 +++++++++++----------
 kernel/cgroup.c        |   17 +++++++++++++++--
 mm/memcontrol.c        |   12 ++++--------
 3 files changed, 30 insertions(+), 20 deletions(-)

Index: mmotm-2.6.31-Jun25/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.31-Jun25.orig/include/linux/cgroup.h
+++ mmotm-2.6.31-Jun25/include/linux/cgroup.h
@@ -366,17 +366,18 @@ int cgroup_task_count(const struct cgrou
 int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task);
 
 /*
- * Allow to use CGRP_WAIT_ON_RMDIR flag to check race with rmdir() for subsys.
- * Subsys can call this function if it's necessary to call pre_destroy() again
- * because it adds not-temporary refs to css after or while pre_destroy().
- * The caller of this function should use css_tryget(), too.
+ * When the subsys has to access css and may add permanent refcnt to css,
+ * it should take care of racy conditions with rmdir(). Following set of
+ * functions, is for stop/restart rmdir if necessary.
+ * Because these will call css_get/put, "css" should be alive css.
+ *
+ *  cgroup_exclude_rmdir();
+ *  ...do some jobs which may access arbitrary empty cgroup
+ *  cgroup_release_rmdir();
  */
-void __cgroup_wakeup_rmdir_waiters(void);
-static inline void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
-{
-	if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
-		__cgroup_wakeup_rmdir_waiters();
-}
+
+void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
+void cgroup_release_rmdir(struct cgroup_subsys_state *css);
 
 /*
  * Control Group subsystem type.
Index: mmotm-2.6.31-Jun25/kernel/cgroup.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/kernel/cgroup.c
+++ mmotm-2.6.31-Jun25/kernel/cgroup.c
@@ -738,11 +738,24 @@ static void cgroup_d_remove_dir(struct d
  */
 DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
 
-void __cgroup_wakeup_rmdir_waiters(void)
+static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
 {
-	wake_up_all(&cgroup_rmdir_waitq);
+	if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
+		wake_up_all(&cgroup_rmdir_waitq);
 }
 
+void cgroup_exclude_rmdir(struct cgroup_subsys_state *css)
+{
+	css_get(css);
+}
+
+void cgroup_release_rmdir(struct cgroup_subsys_state *css)
+{
+	cgroup_wakeup_rmdir_waiter(css->cgroup);
+	css_put(css);
+}
+
+
 static int rebind_subsystems(struct cgroupfs_root *root,
 			      unsigned long final_bits)
 {
Index: mmotm-2.6.31-Jun25/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Jun25/mm/memcontrol.c
@@ -1461,7 +1461,7 @@ __mem_cgroup_commit_charge_swapin(struct
 		return;
 	if (!ptr)
 		return;
-	css_get(&ptr->css);
+	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
 	mem_cgroup_lru_del_before_commit_swapcache(page);
 	__mem_cgroup_commit_charge(ptr, pc, ctype);
@@ -1496,9 +1496,7 @@ __mem_cgroup_commit_charge_swapin(struct
 	 * So, rmdir()->pre_destroy() can be called while we do this charge.
 	 * In that case, we need to call pre_destroy() again. check it here.
 	 */
-	cgroup_wakeup_rmdir_waiter(ptr->css.cgroup);
-	css_put(&ptr->css);
-
+	cgroup_release_rmdir(&ptr->css);
 }
 
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
@@ -1704,7 +1702,7 @@ void mem_cgroup_end_migration(struct mem
 
 	if (!mem)
 		return;
-	css_get(&mem->css);
+	cgroup_exclude_rmdir(&mem->css);
 	/* at migration success, oldpage->mapping is NULL. */
 	if (oldpage->mapping) {
 		target = oldpage;
@@ -1749,9 +1747,7 @@ void mem_cgroup_end_migration(struct mem
 	 * So, rmdir()->pre_destroy() can be called while we do this charge.
 	 * In that case, we need to call pre_destroy() again. check it here.
 	 */
-	cgroup_wakeup_rmdir_waiter(mem->css.cgroup);
-	css_put(&mem->css);
-
+	cgroup_release_rmdir(&mem->css);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
