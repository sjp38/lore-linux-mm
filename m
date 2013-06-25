Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id D11EF6B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 17:51:36 -0400 (EDT)
Date: Tue, 25 Jun 2013 17:51:29 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH] vmpressure: implement strict mode
Message-ID: <20130625175129.7c0d79e1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.cz, minchan@kernel.org, anton@enomsg.org, akpm@linux-foundation.org

Currently, applications are notified for the level they registered for
_plus_ higher levels.

This is a problem if the application wants to implement different
actions for different levels. For example, an application might want
to release 10% of its cache on level low, 50% on medium and 100% on
critical. To do this, the application has to register a different fd
for each event. However, fd low is always going to be notified and
and all fds are going to be notified on level critical.

Strict mode solves this problem by strictly notifiying the event
an fd has registered for. It's optional. By default we still notify
on higher levels.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---

PS: I'm following the discussion on the event storm problem, but I believe
    strict mode is orthogonal to what has been suggested (although the
    patches conflict)

 Documentation/cgroups/memory.txt | 10 ++++++----
 mm/vmpressure.c                  | 19 +++++++++++++++++--
 2 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ddf4f93..3c589cf 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -807,12 +807,14 @@ register a notification, an application must:
 
 - create an eventfd using eventfd(2);
 - open memory.pressure_level;
-- write string like "<event_fd> <fd of memory.pressure_level> <level>"
+- write string like "<event_fd> <fd of memory.pressure_level> <level> [strict]"
   to cgroup.event_control.
 
-Application will be notified through eventfd when memory pressure is at
-the specific level (or higher). Read/write operations to
-memory.pressure_level are no implemented.
+Applications will be notified through eventfd when memory pressure is at
+the specific level or higher. If strict is passed, then applications
+will only be notified when memory pressure reaches the specified level.
+
+Read/write operations to memory.pressure_level are no implemented.
 
 Test:
 
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..6289ede 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -137,6 +137,7 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 struct vmpressure_event {
 	struct eventfd_ctx *efd;
 	enum vmpressure_levels level;
+	bool strict_mode;
 	struct list_head node;
 };
 
@@ -153,6 +154,9 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 
 	list_for_each_entry(ev, &vmpr->events, node) {
 		if (level >= ev->level) {
+			/* strict mode ensures level == ev->level */
+			if (ev->strict_mode && level != ev->level)
+				continue;
 			eventfd_signal(ev->efd, 1);
 			signalled = true;
 		}
@@ -292,7 +296,7 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
  * infrastructure, so that the notifications will be delivered to the
  * @eventfd. The @args parameter is a string that denotes pressure level
  * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
- * "critical").
+ * "critical") and optionally a different operating mode (i.e. "strict")
  *
  * This function should not be used directly, just pass it to (struct
  * cftype).register_event, and then cgroup core will handle everything by
@@ -303,22 +307,33 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 {
 	struct vmpressure *vmpr = cg_to_vmpressure(cg);
 	struct vmpressure_event *ev;
+	bool smode = false;
+	const char *p;
 	int level;
 
 	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
-		if (!strcmp(vmpressure_str_levels[level], args))
+		p = vmpressure_str_levels[level];
+		if (!strncmp(p, args, strlen(p)))
 			break;
 	}
 
 	if (level >= VMPRESSURE_NUM_LEVELS)
 		return -EINVAL;
 
+	p = strchr(args, ' ');
+	if (p) {
+		if (strncmp(++p, "strict", 6))
+			return -EINVAL;
+		smode = true;
+	}
+
 	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
 	if (!ev)
 		return -ENOMEM;
 
 	ev->efd = eventfd;
 	ev->level = level;
+	ev->strict_mode = smode;
 
 	mutex_lock(&vmpr->events_lock);
 	list_add(&ev->node, &vmpr->events);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
