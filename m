Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9D39828E1
	for <linux-mm@kvack.org>; Mon, 16 May 2016 03:17:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so38321333wme.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:17:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si36980458wjj.56.2016.05.16.00.17.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 00:17:13 -0700 (PDT)
Subject: Re: [RFC 11/13] mm, compaction: add the ultimate direct compaction
 priority
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-12-git-send-email-vbabka@suse.cz>
 <20160513133851.GP20141@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573973F7.7070202@suse.cz>
Date: Mon, 16 May 2016 09:17:11 +0200
MIME-Version: 1.0
In-Reply-To: <20160513133851.GP20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/13/2016 03:38 PM, Michal Hocko wrote:
> On Tue 10-05-16 09:36:01, Vlastimil Babka wrote:
>> During reclaim/compaction loop, it's desirable to get a final answer from
>> unsuccessful compaction so we can either fail the allocation or invoke the OOM
>> killer. However, heuristics such as deferred compaction or pageblock skip bits
>> can cause compaction to skip parts or whole zones and lead to premature OOM's,
>> failures or excessive reclaim/compaction retries.
>>
>> To remedy this, we introduce a new direct compaction priority called
>> COMPACT_PRIO_SYNC_FULL, which instructs direct compaction to:
>>
>> - ignore deferred compaction status for a zone
>> - ignore pageblock skip hints
>> - ignore cached scanner positions and scan the whole zone
>> - use MIGRATE_SYNC migration mode
>
> I do not think we can do MIGRATE_SYNC because fallback_migrate_page
> would trigger pageout and we are in the allocation path and so we
> could blow up the stack.

Ah, I thought it was just waiting for the writeout to complete, and you 
wanted to introduce another migrate mode to actually do the writeout. 
But looks like I misremembered.

>> The new priority should get eventually picked up by should_compact_retry() and
>> this should improve success rates for costly allocations using __GFP_RETRY,
>
> s@__GFP_RETRY@__GFP_REPEAT@

Ah thanks. Depending on the patch timing it might be __GFP_RETRY_HARD in 
the end, right :)

>> such as hugetlbfs allocations, and reduce some corner-case OOM's for non-costly
>> allocations.
>
> My testing has shown that even with the current implementation with
> deferring, skip hints and cached positions had (close to) 100% success
> rate even with close to OOM conditions.

Hmm, I thought you at one point said that ignoring skip hints was a 
large improvement, because the current resetting of them is just too fuzzy.

> I am wondering whether this strongest priority should be done only for
> !costly high order pages. But we probably want less special cases
> between costly and !costly orders.

Yeah, if somebody wants to retry hard, let him.

>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
>> ---
>>   include/linux/compaction.h |  1 +
>>   mm/compaction.c            | 15 ++++++++++++---
>>   2 files changed, 13 insertions(+), 3 deletions(-)
>>
> [...]
>> @@ -1631,7 +1639,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>>   								ac->nodemask) {
>>   		enum compact_result status;
>>
>> -		if (compaction_deferred(zone, order)) {
>> +		if (prio > COMPACT_PRIO_SYNC_FULL
>> +					&& compaction_deferred(zone, order)) {
>>   			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
>>   			continue;
>>   		}
>
> Wouldn't it be better to pull the prio check into compaction_deferred
> directly? There are more callers and I am not really sure all of them
> would behave consistently.

I'll check, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
