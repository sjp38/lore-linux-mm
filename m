Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2499D6B00B3
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 03:00:37 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2B80YCt009836
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Mar 2010 17:00:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C99CF45DE52
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:00:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C19345DE4E
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:00:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C3561DB8048
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:00:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 031D41DB804C
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:00:33 +0900 (JST)
Date: Thu, 11 Mar 2010 16:57:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/3] memcg: oom notifier
Message-Id: <20100311165700.4468ef2a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Considering containers or other resource management softwares in userland,
event notification of OOM in memcg should be implemented.
Now, memcg has "threshold" notifier which uses eventfd, we can make
use of it for oom notification.

This patch adds oom notification eventfd callback for memcg. The usage
is very similar to threshold notifier, but control file is
memory.oom_control and no arguments other than eventfd is required.

	% cgroup_event_notifier /cgroup/A/memory.oom_control dummy
	(About cgroup_event_notifier, see Documentation/cgroup/)

TODO:
 - add a knob to disable oom-kill under a memcg.
 - add read/write function to oom_control

Changelog: 20100309
 - splitted from threshold functions. use list rather than array.
 - moved all to inside of mutex.
Changelog: 20100304
 - renewed implemenation.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   20 +++++++
 mm/memcontrol.c                  |  105 ++++++++++++++++++++++++++++++++++++---
 2 files changed, 116 insertions(+), 9 deletions(-)

Index: mmotm-2.6.34-Mar9/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-Mar9.orig/mm/memcontrol.c
+++ mmotm-2.6.34-Mar9/mm/memcontrol.c
@@ -149,6 +149,7 @@ struct mem_cgroup_threshold {
 	u64 threshold;
 };
 
+/* For threshold */
 struct mem_cgroup_threshold_ary {
 	/* An array index points to threshold just below usage. */
 	atomic_t current_threshold;
@@ -157,8 +158,14 @@ struct mem_cgroup_threshold_ary {
 	/* Array of thresholds */
 	struct mem_cgroup_threshold entries[0];
 };
+/* for OOM */
+struct mem_cgroup_eventfd_list {
+	struct list_head list;
+	struct eventfd_ctx *eventfd;
+};
 
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
+static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
 /*
  * The memory controller data structure. The memory controller controls both
@@ -220,6 +227,9 @@ struct mem_cgroup {
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_threshold_ary *memsw_thresholds;
 
+	/* For oom notifier event fd */
+	struct list_head oom_notify;
+
 	/*
 	 * Should we move charges of a task when a task is moved into this
 	 * mem_cgroup ? And what type of charges should we move ?
@@ -282,9 +292,12 @@ enum charge_type {
 /* for encoding cft->private value on file */
 #define _MEM			(0)
 #define _MEMSWAP		(1)
+#define _OOM_TYPE		(2)
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
 #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
+/* Used for OOM nofiier */
+#define OOM_CONTROL		(0)
 
 /*
  * Reclaim flags for mem_cgroup_hierarchical_reclaim
@@ -1351,6 +1364,8 @@ bool mem_cgroup_handle_oom(struct mem_cg
 	 */
 	if (!locked)
 		prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
+	else
+		mem_cgroup_oom_notify(mem);
 	mutex_unlock(&memcg_oom_mutex);
 
 	if (locked)
@@ -3398,8 +3413,22 @@ static int compare_thresholds(const void
 	return _a->threshold - _b->threshold;
 }
 
-static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
-		struct eventfd_ctx *eventfd, const char *args)
+static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem, void *data)
+{
+	struct mem_cgroup_eventfd_list *ev;
+
+	list_for_each_entry(ev, &mem->oom_notify, list)
+		eventfd_signal(ev->eventfd, 1);
+	return 0;
+}
+
+static void mem_cgroup_oom_notify(struct mem_cgroup *mem)
+{
+	mem_cgroup_walk_tree(mem, NULL, mem_cgroup_oom_notify_cb);
+}
+
+static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
+	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
@@ -3483,8 +3512,8 @@ unlock:
 	return ret;
 }
 
-static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
-		struct eventfd_ctx *eventfd)
+static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
+	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
@@ -3568,13 +3597,66 @@ unlock:
 	return ret;
 }
 
+static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
+	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup_eventfd_list *event;
+	int type = MEMFILE_TYPE(cft->private);
+	int ret = -ENOMEM;
+
+	BUG_ON(type != _OOM_TYPE);
+
+	mutex_lock(&memcg_oom_mutex);
+
+	/* Allocate memory for new array of thresholds */
+	event = kmalloc(sizeof(*event),	GFP_KERNEL);
+	if (!event)
+		goto unlock;
+	/* Add new threshold */
+	event->eventfd = eventfd;
+	list_add(&event->list, &memcg->oom_notify);
+
+	/* already in OOM ? */
+	if (atomic_read(&memcg->oom_lock))
+		eventfd_signal(eventfd, 1);
+	ret = 0;
+unlock:
+	mutex_unlock(&memcg_oom_mutex);
+
+	return ret;
+}
+
+static int mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
+	struct cftype *cft, struct eventfd_ctx *eventfd)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup_eventfd_list *ev, *tmp;
+	int type = MEMFILE_TYPE(cft->private);
+
+	BUG_ON(type != _OOM_TYPE);
+
+	mutex_lock(&memcg_oom_mutex);
+
+	list_for_each_entry_safe(ev, tmp, &mem->oom_notify, list) {
+		if (ev->eventfd == eventfd) {
+			list_del(&ev->list);
+			kfree(ev);
+		}
+	}
+
+	mutex_unlock(&memcg_oom_mutex);
+
+	return 0;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
 		.read_u64 = mem_cgroup_read,
-		.register_event = mem_cgroup_register_event,
-		.unregister_event = mem_cgroup_unregister_event,
+		.register_event = mem_cgroup_usage_register_event,
+		.unregister_event = mem_cgroup_usage_unregister_event,
 	},
 	{
 		.name = "max_usage_in_bytes",
@@ -3623,6 +3705,12 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_move_charge_read,
 		.write_u64 = mem_cgroup_move_charge_write,
 	},
+	{
+		.name = "oom_control",
+		.register_event = mem_cgroup_oom_register_event,
+		.unregister_event = mem_cgroup_oom_unregister_event,
+		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -3631,8 +3719,8 @@ static struct cftype memsw_cgroup_files[
 		.name = "memsw.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
 		.read_u64 = mem_cgroup_read,
-		.register_event = mem_cgroup_register_event,
-		.unregister_event = mem_cgroup_unregister_event,
+		.register_event = mem_cgroup_usage_register_event,
+		.unregister_event = mem_cgroup_usage_unregister_event,
 	},
 	{
 		.name = "memsw.max_usage_in_bytes",
@@ -3876,6 +3964,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	}
 	mem->last_scanned_child = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
+	INIT_LIST_HEAD(&mem->oom_notify);
 
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
Index: mmotm-2.6.34-Mar9/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.34-Mar9.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.34-Mar9/Documentation/cgroups/memory.txt
@@ -184,6 +184,9 @@ limits on the root cgroup.
 
 Note2: When panic_on_oom is set to "2", the whole system will panic.
 
+When oom event notifier is registered, event will be delivered.
+(See oom_control section)
+
 2. Locking
 
 The memory controller uses the following hierarchy
@@ -488,7 +491,22 @@ threshold in any direction.
 
 It's applicable for root and non-root cgroup.
 
-10. TODO
+10. OOM Control
+
+Memory controler implements oom notifier using cgroup notification
+API (See cgroups.txt). It allows to register multiple oom notification
+delivery and gets notification when oom happens.
+
+To register a notifier, application need:
+ - create an eventfd using eventfd(2)
+ - open memory.oom_control file
+ - write string like "<event_fd> <memory.oom_control>" to cgroup.event_control
+
+Application will be notifier through eventfd when oom happens.
+OOM notification doesn't work for root cgroup.
+
+
+11. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
