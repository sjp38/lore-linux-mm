Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12C996B02F4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 17:22:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so27556174pfd.11
        for <linux-mm@kvack.org>; Wed, 31 May 2017 14:22:34 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id q26si17628200pge.319.2017.05.31.14.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 14:22:32 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id m17so18120952pfg.3
        for <linux-mm@kvack.org>; Wed, 31 May 2017 14:22:32 -0700 (PDT)
Date: Wed, 31 May 2017 14:22:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, vmpressure: pass-through notification support
Message-ID: <alpine.DEB.2.10.1705311421320.8946@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Anton Vorontsov <anton@enomsg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

By default, vmpressure events are not pass-through, i.e. they propagate
up through the memcg hierarchy until an event notifier is found for any
threshold level.

This presents a difficulty when a thread waiting on a read(2) for a
vmpressure event cannot distinguish between local memory pressure and
memory pressure in a descendant memcg, especially when that thread may
not control the memcg hierarchy.

Consider a user-controlled child memcg with a smaller limit than a
top-level memcg controlled by the "Activity Manager" specified in
Documentation/cgroup-v1/memory.txt.  It may register for memory pressure
notification for descendant memcgs to make a policy decision: oom kill a
low priority job, increase the limit, decrease other limits, etc.
If it registers for memory pressure notification on the top-level memcg,
it currently cannot distinguish between memory pressure in its own memcg
or a descendant memcg, which is user-controlled.

Conversely, if a user registers for memory pressure notification on their
own descendant memcg, the Activity Manager does not receive any pressure
notification for that child memcg hierarchy.  Vmpressure events are not
received for ancestor memcgs if the memcg experiencing pressure have
notifiers registered, perhaps outside the knowledge of the thread
waiting on read(2) at the top level.

Both of these are consequences of vmpressure notification not being
pass-through.

This implements a pass-through behavior for vmpressure events.  When
writing to control.event_control, vmpressure event handlers may
optionally specify a mode.  There are two new modes:

 - "hierarchy": always propagate memory pressure events up the
   hierarchy regardless if descendant memcgs have their own notifiers
   registered, and

 - "local": only receive notifications when the memcg for which the
   event is registered experiences memory pressure.

Of course, processes may register for one notification of "low,local",
for example, and another for "low".

If no mode is specified, the current behavior is maintained for
backwards compatibility.

See the change to Documentation/cgroup-v1/memory.txt for full
specification.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroup-v1/memory.txt |  47 ++++++++++----
 mm/vmpressure.c                    | 122 ++++++++++++++++++++++++++++---------
 2 files changed, 128 insertions(+), 41 deletions(-)

diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -789,23 +789,46 @@ way to trigger. Applications should do whatever they can to help the
 system. It might be too late to consult with vmstat or any other
 statistics, so it's advisable to take an immediate action.
 
-The events are propagated upward until the event is handled, i.e. the
-events are not pass-through. Here is what this means: for example you have
-three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
-and C, and suppose group C experiences some pressure. In this situation,
-only group C will receive the notification, i.e. groups A and B will not
-receive it. This is done to avoid excessive "broadcasting" of messages,
-which disturbs the system and which is especially bad if we are low on
-memory or thrashing. So, organize the cgroups wisely, or propagate the
-events manually (or, ask us to implement the pass-through events,
-explaining why would you need them.)
+By default, events are propagated upward until the event is handled, i.e. the
+events are not pass-through. For example, you have three cgroups: A->B->C. Now
+you set up an event listener on cgroups A, B and C, and suppose group C
+experiences some pressure. In this situation, only group C will receive the
+notification, i.e. groups A and B will not receive it. This is done to avoid
+excessive "broadcasting" of messages, which disturbs the system and which is
+especially bad if we are low on memory or thrashing. Group B, will receive
+notification only if there are no event listers for group C.
+
+There are three optional modes that specify different propagation behavior:
+
+ - "default": this is the default behavior specified above. This mode is the
+   same as omitting the optional mode parameter, preserved by backwards
+   compatibility.
+
+ - "hierarchy": events always propagate up to the root, similar to the default
+   behavior, except that propagation continues regardless of whether there are
+   event listeners at each level, with the "hierarchy" mode. In the above
+   example, groups A, B, and C will receive notification of memory pressure.
+
+ - "local": events are pass-through, i.e. they only receive notifications when
+   memory pressure is experienced in the memcg for which the notification is
+   registered. In the above example, group C will receive notification if
+   registered for "local" notification and the group experiences memory
+   pressure. However, group B will never receive notification, regardless if
+   there is an event listener for group C or not, if group B is registered for
+   local notification.
+
+The level and event notification mode ("hierarchy" or "local", if necessary) are
+specified by a comma-delimited string, i.e. "low,hierarchy" specifies
+hierarchical, pass-through, notification for all ancestor memcgs. Notification
+that is the default, non pass-through behavior, does not specify a mode.
+"medium,local" specifies pass-through notification for the medium level.
 
 The file memory.pressure_level is only used to setup an eventfd. To
 register a notification, an application must:
 
 - create an eventfd using eventfd(2);
 - open memory.pressure_level;
-- write string like "<event_fd> <fd of memory.pressure_level> <level>"
+- write string as "<event_fd> <fd of memory.pressure_level> <level[,mode]>"
   to cgroup.event_control.
 
 Application will be notified through eventfd when memory pressure is at
@@ -821,7 +844,7 @@ Test:
    # cd /sys/fs/cgroup/memory/
    # mkdir foo
    # cd foo
-   # cgroup_event_listener memory.pressure_level low &
+   # cgroup_event_listener memory.pressure_level low,hierarchy &
    # echo 8000000 > memory.limit_in_bytes
    # echo 8000000 > memory.memsw.limit_in_bytes
    # echo $$ > tasks
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -93,12 +93,25 @@ enum vmpressure_levels {
 	VMPRESSURE_NUM_LEVELS,
 };
 
+enum vmpressure_modes {
+	VMPRESSURE_NO_PASSTHROUGH = 0,
+	VMPRESSURE_HIERARCHY,
+	VMPRESSURE_LOCAL,
+	VMPRESSURE_NUM_MODES,
+};
+
 static const char * const vmpressure_str_levels[] = {
 	[VMPRESSURE_LOW] = "low",
 	[VMPRESSURE_MEDIUM] = "medium",
 	[VMPRESSURE_CRITICAL] = "critical",
 };
 
+static const char * const vmpressure_str_modes[] = {
+	[VMPRESSURE_NO_PASSTHROUGH] = "default",
+	[VMPRESSURE_HIERARCHY] = "hierarchy",
+	[VMPRESSURE_LOCAL] = "local",
+};
+
 static enum vmpressure_levels vmpressure_level(unsigned long pressure)
 {
 	if (pressure >= vmpressure_level_critical)
@@ -141,27 +154,31 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 struct vmpressure_event {
 	struct eventfd_ctx *efd;
 	enum vmpressure_levels level;
+	enum vmpressure_modes mode;
 	struct list_head node;
 };
 
 static bool vmpressure_event(struct vmpressure *vmpr,
-			     enum vmpressure_levels level)
+			     const enum vmpressure_levels level,
+			     bool ancestor, bool signalled)
 {
 	struct vmpressure_event *ev;
-	bool signalled = false;
+	bool ret = false;
 
 	mutex_lock(&vmpr->events_lock);
-
 	list_for_each_entry(ev, &vmpr->events, node) {
-		if (level >= ev->level) {
-			eventfd_signal(ev->efd, 1);
-			signalled = true;
-		}
+		if (ancestor && ev->mode == VMPRESSURE_LOCAL)
+			continue;
+		if (signalled && ev->mode == VMPRESSURE_NO_PASSTHROUGH)
+			continue;
+		if (level < ev->level)
+			continue;
+		eventfd_signal(ev->efd, 1);
+		ret = true;
 	}
-
 	mutex_unlock(&vmpr->events_lock);
 
-	return signalled;
+	return ret;
 }
 
 static void vmpressure_work_fn(struct work_struct *work)
@@ -170,6 +187,8 @@ static void vmpressure_work_fn(struct work_struct *work)
 	unsigned long scanned;
 	unsigned long reclaimed;
 	enum vmpressure_levels level;
+	bool ancestor = false;
+	bool signalled = false;
 
 	spin_lock(&vmpr->sr_lock);
 	/*
@@ -194,12 +213,9 @@ static void vmpressure_work_fn(struct work_struct *work)
 	level = vmpressure_calc_level(scanned, reclaimed);
 
 	do {
-		if (vmpressure_event(vmpr, level))
-			break;
-		/*
-		 * If not handled, propagate the event upward into the
-		 * hierarchy.
-		 */
+		if (vmpressure_event(vmpr, level, ancestor, signalled))
+			signalled = true;
+		ancestor = true;
 	} while ((vmpr = vmpressure_parent(vmpr)));
 }
 
@@ -326,17 +342,40 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
 	vmpressure(gfp, memcg, true, vmpressure_win, 0);
 }
 
+static enum vmpressure_levels str_to_level(const char *arg)
+{
+	enum vmpressure_levels level;
+
+	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++)
+		if (!strcmp(vmpressure_str_levels[level], arg))
+			return level;
+	return -1;
+}
+
+static enum vmpressure_modes str_to_mode(const char *arg)
+{
+	enum vmpressure_modes mode;
+
+	for (mode = 0; mode < VMPRESSURE_NUM_MODES; mode++)
+		if (!strcmp(vmpressure_str_modes[mode], arg))
+			return mode;
+	return -1;
+}
+
+#define MAX_VMPRESSURE_ARGS_LEN	(strlen("critical") + strlen("hierarchy") + 2)
+
 /**
  * vmpressure_register_event() - Bind vmpressure notifications to an eventfd
  * @memcg:	memcg that is interested in vmpressure notifications
  * @eventfd:	eventfd context to link notifications with
- * @args:	event arguments (used to set up a pressure level threshold)
+ * @args:	event arguments (pressure level threshold, optional mode)
  *
  * This function associates eventfd context with the vmpressure
  * infrastructure, so that the notifications will be delivered to the
- * @eventfd. The @args parameter is a string that denotes pressure level
- * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
- * "critical").
+ * @eventfd. The @args parameter is a comma-delimited string that denotes a
+ * pressure level threshold (one of vmpressure_str_levels, i.e. "low", "medium",
+ * or "critical") and an optional mode (one of vmpressure_str_modes, i.e.
+ * "hierarchy" or "local").
  *
  * To be used as memcg event method.
  */
@@ -345,28 +384,53 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
 {
 	struct vmpressure *vmpr = memcg_to_vmpressure(memcg);
 	struct vmpressure_event *ev;
-	int level;
+	enum vmpressure_modes mode = VMPRESSURE_NO_PASSTHROUGH;
+	enum vmpressure_levels level = -1;
+	char *spec = NULL;
+	char *token;
+	int ret = 0;
+
+	spec = kzalloc(MAX_VMPRESSURE_ARGS_LEN + 1, GFP_KERNEL);
+	if (!spec) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	strncpy(spec, args, MAX_VMPRESSURE_ARGS_LEN);
 
-	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
-		if (!strcmp(vmpressure_str_levels[level], args))
-			break;
+	/* Find required level */
+	token = strsep(&spec, ",");
+	level = str_to_level(token);
+	if (level == -1) {
+		ret = -EINVAL;
+		goto out;
 	}
 
-	if (level >= VMPRESSURE_NUM_LEVELS)
-		return -EINVAL;
+	/* Find optional mode */
+	token = strsep(&spec, ",");
+	if (token) {
+		mode = str_to_mode(token);
+		if (mode == -1) {
+			ret = -EINVAL;
+			goto out;
+		}
+	}
 
 	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
-	if (!ev)
-		return -ENOMEM;
+	if (!ev) {
+		ret = -ENOMEM;
+		goto out;
+	}
 
 	ev->efd = eventfd;
 	ev->level = level;
+	ev->mode = mode;
 
 	mutex_lock(&vmpr->events_lock);
 	list_add(&ev->node, &vmpr->events);
 	mutex_unlock(&vmpr->events_lock);
-
-	return 0;
+out:
+	kfree(spec);
+	return ret;
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
