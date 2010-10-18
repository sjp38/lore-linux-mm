Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0B40A6B00A5
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:55:55 -0400 (EDT)
Date: Mon, 18 Oct 2010 14:55:36 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Reduce latencies and improve overall reclaim
	efficiency v2
Message-ID: <20101018135535.GC30667@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <4CB721A1.4010508@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4CB721A1.4010508@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 05:28:33PM +0200, Christian Ehrhardt wrote:

> Seing the patches Mel sent a few weeks ago I realized that this series
> might be at least partially related to my reports in 1Q 2010 - so I ran my
> testcase on a few kernels to provide you with some more backing data.

Thanks very much for revisiting this.

> Results are always the average of three iozone runs as it is known to be somewhat noisy - especially when affected by the issue I try to show here.
> As discussed in detail in older threads the setup uses 16 disks and scales the number of concurrent iozone processes.
> Processes are evenly distributed so that it always is one process per disk.
> In the past we reported 40% to 80% degradation for the sequential read case based on 2.6.32 which can still be seen.
> What we found was that the allocations for page cache with GFP_COLD flag loop a long time between try_to_free, get_page, reclaim as free makes some progress and due to that GFP_COLD allocations can loop and retry.
> In addition my case had no writes at all, which forced congestion_wait to wait the full timeout all the time.
> 
> Kernel (git)                   4          8         16   deviation #16 case                           comment
> linux-2.6.30              902694    1396073    1892624                 base                              base
> linux-2.6.32              752008     990425     932938               -50.7%     impact as reported in 1Q 2010
> linux-2.6.35               63532      71573      64083               -96.6%                    got even worse
> linux-2.6.35.6            176485     174442     212102               -88.8%  fixes useful, but still far away
> linux-2.6.36-rc4-trace    119683     188997     187012               -90.1%                         still bad 

FWIW, I wouldn't expect the trace kernel to help. It's only adding the
markers but not doing anything useful with them.

> linux-2.6.36-rc4-fix      884431    1114073    1470659               -22.3%            Mels fixes help a lot!
> 
> So much from the case that I used when I reported the issue earlier this year.
> The short summary is that the patch series from Mel helps a lot for my test case.
> 

This is good to hear. We're going in the right direction at least.

> So I guess Mel you now want some traces of the last two cases right?
> Could you give me some minimal advice what/how you would exactly need.
> 

Yes please. Please do something like the following before the test

mount -t debugfs none /sys/kernel/debug
echo 1 > /sys/kernel/debug/tracing/events/vmscan/enable
echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_congestion_wait/enable
echo 1 > /sys/kernel/debug/tracing/events/writeback/writeback_wait_iff_congested/enable
cat /sys/kernel/debug/tracing/trace_pipe > trace.log &

rerun the test, gzip trace.log and drop it on some publicly accessible
webserver. I can rerun the analysis scripts and see if something odd
falls out.

> In addition it worked really fine, so you can add both, however you like.
> Reported-by: <ehrhardt@linux.vnet.ibm.com>
> Tested-by: <ehrhardt@linux.vnet.ibm.com>
> 
> Note: it might be worth to mention that the write case improved a lot since 2.6.30.
> Not directly related to the read degradations, but with up to 150% (write) 272% (rewrite).
> Therefore not everything is bad :-) 
> 

Every cloud has a silver lining I guess :)

> Any further comments or questions?
> 

The log might help me further in figuring out how and why we are losing
time. When/if the patches move from -mm to mainline, it'd also be worth
retesting as there is some churn in this area and we need to know whether
we are heading in the right direction or not. If all goes according to plan,
kernel 2.6.37-rc1 will be of interest. Thanks again.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
