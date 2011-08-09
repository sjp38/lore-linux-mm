Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DDB076B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 10:54:50 -0400 (EDT)
Date: Tue, 9 Aug 2011 10:54:38 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 3/5] writeback: dirty rate control
Message-ID: <20110809145438.GC6482@redhat.com>
References: <20110806084447.388624428@intel.com>
 <20110806094526.878435971@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110806094526.878435971@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Aug 06, 2011 at 04:44:50PM +0800, Wu Fengguang wrote:
> It's all about bdi->dirty_ratelimit, which aims to be (write_bw / N)
> when there are N dd tasks.
> 
> On write() syscall, use bdi->dirty_ratelimit
> ============================================
> 
>     balance_dirty_pages(pages_dirtied)
>     {
>         pos_bw = bdi->dirty_ratelimit * bdi_position_ratio();
>         pause = pages_dirtied / pos_bw;
>         sleep(pause);
>     }
> 
> On every 200ms, update bdi->dirty_ratelimit
> ===========================================
> 
>     bdi_update_dirty_ratelimit()
>     {
>         bw = bdi->dirty_ratelimit;
>         ref_bw = bw * bdi_position_ratio() * write_bw / dirty_bw;
>         if (dirty pages unbalanced)
>              bdi->dirty_ratelimit = (bw * 3 + ref_bw) / 4;
>     }
> 
> Estimation of balanced bdi->dirty_ratelimit
> ===========================================
> 
> When started N dd, throttle each dd at
> 
>          task_ratelimit = pos_bw (any non-zero initial value is OK)
> 
> After 200ms, we got
> 
>          dirty_bw = # of pages dirtied by app / 200ms
>          write_bw = # of pages written to disk / 200ms
> 
> For aggressive dirtiers, the equality holds
> 
>          dirty_bw == N * task_ratelimit
>                   == N * pos_bw                      	(1)
> 
> The balanced throttle bandwidth can be estimated by
> 
>          ref_bw = pos_bw * write_bw / dirty_bw       	(2)
> 
> >From (1) and (2), we get equality
> 
>          ref_bw == write_bw / N                      	(3)
> 
> If the N dd's are all throttled at ref_bw, the dirty/writeback rates
> will match. So ref_bw is the balanced dirty rate.

Hi Fengguang,

So how much work it is to extend all this to handle the case of cgroups?
IOW, I would imagine that you shall have to keep track of per cgroup/per
bdi state of many of the variables. For example, write_bw will become
per cgroup/per bdi entity instead of per bdi entity only. Same should
be true for position ratio, dirty_bw etc?

I am assuming that if some cgroup is low weight on end device, then
WRITE bandwidth of that cgroup should go down and that should be
accounted for at per bdi state and task throttling should happen
accordingly so that a lower weight cgroup tasks get throttled more
as compared to higher weight cgroup tasks?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
