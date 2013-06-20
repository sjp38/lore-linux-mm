Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 748066B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 22:17:42 -0400 (EDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOO00M0G6DGISG0@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 20 Jun 2013 11:17:40 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
References: <008a01ce6b4e$079b6a50$16d23ef0$%kim@samsung.com>
 <20130617131551.GA5018@dhcp22.suse.cz>
 <CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
 <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
 <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
In-reply-to: <20130619125329.GB16457@dhcp22.suse.cz>
Subject: [PATCH v5] memcg: event control at vmpressure.
Date: Thu, 20 Jun 2013 11:17:39 +0900
Message-id: <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@suse.cz>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name
Cc: 'Kyungmin Park' <kyungmin.park@samsung.com>

In the original vmpressure, events are triggered whenever there is a reclaim
activity. This becomes overheads to user space module and also increases
power consumption if there is somebody to listen to it. This patch provides
options to trigger events only when the pressure level changes.
This trigger option can be set when registering each event by writing
a trigger option, "edge" or "always", next to the string of levels.
"edge" means that the event is triggered only when the pressure level is changed.
"always" means that events are triggered whenever there is a reclaim process.
To keep backward compatibility, "always" is set by default if nothing is input
as an option. Each event can have different option. For example,
"low" level uses "always" trigger option to see reclaim activity at user space
while "medium"/"critical" uses "edge" to do an important job
like killing tasks only once.

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/cgroups/memory.txt |   12 ++++++++++--
 mm/vmpressure.c                  |   34 ++++++++++++++++++++++++++++++----
 2 files changed, 40 insertions(+), 6 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ddf4f93..185870f 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -807,13 +807,21 @@ register a notification, an application must:
 
 - create an eventfd using eventfd(2);
 - open memory.pressure_level;
-- write string like "<event_fd> <fd of memory.pressure_level> <level>"
+- write string like
+	"<event_fd> <fd of memory.pressure_level> <level> <trigger_option>"
   to cgroup.event_control.
 
 Application will be notified through eventfd when memory pressure is at
 the specific level (or higher). Read/write operations to
 memory.pressure_level are no implemented.
 
+Events can be triggered whenever there is a reclaim activity or
+only when the pressure level changes. Trigger option is decided
+by writing it next to the level. The event whose trigger option is
+"always" is triggered whenever there is a reclaim process.
+If "edge" is set, the event is triggered only when the level is changed.
+If the trigger option is not set, "always" is set by default.
+
 Test:
 
    Here is a small script example that makes a new cgroup, sets up a
@@ -823,7 +831,7 @@ Test:
    # cd /sys/fs/cgroup/memory/
    # mkdir foo
    # cd foo
-   # cgroup_event_listener memory.pressure_level low &
+   # cgroup_event_listener memory.pressure_level low edge &
    # echo 8000000 > memory.limit_in_bytes
    # echo 8000000 > memory.memsw.limit_in_bytes
    # echo $$ > tasks
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..3c37b12 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -137,6 +137,8 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
 struct vmpressure_event {
 	struct eventfd_ctx *efd;
 	enum vmpressure_levels level;
+	int last_level;
+	bool edge_trigger;
 	struct list_head node;
 };
 
@@ -153,11 +155,14 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 
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
-
 	mutex_unlock(&vmpr->events_lock);
 
 	return signalled;
@@ -290,9 +295,11 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
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
@@ -303,10 +310,19 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 {
 	struct vmpressure *vmpr = cg_to_vmpressure(cg);
 	struct vmpressure_event *ev;
+	char *strlevel = NULL, *strtrigger = NULL;
 	int level;
 
+	strlevel = args;
+	strtrigger = strchr(args, ' ');
+
+	if (strtrigger) {
+		*strtrigger = '\0';
+		strtrigger++;
+	}
+
 	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
-		if (!strcmp(vmpressure_str_levels[level], args))
+		if (!strcmp(vmpressure_str_levels[level], strlevel))
 			break;
 	}
 
@@ -319,6 +335,16 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 
 	ev->efd = eventfd;
 	ev->level = level;
+	ev->last_level = -1;
+
+	if (strtrigger == NULL)
+		ev->edge_trigger = false;
+	else if (!strcmp(strtrigger, "always"))
+		ev->edge_trigger = false;
+	else if (!strcmp(strtrigger, "edge"))
+		ev->edge_trigger = true;
+	else
+		return -EINVAL;
 
 	mutex_lock(&vmpr->events_lock);
 	list_add(&ev->node, &vmpr->events);
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
