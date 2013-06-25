Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 8748F6B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 22:28:01 -0400 (EDT)
Date: Tue, 25 Jun 2013 12:27:54 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130625022754.GP29376@dastard>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618024623.GP29338@dastard>
 <20130618063104.GB20528@localhost.localdomain>
 <20130618082414.GC13677@dhcp22.suse.cz>
 <20130618104443.GH13677@dhcp22.suse.cz>
 <20130618135025.GK13677@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130618135025.GK13677@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 18, 2013 at 03:50:25PM +0200, Michal Hocko wrote:
> And again, another hang. It looks like the inode deletion never
> finishes. The good thing is that I do not see any LRU related BUG_ONs
> anymore. I am going to test with the other patch in the thread.
> 
> 2476 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0	<<< waiting for an inode to go away
> [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> [<ffffffff8118525f>] iget_locked+0x4f/0x180
> [<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
> [<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
> [<ffffffff81174ad0>] lookup_real+0x20/0x60
> [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> [<ffffffff8117815e>] do_last+0x2de/0x780			<<< holds i_mutex
> [<ffffffff8117ae9a>] path_openat+0xda/0x400
> [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> [<ffffffff81168f9c>] sys_open+0x1c/0x20
> [<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff

I don't think this has anything to do with LRUs.

__wait_on_freeing_inode() only blocks once the inode is being freed
(i.e. I_FREEING is set), and that happens when a lookup is done when
the inode is still in the inode hash.

I_FREEING is set on the inode at the same time it is removed from
the LRU, and from that point onwards the LRUs play no part in the
inode being freed and anyone waiting on the inode being freed
getting woken.

The only way I can see this happening, is if there is a dispose list
that is not getting processed properly. e.g., we move a bunch on
inodes to the dispose list setting I_FREEING, then for some reason
it gets dropped on the ground and so the wakeup call doesn't happen
when the inode has been removed from the hash.

I can't see anywhere in the code that this happens, though, but it
might be some pre-existing race in the inode hash that you are now
triggering because freeing will be happening in parallel on multiple
nodes rather than serialising on a global lock...

I won't have seen this on XFS stress testing, because it doesn't use
the VFS inode hashes for inode lookups. Given that XFS is not
triggering either problem you are seeing, that makes me think
that it might be a pre-existing inode hash lookup/reclaim race
condition, not a LRU problem.

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
