Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49CFD6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 02:26:08 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so16618971pat.3
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 23:26:08 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 81si2300050pfw.133.2016.07.06.23.26.06
        for <linux-mm@kvack.org>;
        Wed, 06 Jul 2016 23:26:07 -0700 (PDT)
Date: Thu, 7 Jul 2016 15:27:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 11/31] mm: vmscan: do not reclaim from kswapd if there is
 any eligible zone
Message-ID: <20160707062701.GC18072@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-12-git-send-email-mgorman@techsingularity.net>
 <20160705061117.GD28164@bbox>
 <20160705103806.GH11498@techsingularity.net>
 <20160706012554.GD12570@bbox>
 <20160706084200.GM11498@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160706084200.GM11498@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 06, 2016 at 09:42:00AM +0100, Mel Gorman wrote:
<snip>
> > > > 
> > > > If buffer_head is over limit, old logic force to reclaim highmem but
> > > > this zone_balanced logic will prevent it.
> > > > 
> > > 
> > > The old logic was always busted on 64-bit because is_highmem would always
> > > be 0. The original intent appears to be that buffer_heads_over_limit
> > > would release the buffers when pages went inactive. There are a number
> > 
> > Yes but the difference is in old, it was handled both direct and background
> > reclaim once buffers_heads is over the limit but your change slightly
> > changs it so kswapd couldn't reclaim high zone if any eligible zone
> > is balanced. I don't know how big difference it can make but we saw
> > highmem buffer_head problems several times, IIRC. So, I just wanted
> > to notice it to you. whether it's handled or not, it's up to you.
> > 
> 
> The last time I remember buffer_heads_over_limit was an NTFS filesystem
> using small sub-page block sizes with a large highmem:lowmem ratio. If a
> similar situation is encountered then a test patch would be something like;
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index dc12af938a8d..a8ebd1871f16 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3151,7 +3151,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  		 * zone was balanced even under extreme pressure when the
>  		 * overall node may be congested.
>  		 */
> -		for (i = sc.reclaim_idx; i >= 0; i--) {
> +		for (i = sc.reclaim_idx; i >= 0 && !buffer_heads_over_limit; i--) {
>  			zone = pgdat->node_zones + i;
>  			if (!populated_zone(zone))
>  				continue;
> 
> I'm not going to go with it for now because buffer_heads_over_limit is not
> necessarily a problem unless lowmem is factor. We don't want background
> reclaim to go ahead unnecessarily just because buffer_heads_over_limit.
> It could be distinguished by only forcing reclaim to go ahead on systems
> with highmem.

If you don't think it's a problem, I don't want to insist on it because I don't
have any report/workload right now. Instead, please write some comment in there
for others to understand why kswapd is okay to ignore buffer_heads_over_limit
unlike direct reclaim. Such non-symmetric behavior is really hard to follow
without any description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
