Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 6563C6B0034
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 08:40:33 -0400 (EDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOQ00H9VTVJNY30@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 21 Jun 2013 21:40:32 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
References: 
 <CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
 <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
 <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox> <20130621091944.GC12424@dhcp22.suse.cz>
 <CAOK=xRMZTTEqX7kAUkkFU+www6jwTQw8bvw6a0p-Jfd828gyCQ@mail.gmail.com>
 <004301ce6e76$17be3220$473a9660$%kim@samsung.com>
In-reply-to: <004301ce6e76$17be3220$473a9660$%kim@samsung.com>
Subject: [PATCH v7] memcg: event control at vmpressure.
Date: Fri, 21 Jun 2013 21:40:31 +0900
Message-id: <004401ce6e7c$84252530$8c6f6f90$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Michal Hocko' <mhocko@suse.cz>

In the original vmpressure, same events could be signaled to user space until
the pressure level changes. However, for some users, these same event signals
are unnecessary, and handling them becomes overheads. This patch provides
triggering options that can decide when events are signaled: (1) signal all
matched events or (2) signal an event only when the pressure level changes.
This trigger option can be set when each event is registered by writing
a trigger option, "always" or "edge", next to the string of levels.
"always" means that all matched events are signaled while "edge" means that
an event is signaled only when the pressure level is changed.
To keep backward compatibility, "always" is set by default if nothing is input
as an option. Each event can have different option. For example,
"low" level uses "always" trigger option to see reclaim activity at user space
while "medium"/"critical" uses "edge" to do an important job
like killing tasks only once.

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/cgroups/memory.txt |   11 +++++++++--
 mm/vmpressure.c                  |   38 ++++++++++++++++++++++++++++++++++----
 2 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ddf4f93..a6bb589 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -807,13 +807,20 @@ register a notification, an application must:
 
 - create an eventfd using eventfd(2);
 - open memory.pressure_level;
-- write string like "<event_fd> <fd of memory.pressure_level> <level>"
+- write string like
+	"<event_fd> <fd of memory.pressure_level> <level> <trigger_option>"
   to cgroup.event_control.
 
 Application will be notified through eventfd when memory pressure is at
 the specific level (or higher). Read/write operations to
 memory.pressure_level are no implemented.
 
+All matched events can always be signaled or an event can be signaled only when
+the pressure level changes. This trigger option is decided by writing it next
+to the level. "Always" trigger option will signal all matched events
+while "edge" option will signal the matched event only when the level changes.
+If the trigger option is not set, "always" is set by default.
+
 Test:
 
    Here is a small script example that makes a new cgroup, sets up a
@@ -823,7 +830,7 @@ Test:
    # cd /sys/fs/cgroup/memory/
    # mkdir foo
    # cd foo
-   # cgroup_event_listener memory.pressure_level low &
+   # cgroup_event_listener memory.pressure_level low edge &
    # echo 8000000 > memory.limit_in_bytes
    # echo 8000000 > memory.memsw.limit_in_bytes
    # echo $$ > tasks
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..7dcfb58 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -91,7 +91,8 @@ static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
 }
 
 enum vmpressure_levels {
-	VMPRESSURE_LOW = 0,
+	VMPRESSURE_NONE = -1,
+	VMPRESSURE_LOW,
 	VMPRESSURE_MEDIUM,
 	VMPRESSURE_CRITICAL,
 	VMPRESSURE_NUM_LEVELS,
@@ -137,6 +138,8 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 struct vmpressure_event {
 	struct eventfd_ctx *efd;
 	enum vmpressure_levels level;
+	enum vmpressure_levels last_level;
+	bool edge_trigger;
 	struct list_head node;
 };
 
@@ -153,9 +156,13 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 
 	list_for_each_entry(ev, &vmpr->events, node) {
 		if (level >= ev->level) {
+			if (ev->edge_trigger && level == ev->last_level)
+				continue;
+
 			eventfd_signal(ev->efd, 1);
 			signalled = true;
 		}
+		ev->last_level = level;
 	}
 
 	mutex_unlock(&vmpr->events_lock);
@@ -290,9 +297,11 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
  *
  * This function associates eventfd context with the vmpressure
  * infrastructure, so that the notifications will be delivered to the
- * @eventfd. The @args parameter is a string that denotes pressure level
+ * @eventfd. The @args parameters are a string that denotes pressure level
  * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
- * "critical").
+ * "critical") and a trigger option that decides whether events are triggered
+ * continuously or only on edge ("always" or "edge" if "edge", events
+ * are triggered when the pressure level changes.
  *
  * This function should not be used directly, just pass it to (struct
  * cftype).register_event, and then cgroup core will handle everything by
@@ -303,22 +312,43 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 {
 	struct vmpressure *vmpr = cg_to_vmpressure(cg);
 	struct vmpressure_event *ev;
+	char *strlevel, *strtrigger;
 	int level;
+	bool edge;
+
+	strlevel = args;
+	strtrigger = strchr(args, ' ');
+
+	if (strtrigger) {
+		*strtrigger = '\0';
+		strtrigger++;
+	}
 
 	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
-		if (!strcmp(vmpressure_str_levels[level], args))
+		if (!strcmp(vmpressure_str_levels[level], strlevel))
 			break;
 	}
 
 	if (level >= VMPRESSURE_NUM_LEVELS)
 		return -EINVAL;
 
+	if (strtrigger == NULL)
+		edge = false;
+	else if (!strcmp(strtrigger, "always"))
+		edge = false;
+	else if (!strcmp(strtrigger, "edge"))
+		edge = true;
+	else
+		return -EINVAL;
+
 	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
 	if (!ev)
 		return -ENOMEM;
 
 	ev->efd = eventfd;
 	ev->level = level;
+	ev->last_level = VMPRESSURE_NONE;
+	ev->edge_trigger = edge;
 
 	mutex_lock(&vmpr->events_lock);
 	list_add(&ev->node, &vmpr->events);
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
