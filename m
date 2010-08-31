Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFA26B01F0
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 03:53:42 -0400 (EDT)
Date: Tue, 31 Aug 2010 08:53:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Question of backporting the trace-vmscan-postprocess.pl
Message-ID: <20100831075323.GA13677@csn.ul.ie>
References: <AANLkTikW74dzq9v1EF1n8SD+T9d8d-EfNgC5m3aXyfL1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTikW74dzq9v1EF1n8SD+T9d8d-EfNgC5m3aXyfL1@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 30, 2010 at 04:10:05PM -0700, Ying Han wrote:
> Hi Mel:
> 
> I've been looking into the vmscan:tracing you added for 2.6.36_rc1. I
> also backported into 2.6.34 which is the kernel we are currently
> working on. However, I seems can not get it fully functional. Are you
> aware of any changes on the kernel tracing ABI which could cause that
> ?
> 

Nothing springs to mind but ...

> Here is how I reproduce it and I also attached the
> postprocess/trace-vmscan-postprocess.pl I patched.
> 
> # mount -t debugfs nodev /sys/kernel/debug/
> 
> # for i in `find /sys/kernel/debug/tracing/events -name "enable" |
> grep mm_`; do echo 1 > $i; done
> 
> run a process with pid==30196
> 
> # echo 'common_pid == 30196' > /sys/kernel/debug/tracing/events/vmscan/filter
> 
> # cat /sys/kernel/debug/tracing/events/vmscan/filter
> common_pid == 30196
> 
> # ./trace-vmscan-postprocess.pl < /sys/kernel/debug/tracing/trace_pipe
> WARNING: Event vmscan/mm_vmscan_lru_shrink_inactive format string not found
> WARNING: Event vmscan/mm_vmscan_lru_shrink_active format string not found
> ^CSIGINT received, report pending. Hit ctrl-c again to exit
> 

I didn't test the script for live processing. I was logging
/sys/kernel/debug/tracing/trace_pipe to a file and post-processing it
after a test. I suggest you do the same and check if any events for pid
30196 were recorded.

> Reclaim latencies expressed as order-latency_in_ms
> 
> Process          Direct     Wokeup      Pages      Pages    Pages
> Time
> details           Rclms     Kswapd    Scanned    Sync-IO ASync-IO
> Stalled
> 
> Kswapd           Kswapd      Order      Pages      Pages    Pages
> Instance        Wakeups  Re-wakeup    Scanned    Sync-IO ASync-IO
> 
> Summary
> Direct reclaims:     			
> Direct reclaim pages scanned:		
> Direct reclaim write file sync I/O:	
> Direct reclaim write anon sync I/O:	
> Direct reclaim write file async I/O:	
> Direct reclaim write anon async I/O:	
> Wake kswapd requests:			
> Time stalled direct reclaim: 		0.00 seconds
> 
> Kswapd wakeups:				
> Kswapd pages scanned:			
> Kswapd reclaim write file sync I/O:	
> Kswapd reclaim write anon sync I/O:	
> Kswapd reclaim write file async I/O:	
> Kswapd reclaim write anon async I/O:	
> Time kswapd awake:			0.00 seconds
> 
> So it didn't give me any output. However, if I turn off the filter for
> vmscan, it did give me some data but with random processes on the
> system.
> 

Did one of them processes include 30196 that you were filtering for?

> The same set of tests works for trace-pagealloc-postprocess.pl though
> 
> # cat /sys/kernel/debug/tracing/events/kmem/filter
> common_pid == 30196
> 
> # ./trace-pagealloc-postprocess.pl < /sys/kernel/debug/tracing/trace_pipe
> 
> Process           Pages      Pages      Pages    Pages       PCPU
> PCPU     PCPU   Fragment Fragment  MigType Fragment Fragment  Unknown
> details          allocd     allocd      freed    freed      pages
> drains  refills   Fallback  Causing  Changed   Severe Moderate
>                         under lock     direct  pagevec      drain
> -30196             2871       2917          0        0          0
>   0      439         32       32        0       32        0        0
> ddtest-30196       4560       4328          0        0          0
>   0      639         26       26        1       25        1        0
> 

Maybe there were page allocator events and not vmscan events?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
