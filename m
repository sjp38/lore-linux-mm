Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2BE446B0074
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 04:13:57 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBG9FRqM012031
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Dec 2008 18:15:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A65C45DD79
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:15:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F3AF45DE55
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:15:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DFCF1DB8048
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:15:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B4911DB8041
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:15:26 +0900 (JST)
Date: Tue, 16 Dec 2008 18:14:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/9] cgroup add css_tryget()
Message-Id: <20081216181430.319c1d4e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This was RFC from Paul Menage, including here just for base of my series.
==
From: menage@google.com

This patch adds css_tryget(), that obtains a counted reference on a
CSS.  It is used in situations where the caller has a "weak" reference
to the CSS, i.e. one that does not protect the cgroup from removal via
a reference count, but would instead be cleaned up by a destroy()
callback.

css_tryget() will return true on success, or false if the cgroup is
being removed.

This is similar to Kamezawa Hiroyuki's patch from a week or two ago,
but with the difference that in the event of css_tryget() racing with
a cgroup_rmdir(), css_tryget() will only return false if the cgroup
really does get removed.

This implementation is done by biasing css->refcnt, so that a refcnt
of 1 means "releasable" and 0 means "released or releasing". In the
event of a race, css_tryget() distinguishes between "released" and
"releasing" by checking for the CSS_REMOVED flag in css->flags.

Signed-off-by: Paul Menage <menage@google.com>

---
Index: mmotm-2.6.28-Dec12/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec12.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec12/include/linux/cgroup.h
@@ -52,9 +52,9 @@ struct cgroup_subsys_state {
 	 * hierarchy structure */
 	struct cgroup *cgroup;
 
-	/* State maintained by the cgroup system to allow
-	 * subsystems to be "busy". Should be accessed via css_get()
-	 * and css_put() */
+	/* State maintained by the cgroup system to allow subsystems
+	 * to be "busy". Should be accessed via css_get(),
+	 * css_tryget() and and css_put(). */
 
 	atomic_t refcnt;
 
@@ -64,11 +64,14 @@ struct cgroup_subsys_state {
 /* bits in struct cgroup_subsys_state flags field */
 enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
+	CSS_REMOVED, /* This CSS is dead */
 };
 
 /*
- * Call css_get() to hold a reference on the cgroup;
- *
+ * Call css_get() to hold a reference on the css; it can be used
+ * for a reference obtained via:
+ * - an existing ref-counted reference to the css
+ * - task->cgroups for a locked task
  */
 
 static inline void css_get(struct cgroup_subsys_state *css)
@@ -77,9 +80,27 @@ static inline void css_get(struct cgroup
 	if (!test_bit(CSS_ROOT, &css->flags))
 		atomic_inc(&css->refcnt);
 }
+
+/*
+ * Call css_tryget() to take a reference on a css if your existing
+ * (known-valid) reference isn't already ref-counted. Returns false if
+ * the css has been destroyed.
+ */
+
+static inline bool css_tryget(struct cgroup_subsys_state *css)
+{
+	if (test_bit(CSS_ROOT, &css->flags))
+		return true;
+	while (!atomic_inc_not_zero(&css->refcnt)) {
+		if (test_bit(CSS_REMOVED, &css->flags))
+			return false;
+	}
+	return true;
+}
+
 /*
  * css_put() should be called to release a reference taken by
- * css_get()
+ * css_get() or css_tryget()
  */
 
 extern void __css_put(struct cgroup_subsys_state *css);
Index: mmotm-2.6.28-Dec12/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Dec12.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Dec12/kernel/cgroup.c
@@ -2321,7 +2321,7 @@ static void init_cgroup_css(struct cgrou
 			       struct cgroup *cgrp)
 {
 	css->cgroup = cgrp;
-	atomic_set(&css->refcnt, 0);
+	atomic_set(&css->refcnt, 1);
 	css->flags = 0;
 	if (cgrp == dummytop)
 		set_bit(CSS_ROOT, &css->flags);
@@ -2453,7 +2453,7 @@ static int cgroup_has_css_refs(struct cg
 {
 	/* Check the reference count on each subsystem. Since we
 	 * already established that there are no tasks in the
-	 * cgroup, if the css refcount is also 0, then there should
+	 * cgroup, if the css refcount is also 1, then there should
 	 * be no outstanding references, so the subsystem is safe to
 	 * destroy. We scan across all subsystems rather than using
 	 * the per-hierarchy linked list of mounted subsystems since
@@ -2474,12 +2474,59 @@ static int cgroup_has_css_refs(struct cg
 		 * matter, since it can only happen if the cgroup
 		 * has been deleted and hence no longer needs the
 		 * release agent to be called anyway. */
-		if (css && atomic_read(&css->refcnt))
+		if (css && (atomic_read(&css->refcnt) > 1))
 			return 1;
 	}
 	return 0;
 }
 
+/*
+ * Atomically mark all of the cgroup's CSS objects as
+ * CSS_REMOVED. Return true on success, or false if the cgroup has
+ * busy subsystems. Call with cgroup_mutex held
+ */
+
+static int cgroup_clear_css_refs(struct cgroup *cgrp)
+{
+	struct cgroup_subsys *ss;
+	unsigned long flags;
+	bool failed = false;
+	local_irq_save(flags);
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		int refcnt;
+		do {
+			/* We can only remove a CSS with a refcnt==1 */
+			refcnt = atomic_read(&css->refcnt);
+			if (refcnt > 1) {
+				failed = true;
+				goto done;
+			}
+			BUG_ON(!refcnt);
+			/*
+			 * Drop the refcnt to 0 while we check other
+			 * subsystems. This will cause any racing
+			 * css_tryget() to spin until we set the
+			 * CSS_REMOVED bits or abort
+			 */
+		} while (atomic_cmpxchg(&css->refcnt, refcnt, 0) != refcnt);
+	}
+ done:
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		if (failed) {
+			/* Restore old refcnt if necessary */
+			if (!atomic_read(&css->refcnt))
+				atomic_set(&css->refcnt, 1);
+		} else {
+			/* Commit the fact that the CSS is removed */
+			set_bit(CSS_REMOVED, &css->flags);
+		}
+	}
+	local_irq_restore(flags);
+	return !failed;
+}
+
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 {
 	struct cgroup *cgrp = dentry->d_fsdata;
@@ -2510,7 +2557,7 @@ static int cgroup_rmdir(struct inode *un
 
 	if (atomic_read(&cgrp->count)
 	    || !list_empty(&cgrp->children)
-	    || cgroup_has_css_refs(cgrp)) {
+	    || !cgroup_clear_css_refs(cgrp)) {
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
@@ -3065,7 +3112,8 @@ void __css_put(struct cgroup_subsys_stat
 {
 	struct cgroup *cgrp = css->cgroup;
 	rcu_read_lock();
-	if (atomic_dec_and_test(&css->refcnt) && notify_on_release(cgrp)) {
+	if ((atomic_dec_return(&css->refcnt) == 1) &&
+	    notify_on_release(cgrp)) {
 		set_bit(CGRP_RELEASABLE, &cgrp->flags);
 		check_for_release(cgrp);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
