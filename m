Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B16EF6B005C
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 21:10:24 -0400 (EDT)
Message-ID: <4FCC0B09.1070708@kernel.org>
Date: Mon, 04 Jun 2012 10:10:33 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com> <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils> <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com> <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com> <alpine.LSU.2.00.1206012108430.11308@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1206012108430.11308@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/02/2012 01:40 PM, Hugh Dickins wrote:

> On Fri, 1 Jun 2012, Linus Torvalds wrote:
>> On Fri, Jun 1, 2012 at 3:17 PM, Hugh Dickins <hughd@google.com> wrote:
>>>
>>> +       spin_lock_irqsave(&zone->lock, flags);
>>>        for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
>>>                                                                  page++) {
>>
>> So holding the spinlock (and disabling irqs!) over the whole loop
>> sounds horrible.
> 
> There looks to be a pretty similar loop inside move_freepages_block(),
> which is the part which I believe really needs the lock - it's moving
> free pages from one lru to another.
> 
>>
>> At the same time, the iterators don't seem to require the spinlock, so
>> it should be possible to just move the lock into the loop, no?
> 
> Move the lock after the loop, I think you meant.
> 
> I put the lock before the loop because it's deciding whether it can
> usefully proceed, and then proceeding: I was thinking that the lock
> would stabilize the conditions that it bases that decision on.


We do it with two phase.
In first phase, we don't need lock because we don't need to be exact.
In second phase where move pages really, we need a lock so we already hold it.

ret = suitable_migration_target(page, cc);
..
..
spin_lock_irqsave(&zone->lock, flags);
ret = suitable_migration_target(page, cc); 

So you shouldn't put the lock in loop.

> 
> But it certainly does not stabilize all of them (most obviously not
> PageLRU), so I'm guesssing that this is a best-effort decision which

> can safely go wrong some of the time.

Right.

> 
> In which case, yes, much better to follow your suggestion, and hold
> the lock (with irqs disabled) for only half the time.
> 
> Similarly untested patch below.
> 
> But I'm entirely unfamiliar with this code: best Cc people more familiar
> with it.  Does this addition of locking to rescue_unmovable_pageblock()
> look correct to you, and do you think it has a good chance of fixing the


No.I think we need to use start_page instead of page and
we need a last page of page block to check cross-over zones, not first page in next page block.

I should have reviewed more carefully. :(

barrios@bbox:~/linux-2.6$ git diff
diff --git a/mm/compaction.c b/mm/compaction.c
index 4ac338a..b3fcc4b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -372,7 +372,7 @@ static bool rescue_unmovable_pageblock(struct page *page)
 
        pfn = page_to_pfn(page);
        start_pfn = pfn & ~(pageblock_nr_pages - 1);
-       end_pfn = start_pfn + pageblock_nr_pages;
+       end_pfn = start_pfn + pageblock_nr_pages - 1;
 
        start_page = pfn_to_page(start_pfn);
        end_page = pfn_to_page(end_pfn);
@@ -381,7 +381,7 @@ static bool rescue_unmovable_pageblock(struct page *page)
        if (page_zone(start_page) != page_zone(end_page))
                return false;
 
-       for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
+       for (page = start_page, pfn = start_pfn; page <= end_page; pfn++,
                                                                  page++) {
                if (!pfn_valid_within(pfn))
                        continue;
@@ -399,8 +399,8 @@ static bool rescue_unmovable_pageblock(struct page *page)
                return false;
        }
 
-       set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-       move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
+       set_pageblock_migratetype(start_page, MIGRATE_MOVABLE);
+       move_freepages_block(page_zone(start_page), start_page, MIGRATE_MOVABLE);
        return true;
 }


Hugh, thanks for looking this.

> move_freepages_block() list debug warnings which Dave has been reporting
> (in this and in another thread)?
> 
> (Although there's still something of a mystery in where Dave's bisection
> appeared to converge, our best assumption at present is that one of my
> tmpfs changes is to blame for the __set_page_dirty_nobuffers warnings,
> and I need to send a finalized patch to fix that later.
> 
> I'm guessing that the few people who see the warning are those running
> new systemd distros, and that systemd is indeed now making use of the
> fallocate support we added into tmpfs for it.)
> 
> Hugh
> 
> --- 3.4.0+/mm/compaction.c	2012-05-30 08:17:19.396008280 -0700
> +++ linux/mm/compaction.c	2012-06-01 20:59:56.840204915 -0700
> @@ -369,6 +369,8 @@ static bool rescue_unmovable_pageblock(s
>  {
>  	unsigned long pfn, start_pfn, end_pfn;
>  	struct page *start_page, *end_page;
> +	struct zone *zone;
> +	unsigned long flags;
>  
>  	pfn = page_to_pfn(page);
>  	start_pfn = pfn & ~(pageblock_nr_pages - 1);
> @@ -378,7 +380,8 @@ static bool rescue_unmovable_pageblock(s
>  	end_page = pfn_to_page(end_pfn);
>  
>  	/* Do not deal with pageblocks that overlap zones */
> -	if (page_zone(start_page) != page_zone(end_page))
> +	zone = page_zone(start_page);
> +	if (zone != page_zone(end_page))
>  		return false;
>  
>  	for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
> @@ -399,8 +402,10 @@ static bool rescue_unmovable_pageblock(s
>  		return false;
>  	}
>  
> +	spin_lock_irqsave(&zone->lock, flags);
>  	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> -	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
> +	move_freepages_block(zone, page, MIGRATE_MOVABLE);
> +	spin_unlock_irqrestore(&zone->lock, flags);
>  	return true;
>  }
>  



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
