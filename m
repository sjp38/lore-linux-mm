Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 673BF6B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 19:00:28 -0500 (EST)
Received: by ywh3 with SMTP id 3so3725283ywh.22
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 16:00:26 -0800 (PST)
Date: Tue, 15 Dec 2009 08:54:55 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 8/8] mm: Give up allocation if the task have fatal
 signal
Message-Id: <20091215085455.13eb65cc.minchan.kim@barrios-desktop>
In-Reply-To: <20091214213224.BBC6.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	<20091214210823.BBAE.A69D9226@jp.fujitsu.com>
	<20091214213224.BBC6.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Dec 2009 21:32:58 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> In OOM case, almost processes may be in vmscan. There isn't any reason
> the killed process continue allocation. process exiting free lots pages
> rather than greedy vmscan.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/page_alloc.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ca9cae1..8a9cbaa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1878,6 +1878,14 @@ rebalance:
>  		goto got_pg;
>  
>  	/*
> +	 * If the allocation is for userland page and we have fatal signal,
> +	 * there isn't any reason to continue allocation. instead, the task
> +	 * should exit soon.
> +	 */
> +	if (fatal_signal_pending(current) && (gfp_mask & __GFP_HIGHMEM))
> +		goto nopage;

If we jump nopage, we meets dump_stack and show_mem. 
Even, we can meet OOM which might kill innocent process.

> +
> +	/*
>  	 * If we failed to make any progress reclaiming, then we are
>  	 * running out of options and have to consider going OOM
>  	 */
> -- 
> 1.6.5.2
> 
> 
> 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
