Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4A28D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:48:19 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1558450Ab1C1Jr5 (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:47:57 +0200
Date: Mon, 28 Mar 2011 11:47:57 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110328094757.GJ13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Memory hotplug support for Xen balloon driver. It should be
mentioned that hotplugged memory is not onlined automatically.
It should be onlined by user through standard sysfs interface.

There are a few prerequisite patches which fixes some problems
found during work on memory hotplug patch or add some futures
which are needed by this patch. They are available here:
  - https://lkml.org/lkml/2011/3/28/94,
  - https://lkml.org/lkml/2011/3/28/98.

I have received notice that previous series of patches broke
machine migration under Xen. I am going to confirm that and
solve that problem ASAP. I do not have received any notices
about other problems till now.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/Kconfig   |   10 +++
 drivers/xen/balloon.c |  148 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/xen/balloon.h |    4 +
 3 files changed, 160 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index e5ecae6..39df71b 100644
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
index f54290b..189023e 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -4,6 +4,12 @@
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
@@ -40,6 +46,9 @@
 #include <linux/mutex.h>
 #include <linux/list.h>
 #include <linux/gfp.h>
+#include <linux/notifier.h>
+#include <linux/memory.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/page.h>
 #include <asm/pgalloc.h>
@@ -194,6 +203,96 @@ static enum bp_state update_schedule(enum bp_state state)
 	return BP_EAGAIN;
 }
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+static long current_credit(void)
+{
+	return balloon_stats.target_pages - balloon_stats.current_pages -
+		balloon_stats.hotplug_pages;
+}
+
+static bool balloon_is_inflated(void)
+{
+	if (balloon_stats.balloon_low || balloon_stats.balloon_high ||
+			balloon_stats.balloon_hotplug)
+		return true;
+	else
+		return false;
+}
+
+/*
+ * reserve_additional_memory() adds memory region of size >= credit above
+ * max_pfn. New region is section aligned and size is modified to be multiple
+ * of section size. Those features allow optimal use of address space and
+ * establish proper alignment when this function is called first time after
+ * boot (last section not fully populated at boot time may contains unused
+ * memory pages with PG_reserved bit not set; online_pages() does not allow
+ * page onlining in whole section if first page does not have PG_reserved
+ * bit set). Real size of added memory is established at page onlining stage.
+ */
+
+static enum bp_state reserve_additional_memory(long credit)
+{
+	int nid, rc;
+	u64 start;
+	unsigned long balloon_hotplug = credit;
+
+	start = PFN_PHYS(SECTION_ALIGN_UP(max_pfn));
+	balloon_hotplug = (balloon_hotplug & PAGE_SECTION_MASK) + PAGES_PER_SECTION;
+	nid = memory_add_physaddr_to_nid(start);
+
+	rc = add_memory(nid, start, balloon_hotplug << PAGE_SHIFT);
+
+	if (rc) {
+		pr_info("xen_balloon: %s: add_memory() failed: %i\n", __func__, rc);
+		return BP_EAGAIN;
+	}
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
+
+	__online_page_increment_counters(page, OP_DO_NOT_INCREMENT_TOTAL_COUNTERS);
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
 static long current_credit(void)
 {
 	unsigned long target = balloon_stats.target_pages;
@@ -206,6 +305,21 @@ static long current_credit(void)
 	return target - balloon_stats.current_pages;
 }
 
+static int balloon_is_inflated(void)
+{
+	if (balloon_stats.balloon_low || balloon_stats.balloon_high)
+		return 1;
+	else
+		return 0;
+}
+
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
@@ -217,6 +331,15 @@ static enum bp_state increase_reservation(unsigned long nr_pages)
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
 
@@ -279,6 +402,15 @@ static enum bp_state decrease_reservation(unsigned long nr_pages, gfp_t gfp)
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
 
@@ -340,8 +472,12 @@ static void balloon_process(struct work_struct *work)
 	do {
 		credit = current_credit();
 
-		if (credit > 0)
-			state = increase_reservation(credit);
+		if (credit > 0) {
+			if (balloon_is_inflated())
+				state = increase_reservation(credit);
+			else
+				state = reserve_additional_memory(credit);
+		}
 
 		if (credit < 0)
 			state = decrease_reservation(-credit, GFP_BALLOON);
@@ -448,6 +584,14 @@ static int __init balloon_init(void)
 	balloon_stats.retry_count = 1;
 	balloon_stats.max_retry_count = RETRY_UNLIMITED;
 
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	balloon_stats.hotplug_pages = 0;
+	balloon_stats.balloon_hotplug = 0;
+
+	register_online_page_notifier(&xen_online_page_nb);
+	register_memory_notifier(&xen_memory_nb);
+#endif
+
 	/*
 	 * Initialise the balloon with excess memory space.  We need
 	 * to make sure we don't add memory which doesn't exist or
diff --git a/include/xen/balloon.h b/include/xen/balloon.h
index a2b22f0..aeca6ae 100644
--- a/include/xen/balloon.h
+++ b/include/xen/balloon.h
@@ -15,6 +15,10 @@ struct balloon_stats {
 	unsigned long max_schedule_delay;
 	unsigned long retry_count;
 	unsigned long max_retry_count;
+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
+	unsigned long hotplug_pages;
+	unsigned long balloon_hotplug;
+#endif
 };
 
 extern struct balloon_stats balloon_stats;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
