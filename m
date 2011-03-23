Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C3DC08D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 03:13:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8BA243EE0BD
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:13:22 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7183045DE56
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:13:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B58C45DE51
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:13:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D76EE78003
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:13:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA9A41DB803E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 16:13:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <AANLkTim1HcdkPcxnWrv+VbMUSh3kQBC=-myZ-j-a8Wiy@mail.gmail.com>
References: <20110323142133.1AC6.A69D9226@jp.fujitsu.com> <AANLkTim1HcdkPcxnWrv+VbMUSh3kQBC=-myZ-j-a8Wiy@mail.gmail.com>
Message-Id: <20110323161354.1AD2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 23 Mar 2011 16:13:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

> Okay. I got it.
> 
> The problem is following as.
> By the race the free_pcppages_bulk and balance_pgdat, it is possible
> zone->all_unreclaimable = 1 and zone->pages_scanned = 0.
> DMA zone have few LRU pages and in case of no-swap and big memory
> pressure, there could be a just a page in inactive file list like your
> example. (anon lru pages isn't important in case of non-swap system)
> In such case, shrink_zones doesn't scan the page at all until priority
> become 0 as get_scan_count does scan >>= priority(it's mostly zero).

Nope.

                        if (zone->all_unreclaimable && priority != DEF_PRIORITY)
                                continue;

This tow lines mean, all_unreclaimable prevent priority 0 reclaim.


> And although priority become 0, nr_scan_try_batch returns zero until
> saved pages become 32. So for scanning the page, at least, we need 32
> times iteration of priority 12..0.  If system has fork-bomb, it is
> almost livelock.

Therefore, 1000 times get_scan_count(DEF_PRIORITY) takes 1000 times no-op.

> 
> If is is right, how about this?

Boo.
You seems forgot why you introduced current all_unreclaimable() function.
While hibernation, we can't trust all_unreclaimable.

That's the reason why I proposed following patch when you introduced
all_unreclaimable().


---
 mm/vmscan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c391c32..1919d8a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -40,6 +40,7 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <linux/oom.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1931,7 +1932,7 @@ out:
 		return sc->nr_reclaimed;
 
 	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (scanning_global_lru(sc) && !all_unreclaimable)
+	if (scanning_global_lru(sc) && !all_unreclaimable && !oom_killer_disabled)
 		return 1;
 
 	return 0;
-- 
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
