Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 9E74D6B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 02:31:12 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id ec20so3228167lab.27
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 23:31:10 -0700 (PDT)
Date: Tue, 18 Jun 2013 10:31:05 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130618063104.GB20528@localhost.localdomain>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618024623.GP29338@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130618024623.GP29338@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 18, 2013 at 12:46:23PM +1000, Dave Chinner wrote:
> On Tue, Jun 18, 2013 at 02:30:05AM +0400, Glauber Costa wrote:
> > On Mon, Jun 17, 2013 at 02:35:08PM -0700, Andrew Morton wrote:
> > > On Mon, 17 Jun 2013 19:14:12 +0400 Glauber Costa <glommer@gmail.com> wrote:
> > > 
> > > > > I managed to trigger:
> > > > > [ 1015.776029] kernel BUG at mm/list_lru.c:92!
> > > > > [ 1015.776029] invalid opcode: 0000 [#1] SMP
> > > > > with Linux next (next-20130607) with https://lkml.org/lkml/2013/6/17/203
> > > > > on top. 
> > > > > 
> > > > > This is obviously BUG_ON(nlru->nr_items < 0) and 
> > > > > ffffffff81122d0b:       48 85 c0                test   %rax,%rax
> > > > > ffffffff81122d0e:       49 89 44 24 18          mov    %rax,0x18(%r12)
> > > > > ffffffff81122d13:       0f 84 87 00 00 00       je     ffffffff81122da0 <list_lru_walk_node+0x110>
> > > > > ffffffff81122d19:       49 83 7c 24 18 00       cmpq   $0x0,0x18(%r12)
> > > > > ffffffff81122d1f:       78 7b                   js     ffffffff81122d9c <list_lru_walk_node+0x10c>
> > > > > [...]
> > > > > ffffffff81122d9c:       0f 0b                   ud2
> > > > > 
> > > > > RAX is -1UL.
> > > > Yes, fearing those kind of imbalances, we decided to leave the counter as a signed quantity
> > > > and BUG, instead of an unsigned quantity.
> > > > 
> > > > > 
> > > > > I assume that the current backtrace is of no use and it would most
> > > > > probably be some shrinker which doesn't behave.
> > > > > 
> > > > There are currently 3 users of list_lru in tree: dentries, inodes and xfs.
> > > > Assuming you are not using xfs, we are left with dentries and inodes.
> > > > 
> > > > The first thing to do is to find which one of them is misbehaving. You can try finding
> > > > this out by the address of the list_lru, and where it lays in the superblock.
> > > > 
> > > > Once we know each of them is misbehaving, then we'll have to figure out why.
> > > 
> > > The trace says shrink_slab_node->super_cache_scan->prune_icache_sb.  So
> > > it's inodes?
> > > 
> > Assuming there is no memory corruption of any sort going on , let's check the code.
> > nr_item is only manipulated in 3 places:
> > 
> > 1) list_lru_add, where it is increased
> > 2) list_lru_del, where it is decreased in case the user have voluntarily removed the
> >    element from the list
> > 3) list_lru_walk_node, where an element is removing during shrink.
> > 
> > All three excerpts seem to be correctly locked, so something like this indicates an imbalance.
> 
> inode_lru_isolate() looks suspicious to me:
> 
>         WARN_ON(inode->i_state & I_NEW);
>         inode->i_state |= I_FREEING;
>         spin_unlock(&inode->i_lock);
> 
>         list_move(&inode->i_lru, freeable);
>         this_cpu_dec(nr_unused);
> 	return LRU_REMOVED;
> }
> 
> All the other cases where I_FREEING is set and the inode is removed
> from the LRU are completely done under the inode->i_lock. i.e. from
> an external POV, the state change to I_FREEING and removal from LRU
> are supposed to be atomic, but they are not here.
> 
> I'm not sure this is the source of the problem, but it definitely
> needs fixing.
> 
Yes, I missed that yesterday, but that does look suspicious to me as well.

Michal, if you can manually move this one inside the lock as well and see
if it fixes your problem as well... Otherwise I can send you a patch as well
so we don't get lost on what is patched and what is not.

Let us at least know if this is the problem.

> > callers:
> > iput_final, evict_inodes, invalidate_inodes.
> > Both evict_inodes and invalidate_inodes will do the following pattern:
> > 
> >                 inode->i_state |= I_FREEING;                                            
> >                 inode_lru_list_del(inode);
> >                 spin_unlock(&inode->i_lock);
> >                 list_add(&inode->i_lru, &dispose);
> > 
> > IOW, they will remove the element from the LRU, and add it to the dispose list.
> > Both of them will also bail out if they see I_FREEING already set, so they are safe
> > against each other - because the flag is manipulated inside the lock.
> > 
> > But how about iput_final? It seems to me that if we are calling iput_final at the
> > same time as the other two, this *could* happen (maybe there is some extra protection
> > that can be seen from Australia but not from here. Dave?)
> 
> If I_FREEING is set before we enter iput_final(), then something
> else is screwed up. I_FREEING is only set once the last reference
> has gone away and we are killing the inode. All the other callers
> that set I_FREEING check that the reference count on the inode is
> zero before they set I_FREEING. Hence I_FREEING cannot be set on the
> transition of i_count from 1 to 0 when iput_final() is called. So
> the patch won't do anything to avoid the problem being seen.
> 
Yes, but isn't things like evict_inodes and invalidate_inodes called at
umount time, for instance? Can't it be that we drop the last reference
to a valid in use inode while someone else is invalidating them all?

> Keep in mind that we this is actually a new warning on the count of
> inodes on the LRU - we never had a check that it didn't go negative
> before....
>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
