Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id CC8196B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:18:02 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so7441956lbj.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 06:18:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FDE79CF.4050702@kernel.org>
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
	<20120614145716.GA2097@barrios>
	<CAHGf_=qcA5OfuNgk0BiwyshcLftNWoPfOO_VW9H6xQTX2tAbuA@mail.gmail.com>
	<4FDAE3CC.60801@kernel.org>
	<CAEtiSavv8nRAFk6VZEgeCMYicjBPy4244+2KQhng5Pq9bxcX5A@mail.gmail.com>
	<4FDE79CF.4050702@kernel.org>
Date: Tue, 19 Jun 2012 18:48:00 +0530
Message-ID: <CAEtiSav8uLfWq0Ee4Nub-5QqyB7MhtfpWGKPdMYSRJd=iz+5gg@mail.gmail.com>
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
From: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, frank.rowand@am.sony.com, tim.bird@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com

On Mon, Jun 18, 2012 at 6:13 AM, Minchan Kim <minchan@kernel.org> wrote:
> On 06/17/2012 02:48 AM, Aaditya Kumar wrote:
>
>> On Fri, Jun 15, 2012 at 12:57 PM, Minchan Kim <minchan@kernel.org> wrote=
:
>>
>>>>
>>>> pgdat_balanced() doesn't recognized zone. Therefore kswapd may sleep
>>>> if node has multiple zones. Hm ok, I realized my descriptions was
>>>> slightly misleading. priority 0 is not needed. bakance_pddat() calls
>>>> pgdat_balanced()
>>>> every priority. Most easy case is, movable zone has a lot of free page=
s and
>>>> normal zone has no reclaimable page.
>>>>
>>>> btw, current pgdat_balanced() logic seems not correct. kswapd should
>>>> sleep only if every zones have much free pages than high water mark
>>>> _and_ 25% of present pages in node are free.
>>>>
>>>
>>>
>>> Sorry. I can't understand your point.
>>> Current kswapd doesn't sleep if relevant zones don't have free pages ab=
ove high watermark.
>>> It seems I am missing your point.
>>> Please anybody correct me.
>>
>> Since currently direct reclaim is given up based on
>> zone->all_unreclaimable flag,
>> so for e.g in one of the scenarios:
>>
>> Lets say system has one node with two zones (NORMAL and MOVABLE) and we
>> hot-remove the all the pages of the MOVABLE zone.
>>
>> While migrating pages during memory hot-unplugging, the allocation funct=
ion
>> (for new page to which the page in MOVABLE zone would be moved) =A0can e=
nd up
>> looping in direct reclaim path for ever.
>>
>> This is so because when most of the pages in the MOVABLE zone have
>> been migrated,
>> the zone now contains lots of free memory (basically above low watermark=
)
>> BUT all are in MIGRATE_ISOLATE list of the buddy list.
>>
>> So kswapd() would not balance this zone as free pages are above low wate=
rmark
>> (but all are in isolate list). So zone->all_unreclaimable flag would
>> never be set for this zone
>> and allocation function would end up looping forever. (assuming the
>> zone NORMAL is
>> left with no reclaimable memory)
>>
>
>
> Thanks a lot, Aaditya! Scenario you mentioned makes perfect.
> But I don't see it's a problem of kswapd.

Hi Kim,

Yes I agree it is not a problem of kswapd.

> a5d76b54 made new migration type 'MIGRATE_ISOLATE' which is very irony ty=
pe because there are many free pages in free list
> but we can't allocate it. :(
> It doesn't reflect right NR_FREE_PAGES while many places in the kernel us=
e NR_FREE_PAGES to trigger some operation.
> Kswapd is just one of them confused.
> As right fix of this problem, we should fix hot plug code, IMHO which can=
 fix CMA, too.
>
> This patch could make inconsistency between NR_FREE_PAGES and SumOf[free_=
area[order].nr_free]


I assume that by the inconsistency you mention above, you mean
temporary inconsistency.

Sorry, but IMHO as for memory hot plug the main issue with this patch
is that the inconsistency you mentioned above would NOT be a temporary
inconsistency.

Every time say 'x' number of page frames are off lined, they will
introduce a difference of 'x' pages between
NR_FREE_PAGES and SumOf[free_area[order].nr_free].
(So for e.g. if we do a frequent offline/online it will make
NR_FREE_PAGES  negative)

This is so because, unset_migratetype_isolate() is called from
offlining  code (to set the migrate type of off lined pages again back
to MIGRATE_MOVABLE)
after the pages have been off lined and removed from the buddy list.
Since the pages for which unset_migratetype_isolate() is called are
not buddy pages so move_freepages_block() does not move any page, and
thus introducing a permanent inconsistency.

> and it could make __zone_watermark_ok confuse so we might need to fix mov=
e_freepages_block itself to reflect
> free_area[order].nr_free exactly.
>
> Any thought?

As for fixing move_freepages_block(), At least for memory hot plug,
the pages stay in MIGRATE_ISOLATE list only for duration
offline_pages() function,
I mean only temporarily. Since fixing move_freepages_block() for will
introduce some overhead, So I am not very sure whether that overhead
is justified
for a temporary condition. What do you think?


> Side Note: I still need KOSAKI's patch with fixed description regardless =
of this problem because set zone->all_unreclaimable of only kswapd is very =
fragile.
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4403009..19de56c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5593,8 +5593,10 @@ int set_migratetype_isolate(struct page *page)
>
> =A0out:
> =A0 =A0 =A0 =A0if (!ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int pages_moved;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_pageblock_migratetype(page, MIGRATE_IS=
OLATE);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_freepages_block(zone, page, MIGRATE_IS=
OLATE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages_moved =3D move_freepages_block(zone, =
page, MIGRATE_ISOLATE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mod_zone_page_state(zone, NR_FREE_PAGES, =
-pages_moved);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lock, flags);
> @@ -5607,12 +5609,14 @@ void unset_migratetype_isolate(struct page *page,=
 unsigned migratetype)
> =A0{
> =A0 =A0 =A0 =A0struct zone *zone;
> =A0 =A0 =A0 =A0unsigned long flags;
> + =A0 =A0 =A0 int pages_moved;
> =A0 =A0 =A0 =A0zone =3D page_zone(page);
> =A0 =A0 =A0 =A0spin_lock_irqsave(&zone->lock, flags);
> =A0 =A0 =A0 =A0if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0set_pageblock_migratetype(page, migratetype);
> - =A0 =A0 =A0 move_freepages_block(zone, page, migratetype);
> + =A0 =A0 =A0 pages_moved =3D move_freepages_block(zone, page, migratetyp=
e);
> + =A0 =A0 =A0 __mod_zone_page_state(zone, NR_FREE_PAGES, pages_moved);
> =A0out:
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lock, flags);
> =A0}
>
>
>>
>> Regards,
>> Aaditya Kumar
>> Sony India Software Centre,
>> Bangalore.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>
>
> --
> Kind regards,
> Minchan Kim

Regards,
Aaditya Kumar
Sony India Software Centre,
Bangalore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
