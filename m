Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 5445C6B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 23:17:44 -0400 (EDT)
Date: Wed, 26 Jun 2013 23:17:12 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130626231712.4a7392a7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.cz, minchan@kernel.org, anton@enomsg.org, akpm@linux-foundation.org, kmpark@infradead.org, hyunhee.kim@samsung.com

Currently, an eventfd is notified for the level it's registered for
_plus_ higher levels.

This is a problem if an application wants to implement different
actions for different levels. For example, an application might want
to release 10% of its cache on level low, 50% on medium and 100% on
critical. To do this, an application has to register a different
eventfd for each pressure level. However, fd low is always going to
be notified and and all fds are going to be notified on level critical.

Strict mode solves this problem by strictly notifiying an eventfd
for the pressure level it registered for. This new mode is optional,
by default we still notify eventfds on higher levels too.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---

o v2

 - Improve documentation
 - Use a bit to store mode instead of a bool
 - Minor changelog changes

 Documentation/cgroups/memory.txt | 26 ++++++++++++++++++++++----
 mm/vmpressure.c                  | 26 ++++++++++++++++++++++++--
 2 files changed, 46 insertions(+), 6 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ddf4f93..412872b 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -791,6 +791,22 @@ way to trigger. Applications should do whatever they can to help the
 system. It might be too late to consult with vmstat or any other
 statistics, so it's advisable to take an immediate action.
 
+Applications can also choose between two notification modes when
+registering an eventfd for memory pressure events:
+
+When in "non-strict" mode, an eventfd is notified for the specific level
+it's registered for and higher levels. For example, an eventfd registered
+for low level is also going to be notified on medium and critical levels.
+This mode makes sense for applications interested on monitoring reclaim
+activity or implementing simple load-balacing logic. The non-strict mode
+is the default notification mode.
+
+When in "strict" mode, an eventfd is strictly notified for the pressure
+level it's registered for. For example, an eventfd registered for the low
+level event is not going to be notified when memory pressure gets into
+medium or critical levels. This allows for more complex logic based on
+the actual pressure level the system is experiencing.
+
 The events are propagated upward until the event is handled, i.e. the
 events are not pass-through. Here is what this means: for example you have
 three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
@@ -807,12 +823,14 @@ register a notification, an application must:
 
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
index 736a601..ba5c17e 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -138,8 +138,16 @@ struct vmpressure_event {
 	struct eventfd_ctx *efd;
 	enum vmpressure_levels level;
 	struct list_head node;
+	unsigned int mode;
 };
 
+#define VMPRESSURE_MODE_STRICT 1
+
+static inline bool vmpressure_mode_is_strict(const struct vmpressure_event *ev)
+{
+	return ev->mode & VMPRESSURE_MODE_STRICT;
+}
+
 static bool vmpressure_event(struct vmpressure *vmpr,
 			     unsigned long scanned, unsigned long reclaimed)
 {
@@ -153,6 +161,9 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 
 	list_for_each_entry(ev, &vmpr->events, node) {
 		if (level >= ev->level) {
+			/* strict mode ensures level == ev->level */
+			if (vmpressure_mode_is_strict(ev) && level != ev->level)
+				continue;
 			eventfd_signal(ev->efd, 1);
 			signalled = true;
 		}
@@ -292,7 +303,7 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
  * infrastructure, so that the notifications will be delivered to the
  * @eventfd. The @args parameter is a string that denotes pressure level
  * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
- * "critical").
+ * "critical") and optionally a different operating mode (i.e. "strict")
  *
  * This function should not be used directly, just pass it to (struct
  * cftype).register_event, and then cgroup core will handle everything by
@@ -303,22 +314,33 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 {
 	struct vmpressure *vmpr = cg_to_vmpressure(cg);
 	struct vmpressure_event *ev;
+	unsigned int mode = 0;
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
+		mode |= VMPRESSURE_MODE_STRICT;
+	}
+
 	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
 	if (!ev)
 		return -ENOMEM;
 
 	ev->efd = eventfd;
 	ev->level = level;
+	ev->mode = mode;
 
 	mutex_lock(&vmpr->events_lock);
 	list_add(&ev->node, &vmpr->events);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
