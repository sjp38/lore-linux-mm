Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 42310900137
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 04:13:12 -0400 (EDT)
Subject: [patch 3/3]vmscan: cleanup kswapd_try_to_sleep
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Jul 2011 16:13:09 +0800
Message-ID: <1311840789.15392.409.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, mgorman@suse.de, Minchan Kim <minchan.kim@gmail.com>

cleanup kswapd_try_to_sleep() a little bit. Sometimes kswapd doesn't
really sleep. In such case, don't call prepare_to_wait/finish_wait.
It just wastes CPU.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/vmscan.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-07-28 15:52:35.000000000 +0800
+++ linux/mm/vmscan.c	2011-07-28 15:55:56.000000000 +0800
@@ -2709,13 +2709,11 @@ static void kswapd_try_to_sleep(pg_data_
 	if (freezing(current) || kthread_should_stop())
 		return;
 
-	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-
 	/* Try to sleep for a short interval */
 	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
+		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 		remaining = schedule_timeout(HZ/10);
 		finish_wait(&pgdat->kswapd_wait, &wait);
-		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 	}
 
 	/*
@@ -2734,7 +2732,9 @@ static void kswapd_try_to_sleep(pg_data_
 		 * them before going back to sleep.
 		 */
 		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
+		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 		schedule();
+		finish_wait(&pgdat->kswapd_wait, &wait);
 		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
 	} else {
 		if (remaining)
@@ -2742,7 +2742,6 @@ static void kswapd_try_to_sleep(pg_data_
 		else
 			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
 	}
-	finish_wait(&pgdat->kswapd_wait, &wait);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
