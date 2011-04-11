Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 67F8C8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 04:01:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 55DEE3EE0B5
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:01:10 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3827B45DE53
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:01:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1567245DE51
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:01:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0153E1DB803F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:01:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C02A61DB803B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:01:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/3] mm, mem-hotplug: update pcp->stat_threshold when memory hotplug occur
In-Reply-To: <20110411165957.0352.A69D9226@jp.fujitsu.com>
References: <20110411165957.0352.A69D9226@jp.fujitsu.com>
Message-Id: <20110411170134.035E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Apr 2011 17:01:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

Currently, cpu hotplug updates pcp->stat_threashold, but memory
hotplug doesn't. there is no reason.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/vmstat.h |    1 +
 mm/page_alloc.c        |    2 ++
 mm/vmstat.c            |    3 +--
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 04fa5df..5f72954 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -201,6 +201,7 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
 void refresh_cpu_vm_stats(int);
+void refresh_zone_stat_thresholds(void);
 
 int calculate_pressure_threshold(struct zone *zone);
 int calculate_normal_threshold(struct zone *zone);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ef90a87..10b5816 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -54,6 +54,7 @@
 #include <trace/events/kmem.h>
 #include <linux/ftrace_event.h>
 #include <linux/memcontrol.h>
+#include <linux/vmstat.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -5130,6 +5131,7 @@ int __meminit init_per_zone_wmark_min(void)
 	if (min_free_kbytes > 65536)
 		min_free_kbytes = 65536;
 	setup_per_zone_wmarks();
+	refresh_zone_stat_thresholds();
 	setup_per_zone_lowmem_reserve();
 	setup_per_zone_inactive_ratio();
 	return 0;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 897ea9e..b23b1f5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -157,7 +157,7 @@ int calculate_normal_threshold(struct zone *zone)
 /*
  * Refresh the thresholds for each zone.
  */
-static void refresh_zone_stat_thresholds(void)
+void refresh_zone_stat_thresholds(void)
 {
 	struct zone *zone;
 	int cpu;
@@ -1198,7 +1198,6 @@ static int __init setup_vmstat(void)
 #ifdef CONFIG_SMP
 	int cpu;
 
-	refresh_zone_stat_thresholds();
 	register_cpu_notifier(&vmstat_notifier);
 
 	for_each_online_cpu(cpu)
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
