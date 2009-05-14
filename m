Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 57E056B01A1
	for <linux-mm@kvack.org>; Thu, 14 May 2009 07:43:30 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4EBi9Jh011162
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 20:44:09 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D06345DE4D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 20:44:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3357245DE4F
	for <linux-mm@kvack.org>; Thu, 14 May 2009 20:44:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E9A89E0800B
	for <linux-mm@kvack.org>; Thu, 14 May 2009 20:44:07 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A2B8D1DB803C
	for <linux-mm@kvack.org>; Thu, 14 May 2009 20:44:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case of no swap space V2
In-Reply-To: <20090514202538.9B81.A69D9226@jp.fujitsu.com>
References: <20090514201150.8536f86e.minchan.kim@barrios-desktop> <20090514202538.9B81.A69D9226@jp.fujitsu.com>
Message-Id: <20090514204033.9B87.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 20:44:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > 
> > Changelog since V2
> >  o Add new function - can_reclaim_anon : it tests anon_list can be reclaim 
> > 
> > Changelog since V1 
> >  o Use nr_swap_pages <= 0 in shrink_active_list to prevent scanning  of active anon list.
> > 
> > Now shrink_active_list is called several places.
> > But if we don't have a swap space, we can't reclaim anon pages.
> > So, we don't need deactivating anon pages in anon lru list.
> > 
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>	
> 
> looks good to me. thanks :)

Grr, my fault.



>  static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  	struct zone *zone, struct scan_control *sc, int priority)
>  {
> @@ -1399,7 +1412,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  		return 0;
>  	}
>  
> -	if (lru == LRU_ACTIVE_ANON && inactive_anon_is_low(zone, sc)) {
> +	if (lru == LRU_ACTIVE_ANON && can_reclaim_anon(zone, sc)) {
>  		shrink_active_list(nr_to_scan, zone, sc, priority, file);
>  		return 0;

you shouldn't do that. if nr_swap_pages==0, get_scan_ratio return anon=0%.
then, this branch is unnecessary.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
