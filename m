Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B1E126B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 23:02:59 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D32sOh003871
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 13 May 2010 12:02:54 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A51345DE62
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:02:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2044045DE61
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:02:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0711AE08005
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:02:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B6994E08002
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:02:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/5] vmscan: fix unmapping behaviour for RECLAIM_SWAP
In-Reply-To: <20100430224315.912441727@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org> <20100430224315.912441727@cmpxchg.org>
Message-Id: <20100512122434.2133.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 May 2010 12:02:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

sorry for the long delayed review.

> The RECLAIM_SWAP flag in zone_reclaim_mode controls whether
> zone_reclaim() is allowed to swap or not (obviously).
> 
> This is currently implemented by allowing or forbidding reclaim to
> unmap pages, which also controls reclaim of shared pages and is thus
> not appropriate.
> 
> We can do better by using the sc->may_swap parameter instead, which
> controls whether the anon lists are scanned.
> 
> Unmapping of pages is then allowed per default from zone_reclaim().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2563,8 +2563,8 @@ static int __zone_reclaim(struct zone *z
>  	int priority;
>  	struct scan_control sc = {
>  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> -		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> -		.may_swap = 1,
> +		.may_unmap = 1,
> +		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>  		.nr_to_reclaim = max_t(unsigned long, nr_pages,
>  				       SWAP_CLUSTER_MAX),
>  		.gfp_mask = gfp_mask,

About half years ago, I did post exactly same patch. but at that time,
it got Mel's objection. after some discution we agreed to merge
documentation change instead code fix.

So, now the documentation describe clearly 4th bit meant no unmap.
Please drop this, instead please make s/RECLAIM_SWAP/RECLAIM_MAPPED/ patch.

But if mel ack this, I have no objection.


----------------------------------------------------------
commit 90afa5de6f3fa89a733861e843377302479fcf7e
Author: Mel Gorman <mel@csn.ul.ie>
Date:   Tue Jun 16 15:33:20 2009 -0700

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 0ea5adb..c4de635 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -315,10 +315,14 @@ min_unmapped_ratio:

 This is available only on NUMA kernels.

-A percentage of the total pages in each zone.  Zone reclaim will only
-occur if more than this percentage of pages are file backed and unmapped.
-This is to insure that a minimal amount of local pages is still available for
-file I/O even if the node is overallocated.
+This is a percentage of the total pages in each zone. Zone reclaim will
+only occur if more than this percentage of pages are in a state that
+zone_reclaim_mode allows to be reclaimed.
+
+If zone_reclaim_mode has the value 4 OR'd, then the percentage is compared
+against all file-backed unmapped pages including swapcache pages and tmpfs
+files. Otherwise, only unmapped pages backed by normal files but not tmpfs
+files and similar are considered.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
