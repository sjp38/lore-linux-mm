Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7435D6B0202
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:19:03 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F8J0Ko017042
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 17:19:00 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8046345DE4D
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:19:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EFA545DE4E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:19:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40EA0E08006
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:19:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EEB08E08004
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:18:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if current is kswapd
In-Reply-To: <20100415131106.D174.A69D9226@jp.fujitsu.com>
References: <20100415130212.D16E.A69D9226@jp.fujitsu.com> <20100415131106.D174.A69D9226@jp.fujitsu.com>
Message-Id: <20100415171750.D195.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 15 Apr 2010 17:18:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Now, vmscan pageout() is one of IO throuput degression source.
> Some IO workload makes very much order-0 allocation and reclaim
> and pageout's 4K IOs are making annoying lots seeks.
> 
> At least, kswapd can avoid such pageout() because kswapd don't
> need to consider OOM-Killer situation. that's no risk.

I've found one bug in this patch myself. flusher thread don't
pageout anon pages. then, we need PageAnon() check ;)



> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3ff3311..d392a50 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -614,6 +614,13 @@ static enum page_references page_check_references(struct page *page,
>  	if (referenced_page)
>  		return PAGEREF_RECLAIM_CLEAN;
>  
> +	/*
> +	 * Delegate pageout IO to flusher thread. They can make more
> +	 * effective IO pattern.
> +	 */
> +	if (current_is_kswapd())
> +		return PAGEREF_RECLAIM_CLEAN;
> +
>  	return PAGEREF_RECLAIM;
>  }
>  
> -- 
> 1.6.5.2
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
