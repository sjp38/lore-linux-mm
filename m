Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id BA2486B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 07:36:22 -0400 (EDT)
Date: Thu, 28 Jun 2012 12:36:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: excessive CPU utilization by isolate_freepages?
Message-ID: <20120628113619.GR8103@csn.ul.ie>
References: <4FEB8237.6030402@sandia.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FEB8237.6030402@sandia.gov>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Schutt <jaschut@sandia.gov>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>

On Wed, Jun 27, 2012 at 03:59:19PM -0600, Jim Schutt wrote:
> Hi,
> 
> I'm running into trouble with systems going unresponsive,
> and perf suggests it's excessive CPU usage by isolate_freepages().
> I'm currently testing 3.5-rc4, but I think this problem may have
> first shown up in 3.4.  I'm only just learning how to use perf,
> so I only currently have results to report for 3.5-rc4.
> 

Out of curiosity, why do you think it showed up in 3.4? It's not
surprising as such if it did show up there but I'm wondering what you
are basing it on.

It's not a suprise because it's also where reclaim/compaction stopped
depending on lumpy reclaim. In the past we would have reclaimed more
pages but now rely on compaction more. It's plassible that for many
parallel compactions that there would be higher CPU usage now.

> <SNIP>
> 2012-06-27 14:00:03.219-06:00
> vmstat -w 4 16
> procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
>  r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
> 75  1          0     566988        576   35664800    0    0     2  1355   21    3   1  4  95  0  0
> 433  1          0     964052        576   35069112    0    0     7 456359 102256 20901   2 98   0  0  0
> 547  3          0     820116        576   34893932    0    0    57 560507 114878 28115   3 96   0  0  0
> 806  2          0     606992        576   34848180    0    0   339 309668 101230 21056   2 98   0  0  0
> 708  1          0     529624        576   34708000    0    0   248 370886 101327 20062   2 97   0  0  0
> 231  5          0     504772        576   34663880    0    0   305 334824 95045 20407   2 97   1  1  0
> 158  6          0    1063088        576   33518536    0    0   531 847435 130696 47140   4 92   1  2  0
> 193  0          0    1449156        576   33035572    0    0   363 371279 94470 18955   2 96   1  1  0
> 266  6          0    1623512        576   32728164    0    0    77 241114 95730 15483   2 98   0  0  0
> 243  8          0    1629504        576   32653080    0    0    81 471018 100223 20920   3 96   0  1  0
> 70 11          0    1342140        576   33084020    0    0   100 925869 139876 56599   6 88   3  3  0
> 211  7          0    1130316        576   33470432    0    0   290 1008984 150699 74320   6 83   6  5  0
> 365  3          0     776736        576   34072772    0    0   182 747167 139436 67135   5 88   4  3  0
> 29  1          0    1528412        576   34110640    0    0    50 612181 137403 77609   4 87   6  3  0
> 266  5          0    1657688        576   34105696    0    0     3 258307 62879 38508   2 93   3  2  0
> 1159  2          0    2002256        576   33775476    0    0    19 88554 42112 14230   1 98   0  0  0
> 

ok, so System CPU usage through the roof.

> 
> Right around 14:00 I was able to get a "perf -a -g"; here's the
> beginning of what "perf report --sort symbol --call-graph fractal,5"
> had to say:
> 
> #
>     64.86%  [k] _raw_spin_lock_irqsave
>             |
>             |--97.94%-- isolate_freepages
>             |          compaction_alloc
>             |          unmap_and_move
>             |          migrate_pages
>             |          compact_zone
>             |          |
>             |          |--99.56%-- try_to_compact_pages
>             |          |          __alloc_pages_direct_compact
>             |          |          __alloc_pages_slowpath
>             |          |          __alloc_pages_nodemask
>             |          |          alloc_pages_vma
>             |          |          do_huge_pmd_anonymous_page
>             |          |          handle_mm_fault
>             |          |          do_page_fault
>             |          |          page_fault
>             |          |          |
>             |          |          |--53.53%-- skb_copy_datagram_iovec
>             |          |          |          tcp_recvmsg
>             |          |          |          inet_recvmsg
>             |          |          |          sock_recvmsg
>             |          |          |          sys_recvfrom
>             |          |          |          system_call_fastpath
>             |          |          |          __recv
>             |          |          |          |
>             |          |          |           --100.00%-- (nil)
>             |          |          |
>             |          |          |--27.80%-- __pthread_create_2_1
>             |          |          |          (nil)
>             |          |          |
>             |          |           --18.67%-- memcpy
>             |          |                     |
>             |          |                     |--57.38%-- 0x50d000005
>             |          |                     |
>             |          |                     |--34.52%-- 0x3b300bf271940a35
>             |          |                     |
>             |          |                      --8.10%-- 0x1500000000000009
>             |           --0.44%-- [...]
>              --2.06%-- [...]
> 

This looks like lock contention to me on zone->lock which
isolate_freepages takes and releases frequently. You do not describe the
exact memory layout but it's likely that there are two very large zones
with 12 CPUs each. If they all were running compaction they would pound
zone->lock pretty heavily.

> <SNIP>

The other call traces also look like they are pounding zone->lock
heavily.

Rik's patch has the potential to reduce contention by virtue of the fact
that less scanning is required. I'd be interested in hearing how much of
an impact that patch has so please test that first.

If that approach does not work I'll put together a patch that either
backs off compaction on zone->lock contention.

> I seem to be able to recreate this issue at will, so please
> let me know what I can do to help learn what is going on.
> 

Thanks very much for testing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
