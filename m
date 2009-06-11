Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F4E36B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 04:21:10 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5B8Llj5006466
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 17:21:47 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 79E0945DD72
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:21:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C23DD45DE4F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:21:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F4DA1DB8042
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:21:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CB031DB8037
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 17:21:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] remove wrong rotation at lumpy reclaim
In-Reply-To: <20090611170018.c3758488.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com> <20090611170018.c3758488.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090611172054.6D39.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 17:21:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> At lumpy reclaim, a page failed to be taken by __isolate_lru_page() can
> be pushed back to "src" list by list_move(). But the page may not be from
> "src" list. And list_move() itself is unnecessary because the page is
> not on top of LRU. Then, leave it as it is if __isolate_lru_page() fails.
> 
> This patch doesn't change the logic as "we should exit loop or not" and
> just fixes buggy list_move().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)
> 
> Index: lumpy-reclaim-trial/mm/vmscan.c
> ===================================================================
> --- lumpy-reclaim-trial.orig/mm/vmscan.c
> +++ lumpy-reclaim-trial/mm/vmscan.c
> @@ -936,18 +936,11 @@ static unsigned long isolate_lru_pages(u
>  			/* Check that we have not crossed a zone boundary. */
>  			if (unlikely(page_zone_id(cursor_page) != zone_id))
>  				continue;
> -			switch (__isolate_lru_page(cursor_page, mode, file)) {
> -			case 0:
> +			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
>  				list_move(&cursor_page->lru, dst);
>  				nr_taken++;
>  				scan++;
>  				break;
> -
> -			case -EBUSY:
> -				/* else it is being freed elsewhere */
> -				list_move(&cursor_page->lru, src);
> -			default:
> -				break;	/* ! on LRU or wrong list */
>  			}
>  		}
>  	}
> 

Looks goold. Thanks fixing annoy bug.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
