Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D7B276B0263
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 08:21:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so56835024wma.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 05:21:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b189si14480585wmd.92.2016.07.18.05.21.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 05:21:06 -0700 (PDT)
Subject: Re: [PATCH v3 12/17] mm, compaction: more reliably increase direct
 compaction priority
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-13-vbabka@suse.cz>
 <20160706053954.GE23627@js1304-P5Q-DELUXE>
 <78b8fc60-ddd8-ae74-4f1a-f4bcb9933016@suse.cz>
 <20160718044112.GA9460@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f5e07f1d-df29-24fb-a49d-9d436ad9b928@suse.cz>
Date: Mon, 18 Jul 2016 14:21:02 +0200
MIME-Version: 1.0
In-Reply-To: <20160718044112.GA9460@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 07/18/2016 06:41 AM, Joonsoo Kim wrote:
> On Fri, Jul 15, 2016 at 03:37:52PM +0200, Vlastimil Babka wrote:
>> On 07/06/2016 07:39 AM, Joonsoo Kim wrote:
>>> On Fri, Jun 24, 2016 at 11:54:32AM +0200, Vlastimil Babka wrote:
>>>> During reclaim/compaction loop, compaction priority can be increased by the
>>>> should_compact_retry() function, but the current code is not optimal. Priority
>>>> is only increased when compaction_failed() is true, which means that compaction
>>>> has scanned the whole zone. This may not happen even after multiple attempts
>>>> with the lower priority due to parallel activity, so we might needlessly
>>>> struggle on the lower priority and possibly run out of compaction retry
>>>> attempts in the process.
>>>>
>>>> We can remove these corner cases by increasing compaction priority regardless
>>>> of compaction_failed(). Examining further the compaction result can be
>>>> postponed only after reaching the highest priority. This is a simple solution
>>>> and we don't need to worry about reaching the highest priority "too soon" here,
>>>> because hen should_compact_retry() is called it means that the system is
>>>> already struggling and the allocation is supposed to either try as hard as
>>>> possible, or it cannot fail at all. There's not much point staying at lower
>>>> priorities with heuristics that may result in only partial compaction.
>>>> Also we now count compaction retries only after reaching the highest priority.
>>>
>>> I'm not sure that this patch is safe. Deferring and skip-bit in
>>> compaction is highly related to reclaim/compaction. Just ignoring them and (almost)
>>> unconditionally increasing compaction priority will result in less
>>> reclaim and less success rate on compaction.
>>
>> I don't see why less reclaim? Reclaim is always attempted before
>> compaction and compaction priority doesn't affect it. And as long as
>> reclaim wants to retry, should_compact_retry() isn't even called, so the
>> priority stays. I wanted to change that in v1, but Michal suggested I
>> shouldn't.
>
> I assume the situation that there is no !costly highorder freepage
> because of fragmentation. In this case, should_reclaim_retry() would
> return false since watermark cannot be met due to absence of high
> order freepage. Now, please see should_compact_retry() with assumption
> that there are enough order-0 free pages. Reclaim/compaction is only
> retried two times (SYNC_LIGHT and SYNC_FULL) with your patchset since
> compaction_withdrawn() return false with enough freepages and
> !COMPACT_SKIPPED.
>
> But, before your patchset, COMPACT_PARTIAL_SKIPPED and
> COMPACT_DEFERRED is considered as withdrawn so will retry
> reclaim/compaction more times.

Perhaps, but it wouldn't guarantee to reach the highest priority.

> As I said before, more reclaim (more freepage) increase migration
> scanner's scan range and then increase compaction success probability.
> Therefore, your patchset which makes reclaim/compaction retry less times
> deterministically would not be safe.

After the patchset, we are guaranteed a full compaction has happened. If 
that doesn't help, yeah maybe we can try reclaiming more... but where to 
draw the line? Reclaim everything for an order-3 allocation just to 
avoid OOM, ignoring that the system might be thrashing heavily? 
Previously it also wasn't guaranteed to reclaim everything, but what is 
the optimal number of retries?

>>
>>> And, as a necessarily, it
>>> would trigger OOM more frequently.
>>
>> OOM is only allowed for costly orders. If reclaim itself doesn't want to
>> retry for non-costly orders anymore, and we finally start calling
>> should_compact_retry(), then I guess the system is really struggling
>> already and eventual OOM wouldn't be premature?
>
> Premature is really subjective so I don't know. Anyway, I tested
> your patchset with simple test case and it causes a regression.
>
> My test setup is:
>
> Mem: 512 MB
> vm.compact_unevictable_allowed = 0
> Mlocked Mem: 225 MB by using mlock(). With some tricks, mlocked pages are
> spread so memory is highly fragmented.

So this testcase isn't really about compaction, as that can't do 
anything even on the full priority. Actually 
compaction_zonelist_suitable() lies to us because it's not really 
suitable. Even with more memory freed by reclaim, it cannot increase the 
chances of compaction (your argument above). Reclaim can only free the 
non-mlocked pages, but compaction can also migrate those.

> fork 500

So the 500 forked processes all wait until the whole forking is done and 
only afterwards they all exit? Or they exit right after fork (or some 
delay?) I would assume the latter otherwise it would fail even before my 
patchset. If the non-mlocked areas don't have enough highorder pages for 
all 500 stacks, it will OOM regardless of how many reclaim and 
compaction retries. But if the processes exit shortly after fork, the 
extra retries might help making time for recycling the freed stacks of 
exited processes. But is it an useful workload for demonstrating the 
regression then?

> This test causes OOM with your patchset but not without your patchset.
>
> Thanks.
>
>>> It would not be your fault. This patch is reasonable in current
>>> situation. It just makes current things more deterministic
>>> although I dislike that current things and this patch would amplify
>>> those problem.
>>>
>>> Thanks.
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
