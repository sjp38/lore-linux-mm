Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 82114620122
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 11:02:44 -0400 (EDT)
Date: Tue, 3 Aug 2010 23:10:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
Message-ID: <20100803151051.GA842@localhost>
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
> 
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
> 
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

Good suggestions, that would be much less confusing. Will post updated
patches tomorrow.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
