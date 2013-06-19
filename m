Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 99F626B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 04:53:05 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id fo12so4406964lab.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 01:53:03 -0700 (PDT)
Date: Wed, 19 Jun 2013 12:52:54 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130619085252.GD1990@localhost.localdomain>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618062623.GA20528@localhost.localdomain>
 <20130619071346.GA9545@dhcp22.suse.cz>
 <20130619073526.GB1990@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130619073526.GB1990@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 19, 2013 at 11:35:27AM +0400, Glauber Costa wrote:
> On Wed, Jun 19, 2013 at 09:13:46AM +0200, Michal Hocko wrote:
> > On Tue 18-06-13 10:26:24, Glauber Costa wrote:
> > [...]
> > > Michal, would you mind testing the following patch?
> > >
> > > diff --git a/fs/inode.c b/fs/inode.c
> > > index 00b804e..48eafa6 100644
> > > --- a/fs/inode.c
> > > +++ b/fs/inode.c
> > > @@ -419,6 +419,8 @@ void inode_add_lru(struct inode *inode)
> > >  
> > >  static void inode_lru_list_del(struct inode *inode)
> > >  {
> > > +	if (inode->i_state & I_FREEING)
> > > +		return;
> > >  
> > >  	if (list_lru_del(&inode->i_sb->s_inode_lru, &inode->i_lru))
> > >  		this_cpu_dec(nr_unused);
> > > @@ -609,8 +611,8 @@ void evict_inodes(struct super_block *sb)
> > >  			continue;
> > >  		}
> > >  
> > > -		inode->i_state |= I_FREEING;
> > >  		inode_lru_list_del(inode);
> > > +		inode->i_state |= I_FREEING;
> > >  		spin_unlock(&inode->i_lock);
> > >  		list_add(&inode->i_lru, &dispose);
> > >  	}
> > > @@ -653,8 +655,8 @@ int invalidate_inodes(struct super_block *sb, bool kill_dirty)
> > >  			continue;
> > >  		}
> > >  
> > > -		inode->i_state |= I_FREEING;
> > >  		inode_lru_list_del(inode);
> > > +		inode->i_state |= I_FREEING;
> > >  		spin_unlock(&inode->i_lock);
> > >  		list_add(&inode->i_lru, &dispose);
> > >  	}
> > > @@ -1381,9 +1383,8 @@ static void iput_final(struct inode *inode)
> > >  		inode->i_state &= ~I_WILL_FREE;
> > >  	}
> > >  
> > > +	inode_lru_list_del(inode);
> > >  	inode->i_state |= I_FREEING;
> > > -	if (!list_empty(&inode->i_lru))
> > > -		inode_lru_list_del(inode);
> > >  	spin_unlock(&inode->i_lock);
> > >  
> > >  	evict(inode);
> > 
> > No luck. I have this on top of inode_lru_isolate one but still can see
> > hangs:
> > 911 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
> > [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> > [<ffffffff8118529f>] iget_locked+0x4f/0x180
> > [<ffffffff811efa23>] ext4_iget+0x33/0x9f0
> > [<ffffffff811f6a5c>] ext4_lookup+0xbc/0x160
> > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > [<ffffffff81175254>] __lookup_hash+0x34/0x40
> > [<ffffffff81179872>] path_lookupat+0x7a2/0x830
> > [<ffffffff81179933>] filename_lookup+0x33/0xd0
> > [<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
> > [<ffffffff8117ab4c>] user_path_at+0xc/0x10
> > [<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
> > [<ffffffff81170116>] vfs_stat+0x16/0x20
> > [<ffffffff8117013f>] sys_newstat+0x1f/0x50
> > [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 21409 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
> > [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> > [<ffffffff8118529f>] iget_locked+0x4f/0x180
> > [<ffffffff811efa23>] ext4_iget+0x33/0x9f0
> > [<ffffffff811f6a5c>] ext4_lookup+0xbc/0x160
> > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > [<ffffffff8117815e>] do_last+0x2de/0x780
> > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 21745 [<ffffffff81179862>] path_lookupat+0x792/0x830
> > [<ffffffff81179933>] filename_lookup+0x33/0xd0
> > [<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
> > [<ffffffff8117ab4c>] user_path_at+0xc/0x10
> > [<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
> > [<ffffffff81170116>] vfs_stat+0x16/0x20
> > [<ffffffff8117013f>] sys_newstat+0x1f/0x50
> > [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 22032 [<ffffffff81179862>] path_lookupat+0x792/0x830
> > [<ffffffff81179933>] filename_lookup+0x33/0xd0
> > [<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
> > [<ffffffff8117ab4c>] user_path_at+0xc/0x10
> > [<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
> > [<ffffffff81170116>] vfs_stat+0x16/0x20
> > [<ffffffff8117013f>] sys_newstat+0x1f/0x50
> > [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 22621 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
> > [<ffffffff81183321>] find_inode_fast+0xa1/0xc0
> > [<ffffffff8118529f>] iget_locked+0x4f/0x180
> > [<ffffffff811efa23>] ext4_iget+0x33/0x9f0
> > [<ffffffff811f6a5c>] ext4_lookup+0xbc/0x160
> > [<ffffffff81174ad0>] lookup_real+0x20/0x60
> > [<ffffffff81177e25>] lookup_open+0x175/0x1d0
> > [<ffffffff8117815e>] do_last+0x2de/0x780
> > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 22711 [<ffffffff81178144>] do_last+0x2c4/0x780
> > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 22946 [<ffffffff81178144>] do_last+0x2c4/0x780
> > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > 23393 [<ffffffff81178144>] do_last+0x2c4/0x780
> > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > [<ffffffff81583129>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> > -- 
> Sorry if you said that before Michal.
> 
> But given the backtrace, are you sure this is LRU-related? You mentioned you bisected
> it but found nothing conclusive. I will keep looking but maybe this could benefit from
> a broader fs look
> 
> In any case, the patch we suggested is obviously correct and we should apply nevertheless.
> I will write it down and send it to Andrew.

My analysis of the LRU side code so far is:

* Assuming we are not hanging because of held locks, the fact that we
are hung at __wait_on_freeing_inode() means that someone who should
be waking us up is not. This would indicate that an inode is marked
as to-be-freed, but later on not freed.

* We will wait for free inodes if the state is I_FREEING or I_WILL_FREE.

* I_WILL_FREE is only set for a very short time during iput_final, and
the code path leads unconditionally to evict(), which wakes up any
waiters.

* clear_inode sets I_FREEING but it is only called from within evict,
which means we will wake up the waiters shortly.

* The LRU will not necessarily put the element into those states, but when
it does, it moves them to the dispose list. We will call evict() for all
ements in the dispose list, and that will unconditionally call wake_up_bit.
So it seems that if the LRU sets I_FREEING (we never set I_WILL_FREE)

* The same is true for evict_inodes and invalidate_inodes. They test
for the freeing bits and will skip the inodes marked as such. This seems
okay, since this means someone else marked them as freeing and it should
be their responsibility to wake up the callers.

So this shows that strangely enough, the code seems very safe and fine.
Still you are seeing hangs... Any chance we are hanging on the acquisition
of inode_hash_lock?

I need to be away for some hours, but I will be back to it soon. Meanwhile,
if Dave could take a look into it, that would be trully great.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
