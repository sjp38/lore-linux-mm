Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LI9bqQ027670
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 11:09:37 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LFkr8s14895308
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LFkrnB42473239
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft4ur-0004xg-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700
Date: Wed, 21 Jun 2006 08:45:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060621154532.18741.13081.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 14/14] Remove useless struct wbs
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606210846538.18960@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Subject: zoned vm counters: remove useless writeback structure
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Martin Bligh <mbligh@google.com>, linux-mm@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Remove writeback state

We can remove some functions now that were needed to calculate the page state
for writeback control since these statistics are now directly available.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Index: linux-2.6.17-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page-writeback.c	2006-06-21 07:45:22.931676221 -0700
+++ linux-2.6.17-mm1/mm/page-writeback.c	2006-06-21 07:45:30.543509618 -0700
@@ -99,23 +99,6 @@ EXPORT_SYMBOL(laptop_mode);
 
 static void background_writeout(unsigned long _min_pages);
 
-struct writeback_state
-{
-	unsigned long nr_dirty;
-	unsigned long nr_unstable;
-	unsigned long nr_mapped;
-	unsigned long nr_writeback;
-};
-
-static void get_writeback_state(struct writeback_state *wbs)
-{
-	wbs->nr_dirty = global_page_state(NR_FILE_DIRTY);
-	wbs->nr_unstable = global_page_state(NR_UNSTABLE_NFS);
-	wbs->nr_mapped = global_page_state(NR_FILE_MAPPED) +
-				global_page_state(NR_ANON_PAGES);
-	wbs->nr_writeback = global_page_state(NR_WRITEBACK);
-}
-
 /*
  * Work out the current dirty-memory clamping and background writeout
  * thresholds.
@@ -134,8 +117,8 @@ static void get_writeback_state(struct w
  * clamping level.
  */
 static void
-get_dirty_limits(struct writeback_state *wbs, long *pbackground, long *pdirty,
-		struct address_space *mapping)
+get_dirty_limits(long *pbackground, long *pdirty,
+					struct address_space *mapping)
 {
 	int background_ratio;		/* Percentages */
 	int dirty_ratio;
@@ -145,8 +128,6 @@ get_dirty_limits(struct writeback_state 
 	unsigned long available_memory = total_pages;
 	struct task_struct *tsk;
 
-	get_writeback_state(wbs);
-
 #ifdef CONFIG_HIGHMEM
 	/*
 	 * If this mapping can only allocate from low memory,
@@ -157,7 +138,9 @@ get_dirty_limits(struct writeback_state 
 #endif
 
 
-	unmapped_ratio = 100 - (wbs->nr_mapped * 100) / total_pages;
+	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
+				global_page_state(NR_ANON_PAGES)) * 100) /
+					total_pages;
 
 	dirty_ratio = vm_dirty_ratio;
 	if (dirty_ratio > unmapped_ratio / 2)
@@ -190,7 +173,6 @@ get_dirty_limits(struct writeback_state 
  */
 static void balance_dirty_pages(struct address_space *mapping)
 {
-	struct writeback_state wbs;
 	long nr_reclaimable;
 	long background_thresh;
 	long dirty_thresh;
@@ -207,11 +189,12 @@ static void balance_dirty_pages(struct a
 			.nr_to_write	= write_chunk,
 		};
 
-		get_dirty_limits(&wbs, &background_thresh,
-					&dirty_thresh, mapping);
-		nr_reclaimable = wbs.nr_dirty + wbs.nr_unstable;
-		if (nr_reclaimable + wbs.nr_writeback <= dirty_thresh)
-			break;
+		get_dirty_limits(&background_thresh, &dirty_thresh, mapping);
+		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
+					global_page_state(NR_UNSTABLE_NFS);
+		if (nr_reclaimable + global_page_state(NR_WRITEBACK) <=
+			dirty_thresh)
+				break;
 
 		if (!dirty_exceeded)
 			dirty_exceeded = 1;
@@ -224,11 +207,14 @@ static void balance_dirty_pages(struct a
 		 */
 		if (nr_reclaimable) {
 			writeback_inodes(&wbc);
-			get_dirty_limits(&wbs, &background_thresh,
-					&dirty_thresh, mapping);
-			nr_reclaimable = wbs.nr_dirty + wbs.nr_unstable;
-			if (nr_reclaimable + wbs.nr_writeback <= dirty_thresh)
-				break;
+			get_dirty_limits(&background_thresh,
+					 	&dirty_thresh, mapping);
+			nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
+					global_page_state(NR_UNSTABLE_NFS);
+			if (nr_reclaimable +
+				global_page_state(NR_WRITEBACK)
+					<= dirty_thresh)
+						break;
 			pages_written += write_chunk - wbc.nr_to_write;
 			if (pages_written >= write_chunk)
 				break;		/* We've done our duty */
@@ -236,8 +222,9 @@ static void balance_dirty_pages(struct a
 		blk_congestion_wait(WRITE, HZ/10);
 	}
 
-	if (nr_reclaimable + wbs.nr_writeback <= dirty_thresh && dirty_exceeded)
-		dirty_exceeded = 0;
+	if (nr_reclaimable + global_page_state(NR_WRITEBACK)
+		<= dirty_thresh && dirty_exceeded)
+			dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
 		return;		/* pdflush is already working this queue */
@@ -299,12 +286,11 @@ EXPORT_SYMBOL(balance_dirty_pages_rateli
 
 void throttle_vm_writeout(void)
 {
-	struct writeback_state wbs;
 	long background_thresh;
 	long dirty_thresh;
 
         for ( ; ; ) {
-		get_dirty_limits(&wbs, &background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
@@ -312,8 +298,9 @@ void throttle_vm_writeout(void)
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
-                if (wbs.nr_unstable + wbs.nr_writeback <= dirty_thresh)
-                        break;
+                if (global_page_state(NR_UNSTABLE_NFS) +
+			global_page_state(NR_WRITEBACK) <= dirty_thresh)
+                        	break;
                 blk_congestion_wait(WRITE, HZ/10);
         }
 }
@@ -335,12 +322,12 @@ static void background_writeout(unsigned
 	};
 
 	for ( ; ; ) {
-		struct writeback_state wbs;
 		long background_thresh;
 		long dirty_thresh;
 
-		get_dirty_limits(&wbs, &background_thresh, &dirty_thresh, NULL);
-		if (wbs.nr_dirty + wbs.nr_unstable < background_thresh
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		if (global_page_state(NR_FILE_DIRTY) +
+			global_page_state(NR_UNSTABLE_NFS) < background_thresh
 				&& min_pages <= 0)
 			break;
 		wbc.encountered_congestion = 0;
@@ -364,12 +351,9 @@ static void background_writeout(unsigned
  */
 int wakeup_pdflush(long nr_pages)
 {
-	if (nr_pages == 0) {
-		struct writeback_state wbs;
-
-		get_writeback_state(&wbs);
-		nr_pages = wbs.nr_dirty + wbs.nr_unstable;
-	}
+	if (nr_pages == 0)
+		nr_pages = global_page_state(NR_FILE_DIRTY) +
+				global_page_state(NR_UNSTABLE_NFS);
 	return pdflush_operation(background_writeout, nr_pages);
 }
 
@@ -400,7 +384,6 @@ static void wb_kupdate(unsigned long arg
 	unsigned long start_jif;
 	unsigned long next_jif;
 	long nr_to_write;
-	struct writeback_state wbs;
 	struct writeback_control wbc = {
 		.bdi		= NULL,
 		.sync_mode	= WB_SYNC_NONE,
@@ -412,11 +395,11 @@ static void wb_kupdate(unsigned long arg
 
 	sync_supers();
 
-	get_writeback_state(&wbs);
 	oldest_jif = jiffies - dirty_expire_interval;
 	start_jif = jiffies;
 	next_jif = start_jif + dirty_writeback_interval;
-	nr_to_write = wbs.nr_dirty + wbs.nr_unstable +
+	nr_to_write = global_page_state(NR_FILE_DIRTY) +
+			global_page_state(NR_UNSTABLE_NFS) +
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
 	while (nr_to_write > 0) {
 		wbc.encountered_congestion = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
