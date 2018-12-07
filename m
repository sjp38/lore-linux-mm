Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0CD76B7E78
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 00:20:56 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so1918641ply.4
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 21:20:56 -0800 (PST)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id h19si2028513pgb.231.2018.12.06.21.20.54
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 21:20:55 -0800 (PST)
Date: Fri, 7 Dec 2018 16:20:51 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] Ext4: fix deadlock on dirty pages between fault and
 writeback
Message-ID: <20181207052051.GB6311@dastard>
References: <1540858969-75803-1-git-send-email-bo.liu@linux.alibaba.com>
 <20181127114249.GH16301@quack2.suse.cz>
 <20181128201122.r4sec265cnlxgj2x@US-160370MP2.local>
 <20181129085238.GD31087@quack2.suse.cz>
 <20181129120253.GR6311@dastard>
 <20181129130002.GM31087@quack2.suse.cz>
 <20181129204019.GS6311@dastard>
 <20181205170656.GJ30615@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205170656.GJ30615@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Liu Bo <bo.liu@linux.alibaba.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz

On Wed, Dec 05, 2018 at 06:06:56PM +0100, Jan Kara wrote:
> Added MM people to CC since this starts to be relevant for them.
> 
> On Fri 30-11-18 07:40:19, Dave Chinner wrote:
> > On Thu, Nov 29, 2018 at 02:00:02PM +0100, Jan Kara wrote:
> > > On Thu 29-11-18 23:02:53, Dave Chinner wrote:
> > > > As it is, this sort of lock vs reclaim inversion should be caught by
> > > > lockdep - allocations and reclaim contexts are recorded by lockdep
> > > > we get reports if we do lock A - alloc and then do reclaim - lock A.
> > > > We've always had problems with false positives from lockdep for
> > > > these situations where common XFS code can be called from GFP_KERNEL
> > > > valid contexts as well as reclaim or GFP_NOFS-only contexts, but I
> > > > don't recall ever seeing such a report for the writeback path....
> > > 
> > > I think for A == page lock, XFS may have the problem (and lockdep won't
> > > notice because it does not track page locks). There are some parts of
> > > kernel which do GFP_KERNEL allocations under page lock - pte_alloc_one() is
> > > one such function which allocates page tables with GFP_KERNEL and gets
> > > called with the faulted page locked. And I believe there are others.
> > 
> > Where in direct reclaim are we doing writeback to XFS?
> > 
> > It doesn't happen, and I've recently proposed we remove ->writepage
> > support from XFS altogether so that memory reclaim never, ever
> > tries to write pages to XFS filesystems, even from kswapd.
> 
> Direct reclaim will never do writeback but it may still wait for writeback
> that has been started by someone else. That is enough for the deadlock to
> happen. But from what you write below you seem to understand that so I just
> write this comment here so that others don't get confused.
> 
> > > So direct reclaim from pte_alloc_one() can wait for writeback on page B
> > > while holding lock on page A. And if B is just prepared (added to bio,
> > > under writeback, unlocked) but not submitted in xfs_writepages() and we
> > > block on lock_page(A), we have a deadlock.
> > 
> > Fundamentally, doing GFP_KERNEL allocations with a page lock
> > held violates any ordering rules we might have for multiple page
> > locking order. This is asking for random ABBA reclaim deadlocks to
> > occur, and it's not a filesystem bug - that's a bug in the page
> > table code. e.g if we are doing this in a filesystem/page cache
> > context, it's always in ascending page->index order for pages
> > referenced by the inode's mapping. Memory reclaim provides none of
> > these lock ordering guarantees.
> 
> So this is where I'd like MM people to tell their opinion. Reclaim code
> tries to avoid possible deadlocks on page lock by always doing trylock on
> the page. But as this example shows it is not enough once is blocks in
> wait_on_page_writeback().

I think it only does this in a "legacy memcg" case, according to the
comment in shrink_page_list. Which is, apparently, a hack around the
fact that memcgs didn't used to have dirty page throttling. AFAIA,
balance_dirty_pages() has had memcg-based throttling for some time
now, so that kinda points to stale reclaim algorithms, right?

> > > Generally deadlocks like these will be invisible to lockdep because it does
> > > not track either PageWriteback or PageLocked as a dependency.
> > 
> > And, because lockdep doesn't report it, it's not a bug that needs
> > fixing, eh?
> 
> The bug definitely needs fixing IMO. Real user hit it after all...

Sorry, I left off the <sarcasm> tag. I'm so used to people ignoring
locking problems until someone adds a lockdep tag to catch that
case....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
