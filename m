Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 544116B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 10:09:25 -0400 (EDT)
Message-ID: <4A438522.7040309@redhat.com>
Date: Thu, 25 Jun 2009 10:09:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] prevent to reclaim anon page of lumpy reclaim for no
 swap space
References: <20090625183616.23b55b24.minchan.kim@barrios-desktop>
In-Reply-To: <20090625183616.23b55b24.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> This patch prevent to reclaim anon page in case of no swap space.
> VM already prevent to reclaim anon page in various place.
> But it doesnt't prevent it for lumpy reclaim.
> 
> It shuffles lru list unnecessary so that it is pointless.
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/vmscan.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 026f452..fb401fe 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -830,7 +830,13 @@ int __isolate_lru_page(struct page *page, int mode, int file)
>  	 * When this function is being called for lumpy reclaim, we
>  	 * initially look into all LRU pages, active, inactive and
>  	 * unevictable; only give shrink_page_list evictable pages.
> +
> +	 * If we don't have enough swap space, reclaiming of anon page
> +	 * is pointless.
>  	 */
> +	if (nr_swap_pages <= 0 && PageAnon(page))
> +		return ret;
> +

Should that be something like this:

	if (nr_swap_pages <= 0 && (PageAnon(page) && !PageSwapCache(page)))

We can still reclaim anonymous pages that already have
a swap slot assigned to them.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
