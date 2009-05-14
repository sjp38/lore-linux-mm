Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8DD686B01AE
	for <linux-mm@kvack.org>; Thu, 14 May 2009 08:11:33 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4ECBgBo008369
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 21:11:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB7CC45DE54
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:11:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A037745DE51
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:11:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 689EB1DB8040
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:11:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 12F981DB8041
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:11:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case  of no swap space V2
In-Reply-To: <28c262360905140505h2db7ac3bp5ca10fcf2b4301bb@mail.gmail.com>
References: <20090514204033.9B87.A69D9226@jp.fujitsu.com> <28c262360905140505h2db7ac3bp5ca10fcf2b4301bb@mail.gmail.com>
Message-Id: <20090514210839.9B90.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 21:11:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Thu, May 14, 2009 at 8:44 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> >
> >> > Changelog since V2
> >> > ?o Add new function - can_reclaim_anon : it tests anon_list can be reclaim
> >> >
> >> > Changelog since V1
> >> > ?o Use nr_swap_pages <= 0 in shrink_active_list to prevent scanning ?of active anon list.
> >> >
> >> > Now shrink_active_list is called several places.
> >> > But if we don't have a swap space, we can't reclaim anon pages.
> >> > So, we don't need deactivating anon pages in anon lru list.
> >> >
> >> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> > Cc: Rik van Riel <riel@redhat.com>
> >>
> >> looks good to me. thanks :)
> >
> > Grr, my fault.
> >
> >
> >
> >> ?static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
> >> ? ? ? struct zone *zone, struct scan_control *sc, int priority)
> >> ?{
> >> @@ -1399,7 +1412,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
> >> ? ? ? ? ? ? ? return 0;
> >> ? ? ? }
> >>
> >> - ? ? if (lru == LRU_ACTIVE_ANON && inactive_anon_is_low(zone, sc)) {
> >> + ? ? if (lru == LRU_ACTIVE_ANON && can_reclaim_anon(zone, sc)) {
> >> ? ? ? ? ? ? ? shrink_active_list(nr_to_scan, zone, sc, priority, file);
> >> ? ? ? ? ? ? ? return 0;
> >
> > you shouldn't do that. if nr_swap_pages==0, get_scan_ratio return anon=0%.
> > then, this branch is unnecessary.
> >
> 
> But, I think at last it can be happen following as.
> 
> 1515         * Even if we did not try to evict anon pages at all, we want to
> 1516         * rebalance the anon lru active/inactive ratio.
> 1517         */
> 1518        if (inactive_anon_is_low(zone, sc))
> 1519                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);

I pointed to shrink_list(), but you replayed shrink_zone().
I only talked about shrink_list().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
