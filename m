Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 5F6F86B0139
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 22:08:18 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so3672474lbj.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:08:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE3C860.4000401@kernel.org>
References: <4FE169B1.7020600@kernel.org>
	<4FE16E80.9000306@gmail.com>
	<4FE18187.3050103@kernel.org>
	<4FE23069.5030702@gmail.com>
	<4FE26470.90401@kernel.org>
	<CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com>
	<4FE27F15.8050102@kernel.org>
	<CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com>
	<4FE2A937.6040701@kernel.org>
	<CAEtiSavHF5Z6Ex25TnZv+tTdwSfUOCFtAeOZ_f+=5cuC8QRTBw@mail.gmail.com>
	<4FE3C860.4000401@kernel.org>
Date: Fri, 22 Jun 2012 07:38:16 +0530
Message-ID: <CAEtiSasc2V_ckLd6i6OUqeX1TQ=ZPt5xkBm+Xwqt-uuXYUHSNQ@mail.gmail.com>
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
From: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On Fri, Jun 22, 2012 at 6:50 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Aaditya,
>
> On 06/21/2012 08:02 PM, Aaditya Kumar wrote:
>
>> On Thu, Jun 21, 2012 at 10:25 AM, Minchan Kim <minchan@kernel.org> wrote=
:
>>> On 06/21/2012 11:45 AM, KOSAKI Motohiro wrote:
>>>
>>>> On Wed, Jun 20, 2012 at 9:55 PM, Minchan Kim <minchan@kernel.org> wrot=
e:
>>>>> On 06/21/2012 10:39 AM, KOSAKI Motohiro wrote:
>>>>>
>>>>>>>> number of isolate page block is almost always 0. then if we have s=
uch counter,
>>>>>>>> we almost always can avoid zone->lock. Just idea.
>>>>>>>
>>>>>>> Yeb. I thought about it but unfortunately we can't have a counter f=
or MIGRATE_ISOLATE.
>>>>>>> Because we have to tweak in page free path for pages which are goin=
g to free later after we
>>>>>>> mark pageblock type to MIGRATE_ISOLATE.
>>>>>>
>>>>>> I mean,
>>>>>>
>>>>>> if (nr_isolate_pageblock !=3D 0)
>>>>>> =A0 =A0free_pages -=3D nr_isolated_free_pages(); // your counting lo=
gic
>>>>>>
>>>>>> return __zone_watermark_ok(z, alloc_order, mark,
>>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzon=
e_idx, alloc_flags, free_pages);
>>>>>>
>>>>>>
>>>>>> I don't think this logic affect your race. zone_watermark_ok() is al=
ready
>>>>>> racy. then new little race is no big matter.
>>>>>
>>>>>
>>>>> It seems my explanation wasn't enough. :(
>>>>> I already understand your intention but we can't make nr_isolate_page=
block.
>>>>> Because we should count two type of free pages.
>>>>
>>>> I mean, move_freepages_block increment number of page *block*, not pag=
es.
>>>> number of free *pages* are counted by zone_watermark_ok_safe().
>>>>
>>>>
>>>>> 1. Already freed page so they are already in buddy list.
>>>>> =A0 Of course, we can count it with return value of move_freepages_bl=
ock(zone, page, MIGRATE_ISOLATE) easily.
>>>>>
>>>>> 2. Will be FREEed page by do_migrate_range.
>>>>> =A0 It's a _PROBLEM_. For it, we should tweak free path. No?
>>>>
>>>> No.
>>>>
>>>>
>>>>> If All of pages are PageLRU when hot-plug happens(ie, 2), nr_isolate_=
pagblock is zero and
>>>>> zone_watermk_ok_safe can't do his role.
>>>>
>>>> number of isolate pageblock don't depend on number of free pages. It's
>>>> a concept of
>>>> an attribute of PFN range.
>>>
>>>
>>> It seems you mean is_migrate_isolate as a just flag, NOT nr_isolate_pag=
eblock.
>>> So do you mean this?
>>>
>>> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolat=
ion.h
>>> index 3bdcab3..7f4d19c 100644
>>> --- a/include/linux/page-isolation.h
>>> +++ b/include/linux/page-isolation.h
>>> @@ -1,6 +1,7 @@
>>> =A0#ifndef __LINUX_PAGEISOLATION_H
>>> =A0#define __LINUX_PAGEISOLATION_H
>>>
>>> +extern bool is_migrate_isolate;
>>> =A0/*
>>> =A0* Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE=
.
>>> =A0* If specified range includes migrate types other than MOVABLE or CM=
A,
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index d2a515d..b997cb3 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -1756,6 +1756,27 @@ bool zone_watermark_ok_safe(struct zone *z, int =
order, unsigned long ma
>>> =A0 =A0 =A0 =A0if (z->percpu_drift_mark && free_pages < z->percpu_drift=
_mark)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_pages =3D zone_page_state_snapshot(=
z, NR_FREE_PAGES);
>>>
>>> +#if defined CONFIG_CMA || CONFIG_MEMORY_HOTPLUG
>>> + =A0 =A0 =A0 if (unlikely(is_migrate_isolate)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&z->lock, flags);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (order =3D MAX_ORDER - 1; order >=3D =
0; order--) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct free_area *area =
=3D &z->free_area[order];
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long count =3D 0;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *curr;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each(curr, &area=
->free_list[MIGRATE_ISOLATE])
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count++;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages -=3D (count <<=
 order);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (free_pages < 0) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page=
s =3D 0;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&z->lock, flags);
>>> + =A0 =A0 =A0 }
>>> +#endif
>>> =A0 =A0 =A0 =A0return __zone_watermark_ok(z, order, mark, classzone_idx=
, alloc_flags,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_pages);
>>> =A0}
>>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>>> index c9f0477..212e526 100644
>>> --- a/mm/page_isolation.c
>>> +++ b/mm/page_isolation.c
>>> @@ -19,6 +19,8 @@ __first_valid_page(unsigned long pfn, unsigned long n=
r_pages)
>>> =A0 =A0 =A0 =A0return pfn_to_page(pfn + i);
>>> =A0}
>>>
>>> +bool is_migrate_isolate =3D false;
>>> +
>>> =A0/*
>>> =A0* start_isolate_page_range() -- make page-allocation-type of range o=
f pages
>>> =A0* to be MIGRATE_ISOLATE.
>>> @@ -43,6 +45,8 @@ int start_isolate_page_range(unsigned long start_pfn,=
 unsigned long end_pfn,
>>> =A0 =A0 =A0 =A0BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
>>> =A0 =A0 =A0 =A0BUG_ON((end_pfn) & (pageblock_nr_pages - 1));
>>>
>>> + =A0 =A0 =A0 is_migrate_isolate =3D true;
>>> +
>>> =A0 =A0 =A0 =A0for (pfn =3D start_pfn;
>>> =A0 =A0 =A0 =A0 =A0 =A0 pfn < end_pfn;
>>> =A0 =A0 =A0 =A0 =A0 =A0 pfn +=3D pageblock_nr_pages) {
>>> @@ -59,6 +63,7 @@ undo:
>>> =A0 =A0 =A0 =A0 =A0 =A0 pfn +=3D pageblock_nr_pages)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unset_migratetype_isolate(pfn_to_page(pf=
n), migratetype);
>>>
>>> + =A0 =A0 =A0 is_migrate_isolate =3D false;
>>> =A0 =A0 =A0 =A0return -EBUSY;
>>> =A0}
>>>
>>> @@ -80,6 +85,9 @@ int undo_isolate_page_range(unsigned long start_pfn, =
unsigned long end_pfn,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unset_migratetype_isolate(page, migratet=
ype);
>>> =A0 =A0 =A0 =A0}
>>> +
>>> + =A0 =A0 =A0 is_migrate_isolate =3D false;
>>> +
>>> =A0 =A0 =A0 =A0return 0;
>>> =A0}
>>> =A0/*
>>>
>>
>> Hello Minchan,
>>
>> Sorry for delayed response.
>>
>> Instead of above how about something like this:
>>
>> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolati=
on.h
>> index 3bdcab3..fe9215f 100644
>> --- a/include/linux/page-isolation.h
>> +++ b/include/linux/page-isolation.h
>> @@ -34,4 +34,6 @@ extern int set_migratetype_isolate(struct page *page);
>> =A0extern void unset_migratetype_isolate(struct page *page, unsigned mig=
ratetype);
>>
>>
>> +extern atomic_t is_migrate_isolated;
>
>> +
>
>> =A0#endif
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index ab1e714..e076fa2 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1381,6 +1381,7 @@ static int get_any_page(struct page *p, unsigned
>> long pfn, int flags)
>> =A0 =A0 =A0 =A0* Isolate the page, so that it doesn't get reallocated if=
 it
>> =A0 =A0 =A0 =A0* was free.
>> =A0 =A0 =A0 =A0*/
>> + =A0 =A0 atomic_inc(&is_migrate_isolated);
>
>
> I didn't take a detail look in your patch yet.

Hi Minchan,

I think looking at kamezawa-san's approach (I copied below), it is
equivalent or rather a better approach than me,
and I agree with this approach, So, please ignore my previous patch.

(From kamezawa-san's previous post:)

***
As you shown, it seems to be not difficult to counting free pages
under MIGRATE_ISOLATE.
And we can know the zone contains MIGRATE_ISOLATE area or not by simple che=
ck.
for example.
=3D=3D
               set_pageblock_migratetype(page, MIGRATE_ISOLATE);
               move_freepages_block(zone, page, MIGRATE_ISOLATE);
               zone->nr_isolated_areas++;
=3D

Then, the solution will be adding a function like following
=3D
u64 zone_nr_free_pages(struct zone *zone) {
       unsigned long free_pages;

       free_pages =3D zone_page_state(NR_FREE_PAGES);
       if (unlikely(z->nr_isolated_areas)) {
               isolated =3D count_migrate_isolated_pages(zone);
               free_pages -=3D isolated;
       }
       return free_pages;
}
=3D

***

> Yes. In my patch, I missed several caller.
> It was just a patch for showing my intention, NOT formal patch.
> But I admit I didn't consider nesting case. brain-dead =A0:(
> Technically other problem about this is atomic doesn't imply memory barri=
er so
> we need barrier.
>
> But the concern about this approach is following as
> Copy/Paste from my reply of Kame.
>
> ***
> But the concern about second approach is how to make sure matched count i=
ncrease/decrease of nr_isolated_areas.
> I mean how to make sure nr_isolated_areas would be zero when isolation is=
 done.
> Of course, we can investigate all of current caller and make sure they do=
n't make mistake
> now. But it's very error-prone if we consider future's user.
> So we might need test_set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>
> IMHO, ideal solution is that we remove MIGRATE_ISOLATE type totally in bu=
ddy.
> ...
> ...
> ***
>
> Of course, We can choose this approach as interim.
> What do you think about it, Fujitsu guys?
>
>
>> =A0 =A0 =A0 set_migratetype_isolate(p);
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* When the target page is a free hugepage, just remove it
>> @@ -1406,6 +1407,7 @@ static int get_any_page(struct page *p, unsigned
>> long pfn, int flags)
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 unset_migratetype_isolate(p, MIGRATE_MOVABLE);
>> =A0 =A0 =A0 unlock_memory_hotplug();
>> + =A0 =A0 atomic_dec(&is_migrate_isolated);
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 0d7e3ec..cd7805c 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -892,6 +892,7 @@ static int __ref offline_pages(unsigned long start_p=
fn,
>> =A0 =A0 =A0 nr_pages =3D end_pfn - start_pfn;
>>
>> =A0 =A0 =A0 /* set above range as isolated */
>> + =A0 =A0 atomic_inc(&is_migrate_isolated);
>> =A0 =A0 =A0 ret =3D start_isolate_page_range(start_pfn, end_pfn, MIGRATE=
_MOVABLE);
>> =A0 =A0 =A0 if (ret)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> @@ -958,6 +959,7 @@ repeat:
>> =A0 =A0 =A0 offline_isolated_pages(start_pfn, end_pfn);
>> =A0 =A0 =A0 /* reset pagetype flags and makes migrate type to be MOVABLE=
 */
>> =A0 =A0 =A0 undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE)=
;
>> + =A0 =A0 atomic_dec(&is_migrate_isolated);
>> =A0 =A0 =A0 /* removal success */
>> =A0 =A0 =A0 zone->present_pages -=3D offlined_pages;
>> =A0 =A0 =A0 zone->zone_pgdat->node_present_pages -=3D offlined_pages;
>> @@ -986,6 +988,7 @@ failed_removal:
>> =A0 =A0 =A0 undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE)=
;
>>
>> =A0out:
>> + =A0 =A0 atomic_dec(&is_migrate_isolated);
>> =A0 =A0 =A0 unlock_memory_hotplug();
>> =A0 =A0 =A0 return ret;
>> =A0}
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 4403009..f549361 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1632,6 +1632,28 @@ bool zone_watermark_ok_safe(struct zone *z, int
>> order, unsigned long mark,
>> =A0 =A0 =A0 if (z->percpu_drift_mark && free_pages < z->percpu_drift_mar=
k)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages =3D zone_page_state_snapshot(z, N=
R_FREE_PAGES);
>>
>> +#if defined CONFIG_CMA || CONFIG_MEMORY_HOTPLUG
>> + =A0 =A0 =A0 if (unlikely(atomic_read(is_migrate_isolated)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&z->lock, flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (order =3D MAX_ORDER - 1; order >=3D 0=
; order--) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct free_area *area =3D=
 &z->free_area[order];
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long count =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *curr;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each(curr, &area-=
>free_list[MIGRATE_ISOLATE])
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count++;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages -=3D (count << =
order);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (free_pages < 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages=
 =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&z->lock, flags);
>> + =A0 =A0 =A0 }
>> +#endif
>> +
>> =A0 =A0 =A0 return __zone_watermark_ok(z, order, mark, classzone_idx, al=
loc_flags,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_pages);
>> =A0}
>> @@ -5785,6 +5807,7 @@ int alloc_contig_range(unsigned long start,
>> unsigned long end,
>> =A0 =A0 =A0 =A0* put back to page allocator so that buddy can use them.
>> =A0 =A0 =A0 =A0*/
>>
>> + =A0 =A0 atomic_inc(&is_migrate_isolated);
>> =A0 =A0 =A0 ret =3D start_isolate_page_range(pfn_max_align_down(start),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0pfn_max_align_up(end), migratetype);
>> =A0 =A0 =A0 if (ret)
>> @@ -5854,6 +5877,7 @@ int alloc_contig_range(unsigned long start,
>> unsigned long end,
>> =A0done:
>> =A0 =A0 =A0 undo_isolate_page_range(pfn_max_align_down(start),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pfn_max_alig=
n_up(end), migratetype);
>> + =A0 =A0 atomic_dec(&is_migrate_isolated);
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index c9f0477..e8eb241 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -19,6 +19,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr=
_pages)
>> =A0 =A0 =A0 return pfn_to_page(pfn + i);
>> =A0}
>>
>> +atomic_t is_migrate_isolated;
>> +
>> =A0/*
>> =A0 * start_isolate_page_range() -- make page-allocation-type of range o=
f pages
>> =A0 * to be MIGRATE_ISOLATE.
>>
>>
>>> It is still racy as you already mentioned and I don't think it's trivia=
l.
>>> Direct reclaim can't wake up kswapd forever by current fragile zone->al=
l_unreclaimable.
>>> So it's a livelock.
>>> Then, do you want to fix this problem by your patch[1]?
>>>
>>> It could solve the livelock by OOM kill if we apply your patch[1] but s=
till doesn't wake up
>>> kswapd although it's not critical. Okay. Then, please write down this p=
roblem in detail
>>> in your patch's changelog and resend, please.
>>>
>>> [1] http://lkml.org/lkml/2012/6/14/74
>>>
>>> --
>>> Kind regards,
>>> Minchan Kim
>
>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
