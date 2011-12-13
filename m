Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 859FA6B0278
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 12:44:36 -0500 (EST)
Received: by yhjj63 with SMTP id j63so90795yhj.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 09:44:35 -0800 (PST)
From: Mike Waychison <mikew@google.com>
Subject: [PATCH] mm: Fix kswapd livelock on single core, no preempt kernel
Date: Tue, 13 Dec 2011 09:44:31 -0800
Message-Id: <1323798271-1452-1-git-send-email-mikew@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickens <hughd@google.com>, Greg Thelen <gthelen@google.com>, Mike Waychison <mikew@google.com>

On a single core system with kernel preemption disabled, it is possible
for the memory system to be so taxed that kswapd cannot make any forward
progress.  This can happen when most of system memory is tied up as
anonymous memory without swap enabled, causing kswapd to consistently
fail to achieve its watermark goals.  In turn, sleeping_prematurely()
will consistently return true and kswapd_try_to_sleep() to never invoke
schedule().  This causes the kswapd thread to stay on the CPU in
perpetuity and keeps other threads from processing oom-kills to reclaim
memory.

The cond_resched() instance in balance_pgdat() is never called as the
loop that iterates from DEF_PRIORITY down to 0 will always set
all_zones_ok to true, and not set it to false once we've passed
DEF_PRIORITY as zones that are marked ->all_unreclaimable are not
considered in the "all_zones_ok" evaluation.

This change modifies kswapd_try_to_sleep to ensure that we enter
scheduler at least once per invocation if needed.  This allows kswapd to
get off the CPU and allows other threads to die off from the OOM killer
(freeing memory that is otherwise unavailable in the process).

Signed-off-by: Mike Waychison <mikew@google.com>
---
 mm/vmscan.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f54a05b..aad70c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2794,6 +2794,7 @@ out:
 static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	long remaining = 0;
+	bool slept = false;
 	DEFINE_WAIT(wait);
 
 	if (freezing(current) || kthread_should_stop())
@@ -2806,6 +2807,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		remaining = schedule_timeout(HZ/10);
 		finish_wait(&pgdat->kswapd_wait, &wait);
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+		slept = true;
 	}
 
 	/*
@@ -2826,6 +2828,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
 		schedule();
 		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
+		slept = true;
 	} else {
 		if (remaining)
 			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
@@ -2833,6 +2836,14 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
 	}
 	finish_wait(&pgdat->kswapd_wait, &wait);
+	/*
+	 * If we did not sleep already, there is a chance that we will sit on
+	 * the CPU trashing without making any forward progress.  This can
+	 * lead to a livelock on a single CPU system without kernel pre-emption,
+	 * so introduce a voluntary context switch.
+	 */
+	if (!slept)
+		cond_resched();
 }
 
 /*
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
