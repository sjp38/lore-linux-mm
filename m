Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7877E6B0032
	for <linux-mm@kvack.org>; Sun, 30 Jun 2013 21:26:18 -0400 (EDT)
Date: Mon, 1 Jul 2013 11:25:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130701012558.GB27780@dastard>
References: <20130618063104.GB20528@localhost.localdomain>
 <20130618082414.GC13677@dhcp22.suse.cz>
 <20130618104443.GH13677@dhcp22.suse.cz>
 <20130618135025.GK13677@dhcp22.suse.cz>
 <20130625022754.GP29376@dastard>
 <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
 <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130630183349.GA23731@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sun, Jun 30, 2013 at 08:33:49PM +0200, Michal Hocko wrote:
> On Sat 29-06-13 12:55:09, Dave Chinner wrote:
> > On Thu, Jun 27, 2013 at 04:54:11PM +0200, Michal Hocko wrote:
> > > On Thu 27-06-13 09:24:26, Dave Chinner wrote:
> > > > On Wed, Jun 26, 2013 at 10:15:09AM +0200, Michal Hocko wrote:
> > > > > On Tue 25-06-13 12:27:54, Dave Chinner wrote:
> > > > > > On Tue, Jun 18, 2013 at 03:50:25PM +0200, Michal Hocko wrote:
> > > > > > > And again, another hang. It looks like the inode deletion never
> > > > > > > finishes. The good thing is that I do not see any LRU related BUG_ONs
> > > > > > > anymore. I am going to test with the other patch in the thread.
> > > > > > > 
> > > > > > > 2476 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0	<<< waiting for an inode to go away
> > > > > > > [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> > > > > > > [<ffffffff8118525f>] iget_locked+0x4f/0x180
> > > > > > > [<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
> > > > > > > [<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
> > > > > > > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > > > > > > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > > > > > > [<ffffffff8117815e>] do_last+0x2de/0x780			<<< holds i_mutex
> > > > > > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > > > > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > > > > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > > > > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > > > > > [<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
> > > > > > > [<ffffffffffffffff>] 0xffffffffffffffff

.....
> Do you mean sysrq+t? It is attached. 
> 
> Btw. I was able to reproduce this again. The stuck processes were
> sitting in the same traces for more than 28 hours without any change so
> I do not think this is a temporal condition.
> 
> Traces of all processes in the D state:
> 7561 [<ffffffffa029c03e>] xfs_iget+0xbe/0x190 [xfs]
> [<ffffffffa02a8e98>] xfs_lookup+0xe8/0x110 [xfs]
> [<ffffffffa029fad9>] xfs_vn_lookup+0x49/0x90 [xfs]
> [<ffffffff81174ad0>] lookup_real+0x20/0x60
> [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> [<ffffffff8117815e>] do_last+0x2de/0x780
> [<ffffffff8117ae9a>] path_openat+0xda/0x400
> [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> [<ffffffff81168f9c>] sys_open+0x1c/0x20
> [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff

This looks like it may be equivalent to the ext4 trace above, though
I'm not totally sure on that yet. Can you get me the line of code
where the above code is sleeping - 'gdb> l *(xfs_iget+0xbe)' output
is sufficient.

If it's where I suspect it is, we are hitting a VFS inode that
igrab() is failing on because I_FREEING is set and that is returning
EAGAIN. Hence xfs_iget() sleeps for a short period and retries the
lookup. If you've still got a system in this state, can you dump the
xfs stats a few times about 5s apart i.e.

$ for i in `seq 0 1 5`; do echo ; date; cat /proc/fs/xfs/stat ; sleep 5 ; done

Depending on what stat is changing (i'm looking for skip vs recycle
in the inode cache stats), that will tell us why the lookup is
failing...

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
