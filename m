Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 59132900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 09:49:43 -0400 (EDT)
Date: Wed, 17 Aug 2011 21:49:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110817134936.GA22484@localhost>
References: <20110816022006.348714319@intel.com>
 <20110816022328.811348370@intel.com>
 <20110816194112.GA25517@quack.suse.cz>
 <20110817132347.GA6628@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110817132347.GA6628@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > > +		if (x_intercept < limit) {
> > > +			x_intercept = limit;	/* auxiliary control line */
> > > +			setpoint += span;
> > > +			pos_ratio >>= 1;
> > > +		}
> >   And here you stretch the control area upto the global dirty limit. I
> > understand you maybe don't want to be really strict and cut control area at
> > bdi_thresh but your choice looks like too benevolent - when you have
> > several active bdi's with different speeds this will effectively erase
> > difference between them, won't it? E.g. with 10 bdi's (x_intercept -
> > bdi_dirty) / (x_intercept - setpoint) is going to be close to 1 unless
> > bdi_dirty really heavily exceeds bdi_thresh.
> 
> Yes the auxiliary control line could be very flat (small slope).
> 
> However it's not normal for the bdi dirty pages to fall into the
> range of auxiliary control line at all. And once it takes effect, 
> the pos_ratio is at most 0.5 (which is the value at the connection
> point with the main bdi control line) which is strong enough to pull
> the dirty pages off the auxiliary bdi control line and into the scope
> of main bdi control line.
> 
> The auxiliary control line is intended for bringing down the bdi_dirty
> of the USB key before 250s (where the "pos bandwidth" line keeps low): 
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/ext4-4dd-1M-8p-2945M-20%25-2.6.38-rc5-dt6+-2011-02-22-09-46/balance_dirty_pages-pages.png
> 
> After that the bdi_dirty will fluctuate around bdi_thresh and won't
> grow high and step into the scope of the auxiliary control line.

Note that the main/auxiliary bdi control lines won't take effect at
the same time: the main bdi control lines works around and under the
bdi setpoint, and the auxiliary line takes over in the higher scope up
to @limit.

In the 1UKEY+1HDD test case, the bdi_dirty of the UKEY rushes at the
free run stage when global dirty pages are smaller than (thresh+bg_thresh)/2.

So it will be initially under the control the auxiliary line. Hence the
dirtier task will progress at 1/4 to 1/2 of the UKEY's write bandwidth. 
This will bring down the bdi_dirty reasonably fast while still allowing
the dirtier task to make some progress.

The connection point of the main/auxiliary control lines has pos_ratio=0.5.

After 250 second, the main bdi control line takes over, indicated by
the bdi_dirty fluctuating around bdi setpoint and the position rate
(green line) fluctuating around the base ratelimit(blue line).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
