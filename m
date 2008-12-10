Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBA4a41N031802
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Dec 2008 13:36:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A5E245DE63
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:36:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 25F9E45DE55
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:36:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E4F101DB8038
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:36:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 979821DB804D
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:36:01 +0900 (JST)
Date: Wed, 10 Dec 2008 13:35:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH mmotm 1/2] cgroup: fix to stop adding a new task while rmdir
 going on
Message-Id: <20081210133508.3ee454ae.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

still need reviews.
==
Recently, pre_destroy() was moved to out of cgroup_lock() for avoiding
dead lock. But, by this, serialization between task attach and rmdir()
is lost.

This adds CGRP_TRY_REMOVE flag to cgroup and check it at attaching.
If attach_pid founds CGRP_TRY_REMOVE, it returns -EBUSY.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 include/linux/cgroup.h |    2 ++
 kernel/cgroup.c        |   11 +++++++++++
 2 files changed, 13 insertions(+)

Index: mmotm-2.6.28-Dec09/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec09.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec09/include/linux/cgroup.h
@@ -98,6 +98,8 @@ enum {
 	CGRP_RELEASABLE,
 	/* Control Group requires release notifications to userspace */
 	CGRP_NOTIFY_ON_RELEASE,
+	/* Control Group is in rmdir() sequence. stop adding new tasks */
+	CGRP_TRY_REMOVE,
 };
 
 struct cgroup {
Index: mmotm-2.6.28-Dec09/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Dec09.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Dec09/kernel/cgroup.c
@@ -122,6 +122,11 @@ inline int cgroup_is_removed(const struc
 {
 	return test_bit(CGRP_REMOVED, &cgrp->flags);
 }
+/* cgroup is in rmdir() sequnece */
+static inline int cgroup_is_being_removed(const struct cgroup *cgrp)
+{
+	return test_bit(CGRP_TRY_REMOVE, &cgrp->flags);
+}
 
 /* bits in struct cgroupfs_root flags field */
 enum {
@@ -1307,6 +1312,10 @@ static int cgroup_tasks_write(struct cgr
 	int ret;
 	if (!cgroup_lock_live_group(cgrp))
 		return -ENODEV;
+	if (cgroup_is_being_removed(cgrp)) {
+		cgroup_unlock();
+		return -EBUSY;
+	}
 	ret = attach_task_by_pid(cgrp, pid);
 	cgroup_unlock();
 	return ret;
@@ -2469,6 +2478,7 @@ static int cgroup_rmdir(struct inode *un
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
+	set_bit(CGRP_TRY_REMOVE, &cgrp->flags);
 	mutex_unlock(&cgroup_mutex);
 
 	/*
@@ -2483,6 +2493,7 @@ static int cgroup_rmdir(struct inode *un
 	if (atomic_read(&cgrp->count)
 	    || !list_empty(&cgrp->children)
 	    || cgroup_has_css_refs(cgrp)) {
+		clear_bit(CGRP_TRY_REMOVE, &cgrp->flags);
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
