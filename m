Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA2236B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 11:16:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so14709120lfc.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:16:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id by8si30495755wjb.40.2016.04.26.08.16.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 08:16:24 -0700 (PDT)
Subject: Re: [PATCH 15/28] mm, page_alloc: Move might_sleep_if check to the
 allocator slowpath
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-3-git-send-email-mgorman@techsingularity.net>
 <571F7002.5030602@suse.cz> <20160426145006.GD2858@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F8645.6060503@suse.cz>
Date: Tue, 26 Apr 2016 17:16:21 +0200
MIME-Version: 1.0
In-Reply-To: <20160426145006.GD2858@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/26/2016 04:50 PM, Mel Gorman wrote:
> On Tue, Apr 26, 2016 at 03:41:22PM +0200, Vlastimil Babka wrote:
>> On 04/15/2016 11:07 AM, Mel Gorman wrote:
>> >There is a debugging check for callers that specify __GFP_DIRECT_RECLAIM
>> >from a context that cannot sleep. Triggering this is almost certainly
>> >a bug but it's also overhead in the fast path.
>>
>> For CONFIG_DEBUG_ATOMIC_SLEEP, enabling is asking for the overhead. But for
>> CONFIG_PREEMPT_VOLUNTARY which turns it into _cond_resched(), I guess it's
>> not.
>>
>
> Either way, it struck me as odd. It does depend on the config and it's
> marginal so if there is a problem then I can drop it.

What I tried to say is that it makes sense, but it's perhaps non-obvious :)

>> >Move the check to the slow
>> >path. It'll be harder to trigger as it'll only be checked when watermarks
>> >are depleted but it'll also only be checked in a path that can sleep.
>>
>> Hmm what about zone_reclaim_mode=1, should the check be also duplicated to
>> that part of get_page_from_freelist()?
>>
>
> zone_reclaim has a !gfpflags_allow_blocking() check, does not call
> cond_resched() before that check so it does not fall into an accidental
> sleep path. I'm not seeing why the check is necessary there.

Hmm I thought the primary purpose of this might_sleep_if() is to catch those 
(via the DEBUG_ATOMIC_SLEEP) that do pass __GFP_DIRECT_RECLAIM (which means 
gfpflags_allow_blocking() will be true and zone_reclaim will proceed), but do so 
from the wrong context. Am I getting that wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
