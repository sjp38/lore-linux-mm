Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1325D6B0068
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 05:05:21 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id f8so3023091wiw.10
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 02:05:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id em6si14181933wib.48.2014.06.05.02.05.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 02:05:20 -0700 (PDT)
Message-ID: <539032CD.9070506@suse.cz>
Date: Thu, 05 Jun 2014 11:05:17 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/6] mm, compaction: periodically drop lock and restore
 IRQs in scanners
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041628100.18899@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406041628100.18899@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/05/2014 01:39 AM, David Rientjes wrote:
> On Wed, 4 Jun 2014, Vlastimil Babka wrote:
>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index ed7102c..f0fd4b5 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -185,47 +185,74 @@ static void update_pageblock_skip(struct compact_control *cc,
>>   }
>>   #endif /* CONFIG_COMPACTION */
>>
>> -static inline bool should_release_lock(spinlock_t *lock)
>> +/*
>> + * Compaction requires the taking of some coarse locks that are potentially
>> + * very heavily contended. Check if the process needs to be scheduled or
>> + * if the lock is contended. For async compaction, back out if the process
>> + * needs to be scheduled, or the lock cannot be taken immediately. For sync
>> + * compaction, schedule and spin on the lock if needed.
>> + *
>> + * Returns true if the lock is held
>> + * Returns false if the lock is not held and compaction should abort
>> + */
>> +static inline bool compact_trylock_irqsave(spinlock_t *lock,
>> +			unsigned long *flags, struct compact_control *cc)
>
> Hmm, what tree is this series based on?  It doesn't apply cleanly to
> linux-next, I think you're missing
> mm-compaction-properly-signal-and-act-upon-lock-and-need_sched-contention-fix.patch
> in your tree.

It was 3.15-rc5 and all compaction stuff in -mm applied. I do have the 
fix, but perhaps I forgot something else, or linux-next did not have the 
fix yet (Andrew picked it up on tuesday I think).
Anyway I saw the pending compaction stuff was just merged so things will 
get easier the next round :)

> Is there a performance benefit to doing the inlining here?

I admit I didn't check, I just thought it might make sense since there 
are just two call sites. I'll reconsider but I doubt I will be able to 
see any runtime difference in this path. Maybe just based on the object 
size.

>>   {
>> -	return need_resched() || spin_is_contended(lock);
>> +	if (cc->mode == MIGRATE_ASYNC) {
>> +		if (need_resched() || !spin_trylock_irqsave(lock, *flags)) {
>> +			cc->contended = true;
>> +			return false;
>> +		}
>> +	} else {
>> +		cond_resched();
>
> Why do we need this cond_resched() here if there is already a
> cond_resched() in compact_unlock_should_abort() for non-async compaction?
>
> If this is trying to reschedule right before disabling irqs because
> otherwise spinning on the lock causes irq starvation, then that's a very
> delicate balance and I think we're going to get in trouble later.

I wasn't thinking about real starvation. I guess it's already not so bad 
if nobody noticed that the periodical unlock and IRQ enable was broken 
for so long and the original patch was adding it based on profiles 
looking better, not solving any particular problem encountered.
So here I just thought it wouldn't be too costly to check before taking 
the lock, since it might have been up to 32 iterations since the last 
check. But it's true it might be pointless since when we hold the lock, 
we check once per 32 iterations (with this patch) anyway.

>> +		spin_lock_irqsave(lock, *flags);
>> +	}
>> +
>> +	return true;
>>   }
>>
>>   /*
>>    * Compaction requires the taking of some coarse locks that are potentially
>> - * very heavily contended. Check if the process needs to be scheduled or
>> - * if the lock is contended. For async compaction, back out in the event
>> - * if contention is severe. For sync compaction, schedule.
>> + * very heavily contended. The lock should be periodically unlocked to avoid
>> + * having disabled IRQs for a long time, even when there is nobody waiting on
>> + * the lock. It might also be that allowing the IRQs will result in
>> + * need_resched() becoming true. If scheduling is needed, or somebody else
>> + * has taken the lock, async compaction aborts. Sync compaction schedules.
>> + * Either compaction type will also abort if a fatal signal is pending.
>> + * In either case if the lock was locked, it is dropped and not regained.
>>    *
>> - * Returns true if the lock is held.
>> - * Returns false if the lock is released and compaction should abort
>> + * Returns true if compaction should abort due to fatal signal pending, or
>> + *		async compaction due to lock contention or need to schedule
>> + * Returns false when compaction can continue (sync compaction might have
>> + *		scheduled)
>>    */
>> -static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>> -				      bool locked, struct compact_control *cc)
>> +static inline bool compact_unlock_should_abort(spinlock_t *lock,
>> +		unsigned long flags, bool *locked, struct compact_control *cc)
>
> This inlining is also suspicious and I think keeping both of them
> out-of-line for the freeing and migration scanners is going to be the best
> route unless there's some measurable performance benefit I'm not seeing.

OK.

>>   {
>> -	if (should_release_lock(lock)) {
>> -		if (locked) {
>> -			spin_unlock_irqrestore(lock, *flags);
>> -			locked = false;
>> -		}
>> +	if (*locked) {
>> +		spin_unlock_irqrestore(lock, flags);
>> +		*locked = false;
>> +	}
>>
>> -		/* async aborts if taking too long or contended */
>> -		if (cc->mode == MIGRATE_ASYNC) {
>> +	if (fatal_signal_pending(current))
>> +		return true;
>> +
>> +	if (cc->mode == MIGRATE_ASYNC) {
>> +		if (need_resched() || spin_is_locked(lock)) {
>>   			cc->contended = true;
>> -			return false;
>> +			return true;
>>   		}
>> -
>> +	} else {
>>   		cond_resched();
>>   	}
>>
>> -	if (!locked)
>> -		spin_lock_irqsave(lock, *flags);
>> -	return true;
>> +	return false;
>>   }
>>
>>   /*
>> - * Aside from avoiding lock contention, compaction also periodically checks
>> + * Aside from avoiding lock contention, compaction should also periodically checks
>
> Not sure what the purpose of this commentary change is, it's gramatically
> incorrect now.
>
>>    * need_resched() and either schedules in sync compaction, or aborts async
>> - * compaction. This is similar to compact_checklock_irqsave() does, but used
>> + * compaction. This is similar to compact_unlock_should_abort() does, but used
>
> This was and still is gramatically incorrect :)

Thanks, will fix.

>
>>    * where no lock is concerned.
>>    *
>>    * Returns false when no scheduling was needed, or sync compaction scheduled.
>> @@ -285,6 +312,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>   		int isolated, i;
>>   		struct page *page = cursor;
>>
>> +		/*
>> +		 * Periodically drop the lock (if held) regardless of its
>> +		 * contention, to give chance to IRQs. Abort async compaction
>> +		 * if contended.
>> +		 */
>> +		if (!(blockpfn % SWAP_CLUSTER_MAX)
>> +		    && compact_unlock_should_abort(&cc->zone->lock, flags,
>> +								&locked, cc))
>> +			break;
>> +
>>   		nr_scanned++;
>>   		if (!pfn_valid_within(blockpfn))
>>   			goto isolate_fail;
>> @@ -302,8 +339,9 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>   		 * spin on the lock and we acquire the lock as late as
>>   		 * possible.
>>   		 */
>> -		locked = compact_checklock_irqsave(&cc->zone->lock, &flags,
>> -								locked, cc);
>> +		if (!locked)
>> +			locked = compact_trylock_irqsave(&cc->zone->lock,
>> +								&flags, cc);
>>   		if (!locked)
>>   			break;
>>
>> @@ -523,13 +561,15 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>>
>>   	/* Time to isolate some pages for migration */
>>   	for (; low_pfn < end_pfn; low_pfn++) {
>> -		/* give a chance to irqs before checking need_resched() */
>> -		if (locked && !(low_pfn % SWAP_CLUSTER_MAX)) {
>> -			if (should_release_lock(&zone->lru_lock)) {
>> -				spin_unlock_irqrestore(&zone->lru_lock, flags);
>> -				locked = false;
>> -			}
>> -		}
>> +		/*
>> +		 * Periodically drop the lock (if held) regardless of its
>> +		 * contention, to give chance to IRQs. Abort async compaction
>> +		 * if contended.
>> +		 */
>> +		if (!(low_pfn % SWAP_CLUSTER_MAX)
>> +		    && compact_unlock_should_abort(&zone->lru_lock, flags,
>> +								&locked, cc))
>> +			break;
>>
>>   		/*
>>   		 * migrate_pfn does not necessarily start aligned to a
>> @@ -631,10 +671,11 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>>   		    page_count(page) > page_mapcount(page))
>>   			continue;
>>
>> -		/* Check if it is ok to still hold the lock */
>> -		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
>> -								locked, cc);
>> -		if (!locked || fatal_signal_pending(current))
>> +		/* If the lock is not held, try to take it */
>> +		if (!locked)
>> +			locked = compact_trylock_irqsave(&zone->lru_lock,
>> +								&flags, cc);
>> +		if (!locked)
>>   			break;
>>
>>   		/* Recheck PageLRU and PageTransHuge under lock */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
