Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99ED76B0389
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 07:54:34 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v66so10399966wrc.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 04:54:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si4244178wra.223.2017.03.08.04.54.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 04:54:33 -0800 (PST)
Date: Wed, 8 Mar 2017 13:54:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/4] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170308125431.GI11028@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-4-mhocko@kernel.org>
 <e7f932bf-313a-917d-6304-81528aca5994@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7f932bf-313a-917d-6304-81528aca5994@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>

On Wed 08-03-17 20:23:37, Tetsuo Handa wrote:
> On 2017/03/08 0:48, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
> > so it relied on the default page allocator behavior for the given set
> > of flags. This means that small allocations actually never failed.
> > 
> > Now that we have __GFP_RETRY_MAYFAIL flag which works independently on the
> > allocation request size we can map KM_MAYFAIL to it. The allocator will
> > try as hard as it can to fulfill the request but fails eventually if
> > the progress cannot be made.
> > 
> > Cc: Darrick J. Wong <darrick.wong@oracle.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  fs/xfs/kmem.h | 10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> > index ae08cfd9552a..ac80a4855c83 100644
> > --- a/fs/xfs/kmem.h
> > +++ b/fs/xfs/kmem.h
> > @@ -54,6 +54,16 @@ kmem_flags_convert(xfs_km_flags_t flags)
> >  			lflags &= ~__GFP_FS;
> >  	}
> >  
> > +	/*
> > +	 * Default page/slab allocator behavior is to retry for ever
> > +	 * for small allocations. We can override this behavior by using
> > +	 * __GFP_RETRY_MAYFAIL which will tell the allocator to retry as long
> > +	 * as it is feasible but rather fail than retry for ever for all
> > +	 * request sizes.
> > +	 */
> > +	if (flags & KM_MAYFAIL)
> > +		lflags |= __GFP_RETRY_MAYFAIL;
> 
> I don't see advantages of supporting both __GFP_NORETRY and __GFP_RETRY_MAYFAIL.
> kmem_flags_convert() can always set __GFP_NORETRY because the callers use
> opencoded __GFP_NOFAIL loop (with possible allocation lockup warning) unless
> KM_MAYFAIL is set.

The behavior would be different (e.g. the OOM killer handling).

[...]
> line, which is likely always true); but this is off-topic for this thread.

yes

[...]

> where both __GFP_NORETRY and __GFP_RETRY_MAYFAIL are checked after
> direct reclaim and compaction failed. __GFP_RETRY_MAYFAIL optimistically
> retries based on one of should_reclaim_retry() or should_compact_retry()
> or read_mems_allowed_retry() returns true or mutex_trylock(&oom_lock) in
> __alloc_pages_may_oom() returns 0. If !__GFP_FS allocation requests are
> holding oom_lock each other, __GFP_RETRY_MAYFAIL allocation requests (which
> are likely !__GFP_FS allocation requests due to __GFP_FS allocation requests
> being blocked on direct reclaim) can be blocked for uncontrollable duration
> without making progress. It seems to me that the difference between
> __GFP_NORETRY and __GFP_RETRY_MAYFAIL is not useful. Rather, the caller can
> set __GFP_NORETRY and retry with any control (e.g. set __GFP_HIGH upon first
> timeout, give up upon second timeout).

You are drown in implementation details here. Try to step back and think
about the high level semantic I would like to achieve - which is
essentially a middle ground between __GFP_NORETRY which doesn't retry
and __GFP_NOFAIL to retry for ever. There are users who could benefit
from such a semantic I believe (the most prominent example is kvmalloc
which has different modes of how hard to try kmalloc before giving up
and falling back to vmalloc)..

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
