Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 244846B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 07:59:06 -0500 (EST)
Date: Wed, 24 Nov 2010 20:59:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 08/13] writeback: quit throttling when bdi dirty pages
 dropped low
Message-ID: <20101124125901.GD10413@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042850.245782303@intel.com>
 <1290597233.2072.454.camel@laptop>
 <20101124123023.GA10413@localhost>
 <1290602811.2072.462.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290602811.2072.462.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 08:46:51PM +0800, Peter Zijlstra wrote:
> On Wed, 2010-11-24 at 20:30 +0800, Wu Fengguang wrote:
> > 
> > For the 1-dd case, it looks better to lower the break threshold to
> > 125ms. After all, it's not easy for the dirty pages to drop by 250ms
> > worth of data when you only slept 200ms (note: the max pause time has
> > been doubled mainly for servers).
> > 
> > -               if (nr_dirty < dirty_thresh &&
> > -                   bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwidth / 4)
> > +               if (nr_dirty <= dirty_thresh &&
> > +                   bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwidth / 8)
> >                         break;
> 
> Hrm, but 125ms worth in 200ms is rather easy, you'd want to keep that
> limit above what the pause should give you, right?

Yeah, I exactly mean to quit the loop after sleeping 200ms.
200ms pause already seem large..

I'll leave the safeguard to the "nr_dirty <= dirty_thresh" test :)

This trace shows the problem it tries to solve. Here on fresh boot,
bdi_dirty=106600 which is much larger than bdi_limit=13525.

The same situation may happen if some task quickly eats lots of
anonymous memory, then the global/bdi limits will be knock down
suddenly and it takes time to bring down bdi_dirty.

#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
           <...>-2722  [005]    39.623216: balance_dirty_pages: bdi=8:0 bdi_dirty=106600 bdi_limit=13525 task_limit=13423 task_weight=12% task_gap=-11022% bdi_gap=-5504% dirtied=268 bw=0 ratelimit=0 period=0 think=0 pause=200
           <...>-2720  [004]    39.623222: balance_dirty_pages: bdi=8:0 bdi_dirty=106600 bdi_limit=13513 task_limit=13441 task_weight=9% task_gap=-11029% bdi_gap=-5510% dirtied=267 bw=0 ratelimit=0 period=0 think=0 pause=200                             
           <...>-2717  [003]    39.623666: balance_dirty_pages: bdi=8:0 bdi_dirty=106560 bdi_limit=13742 task_limit=13659 task_weight=10% task_gap=-10815% bdi_gap=-5402% dirtied=268 bw=0 ratelimit=0 period=0 think=0 pause=200                            
           <...>-2718  [004]    39.623990: balance_dirty_pages: bdi=8:0 bdi_dirty=106560 bdi_limit=13979 task_limit=13913 task_weight=8% task_gap=-10603% bdi_gap=-5297% dirtied=272 bw=0 ratelimit=0 period=0 think=0 pause=200                             
           <...>-2715  [007]    39.626472: balance_dirty_pages: bdi=8:0 bdi_dirty=106360 bdi_limit=15312 task_limit=15211 task_weight=11% task_gap=-9523% bdi_gap=-4756% dirtied=268 bw=0 ratelimit=0 period=0 think=0 pause=200                             
           <...>-2723  [001]    39.628951: balance_dirty_pages: bdi=8:0 bdi_dirty=106560 bdi_limit=15749 task_limit=15640 task_weight=11% task_gap=-9236% bdi_gap=-4612% dirtied=269 bw=0 ratelimit=0 period=0 think=0 pause=200                  

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
