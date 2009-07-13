Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 24EC46B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 22:28:05 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D2lmdY009355
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 13 Jul 2009 11:47:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A67D45DE7F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 11:47:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D530645DE7B
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 11:47:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DDE61DB8041
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 11:47:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A817E08003
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 11:47:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] switch free memory back to MIGRATE_MOVABLE
In-Reply-To: <20090713023030.GA27269@sli10-desk.sh.intel.com>
References: <20090713023030.GA27269@sli10-desk.sh.intel.com>
Message-Id: <20090713113326.624F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 13 Jul 2009 11:47:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> When page is back to buddy and its order is bigger than pageblock_order, we can
> switch its type to MIGRATE_MOVABLE. This can reduce fragmentation. The patch
> has obvious effect when read a block device and then drop caches.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

This patch change hot path, but there is no performance mesurement description.
Also, I don't like modification buddy core for only drop caches.



> ---
>  mm/page_alloc.c |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> Index: linux/mm/page_alloc.c
> ===================================================================
> --- linux.orig/mm/page_alloc.c	2009-07-10 11:36:07.000000000 +0800
> +++ linux/mm/page_alloc.c	2009-07-13 09:25:21.000000000 +0800
> @@ -475,6 +475,15 @@ static inline void __free_one_page(struc
>  		order++;
>  	}
>  	set_page_order(page, order);
> +
> +	if (order >= pageblock_order && migratetype != MIGRATE_MOVABLE) {
> +		int i;
> +
> +		migratetype = MIGRATE_MOVABLE;
> +		for (i = 0; i < (1 << (order - pageblock_order)); i++)
> +			set_pageblock_migratetype(page +
> +				i * pageblock_nr_pages, MIGRATE_MOVABLE);
> +	}
>  	list_add(&page->lru,
>  		&zone->free_area[order].free_list[migratetype]);
>  	zone->free_area[order].nr_free++;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
