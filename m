Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EC5116B01B0
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 09:38:59 -0400 (EDT)
Received: by pva18 with SMTP id 18so17927pva.14
        for <linux-mm@kvack.org>; Thu, 10 Jun 2010 06:38:58 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] Cleanup : change try_set_zone_oom with try_set_zonelist_oom
Date: Thu, 10 Jun 2010 22:38:44 +0900
Message-Id: <1276177124-3395-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

We have been used naming try_set_zone_oom and clear_zonelist_oom.
The role of functions is to lock of zonelist for preventing parallel
OOM. So clear_zonelist_oom makes sense but try_set_zone_oome is rather
awkward and unmatched with clear_zonelist_oom.

Let's change it with try_set_zonelist_oom.

Cc: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Let's change it with try_set_zonelist_oom.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/oom.h |    2 +-
 mm/oom_kill.c       |    4 ++--
 mm/page_alloc.c     |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5376623..2e4b90b 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -24,7 +24,7 @@ enum oom_constraint {
 	CONSTRAINT_MEMORY_POLICY,
 };
 
-extern int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_flags);
+extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 709aedf..84840f3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -509,7 +509,7 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
  * if a parallel OOM killing is already taking place that includes a zone in
  * the zonelist.  Otherwise, locks all zones in the zonelist and returns 1.
  */
-int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_mask)
+int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -526,7 +526,7 @@ int try_set_zone_oom(struct zonelist *zonelist, gfp_t gfp_mask)
 	for_each_zone_zonelist(zone, z, zonelist, gfp_zone(gfp_mask)) {
 		/*
 		 * Lock each zone in the zonelist under zone_scan_lock so a
-		 * parallel invocation of try_set_zone_oom() doesn't succeed
+		 * parallel invocation of try_set_zonelist_oom() doesn't succeed
 		 * when it shouldn't.
 		 */
 		zone_set_flag(zone, ZONE_OOM_LOCKED);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 431214b..492c200 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1738,7 +1738,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct page *page;
 
 	/* Acquire the OOM killer lock for the zones in zonelist */
-	if (!try_set_zone_oom(zonelist, gfp_mask)) {
+	if (!try_set_zonelist_oom(zonelist, gfp_mask)) {
 		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
