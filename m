Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63EA66B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 04:11:31 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ga2so24617344lbc.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:11:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si2408649wmr.111.2016.05.13.01.11.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 May 2016 01:11:29 -0700 (PDT)
Subject: Re: [RFC 04/13] mm, page_alloc: restructure direct compaction
 handling in slowpath
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-5-git-send-email-vbabka@suse.cz>
 <20160512132918.GJ4200@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57358C0A.4020002@suse.cz>
Date: Fri, 13 May 2016 10:10:50 +0200
MIME-Version: 1.0
In-Reply-To: <20160512132918.GJ4200@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On 05/12/2016 03:29 PM, Michal Hocko wrote:
> On Tue 10-05-16 09:35:54, Vlastimil Babka wrote:
>> This patch attempts to restructure the code with only minimal functional
>> changes. The call to the first compaction and THP-specific checks are now
>> placed above the retry loop, and the "noretry" direct compaction is removed.
>>
>> The initial compaction is additionally restricted only to costly orders, as we
>> can expect smaller orders to be held back by watermarks, and only larger orders
>> to suffer primarily from fragmentation. This better matches the checks in
>> reclaim's shrink_zones().
>>
>> There are two other smaller functional changes. One is that the upgrade from
>> async migration to light sync migration will always occur after the initial
>> compaction.
>
> I do not think this belongs to the patch. There are two reasons. First
> we do not need to do potentially more expensive sync mode when async is
> able to make some progress and the second

My concern was that __GFP_NORETRY non-costly allocations wouldn't 
otherwise get a MIGRATE_SYNC_LIGHT pass at all. Previously they would 
get it in the noretry: label. So do you think it's a corner case not 
worth caring about? Alternatively we could also remove the 'restriction 
of initial async compaction to costly orders' from this patch and apply 
it separately later. That would also result in the flip to sync_light 
after the initial async attempt for these allocations.

> is that with the currently
> fragile compaction implementation this might reintroduce the premature
> OOM for order-2 requests reported by Hugh. Please see
> http://lkml.kernel.org/r/alpine.LSU.2.11.1604141114290.1086@eggly.anvils

Hmm IIRC that involved some wrong conflict resolution in mmotm? I don't 
remember what the code exactly did look like, but wasn't the problem 
that the initial compaction was async, then the left-over hunk changed 
migration_mode to sync_light, and then should_compact_retry() thought 
"oh we already failed sync_light, return false" when in fact the 
sync_light compaction never happened? Otherwise I don't see how 
switching to sync_light "too early" could lead to premature OOMs.

> Your later patch (which I haven't reviewed yet) is then changing this
> considerably

Yes, my other concern with should_compact_retry() after your "mm, oom: 
protect !costly allocations some more" is that relying on 
compaction_failed() to upgrade the migration mode is unreliable. Async 
compaction can easily keep returning as contended, so might never see 
the COMPACT_COMPLETE result, if it's e.g. limited to nodes without a 
really small zone such as ZONE_DMA.

> but I think it would be safer to not touch the migration
> mode in this - mostly cleanup - patch.
>
>> This is how it has been until recent patch "mm, oom: protect
>> !costly allocations some more", which introduced upgrading the mode based on
>> COMPACT_COMPLETE result, but kept the final compaction always upgraded, which
>> made it even more special. It's better to return to the simpler handling for
>> now, as migration modes will be further modified later in the series.
>>
>> The second change is that once both reclaim and compaction declare it's not
>> worth to retry the reclaim/compact loop, there is no final compaction attempt.
>> As argued above, this is intentional. If that final compaction were to succeed,
>> it would be due to a wrong retry decision, or simply a race with somebody else
>> freeing memory for us.
>>
>> The main outcome of this patch should be simpler code. Logically, the initial
>> compaction without reclaim is the exceptional case to the reclaim/compaction
>> scheme, but prior to the patch, it was the last loop iteration that was
>> exceptional. Now the code matches the logic better. The change also enable the
>> following patches.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>
> Other than the above thing I like this patch.
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
