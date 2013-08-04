Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A35C26B0037
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 12:07:40 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id hu16so545996qab.10
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 09:07:39 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/5] cgroup, memcg: move cgroup->event_list[_lock] and event callbacks into memcg
Date: Sun,  4 Aug 2013 12:07:25 -0400
Message-Id: <1375632446-2581-5-git-send-email-tj@kernel.org>
In-Reply-To: <1375632446-2581-1-git-send-email-tj@kernel.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

cgroup_event is being moved from cgroup core to memcg and the
implementation is already moved by the previous patch.  This patch
moves the data fields and callbacks.

* cgroup->event_list[_lock] are moved to mem_cgroup.

* cftype->[un]register_event() are moved to cgroup_event.  This makes
  it impossible for individual cftype definitions to specify their
  event callbacks.  This is worked around by simply hard-coding
  filename to event callback mapping in cgroup_write_event_control().
  This is awkward and inflexible, which is actually desirable given
  that we don't want to grow more usages of this feature.

* eventfd_ctx declaration is removed from cgroup.h, which makes
  vmpressure.h miss eventfd_ctx declaration.  Include eventfd.h from
  vmpressure.h.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
---
 include/linux/cgroup.h     | 24 ---------------
 include/linux/vmpressure.h |  1 +
 kernel/cgroup.c            |  2 --
 mm/memcontrol.c            | 75 ++++++++++++++++++++++++++++++++--------------
 4 files changed, 54 insertions(+), 48 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 2ac1021..e33eb7b 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -29,7 +29,6 @@ struct cgroup_subsys;
 struct inode;
 struct cgroup;
 struct css_id;
-struct eventfd_ctx;
 
 extern int cgroup_init_early(void);
 extern int cgroup_init(void);
@@ -233,10 +232,6 @@ struct cgroup {
 	struct work_struct destroy_work;
 	atomic_t css_kill_cnt;
 
-	/* List of events which userspace want to receive */
-	struct list_head event_list;
-	spinlock_t event_list_lock;
-
 	/* directory xattrs */
 	struct simple_xattrs xattrs;
 };
@@ -500,25 +495,6 @@ struct cftype {
 	int (*trigger)(struct cgroup_subsys_state *css, unsigned int event);
 
 	int (*release)(struct inode *inode, struct file *file);
-
-	/*
-	 * register_event() callback will be used to add new userspace
-	 * waiter for changes related to the cftype. Implement it if
-	 * you want to provide this functionality. Use eventfd_signal()
-	 * on eventfd to send notification to userspace.
-	 */
-	int (*register_event)(struct cgroup_subsys_state *css,
-			      struct cftype *cft, struct eventfd_ctx *eventfd,
-			      const char *args);
-	/*
-	 * unregister_event() callback will be called when userspace
-	 * closes the eventfd or on cgroup removing.
-	 * This callback must be implemented, if you want provide
-	 * notification functionality.
-	 */
-	void (*unregister_event)(struct cgroup_subsys_state *css,
-				 struct cftype *cft,
-				 struct eventfd_ctx *eventfd);
 };
 
 /*
diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index b239482..324ea7a 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -7,6 +7,7 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/cgroup.h>
+#include <linux/eventfd.h>
 
 struct vmpressure {
 	unsigned long scanned;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a0b5e22..2bc45d3 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1352,8 +1352,6 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->pidlists);
 	mutex_init(&cgrp->pidlist_mutex);
 	cgrp->dummy_css.cgroup = cgrp;
-	INIT_LIST_HEAD(&cgrp->event_list);
-	spin_lock_init(&cgrp->event_list_lock);
 	simple_xattrs_init(&cgrp->xattrs);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3700b65..e988bf1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -260,6 +260,22 @@ struct cgroup_event {
 	 */
 	struct list_head list;
 	/*
+	 * register_event() callback will be used to add new userspace
+	 * waiter for changes related to this event.  Use eventfd_signal()
+	 * on eventfd to send notification to userspace.
+	 */
+	int (*register_event)(struct cgroup_subsys_state *css,
+			      struct cftype *cft, struct eventfd_ctx *eventfd,
+			      const char *args);
+	/*
+	 * unregister_event() callback will be called when userspace closes
+	 * the eventfd or on cgroup removing.  This callback must be set,
+	 * if you want provide notification functionality.
+	 */
+	void (*unregister_event)(struct cgroup_subsys_state *css,
+				 struct cftype *cft,
+				 struct eventfd_ctx *eventfd);
+	/*
 	 * All fields below needed to unregister event when
 	 * userspace closes eventfd.
 	 */
@@ -372,6 +388,10 @@ struct mem_cgroup {
 	atomic_t	numainfo_updating;
 #endif
 
+	/* List of events which userspace want to receive */
+	struct list_head event_list;
+	spinlock_t event_list_lock;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
@@ -5970,7 +5990,7 @@ static void cgroup_event_remove(struct work_struct *work)
 
 	remove_wait_queue(event->wqh, &event->wait);
 
-	event->cft->unregister_event(css, event->cft, event->eventfd);
+	event->unregister_event(css, event->cft, event->eventfd);
 
 	/* Notify userspace the event is going away. */
 	eventfd_signal(event->eventfd, 1);
@@ -5990,7 +6010,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 {
 	struct cgroup_event *event = container_of(wait,
 			struct cgroup_event, wait);
-	struct cgroup *cgrp = event->css->cgroup;
+	struct mem_cgroup *memcg = mem_cgroup_from_css(event->css);
 	unsigned long flags = (unsigned long)key;
 
 	if (flags & POLLHUP) {
@@ -6003,7 +6023,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 		 * side will require wqh->lock via remove_wait_queue(),
 		 * which we hold.
 		 */
-		spin_lock(&cgrp->event_list_lock);
+		spin_lock(&memcg->event_list_lock);
 		if (!list_empty(&event->list)) {
 			list_del_init(&event->list);
 			/*
@@ -6012,7 +6032,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 			 */
 			schedule_work(&event->remove);
 		}
-		spin_unlock(&cgrp->event_list_lock);
+		spin_unlock(&memcg->event_list_lock);
 	}
 
 	return 0;
@@ -6037,6 +6057,7 @@ static void cgroup_event_ptable_queue_proc(struct file *file,
 static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 				      struct cftype *cft, const char *buffer)
 {
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct cgroup *cgrp = css->cgroup;
 	struct cgroup_event *event;
 	struct cgroup *cgrp_cfile;
@@ -6104,13 +6125,30 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 		goto out_put_cfile;
 	}
 
-	if (!event->cft->register_event || !event->cft->unregister_event) {
+	/*
+	 * Determine the event callbacks and set them in @event.  This used
+	 * to be done via struct cftype but cgroup core no longer knows
+	 * about these events.  The following is crude but the whole thing
+	 * is for compatibility anyway.
+	 */
+	if (!strcmp(event->cft->name, "usage_in_bytes")) {
+		event->register_event = mem_cgroup_usage_register_event;
+		event->unregister_event = mem_cgroup_usage_unregister_event;
+	} else if (!strcmp(event->cft->name, "oom_control")) {
+		event->register_event = mem_cgroup_oom_register_event;
+		event->unregister_event = mem_cgroup_oom_unregister_event;
+	} else if (!strcmp(event->cft->name, "pressure_level")) {
+		event->register_event = vmpressure_register_event;
+		event->unregister_event = vmpressure_unregister_event;
+	} else if (!strcmp(event->cft->name, "memsw.usage_in_bytes")) {
+		event->register_event = mem_cgroup_usage_register_event;
+		event->unregister_event = mem_cgroup_usage_unregister_event;
+	} else {
 		ret = -EINVAL;
 		goto out_put_cfile;
 	}
 
-	ret = event->cft->register_event(css, event->cft,
-			event->eventfd, buffer);
+	ret = event->register_event(css, event->cft, event->eventfd, buffer);
 	if (ret)
 		goto out_put_cfile;
 
@@ -6123,9 +6161,9 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	 */
 	dget(cgrp->dentry);
 
-	spin_lock(&cgrp->event_list_lock);
-	list_add(&event->list, &cgrp->event_list);
-	spin_unlock(&cgrp->event_list_lock);
+	spin_lock(&memcg->event_list_lock);
+	list_add(&event->list, &memcg->event_list);
+	spin_unlock(&memcg->event_list_lock);
 
 	fput(cfile);
 	fput(efile);
@@ -6149,8 +6187,6 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
 		.read = mem_cgroup_read,
-		.register_event = mem_cgroup_usage_register_event,
-		.unregister_event = mem_cgroup_usage_unregister_event,
 	},
 	{
 		.name = "max_usage_in_bytes",
@@ -6210,14 +6246,10 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "oom_control",
 		.read_map = mem_cgroup_oom_control_read,
 		.write_u64 = mem_cgroup_oom_control_write,
-		.register_event = mem_cgroup_oom_register_event,
-		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
 	{
 		.name = "pressure_level",
-		.register_event = vmpressure_register_event,
-		.unregister_event = vmpressure_unregister_event,
 	},
 #ifdef CONFIG_NUMA
 	{
@@ -6265,8 +6297,6 @@ static struct cftype memsw_cgroup_files[] = {
 		.name = "memsw.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
 		.read = mem_cgroup_read,
-		.register_event = mem_cgroup_usage_register_event,
-		.unregister_event = mem_cgroup_usage_unregister_event,
 	},
 	{
 		.name = "memsw.max_usage_in_bytes",
@@ -6457,6 +6487,8 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
 	vmpressure_init(&memcg->vmpressure);
+	INIT_LIST_HEAD(&memcg->event_list);
+	spin_lock_init(&memcg->event_list_lock);
 
 	return &memcg->css;
 
@@ -6529,7 +6561,6 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	struct cgroup *cgrp = css->cgroup;
 	struct cgroup_event *event, *tmp;
 
 	/*
@@ -6537,12 +6568,12 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	 * Notify userspace about cgroup removing only after rmdir of cgroup
 	 * directory to avoid race between userspace and kernelspace.
 	 */
-	spin_lock(&cgrp->event_list_lock);
-	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
+	spin_lock(&memcg->event_list_lock);
+	list_for_each_entry_safe(event, tmp, &memcg->event_list, list) {
 		list_del_init(&event->list);
 		schedule_work(&event->remove);
 	}
-	spin_unlock(&cgrp->event_list_lock);
+	spin_unlock(&memcg->event_list_lock);
 
 	kmem_cgroup_css_offline(memcg);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
