Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 899CB6B00CF
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 07:28:39 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 3/3] vmpressure: limit the number of registered events
Date: Wed,  7 Aug 2013 13:28:27 +0200
Message-Id: <1375874907-22013-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
References: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>

There is no limit for the maximum number of vmpressure events registered
per memcg. This might lead to an user triggered memory depletion if a
regular user is allowed to register events.

Let's be more strict and cap the number of events that might be
registered. MAX_VMPRESSURE_EVENTS value is more or less random. The
expectation is that it should be high enough to cover reasonable
usecases while not too high to allow excessive resources consumption.
1024 events consume something like 32KB which shouldn't be a big deal
and it should be good enough.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/vmpressure.h |    2 ++
 mm/vmpressure.c            |   21 +++++++++++++++++----
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 7dc17e2..474230c 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -14,6 +14,8 @@ struct vmpressure {
 	/* The lock is used to keep the scanned/reclaimed above in sync. */
 	struct spinlock sr_lock;
 
+	/* Number of registered events. */
+	unsigned int events_count;
 	/* The list of vmpressure_event structs. */
 	struct list_head events;
 	/* Have to grab the lock on events traversal or modifications. */
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 0c1e37d..bc9d546 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -281,6 +281,9 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
 	vmpressure(gfp, memcg, vmpressure_win, 0);
 }
 
+/* Maximum number of events registered per group */
+#define MAX_VMPRESSURE_EVENTS 1024
+
 /**
  * vmpressure_register_event() - Bind vmpressure notifications to an eventfd
  * @cg:		cgroup that is interested in vmpressure notifications
@@ -304,6 +307,7 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 	struct vmpressure *vmpr = cg_to_vmpressure(cg);
 	struct vmpressure_event *ev;
 	int level;
+	int ret = 0;
 
 	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
 		if (!strcmp(vmpressure_str_levels[level], args))
@@ -313,18 +317,26 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 	if (level >= VMPRESSURE_NUM_LEVELS)
 		return -EINVAL;
 
+	mutex_lock(&vmpr->events_lock);
+	if (vmpr->events_count == MAX_VMPRESSURE_EVENTS) {
+		ret = -ENOSPC;
+		goto unlock;
+	}
 	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
-	if (!ev)
-		return -ENOMEM;
+	if (!ev) {
+		ret = -ENOMEM;
+		goto unlock;
+	}
 
 	ev->efd = eventfd;
 	ev->level = level;
 
-	mutex_lock(&vmpr->events_lock);
+	vmpr->events_count++;
 	list_add(&ev->node, &vmpr->events);
+unlock:
 	mutex_unlock(&vmpr->events_lock);
 
-	return 0;
+	return ret;
 }
 
 /**
@@ -351,6 +363,7 @@ void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
 	list_for_each_entry(ev, &vmpr->events, node) {
 		if (ev->efd != eventfd)
 			continue;
+		vmpr->events_count--;
 		list_del(&ev->node);
 		kfree(ev);
 		break;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
