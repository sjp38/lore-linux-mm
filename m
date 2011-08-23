Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 059FF6B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 10:36:59 -0400 (EDT)
Date: Tue, 23 Aug 2011 10:36:21 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110823143621.GA15820@redhat.com>
References: <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313154259.6576.42.camel@twins>
 <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
 <20110823034042.GC7332@localhost>
 <1314093660.8002.24.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314093660.8002.24.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 23, 2011 at 12:01:00PM +0200, Peter Zijlstra wrote:
> On Tue, 2011-08-23 at 11:40 +0800, Wu Fengguang wrote:
> > - not a factor at all for updating balanced_rate (whether or not we do (2))
> >   well, in this concept: the balanced_rate formula inherently does not
> >   derive the balanced_rate_(i+1) from balanced_rate_i. Rather it's
> >   based on the ratelimit executed for the past 200ms:
> > 
> >           balanced_rate_(i+1) = task_ratelimit_200ms * bw_ratio
> 
> Ok, this is where it all goes funny..

Exactly. This is where it gets confusing and is bone of contention.

> 
> So if you want completely separated feedback loops I would expect
> something like:
> 
> 	balance_rate_(i+1) = balance_rate_(i) * bw_ratio   ; every 200ms
> 

I agree. This makes sense. IOW.
						      write_bw
bdi->dirty_ratelimit_n = bdi->dirty_ratelimit_(n-1) * -------
						      dirty_rate

> The former is a complete feedback loop, expressing the new value in the
> old value (*) with bw_ratio as feedback parameter; if we throttled too
> much, the dirty_rate will have dropped and the bw_ratio will be <1
> causing the balance_rate to drop increasing the dirty_rate, and vice
> versa.

I think you meant.

"if we throttled too much, the dirty_rate will have dropped and the bw_ratio
 will be >1 causing the balance_rate to increase hence increasing the
 dirty_rate, and vice versa."

> 
> (*) which is the form I expected and why I thought your primary feedback
> loop looked like: rate_(i+1) = rate_(i) * pos_ratio * bw_ratio
> 
> With the above balance_rate is an independent variable that tracks the
> write bandwidth. Now possibly you'd want a low-pass filter on that since
> your bw_ratio is a bit funny in the head, but that's another story.
> 
> Then when you use the balance_rate to actually throttle tasks you apply
> your secondary control steering the dirty page count, yielding:
> 
> 	task_rate = balance_rate * pos_ratio
> 
> >   and task_ratelimit_200ms happen to can be estimated from
> > 
> >           task_ratelimit_200ms ~= balanced_rate_i * pos_ratio
> 
> >   We may alternatively record every task_ratelimit executed in the
> >   past 200ms and average them all to get task_ratelimit_200ms. In this
> >   way we take the "superfluous" pos_ratio out of sight :) 
> 
> Right, so I'm not at all sure that makes sense, its not immediately
> evident that <task_ratelimit> ~= balance_rate * pos_ratio. Nor is it
> clear to me why your primary feedback loop uses task_ratelimit_200ms at
> all. 
> 

We I thought that this is evident that.

task_ratelimit = balanced_rate * pos_ratio

What is not evident to me is following.

balanced_rate_(i+1) = task_ratelimit_200ms * pos_ratio.

Instead, like you, I also thought that following is more obivious.

balanced_rate_(i+1) = balanced_rate_(i) * pos_ratio

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
