Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 3C0306B0083
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 04:15:25 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so181322pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 01:15:24 -0800 (PST)
Date: Wed, 14 Nov 2012 01:15:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/4] mm, oom: cleanup pagefault oom handler
In-Reply-To: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1211140113020.32125@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

To lock the entire system from parallel oom killing, it's possible to
pass in a zonelist with all zones rather than using
for_each_populated_zone() for the iteration.  This obsoletes
try_set_system_oom() and clear_system_oom() so that they can be removed.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   49 +++++++------------------------------------------
 1 files changed, 7 insertions(+), 42 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -591,43 +591,6 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
 	spin_unlock(&zone_scan_lock);
 }
 
-/*
- * Try to acquire the oom killer lock for all system zones.  Returns zero if a
- * parallel oom killing is taking place, otherwise locks all zones and returns
- * non-zero.
- */
-static int try_set_system_oom(void)
-{
-	struct zone *zone;
-	int ret = 1;
-
-	spin_lock(&zone_scan_lock);
-	for_each_populated_zone(zone)
-		if (zone_is_oom_locked(zone)) {
-			ret = 0;
-			goto out;
-		}
-	for_each_populated_zone(zone)
-		zone_set_flag(zone, ZONE_OOM_LOCKED);
-out:
-	spin_unlock(&zone_scan_lock);
-	return ret;
-}
-
-/*
- * Clears ZONE_OOM_LOCKED for all system zones so that failed allocation
- * attempts or page faults may now recall the oom killer, if necessary.
- */
-static void clear_system_oom(void)
-{
-	struct zone *zone;
-
-	spin_lock(&zone_scan_lock);
-	for_each_populated_zone(zone)
-		zone_clear_flag(zone, ZONE_OOM_LOCKED);
-	spin_unlock(&zone_scan_lock);
-}
-
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
@@ -708,15 +671,17 @@ out:
 
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel
- * oom killing is already in progress so do nothing.  If a task is found with
- * TIF_MEMDIE set, it has been killed so do nothing and allow it to exit.
+ * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
+ * parallel oom killing is already in progress so do nothing.
  */
 void pagefault_out_of_memory(void)
 {
-	if (try_set_system_oom()) {
+	struct zonelist *zonelist = node_zonelist(first_online_node,
+						  GFP_KERNEL);
+
+	if (try_set_zonelist_oom(zonelist, GFP_KERNEL)) {
 		out_of_memory(NULL, 0, 0, NULL, false);
-		clear_system_oom();
+		clear_zonelist_oom(zonelist, GFP_KERNEL);
 	}
 	schedule_timeout_killable(1);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
