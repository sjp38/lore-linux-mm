Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE096B02A1
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:24:10 -0400 (EDT)
Received: by qgew3 with SMTP id w3so17066272qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:09 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id h63si3864282qhc.102.2015.05.22.15.24.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:24:05 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so23386699qkg.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:04 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 13/19] writeback: separate out domain_dirty_limits()
Date: Fri, 22 May 2015 18:23:30 -0400
Message-Id: <1432333416-6221-14-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

global_dirty_limits() calculates thresh and bg_thresh (confusingly
called *pdirty and *pbackground in the function) assuming
global_wb_domain; however, cgroup writeback support requires
considering per-memcg wb_domain too.

This patch separates out domain_dirty_limits() which takes
dirty_throttle_control out of global_dirty_limits().  As thresh and
bg_thresh calculation needs the amount of dirtyable memory in the
domain, dirty_throttle_control->avail is added.  The new function
calculates the two thresholds and store them directly in the
dirty_throttle_control.

Also, as memcg domains can't follow vm_dirty_bytes and
dirty_background_bytes settings directly.  If those are set and
domain_dirty_limits() is invoked for a !global domain, the settings
are translated to ratios by scaling them against globally available
memory.  dirty_throttle_control->gdtc is added to enable this when
CONFIG_CGROUP_WRITEBACK.

global_dirty_limits() is now a thin wrapper around
domain_dirty_limits() and balance_dirty_pages() is updated to use the
new function too.

This patch doesn't introduce any behavioral changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 111 ++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 86 insertions(+), 25 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a4d0cee..c8ac8ce 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -128,10 +128,12 @@ struct wb_domain global_wb_domain;
 struct dirty_throttle_control {
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct wb_domain	*dom;
+	struct dirty_throttle_control *gdtc;	/* only set in memcg dtc's */
 #endif
 	struct bdi_writeback	*wb;
 	struct fprop_local_percpu *wb_completions;
 
+	unsigned long		avail;		/* dirtyable */
 	unsigned long		dirty;		/* file_dirty + write + nfs */
 	unsigned long		thresh;		/* dirty threshold */
 	unsigned long		bg_thresh;	/* dirty background threshold */
@@ -157,12 +159,18 @@ struct dirty_throttle_control {
 
 #define GDTC_INIT(__wb)		.dom = &global_wb_domain,		\
 				DTC_INIT_COMMON(__wb)
+#define GDTC_INIT_NO_WB		.dom = &global_wb_domain
 
 static struct wb_domain *dtc_dom(struct dirty_throttle_control *dtc)
 {
 	return dtc->dom;
 }
 
+static struct dirty_throttle_control *mdtc_gdtc(struct dirty_throttle_control *mdtc)
+{
+	return mdtc->gdtc;
+}
+
 static void wb_min_max_ratio(struct bdi_writeback *wb,
 			     unsigned long *minp, unsigned long *maxp)
 {
@@ -193,12 +201,18 @@ static void wb_min_max_ratio(struct bdi_writeback *wb,
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 #define GDTC_INIT(__wb)		DTC_INIT_COMMON(__wb)
+#define GDTC_INIT_NO_WB
 
 static struct wb_domain *dtc_dom(struct dirty_throttle_control *dtc)
 {
 	return &global_wb_domain;
 }
 
+static struct dirty_throttle_control *mdtc_gdtc(struct dirty_throttle_control *mdtc)
+{
+	return NULL;
+}
+
 static void wb_min_max_ratio(struct bdi_writeback *wb,
 			     unsigned long *minp, unsigned long *maxp)
 {
@@ -303,42 +317,88 @@ static unsigned long global_dirtyable_memory(void)
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
-/*
- * global_dirty_limits - background-writeback and dirty-throttling thresholds
+/**
+ * domain_dirty_limits - calculate thresh and bg_thresh for a wb_domain
+ * @dtc: dirty_throttle_control of interest
  *
- * Calculate the dirty thresholds based on sysctl parameters
- * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
- * - vm.dirty_ratio             or  vm.dirty_bytes
- * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
+ * Calculate @dtc->thresh and ->bg_thresh considering
+ * vm_dirty_{bytes|ratio} and dirty_background_{bytes|ratio}.  The caller
+ * must ensure that @dtc->avail is set before calling this function.  The
+ * dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
  * real-time tasks.
  */
-void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
-{
-	const unsigned long available_memory = global_dirtyable_memory();
-	unsigned long background;
-	unsigned long dirty;
+static void domain_dirty_limits(struct dirty_throttle_control *dtc)
+{
+	const unsigned long available_memory = dtc->avail;
+	struct dirty_throttle_control *gdtc = mdtc_gdtc(dtc);
+	unsigned long bytes = vm_dirty_bytes;
+	unsigned long bg_bytes = dirty_background_bytes;
+	unsigned long ratio = vm_dirty_ratio;
+	unsigned long bg_ratio = dirty_background_ratio;
+	unsigned long thresh;
+	unsigned long bg_thresh;
 	struct task_struct *tsk;
 
-	if (vm_dirty_bytes)
-		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
+	/* gdtc is !NULL iff @dtc is for memcg domain */
+	if (gdtc) {
+		unsigned long global_avail = gdtc->avail;
+
+		/*
+		 * The byte settings can't be applied directly to memcg
+		 * domains.  Convert them to ratios by scaling against
+		 * globally available memory.
+		 */
+		if (bytes)
+			ratio = min(DIV_ROUND_UP(bytes, PAGE_SIZE) * 100 /
+				    global_avail, 100UL);
+		if (bg_bytes)
+			bg_ratio = min(DIV_ROUND_UP(bg_bytes, PAGE_SIZE) * 100 /
+				       global_avail, 100UL);
+		bytes = bg_bytes = 0;
+	}
+
+	if (bytes)
+		thresh = DIV_ROUND_UP(bytes, PAGE_SIZE);
 	else
-		dirty = (vm_dirty_ratio * available_memory) / 100;
+		thresh = (ratio * available_memory) / 100;
 
-	if (dirty_background_bytes)
-		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
+	if (bg_bytes)
+		bg_thresh = DIV_ROUND_UP(bg_bytes, PAGE_SIZE);
 	else
-		background = (dirty_background_ratio * available_memory) / 100;
+		bg_thresh = (bg_ratio * available_memory) / 100;
 
-	if (background >= dirty)
-		background = dirty / 2;
+	if (bg_thresh >= thresh)
+		bg_thresh = thresh / 2;
 	tsk = current;
 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
-		background += background / 4;
-		dirty += dirty / 4;
+		bg_thresh += bg_thresh / 4;
+		thresh += thresh / 4;
 	}
-	*pbackground = background;
-	*pdirty = dirty;
-	trace_global_dirty_state(background, dirty);
+	dtc->thresh = thresh;
+	dtc->bg_thresh = bg_thresh;
+
+	/* we should eventually report the domain in the TP */
+	if (!gdtc)
+		trace_global_dirty_state(bg_thresh, thresh);
+}
+
+/**
+ * global_dirty_limits - background-writeback and dirty-throttling thresholds
+ * @pbackground: out parameter for bg_thresh
+ * @pdirty: out parameter for thresh
+ *
+ * Calculate bg_thresh and thresh for global_wb_domain.  See
+ * domain_dirty_limits() for details.
+ */
+void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
+{
+	struct dirty_throttle_control gdtc = { GDTC_INIT_NO_WB };
+
+	gdtc.avail = global_dirtyable_memory();
+	domain_dirty_limits(&gdtc);
+
+	*pbackground = gdtc.bg_thresh;
+	*pdirty = gdtc.thresh;
 }
 
 /**
@@ -1421,9 +1481,10 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 */
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
 					global_page_state(NR_UNSTABLE_NFS);
+		gdtc->avail = global_dirtyable_memory();
 		gdtc->dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
 
-		global_dirty_limits(&gdtc->bg_thresh, &gdtc->thresh);
+		domain_dirty_limits(gdtc);
 
 		if (unlikely(strictlimit)) {
 			wb_dirty_limits(gdtc);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
