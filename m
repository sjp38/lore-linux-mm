Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 85A606B005A
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 11:06:56 -0400 (EDT)
Date: Thu, 11 Jun 2009 16:07:04 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] check unevictable flag in lumy reclaim
Message-ID: <20090611150703.GI7302@csn.ul.ie>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com> <20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 05:01:52PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Lumpy reclaim scans pages from their pfn. Then, it can find unevictable pages
> in its loop. Abort lumpy reclaim when we find Unevictable page, we never get a
> block of pages for requested order.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> Index: lumpy-reclaim-trial/mm/vmscan.c
> ===================================================================
> --- lumpy-reclaim-trial.orig/mm/vmscan.c
> +++ lumpy-reclaim-trial/mm/vmscan.c
> @@ -936,6 +936,9 @@ static unsigned long isolate_lru_pages(u
>  			/* Check that we have not crossed a zone boundary. */
>  			if (unlikely(page_zone_id(cursor_page) != zone_id))
>  				continue;
> +			/* Abort when the page is mlocked */
> +			if (unlikely(PageUnevictable(cursor_page)))
> +				break;
>  			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
>  				list_move(&cursor_page->lru, dst);
>  				nr_taken++;
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
