Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 61C3D6B00D6
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 01:09:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J59e8U008002
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 14:09:40 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9A7245DE4F
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:09:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BEEB45DE4E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:09:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00A93E08002
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:09:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5117B1DB804A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:09:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [resend][PATCH 2/2] mm, mem-hotplug: update pcp->stat_threshold when memory hotplug occur
In-Reply-To: <20101019140831.A1EB.A69D9226@jp.fujitsu.com>
References: <20101019140831.A1EB.A69D9226@jp.fujitsu.com>
Message-Id: <20101019140955.A1EE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 14:09:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Currently, cpu hotplug updates pcp->stat_threashold, but memory
hotplug doesn't. there is no reason.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
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
index 14ee899..222d8cc 100644
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
index cd2e42b..b6b7fed 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -133,7 +133,7 @@ static int calculate_threshold(struct zone *zone)
 /*
  * Refresh the thresholds for each zone.
  */
-static void refresh_zone_stat_thresholds(void)
+void refresh_zone_stat_thresholds(void)
 {
 	struct zone *zone;
 	int cpu;
@@ -371,7 +371,7 @@ void refresh_cpu_vm_stats(int cpu)
 			atomic_long_add(global_diff[i], &vm_stat[i]);
 }
 
-#endif
+#endif /* CONFIG_SMP */
 
 #ifdef CONFIG_NUMA
 /*
@@ -1059,7 +1059,6 @@ static int __init setup_vmstat(void)
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
