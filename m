Date: Wed, 9 Jan 2008 13:16:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 07/19] (NEW) add some sanity checks to get_scan_ratio
Message-Id: <20080109131642.56b3fa91.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080108210005.558041779@redhat.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210005.558041779@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 08 Jan 2008 15:59:46 -0500
Rik van Riel <riel@redhat.com> wrote:

> The access ratio based scan rate determination in get_scan_ratio
> works ok in most situations, but needs to be corrected in some
> corner cases:
> - if we run out of swap space, do not bother scanning the anon LRUs
> - if we have already freed all of the page cache, we need to scan
>   the anon LRUs
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> 
> Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-07 17:33:50.000000000 -0500
> +++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-07 17:57:49.000000000 -0500
> @@ -1182,7 +1182,7 @@ static unsigned long shrink_list(enum lr
>  static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
>  					unsigned long *percent)
>  {
> -	unsigned long anon, file;
> +	unsigned long anon, file, free;
>  	unsigned long anon_prio, file_prio;
>  	unsigned long rotate_sum;
>  	unsigned long ap, fp;
> @@ -1230,6 +1230,20 @@ static void get_scan_ratio(struct zone *
>  	else if (fp > 100)
>  		fp = 100;
>  	percent[1] = fp;
> +
> +	free = zone_page_state(zone, NR_FREE_PAGES);
> +
> +	/*
> +	 * If we have no swap space, do not bother scanning anon pages
> +	 */
> +	if (nr_swap_pages <= 0)
> +		percent[0] = 0;
Doesn't this mean that swap-cache in ACTIVE_ANON_LIST is not scanned ?
Or swap-cache is in File-Cache list ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
