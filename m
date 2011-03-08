Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4128D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 16:51:12 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1579019Ab1CHVut (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 8 Mar 2011 22:50:49 +0100
Date: Tue, 8 Mar 2011 22:50:49 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R4 7/7] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110308215049.GH27331@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Memory hotplug support for Xen balloon driver. It should be
mentioned that hotplugged memory is not onlined automatically.
It should be onlined by user through standard sysfs interface.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/Kconfig   |   10 +++
 drivers/xen/balloon.c |  154 +++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 159 insertions(+), 5 deletions(-)

diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index 07bec09..8f880aa 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -9,6 +9,16 @@ config XEN_BALLOON
 	  the system to expand the domain's memory allocation, or alternatively
 	  return unneeded memory to the system.
 
+config XEN_BALLOON_MEMORY_HOTPLUG
+	bool "Memory hotplug support for Xen balloon driver"
+	default n
+	depends on XEN_BALLOON && MEMORY_HOTPLUG
+	help
+	  Memory hotplug support for Xen balloon driver allows expanding memory
+	  available for the system above limit declared at system startup.
+	  It is very useful on critical systems which require long
+	  run without rebooting.
+
 config XEN_SCRUB_PAGES
 	bool "Scrub pages before returning them to system"
 	depends on XEN_BALLOON
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 431e9f0..3dc8a83 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -6,6 +6,12 @@
  * Copyright (c) 2003, B Dragovic
  * Copyright (c) 2003-2004, M Williamson, K Fraser
  * Copyright (c) 2005 Dan M. Smith, IBM Corporation
+ * Copyright (c) 2010 Daniel Kiper
+ *
+ * Memory hotplug support was written by Daniel Kiper. Work on
+ * it was sponsored by Google under Google Summer of Code 2010
+ * program. Jeremy Fitzhardinge from Xen.org was the mentor for
+ * this project.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -44,6 +50,9 @@
 #include <linux/list.h>
 #include <linux/sysdev.h>
 #include <linux/gfp.h>
+#include <linux/notifier.h>
+#include <linux/memory.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/page.h>
 #include <asm/pgalloc.h>
@@ -93,6 +102,10 @@ struct balloon_stats {
 	unsigned long max_schedule_delay;
 	unsigned long retry_count;
 	unsigned long max_retry_count;
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	unsigned long hotplug_pages;
+	unsigned long balloon_hotplug;
+#endif
 };
 
 static DEFINE_MUTEX(balloon_mutex);
@@ -221,7 +234,93 @@ static enum bp_state update_schedule(enum bp_state state)
 	return BP_EAGAIN;
 }
 
-static unsigned long current_target(void)
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+static long current_credit(void)
+{
+	return balloon_stats.target_pages - balloon_stats.current_pages -
+		balloon_stats.hotplug_pages;
+}
+
+static int balloon_is_inflated(void)
+{
+	if (balloon_stats.balloon_low || balloon_stats.balloon_high ||
+			balloon_stats.balloon_hotplug)
+		return 1;
+	else
+		return 0;
+}
+
+static enum bp_state reserve_additional_memory(long credit)
+{
+	int rc;
+	unsigned long balloon_hotplug = credit;
+
+	balloon_hotplug <<= PAGE_SHIFT;
+
+	rc = add_virtual_memory((u64 *)&balloon_hotplug);
+
+	if (rc) {
+		pr_info("xen_balloon: %s: add_virtual_memory() failed: %i\n", __func__, rc);
+		return BP_EAGAIN;
+	}
+
+	balloon_hotplug >>= PAGE_SHIFT;
+
+	balloon_hotplug -= credit;
+
+	balloon_stats.hotplug_pages += credit;
+	balloon_stats.balloon_hotplug = balloon_hotplug;
+
+	return BP_DONE;
+}
+
+static int xen_online_page_notifier(struct notifier_block *nb, unsigned long val, void *v)
+{
+	struct page *page = v;
+	unsigned long pfn = page_to_pfn(page);
+
+	if (pfn >= num_physpages)
+		num_physpages = pfn + 1;
+
+	inc_totalhigh_pages();
+
+#ifdef CONFIG_FLATMEM
+	max_mapnr = max(pfn, max_mapnr);
+#endif
+
+	mutex_lock(&balloon_mutex);
+
+	__balloon_append(page);
+
+	if (balloon_stats.hotplug_pages)
+		--balloon_stats.hotplug_pages;
+	else
+		--balloon_stats.balloon_hotplug;
+
+	mutex_unlock(&balloon_mutex);
+
+	return NOTIFY_STOP;
+}
+
+static struct notifier_block xen_online_page_nb = {
+	.notifier_call = xen_online_page_notifier,
+	.priority = 10
+};
+
+static int xen_memory_notifier(struct notifier_block *nb, unsigned long val, void *v)
+{
+	if (val == MEM_ONLINE)
+		schedule_delayed_work(&balloon_worker, 0);
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block xen_memory_nb = {
+	.notifier_call = xen_memory_notifier,
+	.priority = 0
+};
+#else
+static long current_credit(void)
 {
 	unsigned long target = balloon_stats.target_pages;
 
@@ -230,9 +329,24 @@ static unsigned long current_target(void)
 		     balloon_stats.balloon_low +
 		     balloon_stats.balloon_high);
 
-	return target;
+	return target - balloon_stats.current_pages;
+}
+
+static int balloon_is_inflated(void)
+{
+	if (balloon_stats.balloon_low || balloon_stats.balloon_high)
+		return 1;
+	else
+		return 0;
 }
 
+static enum bp_state reserve_additional_memory(long credit)
+{
+	balloon_stats.target_pages = balloon_stats.current_pages;
+	return BP_DONE;
+}
+#endif /* CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */
+
 static enum bp_state increase_reservation(unsigned long nr_pages)
 {
 	int rc;
@@ -244,6 +358,15 @@ static enum bp_state increase_reservation(unsigned long nr_pages)
 		.domid        = DOMID_SELF
 	};
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	if (!balloon_stats.balloon_low && !balloon_stats.balloon_high) {
+		nr_pages = min(nr_pages, balloon_stats.balloon_hotplug);
+		balloon_stats.hotplug_pages += nr_pages;
+		balloon_stats.balloon_hotplug -= nr_pages;
+		return BP_DONE;
+	}
+#endif
+
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages = ARRAY_SIZE(frame_list);
 
@@ -308,6 +431,15 @@ static enum bp_state decrease_reservation(unsigned long nr_pages)
 		.domid        = DOMID_SELF
 	};
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	if (balloon_stats.hotplug_pages) {
+		nr_pages = min(nr_pages, balloon_stats.hotplug_pages);
+		balloon_stats.hotplug_pages -= nr_pages;
+		balloon_stats.balloon_hotplug += nr_pages;
+		return BP_DONE;
+	}
+#endif
+
 	if (nr_pages > ARRAY_SIZE(frame_list))
 		nr_pages = ARRAY_SIZE(frame_list);
 
@@ -368,10 +500,14 @@ static void balloon_process(struct work_struct *work)
 	mutex_lock(&balloon_mutex);
 
 	do {
-		credit = current_target() - balloon_stats.current_pages;
+		credit = current_credit();
 
-		if (credit > 0)
-			state = increase_reservation(credit);
+		if (credit > 0) {
+			if (balloon_is_inflated())
+				state = increase_reservation(credit);
+			else
+				state = reserve_additional_memory(credit);
+		}
 
 		if (credit < 0)
 			state = decrease_reservation(-credit);
@@ -458,6 +594,14 @@ static int __init balloon_init(void)
 	balloon_stats.retry_count = 1;
 	balloon_stats.max_retry_count = 16;
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	balloon_stats.hotplug_pages = 0;
+	balloon_stats.balloon_hotplug = 0;
+
+	register_online_page_notifier(&xen_online_page_nb);
+	register_memory_notifier(&xen_memory_nb);
+#endif
+
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
