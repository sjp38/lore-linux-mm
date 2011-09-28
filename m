Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5785C9000D0
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:49:45 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p8S0ngFt021482
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:43 -0700
Received: from iadx2 (iadx2.prod.google.com [10.12.150.2])
	by hpaq11.eem.corp.google.com with ESMTP id p8S0mjac020362
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:41 -0700
Received: by iadx2 with SMTP id x2so9626469iad.34
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:36 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 6/9] kstaled: rate limit pages scanned per second.
Date: Tue, 27 Sep 2011 17:49:04 -0700
Message-Id: <1317170947-17074-7-git-send-email-walken@google.com>
In-Reply-To: <1317170947-17074-1-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

Scan some number of pages from each node every second, instead of trying to
scan the entime memory at once and being idle for the rest of the configured
interval.

In addition to spreading the CPU usage over the entire scanning interval,
this also reduces the jitter between two consecutive scans of the same page.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mmzone.h |    3 ++
 mm/memcontrol.c        |   71 ++++++++++++++++++++++++++++++++++-------------
 2 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6657106..272fbed 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -631,6 +631,9 @@ typedef struct pglist_data {
 	unsigned long node_present_pages; /* total number of physical pages */
 	unsigned long node_spanned_pages; /* total size of physical page
 					     range, including holes */
+#ifdef CONFIG_KSTALED
+	unsigned long node_idle_scan_pfn;
+#endif
 	int node_id;
 	wait_queue_head_t kswapd_wait;
 	struct task_struct *kswapd;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b75d41f..b468867 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5736,15 +5736,19 @@ static unsigned kstaled_scan_page(struct page *page)
 	return nr_pages;
 }
 
-static void kstaled_scan_node(pg_data_t *pgdat)
+static bool kstaled_scan_node(pg_data_t *pgdat, int scan_seconds, bool reset)
 {
 	unsigned long flags;
-	unsigned long pfn, end;
+	unsigned long pfn, end, node_end;
 
 	pgdat_resize_lock(pgdat, &flags);
 
 	pfn = pgdat->node_start_pfn;
-	end = pfn + pgdat->node_spanned_pages;
+	node_end = pfn + pgdat->node_spanned_pages;
+	if (!reset && pfn < pgdat->node_idle_scan_pfn)
+		pfn = pgdat->node_idle_scan_pfn;
+	end = min(pfn + DIV_ROUND_UP(pgdat->node_spanned_pages, scan_seconds),
+		  node_end);
 
 	while (pfn < end) {
 		unsigned long contiguous = end;
@@ -5761,8 +5765,8 @@ static void kstaled_scan_node(pg_data_t *pgdat)
 #ifdef CONFIG_MEMORY_HOTPLUG
 				/* abort if the node got resized */
 				if (pfn < pgdat->node_start_pfn ||
-				    end > (pgdat->node_start_pfn +
-					   pgdat->node_spanned_pages))
+				    node_end > (pgdat->node_start_pfn +
+						pgdat->node_spanned_pages))
 					goto abort;
 #endif
 			}
@@ -5774,17 +5778,30 @@ static void kstaled_scan_node(pg_data_t *pgdat)
 
 abort:
 	pgdat_resize_unlock(pgdat, &flags);
+
+	pgdat->node_idle_scan_pfn = min(pfn, end);
+	return pfn >= node_end;
 }
 
 static int kstaled(void *dummy)
 {
+	bool reset = true;
+	long deadline = jiffies;
+
 	while (1) {
 		int scan_seconds;
 		int nid;
-		struct mem_cgroup *memcg;
+		long delta;
+		bool scan_done;
+
+		deadline += HZ;
+		scan_seconds = kstaled_scan_seconds;
+		if (scan_seconds <= 0) {
+			wait_event_interruptible(kstaled_wait,
+				(scan_seconds = kstaled_scan_seconds) > 0);
+			deadline = jiffies + HZ;
+		}
 
-		wait_event_interruptible(kstaled_wait,
-				 (scan_seconds = kstaled_scan_seconds) > 0);
 		/*
 		 * We use interruptible wait_event so as not to contribute
 		 * to the machine load average while we're sleeping.
@@ -5794,21 +5811,35 @@ static int kstaled(void *dummy)
 		 */
 		BUG_ON(scan_seconds <= 0);
 
-		for_each_mem_cgroup_all(memcg)
-			memset(&memcg->idle_scan_stats, 0,
-			       sizeof(memcg->idle_scan_stats));
-
+		scan_done = true;
 		for_each_node_state(nid, N_HIGH_MEMORY)
-			kstaled_scan_node(NODE_DATA(nid));
-
-		for_each_mem_cgroup_all(memcg) {
-			write_seqcount_begin(&memcg->idle_page_stats_lock);
-			memcg->idle_page_stats = memcg->idle_scan_stats;
-			memcg->idle_page_scans++;
-			write_seqcount_end(&memcg->idle_page_stats_lock);
+			scan_done &= kstaled_scan_node(NODE_DATA(nid),
+						       scan_seconds, reset);
+
+		if (scan_done) {
+			struct mem_cgroup *memcg;
+
+			for_each_mem_cgroup_all(memcg) {
+				write_seqcount_begin(
+					&memcg->idle_page_stats_lock);
+				memcg->idle_page_stats =
+					memcg->idle_scan_stats;
+				memcg->idle_page_scans++;
+				write_seqcount_end(
+					&memcg->idle_page_stats_lock);
+				memset(&memcg->idle_scan_stats, 0,
+				       sizeof(memcg->idle_scan_stats));
+			}
 		}
 
-		schedule_timeout_interruptible(scan_seconds * HZ);
+		delta = jiffies - deadline;
+		if (delta < 0)
+			schedule_timeout_interruptible(-delta);
+		else if (delta >= HZ)
+			pr_warning("kstaled running %ld.%02d seconds late\n",
+				   delta / HZ, (int)(delta % HZ) * 100 / HZ);
+
+		reset = scan_done;
 	}
 
 	BUG();
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
