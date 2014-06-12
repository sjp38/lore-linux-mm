Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id D94226B00F6
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 10:02:10 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so1705973wiv.14
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 07:02:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw1si3368378wib.7.2014.06.12.07.02.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 07:02:08 -0700 (PDT)
Message-ID: <5399B2DC.2040004@suse.cz>
Date: Thu, 12 Jun 2014 16:02:04 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] mm, compaction: report compaction as contended
 only due to lock contention
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-2-git-send-email-vbabka@suse.cz> <20140611011019.GC15630@bbox> <53984A06.6020607@suse.cz> <20140611234944.GA12415@bbox>
In-Reply-To: <20140611234944.GA12415@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/12/2014 01:49 AM, Minchan Kim wrote:
> On Wed, Jun 11, 2014 at 02:22:30PM +0200, Vlastimil Babka wrote:
>> On 06/11/2014 03:10 AM, Minchan Kim wrote:
>>> On Mon, Jun 09, 2014 at 11:26:14AM +0200, Vlastimil Babka wrote:
>>>> Async compaction aborts when it detects zone lock contention or need_resched()
>>>> is true. David Rientjes has reported that in practice, most direct async
>>>> compactions for THP allocation abort due to need_resched(). This means that a
>>>> second direct compaction is never attempted, which might be OK for a page
>>>> fault, but hugepaged is intended to attempt a sync compaction in such case and
>>>> in these cases it won't.
>>>>
>>>> This patch replaces "bool contended" in compact_control with an enum that
>>>> distinguieshes between aborting due to need_resched() and aborting due to lock
>>>> contention. This allows propagating the abort through all compaction functions
>>>> as before, but declaring the direct compaction as contended only when lock
>>>> contantion has been detected.
>>>>
>>>> As a result, hugepaged will proceed with second sync compaction as intended,
>>>> when the preceding async compaction aborted due to need_resched().
>>>
>>> You said "second direct compaction is never attempted, which might be OK
>>> for a page fault" and said "hugepagd is intented to attempt a sync compaction"
>>> so I feel you want to handle khugepaged so special unlike other direct compact
>>> (ex, page fault).
>>
>> Well khugepaged is my primary concern, but I imagine there are other
>> direct compaction users besides THP page fault and khugepaged.
>>
>>> By this patch, direct compaction take care only lock contention, not rescheduling
>>> so that pop questions.
>>>
>>> Is it okay not to consider need_resched in direct compaction really?
>>
>> It still considers need_resched() to back of from async compaction.
>> It's only about signaling contended_compaction back to
>> __alloc_pages_slowpath(). There's this code executed after the
>> first, async compaction fails:
>>
>> /*
>>   * It can become very expensive to allocate transparent hugepages at
>>   * fault, so use asynchronous memory compaction for THP unless it is
>>   * khugepaged trying to collapse.
>>   */
>> if (!(gfp_mask & __GFP_NO_KSWAPD) || (current->flags & PF_KTHREAD))
>>          migration_mode = MIGRATE_SYNC_LIGHT;
>>
>> /*
>>   * If compaction is deferred for high-order allocations, it is because
>>   * sync compaction recently failed. In this is the case and the caller
>>   * requested a movable allocation that does not heavily disrupt the
>>   * system then fail the allocation instead of entering direct reclaim.
>>   */
>> if ((deferred_compaction || contended_compaction) &&
>>                                          (gfp_mask & __GFP_NO_KSWAPD))
>>          goto nopage;
>>
>> Both THP page fault and khugepaged use __GFP_NO_KSWAPD. The first
>> if() decides whether the second attempt will be sync (for
>> khugepaged) or async (page fault). The second if() decides that if
>> compaction was contended, then there won't be any second attempt
>> (and reclaim) at all. Counting need_resched() as contended in this
>> case is bad for khugepaged. Even for page fault it means no direct
>
> I agree khugepaged shouldn't count on need_resched, even lock contention
> because it was a result from admin's decision.
> If it hurts system performance, he should adjust knobs for khugepaged.
>
>> reclaim and a second async compaction. David says need_resched()
>> occurs so often then it is a poor heuristic to decide this.
>
> But page fault is a bit different. Inherently, high-order allocation
> (ie, above PAGE_ALLOC_COSTLY_ORDER) is fragile so all of the caller
> shoud keep in mind that and prepare second plan(ex, 4K allocation)
> so direct reclaim/compaction should take care of latency rather than
> success ratio.

Yes it's a rather delicate balance. But the plan is now to try balance 
this differently than using need_resched.

> If need_resched in second attempt(ie, synchronous compaction) is almost
> true, it means the process consumed his timeslice so it shouldn't be
> greedy and gives a CPU resource to others.

Synchronous compaction uses cond_resched() so that's fine I think?

> I don't mean we should abort but the process could sleep and retry.
> The point is that we should give latency pain to the process request
> high-order alocation, not another random process.

So basically you are saying that there should be cond_resched() also for 
async compaction when need_resched() is true? Now need_resched() is a 
trigger to back off rather quickly all the way back to 
__alloc_pages_direct_compact() which does contain a cond_resched(). So 
there should be a yield before retry. Or are you worried that the back 
off is not quick enough and it shoudl cond_resched() immediately?

> IMHO, if we want to increase high-order alloc ratio in page fault,
> kswapd should be more aggressive than now via feedback loop from
> fail rate from direct compaction.

Recently I think we have been rather decreasing high-order alloc ratio 
in page fault :) But (at least for the THP) page fault allocation 
attempts contain __GFP_NO_KSWAPD, so there's no feedback loop. I guess 
changing that would be rather disruptive.

>>
>>> We have taken care of it in direct reclaim path so why direct compaction is
>>> so special?
>>
>> I admit I'm not that familiar with reclaim but I didn't quickly find
>> any need_resched() there? There's plenty of cond_resched() but that
>> doesn't mean it will abort? Could you explain for me?
>
> I meant cond_resched.
>
>>
>>> Why does khugepaged give up easily if lock contention/need_resched happens?
>>> khugepaged is important for success ratio as I read your description so IMO,
>>> khugepaged should do synchronously without considering early bail out by
>>> lock/rescheduling.
>>
>> Well a stupid answer is that's how __alloc_pages_slowpath() works :)
>> I don't think it's bad to try using first a more lightweight
>> approach before trying the heavyweight one. As long as the
>> heavyweight one is not skipped for khugepaged.
>
> I'm not saying current two-stage trying is bad. My stand is that we should
> take care of need_resched and shouldn't become a greedy but khugepaged would
> be okay.
>
>>
>>> If it causes problems, user should increase scan_sleep_millisecs/alloc_sleep_millisecs,
>>> which is exactly the knob for that cases.
>>>
>>> So, my point is how about making khugepaged doing always dumb synchronous
>>> compaction thorough PG_KHUGEPAGED or GFP_SYNC_TRANSHUGE?
>>>
>>>>
>>>> Reported-by: David Rientjes <rientjes@google.com>
>>>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>>>> Cc: Minchan Kim <minchan@kernel.org>
>>>> Cc: Mel Gorman <mgorman@suse.de>
>>>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>> Cc: Michal Nazarewicz <mina86@mina86.com>
>>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>> Cc: Christoph Lameter <cl@linux.com>
>>>> Cc: Rik van Riel <riel@redhat.com>
>>>> ---
>>>>   mm/compaction.c | 20 ++++++++++++++------
>>>>   mm/internal.h   | 15 +++++++++++----
>>>>   2 files changed, 25 insertions(+), 10 deletions(-)
>>>>
>>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>>> index b73b182..d37f4a8 100644
>>>> --- a/mm/compaction.c
>>>> +++ b/mm/compaction.c
>>>> @@ -185,9 +185,14 @@ static void update_pageblock_skip(struct compact_control *cc,
>>>>   }
>>>>   #endif /* CONFIG_COMPACTION */
>>>>
>>>> -static inline bool should_release_lock(spinlock_t *lock)
>>>> +enum compact_contended should_release_lock(spinlock_t *lock)
>>>>   {
>>>> -	return need_resched() || spin_is_contended(lock);
>>>> +	if (need_resched())
>>>> +		return COMPACT_CONTENDED_SCHED;
>>>> +	else if (spin_is_contended(lock))
>>>> +		return COMPACT_CONTENDED_LOCK;
>>>> +	else
>>>> +		return COMPACT_CONTENDED_NONE;
>>>>   }
>>>>
>>>>   /*
>>>> @@ -202,7 +207,9 @@ static inline bool should_release_lock(spinlock_t *lock)
>>>>   static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>>>>   				      bool locked, struct compact_control *cc)
>>>>   {
>>>> -	if (should_release_lock(lock)) {
>>>> +	enum compact_contended contended = should_release_lock(lock);
>>>> +
>>>> +	if (contended) {
>>>>   		if (locked) {
>>>>   			spin_unlock_irqrestore(lock, *flags);
>>>>   			locked = false;
>>>> @@ -210,7 +217,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>>>>
>>>>   		/* async aborts if taking too long or contended */
>>>>   		if (cc->mode == MIGRATE_ASYNC) {
>>>> -			cc->contended = true;
>>>> +			cc->contended = contended;
>>>>   			return false;
>>>>   		}
>>>>
>>>> @@ -236,7 +243,7 @@ static inline bool compact_should_abort(struct compact_control *cc)
>>>>   	/* async compaction aborts if contended */
>>>>   	if (need_resched()) {
>>>>   		if (cc->mode == MIGRATE_ASYNC) {
>>>> -			cc->contended = true;
>>>> +			cc->contended = COMPACT_CONTENDED_SCHED;
>>>>   			return true;
>>>>   		}
>>>>
>>>> @@ -1095,7 +1102,8 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
>>>>   	VM_BUG_ON(!list_empty(&cc.freepages));
>>>>   	VM_BUG_ON(!list_empty(&cc.migratepages));
>>>>
>>>> -	*contended = cc.contended;
>>>> +	/* We only signal lock contention back to the allocator */
>>>> +	*contended = cc.contended == COMPACT_CONTENDED_LOCK;
>>>>   	return ret;
>>>>   }
>>>>
>>>> diff --git a/mm/internal.h b/mm/internal.h
>>>> index 7f22a11f..4659e8e 100644
>>>> --- a/mm/internal.h
>>>> +++ b/mm/internal.h
>>>> @@ -117,6 +117,13 @@ extern int user_min_free_kbytes;
>>>>
>>>>   #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>>>>
>>>> +/* Used to signal whether compaction detected need_sched() or lock contention */
>>>> +enum compact_contended {
>>>> +	COMPACT_CONTENDED_NONE = 0, /* no contention detected */
>>>> +	COMPACT_CONTENDED_SCHED,    /* need_sched() was true */
>>>> +	COMPACT_CONTENDED_LOCK,     /* zone lock or lru_lock was contended */
>>>> +};
>>>> +
>>>>   /*
>>>>    * in mm/compaction.c
>>>>    */
>>>> @@ -144,10 +151,10 @@ struct compact_control {
>>>>   	int order;			/* order a direct compactor needs */
>>>>   	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
>>>>   	struct zone *zone;
>>>> -	bool contended;			/* True if a lock was contended, or
>>>> -					 * need_resched() true during async
>>>> -					 * compaction
>>>> -					 */
>>>> +	enum compact_contended contended; /* Signal need_sched() or lock
>>>> +					   * contention detected during
>>>> +					   * compaction
>>>> +					   */
>>>>   };
>>>>
>>>>   unsigned long
>>>> --
>>>> 1.8.4.5
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
