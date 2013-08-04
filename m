Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 234126B0038
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 12:07:42 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id hu16so546003qab.10
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 09:07:41 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/5] memcg: rename cgroup_event to mem_cgroup_event
Date: Sun,  4 Aug 2013 12:07:26 -0400
Message-Id: <1375632446-2581-6-git-send-email-tj@kernel.org>
In-Reply-To: <1375632446-2581-1-git-send-email-tj@kernel.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

cgroup_event is only available in memcg now.  Let's brand it that way.
While at it, add a comment encouraging deprecation of the feature and
remove the respective section from cgroup documentation.

This patch is cosmetic.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 Documentation/cgroups/cgroups.txt | 19 -------------
 mm/memcontrol.c                   | 57 +++++++++++++++++++++++++--------------
 2 files changed, 37 insertions(+), 39 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 638bf17..ca5aee9 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -472,25 +472,6 @@ you give a subsystem a name.
 The name of the subsystem appears as part of the hierarchy description
 in /proc/mounts and /proc/<pid>/cgroups.
 
-2.4 Notification API
---------------------
-
-There is mechanism which allows to get notifications about changing
-status of a cgroup.
-
-To register a new notification handler you need to:
- - create a file descriptor for event notification using eventfd(2);
- - open a control file to be monitored (e.g. memory.usage_in_bytes);
- - write "<event_fd> <control_fd> <args>" to cgroup.event_control.
-   Interpretation of args is defined by control file implementation;
-
-eventfd will be woken up by control file implementation or when the
-cgroup is removed.
-
-To unregister a notification handler just close eventfd.
-
-NOTE: Support of notifications should be implemented for the control
-file. See documentation for the subsystem.
 
 3. Kernel API
 =============
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e988bf1..240ae72 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -242,7 +242,7 @@ struct mem_cgroup_eventfd_list {
 /*
  * cgroup_event represents events which userspace want to receive.
  */
-struct cgroup_event {
+struct mem_cgroup_event {
 	/*
 	 * css which the event belongs to.
 	 */
@@ -5977,14 +5977,27 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 #endif
 
 /*
+ * DO NOT USE IN NEW FILES.
+ *
+ * "cgroup.event_control" implementation.
+ *
+ * This is way over-engineered.  It tries to support fully configureable
+ * events for each user.  Such level of flexibility is completely
+ * unnecessary especially in the light of the planned unified hierarchy.
+ *
+ * Please deprecate this and replace with something simpler if at all
+ * possible.
+ */
+
+/*
  * Unregister event and free resources.
  *
  * Gets called from workqueue.
  */
-static void cgroup_event_remove(struct work_struct *work)
+static void memcg_event_remove(struct work_struct *work)
 {
-	struct cgroup_event *event = container_of(work, struct cgroup_event,
-			remove);
+	struct mem_cgroup_event *event = container_of(work,
+					struct mem_cgroup_event, remove);
 	struct cgroup_subsys_state *css = event->css;
 	struct cgroup *cgrp = css->cgroup;
 
@@ -6005,11 +6018,11 @@ static void cgroup_event_remove(struct work_struct *work)
  *
  * Called with wqh->lock held and interrupts disabled.
  */
-static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
-		int sync, void *key)
+static int memcg_event_wake(wait_queue_t *wait, unsigned mode,
+			    int sync, void *key)
 {
-	struct cgroup_event *event = container_of(wait,
-			struct cgroup_event, wait);
+	struct mem_cgroup_event *event =
+		container_of(wait, struct mem_cgroup_event, wait);
 	struct mem_cgroup *memcg = mem_cgroup_from_css(event->css);
 	unsigned long flags = (unsigned long)key;
 
@@ -6038,28 +6051,30 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 	return 0;
 }
 
-static void cgroup_event_ptable_queue_proc(struct file *file,
+static void memcg_event_ptable_queue_proc(struct file *file,
 		wait_queue_head_t *wqh, poll_table *pt)
 {
-	struct cgroup_event *event = container_of(pt,
-			struct cgroup_event, pt);
+	struct mem_cgroup_event *event =
+		container_of(pt, struct mem_cgroup_event, pt);
 
 	event->wqh = wqh;
 	add_wait_queue(wqh, &event->wait);
 }
 
 /*
+ * DO NOT USE IN NEW FILES.
+ *
  * Parse input and register new memcg event handler.
  *
  * Input must be in format '<event_fd> <control_fd> <args>'.
  * Interpretation of args is defined by control file implementation.
  */
-static int cgroup_write_event_control(struct cgroup_subsys_state *css,
-				      struct cftype *cft, const char *buffer)
+static int memcg_write_event_control(struct cgroup_subsys_state *css,
+				     struct cftype *cft, const char *buffer)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct cgroup *cgrp = css->cgroup;
-	struct cgroup_event *event;
+	struct mem_cgroup_event *event;
 	struct cgroup *cgrp_cfile;
 	unsigned int efd, cfd;
 	struct file *efile;
@@ -6082,9 +6097,9 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 		return -ENOMEM;
 	event->css = css;
 	INIT_LIST_HEAD(&event->list);
-	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
-	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
-	INIT_WORK(&event->remove, cgroup_event_remove);
+	init_poll_funcptr(&event->pt, memcg_event_ptable_queue_proc);
+	init_waitqueue_func_entry(&event->wait, memcg_event_wake);
+	INIT_WORK(&event->remove, memcg_event_remove);
 
 	efile = eventfd_fget(efd);
 	if (IS_ERR(efile)) {
@@ -6130,6 +6145,8 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	 * to be done via struct cftype but cgroup core no longer knows
 	 * about these events.  The following is crude but the whole thing
 	 * is for compatibility anyway.
+	 *
+	 * DO NOT ADD NEW FILES.
 	 */
 	if (!strcmp(event->cft->name, "usage_in_bytes")) {
 		event->register_event = mem_cgroup_usage_register_event;
@@ -6227,8 +6244,8 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_hierarchy_read,
 	},
 	{
-		.name = "cgroup.event_control",
-		.write_string = cgroup_write_event_control,
+		.name = "cgroup.event_control",		/* XXX: for compat */
+		.write_string = memcg_write_event_control,
 		.flags = CFTYPE_NO_PREFIX,
 		.mode = S_IWUGO,
 	},
@@ -6561,7 +6578,7 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	struct cgroup_event *event, *tmp;
+	struct mem_cgroup_event *event, *tmp;
 
 	/*
 	 * Unregister events and notify userspace.
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
