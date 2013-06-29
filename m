Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 48BA26B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 22:55:24 -0400 (EDT)
Date: Sat, 29 Jun 2013 12:55:09 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130629025509.GG9047@dastard>
References: <20130617223004.GB2538@localhost.localdomain>
 <20130618024623.GP29338@dastard>
 <20130618063104.GB20528@localhost.localdomain>
 <20130618082414.GC13677@dhcp22.suse.cz>
 <20130618104443.GH13677@dhcp22.suse.cz>
 <20130618135025.GK13677@dhcp22.suse.cz>
 <20130625022754.GP29376@dastard>
 <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130627145411.GA24206@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 27, 2013 at 04:54:11PM +0200, Michal Hocko wrote:
> On Thu 27-06-13 09:24:26, Dave Chinner wrote:
> > On Wed, Jun 26, 2013 at 10:15:09AM +0200, Michal Hocko wrote:
> > > On Tue 25-06-13 12:27:54, Dave Chinner wrote:
> > > > On Tue, Jun 18, 2013 at 03:50:25PM +0200, Michal Hocko wrote:
> > > > > And again, another hang. It looks like the inode deletion never
> > > > > finishes. The good thing is that I do not see any LRU related BUG_ONs
> > > > > anymore. I am going to test with the other patch in the thread.
> > > > > 
> > > > > 2476 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0	<<< waiting for an inode to go away
> > > > > [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> > > > > [<ffffffff8118525f>] iget_locked+0x4f/0x180
> > > > > [<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
> > > > > [<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
> > > > > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > > > > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > > > > [<ffffffff8117815e>] do_last+0x2de/0x780			<<< holds i_mutex
> > > > > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > > > > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > > > > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > > > > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > > > > [<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
> > > > > [<ffffffffffffffff>] 0xffffffffffffffff
> > > > 
> > > > I don't think this has anything to do with LRUs.
> > > 
> > > I am not claiming that. It might be a timing issue which never mattered
> > > but it is strange I can reproduce this so easily and repeatedly with the
> > > shrinkers patchset applied.
> > > As I said earlier, this might be breakage in my -mm tree as well
> > > (missing some patch which didn't go via Andrew or misapplied patch). The
> > > situation is worsen by the state of linux-next which has some unrelated
> > > issues.
> > > 
> > > I really do not want to delay the whole patchset just because of some
> > > problem on my side. Do you have any tree that I should try to test?
> > 
> > No, I've just been testing Glauber's tree and sending patches for
> > problems back to him based on it.
> > 
> > > > I won't have seen this on XFS stress testing, because it doesn't use
> > > > the VFS inode hashes for inode lookups. Given that XFS is not
> > > > triggering either problem you are seeing, that makes me think
> > > 
> > > I haven't tested with xfs.
> > 
> > That might be worthwhile if you can easily do that - another data
> > point indicating a hang or absence of a hang will help point us in
> > the right direction here...
> 
> OK, still hanging (with inode_lru_isolate-fix.patch). It is not the same
> thing, though, as xfs seem to do lookup slightly differently.
> 12467 [<ffffffffa02ca03e>] xfs_iget+0xbe/0x190 [xfs]
> [<ffffffffa02d6e98>] xfs_lookup+0xe8/0x110 [xfs]
> [<ffffffffa02cdad9>] xfs_vn_lookup+0x49/0x90 [xfs]
> [<ffffffff81174ad0>] lookup_real+0x20/0x60
> [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> [<ffffffff8117815e>] do_last+0x2de/0x780
> [<ffffffff8117ae9a>] path_openat+0xda/0x400
> [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> [<ffffffff81168f9c>] sys_open+0x1c/0x20
> [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff

What are the full traces? This could be blocking on IO or locks
here if it's a cache miss and we are reading an inode....

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
