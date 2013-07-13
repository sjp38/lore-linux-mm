Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C7F266B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 23:29:05 -0400 (EDT)
Date: Sat, 13 Jul 2013 13:29:00 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130713032900.GC5228@dastard>
References: <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
 <20130708125352.GC20149@dhcp22.suse.cz>
 <20130710023138.GO3438@dastard>
 <20130710080605.GC4437@dhcp22.suse.cz>
 <20130711022634.GZ3438@dastard>
 <20130711132300.GG21667@dhcp22.suse.cz>
 <alpine.LNX.2.00.1307111741130.2448@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1307111741130.2448@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 06:42:03PM -0700, Hugh Dickins wrote:
> On Thu, 11 Jul 2013, Michal Hocko wrote:
> > On Thu 11-07-13 12:26:34, Dave Chinner wrote:
> > > > We are wating for page under writeback but neither of the 2 paths starts
> > > > in xfs code. So I do not think waiting for PageWriteback causes a
> > > > deadlock here.
> > > 
> > > The problem is this: the page that we are waiting for IO on is in
> > > the IO completion queue, but the IO compeltion requires memory
> > > allocation to complete the transaction. That memory allocation is
> > > causing memcg reclaim, which then waits for IO completion on another
> > > page, which may or may not end up in the same IO completion queue.
> > > The CMWQ can continue to process new Io completions - up to a point
> > > - so slow progress will be made. In the worst case, it can deadlock.
> > 
> > OK, I thought something like that was going on but I just wanted to be
> > sure that I didn't manage to confuse you by the lockup messages.
> > > 
> > > GFP_NOFS allocation is the mechanism by which filesystems are
> > > supposed to be able to avoid this recursive deadlock...
> > 
> > Yes.
> > 
> > > > [...]
> > > > > ... is running IO completion work and trying to commit a transaction
> > > > > that is blocked in memory allocation which is waiting for IO
> > > > > completion. It's disappeared up it's own fundamental orifice.
> > > > > 
> > > > > Ok, this has absolutely nothing to do with the LRU changes - this is
> > > > > a pre-existing XFS/mm interaction problem from around 3.2. The
> > > > > question is now this: how the hell do I get memory allocation to not
> > > > > block waiting on IO completion here? This is already being done in
> > > > > GFP_NOFS allocation context here....
> > > > 
> > > > Just for reference. wait_on_page_writeback is issued only for memcg
> > > > reclaim because there is no other throttling mechanism to prevent from
> > > > too many dirty pages on the list, thus pre-mature OOM killer. See
> > > > e62e384e9d (memcg: prevent OOM with too many dirty pages) for more
> > > > details. The original patch relied on may_enter_fs but that check
> > > > disappeared by later changes by c3b94f44fc (memcg: further prevent OOM
> > > > with too many dirty pages).
> > > 
> > > Aye. That's the exact code I was looking at yesterday and wondering
> > > "how the hell is waiting on page writeback valid in GFP_NOFS
> > > context?". It seems that memcg reclaim is intentionally ignoring
> > > GFP_NOFS to avoid OOM issues.  That's a memcg implementation problem,
> > > not a filesystem or LRU infrastructure problem....
> > 
> > Agreed and until we have a proper per memcg dirty memory throttling we
> > will always be in a workaround mode. Which is sad but that is the
> > reality...
> > 
> > I am CCing Hugh (the discussion was long and started with a different
> > issue but the above should tell about the current xfs hang. It seems
> > that c3b94f44fc make xfs hang).
> 
> The may_enter_fs test came and went several times as we prepared those
> patches: one set of problems with it in, another set with it out.
> 
> When I made c3b94f44fc, I was not imagining that I/O completion might
> have to wait on a further __GFP_IO allocation.  But I can see the sense
> of what XFS is doing there: after writing the data, it wants to perform
> (initiate?) a transaction; but if that happens to fail, wants to mark
> the written data pages as bad before reaching the end_page_writeback.
> I've toyed with reordering that, but its order does seem sensible.
> 
> I've always thought of GFP_NOFS as meaning "don't recurse into the
> filesystem" (and wondered what that amounts to since direct reclaim
> stopped doing filesystem writeback); but here XFS is expecting it
> to include "and don't wait for PageWriteback to be cleared".

Well, it's more general than that - my understanding of GFP_NOFS is
that it means "don't block reclaim on anything filesystem related
because a filesystem deadlock is possible from this calling
content". Even without direct reclaim doing writeback, there is
still shrinkers that need to avoid locking filesystem objects during
direct reclaim, and the fact that waiting on writeback for specific
pages to complete may (indirectly) block a memory allocation
required to complete the writeback of that page. It's the latter
case that is the problem here...

> I've mused on this for a while, and haven't arrived at any conclusion;
> but do have several mutterings on different kinds of solution.
> 
> Probably the easiest solution, but not necessarily the right solution,
> would be for XFS to add a KM_NOIO akin to its KM_NOFS, and use KM_NOIO
> instead of KM_NOFS in xfs_iomap_write_unwritten() (anywhere else?).
> I'd find that more convincing if it were not so obviously designed
> to match an assumption I'd once made over in mm/vmscan.c.

I'd prefer not to have to start using KM_NOIO in specific places in
the filesystem layer. I can see how it may be relevant, though,
because we are in the IO completion path here, and so -technically-
we are dealing with IO layer interactions here. Hmmm - it looks like
there is already a task flag to tell memory allocation we are in IO
context without needing to pass GFP_IO: PF_MEMALLOC_NOIO.

[ As an idle thought, if we drove PF_FSTRANS into the memory
allocation to clear __GFP_FS like PF_MEMALLOC_NOIO clears __GFP_IO,
we could probably get rid of a large amount of the XFS specific
memory allocation wrappers. Hmmm, it would solve all the "we
need to do GFP_NOFS for vmalloc()" problems we have as well, which
is what DM uses PF_MEMALLOC_NOIO for.... ]

> A harder solution, but one which I'd expect to have larger benefits,
> would be to reinstate the may_enter_fs test there in shrink_page_list(),
> but modify ext4 and xfs and gfs2 to use grab_cache_page_write_begin()
> without needing AOP_FLAG_NOFS: I think it is very sad that major FS
> page allocations are made with the limiting GFP_NOFS, and I hope there
> might be an efficient way to make those page allocations outside of the
> transaction, with __GFP_FS instead.

I don't think that helps the AOP_FLAG_NOFS case - even if we aren't
in a transaction context, we're still holding (multiple) filesystem
locks when doing memory allocation...

> Another kind of solution: I did originally worry about your e62e384e9d
> in rather the same way that akpm has, thinking a wait on return from
> shrink_page_list() more appropriate than waiting on a single page
> (with a hold on all the other pages of the page_list).  I did have a
> patch I'd been playing with about the time you posted yours, but we
> agreed to go ahead with yours unless problems showed up (I think mine
> was not so pretty as yours).  Maybe I need to dust off my old
> alternative now - though I've rather forgotten how to test it.

I think that a congestion_wait()-styleange (as Andrew suggested) is
a workable interim solution but I suspect - like Michal - that we
need proper memcg awareness in balance_dirty_pages() to really solve
this problem fully....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
