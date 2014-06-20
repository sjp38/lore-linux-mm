Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id EDB416B003C
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:47:37 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so3600814wes.7
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 04:47:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wf7si10803481wjb.2.2014.06.20.04.47.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 04:47:36 -0700 (PDT)
Message-ID: <53A41F54.8000501@suse.cz>
Date: Fri, 20 Jun 2014 13:47:32 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] mm, compaction: report compaction as contended
 only due to lock contention
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-2-git-send-email-vbabka@suse.cz> <20140611011019.GC15630@bbox> <53984A06.6020607@suse.cz> <20140611234944.GA12415@bbox> <5399B2DC.2040004@suse.cz> <20140613024005.GA8704@gmail.com>
In-Reply-To: <20140613024005.GA8704@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/13/2014 04:40 AM, Minchan Kim wrote:
> On Thu, Jun 12, 2014 at 04:02:04PM +0200, Vlastimil Babka wrote:
>> On 06/12/2014 01:49 AM, Minchan Kim wrote:
>> >On Wed, Jun 11, 2014 at 02:22:30PM +0200, Vlastimil Babka wrote:
>> >>On 06/11/2014 03:10 AM, Minchan Kim wrote:
>> >>>On Mon, Jun 09, 2014 at 11:26:14AM +0200, Vlastimil Babka wrote:
>> >>>>Async compaction aborts when it detects zone lock contention or need_resched()
>> >>>>is true. David Rientjes has reported that in practice, most direct async
>> >>>>compactions for THP allocation abort due to need_resched(). This means that a
>> >>>>second direct compaction is never attempted, which might be OK for a page
>> >>>>fault, but hugepaged is intended to attempt a sync compaction in such case and
>> >>>>in these cases it won't.
>> >>>>
>> >>>>This patch replaces "bool contended" in compact_control with an enum that
>> >>>>distinguieshes between aborting due to need_resched() and aborting due to lock
>> >>>>contention. This allows propagating the abort through all compaction functions
>> >>>>as before, but declaring the direct compaction as contended only when lock
>> >>>>contantion has been detected.
>> >>>>
>> >>>>As a result, hugepaged will proceed with second sync compaction as intended,
>> >>>>when the preceding async compaction aborted due to need_resched().
>> >>>
>> >>>You said "second direct compaction is never attempted, which might be OK
>> >>>for a page fault" and said "hugepagd is intented to attempt a sync compaction"
>> >>>so I feel you want to handle khugepaged so special unlike other direct compact
>> >>>(ex, page fault).
>> >>
>> >>Well khugepaged is my primary concern, but I imagine there are other
>> >>direct compaction users besides THP page fault and khugepaged.
>> >>
>> >>>By this patch, direct compaction take care only lock contention, not rescheduling
>> >>>so that pop questions.
>> >>>
>> >>>Is it okay not to consider need_resched in direct compaction really?
>> >>
>> >>It still considers need_resched() to back of from async compaction.
>> >>It's only about signaling contended_compaction back to
>> >>__alloc_pages_slowpath(). There's this code executed after the
>> >>first, async compaction fails:
>> >>
>> >>/*
>> >>  * It can become very expensive to allocate transparent hugepages at
>> >>  * fault, so use asynchronous memory compaction for THP unless it is
>> >>  * khugepaged trying to collapse.
>> >>  */
>> >>if (!(gfp_mask & __GFP_NO_KSWAPD) || (current->flags & PF_KTHREAD))
>> >>         migration_mode = MIGRATE_SYNC_LIGHT;
>> >>
>> >>/*
>> >>  * If compaction is deferred for high-order allocations, it is because
>> >>  * sync compaction recently failed. In this is the case and the caller
>> >>  * requested a movable allocation that does not heavily disrupt the
>> >>  * system then fail the allocation instead of entering direct reclaim.
>> >>  */
>> >>if ((deferred_compaction || contended_compaction) &&
>> >>                                         (gfp_mask & __GFP_NO_KSWAPD))
>> >>         goto nopage;
>> >>
>> >>Both THP page fault and khugepaged use __GFP_NO_KSWAPD. The first
>> >>if() decides whether the second attempt will be sync (for
>> >>khugepaged) or async (page fault). The second if() decides that if
>> >>compaction was contended, then there won't be any second attempt
>> >>(and reclaim) at all. Counting need_resched() as contended in this
>> >>case is bad for khugepaged. Even for page fault it means no direct
>> >
>> >I agree khugepaged shouldn't count on need_resched, even lock contention
>> >because it was a result from admin's decision.
>> >If it hurts system performance, he should adjust knobs for khugepaged.
>> >
>> >>reclaim and a second async compaction. David says need_resched()
>> >>occurs so often then it is a poor heuristic to decide this.
>> >
>> >But page fault is a bit different. Inherently, high-order allocation
>> >(ie, above PAGE_ALLOC_COSTLY_ORDER) is fragile so all of the caller
>> >shoud keep in mind that and prepare second plan(ex, 4K allocation)
>> >so direct reclaim/compaction should take care of latency rather than
>> >success ratio.
>> 
>> Yes it's a rather delicate balance. But the plan is now to try
>> balance this differently than using need_resched.
>> 
>> >If need_resched in second attempt(ie, synchronous compaction) is almost
>> >true, it means the process consumed his timeslice so it shouldn't be
>> >greedy and gives a CPU resource to others.
>> 
>> Synchronous compaction uses cond_resched() so that's fine I think?
> 
> Sorry for being not clear. I post for the clarification before taking
> a rest in holiday. :)
> 
> When THP page fault occurs and found rescheduling while doing async
> direct compaction, it goes "nopage" and fall-backed to 4K page.
> It's good to me.
> 
> Another topic: I couldn't find any cond_resched. Anyway, it could be
> another patch.
> 

Thanks for the explanation. I'll include a cond_resched() at the level of
try_to_compact_pages() where it fits better, so it's not necessary in the place you
suggested. This should solve the "don't be greedy" problem. I will not yet include
the "bail out for latency" part because we are now slowly moving towards removing
need_resched() as a condition for stopping compaction, and this would on the contrary
extend it to prevent direct reclaim as well. David's data suggests that compaction often
bails out due to need_resched(), so this would reduce the amount of direct reclaim and I
don't want to touch that area in this series :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
