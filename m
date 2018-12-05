Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66AAA6B7552
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 12:07:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m19so10185001edc.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 09:07:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19-v6si3579564ejj.140.2018.12.05.09.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 09:06:58 -0800 (PST)
Date: Wed, 5 Dec 2018 18:06:56 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] Ext4: fix deadlock on dirty pages between fault and
 writeback
Message-ID: <20181205170656.GJ30615@quack2.suse.cz>
References: <1540858969-75803-1-git-send-email-bo.liu@linux.alibaba.com>
 <20181127114249.GH16301@quack2.suse.cz>
 <20181128201122.r4sec265cnlxgj2x@US-160370MP2.local>
 <20181129085238.GD31087@quack2.suse.cz>
 <20181129120253.GR6311@dastard>
 <20181129130002.GM31087@quack2.suse.cz>
 <20181129204019.GS6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181129204019.GS6311@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Liu Bo <bo.liu@linux.alibaba.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz

Added MM people to CC since this starts to be relevant for them.

On Fri 30-11-18 07:40:19, Dave Chinner wrote:
> On Thu, Nov 29, 2018 at 02:00:02PM +0100, Jan Kara wrote:
> > On Thu 29-11-18 23:02:53, Dave Chinner wrote:
> > > On Thu, Nov 29, 2018 at 09:52:38AM +0100, Jan Kara wrote:
> > > > On Wed 28-11-18 12:11:23, Liu Bo wrote:
> > > > > On Tue, Nov 27, 2018 at 12:42:49PM +0100, Jan Kara wrote:
> > > > > > CCed fsdevel since this may be interesting to other filesystem developers
> > > > > > as well.
> > > > > > 
> > > > > > On Tue 30-10-18 08:22:49, Liu Bo wrote:
> > > > > > > mpage_prepare_extent_to_map() tries to build up a large bio to stuff down
> > > > > > > the pipe.  But if it needs to wait for a page lock, it needs to make sure
> > > > > > > and send down any pending writes so we don't deadlock with anyone who has
> > > > > > > the page lock and is waiting for writeback of things inside the bio.
> > > > > > 
> > > > > > Thanks for report! I agree the current code has a deadlock possibility you
> > > > > > describe. But I think the problem reaches a bit further than what your
> > > > > > patch fixes.  The problem is with pages that are unlocked but have
> > > > > > PageWriteback set.  Page reclaim may end up waiting for these pages and
> > > > > > thus any memory allocation with __GFP_FS set can block on these. So in our
> > > > > > current setting page writeback must not block on anything that can be held
> > > > > > while doing memory allocation with __GFP_FS set. Page lock is just one of
> > > > > > these possibilities, wait_on_page_writeback() in
> > > > > > mpage_prepare_extent_to_map() is another suspect and there mat be more. Or
> > > > > > to say it differently, if there's lock A and GFP_KERNEL allocation can
> > > > > > happen under lock A, then A cannot be taken by the writeback path. This is
> > > > > > actually pretty subtle deadlock possibility and our current lockdep
> > > > > > instrumentation isn't going to catch this.
> > > > > >
> > > > > 
> > > > > Thanks for the nice summary, it's true that a lock A held in both
> > > > > writeback path and memory reclaim can end up with deadlock.
> > > > > 
> > > > > Fortunately, by far there're only deadlock reports of page's lock bit
> > > > > and writeback bit in both ext4 and btrfs[1].  I think
> > > > > wait_on_page_writeback() would be OK as it's been protected by page
> > > > > lock.
> > > > > 
> > > > > [1]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=01d658f2ca3c85c1ffb20b306e30d16197000ce7
> > > > 
> > > > Yes, but that may just mean that the other deadlocks are just harder to
> > > > hit...
> > > > 
> > > > > > So I see two ways how to fix this properly:
> > > > > > 
> > > > > > 1) Change ext4 code to always submit the bio once we have a full page
> > > > > > prepared for writing. This may be relatively simple but has a higher CPU
> > > > > > overhead for bio allocation & freeing (actual IO won't really differ since
> > > > > > the plugging code should take care of merging the submitted bios). XFS
> > > > > > seems to be doing this.
> > > > > 
> > > > > Seems that that's the safest way to do it, but as you said there's
> > > > > some tradeoff.
> > > > > 
> > > > > (Just took a look at xfs's writepages, xfs also did the page
> > > > > collection if there're adjacent pages in xfs_add_to_ioend(), and since
> > > > > xfs_vm_writepages() is using the generic helper write_cache_pages()
> > > > > which calls lock_page() as well, it's still possible to run into the
> > > > > above kind of deadlock.)
> > > > 
> > > > Originally I thought XFS doesn't have this problem but now when I look
> > > > again, you are right that their ioend may accumulate more pages to write
> > > > and so they are prone to the same deadlock ext4 is. Added XFS list to CC.
> > > 
> > > I don't think XFS has a problem here, because the deadlock is
> > > dependent on holding a lock that writeback might take and then doing
> > > a GFP_KERNEL allocation. I don't think we do that anywhere in XFS -
> > > the only lock that is of concern here is the ip->i_ilock, and I
> > > think we always do GFP_NOFS allocations inside that lock.
> > > 
> > > As it is, this sort of lock vs reclaim inversion should be caught by
> > > lockdep - allocations and reclaim contexts are recorded by lockdep
> > > we get reports if we do lock A - alloc and then do reclaim - lock A.
> > > We've always had problems with false positives from lockdep for
> > > these situations where common XFS code can be called from GFP_KERNEL
> > > valid contexts as well as reclaim or GFP_NOFS-only contexts, but I
> > > don't recall ever seeing such a report for the writeback path....
> > 
> > I think for A == page lock, XFS may have the problem (and lockdep won't
> > notice because it does not track page locks). There are some parts of
> > kernel which do GFP_KERNEL allocations under page lock - pte_alloc_one() is
> > one such function which allocates page tables with GFP_KERNEL and gets
> > called with the faulted page locked. And I believe there are others.
> 
> Where in direct reclaim are we doing writeback to XFS?
> 
> It doesn't happen, and I've recently proposed we remove ->writepage
> support from XFS altogether so that memory reclaim never, ever
> tries to write pages to XFS filesystems, even from kswapd.

Direct reclaim will never do writeback but it may still wait for writeback
that has been started by someone else. That is enough for the deadlock to
happen. But from what you write below you seem to understand that so I just
write this comment here so that others don't get confused.

> > So direct reclaim from pte_alloc_one() can wait for writeback on page B
> > while holding lock on page A. And if B is just prepared (added to bio,
> > under writeback, unlocked) but not submitted in xfs_writepages() and we
> > block on lock_page(A), we have a deadlock.
> 
> Fundamentally, doing GFP_KERNEL allocations with a page lock
> held violates any ordering rules we might have for multiple page
> locking order. This is asking for random ABBA reclaim deadlocks to
> occur, and it's not a filesystem bug - that's a bug in the page
> table code. e.g if we are doing this in a filesystem/page cache
> context, it's always in ascending page->index order for pages
> referenced by the inode's mapping. Memory reclaim provides none of
> these lock ordering guarantees.

So this is where I'd like MM people to tell their opinion. Reclaim code
tries to avoid possible deadlocks on page lock by always doing trylock on
the page. But as this example shows it is not enough once is blocks in
wait_on_page_writeback().

> Indeed, pte_alloc_one() doing hard coded GFP_KERNEL allocations is a
> problem we've repeatedly tried to get fixed over the past 15 years
> because of the need to call vmalloc in GFP_NOFS contexts. What we've
> got now is just a "blessed hack" of using task based NOFS context
> via memalloc_nofs_save() to override the hard coded pte allocation
> context.
> 
> But that doesn't work with calls direct from page faults - it has no
> idea filesystems or page locking orders for multiple page locking.
> Using GFP_KERNEL while holding a page lock is a bug. Fix the damn
> bug, not force everyone else who is doing things safely and
> correctly to change their code.

I'm fine with banning GFP_KERNEL allocations from under page lock. Life
will be certainly easier for filesystems ... but harder for memory reclaim
so let's see what other people think about this.

> > Generally deadlocks like these will be invisible to lockdep because it does
> > not track either PageWriteback or PageLocked as a dependency.
> 
> And, because lockdep doesn't report it, it's not a bug that needs
> fixing, eh?

The bug definitely needs fixing IMO. Real user hit it after all...

> > > If we switch away which holding a partially built bio, the only page
> > > we have locked is the one we are currently trying to add to the bio.
> > > Lock ordering prevents deadlocks on that one page, and all other
> > > pages in the bio being built are marked as under writeback and are
> > > not locked. Hence anything that wants to modify a page held in the
> > > bio will block waiting for page writeback to clear, not the page
> > > lock.
> > 
> > Yes, and the blocking on writeback of such page in direct reclaim is
> > exactly one link in the deadlock chain...
> 
> So, like preventing explicit writeback in direct reclaim, we either
> need to prevent direct reclaim from waiting on writeback or use
> GFP_NOFS allocation context when holding a page lock. The bug is not
> in the filesystem code here.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
