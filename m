Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id DA3EA6B0034
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 09:23:03 -0400 (EDT)
Date: Thu, 11 Jul 2013 15:23:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130711132300.GG21667@dhcp22.suse.cz>
References: <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
 <20130708125352.GC20149@dhcp22.suse.cz>
 <20130710023138.GO3438@dastard>
 <20130710080605.GC4437@dhcp22.suse.cz>
 <20130711022634.GZ3438@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130711022634.GZ3438@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Thu 11-07-13 12:26:34, Dave Chinner wrote:
> On Wed, Jul 10, 2013 at 10:06:05AM +0200, Michal Hocko wrote:
> > On Wed 10-07-13 12:31:39, Dave Chinner wrote:
> > [...]
> > > > 20761 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
> > > > [<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
> > > > [<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
> > > > [<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
> > > > [<ffffffffa02c5999>] xfs_create+0x1a9/0x5c0 [xfs]
> > > > [<ffffffffa02bccca>] xfs_vn_mknod+0x8a/0x1a0 [xfs]
> > > > [<ffffffffa02bce0e>] xfs_vn_create+0xe/0x10 [xfs]
> > > > [<ffffffff811763dd>] vfs_create+0xad/0xd0
> > > > [<ffffffff81177e68>] lookup_open+0x1b8/0x1d0
> > > > [<ffffffff8117815e>] do_last+0x2de/0x780
> > > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > > [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> > > > [<ffffffffffffffff>] 0xffffffffffffffff
> > > 
> > > That's an XFS log space issue, indicating that it has run out of
> > > space in IO the log and it is waiting for more to come free. That
> > > requires IO completion to occur.
> > >
> > > > [276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > > > [276962.652087] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > [276962.652093] xfs-data/sda9   D ffff88001ffb9cc8     0   930      2 0x00000000
> > > 
> > > Oh, that's why. This is the IO completion worker...
> > 
> > But that task doesn't seem to be stuck anymore (at least lockup watchdog
> > doesn't report it anymore and I have already rebooted to test with ext3
> > :/). I am sorry if the these lockups logs were more confusing than
> > helpful, but they happened _long_ time ago and the system obviously
> > recovered from them. I am pasting only the traces for processes in D
> > state here again for reference.
> 
> Right, there are various triggers that can get XFS out of the
> situation - it takes something to kick the log or metadata writeback
> and that can make space in the log free up and hence things get
> moving again. The problem will be that once in this low memory state
> everything in the filesystem will back up on slow memory allocation
> and it might take minutes to clear the backlog of IO completions....
> 
> > 20757 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
> > [<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
> > [<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
> > [<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
> 
> That is the stack of a process waiting for log space to come
> available.
> 
> > We are wating for page under writeback but neither of the 2 paths starts
> > in xfs code. So I do not think waiting for PageWriteback causes a
> > deadlock here.
> 
> The problem is this: the page that we are waiting for IO on is in
> the IO completion queue, but the IO compeltion requires memory
> allocation to complete the transaction. That memory allocation is
> causing memcg reclaim, which then waits for IO completion on another
> page, which may or may not end up in the same IO completion queue.
> The CMWQ can continue to process new Io completions - up to a point
> - so slow progress will be made. In the worst case, it can deadlock.

OK, I thought something like that was going on but I just wanted to be
sure that I didn't manage to confuse you by the lockup messages.
> 
> GFP_NOFS allocation is the mechanism by which filesystems are
> supposed to be able to avoid this recursive deadlock...

Yes.

> > [...]
> > > ... is running IO completion work and trying to commit a transaction
> > > that is blocked in memory allocation which is waiting for IO
> > > completion. It's disappeared up it's own fundamental orifice.
> > > 
> > > Ok, this has absolutely nothing to do with the LRU changes - this is
> > > a pre-existing XFS/mm interaction problem from around 3.2. The
> > > question is now this: how the hell do I get memory allocation to not
> > > block waiting on IO completion here? This is already being done in
> > > GFP_NOFS allocation context here....
> > 
> > Just for reference. wait_on_page_writeback is issued only for memcg
> > reclaim because there is no other throttling mechanism to prevent from
> > too many dirty pages on the list, thus pre-mature OOM killer. See
> > e62e384e9d (memcg: prevent OOM with too many dirty pages) for more
> > details. The original patch relied on may_enter_fs but that check
> > disappeared by later changes by c3b94f44fc (memcg: further prevent OOM
> > with too many dirty pages).
> 
> Aye. That's the exact code I was looking at yesterday and wondering
> "how the hell is waiting on page writeback valid in GFP_NOFS
> context?". It seems that memcg reclaim is intentionally ignoring
> GFP_NOFS to avoid OOM issues.  That's a memcg implementation problem,
> not a filesystem or LRU infrastructure problem....

Agreed and until we have a proper per memcg dirty memory throttling we
will always be in a workaround mode. Which is sad but that is the
reality...

I am CCing Hugh (the discussion was long and started with a different
issue but the above should tell about the current xfs hang. It seems
that c3b94f44fc make xfs hang).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
