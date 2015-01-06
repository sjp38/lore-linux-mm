Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 55D146B0145
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:00 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j7so188108qaq.12
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:00 -0800 (PST)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id t12si32253302qge.100.2015.01.06.13.26.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:59 -0800 (PST)
Received: by mail-qg0-f45.google.com with SMTP id z107so76492qgd.4
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:59 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 17/45] writeback: make bdi->min/max_ratio handling cgroup writeback aware
Date: Tue,  6 Jan 2015 16:25:54 -0500
Message-Id: <1420579582-8516-18-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

bdi->min/max_ratio are user-configurable per-bdi knobs which regulate
dirty limit of each bdi.  For cgroup writeback, they need to be
further distributed across wb's (bdi_writeback's) belonging to the
configured bdi.

This patch introduces wb_min_max_ratio() which distributes
bdi->min/max_ratio according to a wb's proportion in the total active
bandwidth of its bdi.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c | 46 ++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 42 insertions(+), 4 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index cc0ce70..e1b74d7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -155,6 +155,42 @@ static unsigned long writeout_period_time = 0;
  */
 #define VM_COMPLETIONS_PERIOD_LEN (3*HZ)
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+static void wb_min_max_ratio(struct bdi_writeback *wb,
+			     unsigned long *minp, unsigned long *maxp)
+{
+	unsigned long this_bw = wb->avg_write_bandwidth;
+	unsigned long tot_bw = atomic_long_read(&wb->bdi->tot_write_bandwidth);
+	unsigned long long min = wb->bdi->min_ratio;
+	unsigned long long max = wb->bdi->min_ratio;
+
+	/*
+	 * @wb may already be clean by the time control reaches here and
+	 * the total may not include its bw.
+	 */
+	if (this_bw < tot_bw) {
+		min *= this_bw;
+		max *= this_bw;
+		do_div(min, tot_bw);
+		do_div(max, tot_bw);
+	}
+
+	*minp = min;
+	*maxp = max;
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static void wb_min_max_ratio(struct bdi_writeback *wb,
+			     unsigned long *minp, unsigned long *maxp)
+{
+	*minp = wb->bdi->min_ratio;
+	*maxp = wb->bdi->max_ratio;
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 /*
  * In a memory zone, there is a certain amount of pages we consider
  * available for the page cache, which is essentially the number of
@@ -539,9 +575,9 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
  */
 unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty)
 {
-	struct backing_dev_info *bdi = wb->bdi;
 	u64 wb_dirty;
 	long numerator, denominator;
+	unsigned long wb_min_ratio, wb_max_ratio;
 
 	/*
 	 * Calculate this BDI's share of the dirty ratio.
@@ -552,9 +588,11 @@ unsigned long wb_dirty_limit(struct bdi_writeback *wb, unsigned long dirty)
 	wb_dirty *= numerator;
 	do_div(wb_dirty, denominator);
 
-	wb_dirty += (dirty * bdi->min_ratio) / 100;
-	if (wb_dirty > (dirty * bdi->max_ratio) / 100)
-		wb_dirty = dirty * bdi->max_ratio / 100;
+	wb_min_max_ratio(wb, &wb_min_ratio, &wb_max_ratio);
+
+	wb_dirty += (dirty * wb_min_ratio) / 100;
+	if (wb_dirty > (dirty * wb_max_ratio) / 100)
+		wb_dirty = dirty * wb_max_ratio / 100;
 
 	return wb_dirty;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
