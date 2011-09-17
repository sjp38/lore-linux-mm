Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A6D36940066
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 23:39:48 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p8H3djdM010881
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:45 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq7.eem.corp.google.com with ESMTP id p8H3dg8r024844
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:44 -0700
Received: by pzk36 with SMTP id 36so3387900pzk.3
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:42 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 6/8] kstaled: rate limit pages scanned per second.
Date: Fri, 16 Sep 2011 20:39:11 -0700
Message-Id: <1316230753-8693-7-git-send-email-walken@google.com>
In-Reply-To: <1316230753-8693-1-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

Scan some number of pages from each node every second, instead of trying to
scan the entime memory at once and being idle for the rest of the configured
interval.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mmzone.h |    3 ++
 mm/memcontrol.c        |   85 +++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 72 insertions(+), 16 deletions(-)

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
index 0fdc278..4a76fdcf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5617,6 +5617,7 @@ __setup("swapaccount=", enable_swap_account);
 #ifdef CONFIG_KSTALED
 
 static unsigned int kstaled_scan_seconds;
+static DEFINE_SPINLOCK(kstaled_scan_seconds_lock);
 static DECLARE_WAIT_QUEUE_HEAD(kstaled_wait);
 
 static inline void kstaled_scan_page(struct page *page)
@@ -5728,15 +5729,19 @@ static inline void kstaled_scan_page(struct page *page)
 	put_page(page);
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
@@ -5753,8 +5758,8 @@ static void kstaled_scan_node(pg_data_t *pgdat)
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
@@ -5768,14 +5773,21 @@ static void kstaled_scan_node(pg_data_t *pgdat)
 
 abort:
 	pgdat_resize_unlock(pgdat, &flags);
+
+	pgdat->node_idle_scan_pfn = pfn;
+	return pfn >= node_end;
 }
 
 static int kstaled(void *dummy)
 {
+	int delayed = 0;
+	bool reset = true;
+
 	while (1) {
 		int scan_seconds;
 		int nid;
-		struct mem_cgroup *mem;
+		long earlier, delta;
+		bool scan_done;
 
 		wait_event_interruptible(kstaled_wait,
 				 (scan_seconds = kstaled_scan_seconds) > 0);
@@ -5788,21 +5800,60 @@ static int kstaled(void *dummy)
 		 */
 		BUG_ON(scan_seconds <= 0);
 
-		for_each_mem_cgroup_all(mem)
-			memset(&mem->idle_scan_stats, 0,
-			       sizeof(mem->idle_scan_stats));
+		earlier = jiffies;
 
+		scan_done = true;
 		for_each_node_state(nid, N_HIGH_MEMORY)
-			kstaled_scan_node(NODE_DATA(nid));
+			scan_done &= kstaled_scan_node(NODE_DATA(nid),
+						       scan_seconds, reset);
+
+		if (scan_done) {
+			struct mem_cgroup *mem;
+
+			for_each_mem_cgroup_all(mem) {
+				write_seqcount_begin(&mem->idle_page_stats_lock);
+				mem->idle_page_stats = mem->idle_scan_stats;
+				mem->idle_page_scans++;
+				write_seqcount_end(&mem->idle_page_stats_lock);
+				memset(&mem->idle_scan_stats, 0,
+				       sizeof(mem->idle_scan_stats));
+			}
+		}
 
-		for_each_mem_cgroup_all(mem) {
-			write_seqcount_begin(&mem->idle_page_stats_lock);
-			mem->idle_page_stats = mem->idle_scan_stats;
-			mem->idle_page_scans++;
-			write_seqcount_end(&mem->idle_page_stats_lock);
+		delta = jiffies - earlier;
+		if (delta < HZ / 2) {
+			delayed = 0;
+			schedule_timeout_interruptible(HZ - delta);
+		} else {
+			/*
+			 * Emergency throttle if we're taking too long.
+			 * We are supposed to scan an entire slice in 1 second.
+			 * If we keep taking longer for 10 consecutive times,
+			 * scale back our scan_seconds.
+			 *
+			 * If someone changed kstaled_scan_seconds while we
+			 * were running, hope they know what they're doing and
+			 * assume they've eliminated any delays.
+			 */
+			bool updated = false;
+			spin_lock(&kstaled_scan_seconds_lock);
+			if (scan_seconds != kstaled_scan_seconds)
+				delayed = 0;
+			else if (++delayed == 10) {
+				delayed = 0;
+				scan_seconds *= 2;
+				kstaled_scan_seconds = scan_seconds;
+				updated = true;
+			}
+			spin_unlock(&kstaled_scan_seconds_lock);
+			if (updated)
+				pr_warning("kstaled taking too long, "
+					   "scan_seconds now %d\n",
+					   scan_seconds);
+			schedule_timeout_interruptible(HZ / 2);
 		}
 
-		schedule_timeout_interruptible(scan_seconds * HZ);
+		reset = scan_done;
 	}
 
 	BUG();
@@ -5826,7 +5877,9 @@ static ssize_t kstaled_scan_seconds_store(struct kobject *kobj,
 	err = strict_strtoul(buf, 10, &input);
 	if (err)
 		return -EINVAL;
+	spin_lock(&kstaled_scan_seconds_lock);
 	kstaled_scan_seconds = input;
+	spin_unlock(&kstaled_scan_seconds_lock);
 	wake_up_interruptible(&kstaled_wait);
 	return count;
 }
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
