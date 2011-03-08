Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 952248D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 16:48:46 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578060Ab1CHVsY (ORCPT <rfc822;linux-mm@kvack.org>);
	Tue, 8 Mar 2011 22:48:24 +0100
Date: Tue, 8 Mar 2011 22:48:24 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH R4 4/7] xen/balloon: Protect against CPU exhaust by event/x process
Message-ID: <20110308214824.GE27331@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Protect against CPU exhaust by event/x process during
errors by adding some delays in scheduling next event
and retry count limit.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 drivers/xen/balloon.c |  107 +++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 90 insertions(+), 17 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 4223f64..6bae013 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -66,6 +66,22 @@
 
 #define BALLOON_CLASS_NAME "xen_memory"
 
+/*
+ * balloon_process() state:
+ *
+ * BP_DONE: done or nothing to do,
+ * BP_EAGAIN: error, go to sleep,
+ * BP_ECANCELED: error, balloon operation canceled.
+ */
+
+enum bp_state {
+	BP_DONE,
+	BP_EAGAIN,
+	BP_ECANCELED
+};
+
+#define RETRY_UNLIMITED	0
+
 struct balloon_stats {
 	/* We aim for 'current allocation' == 'target allocation'. */
 	unsigned long current_pages;
@@ -73,6 +89,10 @@ struct balloon_stats {
 	/* Number of pages in high- and low-memory balloons. */
 	unsigned long balloon_low;
 	unsigned long balloon_high;
+	unsigned long schedule_delay;
+	unsigned long max_schedule_delay;
+	unsigned long retry_count;
+	unsigned long max_retry_count;
 };
 
 static DEFINE_MUTEX(balloon_mutex);
@@ -171,6 +191,36 @@ static struct page *balloon_next_page(struct page *page)
 	return list_entry(next, struct page, lru);
 }
 
+static enum bp_state update_schedule(enum bp_state state)
+{
+	if (state == BP_DONE) {
+		balloon_stats.schedule_delay = 1;
+		balloon_stats.retry_count = 1;
+		return BP_DONE;
+	}
+
+	pr_info("xen_balloon: Retry count: %lu/%lu\n", balloon_stats.retry_count,
+			balloon_stats.max_retry_count);
+
+	++balloon_stats.retry_count;
+
+	if (balloon_stats.max_retry_count != RETRY_UNLIMITED &&
+			balloon_stats.retry_count > balloon_stats.max_retry_count) {
+		pr_info("xen_balloon: Retry count limit exceeded\n"
+			"xen_balloon: Balloon operation canceled\n");
+		balloon_stats.schedule_delay = 1;
+		balloon_stats.retry_count = 1;
+		return BP_ECANCELED;
+	}
+
+	balloon_stats.schedule_delay <<= 1;
+
+	if (balloon_stats.schedule_delay > balloon_stats.max_schedule_delay)
+		balloon_stats.schedule_delay = balloon_stats.max_schedule_delay;
+
+	return BP_EAGAIN;
+}
+
 static unsigned long current_target(void)
 {
 	unsigned long target = balloon_stats.target_pages;
@@ -183,11 +233,11 @@ static unsigned long current_target(void)
 	return target;
 }
 
-static int increase_reservation(unsigned long nr_pages)
+static enum bp_state increase_reservation(unsigned long nr_pages)
 {
+	int rc;
 	unsigned long  pfn, i;
 	struct page   *page;
-	long           rc;
 	struct xen_memory_reservation reservation = {
 		.address_bits = 0,
 		.extent_order = 0,
@@ -199,7 +249,10 @@ static int increase_reservation(unsigned long nr_pages)
 
 	page = balloon_first_page();
 	for (i = 0; i < nr_pages; i++) {
-		BUG_ON(page == NULL);
+		if (!page) {
+			nr_pages = i;
+			break;
+		}
 		frame_list[i] = page_to_pfn(page);
 		page = balloon_next_page(page);
 	}
@@ -207,8 +260,10 @@ static int increase_reservation(unsigned long nr_pages)
 	set_xen_guest_handle(reservation.extent_start, frame_list);
 	reservation.nr_extents = nr_pages;
 	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
-	if (rc < 0)
-		goto out;
+	if (rc <= 0) {
+		pr_info("xen_balloon: %s: Cannot allocate memory\n", __func__);
+		return BP_EAGAIN;
+	}
 
 	for (i = 0; i < rc; i++) {
 		page = balloon_retrieve();
@@ -238,15 +293,14 @@ static int increase_reservation(unsigned long nr_pages)
 
 	balloon_stats.current_pages += rc;
 
- out:
-	return rc < 0 ? rc : rc != nr_pages;
+	return BP_DONE;
 }
 
-static int decrease_reservation(unsigned long nr_pages)
+static enum bp_state decrease_reservation(unsigned long nr_pages)
 {
+	enum bp_state state = BP_DONE;
 	unsigned long  pfn, i;
 	struct page   *page;
-	int            need_sleep = 0;
 	int ret;
 	struct xen_memory_reservation reservation = {
 		.address_bits = 0,
@@ -259,8 +313,9 @@ static int decrease_reservation(unsigned long nr_pages)
 
 	for (i = 0; i < nr_pages; i++) {
 		if ((page = alloc_page(GFP_BALLOON)) == NULL) {
+			pr_info("xen_balloon: %s: Cannot allocate memory\n", __func__);
 			nr_pages = i;
-			need_sleep = 1;
+			state = BP_EAGAIN;
 			break;
 		}
 
@@ -296,7 +351,7 @@ static int decrease_reservation(unsigned long nr_pages)
 
 	balloon_stats.current_pages -= nr_pages;
 
-	return need_sleep;
+	return state;
 }
 
 /*
@@ -307,27 +362,31 @@ static int decrease_reservation(unsigned long nr_pages)
  */
 static void balloon_process(struct work_struct *work)
 {
-	int need_sleep = 0;
+	enum bp_state state = BP_DONE;
 	long credit;
 
 	mutex_lock(&balloon_mutex);
 
 	do {
 		credit = current_target() - balloon_stats.current_pages;
+
 		if (credit > 0)
-			need_sleep = (increase_reservation(credit) != 0);
+			state = increase_reservation(credit);
+
 		if (credit < 0)
-			need_sleep = (decrease_reservation(-credit) != 0);
+			state = decrease_reservation(-credit);
+
+		state = update_schedule(state);
 
 #ifndef CONFIG_PREEMPT
 		if (need_resched())
 			schedule();
 #endif
-	} while ((credit != 0) && !need_sleep);
+	} while (credit && state == BP_DONE);
 
 	/* Schedule more work if there is some still to be done. */
-	if (current_target() != balloon_stats.current_pages)
-		schedule_delayed_work(&balloon_worker, HZ);
+	if (state == BP_EAGAIN)
+		schedule_delayed_work(&balloon_worker, balloon_stats.schedule_delay * HZ);
 
 	mutex_unlock(&balloon_mutex);
 }
@@ -394,6 +453,11 @@ static int __init balloon_init(void)
 	balloon_stats.balloon_low   = 0;
 	balloon_stats.balloon_high  = 0;
 
+	balloon_stats.schedule_delay = 1;
+	balloon_stats.max_schedule_delay = 32;
+	balloon_stats.retry_count = 1;
+	balloon_stats.max_retry_count = 16;
+
 	register_balloon(&balloon_sysdev);
 
 	/*
@@ -447,6 +511,11 @@ BALLOON_SHOW(current_kb, "%lu\n", PAGES2KB(balloon_stats.current_pages));
 BALLOON_SHOW(low_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_low));
 BALLOON_SHOW(high_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_high));
 
+static SYSDEV_ULONG_ATTR(schedule_delay, 0444, balloon_stats.schedule_delay);
+static SYSDEV_ULONG_ATTR(max_schedule_delay, 0644, balloon_stats.max_schedule_delay);
+static SYSDEV_ULONG_ATTR(retry_count, 0444, balloon_stats.retry_count);
+static SYSDEV_ULONG_ATTR(max_retry_count, 0644, balloon_stats.max_retry_count);
+
 static ssize_t show_target_kb(struct sys_device *dev, struct sysdev_attribute *attr,
 			      char *buf)
 {
@@ -508,6 +577,10 @@ static SYSDEV_ATTR(target, S_IRUGO | S_IWUSR,
 static struct sysdev_attribute *balloon_attrs[] = {
 	&attr_target_kb,
 	&attr_target,
+	&attr_schedule_delay.attr,
+	&attr_max_schedule_delay.attr,
+	&attr_retry_count.attr,
+	&attr_max_retry_count.attr
 };
 
 static struct attribute *balloon_info_attrs[] = {
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
