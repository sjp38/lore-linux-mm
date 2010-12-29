Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 81C636B0092
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 12:07:31 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1564497Ab0L2RCu (ORCPT <rfc822;linux-mm@kvack.org>);
	Wed, 29 Dec 2010 18:02:50 +0100
Date: Wed, 29 Dec 2010 18:02:50 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R2 2/7] xen/balloon: Removal of driver_pages
Message-ID: <20101229170250.GG2743@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Removal of driver_pages (I do not have seen any references to it).

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 arch/x86/xen/mmu.c    |    3 +--
 drivers/xen/balloon.c |    8 --------
 2 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 42086ac..6278650 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -75,8 +75,7 @@
 
 /*
  * Protects atomic reservation decrease/increase against concurrent increases.
- * Also protects non-atomic updates of current_pages and driver_pages, and
- * balloon lists.
+ * Also protects non-atomic updates of current_pages and balloon lists.
  */
 DEFINE_SPINLOCK(xen_reservation_lock);
 
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 500290b..97919af 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -69,11 +69,6 @@ struct balloon_stats {
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
@@ -407,7 +402,6 @@ static int __init balloon_init(void)
 	balloon_stats.target_pages  = balloon_stats.current_pages;
 	balloon_stats.balloon_low   = 0;
 	balloon_stats.balloon_high  = 0;
-	balloon_stats.driver_pages  = 0UL;
 
 	init_timer(&balloon_timer);
 	balloon_timer.data = 0;
@@ -452,7 +446,6 @@ module_exit(balloon_exit);
 BALLOON_SHOW(current_kb, "%lu\n", PAGES2KB(balloon_stats.current_pages));
 BALLOON_SHOW(low_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_low));
 BALLOON_SHOW(high_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_high));
-BALLOON_SHOW(driver_kb, "%lu\n", PAGES2KB(balloon_stats.driver_pages));
 
 static ssize_t show_target_kb(struct sys_device *dev, struct sysdev_attribute *attr,
 			      char *buf)
@@ -521,7 +514,6 @@ static struct attribute *balloon_info_attrs[] = {
 	&attr_current_kb.attr,
 	&attr_low_kb.attr,
 	&attr_high_kb.attr,
-	&attr_driver_kb.attr,
 	NULL
 };
 
-- 
1.4.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
