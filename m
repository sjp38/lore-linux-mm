Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A42760021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 10:58:14 -0500 (EST)
Received: by mail-fx0-f228.google.com with SMTP id 28so3274160fxm.6
        for <linux-mm@kvack.org>; Wed, 30 Dec 2009 07:58:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v5 1/4] cgroup: implement eventfd-based generic API for notifications
Date: Wed, 30 Dec 2009 17:57:56 +0200
Message-Id: <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
In-Reply-To: <cover.1262186097.git.kirill@shutemov.name>
References: <cover.1262186097.git.kirill@shutemov.name>
In-Reply-To: <cover.1262186097.git.kirill@shutemov.name>
References: <cover.1262186097.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

This patch introduces write-only file "cgroup.event_control" in every
cgroup.

To register new notification handler you need:
- create an eventfd;
- open a control file to be monitored. Callbacks register_event() and
  unregister_event() must be defined for the control file;
- write "<event_fd> <control_fd> <args>" to cgroup.event_control.
  Interpretation of args is defined by control file implementation;

eventfd will be woken up by control file implementation or when the
cgroup is removed.

To unregister notification handler just close eventfd.

If you need notification functionality for a control file you have to
implement callbacks register_event() and unregister_event() in the
struct cftype.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/cgroups.txt |   20 ++++
 include/linux/cgroup.h            |   24 +++++
 kernel/cgroup.c                   |  208 ++++++++++++++++++++++++++++++++++++-
 3 files changed, 251 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 3bda601..b73c306 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -23,6 +23,7 @@ CONTENTS:
   2.1 Basic Usage
   2.2 Attaching processes
   2.3 Mounting hierarchies by name
+  2.4 Notification API
 3. Kernel API
   3.1 Overview
   3.2 Synchronization
@@ -435,6 +436,25 @@ you give a subsystem a name.
 The name of the subsystem appears as part of the hierarchy description
 in /proc/mounts and /proc/<pid>/cgroups.
 
+2.4 Notification API
+--------------------
+
+There is mechanism which allows to get notifications about changing
+status of a cgroup.
+
+To register new notification handler you need:
+ - create a file descriptor for event notification using eventfd(2);
+ - open a control file to be monitored (e.g. memory.usage_in_bytes);
+ - write "<event_fd> <control_fd> <args>" to cgroup.event_control.
+   Interpretation of args is defined by control file implementation;
+
+eventfd will be woken up by control file implementation or when the
+cgroup is removed.
+
+To unregister notification handler just close eventfd.
+
+NOTE: Support of notifications should be implemented for the control
+file. See documentation for the subsystem.
 
 3. Kernel API
 =============
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 0008dee..b078409 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -220,6 +220,10 @@ struct cgroup {
 
 	/* For RCU-protected deletion */
 	struct rcu_head rcu_head;
+
+	/* List of events which userspace want to recieve */
+	struct list_head event_list;
+	spinlock_t event_list_lock;
 };
 
 /*
@@ -362,6 +366,26 @@ struct cftype {
 	int (*trigger)(struct cgroup *cgrp, unsigned int event);
 
 	int (*release)(struct inode *inode, struct file *file);
+
+	/*
+	 * register_event() callback will be used to add new userspace
+	 * waiter for changes related to the cftype. Implement it if
+	 * you want to provide this functionality. Use eventfd_signal()
+	 * on eventfd to send notification to userspace.
+	 */
+	int (*register_event)(struct cgroup *cgrp, struct cftype *cft,
+			struct eventfd_ctx *eventfd, const char *args);
+	/*
+	 * unregister_event() callback will be called when userspace
+	 * closes the eventfd or on cgroup removing.
+	 * This callback must be implemented, if you want provide
+	 * notification functionality.
+	 *
+	 * Be careful. It can be called after destroy(), so you have
+	 * to keep all nesessary data, until all events are removed.
+	 */
+	int (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
+			struct eventfd_ctx *eventfd);
 };
 
 struct cgroup_scanner {
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0249f4b..6017e7a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4,6 +4,10 @@
  *  Based originally on the cpuset system, extracted by Paul Menage
  *  Copyright (C) 2006 Google, Inc
  *
+ *  Notifications support
+ *  Copyright (C) 2009 Nokia Corporation
+ *  Author: Kirill A. Shutemov
+ *
  *  Copyright notices from the original cpuset code:
  *  --------------------------------------------------
  *  Copyright (C) 2003 BULL SA.
@@ -51,6 +55,8 @@
 #include <linux/pid_namespace.h>
 #include <linux/idr.h>
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
+#include <linux/eventfd.h>
+#include <linux/poll.h>
 
 #include <asm/atomic.h>
 
@@ -146,6 +152,35 @@ struct css_id {
 	unsigned short stack[0]; /* Array of Length (depth+1) */
 };
 
+/*
+ * cgroup_event represents events which userspace want to recieve.
+ */
+struct cgroup_event {
+	/*
+	 * Cgroup which the event belongs to.
+	 */
+	struct cgroup *cgrp;
+	/*
+	 * Control file which the event associated.
+	 */
+	struct cftype *cft;
+	/*
+	 * eventfd to signal userspace about the event.
+	 */
+	struct eventfd_ctx *eventfd;
+	/*
+	 * Each of these stored in a list by the cgroup.
+	 */
+	struct list_head list;
+	/*
+	 * All fields below needed to unregister event when
+	 * userspace closes eventfd.
+	 */
+	poll_table pt;
+	wait_queue_head_t *wqh;
+	wait_queue_t wait;
+	struct work_struct remove;
+};
 
 /* The list of hierarchy roots */
 
@@ -734,14 +769,28 @@ static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
 static int cgroup_call_pre_destroy(struct cgroup *cgrp)
 {
 	struct cgroup_subsys *ss;
+	struct cgroup_event *event, *tmp;
 	int ret = 0;
 
 	for_each_subsys(cgrp->root, ss)
 		if (ss->pre_destroy) {
 			ret = ss->pre_destroy(ss, cgrp);
 			if (ret)
-				break;
+				goto out;
 		}
+
+	/*
+	 * Unregister events and notify userspace.
+	 */
+	spin_lock(&cgrp->event_list_lock);
+	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
+		list_del(&event->list);
+		eventfd_signal(event->eventfd, 1);
+		schedule_work(&event->remove);
+	}
+	spin_unlock(&cgrp->event_list_lock);
+
+out:
 	return ret;
 }
 
@@ -1136,6 +1185,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->release_list);
 	INIT_LIST_HEAD(&cgrp->pidlists);
 	mutex_init(&cgrp->pidlist_mutex);
+	INIT_LIST_HEAD(&cgrp->event_list);
+	spin_lock_init(&cgrp->event_list_lock);
 }
 
 static void init_cgroup_root(struct cgroupfs_root *root)
@@ -1935,6 +1986,16 @@ static const struct inode_operations cgroup_dir_inode_operations = {
 	.rename = cgroup_rename,
 };
 
+/*
+ * Check if a file is a control file
+ */
+static inline struct cftype *__file_cft(struct file *file)
+{
+	if (file->f_dentry->d_inode->i_fop != &cgroup_file_operations)
+		return ERR_PTR(-EINVAL);
+	return __d_cft(file->f_dentry);
+}
+
 static int cgroup_create_file(struct dentry *dentry, mode_t mode,
 				struct super_block *sb)
 {
@@ -2789,6 +2850,146 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
 	return 0;
 }
 
+static void cgroup_event_remove(struct work_struct *work)
+{
+	struct cgroup_event *event = container_of(work, struct cgroup_event,
+			remove);
+	struct cgroup *cgrp = event->cgrp;
+
+	/* TODO: check return code*/
+	event->cft->unregister_event(cgrp, event->cft, event->eventfd);
+
+	eventfd_ctx_put(event->eventfd);
+	remove_wait_queue(event->wqh, &event->wait);
+	kfree(event);
+}
+
+static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
+		int sync, void *key)
+{
+	struct cgroup_event *event = container_of(wait,
+			struct cgroup_event, wait);
+	struct cgroup *cgrp = event->cgrp;
+	unsigned long flags = (unsigned long)key;
+
+	if (flags & POLLHUP) {
+		spin_lock(&cgrp->event_list_lock);
+		list_del(&event->list);
+		spin_unlock(&cgrp->event_list_lock);
+		schedule_work(&event->remove);
+	}
+
+	return 0;
+}
+
+static void cgroup_event_ptable_queue_proc(struct file *file,
+		wait_queue_head_t *wqh, poll_table *pt)
+{
+	struct cgroup_event *event = container_of(pt,
+			struct cgroup_event, pt);
+
+	event->wqh = wqh;
+	add_wait_queue(wqh, &event->wait);
+}
+
+static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
+				      const char *buffer)
+{
+	struct cgroup_event *event = NULL;
+	unsigned int efd, cfd;
+	struct file *efile = NULL;
+	struct file *cfile = NULL;
+	char *endp;
+	int ret;
+
+	efd = simple_strtoul(buffer, &endp, 10);
+	if (*endp != ' ')
+		return -EINVAL;
+	buffer = endp + 1;
+
+	cfd = simple_strtoul(buffer, &endp, 10);
+	if ((*endp != ' ') && (*endp != '\0'))
+		return -EINVAL;
+	buffer = endp + 1;
+
+	event = kzalloc(sizeof(*event), GFP_KERNEL);
+	if (!event)
+		return -ENOMEM;
+	event->cgrp = cgrp;
+	INIT_LIST_HEAD(&event->list);
+	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
+	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
+	INIT_WORK(&event->remove, cgroup_event_remove);
+
+	efile = eventfd_fget(efd);
+	if (IS_ERR(efile)) {
+		ret = PTR_ERR(efile);
+		goto fail;
+	}
+
+	event->eventfd = eventfd_ctx_fileget(efile);
+	if (IS_ERR(event->eventfd)) {
+		ret = PTR_ERR(event->eventfd);
+		goto fail;
+	}
+
+	cfile = fget(cfd);
+	if (!cfile) {
+		ret = -EBADF;
+		goto fail;
+	}
+
+	/* the process need read permission on control file */
+	ret = file_permission(cfile, MAY_READ);
+	if (ret < 0)
+		goto fail;
+
+	event->cft = __file_cft(cfile);
+	if (IS_ERR(event->cft)) {
+		ret = PTR_ERR(event->cft);
+		goto fail;
+	}
+
+	if (!event->cft->register_event || !event->cft->unregister_event) {
+		ret = -EINVAL;
+		goto fail;
+	}
+
+	ret = event->cft->register_event(cgrp, event->cft,
+			event->eventfd, buffer);
+	if (ret)
+		goto fail;
+
+	if (efile->f_op->poll(efile, &event->pt) & POLLHUP) {
+		event->cft->unregister_event(cgrp, event->cft, event->eventfd);
+		ret = 0;
+		goto fail;
+	}
+
+	spin_lock(&cgrp->event_list_lock);
+	list_add(&event->list, &cgrp->event_list);
+	spin_unlock(&cgrp->event_list_lock);
+
+	fput(cfile);
+	fput(efile);
+
+	return 0;
+
+fail:
+	if (!IS_ERR(cfile))
+		fput(cfile);
+
+	if (event && event->eventfd && !IS_ERR(event->eventfd))
+		eventfd_ctx_put(event->eventfd);
+
+	if (!IS_ERR(efile))
+		fput(efile);
+
+	kfree(event);
+
+	return ret;
+}
+
 /*
  * for the common functions, 'private' gives the type of file
  */
@@ -2814,6 +3015,11 @@ static struct cftype files[] = {
 		.read_u64 = cgroup_read_notify_on_release,
 		.write_u64 = cgroup_write_notify_on_release,
 	},
+	{
+		.name = CGROUP_FILE_GENERIC_PREFIX "event_control",
+		.write_string = cgroup_write_event_control,
+		.mode = S_IWUGO,
+	},
 };
 
 static struct cftype cft_release_agent = {
-- 
1.6.5.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
