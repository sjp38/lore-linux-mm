Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 535B86B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:16:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so14541169wme.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:16:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xs10si16271645wjc.93.2016.04.29.02.16.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Apr 2016 02:16:47 -0700 (PDT)
Subject: Re: [PATCH 09/14] mm: use compaction feedback for thp backoff
 conditions
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-10-git-send-email-mhocko@kernel.org>
 <5721CF7E.9020106@suse.cz> <20160428123545.GG31489@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5723267C.1050903@suse.cz>
Date: Fri, 29 Apr 2016 11:16:44 +0200
MIME-Version: 1.0
In-Reply-To: <20160428123545.GG31489@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On 04/28/2016 02:35 PM, Michal Hocko wrote:
> On Thu 28-04-16 10:53:18, Vlastimil Babka wrote:
>> On 04/20/2016 09:47 PM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> THP requests skip the direct reclaim if the compaction is either
>>> deferred or contended to reduce stalls which wouldn't help the
>>> allocation success anyway. These checks are ignoring other potential
>>> feedback modes which we have available now.
>>>
>>> It clearly doesn't make much sense to go and reclaim few pages if the
>>> previous compaction has failed.
>>>
>>> We can also simplify the check by using compaction_withdrawn which
>>> checks for both COMPACT_CONTENDED and COMPACT_DEFERRED. This check
>>> is however covering more reasons why the compaction was withdrawn.
>>> None of them should be a problem for the THP case though.
>>>
>>> It is safe to back of if we see COMPACT_SKIPPED because that means
>>> that compaction_suitable failed and a single round of the reclaim is
>>> unlikely to make any difference here. We would have to be close to

Hmm this is actually incorrect, as should_continue_reclaim() will keep 
shrink_zone() going as much as needed for compaction to become enabled, 
so it doesn't reclaim just SWAP_CLUSTER_MAX.

>>> the low watermark to reclaim enough and even then there is no guarantee
>>> that the compaction would make any progress while the direct reclaim
>>> would have caused the stall.
>>>
>>> COMPACT_PARTIAL_SKIPPED is slightly different because that means that we
>>> have only seen a part of the zone so a retry would make some sense. But
>>> it would be a compaction retry not a reclaim retry to perform. We are
>>> not doing that and that might indeed lead to situations where THP fails
>>> but this should happen only rarely and it would be really hard to
>>> measure.
>>>
>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>
>> THP's don't compact by default in page fault path anymore, so we don't need
>> to restrict them even more. And hopefully we'll replace the
>> is_thp_gfp_mask() hack with something better soon, so this might be just
>> extra code churn. But I don't feel strongly enough to nack it.
>
> My main point was to simplify the code and get rid of as much compaction
> specific hacks as possible. We might very well drop this later on but it
> would be at least less code to grasp through. I do not have any problem
> with dropping this but I think this shouldn't collide with other patches
> much so reducing the number of lines is worth it.

I just realized it also affects khugepaged, and not just THP page 
faults, so it may potentially cripple THP's completely. My main issue is 
that the reasons to bail out includes COMPACT_SKIPPED, and for a wrong 
reason (see the comment above). It also goes against the comment below 
the noretry label:

  * High-order allocations do not necessarily loop after direct reclaim
  * and reclaim/compaction depends on compaction being called after
  * reclaim so call directly if necessary.

Given that THP's are large, I expect reclaim would indeed be quite often 
necessary before compaction, and the first optimistic async compaction 
attempt will just return SKIPPED. After this patch, there will be no 
more reclaim/compaction attempts for THP's, including khugepaged. And 
given the change of THP page fault defaults, even crippling that path 
should no longer be necessary.

So I would just drop this for now indeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
