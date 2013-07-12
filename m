Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 087A86B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 21:41:53 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id xa12so8440289pbc.25
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 18:41:53 -0700 (PDT)
Date: Thu, 11 Jul 2013 18:42:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
In-Reply-To: <20130711132300.GG21667@dhcp22.suse.cz>
Message-ID: <alpine.LNX.2.00.1307111741130.2448@eggly.anvils>
References: <20130701081056.GA4072@dastard> <20130702092200.GB16815@dhcp22.suse.cz> <20130702121947.GE14996@dastard> <20130702124427.GG16815@dhcp22.suse.cz> <20130703112403.GP14996@dastard> <20130704163643.GF7833@dhcp22.suse.cz> <20130708125352.GC20149@dhcp22.suse.cz>
 <20130710023138.GO3438@dastard> <20130710080605.GC4437@dhcp22.suse.cz> <20130711022634.GZ3438@dastard> <20130711132300.GG21667@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 11 Jul 2013, Michal Hocko wrote:
> On Thu 11-07-13 12:26:34, Dave Chinner wrote:
> > On Wed, Jul 10, 2013 at 10:06:05AM +0200, Michal Hocko wrote:
> > > On Wed 10-07-13 12:31:39, Dave Chinner wrote:
> > > [...]
> > > > > 20761 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
> > > > > [<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
> > > > > [<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
> > > > > [<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
> > > > > [<ffffffffa02c5999>] xfs_create+0x1a9/0x5c0 [xfs]
> > > > > [<ffffffffa02bccca>] xfs_vn_mknod+0x8a/0x1a0 [xfs]
> > > > > [<ffffffffa02bce0e>] xfs_vn_create+0xe/0x10 [xfs]
> > > > > [<ffffffff811763dd>] vfs_create+0xad/0xd0
> > > > > [<ffffffff81177e68>] lookup_open+0x1b8/0x1d0
> > > > > [<ffffffff8117815e>] do_last+0x2de/0x780
> > > > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > > > [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> > > > > [<ffffffffffffffff>] 0xffffffffffffffff
> > > > 
> > > > That's an XFS log space issue, indicating that it has run out of
> > > > space in IO the log and it is waiting for more to come free. That
> > > > requires IO completion to occur.
> > > >
> > > > > [276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > > > > [276962.652087] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > > [276962.652093] xfs-data/sda9   D ffff88001ffb9cc8     0   930      2 0x00000000
> > > > 
> > > > Oh, that's why. This is the IO completion worker...
> > > 
> > > But that task doesn't seem to be stuck anymore (at least lockup watchdog
> > > doesn't report it anymore and I have already rebooted to test with ext3
> > > :/). I am sorry if the these lockups logs were more confusing than
> > > helpful, but they happened _long_ time ago and the system obviously
> > > recovered from them. I am pasting only the traces for processes in D
> > > state here again for reference.
> > 
> > Right, there are various triggers that can get XFS out of the
> > situation - it takes something to kick the log or metadata writeback
> > and that can make space in the log free up and hence things get
> > moving again. The problem will be that once in this low memory state
> > everything in the filesystem will back up on slow memory allocation
> > and it might take minutes to clear the backlog of IO completions....
> > 
> > > 20757 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
> > > [<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
> > > [<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
> > > [<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
> > 
> > That is the stack of a process waiting for log space to come
> > available.
> > 
> > > We are wating for page under writeback but neither of the 2 paths starts
> > > in xfs code. So I do not think waiting for PageWriteback causes a
> > > deadlock here.
> > 
> > The problem is this: the page that we are waiting for IO on is in
> > the IO completion queue, but the IO compeltion requires memory
> > allocation to complete the transaction. That memory allocation is
> > causing memcg reclaim, which then waits for IO completion on another
> > page, which may or may not end up in the same IO completion queue.
> > The CMWQ can continue to process new Io completions - up to a point
> > - so slow progress will be made. In the worst case, it can deadlock.
> 
> OK, I thought something like that was going on but I just wanted to be
> sure that I didn't manage to confuse you by the lockup messages.
> > 
> > GFP_NOFS allocation is the mechanism by which filesystems are
> > supposed to be able to avoid this recursive deadlock...
> 
> Yes.
> 
> > > [...]
> > > > ... is running IO completion work and trying to commit a transaction
> > > > that is blocked in memory allocation which is waiting for IO
> > > > completion. It's disappeared up it's own fundamental orifice.
> > > > 
> > > > Ok, this has absolutely nothing to do with the LRU changes - this is
> > > > a pre-existing XFS/mm interaction problem from around 3.2. The
> > > > question is now this: how the hell do I get memory allocation to not
> > > > block waiting on IO completion here? This is already being done in
> > > > GFP_NOFS allocation context here....
> > > 
> > > Just for reference. wait_on_page_writeback is issued only for memcg
> > > reclaim because there is no other throttling mechanism to prevent from
> > > too many dirty pages on the list, thus pre-mature OOM killer. See
> > > e62e384e9d (memcg: prevent OOM with too many dirty pages) for more
> > > details. The original patch relied on may_enter_fs but that check
> > > disappeared by later changes by c3b94f44fc (memcg: further prevent OOM
> > > with too many dirty pages).
> > 
> > Aye. That's the exact code I was looking at yesterday and wondering
> > "how the hell is waiting on page writeback valid in GFP_NOFS
> > context?". It seems that memcg reclaim is intentionally ignoring
> > GFP_NOFS to avoid OOM issues.  That's a memcg implementation problem,
> > not a filesystem or LRU infrastructure problem....
> 
> Agreed and until we have a proper per memcg dirty memory throttling we
> will always be in a workaround mode. Which is sad but that is the
> reality...
> 
> I am CCing Hugh (the discussion was long and started with a different
> issue but the above should tell about the current xfs hang. It seems
> that c3b94f44fc make xfs hang).

The may_enter_fs test came and went several times as we prepared those
patches: one set of problems with it in, another set with it out.

When I made c3b94f44fc, I was not imagining that I/O completion might
have to wait on a further __GFP_IO allocation.  But I can see the sense
of what XFS is doing there: after writing the data, it wants to perform
(initiate?) a transaction; but if that happens to fail, wants to mark
the written data pages as bad before reaching the end_page_writeback.
I've toyed with reordering that, but its order does seem sensible.

I've always thought of GFP_NOFS as meaning "don't recurse into the
filesystem" (and wondered what that amounts to since direct reclaim
stopped doing filesystem writeback); but here XFS is expecting it
to include "and don't wait for PageWriteback to be cleared".

I've mused on this for a while, and haven't arrived at any conclusion;
but do have several mutterings on different kinds of solution.

Probably the easiest solution, but not necessarily the right solution,
would be for XFS to add a KM_NOIO akin to its KM_NOFS, and use KM_NOIO
instead of KM_NOFS in xfs_iomap_write_unwritten() (anywhere else?).
I'd find that more convincing if it were not so obviously designed
to match an assumption I'd once made over in mm/vmscan.c.

A harder solution, but one which I'd expect to have larger benefits,
would be to reinstate the may_enter_fs test there in shrink_page_list(),
but modify ext4 and xfs and gfs2 to use grab_cache_page_write_begin()
without needing AOP_FLAG_NOFS: I think it is very sad that major FS
page allocations are made with the limiting GFP_NOFS, and I hope there
might be an efficient way to make those page allocations outside of the
transaction, with __GFP_FS instead.

Another kind of solution: I did originally worry about your e62e384e9d
in rather the same way that akpm has, thinking a wait on return from
shrink_page_list() more appropriate than waiting on a single page
(with a hold on all the other pages of the page_list).  I did have a
patch I'd been playing with about the time you posted yours, but we
agreed to go ahead with yours unless problems showed up (I think mine
was not so pretty as yours).  Maybe I need to dust off my old
alternative now - though I've rather forgotten how to test it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
