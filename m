Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E33296B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 21:56:41 -0400 (EDT)
Date: Thu, 15 Apr 2010 11:56:25 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100415015625.GP2493@dastard>
References: <20100413143659.GA2493@dastard>
 <20100414031205.GE2493@dastard>
 <20100414155222.D150.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100414155222.D150.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 03:52:32PM +0900, KOSAKI Motohiro wrote:
> > On Wed, Apr 14, 2010 at 12:36:59AM +1000, Dave Chinner wrote:
> > > On Tue, Apr 13, 2010 at 08:39:29PM +0900, KOSAKI Motohiro wrote:
> > > > > FWIW, the biggest problem here is that I have absolutely no clue on
> > > > > how to test what the impact on lumpy reclaim really is. Does anyone
> > > > > have a relatively simple test that can be run to determine what the
> > > > > impact is?
> > > > 
> > > > So, can you please run two workloads concurrently?
> > > >  - Normal IO workload (fio, iozone, etc..)
> > > >  - echo $NUM > /proc/sys/vm/nr_hugepages
> > > 
> > > What do I measure/observe/record that is meaningful?
> > 
> > So, a rough as guts first pass - just run a large dd (8 times the
> > size of memory - 8GB file vs 1GB RAM) and repeated try to allocate
> > the entire of memory in huge pages (500) every 5 seconds. The IO
> > rate is roughly 100MB/s, so it takes 75-85s to complete the dd.
.....
> > Basically, with my patch lumpy reclaim was *substantially* more
> > effective with only a slight increase in average allocation latency
> > with this test case.
....
> > I know this is a simple test case, but it shows much better results
> > than I think anyone (even me) is expecting...
> 
> Ummm...
> 
> Probably, I have to say I'm sorry. I guess my last mail give you
> a misunderstand.
> To be honest, I'm not interest this artificial non fragmentation case.

And to be brutally honest, I'm not interested in wasting my time
trying to come up with a test case that you are interested in.

Instead, can you please you provide me with your test cases
(scripts, preferably) that you use to measure the effectiveness of
reclaim changes and I'll run them.

> The above test-case does 1) discard all cache 2) fill pages by streaming
> io. then, it makes artificial "file offset neighbor == block neighbor == PFN neighbor"
> situation. then, file offset order writeout by flusher thread can make
> PFN contenious pages effectively.

Yes, that's true, but it does indicate that in that situation, it is
more effective than the current code. FWIW, in the case of HPC
applications (which often use huge pages and clear the cache before
starting anew job), large streaming IO is a pretty common IO
pattern, so I don't think this situation is as artificial as you are
indicating.

> Why I dont interest it? because lumpy reclaim is a technique for
> avoiding external fragmentation mess. IOW, it is for avoiding
> worst case. but your test case seems to mesure best one.

Then please provide test cases that you consider valid.

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
