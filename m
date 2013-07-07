Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C72276B006C
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:33 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 13so3160354lba.30
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:32 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 14/16] vmpressure: in-kernel notifications
Date: Sun,  7 Jul 2013 11:56:54 -0400
Message-Id: <1373212616-11713-15-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@parallels.com>, Glauber Costa <glommer@openvz.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>

From: Glauber Costa <glommer@parallels.com>

During the past weeks, it became clear to us that the shrinker interface
we have right now works very well for some particular types of users,
but not that well for others. The later are usually people interested in
one-shot notifications, that were forced to adapt themselves to the
count+scan behavior of shrinkers. To do so, they had no choice than to
greatly abuse the shrinker interface producing little monsters all over.

During LSF/MM, one of the proposals that popped out during our session
was to reuse Anton Voronstsov's vmpressure for this. They are designed
for userspace consumption, but also provide a well-stablished,
cgroup-aware entry point for notifications.

This patch extends that to also support in-kernel users. Events that
should be generated for in-kernel consumption will be marked as such,
and for those, we will call a registered function instead of triggering
an eventfd notification.

Please note that due to my lack of understanding of each shrinker user,
I will stay away from converting the actual users, you are all welcome
to do so.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Acked-by: Anton Vorontsov <anton@enomsg.org>
Acked-by: Pekka Enberg <penberg@kernel.org>
Reviewed-by: Greg Thelen <gthelen@google.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/vmpressure.h |  6 ++++++
 mm/vmpressure.c            | 52 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 55 insertions(+), 3 deletions(-)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 76be077..3131e72 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -19,6 +19,9 @@ struct vmpressure {
 	/* Have to grab the lock on events traversal or modifications. */
 	struct mutex events_lock;
 
+	/* False if only kernel users want to be notified, true otherwise. */
+	bool notify_userspace;
+
 	struct work_struct work;
 };
 
@@ -36,6 +39,9 @@ extern struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css);
 extern int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 				     struct eventfd_ctx *eventfd,
 				     const char *args);
+
+extern int vmpressure_register_kernel_event(struct cgroup *cg,
+					    void (*fn)(void));
 extern void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
 					struct eventfd_ctx *eventfd);
 #else
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..e16256e 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -135,8 +135,12 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 }
 
 struct vmpressure_event {
-	struct eventfd_ctx *efd;
+	union {
+		struct eventfd_ctx *efd;
+		void (*fn)(void);
+	};
 	enum vmpressure_levels level;
+	bool kernel_event;
 	struct list_head node;
 };
 
@@ -152,12 +156,15 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 	mutex_lock(&vmpr->events_lock);
 
 	list_for_each_entry(ev, &vmpr->events, node) {
-		if (level >= ev->level) {
+		if (ev->kernel_event) {
+			ev->fn();
+		} else if (vmpr->notify_userspace && level >= ev->level) {
 			eventfd_signal(ev->efd, 1);
 			signalled = true;
 		}
 	}
 
+	vmpr->notify_userspace = false;
 	mutex_unlock(&vmpr->events_lock);
 
 	return signalled;
@@ -227,7 +234,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
 	 * we account it too.
 	 */
 	if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
-		return;
+		goto schedule;
 
 	/*
 	 * If we got here with no pages scanned, then that is an indicator
@@ -244,8 +251,15 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
 	vmpr->scanned += scanned;
 	vmpr->reclaimed += reclaimed;
 	scanned = vmpr->scanned;
+	/*
+	 * If we didn't reach this point, only kernel events will be triggered.
+	 * It is the job of the worker thread to clean this up once the
+	 * notifications are all delivered.
+	 */
+	vmpr->notify_userspace = true;
 	mutex_unlock(&vmpr->sr_lock);
 
+schedule:
 	if (scanned < vmpressure_win || work_pending(&vmpr->work))
 		return;
 	schedule_work(&vmpr->work);
@@ -328,6 +342,38 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 }
 
 /**
+ * vmpressure_register_kernel_event() - Register kernel-side notification
+ * @cg:		cgroup that is interested in vmpressure notifications
+ * @fn:		function to be called when pressure happens
+ *
+ * This function register in-kernel users interested in receiving notifications
+ * about pressure conditions. Pressure notifications will be triggered at the
+ * same time as userspace notifications (with no particular ordering relative
+ * to it).
+ *
+ * Pressure notifications are a alternative method to shrinkers and will serve
+ * well users that are interested in a one-shot notification, with a
+ * well-defined cgroup aware interface.
+ */
+int vmpressure_register_kernel_event(struct cgroup *cg, void (*fn)(void))
+{
+	struct vmpressure *vmpr = cg_to_vmpressure(cg);
+	struct vmpressure_event *ev;
+
+	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
+	if (!ev)
+		return -ENOMEM;
+
+	ev->kernel_event = true;
+	ev->fn = fn;
+
+	mutex_lock(&vmpr->events_lock);
+	list_add(&ev->node, &vmpr->events);
+	mutex_unlock(&vmpr->events_lock);
+	return 0;
+}
+
+/**
  * vmpressure_unregister_event() - Unbind eventfd from vmpressure
  * @cg:		cgroup handle
  * @cft:	cgroup control files handle
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
