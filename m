Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E7BF08D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 16:44:25 -0400 (EDT)
Date: Mon, 14 Mar 2011 21:44:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/5] mm: Properly reflect task dirty limits in
 dirty_exceeded logic
Message-ID: <20110314204418.GB4998@quack.suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <1299623475-5512-3-git-send-email-jack@suse.cz>
 <20110309210253.GD10346@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110309210253.GD10346@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

On Wed 09-03-11 16:02:53, Vivek Goyal wrote:
> On Tue, Mar 08, 2011 at 11:31:12PM +0100, Jan Kara wrote:
> > @@ -291,6 +292,12 @@ static unsigned long task_dirty_limit(struct task_struct *tsk,
> >  	return max(dirty, bdi_dirty/2);
> >  }
> >  
> > +/* Minimum limit for any task */
> > +static unsigned long task_min_dirty_limit(unsigned long bdi_dirty)
> > +{
> > +	return bdi_dirty - bdi_dirty / TASK_LIMIT_FRACTION;
> > +}
> > +
> Should the above be called bdi_min_dirty_limit()? In essense we seem to
> be setting bdi->bdi_exceeded when dirty pages on bdi cross bdi_thresh and
> clear it when dirty pages on bdi are below 7/8*bdi_thresh. So there does
> not seem to be any dependency on task dirty limit here hence string
> "task" sounds confusing to me. In fact, would
> bdi_dirty_exceeded_clear_thresh() be a better name?
  See below...
  
> >  /*
> >   *
> >   */
> > @@ -484,9 +491,11 @@ static void balance_dirty_pages(struct address_space *mapping,
> >  	unsigned long background_thresh;
> >  	unsigned long dirty_thresh;
> >  	unsigned long bdi_thresh;
> > +	unsigned long min_bdi_thresh = ULONG_MAX;
> >  	unsigned long pages_written = 0;
> >  	unsigned long pause = 1;
> >  	bool dirty_exceeded = false;
> > +	bool min_dirty_exceeded = false;
> >  	struct backing_dev_info *bdi = mapping->backing_dev_info;
> >  
> >  	for (;;) {
> > @@ -513,6 +522,7 @@ static void balance_dirty_pages(struct address_space *mapping,
> >  			break;
> >  
> >  		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
> > +		min_bdi_thresh = task_min_dirty_limit(bdi_thresh);
> >  		bdi_thresh = task_dirty_limit(current, bdi_thresh);
>                 ^^^^^
> This patch aside, we use bdi_thresh name both for bdi threshold as well
> as per task per bdi threshold. will task_bdi_thresh be a better name
> here.
  I agree that the naming is a bit confusing altough it is traditional :).
The renaming to task_bdi_thresh makes sense to me. Then we could name the
limit when we clear dirty_exceeded as: min_task_bdi_thresh(). The task in
the name tries to say that this is a limit for "any task" so I'd like to
keep it there. What do you think?

> > @@ -542,6 +552,9 @@ static void balance_dirty_pages(struct address_space *mapping,
> >  		dirty_exceeded =
> >  			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
> >  			|| (nr_reclaimable + nr_writeback > dirty_thresh);
> > +		min_dirty_exceeded =
> > +			(bdi_nr_reclaimable + bdi_nr_writeback > min_bdi_thresh)
> > +			|| (nr_reclaimable + nr_writeback > dirty_thresh);
> 
> Would following be easier to understand.
> 
> 		clear_dirty_exceeded =
> 			(bdi_nr_reclaimable + bdi_nr_writeback <
> 				dirty_exceeded_reset_thresh)
> 			&& (nr_reclaimable + nr_writeback < dirty_thresh);
  Yes, this looks better. I'll change it.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
