Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 792138D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:34:26 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1577721Ab1C1JeK (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:34:10 +0200
Date: Mon, 28 Mar 2011 11:34:10 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 3/4] xen/balloon: Clarify credit calculation
Message-ID: <20110328093410.GH13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Move credit calculation to current_target()
and rename it to current_credit().

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/balloon.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 42a0ba0..a6d8e59 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -193,7 +193,7 @@ static enum bp_state update_schedule(enum bp_state state)
 	return BP_EAGAIN;
 }
 
-static unsigned long current_target(void)
+static long current_credit(void)
 {
 	unsigned long target = balloon_stats.target_pages;
 
@@ -202,7 +202,7 @@ static unsigned long current_target(void)
 		     balloon_stats.balloon_low +
 		     balloon_stats.balloon_high);
 
-	return target;
+	return target - balloon_stats.current_pages;
 }
 
 static enum bp_state increase_reservation(unsigned long nr_pages)
@@ -337,7 +337,7 @@ static void balloon_process(struct work_struct *work)
 	mutex_lock(&balloon_mutex);
 
 	do {
-		credit = current_target() - balloon_stats.current_pages;
+		credit = current_credit();
 
 		if (credit > 0)
 			state = increase_reservation(credit);
@@ -420,7 +420,7 @@ void free_xenballooned_pages(int nr_pages, struct page** pages)
 	}
 
 	/* The balloon may be too large now. Shrink it if needed. */
-	if (current_target() != balloon_stats.current_pages)
+	if (current_credit())
 		schedule_delayed_work(&balloon_worker, 0);
 
 	mutex_unlock(&balloon_mutex);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
