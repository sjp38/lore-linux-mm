Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E183C8D0047
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 04:44:28 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p2P8iROq017084
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:27 -0700
Received: from iwg8 (iwg8.prod.google.com [10.241.66.136])
	by kpbe18.cbf.corp.google.com with ESMTP id p2P8iQxM005082
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:26 -0700
Received: by iwg8 with SMTP id 8so418145iwg.14
        for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:26 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 5/5] kstaled: rate limit pages scanned per second.
Date: Fri, 25 Mar 2011 01:43:55 -0700
Message-Id: <1301042635-11180-6-git-send-email-walken@google.com>
In-Reply-To: <1301042635-11180-1-git-send-email-walken@google.com>
References: <1301042635-11180-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mmzone.h |    1 +
 mm/memcontrol.c        |   81 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 68 insertions(+), 14 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 955fd02..f98fc64 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -636,6 +636,7 @@ typedef struct pglist_data {
 	unsigned long node_present_pages; /* total number of physical pages */
 	unsigned long node_spanned_pages; /* total size of physical page
 					     range, including holes */
+	unsigned long node_idle_scan_pfn;
 	int node_id;
 	wait_queue_head_t kswapd_wait;
 	struct task_struct *kswapd;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5bdaa23..64b157b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5115,6 +5115,7 @@ __setup("noswapaccount", disable_swap_account);
 #endif
 
 static unsigned int kstaled_scan_seconds;
+static DEFINE_SPINLOCK(kstaled_scan_seconds_lock);
 static DECLARE_WAIT_QUEUE_HEAD(kstaled_wait);
 
 static inline void kstaled_scan_page(struct page *page)
@@ -5235,15 +5236,19 @@ static inline void kstaled_scan_page(struct page *page)
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
@@ -5260,14 +5265,21 @@ static void kstaled_scan_node(pg_data_t *pgdat)
 	}
 
 	pgdat_resize_unlock(pgdat, &flags);
+
+	pgdat->node_idle_scan_pfn = end;
+	return end == node_end;
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
@@ -5280,27 +5292,66 @@ static int kstaled(void *dummy)
 		 */
 		BUG_ON(scan_seconds <= 0);
 
-		for_each_mem_cgroup_all(mem)
-			memset(&mem->idle_scan_stats, 0,
-			       sizeof(mem->idle_scan_stats));
+		earlier = jiffies;
 
+		scan_done = true;
 		for_each_node_state(nid, N_HIGH_MEMORY) {
 			const struct cpumask *cpumask = cpumask_of_node(nid);
 
 			if (!cpumask_empty(cpumask))
 				set_cpus_allowed_ptr(current, cpumask);
 
-			kstaled_scan_node(NODE_DATA(nid));
+			scan_done &= kstaled_scan_node(NODE_DATA(nid),
+						       scan_seconds, reset);
 		}
 
-		for_each_mem_cgroup_all(mem) {
-			write_seqcount_begin(&mem->idle_page_stats_lock);
-			mem->idle_page_stats = mem->idle_scan_stats;
-			mem->idle_page_scans++;
-			write_seqcount_end(&mem->idle_page_stats_lock);
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
+
+		delta = jiffies - earlier;
+		if (delta < HZ / 2) {
+			delayed = 0;
+			schedule_timeout_interruptible(HZ - delta);
+		} else {
+			/*
+			 * Emergency throttle if we're taking too long.
+			 * We are supposed to scan an entire slice in 1 second.
+			 * If we keep taking more than half a second for
+			 * 10 consecutive times, scale back our scan_seconds.
+			 *
+			 * If someone changed kstaled_scan_cycle while we were
+			 * running, hope they know what they're doing and
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
@@ -5324,7 +5375,9 @@ static ssize_t kstaled_scan_seconds_store(struct kobject *kobj,
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
