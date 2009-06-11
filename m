Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C6F3D6B0055
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 04:24:16 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5B8OxPU025138
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 17:25:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 953F445DE6E
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:24:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D17E45DE60
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:24:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 52EB2E08009
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:24:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6BAAE08003
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:24:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] check unevictable flag in lumy reclaim
In-Reply-To: <20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com> <20090611170152.7a43b13b.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090611172249.6D3C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 17:24:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Lumpy reclaim scans pages from their pfn. Then, it can find unevictable pages
> in its loop. Abort lumpy reclaim when we find Unevictable page, we never get a
> block of pages for requested order.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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

The code is good. thanks.

But please comment adding more. plus, unevictable is made by multiple reason.
not only mlock. please fix misleading comment.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
