Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 5F0A06B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 07:30:13 -0400 (EDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOJ001DSBY3ZII0@mailout3.samsung.com> for linux-mm@kvack.org;
 Mon, 17 Jun 2013 20:30:11 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
Subject: [PATCH v3] memcg: event control at vmpressure.
Date: Mon, 17 Jun 2013 20:30:11 +0900
Message-id: <008a01ce6b4e$079b6a50$16d23ef0$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, 'Michal Hocko' <mhocko@suse.cz>, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name
Cc: 'Kyungmin Park' <kyungmin.park@samsung.com>

In the original vmpressure, all levels of events less than or equal to
the current pressure level are signaled whenever there is a reclaim
activity. This becomes overheads to user space module and also increases
power consumption if there is somebody to listen to it. This patch provides
options to trigger only the current level of the event when the pressure
level changes. This trigger option can be set when registering each event by writing
a trigger option, "edge" or "always", next to the string of levels.
"edge" means that the event of the current pressure level is signaled only when
the pressure level is changed. "always" means that events are triggered
whenever there is a reclaim process. To keep backward compatibility,
"always" is set by default if nothing is input as an option.
Each event can have different option. For example, "low" level uses "always"
trigger option to see reclaim activity at user space while "medium"/"critical"
uses "edge" to do an important job like killing tasks only once.

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/cgroups/memory.txt |   13 +++++++++++--
 include/linux/vmpressure.h       |    2 ++
 mm/vmpressure.c                  |   25 ++++++++++++++++++++-----
 3 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ddf4f93..f5f91fb 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -791,6 +791,14 @@ way to trigger. Applications should do whatever they can to help the
 system. It might be too late to consult with vmstat or any other
 statistics, so it's advisable to take an immediate action.
 
+All events (<= current pressure level) can be triggered whenever there is a
+reclaim activity or only current pressure level can be triggered when
+the pressure level changes. Trigger option is decided by writing it
+next to level. The event whose trigger option is "always" is triggered
+whenever there is a reclaim process. If "edge" is set, an event
+corresponding to the current pressure level is triggered only when the level
+is changed. If the trigger option is not set, "always" is set by default.
+
 The events are propagated upward until the event is handled, i.e. the
 events are not pass-through. Here is what this means: for example you have
 three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
@@ -807,7 +815,8 @@ register a notification, an application must:
 
 - create an eventfd using eventfd(2);
 - open memory.pressure_level;
-- write string like "<event_fd> <fd of memory.pressure_level> <level>"
+- write string like
+	"<event_fd> <fd of memory.pressure_level> <level> <trigger_option>"
   to cgroup.event_control.
 
 Application will be notified through eventfd when memory pressure is at
@@ -823,7 +832,7 @@ Test:
    # cd /sys/fs/cgroup/memory/
    # mkdir foo
    # cd foo
-   # cgroup_event_listener memory.pressure_level low &
+   # cgroup_event_listener memory.pressure_level low "edge" &
    # echo 8000000 > memory.limit_in_bytes
    # echo 8000000 > memory.memsw.limit_in_bytes
    # echo $$ > tasks
diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 76be077..51aed1f 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -20,6 +20,8 @@ struct vmpressure {
 	struct mutex events_lock;
 
 	struct work_struct work;
+
+	int last_level;
 };
 
 struct mem_cgroup;
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..a18fdb3 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -137,6 +137,7 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 struct vmpressure_event {
 	struct eventfd_ctx *efd;
 	enum vmpressure_levels level;
+	bool edge_trigger;
 	struct list_head node;
 };
 
@@ -150,14 +151,16 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 	level = vmpressure_calc_level(scanned, reclaimed);
 
 	mutex_lock(&vmpr->events_lock);
-
 	list_for_each_entry(ev, &vmpr->events, node) {
 		if (level >= ev->level) {
+			if (ev->edge_trigger && (level == vmpr->last_level
+				|| level != ev->level))
+				continue;
 			eventfd_signal(ev->efd, 1);
 			signalled = true;
 		}
 	}
-
+	vmpr->last_level = level;
 	mutex_unlock(&vmpr->events_lock);
 
 	return signalled;
@@ -290,9 +293,11 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
  *
  * This function associates eventfd context with the vmpressure
  * infrastructure, so that the notifications will be delivered to the
- * @eventfd. The @args parameter is a string that denotes pressure level
+ * @eventfd. The @args parameters are a string that denotes pressure level
  * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
- * "critical").
+ * "critical") and a trigger option that decides whether events are triggered
+ * continuously or only on edge ("always" or "edge" if "edge", only the current
+ * pressure level is triggered when the pressure level changes.
  *
  * This function should not be used directly, just pass it to (struct
  * cftype).register_event, and then cgroup core will handle everything by
@@ -303,10 +308,14 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 {
 	struct vmpressure *vmpr = cg_to_vmpressure(cg);
 	struct vmpressure_event *ev;
+	char strlevel[32], strtrigger[32] = "always";
 	int level;
 
+	if ((sscanf(args, "%s %s\n", strlevel, strtrigger) > 2))
+		return -EINVAL;
+
 	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
-		if (!strcmp(vmpressure_str_levels[level], args))
+		if (!strcmp(vmpressure_str_levels[level], strlevel))
 			break;
 	}
 
@@ -320,6 +329,11 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 	ev->efd = eventfd;
 	ev->level = level;
 
+	if (!strcmp(strtrigger, "edge"))
+		ev->edge_trigger = true;
+	else
+		ev->edge_trigger = false;
+
 	mutex_lock(&vmpr->events_lock);
 	list_add(&ev->node, &vmpr->events);
 	mutex_unlock(&vmpr->events_lock);
@@ -371,4 +385,5 @@ void vmpressure_init(struct vmpressure *vmpr)
 	mutex_init(&vmpr->events_lock);
 	INIT_LIST_HEAD(&vmpr->events);
 	INIT_WORK(&vmpr->work, vmpressure_work_fn);
+	vmpr->last_level = -1;
 }
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
