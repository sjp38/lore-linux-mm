Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CDF746B02A4
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 12:42:11 -0400 (EDT)
Date: Thu, 5 Aug 2010 00:41:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
Message-ID: <20100804164159.GA22189@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021748.879183413@intel.com>
 <1280847822.1923.597.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1280847822.1923.597.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 03, 2010 at 11:03:42PM +0800, Peter Zijlstra wrote:
> On Sun, 2010-07-11 at 10:06 +0800, Wu Fengguang wrote:
> > plain text document attachment (writeback-less-bdi-calc.patch)
> > Split get_dirty_limits() into global_dirty_limits()+bdi_dirty_limit(),
> > so that the latter can be avoided when under global dirty background
> > threshold (which is the normal state for most systems).
> 
> The patch looks OK, although esp with the proposed comments in the
> follow up email, bdi_dirty_limit() gets a bit confusing wrt to how and
> what the limit is.
> 
> Maybe its clearer to not call task_dirty_limit() from bdi_dirty_limit(),
> that way the comment can focus on the device write request completion
> proportion thing.

Done, thanks.

> > +unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
> > +			       unsigned long dirty)
> > +{
> > +	u64 bdi_dirty;
> > +	long numerator, denominator;
> >  
> > +	/*
> > +	 * Calculate this BDI's share of the dirty ratio.
> > +	 */
> > +	bdi_writeout_fraction(bdi, &numerator, &denominator);
> >  
> > +	bdi_dirty = (dirty * (100 - bdi_min_ratio)) / 100;
> > +	bdi_dirty *= numerator;
> > +	do_div(bdi_dirty, denominator);
> >  
> > +	bdi_dirty += (dirty * bdi->min_ratio) / 100;
> > +	if (bdi_dirty > (dirty * bdi->max_ratio) / 100)
> > +		bdi_dirty = dirty * bdi->max_ratio / 100;
> > +
>   +       return bdi_dirty;
> >  }
> 
> And then add the call to task_dirty_limit() here:

Done. I omitted adding task_dirty_limit() to the bdi_dirty_limit()
inside bdi_debug_stats_show() -- looks unnecessary there.

> > +++ linux-next/mm/backing-dev.c	2010-07-11 08:53:44.000000000 +0800
> > @@ -83,7 +83,8 @@ static int bdi_debug_stats_show(struct s
> >  		nr_more_io++;
> >  	spin_unlock(&inode_lock);
> >  
> > -	get_dirty_limits(&background_thresh, &dirty_thresh, &bdi_thresh, bdi);
> > +	global_dirty_limits(&background_thresh, &dirty_thresh);
> > +	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
>   +       bdi_thresh = task_dirty_limit(current, bdi_thresh);
> 
> And add a comment to task_dirty_limit() as well, explaining its reason
> for existence (protecting light/slow dirtying tasks from heavier/fast
> ones).

Comments updated as below. Any suggestions/corrections?

Thanks,
Fengguang

Subject: writeback: add comment to the dirty limits functions
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Thu Jul 15 09:54:25 CST 2010

Document global_dirty_limits(), bdi_dirty_limit() and task_dirty_limit().

Cc: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
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
