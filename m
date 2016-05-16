Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3C596B0253
	for <linux-mm@kvack.org>; Mon, 16 May 2016 05:50:25 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so56640759lbc.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:50:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 139si19137840wmy.14.2016.05.16.02.50.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 02:50:24 -0700 (PDT)
Subject: Re: [RFC 13/13] mm, compaction: fix and improve watermark handling
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-14-git-send-email-vbabka@suse.cz>
 <20160516092505.GE23146@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573997DE.6010109@suse.cz>
Date: Mon, 16 May 2016 11:50:22 +0200
MIME-Version: 1.0
In-Reply-To: <20160516092505.GE23146@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/16/2016 11:25 AM, Michal Hocko wrote:
> On Tue 10-05-16 09:36:03, Vlastimil Babka wrote:
>> Compaction has been using watermark checks when deciding whether it was
>> successful, and whether compaction is at all suitable. There are few problems
>> with these checks.
>>
>> - __compact_finished() uses low watermark in a check that has to pass if
>>    the direct compaction is to finish and allocation should succeed. This is
>>    too pessimistic, as the allocation will typically use min watermark. It
>>    may happen that during compaction, we drop below the low watermark (due to
>>    parallel activity), but still form the target high-order page. By checking
>>    against low watermark, we might needlessly continue compaction. After this
>>    patch, the check uses direct compactor's alloc_flags to determine the
>>    watermark, which is effectively the min watermark.
>
> OK, this makes some sense. It would be great if we could have at least
> some clarification why the low wmark has been used previously. Probably
> Mel can remember?
>
>> - __compaction_suitable has the same issue in the check whether the allocation
>>    is already supposed to succeed and we don't need to compact. Fix it the same
>>    way.
>>
>> - __compaction_suitable() then checks the low watermark plus a (2 << order) gap
>>    to decide if there's enough free memory to perform compaction. This check
>
> And this was a real head scratcher when I started looking into the
> compaction recently. Why do we need to be above low watermark to even
> start compaction.

Hmm, above you said you're fine with low wmark (maybe after 
clarification). I don't know why it was used, can only guess.

> Compaction uses additional memory only for a short
> period of time and then releases the already migrated pages.

As for the 2 << order gap. I can imagine that e.g. order-5 compaction 
(32 pages) isolates 20 pages for migration and starts looking for free 
pages. It collects 19 free pages and then reaches an order-4 free page. 
Splitting that page to collect it would result in 19+16=35 pages 
isolated, thus exceed the 1 << order gap, and fail. With 2 << order gap, 
chances of this happening are reduced.

>>    uses direct compactor's alloc_flags, but that's wrong. If alloc_flags doesn't
>>    include ALLOC_CMA, we might fail the check, even though the freepage
>>    isolation isn't restricted outside of CMA pageblocks. On the other hand,
>>    alloc_flags may indicate access to memory reserves, making compaction proceed
>>    and then fail watermark check during freepage isolation, which doesn't pass
>>    alloc_flags. The fix here is to use fixed ALLOC_CMA flags in the
>>    __compaction_suitable() check.
>
> This makes my head hurt. Whut?

I'll try to explain better next time.

>> - __isolate_free_page uses low watermark check to decide if free page can be
>>    isolated. It also doesn't use ALLOC_CMA, so add it for the same reasons.
>
> Why do we check the watermark at all? What would happen if this obscure
> if (!is_migrate_isolate(mt)) was gone? I remember I put some tracing
> there and it never hit for me even when I was testing close to OOM
> conditions. Maybe an earlier check bailed out but this code path looks
> really obscure so it should either deserve a large fat comment or to
> die.

The check is there so that compaction doesn't exhaust memory below 
reserves during its work, just like any other non-privileged allocation.

>> - The use of low watermark checks in __compaction_suitable() and
>>    __isolate_free_page does perhaps make sense for high-order allocations where
>>    more freepages increase the chance of success, and we can typically fail
>>    with some order-0 fallback when the system is struggling. But for low-order
>>    allocation, forming the page should not be that hard. So using low watermark
>>    here might just prevent compaction from even trying, and eventually lead to
>>    OOM killer even if we are above min watermarks. So after this patch, we use
>>    min watermark for non-costly orders in these checks, by passing the
>>    alloc_flags parameter to split_page() and __isolate_free_page().
>
> OK, so if IIUC costly high order requests even shouldn't try when we are
> below watermark (unless they are __GFP_REPEAT which would get us to a
> stronger compaction mode/priority) and that would reclaim us over low
> wmark and go on. Is that what you are saying? This makes some sense but
> then let's have a _single_ place to check the watermak please. This
> checks at few different levels is just subtle as hell and error prone
> likewise.

What single place then? The situation might change dynamically so 
passing the initial __compaction_suitable() check doesn't guarantee that 
enough free pages are still available when it comes to isolating 
freepages. Your testing that never hit it shows that this is rare, but 
do we want to risk compaction making an OOM situation worse?

>> To sum up, after this patch, the kernel should in some situations finish
>> successful direct compaction sooner, prevent compaction from starting when it's
>> not needed, proceed with compaction when free memory is in CMA pageblocks, and
>> for non-costly orders, prevent OOM killing or excessive reclaim when free
>> memory is between the min and low watermarks.
>
> Could you please split this patch into three(?) parts. One to remove as many
> wmark checks as possible, move low wmark to min for !costly high orders
> and finally the cma part which I fail to understand...

Sure, although I'm not yet convinced we can remove any checks.

> Thanks!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
