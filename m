Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id A814A6B0062
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:52:17 -0500 (EST)
Date: Wed, 28 Nov 2012 14:52:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kswapd craziness in 3.7
Message-Id: <20121128145215.d23aeb1b.akpm@linux-foundation.org>
In-Reply-To: <20121128101359.GT8218@suse.de>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
	<CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
	<50B52DC4.5000109@redhat.com>
	<20121127214928.GA20253@cmpxchg.org>
	<50B5387C.1030005@redhat.com>
	<20121127222637.GG2301@cmpxchg.org>
	<CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com>
	<20121128101359.GT8218@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 28 Nov 2012 10:13:59 +0000
Mel Gorman <mgorman@suse.de> wrote:

> Based on the reports I've seen I expect the following to work for 3.7
> 
> Keep
>   96710098 mm: revert "mm: vmscan: scale number of pages reclaimed by reclaim/compaction based on failures"
>   ef6c5be6 fix incorrect NR_FREE_PAGES accounting (appears like memory leak)
> 
> Revert
>   82b212f4 Revert "mm: remove __GFP_NO_KSWAPD"
> 
> Merge
>   mm: vmscan: fix kswapd endless loop on higher order allocation
>   mm: Avoid waking kswapd for THP allocations when compaction is deferred or contended

"mm: Avoid waking kswapd for THP ..." is marked "I have not tested it
myself" and when Zdenek tested it he hit an unexplained oom.

> Johannes' patch should remove the necessity for __GFP_NO_KSWAPD revert but I
> think we should also avoid waking kswapd for THP allocations if compaction
> is deferred. Johannes' patch might mean that kswapd goes quickly go back
> to sleep but it's still busy work.
> 
> 3.6 is still known to be screwed in terms of THP because of the amount of
> time it can spend in compaction after lumpy reclaim was removed. This is
> my old list of patches I felt needed to be backported after 3.7 came out.
> They are not tagged -stable, I'll be sending it to Greg manually.
> 
> e64c523 mm: compaction: abort compaction loop if lock is contended or run too long
> 3cc668f mm: compaction: move fatal signal check out of compact_checklock_irqsave
> 661c4cb mm: compaction: Update try_to_compact_pages()kerneldoc comment
> 2a1402a mm: compaction: acquire the zone->lru_lock as late as possible
> f40d1e4 mm: compaction: acquire the zone->lock as late as possible
> 753341a revert "mm: have order > 0 compaction start off where it left"
> bb13ffe mm: compaction: cache if a pageblock was scanned and no pages were isolated
> c89511a mm: compaction: Restart compaction from near where it left off
> 6299702 mm: compaction: clear PG_migrate_skip based on compaction and reclaim activity
> 0db63d7 mm: compaction: correct the nr_strict va isolated check for CMA
> 
> Only Johannes' patch needs to be added to this list. kswapd is not woken
> for THP in 3.6 but as it calls compaction for other high-order allocations
> it still makes sense.

Please identify "Johannes' patch"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
