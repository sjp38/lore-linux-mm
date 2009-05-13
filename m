Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DAC756B00D4
	for <linux-mm@kvack.org>; Wed, 13 May 2009 05:11:24 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 3/6] mm, PM/Freezer: Disable OOM killer when tasks are frozen
Date: Wed, 13 May 2009 10:37:49 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905101548.57557.rjw@sisk.pl> <200905131032.53624.rjw@sisk.pl>
In-Reply-To: <200905131032.53624.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905131037.50011.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: pm list <linux-pm@lists.linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Currently, the following scenario appears to be possible in theory:

* Tasks are frozen for hibernation or suspend.
* Free pages are almost exhausted.
* Certain piece of code in the suspend code path attempts to allocate
  some memory using GFP_KERNEL and allocation order less than or
  equal to PAGE_ALLOC_COSTLY_ORDER.
* __alloc_pages_internal() cannot find a free page so it invokes the
  OOM killer.
* The OOM killer attempts to kill a task, but the task is frozen, so
  it doesn't die immediately.
* __alloc_pages_internal() jumps to 'restart', unsuccessfully tries
  to find a free page and invokes the OOM killer.
* No progress can be made.

Although it is now hard to trigger during hibernation due to the
memory shrinking carried out by the hibernation code, it is
theoretically possible to trigger during suspend after the memory
shrinking has been removed from that code path.  Moreover, since
memory allocations are going to be used for the hibernation memory
shrinking, it will be even more likely to happen during hibernation.

To prevent it from happening, introduce the oom_killer_disabled
switch that will cause __alloc_pages_internal() to fail in the
situations in which the OOM killer would have been called and make
the freezer set this switch after tasks have been successfully
frozen.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 include/linux/gfp.h    |   12 ++++++++++++
 kernel/power/process.c |    5 +++++
 mm/page_alloc.c        |    5 +++++
 3 files changed, 22 insertions(+)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -175,6 +175,8 @@ static void set_pageblock_migratetype(st
 					PB_migrate, PB_migrate_end);
 }
 
+bool oom_killer_disabled __read_mostly;
+
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
@@ -1600,6 +1602,9 @@ nofail_alloc:
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
+		if (oom_killer_disabled)
+			goto nopage;
+
 		if (!try_set_zone_oom(zonelist, gfp_mask)) {
 			schedule_timeout_uninterruptible(1);
 			goto restart;
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h
+++ linux-2.6/include/linux/gfp.h
@@ -245,4 +245,16 @@ void drain_zone_pages(struct zone *zone,
 void drain_all_pages(void);
 void drain_local_pages(void *dummy);
 
+extern bool oom_killer_disabled;
+
+static inline void oom_killer_disable(void)
+{
+	oom_killer_disabled = true;
+}
+
+static inline void oom_killer_enable(void)
+{
+	oom_killer_disabled = false;
+}
+
 #endif /* __LINUX_GFP_H */
Index: linux-2.6/kernel/power/process.c
===================================================================
--- linux-2.6.orig/kernel/power/process.c
+++ linux-2.6/kernel/power/process.c
@@ -117,9 +117,12 @@ int freeze_processes(void)
 	if (error)
 		goto Exit;
 	printk("done.");
+
+	oom_killer_disable();
  Exit:
 	BUG_ON(in_atomic());
 	printk("\n");
+
 	return error;
 }
 
@@ -145,6 +148,8 @@ static void thaw_tasks(bool nosig_only)
 
 void thaw_processes(void)
 {
+	oom_killer_enable();
+
 	printk("Restarting tasks ... ");
 	thaw_tasks(true);
 	thaw_tasks(false);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
