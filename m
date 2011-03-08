From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R4 1/7] xen/balloon: Removal of driver_pages
Date: Tue, 8 Mar 2011 22:45:46 +0100
Message-ID: <20110308214546.GB27331__7281.90973536602$1299620793$gmane$org@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Px4jV-0001ot-57
	for glkm-linux-mm-2@m.gmane.org; Tue, 08 Mar 2011 22:46:21 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B96B8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 16:46:19 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578948Ab1CHVpq (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 8 Mar 2011 22:45:46 +0100
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer

Removal of driver_pages (I do not have seen any references to it).

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 arch/x86/xen/mmu.c    |    3 +--
 drivers/xen/balloon.c |    8 --------
 2 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 5e92b61..e7c378e 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -78,8 +78,7 @@
 
 /*
  * Protects atomic reservation decrease/increase against concurrent increases.
- * Also protects non-atomic updates of current_pages and driver_pages, and
- * balloon lists.
+ * Also protects non-atomic updates of current_pages and balloon lists.
  */
 DEFINE_SPINLOCK(xen_reservation_lock);
 
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 43f9f02..b4206fd 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -70,11 +70,6 @@ struct balloon_stats {
 	/* We aim for 'current allocation' == 'target allocation'. */
 	unsigned long current_pages;
 	unsigned long target_pages;
-	/*
-	 * Drivers may alter the memory reservation independently, but they
-	 * must inform the balloon driver so we avoid hitting the hard limit.
-	 */
-	unsigned long driver_pages;
 	/* Number of pages in high- and low-memory balloons. */
 	unsigned long balloon_low;
 	unsigned long balloon_high;
@@ -404,7 +399,6 @@ static int __init balloon_init(void)
 	balloon_stats.target_pages  = balloon_stats.current_pages;
 	balloon_stats.balloon_low   = 0;
 	balloon_stats.balloon_high  = 0;
-	balloon_stats.driver_pages  = 0UL;
 
 	init_timer(&balloon_timer);
 	balloon_timer.data = 0;
@@ -462,7 +456,6 @@ module_exit(balloon_exit);
 BALLOON_SHOW(current_kb, "%lu\n", PAGES2KB(balloon_stats.current_pages));
 BALLOON_SHOW(low_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_low));
 BALLOON_SHOW(high_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_high));
-BALLOON_SHOW(driver_kb, "%lu\n", PAGES2KB(balloon_stats.driver_pages));
 
 static ssize_t show_target_kb(struct sys_device *dev, struct sysdev_attribute *attr,
 			      char *buf)
@@ -531,7 +524,6 @@ static struct attribute *balloon_info_attrs[] = {
 	&attr_current_kb.attr,
 	&attr_low_kb.attr,
 	&attr_high_kb.attr,
-	&attr_driver_kb.attr,
 	NULL
 };
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
