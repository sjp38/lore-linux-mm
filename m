Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 75F386B006E
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 08:44:50 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so5225409vbk.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 05:44:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE18187.3050103@kernel.org>
References: <4FE169B1.7020600@kernel.org>
	<4FE16E80.9000306@gmail.com>
	<4FE18187.3050103@kernel.org>
Date: Wed, 20 Jun 2012 20:44:48 +0800
Message-ID: <CAJd=RBC2PdP0ggZ=RvXwXbToFmzRdpxYKWvkX_8qr7-Zw+DB1Q@mail.gmail.com>
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 20, 2012 at 3:53 PM, Minchan Kim <minchan@kernel.org> wrote:
> On 06/20/2012 03:32 PM, KOSAKI Motohiro wrote:
>
>> (6/20/12 2:12 AM), Minchan Kim wrote:
>>>
>>> Hi Aaditya,
>>>
>>> I want to discuss this problem on another thread.
>>>
>>> On 06/19/2012 10:18 PM, Aaditya Kumar wrote:
>>>> On Mon, Jun 18, 2012 at 6:13 AM, Minchan Kim <minchan@kernel.org> wrot=
e:
>>>>> On 06/17/2012 02:48 AM, Aaditya Kumar wrote:
>>>>>
>>>>>> On Fri, Jun 15, 2012 at 12:57 PM, Minchan Kim <minchan@kernel.org> w=
rote:
>>>>>>
>>>>>>>>
>>>>>>>> pgdat_balanced() doesn't recognized zone. Therefore kswapd may sle=
ep
>>>>>>>> if node has multiple zones. Hm ok, I realized my descriptions was
>>>>>>>> slightly misleading. priority 0 is not needed. bakance_pddat() cal=
ls
>>>>>>>> pgdat_balanced()
>>>>>>>> every priority. Most easy case is, movable zone has a lot of free =
pages and
>>>>>>>> normal zone has no reclaimable page.
>>>>>>>>
>>>>>>>> btw, current pgdat_balanced() logic seems not correct. kswapd shou=
ld
>>>>>>>> sleep only if every zones have much free pages than high water mar=
k
>>>>>>>> _and_ 25% of present pages in node are free.
>>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> Sorry. I can't understand your point.
>>>>>>> Current kswapd doesn't sleep if relevant zones don't have free page=
s above high watermark.
>>>>>>> It seems I am missing your point.
>>>>>>> Please anybody correct me.
>>>>>>
>>>>>> Since currently direct reclaim is given up based on
>>>>>> zone->all_unreclaimable flag,
>>>>>> so for e.g in one of the scenarios:
>>>>>>
>>>>>> Lets say system has one node with two zones (NORMAL and MOVABLE) and=
 we
>>>>>> hot-remove the all the pages of the MOVABLE zone.
>>>>>>
>>>>>> While migrating pages during memory hot-unplugging, the allocation f=
unction
>>>>>> (for new page to which the page in MOVABLE zone would be moved) =C2=
=A0can end up
>>>>>> looping in direct reclaim path for ever.
>>>>>>
>>>>>> This is so because when most of the pages in the MOVABLE zone have
>>>>>> been migrated,
>>>>>> the zone now contains lots of free memory (basically above low water=
mark)
>>>>>> BUT all are in MIGRATE_ISOLATE list of the buddy list.
>>>>>>
>>>>>> So kswapd() would not balance this zone as free pages are above low =
watermark
>>>>>> (but all are in isolate list). So zone->all_unreclaimable flag would
>>>>>> never be set for this zone
>>>>>> and allocation function would end up looping forever. (assuming the
>>>>>> zone NORMAL is
>>>>>> left with no reclaimable memory)
>>>>>>
>>>>>
>>>>>
>>>>> Thanks a lot, Aaditya! Scenario you mentioned makes perfect.
>>>>> But I don't see it's a problem of kswapd.
>>>>
>>>> Hi Kim,
>>>
>>> I like called Minchan rather than Kim
>>> Never mind. :)
>>>
>>>>
>>>> Yes I agree it is not a problem of kswapd.
>>>
>>> Yeb.
>>>
>>>>
>>>>> a5d76b54 made new migration type 'MIGRATE_ISOLATE' which is very iron=
y type because there are many free pages in free list
>>>>> but we can't allocate it. :(
>>>>> It doesn't reflect right NR_FREE_PAGES while many places in the kerne=
l use NR_FREE_PAGES to trigger some operation.
>>>>> Kswapd is just one of them confused.
>>>>> As right fix of this problem, we should fix hot plug code, IMHO which=
 can fix CMA, too.
>>>>>
>>>>> This patch could make inconsistency between NR_FREE_PAGES and SumOf[f=
ree_area[order].nr_free]
>>>>
>>>>
>>>> I assume that by the inconsistency you mention above, you mean
>>>> temporary inconsistency.
>>>>
>>>> Sorry, but IMHO as for memory hot plug the main issue with this patch
>>>> is that the inconsistency you mentioned above would NOT be a temporary
>>>> inconsistency.
>>>>
>>>> Every time say 'x' number of page frames are off lined, they will
>>>> introduce a difference of 'x' pages between
>>>> NR_FREE_PAGES and SumOf[free_area[order].nr_free].
>>>> (So for e.g. if we do a frequent offline/online it will make
>>>> NR_FREE_PAGES =C2=A0negative)
>>>>
>>>> This is so because, unset_migratetype_isolate() is called from
>>>> offlining =C2=A0code (to set the migrate type of off lined pages again=
 back
>>>> to MIGRATE_MOVABLE)
>>>> after the pages have been off lined and removed from the buddy list.
>>>> Since the pages for which unset_migratetype_isolate() is called are
>>>> not buddy pages so move_freepages_block() does not move any page, and
>>>> thus introducing a permanent inconsistency.
>>>
>>> Good point. Negative NR_FREE_PAGES is caused by double counting by my p=
atch and __offline_isolated_pages.
>>> I think at first MIGRATE_ISOLATE type freed page shouldn't account as f=
ree page.
>>>
>>>>
>>>>> and it could make __zone_watermark_ok confuse so we might need to fix=
 move_freepages_block itself to reflect
>>>>> free_area[order].nr_free exactly.
>>>>>
>>>>> Any thought?
>>>>
>>>> As for fixing move_freepages_block(), At least for memory hot plug,
>>>> the pages stay in MIGRATE_ISOLATE list only for duration
>>>> offline_pages() function,
>>>> I mean only temporarily. Since fixing move_freepages_block() for will
>>>> introduce some overhead, So I am not very sure whether that overhead
>>>> is justified
>>>> for a temporary condition. What do you think?
>>>
>>> Yes. I don't like hurt fast path, either.
>>> How about this? (Passed just compile test :( =C2=A0)
>>> The patch's goal is to NOT increase nr_free and NR_FREE_PAGES about fre=
ed page into MIGRATE_ISOLATED.
>>>
>>> This patch hurts high order page free path but I think it's not critica=
l because higher order allocation
>>> is rare than order-0 allocation and we already have done same thing on =
free_hot_cold_page on order-0 free path
>>> which is more hot.
>>
>> Can't we change zone_water_mark_ok_safe() instead of page allocator? mem=
ory hotplug is really rare event.
>
>
> +1
>
> Firstly, I want to make zone_page_state(z, NR_FREE_PAGES) itself more acc=
urately because it is used by
> several places. As I looked over places, I can't find critical places exc=
ept kswapd forever sleep case.
> So it's a nice idea!
>
> In that case, we need zone->lock whenever zone_watermark_ok_safe is calle=
d.
>
Ifdefinery could be utilized for builds with CMA disabled, first.

> Most of cases, it's unnecessary and it might hurt alloc/free performance =
when memory pressure is high.
> But if memory pressure is high, it may be already meaningless alloc/free =
performance.
> So it does make sense, IMHO.
>
> Please raise your hands if anyone has a concern about this.
>
> barrios@bbox:~/linux-next$ git diff
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d2a515d..82cc0a2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1748,16 +1748,38 @@ bool zone_watermark_ok(struct zone *z, int order,=
 unsigned long mark,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_page=
_state(z, NR_FREE_PAGES));
> =C2=A0}
>
> -bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mar=
k,
> +bool zone_watermark_ok_safe(struct zone *z, int alloc_order, unsigned lo=
ng mark,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0int classzone_idx, int alloc_flags)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct free_area *area;
> + =C2=A0 =C2=A0 =C2=A0 struct list_head *curr;
> + =C2=A0 =C2=A0 =C2=A0 int order;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0long free_pages =3D zone_page_state(z, NR_FREE=
_PAGES);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (z->percpu_drift_mark && free_pages < z->pe=
rcpu_drift_mark)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0free_pages =3D zon=
e_page_state_snapshot(z, NR_FREE_PAGES);
>
> - =C2=A0 =C2=A0 =C2=A0 return __zone_watermark_ok(z, order, mark, classzo=
ne_idx, alloc_flags,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 f=
ree_pages);
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Memory hotplug/CMA can isolate freed page =
into MIGRATE_ISOLATE
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* so that buddy can't allocate it although t=
hey are in free list.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&z->lock, flags);
> + =C2=A0 =C2=A0 =C2=A0 for (order =3D 0; order < MAX_ORDER; order++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int count =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 area =3D &(z->free_are=
a[order]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(!list_emp=
ty(&area->free_list[MIGRATE_ISOLATE]))) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 list_for_each(curr, &area->free_list[MIGRATE_ISOLATE])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count++;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 free_pages -=3D (count << order);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (free_pages < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 free_pages =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&z->lock, flags);
> +
> + =C2=A0 =C2=A0 =C2=A0 return __zone_watermark_ok(z, alloc_order, mark,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 classzone_idx, alloc_flags, free_pages);
> =C2=A0}
>
Then isolated pages could be scanned in another direction?

	spin_lock_irqsave(&z->lock, flags);
	for (order =3D MAX_ORDER - 1; order >=3D 0; order--) {
		struct free_area *area =3D &z->free_area[order];
		long count =3D 0;
		struct list_head *curr;

		list_for_each(curr, &area->free_list[MIGRATE_ISOLATE])
			count++;

		free_pages -=3D (count << order);
		if (free_pages < 0) {
			free_pages =3D 0;
			break;
		}
	}
	spin_unlock_irqrestore(&z->lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
