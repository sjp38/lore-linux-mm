Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7725C6B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 22:26:54 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5S2Qpve022459
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Jun 2010 11:26:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4966545DE57
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:26:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B0EB45DE52
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:26:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 08471E08003
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:26:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B4AD21DB8014
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:26:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] vmscan: don't subtraction of unsined 
In-Reply-To: <alpine.DEB.2.00.1006250912380.18900@router.home>
References: <20100625202126.806A.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006250912380.18900@router.home>
Message-Id: <20100628101802.386A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Jun 2010 11:26:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 25 Jun 2010, KOSAKI Motohiro wrote:
> 
> > 'slab_reclaimable' and 'nr_pages' are unsigned. so, subtraction is
> > unsafe.
> 
> Why? We are subtracting the current value of NR_SLAB_RECLAIMABLE from the
> earlier one. The result can be negative (maybe concurrent allocations) and
> then the nr_reclaimed gets decremented instead. This is  okay since we
> have not reached our goal then of reducing the number of reclaimable slab
> pages on the zone.

It's unsigned. negative mean very big value. so

"zone_page_state(zone, NR_SLAB_RECLAIMABLE) > slab_reclaimable - nr_pages)" will
be evaluated false.

ok, your mysterious 'order' parameter (as pointed [1/2]) almostly prevent this case.
because passing 'order' makes very heavy slab pressure and it avoid negative occur.

but unnaturall coding style can make confusing to reviewers. ya, it's not
big issue. but I also don't find no fixing reason.


> 
> > @@ -2622,17 +2624,21 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  		 * Note that shrink_slab will free memory on all zones and may
> >  		 * take a long time.
> >  		 */
> > -		while (shrink_slab(sc.nr_scanned, gfp_mask, lru_pages) &&
> > -			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
> > -				slab_reclaimable - nr_pages)
> 
> The comparison could be a problem here. So
> 
> 			zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
> 				slab_reclaimable
> 
> ?

My patch take the same thing. but It avoided two line comparision.
Do you mean you like this style? (personally, I don't). If so, I'll 
repost this patch.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
