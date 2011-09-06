Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 295876B016C
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 19:34:34 -0400 (EDT)
Date: Wed, 7 Sep 2011 01:34:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 05/18] writeback: per task dirty rate limit
Message-ID: <20110906233429.GD31945@quack.suse.cz>
References: <20110904015305.367445271@intel.com>
 <20110904020915.240747479@intel.com>
 <1315324030.14232.14.camel@twins>
 <20110906232738.GC31945@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110906232738.GC31945@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 07-09-11 01:27:38, Jan Kara wrote:
> On Tue 06-09-11 17:47:10, Peter Zijlstra wrote:
> > On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> > >  /*
> > > + * After a task dirtied this many pages, balance_dirty_pages_ratelimited_nr()
> > > + * will look to see if it needs to start dirty throttling.
> > > + *
> > > + * If dirty_poll_interval is too low, big NUMA machines will call the expensive
> > > + * global_page_state() too often. So scale it near-sqrt to the safety margin
> > > + * (the number of pages we may dirty without exceeding the dirty limits).
> > > + */
> > > +static unsigned long dirty_poll_interval(unsigned long dirty,
> > > +                                        unsigned long thresh)
> > > +{
> > > +       if (thresh > dirty)
> > > +               return 1UL << (ilog2(thresh - dirty) >> 1);
> > > +
> > > +       return 1;
> > > +}
> > 
> > Where does that sqrt come from? 
>   He does 2^{log_2(x)/2} which, if done in real numbers arithmetics, would
> result in x^{1/2}. Given the integer arithmetics, it might be twice as
> small but still it's some approximation...
  Ah, now I realized that you probably meant to ask why does he use sqrt
and not some other function... Sorry for the noise.

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
