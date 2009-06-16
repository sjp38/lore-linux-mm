Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A4A3D6B0055
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 05:39:52 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5G9f5Qx000955
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Jun 2009 18:41:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 753F345DE53
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 18:41:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BCD145DE59
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 18:41:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EEBB1DB8073
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 18:41:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 928B41DB8062
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 18:41:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] vmscan: Fix use of delta in zone_pagecache_reclaimable()
In-Reply-To: <1245064482-19245-2-git-send-email-mel@csn.ul.ie>
References: <1245064482-19245-1-git-send-email-mel@csn.ul.ie> <1245064482-19245-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20090616184030.99A9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Jun 2009 18:41:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> zone_pagecache_reclaimable() works out how many pages are in a state
> that zone_reclaim() can reclaim based on the current zone_reclaim_mode.
> As part of this, it calculates a delta to the number of unmapped pages.
> The code was meant to check delta would not cause underflows and then apply
> it but it got accidentally removed.
> 
> This patch properly uses delta. It's excessively paranoid at the moment
> because it's impossible to underflow but the current form will make future
> patches to zone_pagecache_reclaimable() fixing any other scan-heuristic
> breakage easier to read and acts as self-documentation reminding authors
> of future patches to consider underflow.
> 
> This is a fix to patch
> vmscan-properly-account-for-the-number-of-page-cache-pages-zone_reclaim-can-reclaim.patch
> and they should be merged together.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 026f452..bd8e3ed 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2398,7 +2398,11 @@ static long zone_pagecache_reclaimable(struct zone *zone)
>  	if (!(zone_reclaim_mode & RECLAIM_WRITE))
>  		delta += zone_page_state(zone, NR_FILE_DIRTY);
>  
> -	return nr_pagecache_reclaimable;
> +	/* Watch for any possible underflows due to delta */
> +	if (unlikely(delta > nr_pagecache_reclaimable))
> +		delta = nr_pagecache_reclaimable;
> +
> +	return nr_pagecache_reclaimable - delta;
>  }

looks good. thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
