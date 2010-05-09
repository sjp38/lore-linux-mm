Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D615A6200BD
	for <linux-mm@kvack.org>; Sat,  8 May 2010 20:11:27 -0400 (EDT)
Received: by fxm7 with SMTP id 7so830564fxm.14
        for <linux-mm@kvack.org>; Sat, 08 May 2010 17:11:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH v2] cgroups: make cftype.unregister_event() void-returning
Date: Sun,  9 May 2010 03:10:22 +0300
Message-Id: <1273363822-7796-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, containers@lists.linux-foundation.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Phil Carmody <ext-phil.2.carmody@nokia.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Since we unable to handle error returned by cftype.unregister_event()
properly, let's make the callback void-returning.

mem_cgroup_unregister_event() has been rewritten to be "never fail"
function. On mem_cgroup_usage_register_event() we save old buffer
for thresholds array and reuse it in mem_cgroup_usage_unregister_event()
to avoid allocation.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
Changelog:

* v1 -> v2
  - Fix memory leak.

---
 include/linux/cgroup.h |    2 +-
 kernel/cgroup.c        |    1 -
 mm/memcontrol.c        |   65 ++++++++++++++++++++++++++++++-----------------
 3 files changed, 42 insertions(+), 26 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8f78073..0c62160 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -397,7 +397,7 @@ struct cftype {
 	 * This callback must be implemented, if you want provide
 	 * notification functionality.
 	 */
-	int (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
+	void (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
 			struct eventfd_ctx *eventfd);
 };
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 06dbf97..6675e8c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2988,7 +2988,6 @@ static void cgroup_event_remove(struct work_struct *work)
 			remove);
 	struct cgroup *cgrp = event->cgrp;
 
-	/* TODO: check return code */
 	event->cft->unregister_event(cgrp, event->cft, event->eventfd);
 
 	eventfd_ctx_put(event->eventfd);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8cb2722..a6d2a4c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -226,9 +226,19 @@ struct mem_cgroup {
 	/* thresholds for memory usage. RCU-protected */
 	struct mem_cgroup_threshold_ary *thresholds;
 
+	/*
+	 * Preallocated buffer to be used in mem_cgroup_unregister_event()
+	 * to make it "never fail".
+	 * It must be able to store at least thresholds->size - 1 entries.
+	 */
+	struct mem_cgroup_threshold_ary *__thresholds;
+
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_threshold_ary *memsw_thresholds;
 
+	/* the same as __thresholds, but for memsw_thresholds */
+	struct mem_cgroup_threshold_ary *__memsw_thresholds;
+
 	/* For oom notifier event fd */
 	struct list_head oom_notify;
 
@@ -3575,17 +3585,27 @@ static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
 	else
 		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
 
-	/* To be sure that nobody uses thresholds before freeing it */
+	/* To be sure that nobody uses thresholds */
 	synchronize_rcu();
 
-	kfree(thresholds);
+	/*
+	 * Free old preallocated buffer and use thresholds as new
+	 * preallocated buffer.
+	 */
+	if (type == _MEM) {
+		kfree(memcg->__thresholds);
+		memcg->__thresholds = thresholds;
+	} else {
+		kfree(memcg->__memsw_thresholds);
+		memcg->__memsw_thresholds = thresholds;
+	}
 unlock:
 	mutex_unlock(&memcg->thresholds_lock);
 
 	return ret;
 }
 
-static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
+static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
@@ -3593,7 +3613,7 @@ static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	int type = MEMFILE_TYPE(cft->private);
 	u64 usage;
 	int size = 0;
-	int i, j, ret = 0;
+	int i, j;
 
 	mutex_lock(&memcg->thresholds_lock);
 	if (type == _MEM)
@@ -3620,20 +3640,19 @@ static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 			size++;
 	}
 
+	/* Use preallocated buffer for new array of thresholds */
+	if (type == _MEM)
+		thresholds_new = memcg->__thresholds;
+	else
+		thresholds_new = memcg->__memsw_thresholds;
+
 	/* Set thresholds array to NULL if we don't have thresholds */
 	if (!size) {
+		kfree(thresholds_new);
 		thresholds_new = NULL;
-		goto assign;
+		goto swap_buffers;
 	}
 
-	/* Allocate memory for new array of thresholds */
-	thresholds_new = kmalloc(sizeof(*thresholds_new) +
-			size * sizeof(struct mem_cgroup_threshold),
-			GFP_KERNEL);
-	if (!thresholds_new) {
-		ret = -ENOMEM;
-		goto unlock;
-	}
 	thresholds_new->size = size;
 
 	/* Copy thresholds and find current threshold */
@@ -3654,20 +3673,20 @@ static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 		j++;
 	}
 
-assign:
-	if (type == _MEM)
+swap_buffers:
+	/* Swap thresholds array and preallocated buffer */
+	if (type == _MEM) {
+		memcg->__thresholds = thresholds;
 		rcu_assign_pointer(memcg->thresholds, thresholds_new);
-	else
+	} else {
+		memcg->__memsw_thresholds = thresholds;
 		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
+	}
 
-	/* To be sure that nobody uses thresholds before freeing it */
+	/* To be sure that nobody uses thresholds */
 	synchronize_rcu();
 
-	kfree(thresholds);
-unlock:
 	mutex_unlock(&memcg->thresholds_lock);
-
-	return ret;
 }
 
 static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
@@ -3695,7 +3714,7 @@ static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
 	return 0;
 }
 
-static int mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
+static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
@@ -3714,8 +3733,6 @@ static int mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 	}
 
 	mutex_unlock(&memcg_oom_mutex);
-
-	return 0;
 }
 
 static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
