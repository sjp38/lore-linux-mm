Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5A6376B02A5
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 04:21:14 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o698L9P8020654
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 17:21:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DB8745DE4F
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 17:21:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 62CE245DE4E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 17:21:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B0981DB804C
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 17:21:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C4A901DB8047
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 17:21:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 2/2] vmscan: shrink_slab() require number of lru_pages, not page order
In-Reply-To: <20100708133152.5e556508.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1007080901460.9707@router.home> <20100708133152.5e556508.akpm@linux-foundation.org>
Message-Id: <20100709171850.FA22.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Jul 2010 17:21:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> > The "lru_pages" parameter is really a division factor affecting
> > the number of pages scanned. This patch increases this division factor
> > significantly and therefore reduces the number of items scanned during
> > zone_reclaim.
> > 
> 
> And for that reason I won't apply the patch.  I'd be crazy to do so. 
> It tosses away four years testing, replacing it with something which
> could have a large effect on reclaim behaviour, with no indication
> whether that effect is good or bad.

Unfortunatelly, current code is more crazy. it is nearly worst bad behavior.
I've applied attached debugging patch and got following result.

That said, really low memory pressure (scan = 32, order = 0) drop _all_
icache and dcache (about 100MB!). I don't blieve anyone tested slab behavior
on zone_reclaim=1 for this four years.

please remember shrink_slab() scanning equation. order=0 always makes
all slab dropping!

btw, current shrink_slab() don't exit even if (*shrinker->shrink)(0) return 0.
It's a bit inefficient and meaningless loop iteration. I'll make a fix.


           <...>-2677  [001]   840.832711: shrink_slab: shrink_icache_memory before=56100 after=56000
           <...>-2677  [001]   840.832898: shrink_slab: shrink_icache_memory before=56000 after=55900
           <...>-2677  [001]   840.833081: shrink_slab: shrink_icache_memory before=55900 after=55800
           <...>-2677  [001]   840.833693: shrink_slab: shrink_icache_memory before=55800 after=55600
           <...>-2677  [001]   840.833860: shrink_slab: shrink_icache_memory before=55600 after=55500
           <...>-2677  [001]   840.834033: shrink_slab: shrink_icache_memory before=55500 after=55400
           <...>-2677  [001]   840.834201: shrink_slab: shrink_icache_memory before=55400 after=55200
           <...>-2677  [001]   840.834385: shrink_slab: shrink_icache_memory before=55200 after=55100
           <...>-2677  [001]   840.834553: shrink_slab: shrink_icache_memory before=55100 after=55000
           <...>-2677  [001]   840.834720: shrink_slab: shrink_icache_memory before=55000 after=54900
           <...>-2677  [001]   840.834889: shrink_slab: shrink_icache_memory before=54900 after=54700
           <...>-2677  [001]   840.835063: shrink_slab: shrink_icache_memory before=54700 after=54600
           <...>-2677  [001]   840.835229: shrink_slab: shrink_icache_memory before=54600 after=54500
           <...>-2677  [001]   840.835596: shrink_slab: shrink_icache_memory before=54500 after=54300
           <...>-2677  [001]   840.835761: shrink_slab: shrink_icache_memory before=54300 after=54200
           <...>-2677  [001]   840.835926: shrink_slab: shrink_icache_memory before=54200 after=54100
           <...>-2677  [001]   840.836097: shrink_slab: shrink_icache_memory before=54100 after=54000
           <...>-2677  [001]   840.836284: shrink_slab: shrink_icache_memory before=54000 after=53800
           <...>-2677  [001]   840.836453: shrink_slab: shrink_icache_memory before=53800 after=53700
           <...>-2677  [001]   840.836621: shrink_slab: shrink_icache_memory before=53700 after=53600
           <...>-2677  [001]   840.836793: shrink_slab: shrink_icache_memory before=53600 after=53500
           <...>-2677  [001]   840.836962: shrink_slab: shrink_icache_memory before=53500 after=53300
           <...>-2677  [001]   840.837137: shrink_slab: shrink_icache_memory before=53300 after=53200
           <...>-2677  [001]   840.837317: shrink_slab: shrink_icache_memory before=53200 after=53100
           <...>-2677  [001]   840.837485: shrink_slab: shrink_icache_memory before=53100 after=52900
           <...>-2677  [001]   840.837652: shrink_slab: shrink_icache_memory before=52900 after=52800
           <...>-2677  [001]   840.837821: shrink_slab: shrink_icache_memory before=52800 after=52700
           <...>-2677  [001]   840.837993: shrink_slab: shrink_icache_memory before=52700 after=52600
           <...>-2677  [001]   840.838168: shrink_slab: shrink_icache_memory before=52600 after=52400
           <...>-2677  [001]   840.838353: shrink_slab: shrink_icache_memory before=52400 after=52300
           <...>-2677  [001]   840.838524: shrink_slab: shrink_icache_memory before=52300 after=52200
           <...>-2677  [001]   840.838695: shrink_slab: shrink_icache_memory before=52200 after=52000
           <...>-2677  [001]   840.838865: shrink_slab: shrink_icache_memory before=52000 after=51900
           <...>-2677  [001]   840.839037: shrink_slab: shrink_icache_memory before=51900 after=51800
           <...>-2677  [001]   840.839207: shrink_slab: shrink_icache_memory before=51800 after=51700
           <...>-2677  [001]   840.839422: shrink_slab: shrink_icache_memory before=51700 after=51500
           <...>-2677  [001]   840.839589: shrink_slab: shrink_icache_memory before=51500 after=51400
           <...>-2677  [001]   840.839753: shrink_slab: shrink_icache_memory before=51400 after=51300
           <...>-2677  [001]   840.839920: shrink_slab: shrink_icache_memory before=51300 after=51100
           <...>-2677  [001]   840.840094: shrink_slab: shrink_icache_memory before=51100 after=51000
           <...>-2677  [001]   840.840278: shrink_slab: shrink_icache_memory before=51000 after=50900
           <...>-2677  [001]   840.840446: shrink_slab: shrink_icache_memory before=50900 after=50800
           <...>-2677  [001]   840.840618: shrink_slab: shrink_icache_memory before=50800 after=50600
           <...>-2677  [001]   840.840787: shrink_slab: shrink_icache_memory before=50600 after=50500
           <...>-2677  [001]   840.840953: shrink_slab: shrink_icache_memory before=50500 after=50400
           <...>-2677  [001]   840.841128: shrink_slab: shrink_icache_memory before=50400 after=50300
           <...>-2677  [001]   840.841310: shrink_slab: shrink_icache_memory before=50300 after=50100
           <...>-2677  [001]   840.841480: shrink_slab: shrink_icache_memory before=50100 after=50000
           <...>-2677  [001]   840.841649: shrink_slab: shrink_icache_memory before=50000 after=49900
           <...>-2677  [001]   840.841815: shrink_slab: shrink_icache_memory before=49900 after=49700
           <...>-2677  [001]   840.841984: shrink_slab: shrink_icache_memory before=49700 after=49600
           <...>-2677  [001]   840.842159: shrink_slab: shrink_icache_memory before=49600 after=49500
           <...>-2677  [001]   840.842346: shrink_slab: shrink_icache_memory before=49500 after=49400
           <...>-2677  [001]   840.842515: shrink_slab: shrink_icache_memory before=49400 after=49200
           <...>-2677  [001]   840.842684: shrink_slab: shrink_icache_memory before=49200 after=49100
           <...>-2677  [001]   840.842864: shrink_slab: shrink_icache_memory before=49100 after=49000
           <...>-2677  [001]   840.843039: shrink_slab: shrink_icache_memory before=49000 after=48800
           <...>-2677  [001]   840.843205: shrink_slab: shrink_icache_memory before=48800 after=48700
           <...>-2677  [001]   840.843391: shrink_slab: shrink_icache_memory before=48700 after=48600
           <...>-2677  [001]   840.843560: shrink_slab: shrink_icache_memory before=48600 after=48500
           <...>-2677  [001]   840.843735: shrink_slab: shrink_icache_memory before=48500 after=48300
           <...>-2677  [001]   840.844964: shrink_slab: shrink_icache_memory before=48300 after=48200
           <...>-2677  [001]   840.845242: shrink_slab: shrink_icache_memory before=48200 after=48100
           <...>-2677  [001]   840.845411: shrink_slab: shrink_icache_memory before=48100 after=47900
           <...>-2677  [001]   840.845581: shrink_slab: shrink_icache_memory before=47900 after=47800
           <...>-2677  [001]   840.845752: shrink_slab: shrink_icache_memory before=47800 after=47700
           <...>-2677  [001]   840.845920: shrink_slab: shrink_icache_memory before=47700 after=47600
           <...>-2677  [001]   840.860766: shrink_slab: shrink_icache_memory before=47600 after=47400
           <...>-2677  [001]   840.860949: shrink_slab: shrink_icache_memory before=47400 after=47300
           <...>-2677  [001]   840.861118: shrink_slab: shrink_icache_memory before=47300 after=47200
           <...>-2677  [001]   840.861306: shrink_slab: shrink_icache_memory before=47200 after=47100
           <...>-2677  [001]   840.861476: shrink_slab: shrink_icache_memory before=47100 after=46900
           <...>-2677  [001]   840.861646: shrink_slab: shrink_icache_memory before=46900 after=46800
           <...>-2677  [001]   840.861817: shrink_slab: shrink_icache_memory before=46800 after=46700
           <...>-2677  [001]   840.861986: shrink_slab: shrink_icache_memory before=46700 after=46500
           <...>-2677  [001]   840.862159: shrink_slab: shrink_icache_memory before=46500 after=46400
           <...>-2677  [001]   840.862438: shrink_slab: shrink_icache_memory before=46400 after=46300
           <...>-2677  [001]   840.862626: shrink_slab: shrink_icache_memory before=46300 after=46200
           <...>-2677  [001]   840.862796: shrink_slab: shrink_icache_memory before=46200 after=46000
           <...>-2677  [001]   840.862963: shrink_slab: shrink_icache_memory before=46000 after=45900
           <...>-2677  [001]   840.863148: shrink_slab: shrink_icache_memory before=45900 after=45800
           <...>-2677  [001]   840.863323: shrink_slab: shrink_icache_memory before=45800 after=45600
           <...>-2677  [001]   840.863492: shrink_slab: shrink_icache_memory before=45600 after=45500
           <...>-2677  [001]   840.863656: shrink_slab: shrink_icache_memory before=45500 after=45400
           <...>-2677  [001]   840.863821: shrink_slab: shrink_icache_memory before=45400 after=45300
           <...>-2677  [001]   840.863988: shrink_slab: shrink_icache_memory before=45300 after=45100
CPU:1 [LOST 702 EVENTS]
           <...>-2677  [001]   840.928410: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928411: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928412: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928414: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928415: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928416: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928418: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928419: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928420: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928422: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928423: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928425: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928426: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928427: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928429: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928430: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928432: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928433: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928434: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928436: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928437: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928438: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928440: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928441: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928443: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928444: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928445: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928447: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928448: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928449: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928451: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928452: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928454: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928455: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928456: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928458: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928459: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928460: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928462: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928463: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928464: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928466: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928467: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928468: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928470: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928471: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928473: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928474: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928475: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928477: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928478: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928479: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928481: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928482: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928483: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928485: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928486: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928487: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928489: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928490: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928492: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928493: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928494: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928496: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928497: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928498: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928500: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928501: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928502: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928504: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928505: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928506: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928508: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928509: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928510: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928512: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928513: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928515: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928516: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928518: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928519: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928520: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928522: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928523: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928524: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928526: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928527: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928529: shrink_slab: shrink_icache_memory before=0 after=0
           <...>-2677  [001]   840.928532: zone_reclaim: scan 32, order 0, old 39546 new 16605





diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5a377e6..5767a08 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -244,6 +244,12 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,

                        nr_before = (*shrinker->shrink)(0, gfp_mask);
                        shrink_ret = (*shrinker->shrink)(this_scan, gfp_mask);
+
+                       trace_printk("%pf before=%d after=%d\n",
+                                    shrinker->shrink,
+                                    nr_before,
+                                    shrink_ret);
+
                        if (shrink_ret == -1)
                                break;
                        if (shrink_ret < nr_before)
@@ -2619,10 +2625,23 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int orde
                 * Note that shrink_slab will free memory on all zones and may
                 * take a long time.
                 */
-               while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
-                       zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
-                               slab_reclaimable - nr_pages)
-                       ;
+               for (;;) {
+                       unsigned long slab;
+
+                       if (!shrink_slab(sc.nr_scanned, gfp_mask, order))
+                               break;
+
+                       slab = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+
+                       trace_printk("scan %lu, order %d, old %lu new %lu\n",
+                                    sc.nr_scanned,
+                                    order,
+                                    slab_reclaimable,
+                                    slab);
+
+                       if (slab + nr_pages <= slab_reclaimable)
+                               break;
+               }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
