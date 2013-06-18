Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id CE33D6B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 06:44:45 -0400 (EDT)
Date: Tue, 18 Jun 2013 12:44:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130618104443.GH13677@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618024623.GP29338@dastard>
 <20130618063104.GB20528@localhost.localdomain>
 <20130618082414.GC13677@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130618082414.GC13677@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 18-06-13 10:24:14, Michal Hocko wrote:
> On Tue 18-06-13 10:31:05, Glauber Costa wrote:
> > On Tue, Jun 18, 2013 at 12:46:23PM +1000, Dave Chinner wrote:
> > > On Tue, Jun 18, 2013 at 02:30:05AM +0400, Glauber Costa wrote:
> > > > On Mon, Jun 17, 2013 at 02:35:08PM -0700, Andrew Morton wrote:
> > > > > On Mon, 17 Jun 2013 19:14:12 +0400 Glauber Costa <glommer@gmail.com> wrote:
> > > > > 
> > > > > > > I managed to trigger:
> > > > > > > [ 1015.776029] kernel BUG at mm/list_lru.c:92!
> > > > > > > [ 1015.776029] invalid opcode: 0000 [#1] SMP
> > > > > > > with Linux next (next-20130607) with https://lkml.org/lkml/2013/6/17/203
> > > > > > > on top. 
> > > > > > > 
> > > > > > > This is obviously BUG_ON(nlru->nr_items < 0) and 
> > > > > > > ffffffff81122d0b:       48 85 c0                test   %rax,%rax
> > > > > > > ffffffff81122d0e:       49 89 44 24 18          mov    %rax,0x18(%r12)
> > > > > > > ffffffff81122d13:       0f 84 87 00 00 00       je     ffffffff81122da0 <list_lru_walk_node+0x110>
> > > > > > > ffffffff81122d19:       49 83 7c 24 18 00       cmpq   $0x0,0x18(%r12)
> > > > > > > ffffffff81122d1f:       78 7b                   js     ffffffff81122d9c <list_lru_walk_node+0x10c>
> > > > > > > [...]
> > > > > > > ffffffff81122d9c:       0f 0b                   ud2
> > > > > > > 
> > > > > > > RAX is -1UL.
> > > > > > Yes, fearing those kind of imbalances, we decided to leave the counter as a signed quantity
> > > > > > and BUG, instead of an unsigned quantity.
> > > > > > 
> > > > > > > 
> > > > > > > I assume that the current backtrace is of no use and it would most
> > > > > > > probably be some shrinker which doesn't behave.
> > > > > > > 
> > > > > > There are currently 3 users of list_lru in tree: dentries, inodes and xfs.
> > > > > > Assuming you are not using xfs, we are left with dentries and inodes.
> > > > > > 
> > > > > > The first thing to do is to find which one of them is misbehaving. You can try finding
> > > > > > this out by the address of the list_lru, and where it lays in the superblock.
> > > > > > 
> > > > > > Once we know each of them is misbehaving, then we'll have to figure out why.
> > > > > 
> > > > > The trace says shrink_slab_node->super_cache_scan->prune_icache_sb.  So
> > > > > it's inodes?
> > > > > 
> > > > Assuming there is no memory corruption of any sort going on , let's check the code.
> > > > nr_item is only manipulated in 3 places:
> > > > 
> > > > 1) list_lru_add, where it is increased
> > > > 2) list_lru_del, where it is decreased in case the user have voluntarily removed the
> > > >    element from the list
> > > > 3) list_lru_walk_node, where an element is removing during shrink.
> > > > 
> > > > All three excerpts seem to be correctly locked, so something like this indicates an imbalance.
> > > 
> > > inode_lru_isolate() looks suspicious to me:
> > > 
> > >         WARN_ON(inode->i_state & I_NEW);
> > >         inode->i_state |= I_FREEING;
> > >         spin_unlock(&inode->i_lock);
> > > 
> > >         list_move(&inode->i_lru, freeable);
> > >         this_cpu_dec(nr_unused);
> > > 	return LRU_REMOVED;
> > > }
> > > 
> > > All the other cases where I_FREEING is set and the inode is removed
> > > from the LRU are completely done under the inode->i_lock. i.e. from
> > > an external POV, the state change to I_FREEING and removal from LRU
> > > are supposed to be atomic, but they are not here.
> > > 
> > > I'm not sure this is the source of the problem, but it definitely
> > > needs fixing.
> > > 
> > Yes, I missed that yesterday, but that does look suspicious to me as well.
> > 
> > Michal, if you can manually move this one inside the lock as well and see
> > if it fixes your problem as well... Otherwise I can send you a patch as well
> > so we don't get lost on what is patched and what is not.
> 
> OK, I am testing with this now:
> diff --git a/fs/inode.c b/fs/inode.c
> index 604c15e..95e598c 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -733,9 +733,9 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>  
>  	WARN_ON(inode->i_state & I_NEW);
>  	inode->i_state |= I_FREEING;
> +	list_move(&inode->i_lru, freeable);
>  	spin_unlock(&inode->i_lock);
>  
> -	list_move(&inode->i_lru, freeable);
>  	this_cpu_dec(nr_unused);
>  	return LRU_REMOVED;
>  }

And this hung again:
 4434 pts/0    S+     0:00                 /bin/sh ./run_batch.sh mmotmdebug
 4436 pts/0    S+     0:00                   /bin/bash ./start.sh
 4441 pts/0    S+     0:26                     /bin/bash ./start.sh
 1919 pts/0    S+     0:00                       sleep 1s
 4457 pts/0    S+     0:00                     /bin/bash ./run_test.sh /dev/cgroup A 2
 4459 pts/0    S+     0:27                       /bin/bash ./run_test.sh /dev/cgroup A 2
 1913 pts/0    S+     0:00                         sleep 1s
 5626 pts/0    S+     0:00                       /usr/bin/time -v make -j4 vmlinux
 5628 pts/0    S+     0:00                         make -j4 vmlinux
 2676 pts/0    S+     0:00                           make -f scripts/Makefile.build obj=sound
 2893 pts/0    S+     0:00                             make -f scripts/Makefile.build obj=sound/pci
 2998 pts/0    D+     0:00                               make -f scripts/Makefile.build obj=sound/pci/emu10k1
 6590 pts/0    D+     0:00                           make -f scripts/Makefile.build obj=net
 4458 pts/0    S+     0:00                     /bin/bash ./run_test.sh /dev/cgroup B 2
 4464 pts/0    S+     0:27                       /bin/bash ./run_test.sh /dev/cgroup B 2
 1914 pts/0    S+     0:00                         sleep 1s
 5625 pts/0    S+     0:00                       /usr/bin/time -v make -j4 vmlinux
 5627 pts/0    S+     0:00                         make -j4 vmlinux
13010 pts/0    D+     0:00                           make -f scripts/Makefile.build obj=kernel
 3933 pts/0    Z+     0:00                             [sh] <defunct>
14459 pts/0    S+     0:00                           make -f scripts/Makefile.build obj=fs
  784 pts/0    D+     0:00                             make -f scripts/Makefile.build obj=fs/romfs
 2401 pts/0    S+     0:00                           make -f scripts/Makefile.build obj=crypto
 4614 pts/0    D+     0:00                             make -f scripts/Makefile.build obj=crypto/asymmetric_keys
 3343 pts/0    S+     0:00                           make -f scripts/Makefile.build obj=block
 5167 pts/0    D+     0:00                             make -f scripts/Makefile.build obj=block/partitions

demon:/home/mhocko # cat /proc/2998/stack 
[<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118525f>] iget_locked+0x4f/0x180
[<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81177e25>] lookup_open+0x175/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
demon:/home/mhocko # cat /proc/6590/stack 
[<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118525f>] iget_locked+0x4f/0x180
[<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81175254>] __lookup_hash+0x34/0x40
[<ffffffff81179872>] path_lookupat+0x7a2/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
demon:/home/mhocko # cat /proc/13010/stack 
[<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118525f>] iget_locked+0x4f/0x180
[<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81175254>] __lookup_hash+0x34/0x40
[<ffffffff81179872>] path_lookupat+0x7a2/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
demon:/home/mhocko # cat /proc/784/stack 
[<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118525f>] iget_locked+0x4f/0x180
[<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81175254>] __lookup_hash+0x34/0x40
[<ffffffff81179872>] path_lookupat+0x7a2/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
demon:/home/mhocko # cat /proc/4614/stack 
[<ffffffff8117d0ca>] vfs_readdir+0x7a/0xc0
[<ffffffff8117d1a6>] sys_getdents64+0x96/0x100
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
demon:/home/mhocko # cat /proc/5167/stack 
[<ffffffff8117d0ca>] vfs_readdir+0x7a/0xc0
[<ffffffff8117d1a6>] sys_getdents64+0x96/0x100
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

JFYI: This is still with my -mm git tree + the above diff + referenced
patch from Mel (mm: Clear page active before releasing pages).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
