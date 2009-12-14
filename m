Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B62096B0047
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 18:52:07 -0500 (EST)
Received: by gxk24 with SMTP id 24so2216022gxk.6
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 15:52:06 -0800 (PST)
Date: Tue, 15 Dec 2009 08:46:36 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 5/8] Use io_schedule() instead schedule()
Message-Id: <20091215084636.c7790658.minchan.kim@barrios-desktop>
In-Reply-To: <20091214213026.BBBD.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	<20091214210823.BBAE.A69D9226@jp.fujitsu.com>
	<20091214213026.BBBD.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Dec 2009 21:30:54 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> All task sleeping point in vmscan (e.g. congestion_wait) use
> io_schedule. then shrink_zone_begin use it too.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3562a2d..0880668 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1624,7 +1624,7 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
>  		    max_zone_concurrent_reclaimers)
>  			break;
>  
> -		schedule();
> +		io_schedule();

Hmm. We have many cond_resched which is not io_schedule in vmscan.c.
In addition, if system doesn't have swap device space and out of page cache 
due to heavy memory pressue, VM might scan & drop pages until priority is zero
or zone is unreclaimable. 

I think it would be not a IO wait.





>  
>                 /*
>                  * If other processes freed enough memory while we waited,
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
