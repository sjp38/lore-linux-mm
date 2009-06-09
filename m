Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C4A06B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:59:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n599TVer007577
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 18:29:33 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EBA2145DE7B
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:29:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CA87045DE6F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:29:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7A7F1DB8042
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:29:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 63D9D1DB803F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:29:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] fix wrong lru rotate back at lumpty reclaim
In-Reply-To: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090609181745.DD88.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 18:29:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In lumpty reclaim, "cursor_page" is found just by pfn. Then, we don't know
     ^^^^^^
     lumpy?

> from which LRU "cursor" page came from. Then, putback it to "src" list is BUG.
> Just leave it as it is.
> (And I think rotate here is overkilling even if "src" is correct.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Yes, thanks great catch!

lumpy reclaimed neighbor pages doesn't need to ratate, it because
neighbor pages doesn't stay in head of lru list.


   Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



> ---
>  mm/vmscan.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> Index: mmotm-2.6.30-Jun4/mm/vmscan.c
> ===================================================================
> --- mmotm-2.6.30-Jun4.orig/mm/vmscan.c
> +++ mmotm-2.6.30-Jun4/mm/vmscan.c
> @@ -940,10 +940,9 @@ static unsigned long isolate_lru_pages(u
>  				nr_taken++;
>  				scan++;
>  				break;
> -
>  			case -EBUSY:
> -				/* else it is being freed elsewhere */
> -				list_move(&cursor_page->lru, src);
> +				/* Do nothing because we don't know where
> + 				   cusrsor_page comes from */
>  			default:
>  				break;	/* ! on LRU or wrong list */
>  			}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
