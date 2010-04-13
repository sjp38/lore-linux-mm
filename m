Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 10C7F6B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 07:39:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3DBdXr7022336
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Apr 2010 20:39:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 91AAA45DE4F
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:39:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F79D45DE4D
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:39:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 44746E08002
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:39:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EDA83E08001
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 20:39:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <20100413102938.GX2493@dastard>
References: <20100413142445.D0FE.A69D9226@jp.fujitsu.com> <20100413102938.GX2493@dastard>
Message-Id: <20100413201635.D119.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Apr 2010 20:39:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi

> > Pros:
> > 	1) prevent XFS stack overflow
> > 	2) improve io workload performance
> > 
> > Cons:
> > 	3) TOTALLY kill lumpy reclaim (i.e. high order allocation)
> > 
> > So, If we only need to consider io workload this is no downside. but
> > it can't.
> > 
> > I think (1) is XFS issue. XFS should care it itself.
> 
> The filesystem is irrelevant, IMO.
> 
> The traces from the reporter showed that we've got close to a 2k
> stack footprint for memory allocation to direct reclaim and then we
> can put the entire writeback path on top of that. This is roughly
> 3.5k for XFS, and then depending on the storage subsystem
> configuration and transport can be another 2k of stack needed below
> XFS.
> 
> IOWs, if we completely ignore the filesystem stack usage, there's
> still up to 4k of stack needed in the direct reclaim path. Given
> that one of the stack traces supplied show direct reclaim being
> entered with over 3k of stack already used, pretty much any
> filesystem is capable of blowing an 8k stack.
> 
> So, this is not an XFS issue, even though XFS is the first to
> uncover it. Don't shoot the messenger....

Thanks explanation. I haven't noticed direct reclaim consume
2k stack. I'll investigate it and try diet it.
But XFS 3.5K stack consumption is too large too. please diet too.


> > but (2) is really
> > VM issue. Now our VM makes too agressive pageout() and decrease io 
> > throughput. I've heard this issue from Chris (cc to him). I'd like to 
> > fix this.
> 
> I didn't expect this to be easy. ;)
> 
> I had a good look at what the code was doing before I wrote the
> patch, and IMO, there is no good reason for issuing IO from direct
> reclaim.
> 
> My reasoning is as follows - consider a system with a typical
> sata disk and the machine is low on memory and in direct reclaim.
> 
> direct reclaim is taking pages of the end of the LRU and writing
> them one at a time from there. It is scanning thousands of pages
> pages and it triggers IO on on the dirty ones it comes across.
> This is done with no regard to the IO patterns it generates - it can
> (and frequently does) result in completely random single page IO
> patterns hitting the disk, and as a result cleaning pages happens
> really, really slowly. If we are in a OOM situation, the machine
> will grind to a halt as it struggles to clean maybe 1MB of RAM per
> second.
> 
> On the other hand, if the IO is well formed then the disk might be
> capable of 100MB/s. The background flusher threads and filesystems
> try very hard to issue well formed IOs, so the difference in the
> rate that memory can be cleaned may be a couple of orders of
> magnitude.
> 
> (Of course, the difference will typically be somewhere in between
> these two extremes, but I'm simply trying to illustrate how big
> the difference in performance can be.)
> 
> IOWs, the background flusher threads are there to clean memory by
> issuing IO as efficiently as possible.  Direct reclaim is very
> efficient at reclaiming clean memory, but it really, really sucks at
> cleaning dirty memory in a predictable and deterministic manner. It
> is also much more likely to hit worst case IO patterns than the
> background flusher threads.
> 
> Hence I think that direct reclaim should be deferring to the
> background flusher threads for cleaning memory and not trying to be
> doing it itself.

Well, you seems continue to discuss io workload. I don't disagree
such point. 

example, If only order-0 reclaim skip pageout(), we will get the above
benefit too.



> > but we never kill pageout() completely because we can't
> > assume users don't run high order allocation workload.
> 
> I think that lumpy reclaim will still work just fine.
> 
> Lumpy reclaim appears to be using IO as a method of slowing
> down the reclaim cycle - the congestion_wait() call will still
> function as it does now if the background flusher threads are active
> and causing congestion. I don't see why lumpy reclaim specifically
> needs to be issuing IO to make it work - if the congestion_wait() is
> not waiting long enough then wait longer - don't issue IO to extend
> the wait time.

lumpy reclaim is for allocation high order page. then, it not only
reclaim LRU head page, but also its PFN neighborhood. PFN neighborhood
is often newly page and still dirty. then we enfoce pageout cleaning
and discard it.

When high order allocation occur, we don't only need free enough amount
memory, but also need free enough contenious memory block.

If we need to consider _only_ io throughput, waiting flusher thread
might faster perhaps, but actually we also need to consider reclaim
latency. I'm worry about such point too.



> Also, there doesn't appear to be anything special about the chunks of
> pages it's issuing IO on and waiting for, either. They are simply
> the last N pages on the LRU that could be grabbed so they have no
> guarantee of contiguity, so the IO it issues does nothing specific
> to help higher order allocations to succeed.

It does. lumpy reclaim doesn't grab last N pages. instead grab contenious
memory chunk. please see isolate_lru_pages(). 

> 
> Hence it really seems to me that the effectiveness of lumpy reclaim
> is determined mostly by the effectiveness of the IO subsystem - the
> faster the IO subsystem cleans pages, the less time lumpy reclaim
> will block and the faster it will free pages. From this observation
> and the fact that issuing IO only from the bdi flusher threads will
> have the same effect (improves IO subsystem effectiveness), it seems
> to me that lumpy reclaim should not be adversely affected by this
> change.
> 
> Of course, the code is a maze of twisty passages, so I probably
> missed something important. Hopefully someone can tell me what. ;)
> 
> FWIW, the biggest problem here is that I have absolutely no clue on
> how to test what the impact on lumpy reclaim really is. Does anyone
> have a relatively simple test that can be run to determine what the
> impact is?

So, can you please run two workloads concurrently?
 - Normal IO workload (fio, iozone, etc..)
 - echo $NUM > /proc/sys/vm/nr_hugepages

Most typical high order allocation is occur by blutal wireless LAN driver.
(or some cheap LAN card)
But sadly, If the test depend on specific hardware, our discussion might
make mess maze easily. then, I hope to use hugepage feature instead.


Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
