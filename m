Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id AC9BE6B006C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 11:05:48 -0500 (EST)
Received: by widex7 with SMTP id ex7so16037726wid.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 08:05:48 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z14si1408089wjw.55.2015.03.02.08.05.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 08:05:47 -0800 (PST)
Date: Mon, 2 Mar 2015 11:05:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150302160537.GA23072@phnom.home.cmpxchg.org>
References: <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150302151832.GE26334@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302151832.GE26334@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Mon, Mar 02, 2015 at 04:18:32PM +0100, Michal Hocko wrote:
> On Mon 23-02-15 11:45:21, Dave Chinner wrote:
> [...]
> > A reserve memory pool is no different - every time a memory reserve
> > occurs, a watermark is lifted to accommodate it, and the transaction
> > is not allowed to proceed until the amount of free memory exceeds
> > that watermark. The memory allocation subsystem then only allows
> > *allocations* marked correctly to allocate pages from that the
> > reserve that watermark protects. e.g. only allocations using
> > __GFP_RESERVE are allowed to dip into the reserve pool.
> 
> The idea is sound. But I am pretty sure we will find many corner
> cases. E.g. what if the mere reservation attempt causes the system
> to go OOM and trigger the OOM killer? Sure that wouldn't be too much
> different from the OOM triggered during the allocation but there is one
> major difference. Reservations need to be estimated and I expect the
> estimation would be on the more conservative side and so the OOM might
> not happen without them.

The whole idea is that filesystems request the reserves while they can
still sleep for progress or fail the macro-operation with -ENOMEM.

And the estimate wouldn't just be on the conservative side, it would
have to be the worst-case scenario.  If we run out of reserves in an
allocation that can not fail that would be a bug that can lock up the
machine.  We can then fall back to the OOM killer in a last-ditch
effort to make forward progress, but as the victim tasks can get stuck
behind state/locks held by the allocation side, the machine might lock
up after all.

> > By using watermarks, freeing of memory will automatically top
> > up the reserve pool which means that we guarantee that reclaimable
> > memory allocated for demand paging during transacitons doesn't
> > deplete the reserve pool permanently.  As a result, when there is
> > plenty of free and/or reclaimable memory, the reserve pool
> > watermarks will have almost zero impact on performance and
> > behaviour.
> 
> Typical busy system won't be very far away from the high watermark
> so there would be a reclaim performed during increased watermaks
> (aka reservation) and that might lead to visible performance
> degradation. This might be acceptable but it also adds a certain level
> of unpredictability when performance characteristics might change
> suddenly.

There is usually a good deal of clean cache.  As Dave pointed out
before, clean cache can be considered re-allocatable from NOFS
contexts, and so we'd only have to maintain this invariant:

	min_wmark + private_reserves < free_pages + clean_cache

> > Further, because it's just accounting and behavioural thresholds,
> > this allows the mm subsystem to control how the reserve pool is
> > accounted internally. e.g. clean, reclaimable pages in the page
> > cache could serve as reserve pool pages as they can be immediately
> > reclaimed for allocation.
> 
> But they also can turn into hard/impossible to reclaim as well. Clean
> pages might get dirty and e.g. swap backed pages run out of their
> backing storage. So I guess we cannot count with those pages without
> reclaiming them first and hiding them into the reserve. Which is what
> you suggest below probably but I wasn't really sure...

Pages reserved for use by the page cleaning path can't be considered
dirtyable.  They have to be included in the dirty_balance_reserve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
