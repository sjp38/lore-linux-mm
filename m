Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 84B576B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 10:37:16 -0400 (EDT)
Date: Wed, 14 Apr 2010 00:36:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100413143659.GA2493@dastard>
References: <20100413142445.D0FE.A69D9226@jp.fujitsu.com>
 <20100413102938.GX2493@dastard>
 <20100413201635.D119.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413201635.D119.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 08:39:29PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > > Pros:
> > > 	1) prevent XFS stack overflow
> > > 	2) improve io workload performance
> > > 
> > > Cons:
> > > 	3) TOTALLY kill lumpy reclaim (i.e. high order allocation)
> > > 
> > > So, If we only need to consider io workload this is no downside. but
> > > it can't.
> > > 
> > > I think (1) is XFS issue. XFS should care it itself.
> > 
> > The filesystem is irrelevant, IMO.
> > 
> > The traces from the reporter showed that we've got close to a 2k
> > stack footprint for memory allocation to direct reclaim and then we
> > can put the entire writeback path on top of that. This is roughly
> > 3.5k for XFS, and then depending on the storage subsystem
> > configuration and transport can be another 2k of stack needed below
> > XFS.
> > 
> > IOWs, if we completely ignore the filesystem stack usage, there's
> > still up to 4k of stack needed in the direct reclaim path. Given
> > that one of the stack traces supplied show direct reclaim being
> > entered with over 3k of stack already used, pretty much any
> > filesystem is capable of blowing an 8k stack.
> > 
> > So, this is not an XFS issue, even though XFS is the first to
> > uncover it. Don't shoot the messenger....
> 
> Thanks explanation. I haven't noticed direct reclaim consume
> 2k stack. I'll investigate it and try diet it.
> But XFS 3.5K stack consumption is too large too. please diet too.

It hasn't grown in the last 2 years after the last major diet where
all the fat was trimmed from it in the last round of the i386 4k
stack vs XFS saga. it seems that everything else around XFS has
grown in that time, and now we are blowing stacks again....

> > Hence I think that direct reclaim should be deferring to the
> > background flusher threads for cleaning memory and not trying to be
> > doing it itself.
> 
> Well, you seems continue to discuss io workload. I don't disagree
> such point. 
> 
> example, If only order-0 reclaim skip pageout(), we will get the above
> benefit too.

But it won't prevent start blowups...

> > > but we never kill pageout() completely because we can't
> > > assume users don't run high order allocation workload.
> > 
> > I think that lumpy reclaim will still work just fine.
> > 
> > Lumpy reclaim appears to be using IO as a method of slowing
> > down the reclaim cycle - the congestion_wait() call will still
> > function as it does now if the background flusher threads are active
> > and causing congestion. I don't see why lumpy reclaim specifically
> > needs to be issuing IO to make it work - if the congestion_wait() is
> > not waiting long enough then wait longer - don't issue IO to extend
> > the wait time.
> 
> lumpy reclaim is for allocation high order page. then, it not only
> reclaim LRU head page, but also its PFN neighborhood. PFN neighborhood
> is often newly page and still dirty. then we enfoce pageout cleaning
> and discard it.

Ok, I see that now - I missed the second call to __isolate_lru_pages()
in isolate_lru_pages().

> When high order allocation occur, we don't only need free enough amount
> memory, but also need free enough contenious memory block.

Agreed, that was why I was kind of surprised not to find it was
doing that. But, as you have pointed out, that was my mistake.

> If we need to consider _only_ io throughput, waiting flusher thread
> might faster perhaps, but actually we also need to consider reclaim
> latency. I'm worry about such point too.

True, but without know how to test and measure such things I can't
really comment...

> > Of course, the code is a maze of twisty passages, so I probably
> > missed something important. Hopefully someone can tell me what. ;)
> > 
> > FWIW, the biggest problem here is that I have absolutely no clue on
> > how to test what the impact on lumpy reclaim really is. Does anyone
> > have a relatively simple test that can be run to determine what the
> > impact is?
> 
> So, can you please run two workloads concurrently?
>  - Normal IO workload (fio, iozone, etc..)
>  - echo $NUM > /proc/sys/vm/nr_hugepages

What do I measure/observe/record that is meaningful?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
