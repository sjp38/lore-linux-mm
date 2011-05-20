Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1116B0033
	for <linux-mm@kvack.org>; Fri, 20 May 2011 13:23:20 -0400 (EDT)
Date: Fri, 20 May 2011 18:23:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
Message-ID: <20110520172314.GW5279@suse.de>
References: <4DCDA347.9080207@cray.com>
 <BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>
 <4DD2991B.5040707@cray.com>
 <BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com>
 <20110520164924.GB2386@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110520164924.GB2386@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Barry <abarry@cray.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>

On Sat, May 21, 2011 at 01:49:24AM +0900, Minchan Kim wrote:
> <SNIP>
> 
> From 8bd3f16736548375238161d1bd85f7d7c381031f Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Sat, 21 May 2011 01:37:41 +0900
> Subject: [PATCH] Prevent unending loop in __alloc_pages_slowpath
> 
> From: Andrew Barry <abarry@cray.com>
> 
> I believe I found a problem in __alloc_pages_slowpath, which allows a process to
> get stuck endlessly looping, even when lots of memory is available.
> 
> Running an I/O and memory intensive stress-test I see a 0-order page allocation
> with __GFP_IO and __GFP_WAIT, running on a system with very little free memory.
> Right about the same time that the stress-test gets killed by the OOM-killer,
> the utility trying to allocate memory gets stuck in __alloc_pages_slowpath even
> though most of the systems memory was freed by the oom-kill of the stress-test.
> 
> The utility ends up looping from the rebalance label down through the
> wait_iff_congested continiously. Because order=0, __alloc_pages_direct_compact
> skips the call to get_page_from_freelist. Because all of the reclaimable memory
> on the system has already been reclaimed, __alloc_pages_direct_reclaim skips the
> call to get_page_from_freelist. Since there is no __GFP_FS flag, the block with
> __alloc_pages_may_oom is skipped. The loop hits the wait_iff_congested, then
> jumps back to rebalance without ever trying to get_page_from_freelist. This loop
> repeats infinitely.
> 
> The test case is pretty pathological. Running a mix of I/O stress-tests that do
> a lot of fork() and consume all of the system memory, I can pretty reliably hit
> this on 600 nodes, in about 12 hours. 32GB/node.
> 
> Signed-off-by: Andrew Barry <abarry@cray.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Mel Gorman <mgorman@suse.de>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
