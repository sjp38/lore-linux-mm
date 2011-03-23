Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D41408D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 04:24:40 -0400 (EDT)
Received: by pxi10 with SMTP id 10so1623041pxi.8
        for <linux-mm@kvack.org>; Wed, 23 Mar 2011 01:24:38 -0700 (PDT)
Date: Wed, 23 Mar 2011 17:24:23 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
Message-ID: <20110323082423.GA1969@barrios-desktop>
References: <20110323142133.1AC6.A69D9226@jp.fujitsu.com>
 <AANLkTim1HcdkPcxnWrv+VbMUSh3kQBC=-myZ-j-a8Wiy@mail.gmail.com>
 <20110323161354.1AD2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110323161354.1AD2.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Mar 23, 2011 at 04:13:21PM +0900, KOSAKI Motohiro wrote:
> > Okay. I got it.
> > 
> > The problem is following as.
> > By the race the free_pcppages_bulk and balance_pgdat, it is possible
> > zone->all_unreclaimable = 1 and zone->pages_scanned = 0.
> > DMA zone have few LRU pages and in case of no-swap and big memory
> > pressure, there could be a just a page in inactive file list like your
> > example. (anon lru pages isn't important in case of non-swap system)
> > In such case, shrink_zones doesn't scan the page at all until priority
> > become 0 as get_scan_count does scan >>= priority(it's mostly zero).
> 
> Nope.
> 
>                         if (zone->all_unreclaimable && priority != DEF_PRIORITY)
>                                 continue;
> 
> This tow lines mean, all_unreclaimable prevent priority 0 reclaim.
> 

Yes. I missed it. Thanks. 

> 
> > And although priority become 0, nr_scan_try_batch returns zero until
> > saved pages become 32. So for scanning the page, at least, we need 32
> > times iteration of priority 12..0.  If system has fork-bomb, it is
> > almost livelock.
> 
> Therefore, 1000 times get_scan_count(DEF_PRIORITY) takes 1000 times no-op.
> 
> > 
> > If is is right, how about this?
> 
> Boo.
> You seems forgot why you introduced current all_unreclaimable() function.
> While hibernation, we can't trust all_unreclaimable.

Hmm. AFAIR, the why we add all_unreclaimable is when the hibernation is going on,
kswapd is freezed so it can't mark the zone->all_unreclaimable.
So I think hibernation can't be a problem.
Am I miss something?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
