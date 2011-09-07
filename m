Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 019826B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 21:04:52 -0400 (EDT)
Date: Wed, 7 Sep 2011 09:04:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 05/18] writeback: per task dirty rate limit
Message-ID: <20110907010448.GA6513@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020915.240747479@intel.com>
 <1315324030.14232.14.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315324030.14232.14.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 06, 2011 at 11:47:10PM +0800, Peter Zijlstra wrote:
> On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> >  /*
> > + * After a task dirtied this many pages, balance_dirty_pages_ratelimited_nr()
> > + * will look to see if it needs to start dirty throttling.
> > + *
> > + * If dirty_poll_interval is too low, big NUMA machines will call the expensive
> > + * global_page_state() too often. So scale it near-sqrt to the safety margin
> > + * (the number of pages we may dirty without exceeding the dirty limits).
> > + */
> > +static unsigned long dirty_poll_interval(unsigned long dirty,
> > +                                        unsigned long thresh)
> > +{
> > +       if (thresh > dirty)
> > +               return 1UL << (ilog2(thresh - dirty) >> 1);
> > +
> > +       return 1;
> > +}
> 
> Where does that sqrt come from? 

Ideally if we know there are N dirtiers, it's safe to let each task
poll at (thresh-dirty)/N without exceeding the dirty limit.

However we neither know the current N, nor is sure whether it will
rush high at next second. So sqrt is used to tolerate larger N on
increased (thresh-dirty) gap:

irb> 0.upto(10) { |i| mb=2**i; pages=mb<<(20-12); printf "%4d\t%4d\n", mb, Math.sqrt(pages)}
   1      16
   2      22
   4      32
   8      45
  16      64
  32      90
  64     128
 128     181
 256     256
 512     362
1024     512

The above table means, given 1MB (or 1GB) gap and the dd tasks polling
balance_dirty_pages() on every 16 (or 512) pages, the dirty limit
won't be exceeded as long as there are less than 16 (or 512) concurrent
dd's.

Note that dirty_poll_interval() will mainly be used when (dirty < freerun).
When the dirty pages are floating in range [freerun, limit],
"[PATCH 14/18] writeback: control dirty pause time" will independently
adjust tsk->nr_dirtied_pause to get suitable pause time.

So the sqrt naturally leads to less overheads and more N tolerance for
large memory servers, which have large (thresh-freerun) gaps.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
