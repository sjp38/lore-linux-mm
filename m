Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D758E6B01AD
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 14:13:36 -0400 (EDT)
Date: Fri, 11 Jun 2010 19:13:14 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100611181314.GA9946@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <1275987745-21708-7-git-send-email-mel@csn.ul.ie> <20100610231706.1d7528f2.akpm@linux-foundation.org> <20100611162523.GA24707@infradead.org> <20100611104331.d8463580.akpm@linux-foundation.org> <20100611174900.GA32761@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100611174900.GA32761@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 11, 2010 at 01:49:00PM -0400, Christoph Hellwig wrote:
> On Fri, Jun 11, 2010 at 10:43:31AM -0700, Andrew Morton wrote:
> > Of course, but making a change like that in the current VM will cause a
> > large number of dirty pages to get refiled, so the impact of this
> > change on some workloads could be quite bad.
> 
> Note that ext4, btrfs and xfs all error out on ->writepage from reclaim
> context.  That is both kswapd and direct reclaim because there is no way
> to distinguish between the two. 

What's wrong with PF_KSWAPD?

> Things seem to work fine with these
> filesystems, so the issue can't be _that_ bad.  Of course reducing this
> to just error out from direct reclaim, and fixing them VM to better
> cope with it is even better.
> 

I have some preliminary figures but tests are still ongoing but right
now, it doesn't seem as bad as was expected. Only my ppc64 machine has
finished tests so here is what I found. The tests I used were kernbench,
iozone, simple-writeback and stress-highalloc

This data is based on the tracepoints. Three kernels are tested on a new
patch stack (not posted yet but bits and pieces of it have)

traceonly	- Just the tracepoints
stackreduce	- Reduces the stack usage of page reclaim in general.
		  This is more a thread originally posted over a month
		  ago and picked up again in the interest of allowing
		  kswapd to do writeback at some point in the future.
nodirect	- Avoid writing any pages direct reclaim. This is the
		last patch from this series juggled slightly.

kernbench FTrace Reclaim Statistics
            
                			traceonly-v2r5  stackreduce-v2r5  nodirect-v2r5
Direct reclaims                                0        0        0 
Direct reclaim pages scanned                   0        0        0 
Direct reclaim write sync I/O                  0        0        0 
Direct reclaim write async I/O                 0        0        0 
Wake kswapd requests                           0        0        0 
Kswapd wakeups                                 0        0        0 
Kswapd pages scanned                           0        0        0 
Kswapd reclaim write sync I/O                  0        0        0 
Kswapd reclaim write async I/O                 0        0        0 
Time stalled direct reclaim                 0.00     0.00     0.00 
Time kswapd awake                           0.00     0.00     0.00 

No surprises, kernbench is not memory intensive so reclaim didn't happen


iozone FTrace Reclaim Statistics
                			traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
Direct reclaims                                0        0        0 
Direct reclaim pages scanned                   0        0        0 
Direct reclaim write sync I/O                  0        0        0 
Direct reclaim write async I/O                 0        0        0 
Wake kswapd requests                           0        0        0 
Kswapd wakeups                                 0        0        0 
Kswapd pages scanned                           0        0        0 
Kswapd reclaim write sync I/O                  0        0        0 
Kswapd reclaim write async I/O                 0        0        0 
Time stalled direct reclaim                 0.00     0.00     0.00 
Time kswapd awake                           0.00     0.00     0.00 

Again, not very surprising. Memory pressure was not a factor for iozone.

simple-writeback FTrace Reclaim Statistics
                			traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
Direct reclaims                             4098     2436     5670 
Direct reclaim pages scanned              393664   215821   505483 
Direct reclaim write sync I/O                  0        0        0 
Direct reclaim write async I/O                 0        0        0 
Wake kswapd requests                      865097   728976  1036147 
Kswapd wakeups                               639      561      585 
Kswapd pages scanned                    11123648 10383929 10561818 
Kswapd reclaim write sync I/O                  0        0        0 
Kswapd reclaim write async I/O              3595        0    19068 
Time stalled direct reclaim              2843.74  2771.71    32.76 
Time kswapd awake                         347.58  8865.65   433.27 

This is a dd-orientated benchmark that was intended to just generate IO.
On a 4-core machine it starts with 4 jobs. Each iteration of the test
increases the number of jobs until a total of 64 are running. The total
amount of data written is 4*PhysicalMemory. dd was run with conv=fsync so
the timing figures would be a bit more stable but unfortunately, the figures
from the VM with respect to reclaim are not very stable. The intention was
to create a lot of dirty data and see what fell out.

Interestingly, direct reclaim didn't write pages in any of the kernels and
kswapd was not crazy on the amount it wrote out implying that in this test
at least, there were not many dirty pages on the LRU. Disabling writeback in
direct reclaim did mean that processes were stalled less but that is hardly
a surprise.

stress-highorder FTrace Reclaim Statistics
                traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
Direct reclaims                             2143     2184      847 
Direct reclaim pages scanned              181293   191127   136593 
Direct reclaim write sync I/O              13709    15617        0 
Direct reclaim write async I/O             26686    28058        0 
Wake kswapd requests                         234      217    17271 
Kswapd wakeups                               200      192      145 
Kswapd pages scanned                    10810122  9822064  3104526 
Kswapd reclaim write sync I/O                  0        0        0 
Kswapd reclaim write async I/O            790109   762967   236092 
Time stalled direct reclaim              1956.76  1810.06  1395.76 
Time kswapd awake                        1171.50  1174.24   484.00 

This test starts a number of simulatenous kernel compiles whose total size
exceeeds physical memory and then tries to allocate as many huge pages as there
is physical memory. This stresses page reclaim, particularly lumpy reclaim.

As expected, with direct reclaim not able to writeback, the IO counts
for it are 0 and it stalled less as you might expect. What was very
unexpected is that kswapd wrote fewer pages with direct relcaim disabled
than with.

I think with this test, much of the direct reclaim IO was due to lumpy
reclaim. So far, I'm not seeing as many dirty pages on the LRU as I was
expecting - even more lumpy reclaim. Does anyone have a test in mind
that is known to cause serious problems with dirty pages on the LRU?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
