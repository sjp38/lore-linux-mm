Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5698D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 16:47:58 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578060Ab1CHVrj (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 8 Mar 2011 22:47:39 +0100
Date: Tue, 8 Mar 2011 22:47:39 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R4 3/7] xen/balloon: Migration from mod_timer() to schedule_delayed_work()
Message-ID: <20110308214739.GD27331@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Migration from mod_timer() to schedule_delayed_work().

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/balloon.c |   16 +++-------------
 1 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 952cfe2..4223f64 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -99,8 +99,7 @@ static LIST_HEAD(ballooned_pages);
 
 /* Main work function, always executed in process context. */
 static void balloon_process(struct work_struct *work);
-static DECLARE_WORK(balloon_worker, balloon_process);
-static struct timer_list balloon_timer;
+static DECLARE_DELAYED_WORK(balloon_worker, balloon_process);
 
 /* When ballooning out (allocating memory to return to Xen) we don't really
    want the kernel to try too hard since that can trigger the oom killer. */
@@ -172,11 +171,6 @@ static struct page *balloon_next_page(struct page *page)
 	return list_entry(next, struct page, lru);
 }
 
-static void balloon_alarm(unsigned long unused)
-{
-	schedule_work(&balloon_worker);
-}
-
 static unsigned long current_target(void)
 {
 	unsigned long target = balloon_stats.target_pages;
@@ -333,7 +327,7 @@ static void balloon_process(struct work_struct *work)
 
 	/* Schedule more work if there is some still to be done. */
 	if (current_target() != balloon_stats.current_pages)
-		mod_timer(&balloon_timer, jiffies + HZ);
+		schedule_delayed_work(&balloon_worker, HZ);
 
 	mutex_unlock(&balloon_mutex);
 }
@@ -343,7 +337,7 @@ static void balloon_set_new_target(unsigned long target)
 {
 	/* No need for lock. Not read-modify-write updates. */
 	balloon_stats.target_pages = target;
-	schedule_work(&balloon_worker);
+	schedule_delayed_work(&balloon_worker, 0);
 }
 
 static struct xenbus_watch target_watch =
@@ -400,10 +394,6 @@ static int __init balloon_init(void)
 	balloon_stats.balloon_low   = 0;
 	balloon_stats.balloon_high  = 0;
 
-	init_timer(&balloon_timer);
-	balloon_timer.data = 0;
-	balloon_timer.function = balloon_alarm;
-
 	register_balloon(&balloon_sysdev);
 
 	/*
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
