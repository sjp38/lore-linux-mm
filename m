Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BA1109000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 23:32:07 -0400 (EDT)
Date: Thu, 29 Sep 2011 11:32:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 10/18] writeback: dirty position control - bdi reserve
 area
Message-ID: <20110929033201.GA21722@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020915.942753370@intel.com>
 <1315318179.14232.3.camel@twins>
 <20110907123108.GB6862@localhost>
 <1315822779.26517.23.camel@twins>
 <20110918141705.GB15366@localhost>
 <20110918143721.GA17240@localhost>
 <20110918144751.GA18645@localhost>
 <20110928140205.GA26617@localhost>
 <1317221435.24040.39.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317221435.24040.39.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 28, 2011 at 10:50:35PM +0800, Peter Zijlstra wrote:
> On Wed, 2011-09-28 at 22:02 +0800, Wu Fengguang wrote:
> 
> /me attempts to swap back neurons related to writeback
> 
> > After lots of experiments, I end up with this bdi reserve point
> > 
> > +       x_intercept = bdi_thresh / 2 + MIN_WRITEBACK_PAGES;
> > 
> > together with this chunk to avoid a bdi stuck in bdi_thresh=0 state:
> > 
> > @@ -590,6 +590,7 @@ static unsigned long bdi_position_ratio(
> >          */
> >         if (unlikely(bdi_thresh > thresh))
> >                 bdi_thresh = thresh;
> > +       bdi_thresh = max(bdi_thresh, (limit - dirty) / 8);
> >         /*
> >          * scale global setpoint to bdi's:
> >          *      bdi_setpoint = setpoint * bdi_thresh / thresh
> 
> So you cap bdi_thresh at a minimum of (limit-dirty)/8 which can be
> pretty close to 0 if we have a spike in dirty or a negative spike in
> writeout bandwidth (sudden seeks or whatnot).

That's right. However to bring bdi_thresh out of the close-to-zero
state, it's only required that (limit-dirty)/8 is reasonable large for
the _majority_ time, which is not a problem for the servers unless
something goes wrong.

> 
> > The above changes are good enough to keep reasonable amount of bdi
> > dirty pages, so the bdi underrun flag ("[PATCH 11/18] block: add bdi
> > flag to indicate risk of io queue underrun") is dropped.
> 
> That sounds like goodness ;-)

Yeah!

> > I also tried various bdi freerun patches, however the results are not
> > satisfactory. Basically the bdi reserve area approach (this patch)
> > yields noticeably more smooth/resilient behavior than the
> > freerun/underrun approaches. I noticed that the bdi underrun flag
> > could lead to sudden surge of dirty pages (especially if not
> > safeguarded by the dirty_exceeded condition) in the very small
> > window.. 
> 
> OK, so let me try and parse this magic:
> 
> +       x_intercept = bdi_thresh / 2 + MIN_WRITEBACK_PAGES;
> +       if (bdi_dirty < x_intercept) {
> +               if (bdi_dirty > x_intercept / 8) {
> +                       pos_ratio *= x_intercept;
> +                       do_div(pos_ratio, bdi_dirty);
> +               } else
> +                       pos_ratio *= 8;
> +       }
> 
> So we set our target some place north of MIN_WRITEBACK_PAGES: if we're
> short we add a factor of: x_intercept/bdi_dirty. 
> 
> Now, since bdi_dirty < x_intercept, this is > 1 and thus we promote more
> dirties.

That's right.

> Additionally we don't let the factor get larger than 8 to avoid silly
> large fluctuations (8 already seems quite generous to me).

I actually increased 8 to 128 and still think it safe: for the
promotion ratio to be 128, bdi_dirty should be around bdi_thresh/2/128
(or 0.4% bdi_thresh). Whatever large the promotion ratio is, it won't
be more radical than some bdi freerun threshold.

In the tests, what the bdi reserve area protect is mainly small memory
systems (small dirty threshold comparing to writeout bandwidth), where
an IO completion could bring down bdi_dirty considerably (relatively)
and we really need to ramp it up fast at the point to feed the disk.

> Now I guess the only problem is when nr_bdi * MIN_WRITEBACK_PAGES ~
> limit, at which point things go pear shaped.

Yes. In that case the global @dirty will always be drove up to @limit.
Once @dirty dropped reasonably below, whichever bdi task wakeup first
will take the chance to fill the gap, which is not fair for bdi's of
different speed.

Let me retry the thresh=1M,10M test cases without MIN_WRITEBACK_PAGES.
Hopefully the removal of it won't impact performance a lot.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
