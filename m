Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9486B0093
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 08:50:35 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1558596Ab0LTNrY (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 20 Dec 2010 14:47:24 +0100
Date: Mon, 20 Dec 2010 14:47:24 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 2/3] drivers/xen/balloon.c: Various balloon features and fixes
Message-ID: <20101220134724.GC6749@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Features and fixes:
  - HVM mode is supported now,
  - migration from mod_timer() to schedule_delayed_work(),
  - removal of driver_pages (I do not have seen any
    references to it),
  - protect before CPU exhaust by event/x process during
    errors by adding some delays in scheduling next event,
  - some other minor fixes.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 arch/x86/xen/mmu.c    |    3 +-
 drivers/xen/balloon.c |  128 +++++++++++++++++++++++++++++++++----------------
 2 files changed, 87 insertions(+), 44 deletions(-)

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
index 500290b..06dbdad 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -69,14 +69,11 @@ struct balloon_stats {
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
+	unsigned long schedule_delay;
+	unsigned long max_schedule_delay;
 };
 
 static DEFINE_MUTEX(balloon_mutex);
@@ -103,15 +100,14 @@ static LIST_HEAD(ballooned_pages);
 
 /* Main work function, always executed in process context. */
 static void balloon_process(struct work_struct *work);
-static DECLARE_WORK(balloon_worker, balloon_process);
-static struct timer_list balloon_timer;
+static DECLARE_DELAYED_WORK(balloon_worker, balloon_process);
 
 /* When ballooning out (allocating memory to return to Xen) we don't really
    want the kernel to try too hard since that can trigger the oom killer. */
 #define GFP_BALLOON \
 	(GFP_HIGHUSER | __GFP_NOWARN | __GFP_NORETRY | __GFP_NOMEMALLOC)
 
-static void scrub_page(struct page *page)
+static inline void scrub_page(struct page *page)
 {
 #ifdef CONFIG_XEN_SCRUB_PAGES
 	clear_highpage(page);
@@ -172,9 +168,29 @@ static struct page *balloon_next_page(struct page *page)
 	return list_entry(next, struct page, lru);
 }
 
-static void balloon_alarm(unsigned long unused)
+static void update_schedule_delay(int cmd)
 {
-	schedule_work(&balloon_worker);
+	unsigned long new_schedule_delay;
+
+	/*
+	 * cmd >= 0: balloon_stats.schedule_delay = 1,
+	 * cmd < 0: increase balloon_stats.schedule_delay but
+	 *          no more than balloon_stats.max_schedule_delay.
+	 */
+
+	if (cmd >= 0) {
+		balloon_stats.schedule_delay = 1;
+		return;
+	}
+
+	new_schedule_delay = balloon_stats.schedule_delay << 1;
+
+	if (new_schedule_delay > balloon_stats.max_schedule_delay) {
+		balloon_stats.schedule_delay = balloon_stats.max_schedule_delay;
+		return;
+	}
+
+	balloon_stats.schedule_delay = new_schedule_delay;
 }
 
 static unsigned long current_target(void)
@@ -191,9 +207,9 @@ static unsigned long current_target(void)
 
 static int increase_reservation(unsigned long nr_pages)
 {
+	int rc, state = 0;
 	unsigned long  pfn, i, flags;
 	struct page   *page;
-	long           rc;
 	struct xen_memory_reservation reservation = {
 		.address_bits = 0,
 		.extent_order = 0,
@@ -206,8 +222,17 @@ static int increase_reservation(unsigned long nr_pages)
 	spin_lock_irqsave(&xen_reservation_lock, flags);
 
 	page = balloon_first_page();
+
+	if (!page) {
+		state = -ENOMEM;
+		goto out;
+	}
+
 	for (i = 0; i < nr_pages; i++) {
-		BUG_ON(page == NULL);
+		if (!page) {
+			nr_pages = i;
+			break;
+		}
 		frame_list[i] = page_to_pfn(page);
 		page = balloon_next_page(page);
 	}
@@ -215,8 +240,11 @@ static int increase_reservation(unsigned long nr_pages)
 	set_xen_guest_handle(reservation.extent_start, frame_list);
 	reservation.nr_extents = nr_pages;
 	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
-	if (rc < 0)
-		goto out;
+	if (rc < nr_pages) {
+		state = (rc <= 0) ? -ENOMEM : 1;
+		if (rc <= 0)
+			goto out;
+	}
 
 	for (i = 0; i < rc; i++) {
 		page = balloon_retrieve();
@@ -229,7 +257,7 @@ static int increase_reservation(unsigned long nr_pages)
 		set_phys_to_machine(pfn, frame_list[i]);
 
 		/* Link back into the page tables if not highmem. */
-		if (pfn < max_low_pfn) {
+		if (xen_pv_domain() && !PageHighMem(page)) {
 			int ret;
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
@@ -249,15 +277,14 @@ static int increase_reservation(unsigned long nr_pages)
  out:
 	spin_unlock_irqrestore(&xen_reservation_lock, flags);
 
-	return rc < 0 ? rc : rc != nr_pages;
+	return state;
 }
 
 static int decrease_reservation(unsigned long nr_pages)
 {
 	unsigned long  pfn, i, flags;
 	struct page   *page;
-	int            need_sleep = 0;
-	int ret;
+	int ret, state = 0;
 	struct xen_memory_reservation reservation = {
 		.address_bits = 0,
 		.extent_order = 0,
@@ -270,7 +297,7 @@ static int decrease_reservation(unsigned long nr_pages)
 	for (i = 0; i < nr_pages; i++) {
 		if ((page = alloc_page(GFP_BALLOON)) == NULL) {
 			nr_pages = i;
-			need_sleep = 1;
+			state = -ENOMEM;
 			break;
 		}
 
@@ -279,7 +306,7 @@ static int decrease_reservation(unsigned long nr_pages)
 
 		scrub_page(page);
 
-		if (!PageHighMem(page)) {
+		if (xen_pv_domain() && !PageHighMem(page)) {
 			ret = HYPERVISOR_update_va_mapping(
 				(unsigned long)__va(pfn << PAGE_SHIFT),
 				__pte_ma(0), 0);
@@ -310,7 +337,7 @@ static int decrease_reservation(unsigned long nr_pages)
 
 	spin_unlock_irqrestore(&xen_reservation_lock, flags);
 
-	return need_sleep;
+	return state;
 }
 
 /*
@@ -321,27 +348,41 @@ static int decrease_reservation(unsigned long nr_pages)
  */
 static void balloon_process(struct work_struct *work)
 {
-	int need_sleep = 0;
+	int rc, state = 0;
 	long credit;
 
 	mutex_lock(&balloon_mutex);
 
 	do {
 		credit = current_target() - balloon_stats.current_pages;
-		if (credit > 0)
-			need_sleep = (increase_reservation(credit) != 0);
-		if (credit < 0)
-			need_sleep = (decrease_reservation(-credit) != 0);
+
+		/*
+		 * state > 0: hungry,
+		 * state == 0: done or nothing to do,
+		 * state < 0: error, go to sleep.
+		 */
+
+		if (credit > 0) {
+			rc = increase_reservation(credit);
+			state = (rc < 0) ? rc : state;
+		}
+
+		if (credit < 0) {
+			rc = decrease_reservation(-credit);
+			state = (rc < 0) ? rc : state;
+		}
+
+		update_schedule_delay(state);
 
 #ifndef CONFIG_PREEMPT
 		if (need_resched())
 			schedule();
 #endif
-	} while ((credit != 0) && !need_sleep);
+	} while (credit && state >= 0);
 
 	/* Schedule more work if there is some still to be done. */
-	if (current_target() != balloon_stats.current_pages)
-		mod_timer(&balloon_timer, jiffies + HZ);
+	if (state < 0)
+		schedule_delayed_work(&balloon_worker, balloon_stats.schedule_delay * HZ);
 
 	mutex_unlock(&balloon_mutex);
 }
@@ -351,7 +392,7 @@ static void balloon_set_new_target(unsigned long target)
 {
 	/* No need for lock. Not read-modify-write updates. */
 	balloon_stats.target_pages = target;
-	schedule_work(&balloon_worker);
+	schedule_delayed_work(&balloon_worker, 0);
 }
 
 static struct xenbus_watch target_watch =
@@ -395,28 +436,28 @@ static struct notifier_block xenstore_notifier;
 
 static int __init balloon_init(void)
 {
-	unsigned long pfn;
+	unsigned long pfn, nr_pages;
 	struct page *page;
 
-	if (!xen_pv_domain())
+	if (!xen_domain())
 		return -ENODEV;
 
 	pr_info("xen_balloon: Initialising balloon driver.\n");
 
-	balloon_stats.current_pages = min(xen_start_info->nr_pages, max_pfn);
+	nr_pages = xen_pv_domain() ? xen_start_info->nr_pages : max_pfn;
+
+	balloon_stats.current_pages = min(nr_pages, max_pfn);
 	balloon_stats.target_pages  = balloon_stats.current_pages;
 	balloon_stats.balloon_low   = 0;
 	balloon_stats.balloon_high  = 0;
-	balloon_stats.driver_pages  = 0UL;
 
-	init_timer(&balloon_timer);
-	balloon_timer.data = 0;
-	balloon_timer.function = balloon_alarm;
+	balloon_stats.schedule_delay = 1;
+	balloon_stats.max_schedule_delay = 32;
 
 	register_balloon(&balloon_sysdev);
 
 	/* Initialise the balloon with excess memory space. */
-	for (pfn = xen_start_info->nr_pages; pfn < max_pfn; pfn++) {
+	for (pfn = nr_pages; pfn < max_pfn; pfn++) {
 		page = pfn_to_page(pfn);
 		if (!PageReserved(page))
 			balloon_append(page);
@@ -452,7 +493,9 @@ module_exit(balloon_exit);
 BALLOON_SHOW(current_kb, "%lu\n", PAGES2KB(balloon_stats.current_pages));
 BALLOON_SHOW(low_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_low));
 BALLOON_SHOW(high_kb, "%lu\n", PAGES2KB(balloon_stats.balloon_high));
-BALLOON_SHOW(driver_kb, "%lu\n", PAGES2KB(balloon_stats.driver_pages));
+
+static SYSDEV_ULONG_ATTR(schedule_delay, 0644, balloon_stats.schedule_delay);
+static SYSDEV_ULONG_ATTR(max_schedule_delay, 0644, balloon_stats.max_schedule_delay);
 
 static ssize_t show_target_kb(struct sys_device *dev, struct sysdev_attribute *attr,
 			      char *buf)
@@ -515,23 +558,24 @@ static SYSDEV_ATTR(target, S_IRUGO | S_IWUSR,
 static struct sysdev_attribute *balloon_attrs[] = {
 	&attr_target_kb,
 	&attr_target,
+	&attr_schedule_delay.attr,
+	&attr_max_schedule_delay.attr
 };
 
 static struct attribute *balloon_info_attrs[] = {
 	&attr_current_kb.attr,
 	&attr_low_kb.attr,
 	&attr_high_kb.attr,
-	&attr_driver_kb.attr,
 	NULL
 };
 
 static struct attribute_group balloon_info_group = {
 	.name = "info",
-	.attrs = balloon_info_attrs,
+	.attrs = balloon_info_attrs
 };
 
 static struct sysdev_class balloon_sysdev_class = {
-	.name = BALLOON_CLASS_NAME,
+	.name = BALLOON_CLASS_NAME
 };
 
 static int register_balloon(struct sys_device *sysdev)
-- 
1.4.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
