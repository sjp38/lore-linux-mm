Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CD2BF6B011E
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 23:54:37 -0400 (EDT)
Date: Mon, 24 Aug 2009 09:41:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: +
	mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-c
	ache-references.patch added to -mm tree
Message-ID: <20090824014144.GB7346@localhost>
References: <200908212250.n7LMox3g029154@imap1.linux-foundation.org> <20090822025150.GB7798@localhost> <1251020013.2270.24.camel@castor> <20090823130056.GA10596@localhost> <1251035196.2270.50.camel@castor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1251035196.2270.50.camel@castor>
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>, "mbligh@mbligh.org" <mbligh@mbligh.org>, "miklos@szeredi.hu" <miklos@szeredi.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 23, 2009 at 09:46:36PM +0800, Richard Kennedy wrote:
> On Sun, 2009-08-23 at 21:00 +0800, Wu Fengguang wrote:
> > On Sun, Aug 23, 2009 at 05:33:33PM +0800, Richard Kennedy wrote:
> > > On Sat, 2009-08-22 at 10:51 +0800, Wu Fengguang wrote:
> > > 
> > > > > 
> > > > >  mm/page-writeback.c |  116 +++++++++++++++---------------------------
> > > > >  1 file changed, 43 insertions(+), 73 deletions(-)
> > > > > 
> > > > > diff -puN mm/page-writeback.c~mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-cache-references mm/page-writeback.c
> > > > > --- a/mm/page-writeback.c~mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-cache-references
> > > > > +++ a/mm/page-writeback.c
> > > > > @@ -249,32 +249,6 @@ static void bdi_writeout_fraction(struct
> > > > >  	}
> > > > >  }
> > > > >  
> > > > > -/*
> > > > > - * Clip the earned share of dirty pages to that which is actually available.
> > > > > - * This avoids exceeding the total dirty_limit when the floating averages
> > > > > - * fluctuate too quickly.
> > > > > - */
> > > > > -static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
> > > > > -		unsigned long dirty, unsigned long *pbdi_dirty)
> > > > > -{
> > > > > -	unsigned long avail_dirty;
> > > > > -
> > > > > -	avail_dirty = global_page_state(NR_FILE_DIRTY) +
> > > > > -		 global_page_state(NR_WRITEBACK) +
> > > > > -		 global_page_state(NR_UNSTABLE_NFS) +
> > > > > -		 global_page_state(NR_WRITEBACK_TEMP);
> > > > > -
> > > > > -	if (avail_dirty < dirty)
> > > > > -		avail_dirty = dirty - avail_dirty;
> > > > > -	else
> > > > > -		avail_dirty = 0;
> > > > > -
> > > > > -	avail_dirty += bdi_stat(bdi, BDI_RECLAIMABLE) +
> > > > > -		bdi_stat(bdi, BDI_WRITEBACK);
> > > > > -
> > > > > -	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
> > > > > -}
> > > > > -
> > > > >  static inline void task_dirties_fraction(struct task_struct *tsk,
> > > > >  		long *numerator, long *denominator)
> > > > >  {
> > > > > @@ -465,7 +439,6 @@ get_dirty_limits(unsigned long *pbackgro
> > > > >  			bdi_dirty = dirty * bdi->max_ratio / 100;
> > > > >  
> > > > >  		*pbdi_dirty = bdi_dirty;
> > > > > -		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
> > > > >  		task_dirty_limit(current, pbdi_dirty);
> > > > >  	}
> > > > >  }
> > > > > @@ -499,45 +472,12 @@ static void balance_dirty_pages(struct a
> > > > >  		};
> > > > >  
> > > > >  		get_dirty_limits(&background_thresh, &dirty_thresh,
> > > > > -				&bdi_thresh, bdi);
> > > > > +				 &bdi_thresh, bdi);
> > > > >  
> > > > >  		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> > > > > -					global_page_state(NR_UNSTABLE_NFS);
> > > > > -		nr_writeback = global_page_state(NR_WRITEBACK);
> > > > > -
> > > > > -		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> > > > > -		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> > > > > -
> > > > > -		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> > > > > -			break;
> > > > > -
> > > > > -		/*
> > > > > -		 * Throttle it only when the background writeback cannot
> > > > > -		 * catch-up. This avoids (excessively) small writeouts
> > > > > -		 * when the bdi limits are ramping up.
> > > > > -		 */
> > > > > -		if (nr_reclaimable + nr_writeback <
> > > > > -				(background_thresh + dirty_thresh) / 2)
> > > > > -			break;
> > > > > -
> > > > > -		if (!bdi->dirty_exceeded)
> > > > > -			bdi->dirty_exceeded = 1;
> > > > > -
> > > > > -		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> > > > > -		 * Unstable writes are a feature of certain networked
> > > > > -		 * filesystems (i.e. NFS) in which data may have been
> > > > > -		 * written to the server's write cache, but has not yet
> > > > > -		 * been flushed to permanent storage.
> > > > > -		 * Only move pages to writeback if this bdi is over its
> > > > > -		 * threshold otherwise wait until the disk writes catch
> > > > > -		 * up.
> > > > > -		 */
> > > > > -		if (bdi_nr_reclaimable > bdi_thresh) {
> > > > > -			generic_sync_bdi_inodes(NULL, &wbc);
> > > > > -			pages_written += write_chunk - wbc.nr_to_write;
> > > > > -			get_dirty_limits(&background_thresh, &dirty_thresh,
> > > > > -				       &bdi_thresh, bdi);
> > > > > -		}
> > > > > +			global_page_state(NR_UNSTABLE_NFS);
> > > > > +		nr_writeback = global_page_state(NR_WRITEBACK) +
> > > > > +			global_page_state(NR_WRITEBACK_TEMP);
> > > > >  
> > > > >  		/*
> > > > >  		 * In order to avoid the stacked BDI deadlock we need
> > > > > @@ -557,16 +497,48 @@ static void balance_dirty_pages(struct a
> > > > >  			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> > > > >  		}
> > > > >  
> > > > > -		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> > > > > -			break;
> > > > > -		if (pages_written >= write_chunk)
> > > > > -			break;		/* We've done our duty */
> > > > 
> > > > > +		/* always throttle if over threshold */
> > > > > +		if (nr_reclaimable + nr_writeback < dirty_thresh) {
> > > > 
> > > > That 'if' is a big behavior change. It effectively blocks every one
> > > > and canceled Peter's proportional throttling work: the less a process
> > > > dirtied, the less it should be throttled.
> > > > 
> > > I don't think it does. the code ends up looking like
> > > 
> > > FOR
> > > 	IF less than dirty_thresh THEN
> > > 		check bdi limits etc	
> > > 	ENDIF
> > > 
> > > 	thottle
> > > ENDFOR
> > > 
> > > Therefore we always throttle when over the threshold otherwise we apply
> > > the per bdi limits to decide if we throttle.
> > > 
> > > In the existing code clip_bdi_dirty_limit modified the bdi_thresh so
> > > that it would not let a bdi dirty enough pages to go over the
> > > dirty_threshold. All I've done is to bring the check of dirty_thresh up
> > > into balance_dirty_pages.
> > > 
> > > So isn't this effectively the same ?
> > 
> > Yes and no. For the bdi_thresh part it somehow makes the
> > clip_bdi_dirty_limit() logic more simple and obvious. Which I tend to
> > agree with you and Peter on doing something like this:
> > 
> >         if (nr_reclaimable + nr_writeback < dirty_thresh) {
> >                 /* compute bdi_* */
> >                 if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> >          		break;
> >         }
> > 
> > For other two 'if's..
> >  
> > > > I'd propose to remove the above 'if' and liberate the following three 'if's.
> > > > 
> > > > > +
> > > > > +			if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> > > > > +				break;
> > > > > +
> > > > > +			/*
> > > > > +			 * Throttle it only when the background writeback cannot
> > > > > +			 * catch-up. This avoids (excessively) small writeouts
> > > > > +			 * when the bdi limits are ramping up.
> > > > > +			 */
> > > > > +			if (nr_reclaimable + nr_writeback <
> > > > > +			    (background_thresh + dirty_thresh) / 2)
> > > > > +				break;
> > 
> > That 'if' can be trivially moved out.
> 
> OK, 
> > > > > +
> > > > > +			/* done enough? */
> > > > > +			if (pages_written >= write_chunk)
> > > > > +				break;
> > 
> > That 'if' must be moved out, otherwise it can block a light writer
> > for ever, as long as there is another heavy dirtier keeps the dirty
> > numbers high.
> 
> Yes, I see. But I was worried about a failing device that gets stuck.
> Doesn't this let the application keep dirtying pages forever if the
> pages aren't get written to the device?

In that case every task will be granted up to 8 dirty pages and then
get blocked here, because it will never get big enough pages_written.

That is not perfect, but should be acceptable for a relatively rare case.

> Maybe something like this ?
> 
> if ( nr_writeback < background_thresh && pages_written >= write_chunk)
> 	break;
> 
> or bdi_nr_writeback < bdi_thresh/2 ?

Does that improve _anything_ on a failing device?
That 8-pages-per-task will still be granted..

> > > > > +		}
> > > > > +		if (!bdi->dirty_exceeded)
> > > > > +			bdi->dirty_exceeded = 1;
> > > > >  
> > > > > +		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> > > > > +		 * Unstable writes are a feature of certain networked
> > > > > +		 * filesystems (i.e. NFS) in which data may have been
> > > > > +		 * written to the server's write cache, but has not yet
> > > > > +		 * been flushed to permanent storage.
> > 
> > > > > +		 * Only move pages to writeback if this bdi is over its
> > > > > +		 * threshold otherwise wait until the disk writes catch
> > > > > +		 * up.
> > > > > +		 */
> > > > > +		if (bdi_nr_reclaimable > bdi_thresh) {
> > 
> > I'd much prefer its original form
> > 
> >                 if (bdi_nr_reclaimable) {
> > 
> > Let's push dirty pages to disk ASAP :)
> 
> That change comes from my previous patch, and it's to stop this code
> over reacting and pushing all the available dirty pages to the writeback
> list.

This is the fs guys' expectation. The background sync logic will
also try to push all available dirty pages all the way down to 0.
There may be fat IO pipes and we want to fill them as much as we can
once IO is started, to achieve better IO efficiency.

> > > > > +			writeback_inodes(&wbc);
> > > > > +			pages_written += write_chunk - wbc.nr_to_write;
> > > > 
> > > > > +			if (wbc.nr_to_write == 0)
> > > > > +				continue;
> > > > 
> > > > What's the purpose of the above 2 lines?
> > > 
> > > This is to try to replicate the existing code as closely as possible.
> > > 
> > > If writeback_inodes wrote write_chunk pages in one pass then skip to the
> > > top of the loop to recheck the limits and decide if we can let the
> > > application continue. Otherwise it's not making enough forward progress
> > > due to congestion so do the congestion_wait & loop. 
> > 
> > It makes sense. We have wbc.encountered_congestion for that purpose.
> > However it may not able to write enough pages for other reasons like
> > lock contention. So I'd suggest to test (wbc.nr_to_write <= 0).
> > Thanks,
> > Fengguang
> 
> 
> I didn't test the congestion flag directly because we don't care about
> it if writeback_inodes did enough. If write_chunk pages get moved to
> writeback then we don't need to do the congestion_wait.

Right. (wbc.nr_to_write <= 0) indicates no congestion encountered.

> Can writeback_inodes do more work than it was asked to do?

Maybe not. But all existing code check for inequality instead of '== 0' ;)

> But OK, I can make that change if you think it worthwhile.

OK, thanks!

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
