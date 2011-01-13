Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D7E26B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 23:14:46 -0500 (EST)
Date: Thu, 13 Jan 2011 12:14:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 02/35] writeback: safety margin for bdi stat error
Message-ID: <20110113041440.GC7840@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150326.604451840@intel.com>
 <20110112215949.GD14260@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110112215949.GD14260@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2011 at 05:59:49AM +0800, Jan Kara wrote:
> On Mon 13-12-10 22:46:48, Wu Fengguang wrote:
> > In a simple dd test on a 8p system with "mem=256M", I find all light
> > dirtier tasks on the root fs are get heavily throttled. That happens
> > because the global limit is exceeded. It's unbelievable at first sight,
> > because the test fs doing the heavy dd is under its bdi limit.  After
> > doing some tracing, it's discovered that
> > 
> >         bdi_dirty < bdi_dirty_limit() < global_dirty_limit() < nr_dirty
>           ^^ bdi_dirty is the number of pages dirtied on BDI? I.e.
> bdi_nr_reclaimable + bdi_nr_writeback?

Yes.

> > So the root cause is, the bdi_dirty is well under the global nr_dirty
> > due to accounting errors. This can be fixed by using bdi_stat_sum(),
>   So which statistic had the big error? I'd just like to understand
> this (and how come your patch improves the situation)...

bdi_stat_error() = nr_cpu_ids * BDI_STAT_BATCH
                 = 8 * (8*(1+ilog2(8)))
                 = 8 * 8 * 4
                 = 256 pages
                 = 1MB

> > however that's costly on large NUMA machines. So do a less costly fix
> > of lowering the bdi limit, so that the accounting errors won't lead to
> > the absurd situation "global limit exceeded but bdi limit not exceeded".
> > 
> > This provides guarantee when there is only 1 heavily dirtied bdi, and
> > works by opportunity for 2+ heavy dirtied bdi's (hopefully they won't
> > reach big error _and_ exceed their bdi limit at the same time).
> > 
> ...
> > @@ -458,6 +464,14 @@ unsigned long bdi_dirty_limit(struct bac
> >  	long numerator, denominator;
> >  
> >  	/*
> > +	 * try to prevent "global limit exceeded but bdi limit not exceeded"
> > +	 */
> > +	if (likely(dirty > bdi_stat_error(bdi)))
> > +		dirty -= bdi_stat_error(bdi);
> > +	else
> > +		return 0;
> > +
>   Ugh, so if by any chance global_dirty_limit() <= bdi_stat_error(bdi), you
> will limit number of unreclaimable pages for that bdi 0? Why?

Good catch! Yeah it may lead to regressions and should be voided.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
