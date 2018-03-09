Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42B246B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 17:38:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v3so2306966pfm.21
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 14:38:17 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id h10si1377009pgf.326.2018.03.09.14.38.14
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 14:38:15 -0800 (PST)
Date: Sat, 10 Mar 2018 09:38:12 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Removing GFP_NOFS
Message-ID: <20180309223812.GW7000@dastard>
References: <20180308234618.GE29073@bombadil.infradead.org>
 <20180309013535.GU7000@dastard>
 <20180309040650.GV7000@dastard>
 <e461128e-6724-3c7f-0f62-860ac4071357@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e461128e-6724-3c7f-0f62-860ac4071357@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, penguin-kernel@i-love.sakura.ne.jp

On Fri, Mar 09, 2018 at 08:48:32AM -0600, Goldwyn Rodrigues wrote:
> 
> 
> On 03/08/2018 10:06 PM, Dave Chinner wrote:
> > On Fri, Mar 09, 2018 at 12:35:35PM +1100, Dave Chinner wrote:
> >> On Thu, Mar 08, 2018 at 03:46:18PM -0800, Matthew Wilcox wrote:
> >>>
> >>> Do we have a strategy for eliminating GFP_NOFS?
> >>>
> >>> As I understand it, our intent is to mark the areas in individual
> >>> filesystems that can't be reentered with memalloc_nofs_save()/restore()
> >>> pairs.  Once they're all done, then we can replace all the GFP_NOFS
> >>> users with GFP_KERNEL.
> >>
> >> Won't be that easy, I think.  We recently came across user-reported
> >> allocation deadlocks in XFS where we were doing allocation with
> >> pages held in the writeback state that lockdep has never triggered
> >> on.
> >>
> >> https://www.spinics.net/lists/linux-xfs/msg16154.html
> >>
> >> IOWs, GFP_NOFS isn't a solid guide to where
> >> memalloc_nofs_save/restore need to cover in the filesystems because
> >> there's a surprising amount of code that isn't covered by existing
> >> lockdep annotations to warning us about un-intended recursion
> >> problems.
> >>
> >> I think we need to start with some documentation of all the generic
> >> rules for where these will need to be set, then the per-filesystem
> >> rules can be added on top of that...
> > 
> > So thinking a bit further here:
> > 
> > * page writeback state gets set and held:
> > 	->writepage should be under memalloc_nofs_save
> > 	->writepages should be under memalloc_nofs_save
> > * page cache write path is often under AOP_FLAG_NOFS
> > 	- should probably be under memalloc_nofs_save
> > * metadata writeback that uses page cache and page writeback flags
> >   should probably be under memalloc_nofs_save
> > 
> > What other generic code paths are susceptible to allocation
> > deadlocks?
> > 
> 
> AFAIU, these are callbacks into the filesystem from the mm code which
> are executed in case of low memory.

Except that many filesystems reject such attempts at writeback from
direct reclaim because they are a problem:

        /*
         * Refuse to write the page out if we are called from reclaim context.
         *
         * This avoids stack overflows when called from deeply used stacks in
         * random callers for direct reclaim or memcg reclaim.  We explicitly
         * allow reclaim from kswapd as the stack usage there is relatively low.
         *
         * This should never happen except in the case of a VM regression so
         * warn about it.
         */
        if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
                        PF_MEMALLOC))
                goto redirty;

But writback is also called on demand - the filemap_fdatawrite() and
friends interfaces. This means they can be called from anywhere in
the kernel....

> So, the calls of memory allocation
> from filesystem code are the ones that should be the one under
> memalloc_nofs_save() in order to save from recursion.

I don't think you understand the problem here - the problem is not
recursing into the writeback path - it's being in the writeback path
and doing an allocation that then triggers memory reclaim which then
recurses into the same filesystem while we hold pages in writeback
state.

i.e. the writeback path is a source of allocation deadlocks no matter
where it is called from.

> OTOH (contradicting myself here), writepages, in essence writebacks, are
> performed by per-BDI flusher threads which are kicked by the mm code in
> low memory situations, as opposed to the thread performing the allocation.
> 
> As Tetsuo pointed out, direct reclaims are the real problematic scenarios.

Sure, but I've been saying for more than 10 years we need to get rid
of direct reclaim because it's horribly inefficient when there's
lots of concurrent allocation pressure, not to mention it's full of
deadlock scenarios like this.

Really, though I'm tired of having the same arguments over and over
again about architectural problems that people just don't seem to
understand or want to fix.

> Also the shrinkers registered by filesystem code. However, there are no
> shrinkers that I know of, which allocate memory or perform locking.
> Thanks to smartly swapping into a temporary local list variable.

Go look at the XFS shrinkers that will lock inodes, dquots, buffers,
etc, run transactions, issue IO, block waiting for IO to complete,
etc.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
