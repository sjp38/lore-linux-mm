Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0076B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 09:17:37 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so4632675eek.2
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:17:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si59771533een.173.2014.04.22.06.17.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 06:17:35 -0700 (PDT)
Message-ID: <53566BEA.2060808@suse.cz>
Date: Tue, 22 Apr 2014 15:17:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
References: <5342BA34.8050006@suse.cz> <1397553507-15330-1-git-send-email-vbabka@suse.cz> <1397553507-15330-2-git-send-email-vbabka@suse.cz> <20140417000745.GF27534@bbox> <20140421124146.c8beacf0d58aafff2085a461@linux-foundation.org> <535590FC.10607@suse.cz> <20140421235319.GD7178@bbox> <53560D3F.2030002@suse.cz> <20140422065224.GE24292@bbox>
In-Reply-To: <20140422065224.GE24292@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 04/22/2014 08:52 AM, Minchan Kim wrote:
> On Tue, Apr 22, 2014 at 08:33:35AM +0200, Vlastimil Babka wrote:
>> On 22.4.2014 1:53, Minchan Kim wrote:
>>> On Mon, Apr 21, 2014 at 11:43:24PM +0200, Vlastimil Babka wrote:
>>>> On 21.4.2014 21:41, Andrew Morton wrote:
>>>>> On Thu, 17 Apr 2014 09:07:45 +0900 Minchan Kim <minchan@kernel.org> wrote:
>>>>>
>>>>>> Hi Vlastimil,
>>>>>>
>>>>>> Below just nitpicks.
>>>>> It seems you were ignored ;)
>>>> Oops, I managed to miss your e-mail, sorry.
>>>>
>>>>>>>  {
>>>>>>>  	struct page *page;
>>>>>>> -	unsigned long high_pfn, low_pfn, pfn, z_end_pfn;
>>>>>>> +	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
>>>>>> Could you add comment for each variable?
>>>>>>
>>>>>> unsigned long pfn; /* scanning cursor */
>>>>>> unsigned long low_pfn; /* lowest pfn free scanner is able to scan */
>>>>>> unsigned long next_free_pfn; /* start pfn for scaning at next truen */
>>>>>> unsigned long z_end_pfn; /* zone's end pfn */
>>>>>>
>>>>>>
>>>>>>> @@ -688,11 +688,10 @@ static void isolate_freepages(struct zone *zone,
>>>>>>>  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>>>>>>  	/*
>>>>>>> -	 * Take care that if the migration scanner is at the end of the zone
>>>>>>> -	 * that the free scanner does not accidentally move to the next zone
>>>>>>> -	 * in the next isolation cycle.
>>>>>>> +	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
>>>>>>> +	 * none, the pfn < low_pfn check will kick in.
>>>>>>        "none" what? I'd like to clear more.
>>>> If there are no updates to next_free_pfn within the for cycle. Which
>>>> matches Andrew's formulation below.
>>>>
>>>>> I did this:
>>>> Thanks!
>>>>
>>>>> --- a/mm/compaction.c~mm-compaction-cleanup-isolate_freepages-fix
>>>>> +++ a/mm/compaction.c
>>>>> @@ -662,7 +662,10 @@ static void isolate_freepages(struct zon
>>>>>  				struct compact_control *cc)
>>>>>  {
>>>>>  	struct page *page;
>>>>> -	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
>>>>> +	unsigned long pfn;	     /* scanning cursor */
>>>>> +	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
>>>>> +	unsigned long next_free_pfn; /* start pfn for scaning at next round */
>>>>> +	unsigned long z_end_pfn;     /* zone's end pfn */
>>>> Yes that works.
>>>>
>>>>>  	int nr_freepages = cc->nr_freepages;
>>>>>  	struct list_head *freelist = &cc->freepages;
>>>>> @@ -679,8 +682,8 @@ static void isolate_freepages(struct zon
>>>>>  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>>>>>  	/*
>>>>> -	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
>>>>> -	 * none, the pfn < low_pfn check will kick in.
>>>>> +	 * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
>>>>> +	 * isolated, the pfn < low_pfn check will kick in.
>>>> OK.
>>>>
>>>>>  	 */
>>>>>  	next_free_pfn = 0;
>>>>>>> @@ -766,9 +765,9 @@ static void isolate_freepages(struct zone *zone,
>>>>>>>  	 * so that compact_finished() may detect this
>>>>>>>  	 */
>>>>>>>  	if (pfn < low_pfn)
>>>>>>> -		cc->free_pfn = max(pfn, zone->zone_start_pfn);
>>>>>>> -	else
>>>>>>> -		cc->free_pfn = high_pfn;
>>>>>>> +		next_free_pfn = max(pfn, zone->zone_start_pfn);
>>>>>> Why we need max operation?
>>>>>> IOW, what's the problem if we do (next_free_pfn = pfn)?
>>>>> An answer to this would be useful, thanks.
>>>> The idea (originally, not new here) is that the free scanner wants
>>>> to remember the highest-pfn
>>>> block where it managed to isolate some pages. If the following page
>>>> migration fails, these isolated
>>>> pages might be put back and would be skipped in further compaction
>>>> attempt if we used just
>>>> "next_free_pfn = pfn", until the scanners get reset.
>>>>
>>>> The question of course is if such situations are frequent and makes
>>>> any difference to compaction
>>>> outcome. And the downsides are potentially useless rescans and code
>>>> complexity. Maybe Mel
>>>> remembers how important this is? It should probably be profiled
>>>> before changes are made.
>>> I didn't mean it. What I mean is code snippet you introduced in 7ed695e069c3c.
>>> At that time, I didn't Cced so I missed that code so let's ask this time.
>>> In that patch, you added this.
>>>
>>> if (pfn < low_pfn)
>>>   cc->free_pfn = max(pfn, zone->zone_start_pfn);
>>> else
>>>   cc->free_pfn = high_pfn;
>>
>> Oh, right, this max(), not the one in the for loop. Sorry, I should
>> have read more closely.
>> But still maybe it's a good opportunity to kill the other max() as
>> well. I'll try some testing.
>>
>> Anyway, this is what I answered to Mel when he asked the same thing
>> when I sent
>> that 7ed695069c3c patch:
>>
>> If a zone starts in a middle of a pageblock and migrate scanner isolates
>> enough pages early to stay within that pageblock, low_pfn will be at the
>> end of that pageblock and after the for cycle in this function ends, pfn
>> might be at the beginning of that pageblock. It might not be an actual
>> problem (this compaction will finish at this point, and if someone else
>> is racing, he will probably check the boundaries himself), but I played
>> it safe.
>>
>>
>>> So the purpose of max(pfn, zone->zone_start_pfn) is to be detected by
>>> compact_finished to stop compaction. And your [1/2] patch in this patchset
>>> always makes free page scanner start on pageblock boundary so when the
>>> loop in isolate_freepages is finished and pfn is lower low_pfn, the pfn
>>> would be lower than migration scanner so compact_finished will always detect
>>> it so I think you could just do
>>>
>>> if (pfn < low_pfn)
>>>   next_free_pfn = pfn;
>>>
>>> cc->free_pfn = next_free_pfn;
>>
>> That could work. I was probably wrong about danger of racing in the
>> reply to Mel,
>> because free_pfn is stored in cc (private), not zone (shared).
>>
>>>
>>> Or, if you want to clear *reset*,
>>> if (pfn < lown_pfn)
>>>   next_free_pfn = zone->zone_start_pfn;
>>>
>>> cc->free_pfn = next_free_pfn;
>>
>> That would work as well but is less straightforward I think. Might
>> be misleading if
>> someone added tracepoints to track the free scanner progress with
>> pfn's (which
>> might happen soon...)
> 
> My preference is to add following with pair of compact_finished
> 
> static inline void finish_compact(struct compact_control *cc)
> {
>   cc->free_pfn = cc->migrate_pfn;
> }

Yes setting free_pfn to migrate_pfn is probably the best way, as these
are the values compared in compact_finished. But I wouldn't introduce a
new function just for one instance of this. Also compact_finished()
doesn't test just the scanners to decide whether compaction should
continue, so the pairing would be imperfect anyway.
So Andrew, if you agree can you please fold in the patch below.

> But I don't care.
> If you didn't send this patch as clean up, I would never interrupt
> on the way but you said it's cleanup patch and the one made me spend a
> few minutes to understand the code so it's not a clean up patch. ;-).
> So, IMO, it's worth to tidy it up.

Yes, I understand and agree.

------8<------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Tue, 22 Apr 2014 13:55:36 +0200
Subject: mm-compaction-cleanup-isolate_freepages-fix2

Cleanup detection of compaction scanners crossing in isolate_freepages().
To make sure compact_finished() observes scanners crossing, we can just set
free_pfn to migrate_pfn instead of confusing max() construct.

Suggested-by: Minchan Kim <minchan@kernel.org>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Dongjun Shin <d.j.shin@samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Sunghwan Yun <sunghwan.yun@samsung.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 37c15fe..1c992dc 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -768,7 +768,7 @@ static void isolate_freepages(struct zone *zone,
 	 * so that compact_finished() may detect this
 	 */
 	if (pfn < low_pfn)
-		next_free_pfn = max(pfn, zone->zone_start_pfn);
+		next_free_pfn = cc->migrate_pfn;
 
 	cc->free_pfn = next_free_pfn;
 	cc->nr_freepages = nr_freepages;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
