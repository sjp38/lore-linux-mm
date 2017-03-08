Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67D386B03A1
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 04:36:00 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u9so9309174wme.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 01:36:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 23si3593119wrz.119.2017.03.08.01.35.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 01:35:59 -0800 (PST)
Date: Wed, 8 Mar 2017 10:35:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/4] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170308093557.GF11028@dhcp22.suse.cz>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-4-mhocko@kernel.org>
 <20170307170519.GE5281@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307170519.GE5281@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-03-17 09:05:19, Darrick J. Wong wrote:
> On Tue, Mar 07, 2017 at 04:48:42PM +0100, Michal Hocko wrote:
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
> 
> s/for ever/forever/

fixed

> 
> > +	 * request sizes.
> > +	 */
> > +	if (flags & KM_MAYFAIL)
> > +		lflags |= __GFP_RETRY_MAYFAIL;
> 
> But otherwise seems ok from a quick grep -B5 MAYFAIL through the XFS code.
> 
> (Has this been tested anywhere?)

not yet, this is more for a discussion at this stage. I plan to run it
through xfstests once we agree on the proper semantic. I have to confess
I rely on the proper KM_MAYFAIL annotations here, though.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
