Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5682A6B0071
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 21:20:34 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I2KV1u021463
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Jan 2010 11:20:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4801145DE53
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:20:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1789745DE55
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:20:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BCE51DB8064
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:20:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 010441DB805A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:20:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [linux-pm] [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: Memory allocations in .suspend became very unreliable)
In-Reply-To: <201001180125.59413.rjw@sisk.pl>
References: <1263745267.2162.42.camel@barrios-desktop> <201001180125.59413.rjw@sisk.pl>
Message-Id: <20100118111703.AE36.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 18 Jan 2010 11:20:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -1963,10 +1963,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
>  	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
>  			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
>  			preferred_zone, migratetype);
> -	if (unlikely(!page))
> +	if (unlikely(!page)) {
> +		mm_lock_suspend(gfp_mask);
>  		page = __alloc_pages_slowpath(gfp_mask, order,
>  				zonelist, high_zoneidx, nodemask,
>  				preferred_zone, migratetype);
> +		mm_unlock_suspend(gfp_mask);
> +	}
>  
>  	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
>  	return page;

I think we don't need read side lock at all. generally, no lock might makes race.
But in this case, changing gfp_allowed_mask and nvidia suspend method should be
serialized higher level. Why the above two code need to run concurrently?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
