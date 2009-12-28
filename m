Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 07DC960021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 02:48:55 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS7mru9005678
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Dec 2009 16:48:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E07FD45DE6E
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:48:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A48BC45DE4D
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:48:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 80F091DB803B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:48:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E5B71DB803A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 16:48:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/4] vmstat: add anon_scan_ratio field to zoneinfo
In-Reply-To: <20091228164451.A687.A69D9226@jp.fujitsu.com>
References: <20091228164451.A687.A69D9226@jp.fujitsu.com>
Message-Id: <20091228164816.A68D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Dec 2009 16:48:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Vmscan folks was asked "why does my system makes so much swap-out?"
in lkml at several times.
At that time, I made the debug patch to show recent_anon_{scanned/rorated}
parameter at least three times.

Thus, its parameter should be showed on /proc/zoneinfo. It help
vmscan folks debugging.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/swap.h |    2 ++
 mm/vmscan.c          |   15 +++++++++++++++
 mm/vmstat.c          |    7 +++++--
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index a2602a8..e95d7ed 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -280,6 +280,8 @@ extern void scan_unevictable_unregister_node(struct node *node);
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
 
+unsigned long get_anon_scan_ratio(struct zone *zone, struct mem_cgroup *memcg, int swappiness);
+
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 640486b..1c39a74 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1572,6 +1572,21 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 	percent[1] = 100 - percent[0];
 }
 
+unsigned long get_anon_scan_ratio(struct zone *zone, struct mem_cgroup *memcg, int swappiness)
+{
+	unsigned long percent[2];
+	struct scan_control sc = {
+		.may_swap = 1,
+		.swappiness = swappiness,
+		.mem_cgroup = memcg,
+	};
+
+	get_scan_ratio(zone, &sc, percent);
+
+	return percent[0];
+}
+
+
 /*
  * Smallish @nr_to_scan's are deposited in @nr_saved_scan,
  * until we collected @swap_cluster_max pages to scan.
diff --git a/mm/vmstat.c b/mm/vmstat.c
index a5d45bc..24383b4 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -15,6 +15,7 @@
 #include <linux/cpu.h>
 #include <linux/vmstat.h>
 #include <linux/sched.h>
+#include <linux/swap.h>
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
@@ -762,11 +763,13 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   "\n  all_unreclaimable: %u"
 		   "\n  prev_priority:     %i"
 		   "\n  start_pfn:         %lu"
-		   "\n  inactive_ratio:    %u",
+		   "\n  inactive_ratio:    %u"
+		   "\n  anon_scan_ratio:   %lu",
 			   zone_is_all_unreclaimable(zone),
 		   zone->prev_priority,
 		   zone->zone_start_pfn,
-		   zone->inactive_ratio);
+		   zone->inactive_ratio,
+		   get_anon_scan_ratio(zone, NULL, vm_swappiness));
 	seq_putc(m, '\n');
 }
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
