Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 28A576B0047
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 06:25:16 -0500 (EST)
Date: Tue, 26 Jan 2010 11:24:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126112459.GA16468@csn.ul.ie>
References: <patchbomb.1264054824@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <patchbomb.1264054824@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 07:20:24AM +0100, Andrea Arcangeli wrote:
> - I need to integrate Mel's memory compation code to be used by khugepaged and
>   by the page faults if "defrag" sysfs file setting requires it. His results
>   (especially with the bug fixes that decreased reclaim a lot) looks promising.
> 

As a heads-up on this. I have a V2 ready for testing but no test machines
available to start any of the tests until the weekend at the earliest. There
are no major changes though. Some cleanup, sysfs prototype and the like. The
basic mechanics are the same.

> - likely we'll need a slab front allocator too allocating in 2m chunks, but
>   this should be re-evaluated after merging Mel's work, maybe he already did
>   that.
> 

He didn't but it occurs to me that it could be tested with SLUB by mucking
around with the min_order parameters.

> - khugepaged isn't yet capable of merging readonly shared anon pages, that
>   isn't needed by KVM (KVM uses MADV_DONTFORK) but it might want to learn it
>   for other apps
> 
> - khugepaged should also learn to skip the copy and collapse the hugepage
>   in-place, if possible (to undo the effect of surpious split_huge_page)
> 
> I'm leaving this under a continous stress with scan_sleep_millisecs and
> defrag_sleep_millisecs set to 0 and a 5G swap storm + ~4G in ram. The swap storm
> before settling in pause() will call madvise to split all hugepages in ram and
> then it will run a further memset again to swapin everything a second time.
> Eventually it will settle and khugepaged will remerge as many hugepages as
> they're fully mapped in userland (mapped as swapcache is ok, but khugepaged
> will not trigger swapin I/O or swapcache minor fault) if there are enough not
> fragmented hugepages available.
> 
> This is shortly after start.
> 
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
> 0  5 3938052  67688    208   3684 1219 2779  1239  2779  396 1061  1  5 75 20
> 2  5 3937092  61612    208   3712 25120 24112 25120 24112 7420 5396  0  8 44 48
> 0  5 3932116  55536    208   3780 26444 21468 26444 21468 7532 5399  0  8 52 40
> 0  5 3927264  46724    208   3296 28208 22528 28328 22528 7871 5722  0  7 52 41
> AnonPages:       1751352 kB
> AnonHugePages:   2021376 kB
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
> r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
> 0  5 3935604  58092    208   3864 1233 2787  1253  2787  400 1061  1  5 74 20
> 0  5 3933924  54248    208   3508 23748 23548 23904 23548 7112 4829  0  6 49 45
> 1  4 3937708  60696    208   3704 24680 28680 24760 28680 7034 5112  0  8 50 42
> 1  4 3934508  59084    208   3304 24096 21020 24156 21020 6832 5015  0  7 48 46
> AnonPages:       1746296 kB
> AnonHugePages:   2023424 kB
> 
> this is after it settled and it's waiting in pause(). khugepaged when it's not
> copying with defrag_sleep/scan_sleep both = 0, just trigers a
> superoverschedule, but as you can see it's extremely low overhead, only taking
> 8% of 4 cores or 32% of 1 core. Likely most of the cpu is taking by schedule().
> So you can imagine how low overhead it is when sleep is set to a "production"
> level and not stress test level. Default sleep is 10seconds and not 2usec...
> 
> 1  0 5680228 106028    396   5060    0    0     0     0  534 341005  0  8 92  0
> 1  0 5680228 106028    396   5060    0    0     0     0  517 349159  0  9 91  0
> 1  0 5680228 106028    396   5060    0    0     0     0  518 346356  0  6 94  0
> 0  0 5680228 106028    396   5060    0    0     0     0  511 348478  0  8 92  0
> AnonPages:        392396 kB
> AnonHugePages:   3371008 kB
> 
> So it looks good so far.
> 
> I think it's probably time to port the patchset to mmotd.
> Further review welcome!
> 
> Andrea
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
