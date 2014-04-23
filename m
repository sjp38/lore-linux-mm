Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id CFE546B0036
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 09:54:54 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id t60so884214wes.19
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 06:54:54 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id yx6si625537wjc.0.2014.04.23.06.54.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 06:54:53 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id hm4so4574622wib.2
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 06:54:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53576C08.2080003@suse.cz>
References: <5342BA34.8050006@suse.cz>
	<1397553507-15330-1-git-send-email-vbabka@suse.cz>
	<1397553507-15330-2-git-send-email-vbabka@suse.cz>
	<20140417000745.GF27534@bbox>
	<20140421124146.c8beacf0d58aafff2085a461@linux-foundation.org>
	<535590FC.10607@suse.cz>
	<20140421235319.GD7178@bbox>
	<53560D3F.2030002@suse.cz>
	<20140422065224.GE24292@bbox>
	<53566BEA.2060808@suse.cz>
	<20140423025806.GA11184@js1304-P5Q-DELUXE>
	<53576C08.2080003@suse.cz>
Date: Wed, 23 Apr 2014 22:54:52 +0900
Message-ID: <CAAmzW4OjKcrzXYNG6KN8acbOVfVtFmu-1COKpNQJrraBTmWGiA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Heesub Shin <heesub.shin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

2014-04-23 16:30 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 04/23/2014 04:58 AM, Joonsoo Kim wrote:
>> On Tue, Apr 22, 2014 at 03:17:30PM +0200, Vlastimil Babka wrote:
>>> On 04/22/2014 08:52 AM, Minchan Kim wrote:
>>>> On Tue, Apr 22, 2014 at 08:33:35AM +0200, Vlastimil Babka wrote:
>>>>> On 22.4.2014 1:53, Minchan Kim wrote:
>>>>>> On Mon, Apr 21, 2014 at 11:43:24PM +0200, Vlastimil Babka wrote:
>>>>>>> On 21.4.2014 21:41, Andrew Morton wrote:
>>>>>>>> On Thu, 17 Apr 2014 09:07:45 +0900 Minchan Kim <minchan@kernel.org> wrote:
>>>>>>>>
>>>>>>>>> Hi Vlastimil,
>>>>>>>>>
>>>>>>>>> Below just nitpicks.
>>>>>>>> It seems you were ignored ;)
>>>>>>> Oops, I managed to miss your e-mail, sorry.
>>>>>>>
>>>>>>>>>>  {
>>>>>>>>>>       struct page *page;
>>>>>>>>>> -     unsigned long high_pfn, low_pfn, pfn, z_end_pfn;
>>>>>>>>>> +     unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
>>>>>>>>> Could you add comment for each variable?
>>>>>>>>>
>>>>>>>>> unsigned long pfn; /* scanning cursor */
>>>>>>>>> unsigned long low_pfn; /* lowest pfn free scanner is able to scan */
>>>>>>>>> unsigned long next_free_pfn; /* start pfn for scaning at next truen */
>>>>>>>>> unsigned long z_end_pfn; /* zone's end pfn */
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>> @@ -688,11 +688,10 @@ static void isolate_freepages(struct zone *zone,
>>>>>>>>>>       low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>>>>>>>>>       /*
>>>>>>>>>> -      * Take care that if the migration scanner is at the end of the zone
>>>>>>>>>> -      * that the free scanner does not accidentally move to the next zone
>>>>>>>>>> -      * in the next isolation cycle.
>>>>>>>>>> +      * Seed the value for max(next_free_pfn, pfn) updates. If there are
>>>>>>>>>> +      * none, the pfn < low_pfn check will kick in.
>>>>>>>>>        "none" what? I'd like to clear more.
>>>>>>> If there are no updates to next_free_pfn within the for cycle. Which
>>>>>>> matches Andrew's formulation below.
>>>>>>>
>>>>>>>> I did this:
>>>>>>> Thanks!
>>>>>>>
>>>>>>>> --- a/mm/compaction.c~mm-compaction-cleanup-isolate_freepages-fix
>>>>>>>> +++ a/mm/compaction.c
>>>>>>>> @@ -662,7 +662,10 @@ static void isolate_freepages(struct zon
>>>>>>>>                                 struct compact_control *cc)
>>>>>>>>  {
>>>>>>>>         struct page *page;
>>>>>>>> -       unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
>>>>>>>> +       unsigned long pfn;           /* scanning cursor */
>>>>>>>> +       unsigned long low_pfn;       /* lowest pfn scanner is able to scan */
>>>>>>>> +       unsigned long next_free_pfn; /* start pfn for scaning at next round */
>>>>>>>> +       unsigned long z_end_pfn;     /* zone's end pfn */
>>>>>>> Yes that works.
>>>>>>>
>>>>>>>>         int nr_freepages = cc->nr_freepages;
>>>>>>>>         struct list_head *freelist = &cc->freepages;
>>>>>>>> @@ -679,8 +682,8 @@ static void isolate_freepages(struct zon
>>>>>>>>         low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>>>>>>>         /*
>>>>>>>> -        * Seed the value for max(next_free_pfn, pfn) updates. If there are
>>>>>>>> -        * none, the pfn < low_pfn check will kick in.
>>>>>>>> +        * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
>>>>>>>> +        * isolated, the pfn < low_pfn check will kick in.
>>>>>>> OK.
>>>>>>>
>>>>>>>>          */
>>>>>>>>         next_free_pfn = 0;
>>>>>>>>>> @@ -766,9 +765,9 @@ static void isolate_freepages(struct zone *zone,
>>>>>>>>>>        * so that compact_finished() may detect this
>>>>>>>>>>        */
>>>>>>>>>>       if (pfn < low_pfn)
>>>>>>>>>> -             cc->free_pfn = max(pfn, zone->zone_start_pfn);
>>>>>>>>>> -     else
>>>>>>>>>> -             cc->free_pfn = high_pfn;
>>>>>>>>>> +             next_free_pfn = max(pfn, zone->zone_start_pfn);
>>>>>>>>> Why we need max operation?
>>>>>>>>> IOW, what's the problem if we do (next_free_pfn = pfn)?
>>>>>>>> An answer to this would be useful, thanks.
>>>>>>> The idea (originally, not new here) is that the free scanner wants
>>>>>>> to remember the highest-pfn
>>>>>>> block where it managed to isolate some pages. If the following page
>>>>>>> migration fails, these isolated
>>>>>>> pages might be put back and would be skipped in further compaction
>>>>>>> attempt if we used just
>>>>>>> "next_free_pfn = pfn", until the scanners get reset.
>>>>>>>
>>>>>>> The question of course is if such situations are frequent and makes
>>>>>>> any difference to compaction
>>>>>>> outcome. And the downsides are potentially useless rescans and code
>>>>>>> complexity. Maybe Mel
>>>>>>> remembers how important this is? It should probably be profiled
>>>>>>> before changes are made.
>>>>>> I didn't mean it. What I mean is code snippet you introduced in 7ed695e069c3c.
>>>>>> At that time, I didn't Cced so I missed that code so let's ask this time.
>>>>>> In that patch, you added this.
>>>>>>
>>>>>> if (pfn < low_pfn)
>>>>>>   cc->free_pfn = max(pfn, zone->zone_start_pfn);
>>>>>> else
>>>>>>   cc->free_pfn = high_pfn;
>>>>>
>>>>> Oh, right, this max(), not the one in the for loop. Sorry, I should
>>>>> have read more closely.
>>>>> But still maybe it's a good opportunity to kill the other max() as
>>>>> well. I'll try some testing.
>>>>>
>>>>> Anyway, this is what I answered to Mel when he asked the same thing
>>>>> when I sent
>>>>> that 7ed695069c3c patch:
>>>>>
>>>>> If a zone starts in a middle of a pageblock and migrate scanner isolates
>>>>> enough pages early to stay within that pageblock, low_pfn will be at the
>>>>> end of that pageblock and after the for cycle in this function ends, pfn
>>>>> might be at the beginning of that pageblock. It might not be an actual
>>>>> problem (this compaction will finish at this point, and if someone else
>>>>> is racing, he will probably check the boundaries himself), but I played
>>>>> it safe.
>>>>>
>>>>>
>>>>>> So the purpose of max(pfn, zone->zone_start_pfn) is to be detected by
>>>>>> compact_finished to stop compaction. And your [1/2] patch in this patchset
>>>>>> always makes free page scanner start on pageblock boundary so when the
>>>>>> loop in isolate_freepages is finished and pfn is lower low_pfn, the pfn
>>>>>> would be lower than migration scanner so compact_finished will always detect
>>>>>> it so I think you could just do
>>>>>>
>>>>>> if (pfn < low_pfn)
>>>>>>   next_free_pfn = pfn;
>>>>>>
>>>>>> cc->free_pfn = next_free_pfn;
>>>>>
>>>>> That could work. I was probably wrong about danger of racing in the
>>>>> reply to Mel,
>>>>> because free_pfn is stored in cc (private), not zone (shared).
>>>>>
>>>>>>
>>>>>> Or, if you want to clear *reset*,
>>>>>> if (pfn < lown_pfn)
>>>>>>   next_free_pfn = zone->zone_start_pfn;
>>>>>>
>>>>>> cc->free_pfn = next_free_pfn;
>>>>>
>>>>> That would work as well but is less straightforward I think. Might
>>>>> be misleading if
>>>>> someone added tracepoints to track the free scanner progress with
>>>>> pfn's (which
>>>>> might happen soon...)
>>>>
>>>> My preference is to add following with pair of compact_finished
>>>>
>>>> static inline void finish_compact(struct compact_control *cc)
>>>> {
>>>>   cc->free_pfn = cc->migrate_pfn;
>>>> }
>>>
>>> Yes setting free_pfn to migrate_pfn is probably the best way, as these
>>> are the values compared in compact_finished. But I wouldn't introduce a
>>> new function just for one instance of this. Also compact_finished()
>>> doesn't test just the scanners to decide whether compaction should
>>> continue, so the pairing would be imperfect anyway.
>>> So Andrew, if you agree can you please fold in the patch below.
>>>
>>>> But I don't care.
>>>> If you didn't send this patch as clean up, I would never interrupt
>>>> on the way but you said it's cleanup patch and the one made me spend a
>>>> few minutes to understand the code so it's not a clean up patch. ;-).
>>>> So, IMO, it's worth to tidy it up.
>>>
>>> Yes, I understand and agree.
>>>
>>> ------8<------
>>> From: Vlastimil Babka <vbabka@suse.cz>
>>> Date: Tue, 22 Apr 2014 13:55:36 +0200
>>> Subject: mm-compaction-cleanup-isolate_freepages-fix2
>>>
>>> Cleanup detection of compaction scanners crossing in isolate_freepages().
>>> To make sure compact_finished() observes scanners crossing, we can just set
>>> free_pfn to migrate_pfn instead of confusing max() construct.
>>>
>>> Suggested-by: Minchan Kim <minchan@kernel.org>
>>> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
>>> Cc: Christoph Lameter <cl@linux.com>
>>> Cc: Dongjun Shin <d.j.shin@samsung.com>
>>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>> Cc: Mel Gorman <mgorman@suse.de>
>>> Cc: Michal Nazarewicz <mina86@mina86.com>
>>> Cc: Minchan Kim <minchan@kernel.org>
>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>> Cc: Rik van Riel <riel@redhat.com>
>>> Cc: Sunghwan Yun <sunghwan.yun@samsung.com>
>>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>>>
>>> ---
>>>  mm/compaction.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index 37c15fe..1c992dc 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -768,7 +768,7 @@ static void isolate_freepages(struct zone *zone,
>>>       * so that compact_finished() may detect this
>>>       */
>>>      if (pfn < low_pfn)
>>> -            next_free_pfn = max(pfn, zone->zone_start_pfn);
>>> +            next_free_pfn = cc->migrate_pfn;
>>>
>>>      cc->free_pfn = next_free_pfn;
>>>      cc->nr_freepages = nr_freepages;
>>> --
>>> 1.8.4.5
>>>
>>
>> Hello,
>>
>> How about doing more clean-up at this time?
>>
>> What I did is that taking end_pfn out of the loop and consider zone
>> boundary once. After then, we just subtract pageblock_nr_pages on
>> every iteration. With this change, we can remove local variable, z_end_pfn.
>> Another things I did are removing max() operation and un-needed
>> assignment to isolate variable.
>>
>> Thanks.
>>
>> --------->8------------
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 1c992dc..95a506d 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -671,10 +671,10 @@ static void isolate_freepages(struct zone *zone,
>>                               struct compact_control *cc)
>>  {
>>       struct page *page;
>> -     unsigned long pfn;           /* scanning cursor */
>> +     unsigned long pfn;           /* start of scanning window */
>> +     unsigned long end_pfn;       /* end of scanning window */
>>       unsigned long low_pfn;       /* lowest pfn scanner is able to scan */
>>       unsigned long next_free_pfn; /* start pfn for scaning at next round */
>> -     unsigned long z_end_pfn;     /* zone's end pfn */
>>       int nr_freepages = cc->nr_freepages;
>>       struct list_head *freelist = &cc->freepages;
>>
>> @@ -688,15 +688,16 @@ static void isolate_freepages(struct zone *zone,
>>        * is using.
>>        */
>>       pfn = cc->free_pfn & ~(pageblock_nr_pages-1);
>> -     low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>
>>       /*
>> -      * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
>> -      * isolated, the pfn < low_pfn check will kick in.
>> +      * Take care when isolating in last pageblock of a zone which
>> +      * ends in the middle of a pageblock.
>>        */
>> -     next_free_pfn = 0;
>> +     end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn(zone));
>> +     low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>
>> -     z_end_pfn = zone_end_pfn(zone);
>> +     /* If no pages are isolated, the pfn < low_pfn check will kick in. */
>> +     next_free_pfn = 0;
>>
>>       /*
>>        * Isolate free pages until enough are available to migrate the
>> @@ -704,9 +705,8 @@ static void isolate_freepages(struct zone *zone,
>>        * and free page scanners meet or enough free pages are isolated.
>>        */
>>       for (; pfn >= low_pfn && cc->nr_migratepages > nr_freepages;
>> -                                     pfn -= pageblock_nr_pages) {
>> +             pfn -= pageblock_nr_pages, end_pfn -= pageblock_nr_pages) {
>
> If zone_end_pfn was in the middle of a pageblock, then your end_pfn will
> always be in the middle of a pageblock and you will not scan half of all
> pageblocks.
>

Okay. I think a way to fix it.
By assigning pfn(start of scanning window) to
end_pfn(end of scanning window) for the next loop, we can solve the problem
you mentioned. How about below?

-             pfn -= pageblock_nr_pages, end_pfn -= pageblock_nr_pages) {
+            end_pfn = pfn, pfn -= pageblock_nr_pages) {

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
