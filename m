Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6A5926B02A5
	for <linux-mm@kvack.org>; Sat,  7 Aug 2010 12:47:40 -0400 (EDT)
Date: Sun, 8 Aug 2010 00:47:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 03/13] writeback: add comment to the dirty limits
 functions
Message-ID: <20100807164733.GB7109@localhost>
References: <20100805161051.501816677@intel.com>
 <20100805162433.105093335@intel.com>
 <1281089846.1947.411.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1281089846.1947.411.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 06, 2010 at 06:17:26PM +0800, Peter Zijlstra wrote:
> On Fri, 2010-08-06 at 00:10 +0800, Wu Fengguang wrote:
> 
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> > +/**
> > + * bdi_dirty_limit - @bdi's share of dirty throttling threshold
> > + *
> > + * Allocate high/low dirty limits to fast/slow devices, in order to prevent
> > + * - starving fast devices
> > + * - piling up dirty pages (that will take long time to sync) on slow devices
> > + *
> > + * The bdi's share of dirty limit will be adapting to its throughput and
> > + * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
> > + */ 
> 
> Another thing solved by the introduction of per-bdi dirty limits (and
> now per-bdi flushing) is the whole stacked-bdi writeout deadlock.
> 
> Although I'm not sure we want/need to mention that here.

The changelog looks like a suitable place :)

Thanks,
Fengguang
---
Subject: writeback: add comment to the dirty limits functions
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Thu Jul 15 09:54:25 CST 2010

Document global_dirty_limits(), bdi_dirty_limit() and task_dirty_limit().

Note that another thing solved by the introduction of per-bdi dirty
limits (and now per-bdi flushing) is the whole stacked-bdi writeout
deadlock.						-- Peter

Cc: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jens Axboe <axboe@kernel.dk>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-08-03 23:14:19.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-08-05 00:37:17.000000000 +0800
@@ -261,11 +261,18 @@ static inline void task_dirties_fraction
 }
 
 /*
- * scale the dirty limit
+ * task_dirty_limit - scale down dirty throttling threshold for one task
  *
  * task specific dirty limit:
  *
  *   dirty -= (dirty/8) * p_{t}
+ *
+ * To protect light/slow dirtying tasks from heavier/fast ones, we start
+ * throttling individual tasks before reaching the bdi dirty limit.
+ * Relatively low thresholds will be allocated to heavy dirtiers. So when
+ * dirty pages grow large, heavy dirtiers will be throttled first, which will
+ * effectively curb the growth of dirty pages. Light dirtiers with high enough
+ * dirty threshold may never get throttled.
  */
 static unsigned long task_dirty_limit(struct task_struct *tsk,
 				       unsigned long bdi_dirty)
@@ -390,6 +397,15 @@ unsigned long determine_dirtyable_memory
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
+/**
+ * global_dirty_limits - background-writeback and dirty-throttling thresholds
+ *
+ * Calculate the dirty thresholds based on sysctl parameters
+ * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
+ * - vm.dirty_ratio             or  vm.dirty_bytes
+ * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
+ * runtime tasks.
+ */
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
 	unsigned long background;
@@ -424,8 +440,17 @@ void global_dirty_limits(unsigned long *
 	*pdirty = dirty;
 }
 
-unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
-			       unsigned long dirty)
+/**
+ * bdi_dirty_limit - @bdi's share of dirty throttling threshold
+ *
+ * Allocate high/low dirty limits to fast/slow devices, in order to prevent
+ * - starving fast devices
+ * - piling up dirty pages (that will take long time to sync) on slow devices
+ *
+ * The bdi's share of dirty limit will be adapting to its throughput and
+ * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
+ */
+unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
 {
 	u64 bdi_dirty;
 	long numerator, denominator;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
