Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 62B926B0062
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 06:55:24 -0500 (EST)
Received: by mail-bw0-f215.google.com with SMTP id 7so369306bwz.6
        for <linux-mm@kvack.org>; Fri, 27 Nov 2009 03:55:22 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH RFC v1 1/3] cgroup: implement eventfd-based generic API for notifications
Date: Fri, 27 Nov 2009 13:55:02 +0200
Message-Id: <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259321503.git.kirill@shutemov.name>
In-Reply-To: <cover.1259255307.git.kirill@shutemov.name>
References: <cover.1259255307.git.kirill@shutemov.name>
In-Reply-To: <cover.1259321503.git.kirill@shutemov.name>
References: <cover.1259321503.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>
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

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/cgroup.h |    8 ++
 kernel/cgroup.c        |  181 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 188 insertions(+), 1 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 0008dee..285eaff 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -220,6 +220,9 @@ struct cgroup {
 
 	/* For RCU-protected deletion */
 	struct rcu_head rcu_head;
+
+	struct list_head event_list;
+	struct mutex event_list_mutex;
 };
 
 /*
@@ -362,6 +365,11 @@ struct cftype {
 	int (*trigger)(struct cgroup *cgrp, unsigned int event);
 
 	int (*release)(struct inode *inode, struct file *file);
+
+	int (*register_event)(struct cgroup *cgrp, struct cftype *cft,
+			struct eventfd_ctx *eventfd, const char *args);
+	int (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
+			struct eventfd_ctx *eventfd);
 };
 
 struct cgroup_scanner {
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0249f4b..5438d46 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4,6 +4,10 @@
  *  Based originally on the cpuset system, extracted by Paul Menage
  *  Copyright (C) 2006 Google, Inc
  *
+ *  Notifiactions support
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
 
@@ -146,6 +152,16 @@ struct css_id {
 	unsigned short stack[0]; /* Array of Length (depth+1) */
 };
 
+struct cgroup_event {
+	struct cgroup *cgrp;
+	struct cftype *cft;
+	struct eventfd_ctx *eventfd;
+	struct list_head list;
+	poll_table pt;
+	wait_queue_head_t *wqh;
+	wait_queue_t wait;
+};
+static int cgroup_event_remove(struct cgroup_event *event);
 
 /* The list of hierarchy roots */
 
@@ -734,14 +750,26 @@ static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
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
+	mutex_lock(&cgrp->event_list_mutex);
+	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
+		ret = cgroup_event_remove(event);
+		if (ret)
+			break;
+		eventfd_signal(event->eventfd, 1);
+	}
+	mutex_unlock(&cgrp->event_list_mutex);
+
+out:
 	return ret;
 }
 
@@ -1136,6 +1164,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->release_list);
 	INIT_LIST_HEAD(&cgrp->pidlists);
 	mutex_init(&cgrp->pidlist_mutex);
+	INIT_LIST_HEAD(&cgrp->event_list);
+	mutex_init(&cgrp->event_list_mutex);
 }
 
 static void init_cgroup_root(struct cgroupfs_root *root)
@@ -1935,6 +1965,13 @@ static const struct inode_operations cgroup_dir_inode_operations = {
 	.rename = cgroup_rename,
 };
 
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
@@ -2789,6 +2826,143 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
 	return 0;
 }
 
+static int cgroup_event_remove(struct cgroup_event *event)
+{
+	struct cgroup *cgrp = event->cgrp;
+	int ret;
+
+	BUG_ON(!mutex_is_locked(&cgrp->event_list_mutex));
+	ret = event->cft->unregister_event(cgrp, event->cft, event->eventfd);
+	eventfd_ctx_put(event->eventfd);
+	remove_wait_queue(event->wqh, &event->wait);
+	list_del(&event->list);
+	kfree(event);
+
+	return ret;
+}
+
+static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
+		int sync, void *key)
+{
+	struct cgroup_event *event = container_of(wait,
+			struct cgroup_event, wait);
+	struct cgroup *cgrp = event->cgrp;
+	unsigned long flags = (unsigned long)key;
+	int ret;
+
+	if (!(flags & POLLHUP))
+		return 0;
+
+	mutex_lock(&cgrp->event_list_mutex);
+	ret = cgroup_event_remove(event);
+	mutex_unlock(&cgrp->event_list_mutex);
+
+	return ret;
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
+static int cgroup_write_event_control(struct cgroup *cont, struct cftype *cft,
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
+	event->cgrp = cont;
+	INIT_LIST_HEAD(&event->list);
+	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
+	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
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
+	ret = event->cft->register_event(cont, event->cft,
+			event->eventfd, buffer);
+	if (ret)
+		goto fail;
+
+	efile->f_op->poll(efile, &event->pt);
+
+	mutex_lock(&cont->event_list_mutex);
+	list_add(&event->list, &cont->event_list);
+	mutex_unlock(&cont->event_list_mutex);
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
+	if (event)
+		kfree(event);
+
+	return ret;
+}
+
 /*
  * for the common functions, 'private' gives the type of file
  */
@@ -2814,6 +2988,11 @@ static struct cftype files[] = {
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
1.6.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
