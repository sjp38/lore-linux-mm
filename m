Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4F37F6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 18:20:44 -0400 (EDT)
Date: Thu, 25 Aug 2011 18:20:01 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110825222001.GG27162@redhat.com>
References: <1313154259.6576.42.camel@twins>
 <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
 <20110823034042.GC7332@localhost>
 <1314093660.8002.24.camel@twins>
 <20110823141504.GA15949@localhost>
 <20110823174757.GC15820@redhat.com>
 <20110824001257.GA6349@localhost>
 <20110824180058.GC22434@redhat.com>
 <20110825031934.GA9764@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110825031934.GA9764@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 25, 2011 at 11:19:34AM +0800, Wu Fengguang wrote:

[..]
> > So you are trying to make one feedback loop aware of second loop so that
> > if second loop is unbalanced, first loop reacts to that as well and not
> > just look at dirty_rate and write_bw. So refining new balanced rate by
> > pos_ratio helps.
> > 						      write_bw	
> > bdi->dirty_ratelimit_(i+1) = bdi->dirty_ratelimit_i * --------- * pos_ratio
> > 						      dirty_bw
> > 
> > Now if global dirty pages are imbalanced, balanced rate will still go
> > down despite the fact that dirty_bw == write_bw. This will lead to
> > further reduction in task dirty rate. Which in turn will lead to reduced
> > number of dirty rate and should eventually lead to pos_ratio=1.
> 
> Right, that's a good alternative viewpoint to the below one.
> 
>   						  write_bw	
>   bdi->dirty_ratelimit_(i+1) = task_ratelimit_i * ---------
>   						  dirty_bw
> 
> (1) the periodic rate estimation uses that to refresh the balanced rate on every 200ms
> (2) as long as the rate estimation is correct, pos_ratio is able to drive itself to 1.0

Personally I found it much easier to understand the other representation.
Once you have come up with equation.

balance_rate_(i+1) = balance_rate(i) * write_bw/dirty_bw

Can you please put few lines of comments to explain that why above
alone is not sufficient and we need to take pos_ratio also in to
account to keep number of dirty pages in check. And then go onto

balance_rate_(i+1) = balance_rate(i) * write_bw/dirty_bw * pos_ratio

This kind of maintains the continuity of explanation and explains
that why are we deviating from the theory we discussed so far.

> 
> > A related question though I should have asked you this long back. How does
> > throttling based on rate helps. Why we could not just work with two
> > pos_ratios. One is gloabl postion ratio and other is bdi position ratio.
> > And then throttle task gradually to achieve smooth throttling behavior.
> > IOW, what property does rate provide which is not available just by
> > looking at per bdi dirty pages. Can't we come up with bdi setpoint and
> > limit the way you have done for gloabl setpoint and throttle tasks
> > accordingly?
> 
> Good question. If we have no idea of the balanced rate at all, but
> still want to limit dirty pages within the range [freerun, limit],
> all we can do is to throttle the task at eg. 1TB/s at @freerun and
> 0 at @limit. Then you get a really sharp control line which will make
> task_ratelimit fluctuate like mad...
> 
> So the balanced rate estimation is the key to get smooth task_ratelimit,
> while pos_ratio is the ultimate guarantee for the dirty pages range.

Ok, that makes sense. By keeping an estimation of rate at which bdi
can write, our range of throttling goes down. Say 0 to 300MB/s instead
of 0 to 1TB/sec and that can lead to a more smooth behavior.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
