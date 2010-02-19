Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7496A6B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 17:28:36 -0500 (EST)
Received: by fxm22 with SMTP id 22so684283fxm.6
        for <linux-mm@kvack.org>; Fri, 19 Feb 2010 14:28:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH -mmotm 1/4] cgroups: Fix race between userspace and kernelspace
Date: Sat, 20 Feb 2010 00:28:16 +0200
Message-Id: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Notify userspace about cgroup removing only after rmdir of cgroup
directory to avoid race between userspace and kernelspace.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 kernel/cgroup.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ce9008f..46903cb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -780,28 +780,15 @@ static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
 static int cgroup_call_pre_destroy(struct cgroup *cgrp)
 {
 	struct cgroup_subsys *ss;
-	struct cgroup_event *event, *tmp;
 	int ret = 0;
 
 	for_each_subsys(cgrp->root, ss)
 		if (ss->pre_destroy) {
 			ret = ss->pre_destroy(ss, cgrp);
 			if (ret)
-				goto out;
+				break;
 		}
 
-	/*
-	 * Unregister events and notify userspace.
-	 */
-	spin_lock(&cgrp->event_list_lock);
-	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
-		list_del(&event->list);
-		eventfd_signal(event->eventfd, 1);
-		schedule_work(&event->remove);
-	}
-	spin_unlock(&cgrp->event_list_lock);
-
-out:
 	return ret;
 }
 
@@ -2991,7 +2978,6 @@ static void cgroup_event_remove(struct work_struct *work)
 	event->cft->unregister_event(cgrp, event->cft, event->eventfd);
 
 	eventfd_ctx_put(event->eventfd);
-	remove_wait_queue(event->wqh, &event->wait);
 	kfree(event);
 }
 
@@ -3009,6 +2995,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 	unsigned long flags = (unsigned long)key;
 
 	if (flags & POLLHUP) {
+		remove_wait_queue_locked(event->wqh, &event->wait);
 		spin_lock(&cgrp->event_list_lock);
 		list_del(&event->list);
 		spin_unlock(&cgrp->event_list_lock);
@@ -3457,6 +3444,7 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	struct dentry *d;
 	struct cgroup *parent;
 	DEFINE_WAIT(wait);
+	struct cgroup_event *event, *tmp;
 	int ret;
 
 	/* the vfs holds both inode->i_mutex already */
@@ -3540,6 +3528,20 @@ again:
 	set_bit(CGRP_RELEASABLE, &parent->flags);
 	check_for_release(parent);
 
+	/*
+	 * Unregister events and notify userspace.
+	 * Notify userspace about cgroup removing only after rmdir of cgroup
+	 * directory to avoid race between userspace and kernelspace
+	 */
+	spin_lock(&cgrp->event_list_lock);
+	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
+		list_del(&event->list);
+		remove_wait_queue(event->wqh, &event->wait);
+		eventfd_signal(event->eventfd, 1);
+		schedule_work(&event->remove);
+	}
+	spin_unlock(&cgrp->event_list_lock);
+
 	mutex_unlock(&cgroup_mutex);
 	return 0;
 }
-- 
1.6.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
