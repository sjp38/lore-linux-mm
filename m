Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 1CE816B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 04:11:02 -0400 (EDT)
Date: Mon, 1 Jul 2013 18:10:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130701081056.GA4072@dastard>
References: <20130618104443.GH13677@dhcp22.suse.cz>
 <20130618135025.GK13677@dhcp22.suse.cz>
 <20130625022754.GP29376@dastard>
 <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
 <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130701075005.GA28765@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 01, 2013 at 09:50:05AM +0200, Michal Hocko wrote:
> On Mon 01-07-13 11:25:58, Dave Chinner wrote:
> > On Sun, Jun 30, 2013 at 08:33:49PM +0200, Michal Hocko wrote:
> > > On Sat 29-06-13 12:55:09, Dave Chinner wrote:
> > > > On Thu, Jun 27, 2013 at 04:54:11PM +0200, Michal Hocko wrote:
> > > > > On Thu 27-06-13 09:24:26, Dave Chinner wrote:
> > > > > > On Wed, Jun 26, 2013 at 10:15:09AM +0200, Michal Hocko wrote:
> > > > > > > On Tue 25-06-13 12:27:54, Dave Chinner wrote:
> > > > > > > > On Tue, Jun 18, 2013 at 03:50:25PM +0200, Michal Hocko wrote:
> > > > > > > > > And again, another hang. It looks like the inode deletion never
> > > > > > > > > finishes. The good thing is that I do not see any LRU related BUG_ONs
> > > > > > > > > anymore. I am going to test with the other patch in the thread.
> > > > > > > > > 
> > > > > > > > > 2476 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0	<<< waiting for an inode to go away
> > > > > > > > > [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> > > > > > > > > [<ffffffff8118525f>] iget_locked+0x4f/0x180
> > > > > > > > > [<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
> > > > > > > > > [<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
> > > > > > > > > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > > > > > > > > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > > > > > > > > [<ffffffff8117815e>] do_last+0x2de/0x780			<<< holds i_mutex
> > > > > > > > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > > > > > > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > > > > > > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > > > > > > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > > > > > > > [<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
> > > > > > > > > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > .....
> > > Do you mean sysrq+t? It is attached. 
> > > 
> > > Btw. I was able to reproduce this again. The stuck processes were
> > > sitting in the same traces for more than 28 hours without any change so
> > > I do not think this is a temporal condition.
> > > 
> > > Traces of all processes in the D state:
> > > 7561 [<ffffffffa029c03e>] xfs_iget+0xbe/0x190 [xfs]
> > > [<ffffffffa02a8e98>] xfs_lookup+0xe8/0x110 [xfs]
> > > [<ffffffffa029fad9>] xfs_vn_lookup+0x49/0x90 [xfs]
> > > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > > [<ffffffff8117815e>] do_last+0x2de/0x780
> > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > This looks like it may be equivalent to the ext4 trace above, though
> > I'm not totally sure on that yet. Can you get me the line of code
> > where the above code is sleeping - 'gdb> l *(xfs_iget+0xbe)' output
> > is sufficient.
> 
> OK, this is a bit tricky because I have xfs built as a module so objdump
> on xfs.ko shows nonsense
>    19039:       e8 00 00 00 00          callq  1903e <xfs_iget+0xbe>
>    1903e:       48 8b 75 c0             mov    -0x40(%rbp),%rsi
> 
> crash was more clever though and it says:
> 0xffffffffa029c034 <xfs_iget+180>:      mov    $0x1,%edi
> 0xffffffffa029c039 <xfs_iget+185>:      callq  0xffffffff815776d0
> <schedule_timeout_uninterruptible>
> /dev/shm/mhocko-build/BUILD/kernel-3.9.0mmotm+/fs/xfs/xfs_icache.c: 423
> 0xffffffffa029c03e <xfs_iget+190>:      mov    -0x40(%rbp),%rsi
> 
> which maps to:
> out_error_or_again:
>         if (error == EAGAIN) {
>                 delay(1);
>                 goto again;
>         }
> 
> So this looks like this path loops in goto again and out_error_or_again.

Yup, that's what I suspected.

> > If it's where I suspect it is, we are hitting a VFS inode that
> > igrab() is failing on because I_FREEING is set and that is returning
> > EAGAIN. Hence xfs_iget() sleeps for a short period and retries the
> > lookup. If you've still got a system in this state, can you dump the
> > xfs stats a few times about 5s apart i.e.
> > 
> > $ for i in `seq 0 1 5`; do echo ; date; cat /proc/fs/xfs/stat ; sleep 5 ; done
> > 
> > Depending on what stat is changing (i'm looking for skip vs recycle
> > in the inode cache stats), that will tell us why the lookup is
> > failing...
> 
> $ for i in `seq 0 1 5`; do echo ; date; cat /proc/fs/xfs/stat ; sleep 5 ; done
> 
> Mon Jul  1 09:29:57 CEST 2013
> extent_alloc 1484333 2038118 1678 13182
> abt 0 0 0 0
> blk_map 21004635 3433178 1450438 1461372 1450017 25888309 0
> bmbt 0 0 0 0
> dir 1482235 1466711 7281 2529
> trans 7676 6231535 1444850
> ig 0 8534 299 1463749 0 1256778 262381
            ^^^

That is the recycle stat, which indicates we've found an inode being
reclaimed. When it's found an inode that have been evicted, but not
yet reclaimed at the XFS level, that stat will increase. If the
inode is still valid at the VFS level, and igrab() fails, then we'll
get EAGAIN without that stat being increased. So, igrab() is
failing, and that means I_FREEING|I_WILL_FREE are set.

So, it looks to be the same case as the ext4 hang, and it's likely
that we have some dangling inode dispose list somewhere. So, here's
the fun part. Use tracing to grab the inode number that is stuck
(tracepoint xfs::xfs_iget_skip), and then run crash on the live
kernel on the process that is looping, and find the struct xfs_inode
and print it.  Use the inode number from the trace point to check
you've got the right inode.

Th struct inode of the VFS inode is embedded into the struct
xfs_inode, and the dispose list that it is on should be the on the
inode->i_lru_list. What that, and see how many other inodes are on
that list. Once we know if it's a single inode, and whether the
dispose list it is on is intact, empty or corrupt, we might have a
better idea of how these inodes are getting lost....

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
