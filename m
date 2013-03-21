Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 2F1596B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 22:32:16 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 21 Mar 2013 07:57:36 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 9F2AC394002D
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 08:02:08 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2L2W3eL1311132
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 08:02:03 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2L2W8LH003671
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 13:32:08 +1100
Date: Thu, 21 Mar 2013 10:32:06 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: page_alloc: Avoid marking zones full prematurely
 after zone_reclaim()
Message-ID: <20130321023206.GA28909@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130320181957.GA1878@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130320181957.GA1878@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hedi Berriche <hedi@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 20, 2013 at 06:19:57PM +0000, Mel Gorman wrote:
>The following problem was reported against a distribution kernel when
>zone_reclaim was enabled but the same problem applies to the mainline
>kernel. The reproduction case was as follows
>
>1. Run numactl -m +0 dd if=largefile of=/dev/null
>   This allocates a large number of clean pages in node 0
>
>2. numactl -N +0 memhog 0.5*Mg
>   This start a memory-using application in node 0.
>
>The expected behaviour is that the clean pages get reclaimed and the
>application uses node 0 for its memory. The observed behaviour was that
>the memory for the memhog application was allocated off-node since commits
>cd38b11 (mm: page allocator: initialise ZLC for first zone eligible for
>zone_reclaim) and commit 76d3fbf (mm: page allocator: reconsider zones
>for allocation after direct reclaim).
>
>The assumption of those patches was that it was always preferable to
>allocate quickly than stall for long periods of time and they were
>meant to take care that the zone was only marked full when necessary but
>an important case was missed.
>
>In the allocator fast path, only the low watermarks are checked. If the
>zones free pages are between the low and min watermark then allocations
>from the allocators slow path will succeed. However, zone_reclaim
>will only reclaim SWAP_CLUSTER_MAX or 1<<order pages. There is no
>guarantee that this will meet the low watermark causing the zone to be
>marked full prematurely.
>
>This patch will only mark the zone full after zone_reclaim if it the min
>watermarks are checked or if page reclaim failed to make sufficient
>progress.
>
>Reported-and-tested-by: Hedi Berriche <hedi@sgi.com>
>Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/page_alloc.c | 17 ++++++++++++++++-
> 1 file changed, 16 insertions(+), 1 deletion(-)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 8fcced7..adce823 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -1940,9 +1940,24 @@ zonelist_scan:
> 				continue;
> 			default:
> 				/* did we reclaim enough */
>-				if (!zone_watermark_ok(zone, order, mark,
>+				if (zone_watermark_ok(zone, order, mark,
> 						classzone_idx, alloc_flags))
>+					goto try_this_zone;
>+
>+				/*
>+				 * Failed to reclaim enough to meet watermark.
>+				 * Only mark the zone full if checking the min
>+				 * watermark or if we failed to reclaim just
>+				 * 1<<order pages or else the page allocator
>+				 * fastpath will prematurely mark zones full
>+				 * when the watermark is between the low and
>+				 * min watermarks.
>+				 */
>+				if ((alloc_flags & ALLOC_WMARK_MIN) ||
>+				    ret == ZONE_RECLAIM_SOME)
> 					goto this_zone_full;
>+
>+				continue;
> 			}
> 		}
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
