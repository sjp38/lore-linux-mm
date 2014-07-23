Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 93A426B0037
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:24:34 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id q58so1038554wes.32
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:24:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uj9si4198205wjc.132.2014.07.23.04.24.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 04:24:25 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] mm: Move RSS stat event count synchronisation out of the fast path
Date: Wed, 23 Jul 2014 12:24:16 +0100
Message-Id: <1406114656-16350-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1406114656-16350-1-git-send-email-mgorman@suse.de>
References: <1406114656-16350-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

With split RSS counters there is a per-task RSS counter that is synced with
the mm counters every 64 page faults in the fast path. Not all faults result
in modifications to these stats and the sync is potentially a waste. This
patch synchronises the counts to synchronise when the counter overflows
the threshold. It may mean that drift can be long-lived if the number of
events was limited but the amount of drift will be bounded.

Unlike the previous patch this is easier to quantify by anything that is
fault intensive by monitoring CPU usage.

kernbench
                          3.16.0-rc5             3.16.0-rc5
              memcgstat-preempt-v1r1 rssthresh-preempt-v1r1
User    min         579.44 (  0.00%)      580.04 ( -0.10%)
User    mean        579.92 (  0.00%)      580.70 ( -0.13%)
User    stddev        0.27 (  0.00%)        0.49 (-84.55%)
User    max         580.25 (  0.00%)      581.33 ( -0.19%)
User    range         0.81 (  0.00%)        1.29 (-59.26%)
System  min          35.94 (  0.00%)       35.93 (  0.03%)
System  mean         36.22 (  0.00%)       36.05 (  0.46%)
System  stddev        0.21 (  0.00%)        0.10 ( 50.88%)
System  max          36.53 (  0.00%)       36.24 (  0.79%)
System  range         0.59 (  0.00%)        0.31 ( 47.46%)
Elapsed min          83.99 (  0.00%)       83.98 (  0.01%)
Elapsed mean         84.17 (  0.00%)       84.31 ( -0.17%)
Elapsed stddev        0.21 (  0.00%)        0.22 ( -3.37%)
Elapsed max          84.55 (  0.00%)       84.51 (  0.05%)
Elapsed range         0.56 (  0.00%)        0.53 (  5.36%)
CPU     min         728.00 (  0.00%)      729.00 ( -0.14%)
CPU     mean        731.60 (  0.00%)      731.00 (  0.08%)
CPU     stddev        1.96 (  0.00%)        2.10 ( -7.04%)
CPU     max         733.00 (  0.00%)      734.00 ( -0.14%)
CPU     range         5.00 (  0.00%)        5.00 (  0.00%)

        memcgstat-     rssthresh
User         7313.65     7210.70
System        484.33      466.93
Elapsed      1154.23     1133.01

page fault test
                        3.16.0-rc5            3.16.0-rc5
            memcgstat-preempt-v1r1rssthresh-preempt-v1r1
System     1       0.4790 (  0.00%)       0.4980 ( -3.97%)
System     2       0.5120 (  0.00%)       0.5035 (  1.66%)
System     3       0.5410 (  0.00%)       0.5355 (  1.02%)
System     4       0.6805 (  0.00%)       0.6735 (  1.03%)
System     5       0.8530 (  0.00%)       0.8560 ( -0.35%)
System     6       1.0425 (  0.00%)       1.0360 (  0.62%)
System     7       1.2645 (  0.00%)       1.2525 (  0.95%)
System     8       1.5070 (  0.00%)       1.5040 (  0.20%)
Elapsed    1       0.5630 (  0.00%)       0.5835 ( -3.64%)
Elapsed    2       0.3010 (  0.00%)       0.2955 (  1.83%)
Elapsed    3       0.2105 (  0.00%)       0.2105 (  0.00%)
Elapsed    4       0.1965 (  0.00%)       0.1920 (  2.29%)
Elapsed    5       0.2145 (  0.00%)       0.2190 ( -2.10%)
Elapsed    6       0.2055 (  0.00%)       0.2040 (  0.73%)
Elapsed    7       0.2080 (  0.00%)       0.2020 (  2.88%)
Elapsed    8       0.2100 (  0.00%)       0.2100 (  0.00%)

          3.16.0-rc5  3.16.0-rc5
        memcgstat-preempt-v1r1rssthresh-preempt-v1r1
User          109.91      104.41
System        370.77      360.09
Elapsed       274.71      266.62

The difference is marginal in the overall cost of a page fault but there
is no point having unnecessary overhead either.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h |  1 -
 mm/memory.c              | 32 +++++++++++++-------------------
 2 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 96c5750..c9404e4 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -332,7 +332,6 @@ enum {
 #define SPLIT_RSS_COUNTING
 /* per-thread cached information, */
 struct task_rss_stat {
-	int events;	/* for synchronization threshold */
 	int count[NR_MM_COUNTERS];
 };
 #endif /* USE_SPLIT_PTE_PTLOCKS */
diff --git a/mm/memory.c b/mm/memory.c
index d67fd9f..26b41be 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -131,6 +131,9 @@ core_initcall(init_zero_pfn);
 
 #if defined(SPLIT_RSS_COUNTING)
 
+/* sync counter once per 64 rss stat update events */
+#define TASK_RSS_EVENTS_THRESH	(64)
+
 void sync_mm_rss(struct mm_struct *mm)
 {
 	int i;
@@ -141,39 +144,33 @@ void sync_mm_rss(struct mm_struct *mm)
 			current->rss_stat.count[i] = 0;
 		}
 	}
-	current->rss_stat.events = 0;
 }
 
 static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
 {
 	struct task_struct *task = current;
 
-	if (likely(task->mm == mm))
+	if (likely(task->mm == mm)) {
 		task->rss_stat.count[member] += val;
-	else
+		if (task != current)
+			return;
+
+		if (task->rss_stat.count[member] > TASK_RSS_EVENTS_THRESH ||
+		    task->rss_stat.count[member] < -TASK_RSS_EVENTS_THRESH) {
+			add_mm_counter(mm, member, current->rss_stat.count[member]);
+			current->rss_stat.count[member] = 0;
+		}
+	} else
 		add_mm_counter(mm, member, val);
 }
 #define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, 1)
 #define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, -1)
 
-/* sync counter once per 64 page faults */
-#define TASK_RSS_EVENTS_THRESH	(64)
-static void check_sync_rss_stat(struct task_struct *task)
-{
-	if (unlikely(task != current))
-		return;
-	if (unlikely(task->rss_stat.events++ > TASK_RSS_EVENTS_THRESH))
-		sync_mm_rss(task->mm);
-}
 #else /* SPLIT_RSS_COUNTING */
 
 #define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
 #define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
 
-static void check_sync_rss_stat(struct task_struct *task)
-{
-}
-
 #endif /* SPLIT_RSS_COUNTING */
 
 #ifdef HAVE_GENERIC_MMU_GATHER
@@ -3319,9 +3316,6 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	count_vm_event(PGFAULT);
 	mem_cgroup_count_vm_event(mm, PGFAULT);
 
-	/* do counter updates before entering really critical section. */
-	check_sync_rss_stat(current);
-
 	/*
 	 * Enable the memcg OOM handling for faults triggered in user
 	 * space.  Kernel faults are handled more gracefully.
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
