Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1ECA06B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 18:09:00 -0500 (EST)
Received: by ywh3 with SMTP id 3so3683109ywh.22
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 15:08:59 -0800 (PST)
Date: Tue, 15 Dec 2009 08:03:28 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/8] Use prepare_to_wait_exclusive() instead
 prepare_to_wait()
Message-Id: <20091215080328.b4af59ad.minchan.kim@barrios-desktop>
In-Reply-To: <20091214212936.BBBA.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	<20091214210823.BBAE.A69D9226@jp.fujitsu.com>
	<20091214212936.BBBA.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Dec 2009 21:30:19 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> if we don't use exclusive queue, wake_up() function wake _all_ waited
> task. This is simply cpu wasting.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e0cb834..3562a2d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1618,7 +1618,7 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
>  	 * we would just make things slower.
>  	 */
>  	for (;;) {
> -		prepare_to_wait(wq, &wait, TASK_UNINTERRUPTIBLE);
> +		prepare_to_wait_exclusive(wq, &wait, TASK_UNINTERRUPTIBLE);
>  
>  		if (atomic_read(&zone->concurrent_reclaimers) <=
>  		    max_zone_concurrent_reclaimers)
> @@ -1632,7 +1632,7 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
>                  */
>  		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
>  					0, 0)) {
> -			wake_up(wq);
> +			wake_up_all(wq);

I think it's typo. The description in changelog says we want "wake_up". 
Otherwise, looks good to me.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
