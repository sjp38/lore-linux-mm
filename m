Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 79A13900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:31:26 -0400 (EDT)
Date: Thu, 14 Apr 2011 07:31:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
Message-ID: <20110413233122.GA6097@localhost>
References: <20110413085937.981293444@intel.com>
 <20110413090415.763161169@intel.com>
 <20110413220444.GF4648@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110413220444.GF4648@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Thu, Apr 14, 2011 at 06:04:44AM +0800, Jan Kara wrote:
> On Wed 13-04-11 16:59:41, Wu Fengguang wrote:
> > Reduce the dampening for the control system, yielding faster
> > convergence. The change is a bit conservative, as smaller values may
> > lead to noticeable bdi threshold fluctuates in low memory JBOD setup.
> > 
> > CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > CC: Richard Kennedy <richard@rsk.demon.co.uk>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>   Well, I have nothing against this change as such but what I don't like is
> that it just changes magical +2 for similarly magical +0. It's clear that

The patch tends to make the rampup time a bit more reasonable for
common desktops. From 100s to 25s (see below).

> this will lead to more rapid updates of proportions of bdi's share of
> writeback and thread's share of dirtying but why +0? Why not +1 or -1? So

Yes, it will especially be a problem on _small memory_ JBOD setups.
Richard actually has requested for a much radical change (decrease by
6) but that looks too much.

My team has a 12-disk JBOD with only 6G memory. The memory is pretty
small as a server, but it's a real setup and serves well as the
reference minimal setup that Linux should be able to run well on.

It will sure create more fluctuations, but still is acceptable in my
tests. For example,

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/10HDD-JBOD-6G/xfs-128dd-1M-16p-5904M-20%25-2.6.38-rc6-dt6+-2011-02-23-19-46/balance_dirty_pages-pages.png

> I'd prefer to get some understanding of why do we need to update the
> proportion period and why 4-times faster is just the right amount of faster
> :) If I remember right you had some numbers for this, didn't you?

Even better, I have a graph :)

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/4G/xfs-1dd-1M-8p-3911M-20%25-2.6.38-rc7+-2011-03-07-21-55/balance_dirty_pages-pages.png

It shows that doing 1 dd on a 4G box, it took more than 100s to
rampup. The patch will reduce it to 25 seconds for a typical desktop.
The disk has 50MB/s throughput. Given a modern HDD or SSD, it will
converge more fast.

Thanks,
Fengguang

> > ---
> >  mm/page-writeback.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- linux-next.orig/mm/page-writeback.c	2011-03-02 14:52:19.000000000 +0800
> > +++ linux-next/mm/page-writeback.c	2011-03-02 15:00:17.000000000 +0800
> > @@ -145,7 +145,7 @@ static int calc_period_shift(void)
> >  	else
> >  		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> >  				100;
> > -	return 2 + ilog2(dirty_total - 1);
> > +	return ilog2(dirty_total - 1);
> >  }
> >  
> >  /*
> > 
> > 
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
