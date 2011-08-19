Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 56CCB6B016B
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 22:54:11 -0400 (EDT)
Date: Fri, 19 Aug 2011 10:54:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110819025406.GA13365@localhost>
References: <20110816022006.348714319@intel.com>
 <20110816022329.190706384@intel.com>
 <20110819020637.GA13597@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110819020637.GA13597@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Vivek,

> > +		base_rate = bdi->dirty_ratelimit;
> > +		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
> > +					       background_thresh, nr_dirty,
> > +					       bdi_thresh, bdi_dirty);
> > +		if (unlikely(pos_ratio == 0)) {
> > +			pause = MAX_PAUSE;
> > +			goto pause;
> >  		}
> > +		task_ratelimit = (u64)base_rate *
> > +					pos_ratio >> RATELIMIT_CALC_SHIFT;
> 
> Hi Fenguaang,
> 
> I am little confused here. I see that you have already taken pos_ratio
> into account in bdi_update_dirty_ratelimit() and wondering why to take
> that into account again in balance_diry_pages().
> 
> We calculated the pos_rate and balanced_rate and adjusted the
> bdi->dirty_ratelimit accordingly in bdi_update_dirty_ratelimit().

Good question. There are some inter-dependencies in the calculation,
and the dependency chain is the opposite to the one in your mind:
balance_dirty_pages() used pos_ratio in the first place, so that
bdi_update_dirty_ratelimit() have to use pos_ratio in the calculation
of the balanced dirty rate, too.

Let's return to how the balanced dirty rate is estimated. Please pay
special attention to the last paragraphs below the "......" line.

Start by throttling each dd task at rate

        task_ratelimit = task_ratelimit_0                               (1)
                         (any non-zero initial value is OK)

After 200ms, we measured

        dirty_rate = # of pages dirtied by all dd's / 200ms
        write_bw   = # of pages written to the disk / 200ms

For the aggressive dd dirtiers, the equality holds

        dirty_rate == N * task_rate
                   == N * task_ratelimit
                   == N * task_ratelimit_0                              (2)
Or     
        task_ratelimit_0 = dirty_rate / N                               (3)

Now we conclude that the balanced task ratelimit can be estimated by

        balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)      (4)

Because with (2) and (3), (4) yields the desired equality (1):

        balanced_rate == (dirty_rate / N) * (write_bw / dirty_rate)
                      == write_bw / N

.............................................................................

Now let's revisit (1). Since balance_dirty_pages() chooses to execute
the ratelimit

        task_ratelimit = task_ratelimit_0
                       = dirty_ratelimit * pos_ratio                    (5)

Put (5) into (4), we get the final form used in
bdi_update_dirty_ratelimit()

        balanced_rate = (dirty_ratelimit * pos_ratio) * (write_bw / dirty_rate)

So you really need to take (dirty_ratelimit * pos_ratio) as a single entity.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
