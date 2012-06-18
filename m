Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id BD7316B0062
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 20:43:47 -0400 (EDT)
Message-ID: <4FDE79CF.4050702@kernel.org>
Date: Mon, 18 Jun 2012 09:43:59 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com> <20120614145716.GA2097@barrios> <CAHGf_=qcA5OfuNgk0BiwyshcLftNWoPfOO_VW9H6xQTX2tAbuA@mail.gmail.com> <4FDAE3CC.60801@kernel.org> <CAEtiSavv8nRAFk6VZEgeCMYicjBPy4244+2KQhng5Pq9bxcX5A@mail.gmail.com>
In-Reply-To: <CAEtiSavv8nRAFk6VZEgeCMYicjBPy4244+2KQhng5Pq9bxcX5A@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, frank.rowand@am.sony.com, tim.bird@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com

On 06/17/2012 02:48 AM, Aaditya Kumar wrote:

> On Fri, Jun 15, 2012 at 12:57 PM, Minchan Kim <minchan@kernel.org> wrote:
> 
>>>
>>> pgdat_balanced() doesn't recognized zone. Therefore kswapd may sleep
>>> if node has multiple zones. Hm ok, I realized my descriptions was
>>> slightly misleading. priority 0 is not needed. bakance_pddat() calls
>>> pgdat_balanced()
>>> every priority. Most easy case is, movable zone has a lot of free pages and
>>> normal zone has no reclaimable page.
>>>
>>> btw, current pgdat_balanced() logic seems not correct. kswapd should
>>> sleep only if every zones have much free pages than high water mark
>>> _and_ 25% of present pages in node are free.
>>>
>>
>>
>> Sorry. I can't understand your point.
>> Current kswapd doesn't sleep if relevant zones don't have free pages above high watermark.
>> It seems I am missing your point.
>> Please anybody correct me.
> 
> Since currently direct reclaim is given up based on
> zone->all_unreclaimable flag,
> so for e.g in one of the scenarios:
> 
> Lets say system has one node with two zones (NORMAL and MOVABLE) and we
> hot-remove the all the pages of the MOVABLE zone.
> 
> While migrating pages during memory hot-unplugging, the allocation function
> (for new page to which the page in MOVABLE zone would be moved)  can end up
> looping in direct reclaim path for ever.
> 
> This is so because when most of the pages in the MOVABLE zone have
> been migrated,
> the zone now contains lots of free memory (basically above low watermark)
> BUT all are in MIGRATE_ISOLATE list of the buddy list.
> 
> So kswapd() would not balance this zone as free pages are above low watermark
> (but all are in isolate list). So zone->all_unreclaimable flag would
> never be set for this zone
> and allocation function would end up looping forever. (assuming the
> zone NORMAL is
> left with no reclaimable memory)
>


Thanks a lot, Aaditya! Scenario you mentioned makes perfect.
But I don't see it's a problem of kswapd.

a5d76b54 made new migration type 'MIGRATE_ISOLATE' which is very irony type because there are many free pages in free list
but we can't allocate it. :(
It doesn't reflect right NR_FREE_PAGES while many places in the kernel use NR_FREE_PAGES to trigger some operation.
Kswapd is just one of them confused.
As right fix of this problem, we should fix hot plug code, IMHO which can fix CMA, too. 

This patch could make inconsistency between NR_FREE_PAGES and SumOf[free_area[order].nr_free]
and it could make __zone_watermark_ok confuse so we might need to fix move_freepages_block itself to reflect
free_area[order].nr_free exactly. 

Any thought?

Side Note: I still need KOSAKI's patch with fixed description regardless of this problem because set zone->all_unreclaimable of only kswapd is very fragile.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..19de56c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5593,8 +5593,10 @@ int set_migratetype_isolate(struct page *page)
 
 out:
        if (!ret) {
+               int pages_moved;
                set_pageblock_migratetype(page, MIGRATE_ISOLATE);
-               move_freepages_block(zone, page, MIGRATE_ISOLATE);
+               pages_moved = move_freepages_block(zone, page, MIGRATE_ISOLATE);
+               __mod_zone_page_state(zone, NR_FREE_PAGES, -pages_moved);
        }   
 
        spin_unlock_irqrestore(&zone->lock, flags);
@@ -5607,12 +5609,14 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
        struct zone *zone;
        unsigned long flags;
+       int pages_moved;
        zone = page_zone(page);
        spin_lock_irqsave(&zone->lock, flags);
        if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
                goto out;
        set_pageblock_migratetype(page, migratetype);
-       move_freepages_block(zone, page, migratetype);
+       pages_moved = move_freepages_block(zone, page, migratetype);
+       __mod_zone_page_state(zone, NR_FREE_PAGES, pages_moved);
 out:
        spin_unlock_irqrestore(&zone->lock, flags);
 }


> 
> Regards,
> Aaditya Kumar
> Sony India Software Centre,
> Bangalore.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
