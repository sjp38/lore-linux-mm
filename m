Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 08D716B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 10:18:36 -0500 (EST)
Received: by wevl61 with SMTP id l61so34019996wev.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 07:18:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9si22661492wjs.200.2015.03.02.07.18.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 07:18:34 -0800 (PST)
Date: Mon, 2 Mar 2015 16:18:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150302151832.GE26334@dhcp22.suse.cz>
References: <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150223004521.GK12722@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Mon 23-02-15 11:45:21, Dave Chinner wrote:
[...]
> A reserve memory pool is no different - every time a memory reserve
> occurs, a watermark is lifted to accommodate it, and the transaction
> is not allowed to proceed until the amount of free memory exceeds
> that watermark. The memory allocation subsystem then only allows
> *allocations* marked correctly to allocate pages from that the
> reserve that watermark protects. e.g. only allocations using
> __GFP_RESERVE are allowed to dip into the reserve pool.

The idea is sound. But I am pretty sure we will find many corner
cases. E.g. what if the mere reservation attempt causes the system
to go OOM and trigger the OOM killer? Sure that wouldn't be too much
different from the OOM triggered during the allocation but there is one
major difference. Reservations need to be estimated and I expect the
estimation would be on the more conservative side and so the OOM might
not happen without them.

> By using watermarks, freeing of memory will automatically top
> up the reserve pool which means that we guarantee that reclaimable
> memory allocated for demand paging during transacitons doesn't
> deplete the reserve pool permanently.  As a result, when there is
> plenty of free and/or reclaimable memory, the reserve pool
> watermarks will have almost zero impact on performance and
> behaviour.

Typical busy system won't be very far away from the high watermark
so there would be a reclaim performed during increased watermaks
(aka reservation) and that might lead to visible performance
degradation. This might be acceptable but it also adds a certain level
of unpredictability when performance characteristics might change
suddenly.

> Further, because it's just accounting and behavioural thresholds,
> this allows the mm subsystem to control how the reserve pool is
> accounted internally. e.g. clean, reclaimable pages in the page
> cache could serve as reserve pool pages as they can be immediately
> reclaimed for allocation.

But they also can turn into hard/impossible to reclaim as well. Clean
pages might get dirty and e.g. swap backed pages run out of their
backing storage. So I guess we cannot count with those pages without
reclaiming them first and hiding them into the reserve. Which is what
you suggest below probably but I wasn't really sure...

> This could be acheived by setting reclaim targets first to the reserve
> pool watermark, then the second target is enough pages to satisfy the
> current allocation.
> 
> And, FWIW, there's nothing stopping this mechanism from have order
> based reserve thresholds. e.g. IB could really do with a 64k reserve
> pool threshold and hence help solve the long standing problems they
> have with filling the receive ring in GFP_ATOMIC context...
> 
> Sure, that's looking further down the track, but my point still
> remains: we need a viable long term solution to this problem. Maybe
> reservations are not the solution, but I don't see anyone else who
> is thinking of how to address this architectural problem at a system
> level right now.

I think the idea is good! It will just be quite tricky to get there
without causing more problems than those being solved. The biggest
question mark so far seems to be the reservation size estimation. If
it is hard for any caller to know the size beforehand (which would
be really close to the actually used size) then the whole complexity
in the code sounds like an overkill and asking administrator to tune
min_free_kbytes seems a better fit (we would still have to teach the
allocator to access reserves when really necessary) because the system
would behave more predictably (although some memory would be wasted).

> We need to design and document the model first, then review it, then
> we can start working at the code level to implement the solution we've
> designed.

I have already asked James to add this on LSF agenda but nothing has
materialized on the schedule yet. I will poke him again.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
