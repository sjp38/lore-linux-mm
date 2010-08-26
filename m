Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E70B86B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:20:49 -0400 (EDT)
Received: by gwj16 with SMTP id 16so1008867gwj.14
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:20:47 -0700 (PDT)
Date: Fri, 27 Aug 2010 02:20:38 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 0/3] Do not wait the full timeout on
 congestion_wait when there is no congestion
Message-ID: <20100826172038.GA6873@barrios-desktop>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 04:14:13PM +0100, Mel Gorman wrote:
> congestion_wait() is a bit stupid in that it goes to sleep even when there
> is no congestion. This causes stalls in a number of situations and may be
> partially responsible for bug reports about desktop interactivity.
> 
> This patch series aims to account for these unnecessary congestion_waits()
> and to avoid going to sleep when there is no congestion available. Patches
> 1 and 2 add instrumentation related to congestion which should be reuable
> by alternative solutions to congestion_wait. Patch 3 calls cond_resched()
> instead of going to sleep if there is no congestion.
> 
> Once again, I shoved this through performance test. Unlike previous tests,
> I ran this on a ported version of my usual test-suite that should be suitable
> for release soon. It's not quite as good as my old set but it's sufficient
> for this and related series. The tests I ran were kernbench vmr-stream
> iozone hackbench-sockets hackbench-pipes netperf-udp netperf-tcp sysbench
> stress-highalloc. Sysbench was a read/write tests and stress-highalloc is
> the usual stress the number of high order allocations that can be made while
> the system is under severe stress. The suite contains the necessary analysis
> scripts as well and I'd release it now except the documentation blows.
> 
> x86:    Intel Pentium D 3GHz with 3G RAM (no-brand machine)
> x86-64:	AMD Phenom 9950 1.3GHz with 3G RAM (no-brand machine)
> ppc64:	PPC970MP 2.5GHz with 3GB RAM (it's a terrasoft powerstation)
> 
> The disks on all of them were single disks and not particularly fast.
> 
> Comparison was between a 2.6.36-rc1 with patches 1 and 2 applied for
> instrumentation and a second test with patch 3 applied.
> 
> In all cases, kernbench, hackbench, STREAM and iozone did not show any
> performance difference because none of them were pressuring the system
> enough to be calling congestion_wait() so I won't post the results.
> About all worth noting for them is that nothing horrible appeared to break.
> 
> In the analysis scripts, I record unnecessary sleeps to be a sleep that
> had no congestion. The post-processing scripts for cond_resched() will only
> count an uncongested call to congestion_wait() as unnecessary if the process
> actually gets scheduled. Ordinarily, we'd expect it to continue uninterrupted.
> 
> One vague concern I have is when too many pages are isolated, we call
> congestion_wait(). This could now actively spin in the loop for its quanta
> before calling cond_resched(). If it's calling with no congestion, it's
> hard to know what the proper thing to do there is.

Suddenly, many processes could enter into the direct reclaim path by another
reason(ex, fork bomb) regradless of congestion. backing dev congestion is 
just one of them. 

I think if congestion_wait returns without calling io_schedule_timeout 
by your patch, too_many_isolated can schedule_timeout to wait for the system's 
calm to preventing OOM killing.

How about this?

If you don't mind, I will send the patch based on this patch series 
after your patch settle down or Could you add this to your patch series?
But I admit this doesn't almost affect your experiment. 
