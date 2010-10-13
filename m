Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1B4086B00F7
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 02:28:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D6SH91008336
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Oct 2010 15:28:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E552745DE57
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:28:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B59CF45DE52
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:28:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66C461DB8041
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:28:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3A0D1DB803B
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:28:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 2/3] mm: update pcp->stat_threshold when memory hotplug occur
In-Reply-To: <20101013151723.ADBD.A69D9226@jp.fujitsu.com>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013151723.ADBD.A69D9226@jp.fujitsu.com>
Message-Id: <20101013152820.ADC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Oct 2010 15:28:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Currently, cpu hotplug updates pcp->stat_threashold, but memory
hotplug doesn't. there is no reason.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/vmstat.h |    5 ++++-
 mm/page_alloc.c        |    3 +++
 mm/vmstat.c            |    5 ++---
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index eaaea37..1997988 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -254,6 +254,7 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
 void refresh_cpu_vm_stats(int);
+void refresh_zone_stat_thresholds(void);
 #else /* CONFIG_SMP */
 
 /*
@@ -299,6 +300,8 @@ static inline void __dec_zone_page_state(struct page *page,
 #define mod_zone_page_state __mod_zone_page_state
 
 static inline void refresh_cpu_vm_stats(int cpu) { }
-#endif
+static inline void refresh_zone_stat_thresholds(void) { }
+
+#endif /* CONFIG_SMP */
 
 #endif /* _LINUX_VMSTAT_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6846096..53627fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -51,6 +51,7 @@
 #include <linux/kmemleak.h>
 #include <linux/memory.h>
 #include <linux/compaction.h>
+#include <linux/vmstat.h>
 #include <trace/events/kmem.h>
 #include <linux/ftrace_event.h>
 
@@ -5013,6 +5014,8 @@ int __meminit init_per_zone_wmark_min(void)
 		min_free_kbytes = 128;
 	if (min_free_kbytes > 65536)
 		min_free_kbytes = 65536;
+
+	refresh_zone_stat_thresholds();
 	setup_per_zone_wmarks();
 	setup_per_zone_lowmem_reserve();
 	setup_per_zone_inactive_ratio();
diff --git a/mm/vmstat.c b/mm/vmstat.c
index baa4ab3..48b0463 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -132,7 +132,7 @@ static int calculate_threshold(struct zone *zone)
 /*
  * Refresh the thresholds for each zone.
  */
-static void refresh_zone_stat_thresholds(void)
+void refresh_zone_stat_thresholds(void)
 {
 	struct zone *zone;
 	int cpu;
@@ -370,7 +370,7 @@ void refresh_cpu_vm_stats(int cpu)
 			atomic_long_add(global_diff[i], &vm_stat[i]);
 }
 
-#endif
+#endif /* CONFIG_SMP */
 
 #ifdef CONFIG_NUMA
 /*
@@ -1057,7 +1057,6 @@ static int __init setup_vmstat(void)
 #ifdef CONFIG_SMP
 	int cpu;
 
-	refresh_zone_stat_thresholds();
 	register_cpu_notifier(&vmstat_notifier);
 
 	for_each_online_cpu(cpu)
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
