Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 479656B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 09:37:49 -0500 (EST)
Date: Wed, 10 Nov 2010 14:37:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Reduce latencies and improve overall reclaim
	efficiency v2
Message-ID: <20101110143733.GD19679@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <4CB721A1.4010508@linux.vnet.ibm.com> <20101018135535.GC30667@csn.ul.ie> <4CD13E7B.5090804@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4CD13E7B.5090804@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 11:50:35AM +0100, Christian Ehrhardt wrote:
> 
> 
> On 10/18/2010 03:55 PM, Mel Gorman wrote:
> > On Thu, Oct 14, 2010 at 05:28:33PM +0200, Christian Ehrhardt wrote:
> > 
> >> Seing the patches Mel sent a few weeks ago I realized that this series
> >> might be at least partially related to my reports in 1Q 2010 - so I ran my
> >> testcase on a few kernels to provide you with some more backing data.
> > 
> > Thanks very much for revisiting this.
> > 
> >> Results are always the average of three iozone runs as it is known to be somewhat noisy - especially when affected by the issue I try to show here.
> >> As discussed in detail in older threads the setup uses 16 disks and scales the number of concurrent iozone processes.
> >> Processes are evenly distributed so that it always is one process per disk.
> >> In the past we reported 40% to 80% degradation for the sequential read case based on 2.6.32 which can still be seen.
> >> What we found was that the allocations for page cache with GFP_COLD flag loop a long time between try_to_free, get_page, reclaim as free makes some progress and due to that GFP_COLD allocations can loop and retry.
> >> In addition my case had no writes at all, which forced congestion_wait to wait the full timeout all the time.
> >>
> >> Kernel (git)                   4          8         16   deviation #16 case                           comment
> >> linux-2.6.30              902694    1396073    1892624                 base                              base
> >> linux-2.6.32              752008     990425     932938               -50.7%     impact as reported in 1Q 2010
> >> linux-2.6.35               63532      71573      64083               -96.6%                    got even worse
> >> linux-2.6.35.6            176485     174442     212102               -88.8%  fixes useful, but still far away
> >> linux-2.6.36-rc4-trace    119683     188997     187012               -90.1%                         still bad
> >> linux-2.6.36-rc4-fix      884431    1114073    1470659               -22.3%            Mels fixes help a lot!
> >>
> [...]
> > If all goes according to plan,
> > kernel 2.6.37-rc1 will be of interest. Thanks again.
> 
> Here a measurement with 2.6.37-rc1 as confirmation of progress:
>    linux-2.6.37-rc1          876588    1161876    1643430               -13.1%       even better than 2.6.36-fix
> 

Ok, great. There were a few other changes related to reclaim and
writeback that I expected to help, but was not certain. It's good to
have confirmation.

> That means 2.6.37-rc1 really shows what we hoped for.
> And it eventually even turned out a little bit better than 2.6.36 + your fixes.
> 

Good. I looked over your data and I see we are still losing time but I
haven't new ideas on how to improve it further yet without falling into the
"special case" hole. I'll keep on it and hopefully we can get parity
performance on read while still keeping the write improvements.

Thanks a lot for testing this.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
