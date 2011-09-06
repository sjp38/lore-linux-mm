Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AC9BE6B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 22:43:15 -0400 (EDT)
Date: Tue, 6 Sep 2011 10:43:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 02/18] writeback: dirty position control
Message-ID: <20110906024311.GB11706@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020914.848566742@intel.com>
 <1315235157.3191.6.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315235157.3191.6.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 05, 2011 at 11:05:57PM +0800, Peter Zijlstra wrote:
> On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> > @@ -591,6 +790,7 @@ static void global_update_bandwidth(unsi
> >  
> >  void __bdi_update_bandwidth(struct backing_dev_info *bdi,
> >                             unsigned long thresh,
> > +                           unsigned long bg_thresh,
> >                             unsigned long dirty,
> >                             unsigned long bdi_thresh,
> >                             unsigned long bdi_dirty,
> > @@ -627,6 +827,7 @@ snapshot:
> >  
> >  static void bdi_update_bandwidth(struct backing_dev_info *bdi,
> >                                  unsigned long thresh,
> > +                                unsigned long bg_thresh,
> >                                  unsigned long dirty,
> >                                  unsigned long bdi_thresh,
> >                                  unsigned long bdi_dirty,
> > @@ -635,8 +836,8 @@ static void bdi_update_bandwidth(struct 
> >         if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
> >                 return;
> >         spin_lock(&bdi->wb.list_lock);
> > -       __bdi_update_bandwidth(bdi, thresh, dirty, bdi_thresh, bdi_dirty,
> > -                              start_time);
> > +       __bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
> > +                              bdi_thresh, bdi_dirty, start_time);
> >         spin_unlock(&bdi->wb.list_lock);
> >  }
> >  
> > @@ -677,7 +878,8 @@ static void balance_dirty_pages(struct a
> >                  * catch-up. This avoids (excessively) small writeouts
> >                  * when the bdi limits are ramping up.
> >                  */
> > -               if (nr_dirty <= (background_thresh + dirty_thresh) / 2)
> > +               if (nr_dirty <= dirty_freerun_ceiling(dirty_thresh,
> > +                                                     background_thresh))
> >                         break;
> >  
> >                 bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
> > @@ -721,8 +923,9 @@ static void balance_dirty_pages(struct a
> >                 if (!bdi->dirty_exceeded)
> >                         bdi->dirty_exceeded = 1;
> >  
> > -               bdi_update_bandwidth(bdi, dirty_thresh, nr_dirty,
> > -                                    bdi_thresh, bdi_dirty, start_time);
> > +               bdi_update_bandwidth(bdi, dirty_thresh, background_thresh,
> > +                                    nr_dirty, bdi_thresh, bdi_dirty,
> > +                                    start_time);
> >  
> >                 /* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> >                  * Unstable writes are a feature of certain networked
> > --- linux-next.orig/fs/fs-writeback.c   2011-08-26 15:57:18.000000000 +0800
> > +++ linux-next/fs/fs-writeback.c        2011-08-26 15:57:20.000000000 +0800
> > @@ -675,7 +675,7 @@ static inline bool over_bground_thresh(v
> >  static void wb_update_bandwidth(struct bdi_writeback *wb,
> >                                 unsigned long start_time)
> >  {
> > -       __bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, start_time);
> > +       __bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, 0, start_time);
> >  }
> >  
> >  /*
> > --- linux-next.orig/include/linux/writeback.h   2011-08-26 15:57:18.000000000 +0800
> > +++ linux-next/include/linux/writeback.h        2011-08-26 15:57:20.000000000 +0800
> > @@ -141,6 +141,7 @@ unsigned long bdi_dirty_limit(struct bac
> >  
> >  void __bdi_update_bandwidth(struct backing_dev_info *bdi,
> >                             unsigned long thresh,
> > +                           unsigned long bg_thresh,
> >                             unsigned long dirty,
> >                             unsigned long bdi_thresh,
> >                             unsigned long bdi_dirty,
> 
> 
> All this function signature muck doesn't seem immediately relevant to
> the introduction of bdi_position_ratio() since the new function isn't
> actually used.

Ahh, you are right.

I'll just make the chunks a standalone patch. Logically they are more
related to patch 03 "writeback: dirty rate control", however let's not
add burden to the already complex patch 03..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
