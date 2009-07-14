Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D653A6B005D
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 19:49:30 -0400 (EDT)
From: Vladislav Buzov <vbuzov@embeddedalley.com>
Subject: [PATCH 2/2] Memory usage limit notification addition to memcg (v3)
Date: Mon, 13 Jul 2009 17:16:21 -0700
Message-Id: <1247530581-31416-3-git-send-email-vbuzov@embeddedalley.com>
In-Reply-To: <1247530581-31416-2-git-send-email-vbuzov@embeddedalley.com>
References: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
 <1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>
 <1247530581-31416-2-git-send-email-vbuzov@embeddedalley.com>
Sender: owner-linux-mm@kvack.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Linux Containers Mailing List <containers@lists.linux-foundation.org>, Linux memory management list <linux-mm@kvack.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vladislav Buzov <vbuzov@embeddedalley.com>
List-ID: <linux-mm.kvack.org>

This patch updates the Memory Controller Control Group to add a
configurable memory usage limit notification. The feature was
presented at the April 2009 Embedded Linux Conference.

Signed-off-by: Vladislav Buzov <vbuzov@embeddedalley.com>
Signed-off-by: Dan Malek <dan@embeddedalley.com>
---
 Documentation/cgroups/mem_notify.txt |  140 ++++++++++++++++++++++++++++++++++
 mm/memcontrol.c                      |  100 ++++++++++++++++++++++++-
 2 files changed, 239 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/cgroups/mem_notify.txt

diff --git a/Documentation/cgroups/mem_notify.txt b/Documentation/cgroups/mem_notify.txt
new file mode 100644
index 0000000..94be3f3
--- /dev/null
+++ b/Documentation/cgroups/mem_notify.txt
@@ -0,0 +1,140 @@
+
+Memory Limit Notification
+
+Attempts have been made in the past to provide a mechanism for
+the notification to processes (task, an address space) when memory
+usage is approaching a high limit.  The intention is that it gives
+the application an opportunity to release some memory and continue
+operation rather than be OOM killed.  The CE Linux Forum requested
+a more contemporary implementation, and this is the result.
+
+The memory limit notification is an extension to the existing Memory
+Resource Controller.  Please read memory.txt in this directory to
+understand its operation before continuing here.
+
+1. Operation
+
+When the Memory Controller cgroup file system is mounted, the following
+files will appear:
+
+	memory.notify_threshold_in_bytes
+	memory.notify_threshold_lowait
+
+The notification is based upon reaching a threshold below the Memory
+Resource Controller limit (memory.limit_in_bytes).  The threshold
+represents the minimal number of bytes that should be available under
+the limit.  When the controller group is created, the threshold is set
+to zero which triggers notification when the Memory Resource Controller
+limit is reached.
+
+The threshold may be set by writing to memory.notify_threshold_in_bytes,
+such as:
+
+	echo 10M > memory.notify_threshold_in_bytes
+
+The current number of available bytes may be computed at any time as a
+difference between the memory.limit_in_bytes and memory.usage_in_bytes.
+
+The memory.notify_threshold_lowait is a blocking read file.  The read will
+block until one of four conditions occurs:
+
+    - The amount of available memory is equal or less than the threshold
+      defined in memory.notify_threshold_in_bytes
+    - The memory.notify_threshold_lowait file is written with any value (debug)
+    - A thread is moved to another controller group
+    - The cgroup is destroyed or forced empty (memory.force_empty)
+
+
+1.1 Example Usage
+
+An application must be designed to properly take advantage of this
+memory threshold notification feature.  It is a powerful management component
+of some operating systems and embedded devices that must provide
+highly available and reliable computing services.  The application works
+in conjunction with information provided by the operating system to
+control limited resource usage.  Since many programmers still think
+memory is infinite and never check the return value from malloc(), it
+may come as a surprise that such mechanisms have been utilized long ago.
+
+A typical application will be multithreaded, with one thread either
+polling or waiting for the notification event.  When the event occurs,
+the thread will take whatever action is appropriate within the application
+design.  This could be actually running a garbage collection algorithm
+or to simply signal other processing threads they must do something to
+reduce their memory usage.  The notification thread will then be required
+to poll the actual usage until the low limit of its choosing is met,
+at which time the reclaim of memory can stop and the notification thread
+will wait for the next event.
+
+Internally, the application only needs to
+fopen("memory.notify_usage_in_bytes" ..) or
+fopen("memory.notify_threshold_lowait" ...), then either poll the former
+files or block read on the latter file using fread() or fscanf() as desired.
+Subtracting the value returned from either of these read function from the
+value obtained by reading memory.limit_in_bytes and further comparing it with
+the threshold obtained by reading memory.notify_threshold_in_bytes will be an
+indication of the amount of memory used over the threshold limit.
+
+2. Configuration
+
+Follow the instructions in memory.txt for the configuration and usage of
+the Memory Resource Controller cgroup.  Once this is created and tasks
+assigned, use the memory threshold notification as described here.
+
+The only action that is needed outside of the application waiting or polling
+is to set the memory.notify_threshold_in_bytes.  To set a notification to occur
+when memory usage of the cgroup reaches or exceeds 1 MByte below the limit
+can be simply done:
+
+	echo 1M > memory.notify_threshold_in_bytes
+
+This value may be read or changed at any time.  Writing a higher value once
+the Memory Resource Controller is in operation may trigger immediate
+notification if the usage is above the new threshold.  Writing a value higher
+than the Memory Controller limit will cause an error while setting the limit
+lower than the threshold will cause setting the threshold to zero.
+
+3. Debug and Testing
+
+The design of cgroups makes it easier to perform some debugging or
+monitoring tasks without modification to the application.  For example,
+a write of any value to memory.notify_threshold_lowait will wake up all
+threads waiting for notifications regardless of current memory usage.
+
+Collecting performance data about the cgroup is also simplified, as
+no application modifications are necessary.  A separate task can be
+created that will open and monitor any necessary files of the cgroup
+(such as current limits, usage and usage percentages and even when
+notification occurs).  This task can also operate outside of the cgroup,
+so its memory usage is not charged to the cgroup.
+
+4. Design
+
+The Memory Resource Controller utilizes the Resource Counter to track and manage
+the memory of the Control Group.  The Resource Counter was extended to support
+the resource usage threshold, which is the minimal difference between the
+resource limit and usage causing the notification.  For the Memory Controller
+cgroup it means a number of bytes of the memory not in use so the cgroup
+parameters may continue to be dynamically modified without the need to modify
+the notification parameters.  Otherwise, the notification threshold would have
+to also be computed and modified on any Memory Resource Controller operating
+parameter change.
+
+The cgroup file semantics are not well suited for this type of notification
+mechanism.  While applications may choose to simply poll the current
+usage at their convenience, it was also desired to have a notification
+event that would trigger when the usage attained the threshold.  The
+blocking read() was chosen, as it is the only current useful method.
+This presented the problems of "out of band" notification, when you want
+to return some exceptional status other than reaching the notification
+threshold.  In the cases listed above, the read() on the
+memory.notify_threshold_lowait file will not block and return "0" for
+the remaining size.  When this occurs, the thread must determine if the task
+has moved to a new cgroup or if the cgroup has been destroyed.  Due to
+the usage model of this cgroup, neither is likely to happen during normal
+operation of a product.
+
+Dan Malek <dan@embeddedalley.com>
+Vladislav Buzov <vbuzov@embeddedalley.com>
+Embedded Alley Solutions, Inc.
+10 July 2009
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2fa20d..3b49fd4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6,6 +6,11 @@
  * Copyright 2007 OpenVZ SWsoft Inc
  * Author: Pavel Emelianov <xemul@openvz.org>
  *
+ * Memory Limit Notification update
+ * Copyright 2009 CE Linux Forum and Embedded Alley Solutions, Inc.
+ * Author: Dan Malek <dan@embeddedalley.com>
+ * Author: Vladislav Buzov <vbuzov@embeddedalley.com>
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -180,6 +185,9 @@ struct mem_cgroup {
 	/* set when res.limit == memsw.limit */
 	bool		memsw_is_minimum;
 
+	/* tasks waiting for memory usage threshold notification */
+	wait_queue_head_t notify_threshold_wait;
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -2052,7 +2060,7 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 }
 /*
  * The user of this function is...
- * RES_LIMIT.
+ * RES_LIMIT, RES_THRESHOLD
  */
 static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			    const char *buffer)
@@ -2075,6 +2083,17 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 		else
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
+	case RES_THRESHOLD:
+		/* This function does all necessary parse...reuse it */
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		/* For memsw threshold is not implemented */
+		if (type == _MEM)
+			ret = res_counter_set_threshold(&memcg->res, val);
+		else
+			ret = -EINVAL;
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -2308,6 +2327,68 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+/*
+ * This is a blocking read operation forcing a reader to sleep unless
+ * a low memory condition occurs, someone intentionaly writes to
+ * "memory.notify_threshold_lowait" or cgroup state is changed. E.g.
+ * the cgroup is destroyed or task is moved to another cgroup.
+ */
+static u64 mem_cgroup_notify_threshold_lowait(struct cgroup *cgrp,
+					      struct cftype *cft)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	DEFINE_WAIT(notify_lowait);
+
+	/*
+	 * A memory resource usage of zero is a special case that
+	 * causes us not to sleep.  It normally happens when the
+	 * cgroup is about to be destroyed, and we don't want someone
+	 * trying to sleep on a queue that is about to go away.  This
+	 * condition can also be forced as part of testing.
+	 */
+	if (likely(mem->res.usage != 0)) {
+		prepare_to_wait(&mem->notify_threshold_wait, &notify_lowait,
+							TASK_INTERRUPTIBLE);
+
+		if (res_counter_check_under_threshold(&mem->res))
+			schedule();
+
+		finish_wait(&mem->notify_threshold_wait, &notify_lowait);
+	}
+
+	return res_counter_read_u64(&mem->res, RES_USAGE);
+}
+
+/*
+ * Memory usage threshold notification callback. Called under disabled
+ * interrupts by the memory resource counter when low memory condition
+ * occurs.
+ */
+static void mem_cgroup_res_threshold_notifier(struct res_counter *cnt)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = mem_cgroup_from_res_counter(cnt, res);
+	if (waitqueue_active(&memcg->notify_threshold_wait))
+		wake_up_locked(&memcg->notify_threshold_wait);
+}
+
+/*
+ * This is used to wake up all threads that may be hanging
+ * out waiting for a low memory condition prior to that happening.
+ * Useful for triggering the event to assist with debug of applications.
+ */
+static int mem_cgroup_notify_threshold_wake_em_up(struct cgroup *cgrp,
+						  unsigned int event)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = mem_cgroup_from_cont(cgrp);
+	if (waitqueue_active(&memcg->notify_threshold_wait))
+		wake_up(&memcg->notify_threshold_wait);
+	return 0;
+}
+
 
 static struct cftype mem_cgroup_files[] = {
 	{
@@ -2351,6 +2432,17 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_swappiness_read,
 		.write_u64 = mem_cgroup_swappiness_write,
 	},
+	{
+		.name = "notify_threshold_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_THRESHOLD),
+		.write_string = mem_cgroup_write,
+		.read_u64 = mem_cgroup_read,
+	},
+	{
+		.name = "notify_threshold_lowait",
+		.trigger = mem_cgroup_notify_threshold_wake_em_up,
+		.read_u64 = mem_cgroup_notify_threshold_lowait,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -2554,6 +2646,9 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
 
+	init_waitqueue_head(&mem->notify_threshold_wait);
+	mem->res.threshold_notifier = mem_cgroup_res_threshold_notifier;
+
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
@@ -2568,6 +2663,7 @@ static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	mem_cgroup_notify_threshold_wake_em_up(cont, 0);
 	return mem_cgroup_force_empty(mem, false);
 }
 
@@ -2597,6 +2693,8 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *old_cont,
 				struct task_struct *p)
 {
+	mem_cgroup_notify_threshold_wake_em_up(old_cont, 0);
+
 	mutex_lock(&memcg_tasklist);
 	/*
 	 * FIXME: It's better to move charges of this process from old
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
