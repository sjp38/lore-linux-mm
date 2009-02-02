Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 399975F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 06:44:52 -0500 (EST)
Subject: Re: [BUG??] Deadlock between kswapd and
 sys_inotify_add_watch(lockdep  report)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090202112721.GA13532@barrios-desktop>
References: <20090202101735.GA12757@barrios-desktop>
	 <28c262360902020225w6419089ft2dda30da9dfb32a9@mail.gmail.com>
	 <1233571202.4787.124.camel@laptop> <20090202112721.GA13532@barrios-desktop>
Content-Type: text/plain
Date: Mon, 02 Feb 2009 12:44:45 +0100
Message-Id: <1233575085.4787.140.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, linux kernel <linux-kernel@vger.kernel.org>, linux mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-02 at 20:27 +0900, MinChan Kim wrote:
> On Mon, Feb 02, 2009 at 11:40:02AM +0100, Peter Zijlstra wrote:
> > On Mon, 2009-02-02 at 19:25 +0900, MinChan Kim wrote:
> > > But, I am not sure whether it's real bug or not.
> > 
> > Me neither, inode life-times are tricky, but on first sight it looks
> > real enough.
> > 
> > > I always suffer from reading lockdep report's result. :(
> > > It would be better to have a document about lockdep report analysis.
> > 
> > I've never found them hard to read, so I'm afraid you'll have to be more
> > explicit about what is unclear to you.
> 
> It's becuase not lockdep humble report but my poor knowledge. :(
> Could you elaborate please ?
> 
> >[  331.718120] [ INFO: inconsistent lock state ]
> >[  331.718124] 2.6.28-rc2-mm1-lockdep #6
> >[  331.718126] ---------------------------------
> >[  331.718129] inconsistent {ov-reclaim-W} -> {in-reclaim-W} usage.
>                                          ^                 ^ 
>                                         write ?           write ?

Correct, we track states for read and write, for single state locks we
map everything on the exclusive state (write).

> >
> >[  331.718133] kswapd0/218 [HC0[0]:SC0[0]:HE0:SE1] takes:
>                             ^^^^^^^^^^^^^^^^^^^^^^
>                             what means ? HC,SC,HE,SE

Ah, yes, that's a bit obscure, but usually not needed.

Hardirq Context -- irq state tracking [preempt_count tracking]
Softirq Context -- idem

Hardirq Enabled
Softirq Enabled

It allows you to see if the irq state tracking matches up, and what the
call context is.

> >
> >[  331.718136]  (&inode->inotify_mutex){--..+.}, at: [<c01dba70>] inotify_inode_is_dead+0x20/0x90
> >             
> 
> Is it related to recursive lock of inotify_mutex ?

Yes.

> but, Subject means 'inconsistent {ov-reclaim-W} -> {in-reclaim-W}', 
> IOW, it's related to reclaim of GFP_FS. 
> What's relation inotify_mutex and reclaim of GFP_FS?

The lockdep report states the following:

While holding inotify_mutex, we do a __GFP_FS allocation.
But __GFP_FS allocations can end up locking inotify_mutex.

> I think if reclaim context which have GFP_FS already have lock A and then 
> do pageout, if writepage need the lock A, we have to catch such a case. 
> I thought Nick's patch's goal catchs such a case. 

Correct, it exactly does that.

> One more question is that what's difference between lock inversion and
> circular locking dependency ?

I'm not sure if there's a difference. I suspect they are two ways of
saying the same.

> >[  331.718148] {ov-reclaim-W} state was registered at:
> >[  331.718150]   [<c01532ee>] mark_held_locks+0x3e/0x90
> >[  331.718157]   [<c015338e>] lockdep_trace_alloc+0x4e/0x80
> >[  331.718162]   [<c01acee6>] kmem_cache_alloc+0x26/0xf0
> >[  331.718166]   [<c0243fa0>] idr_pre_get+0x50/0x70
> >[  331.718172]   [<c01db761>] inotify_handle_get_wd+0x21/0x60
> >[  331.718176]   [<c01dc012>] inotify_add_watch+0x52/0xe0
> >[  331.718181]   [<c01dcca8>] sys_inotify_add_watch+0x148/0x170
> >[  331.718185]   [<c0104032>] syscall_call+0x7/0xb
> >[  331.718190]   [<ffffffff>] 0xffffffff

This bit states, we saw inotify_mutex being held over a __GFP_FS
reclaim.

> >[  331.718205] irq event stamp: 1288446
> >[  331.718207] hardirqs last  enabled at (1288445): [<c0179695>] call_rcu+0x75/0x90
> >[  331.718213] hardirqs last disabled at (1288446): [<c0370103>] mutex_lock_nested+0x53/0x2f0
> >[  331.718221] softirqs last  enabled at (1284622): [<c0132fa2>] __do_softirq+0x132/0x180
> >[  331.718226] softirqs last disabled at (1284617): [<c0133079>] do_softirq+0x89/0x90
> >[  331.718231]
> >[  331.718232] other info that might help us debug this:
> >[  331.718236] 2 locks held by kswapd0/218:
> >[  331.718238]  #0:  (shrinker_rwsem){----..}, at: [<c0192d65>] shrink_slab+0x25/0x1a0
> >[  331.718248]  #1:  (&type->s_umount_key#4){-----.}, at: [<c01c21fb>] shrink_dcache_memory+0xfb/0x1a0
> >[  331.718259]
> >[  331.718260] stack backtrace:
> >[  331.718263] Pid: 218, comm: kswapd0 Not tainted 2.6.28-rc2-mm1-lockdep #6

> >[  331.718266] Call Trace:
> >[  331.718272]  [<c0151726>] print_usage_bug+0x176/0x1c0
> >[  331.718276]  [<c0152d05>] mark_lock+0xb05/0x10b0
> >[  331.718282]  [<c018c0e9>] ? __free_pages_ok+0x349/0x450
> >[  331.718287]  [<c0155362>] __lock_acquire+0x602/0xa80
> >[  331.718291]  [<c01540ff>] ? validate_chain+0x3ef/0x1050
> >[  331.718296]  [<c0155851>] lock_acquire+0x71/0xa0
> >[  331.718300]  [<c01dba70>] ? inotify_inode_is_dead+0x20/0x90
> >[  331.718305]  [<c037014d>] mutex_lock_nested+0x9d/0x2f0
> >[  331.718310]  [<c01dba70>] ? inotify_inode_is_dead+0x20/0x90
> >[  331.718314]  [<c01dba70>] ? inotify_inode_is_dead+0x20/0x90
> >[  331.718318]  [<c01dba70>] inotify_inode_is_dead+0x20/0x90
> >[  331.718323]  [<c024e2d6>] ? _raw_spin_unlock+0x46/0x80
> >[  331.718328]  [<c01c1d14>] dentry_iput+0xa4/0xc0
> >[  331.718333]  [<c01c1dfb>] d_kill+0x3b/0x60
> >[  331.718337]  [<c01c1fe6>] __shrink_dcache_sb+0x1c6/0x2c0
> >[  331.718342]  [<c01c228d>] shrink_dcache_memory+0x18d/0x1a0
> >[  331.718347]  [<c0192e6b>] shrink_slab+0x12b/0x1a0
> >[  331.718351]  [<c01939ff>] kswapd+0x3af/0x5c0
> >[  331.718356]  [<c01910a0>] ? isolate_pages_global+0x0/0x220
> >[  331.718362]  [<c0142800>] ? autoremove_wake_function+0x0/0x40
> >[  331.718366]  [<c0193650>] ? kswapd+0x0/0x5c0
> >[  331.718371]  [<c01424f7>] kthread+0x47/0x80
> >[  331.718375]  [<c01424b0>] ? kthread+0x0/0x80
> >[  331.718380]  [<c01054f7>] kernel_thread_helper+0x7/0x10

This trace gives us the current situation, that is reported to violate
the previous state. IOW here we use inotify_mutex during a __GFP_FS
reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
