Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4ED456B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 18:40:36 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0CNeXb3007153
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Jan 2010 08:40:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD36A45DE6E
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 08:40:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9928945DE60
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 08:40:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6848C1DB803E
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 08:40:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 198F71DB803B
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 08:40:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm-2010-01-06-14-34] check high watermark after shrink zone
In-Reply-To: <20100112150152.78604b78.akpm@linux-foundation.org>
References: <20100108141235.ef56b567.minchan.kim@barrios-desktop> <20100112150152.78604b78.akpm@linux-foundation.org>
Message-Id: <20100113083339.B3C5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Jan 2010 08:40:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> >  mm/vmscan.c |   21 +++++++++++----------
> >  1 files changed, 11 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 885207a..b81adf8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2057,9 +2057,6 @@ loop_again:
> >  					priority != DEF_PRIORITY)
> >  				continue;
> >  
> > -			if (!zone_watermark_ok(zone, order,
> > -					high_wmark_pages(zone), end_zone, 0))
> > -				all_zones_ok = 0;
> 
> This will make kswapd stop doing reclaim if all zones have
> zone_is_all_unreclaimable():
> 
> 			if (zone_is_all_unreclaimable(zone))
> 				continue;
> 
> This seems bad.

No. That's intentional, I think. All zones of small asymmetric numa
node are always unreclaimable typically. stopping kswapd prevent to
waste 100% cpu time such situation.

In the other hand, This logic doesn't cause disaster to symmetric numa.
it merely cause direct reclaim and re-wakeup kswapd.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
