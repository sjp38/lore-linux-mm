Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id B298A6B0031
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 03:34:36 -0400 (EDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOS009BGADMXJ50@mailout4.samsung.com> for linux-mm@kvack.org;
 Sat, 22 Jun 2013 16:34:35 +0900 (KST)
From: Hyunhee Kim <hyunhee.kim@samsung.com>
References: 
 <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
 <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox> <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
In-reply-to: <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
Subject: [PATCH] memcg: add interface to specify thresholds of vmpressure
Date: Sat, 22 Jun 2013 16:34:34 +0900
Message-id: <005801ce6f1a$f1664f90$d432eeb0$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hyunhee Kim' <hyunhee.kim@samsung.com>, 'Minchan Kim' <minchan@kernel.org>, 'Michal Hocko' <mhocko@suse.cz>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

Memory pressure is calculated based on scanned/reclaimed ratio. The higher
the value, the more number unsuccessful reclaims there were. These thresholds
can be specified when each event is registered by writing it next to the
string of level. Default value is 60 for "medium" and 95 for "critical"

Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/cgroups/memory.txt |    8 +++++-
 mm/vmpressure.c                  |   54 +++++++++++++++++++++++++++-----------
 2 files changed, 45 insertions(+), 17 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index ddf4f93..bd9cf46 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -807,13 +807,19 @@ register a notification, an application must:
 
 - create an eventfd using eventfd(2);
 - open memory.pressure_level;
-- write string like "<event_fd> <fd of memory.pressure_level> <level>"
+- write string like "<event_fd> <fd of memory.pressure_level> <level> <threshold>"
   to cgroup.event_control.
 
 Application will be notified through eventfd when memory pressure is at
 the specific level (or higher). Read/write operations to
 memory.pressure_level are no implemented.
 
+We account memory pressure based on scanned/reclaimed ratio. The higher
+the value, the more number unsuccessful reclaims there were. These thresholds
+can be specified when each event is registered by writing it next to the
+string of level. Default value is 60 for "medium" and 95 for "critical".
+If nothing is input as threshold, default values are used.
+
 Test:
 
    Here is a small script example that makes a new cgroup, sets up a
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 736a601..52b266c 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -40,15 +40,6 @@
 static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
 
 /*
- * These thresholds are used when we account memory pressure through
- * scanned/reclaimed ratio. The current values were chosen empirically. In
- * essence, they are percents: the higher the value, the more number
- * unsuccessful reclaims there were.
- */
-static const unsigned int vmpressure_level_med = 60;
-static const unsigned int vmpressure_level_critical = 95;
-
-/*
  * When there are too little pages left to scan, vmpressure() may miss the
  * critical pressure as number of pages will be less than "window size".
  * However, in that case the vmscan priority will raise fast as the
@@ -97,6 +88,19 @@ enum vmpressure_levels {
 	VMPRESSURE_NUM_LEVELS,
 };
 
+/*
+ * These thresholds are used when we account memory pressure through
+ * scanned/reclaimed ratio. In essence, they are percents: the higher
+ * the value, the more number unsuccessful reclaims there were.
+ * These thresholds can be specified when each event is registered.
+ */
+
+static unsigned int vmpressure_threshold_levels[] = {
+	[VMPRESSURE_LOW] = 0,
+	[VMPRESSURE_MEDIUM] = 60,
+	[VMPRESSURE_CRITICAL] = 95,
+};
+
 static const char * const vmpressure_str_levels[] = {
 	[VMPRESSURE_LOW] = "low",
 	[VMPRESSURE_MEDIUM] = "medium",
@@ -105,11 +109,14 @@ static const char * const vmpressure_str_levels[] = {
 
 static enum vmpressure_levels vmpressure_level(unsigned long pressure)
 {
-	if (pressure >= vmpressure_level_critical)
-		return VMPRESSURE_CRITICAL;
-	else if (pressure >= vmpressure_level_med)
-		return VMPRESSURE_MEDIUM;
-	return VMPRESSURE_LOW;
+	int level;
+
+	for (level = VMPRESSURE_NUM_LEVELS - 1; level >= 0; level--) {
+		if (pressure >= vmpressure_threshold_levels[level])
+			break;
+	}
+
+	return level;
 }
 
 static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
@@ -303,10 +310,21 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 {
 	struct vmpressure *vmpr = cg_to_vmpressure(cg);
 	struct vmpressure_event *ev;
-	int level;
+	char *strlevel, *strthres;
+	int level, thres = -1;
+
+	strlevel = args;
+	strthres = strchr(args, ' ');
+
+	if (strthres) {
+		*strthres = '\0';
+		strthres++;
+		if(kstrtoint(strthres, 10, &thres))
+			return -EINVAL;
+	}
 
 	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
-		if (!strcmp(vmpressure_str_levels[level], args))
+		if (!strcmp(vmpressure_str_levels[level], strlevel))
 			break;
 	}
 
@@ -320,6 +338,10 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
 	ev->efd = eventfd;
 	ev->level = level;
 
+	/* If user input threshold is not valid value, use default value */
+	if (thres <= 100 && thres >= 0)
+		vmpressure_threshold_levels[level] = thres;
+
 	mutex_lock(&vmpr->events_lock);
 	list_add(&ev->node, &vmpr->events);
 	mutex_unlock(&vmpr->events_lock);
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
