Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 879506B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 22:37:25 -0400 (EDT)
Date: Wed, 7 Sep 2011 10:37:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 11/18] block: add bdi flag to indicate risk of io queue
 underrun
Message-ID: <20110907023719.GC13755@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020916.070059502@intel.com>
 <1315318968.14232.6.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315318968.14232.6.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, "Li, Shaohua" <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 06, 2011 at 10:22:48PM +0800, Peter Zijlstra wrote:
> On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> > +++ linux-next/mm/page-writeback.c      2011-08-31 14:40:58.000000000 +0800
> > @@ -1067,6 +1067,9 @@ static void balance_dirty_pages(struct a
> >                                      nr_dirty, bdi_thresh, bdi_dirty,
> >                                      start_time);
> >  
> > +               if (unlikely(!dirty_exceeded && bdi_async_underrun(bdi)))
> > +                       break;
> > +
> >                 dirty_ratelimit = bdi->dirty_ratelimit;
> >                 pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
> >                                                background_thresh, nr_dirty,
> 
> So dirty_exceeded looks like:
> 
> 
> 1109                 dirty_exceeded = (bdi_dirty > bdi_thresh) ||
> 1110                                   (nr_dirty > dirty_thresh);
> 
> Would it make sense to write it as:
> 
> 	if (nr_dirty > dirty_thresh || 
> 	    (nr_dirty > freerun && bdi_dirty > bdi_thresh))
> 		dirty_exceeded = 1;
> 
> So that we don't actually throttle bdi thingies when we're still in the
> freerun area?

Sounds not necessary -- (nr_dirty > freerun) is implicitly true
because there is a big break early in the loop:

        if (nr_dirty > freerun)
                break;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
