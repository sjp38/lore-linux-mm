Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1E4426B005A
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 18:18:05 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC failures V2
Date: Mon, 26 Oct 2009 23:17:50 +0100
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910262317.55960.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 22 October 2009, Mel Gorman wrote:
> Test 1: Verify your problem occurs on 2.6.32-rc5 if you can

I've tested against 2.6.31.1 as it's easier for me to compare behaviors 
with that than with .32. All patches applied without problems against .31.

I've also tested 2.6.31.1 with SLAB instead of SLUB, but that does not seem 
to make a significant difference for my test.

> Test 2: Apply the following two patches and test again
>   1/5 page allocator: Always wake kswapd when restarting an allocation
>       attempt after direct reclaim failed
>   2/5 page allocator: Do not allow interrupts to use ALLOC_HARDER

Does not look to make any difference. Possibly causes more variation in the 
duration of the test (increases timing effects)?

> Test 3: If you are getting allocation failures, try with the following
> patch
>   3/5 vmscan: Force kswapd to take notice faster when high-order
>       watermarks are being hit

Applied on top of patches 1-2. Does not look to make any difference.

> Test 4: If you are still getting failures, apply the following
>   4/5 page allocator: Pre-emptively wake kswapd when high-order
>       watermarks are hit

Applied on top of patches 1-3. Does not look to make any difference.

> Test 5: If things are still screwed, apply the following
>   5/5 Revert 373c0a7e, 8aa7e847: Fix congestion_wait() sync/async vs
>       read/write confusion

Applied on top of patches 1-4. Despite Jens' scepticism is this still the 
patch that makes the most significant difference in my test.
The reading of commits in gitk is much more fluent and music skips are a 
lot less severe. But most important is that there is no long total freeze 
of the system halfway during the reading of commits and gitk loads 
fastest. It also gives by far the most consistent results.
The likelyhood of SKB allocation errors during the test is a lot smaller.
See also http://lkml.org/lkml/2009/10/26/455.


Detailed test results follow. I've done 2 test runs with each kernel (3 for 
the last).

The columns below give the following info:
- time at which all commits have been read by gitk
- time at which gitk fills in "branch", "follows" and "precedes" data for
  the current commit
- time at which there's no longer any disk activity, i.e. when gitk is
  fully loaded and all swapping is done
- total number of SKB allocation errors during the test
A "freeze" during the reading of commits is indicated by an "f" (short 
freeze) or "F" (long "hard" freeze). An "S" shows when there were SKB 
allocation errors.

		end commits	show branch	done		SKB errs
1) vanilla .31.1
run 1:		1:20 fFS	2:10 S		2:30		44 a)
run 2:		1:35 FS		1:45		2:10		13

2) .31.1 + patches 1-2
run1:		2:30 fFS	2:45		3:00		58
run2:		1:15 fS		2:00		2:20		2 a)

3) .31.1 + patches 1-3
run1:		1:00 fS		1:15		1:45		1 *)
run2:		3:00 fFS	3:15		3:30		33
*) unexpected; fortunate timing?

4) .31.1 + patches 1-4
run1:		1:10 ffS	1:55 S		2:20		35 a)
run2:		3:05 fFS	3:15		3:25		36

5) .31.1 + patches 1-5
run1:		1:00		1:15		1:35		0
run2:		0:50		1:15 S		1:45		45 *)
run3:		1:00		1:15		1:45		0
*) unexpected; unfortunate timing?

a) fast in 1st phase; slow in 2nd and 3rd

Note that without the congestion_wait() reverts occurrence of SKB errors, 
the long freezes and time it takes for gitk to load seem roughly related; 
with the reverts total time is not affected even with many SKB errors.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
