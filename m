Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A783A6B015B
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:04:20 -0400 (EDT)
Subject: Re: +
 mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-c
 ache-references.patch added to -mm tree
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <20090822025150.GB7798@localhost>
References: <200908212250.n7LMox3g029154@imap1.linux-foundation.org>
	 <20090822025150.GB7798@localhost>
Content-Type: text/plain
Date: Sun, 23 Aug 2009 10:33:33 +0100
Message-Id: <1251020013.2270.24.camel@castor>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>, "mbligh@mbligh.org" <mbligh@mbligh.org>, "miklos@szeredi.hu" <miklos@szeredi.hu>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 2009-08-22 at 10:51 +0800, Wu Fengguang wrote:

> > 
> >  mm/page-writeback.c |  116 +++++++++++++++---------------------------
> >  1 file changed, 43 insertions(+), 73 deletions(-)
> > 
> > diff -puN mm/page-writeback.c~mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-cache-references mm/page-writeback.c
> > --- a/mm/page-writeback.c~mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-cache-references
> > +++ a/mm/page-writeback.c
> > @@ -249,32 +249,6 @@ static void bdi_writeout_fraction(struct
> >  	}
> >  }
> >  
> > -/*
> > - * Clip the earned share of dirty pages to that which is actually available.
> > - * This avoids exceeding the total dirty_limit when the floating averages
> > - * fluctuate too quickly.
> > - */
> > -static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
> > -		unsigned long dirty, unsigned long *pbdi_dirty)
> > -{
> > -	unsigned long avail_dirty;
> > -
> > -	avail_dirty = global_page_state(NR_FILE_DIRTY) +
> > -		 global_page_state(NR_WRITEBACK) +
> > -		 global_page_state(NR_UNSTABLE_NFS) +
> > -		 global_page_state(NR_WRITEBACK_TEMP);
> > -
> > -	if (avail_dirty < dirty)
> > -		avail_dirty = dirty - avail_dirty;
> > -	else
> > -		avail_dirty = 0;
> > -
> > -	avail_dirty += bdi_stat(bdi, BDI_RECLAIMABLE) +
> > -		bdi_stat(bdi, BDI_WRITEBACK);
> > -
> > -	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
> > -}
> > -
> >  static inline void task_dirties_fraction(struct task_struct *tsk,
> >  		long *numerator, long *denominator)
> >  {
> > @@ -465,7 +439,6 @@ get_dirty_limits(unsigned long *pbackgro
> >  			bdi_dirty = dirty * bdi->max_ratio / 100;
> >  
> >  		*pbdi_dirty = bdi_dirty;
> > -		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
> >  		task_dirty_limit(current, pbdi_dirty);
> >  	}
> >  }
> > @@ -499,45 +472,12 @@ static void balance_dirty_pages(struct a
> >  		};
> >  
> >  		get_dirty_limits(&background_thresh, &dirty_thresh,
> > -				&bdi_thresh, bdi);
> > +				 &bdi_thresh, bdi);
> >  
> >  		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> > -					global_page_state(NR_UNSTABLE_NFS);
> > -		nr_writeback = global_page_state(NR_WRITEBACK);
> > -
> > -		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> > -		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> > -
> > -		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> > -			break;
> > -
> > -		/*
> > -		 * Throttle it only when the background writeback cannot
> > -		 * catch-up. This avoids (excessively) small writeouts
> > -		 * when the bdi limits are ramping up.
> > -		 */
> > -		if (nr_reclaimable + nr_writeback <
> > -				(background_thresh + dirty_thresh) / 2)
> > -			break;
> > -
> > -		if (!bdi->dirty_exceeded)
> > -			bdi->dirty_exceeded = 1;
> > -
> > -		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> > -		 * Unstable writes are a feature of certain networked
> > -		 * filesystems (i.e. NFS) in which data may have been
> > -		 * written to the server's write cache, but has not yet
> > -		 * been flushed to permanent storage.
> > -		 * Only move pages to writeback if this bdi is over its
> > -		 * threshold otherwise wait until the disk writes catch
> > -		 * up.
> > -		 */
> > -		if (bdi_nr_reclaimable > bdi_thresh) {
> > -			generic_sync_bdi_inodes(NULL, &wbc);
> > -			pages_written += write_chunk - wbc.nr_to_write;
> > -			get_dirty_limits(&background_thresh, &dirty_thresh,
> > -				       &bdi_thresh, bdi);
> > -		}
> > +			global_page_state(NR_UNSTABLE_NFS);
> > +		nr_writeback = global_page_state(NR_WRITEBACK) +
> > +			global_page_state(NR_WRITEBACK_TEMP);
> >  
> >  		/*
> >  		 * In order to avoid the stacked BDI deadlock we need
> > @@ -557,16 +497,48 @@ static void balance_dirty_pages(struct a
> >  			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> >  		}
> >  
> > -		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> > -			break;
> > -		if (pages_written >= write_chunk)
> > -			break;		/* We've done our duty */
> 
> > +		/* always throttle if over threshold */
> > +		if (nr_reclaimable + nr_writeback < dirty_thresh) {
> 
> That 'if' is a big behavior change. It effectively blocks every one
> and canceled Peter's proportional throttling work: the less a process
> dirtied, the less it should be throttled.
> 
I don't think it does. the code ends up looking like

FOR
	IF less than dirty_thresh THEN
		check bdi limits etc	
	ENDIF

	thottle
ENDFOR

Therefore we always throttle when over the threshold otherwise we apply
the per bdi limits to decide if we throttle.

In the existing code clip_bdi_dirty_limit modified the bdi_thresh so
that it would not let a bdi dirty enough pages to go over the
dirty_threshold. All I've done is to bring the check of dirty_thresh up
into balance_dirty_pages.

So isn't this effectively the same ?


> I'd propose to remove the above 'if' and liberate the following three 'if's.
> 
> > +
> > +			if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> > +				break;
> > +
> > +			/*
> > +			 * Throttle it only when the background writeback cannot
> > +			 * catch-up. This avoids (excessively) small writeouts
> > +			 * when the bdi limits are ramping up.
> > +			 */
> > +			if (nr_reclaimable + nr_writeback <
> > +			    (background_thresh + dirty_thresh) / 2)
> > +				break;
> > +
> > +			/* done enough? */
> > +			if (pages_written >= write_chunk)
> > +				break;
> > +		}
> > +		if (!bdi->dirty_exceeded)
> > +			bdi->dirty_exceeded = 1;
> >  
> > +		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> > +		 * Unstable writes are a feature of certain networked
> > +		 * filesystems (i.e. NFS) in which data may have been
> > +		 * written to the server's write cache, but has not yet
> > +		 * been flushed to permanent storage.
> > +		 * Only move pages to writeback if this bdi is over its
> > +		 * threshold otherwise wait until the disk writes catch
> > +		 * up.
> > +		 */
> > +		if (bdi_nr_reclaimable > bdi_thresh) {
> > +			writeback_inodes(&wbc);
> > +			pages_written += write_chunk - wbc.nr_to_write;
> 
> > +			if (wbc.nr_to_write == 0)
> > +				continue;
> 
> What's the purpose of the above 2 lines?

This is to try to replicate the existing code as closely as possible.

If writeback_inodes wrote write_chunk pages in one pass then skip to the
top of the loop to recheck the limits and decide if we can let the
application continue. Otherwise it's not making enough forward progress
due to congestion so do the congestion_wait & loop. 


> Thanks,
> Fengguang
> 
regards 
Richard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
