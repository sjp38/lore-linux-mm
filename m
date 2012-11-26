Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 08B8C6B004D
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 13:24:33 -0500 (EST)
Date: Mon, 26 Nov 2012 13:24:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121126182421.GB2301@cmpxchg.org>
References: <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
 <20121123100438.GF24698@dhcp22.suse.cz>
 <20121125011047.7477BB5E@pobox.sk>
 <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126174622.GE2799@cmpxchg.org>
 <20121126180444.GA12602@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126180444.GA12602@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Nov 26, 2012 at 07:04:44PM +0100, Michal Hocko wrote:
> On Mon 26-11-12 12:46:22, Johannes Weiner wrote:
> > On Mon, Nov 26, 2012 at 02:18:37PM +0100, Michal Hocko wrote:
> > > [CCing also Johannes - the thread started here:
> > > https://lkml.org/lkml/2012/11/21/497]
> > > 
> > > On Mon 26-11-12 01:38:55, azurIt wrote:
> > > > >This is hackish but it should help you in this case. Kamezawa, what do
> > > > >you think about that? Should we generalize this and prepare something
> > > > >like mem_cgroup_cache_charge_locked which would add __GFP_NORETRY
> > > > >automatically and use the function whenever we are in a locked context?
> > > > >To be honest I do not like this very much but nothing more sensible
> > > > >(without touching non-memcg paths) comes to my mind.
> > > > 
> > > > 
> > > > I installed kernel with this patch, will report back if problem occurs
> > > > again OR in few weeks if everything will be ok. Thank you!
> > > 
> > > Now that I am looking at the patch closer it will not work because it
> > > depends on other patch which is not merged yet and even that one would
> > > help on its own because __GFP_NORETRY doesn't break the charge loop.
> > > Sorry I have missed that...
> > > 
> > > The patch bellow should help though. (it is based on top of the current
> > > -mm tree but I will send a backport to 3.2 in the reply as well)
> > > ---
> > > >From 7796f942d62081ad45726efd90b5292b80e7c690 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.cz>
> > > Date: Mon, 26 Nov 2012 11:47:57 +0100
> > > Subject: [PATCH] memcg: do not trigger OOM from add_to_page_cache_locked
> > > 
> > > memcg oom killer might deadlock if the process which falls down to
> > > mem_cgroup_handle_oom holds a lock which prevents other task to
> > > terminate because it is blocked on the very same lock.
> > > This can happen when a write system call needs to allocate a page but
> > > the allocation hits the memcg hard limit and there is nothing to reclaim
> > > (e.g. there is no swap or swap limit is hit as well and all cache pages
> > > have been reclaimed already) and the process selected by memcg OOM
> > > killer is blocked on i_mutex on the same inode (e.g. truncate it).
> > > 
> > > Process A
> > > [<ffffffff811109b8>] do_truncate+0x58/0xa0		# takes i_mutex
> > > [<ffffffff81121c90>] do_last+0x250/0xa30
> > > [<ffffffff81122547>] path_openat+0xd7/0x440
> > > [<ffffffff811229c9>] do_filp_open+0x49/0xa0
> > > [<ffffffff8110f7d6>] do_sys_open+0x106/0x240
> > > [<ffffffff8110f950>] sys_open+0x20/0x30
> > > [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > > 
> > > Process B
> > > [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
> > > [<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
> > > [<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
> > > [<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
> > > [<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
> > > [<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
> > > [<ffffffff81193a18>] ext3_write_begin+0x88/0x270
> > > [<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
> > > [<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
> > > [<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0           # takes ->i_mutex
> > > [<ffffffff8111156a>] do_sync_write+0xea/0x130
> > > [<ffffffff81112183>] vfs_write+0xf3/0x1f0
> > > [<ffffffff81112381>] sys_write+0x51/0x90
> > > [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > So process B manages to lock the hierarchy, calls
> > mem_cgroup_out_of_memory() and retries the charge infinitely, waiting
> > for task A to die.  All while it holds the i_mutex, preventing task A
> > from dying, right?
> 
> Right.
> 
> > I think global oom already handles this in a much better way: invoke
> > the OOM killer, sleep for a second, then return to userspace to
> > relinquish all kernel resources and locks.  The only reason why we
> > can't simply change from an endless retry loop is because we don't
> > want to return VM_FAULT_OOM and invoke the global OOM killer.
> 
> Exactly.
> 
> > But maybe we can return a new VM_FAULT_OOM_HANDLED for memcg OOM and
> > just restart the pagefault.  Return -ENOMEM to the buffered IO syscall
> > respectively.  This way, the memcg OOM killer is invoked as it should
> > but nobody gets stuck anywhere livelocking with the exiting task.
> 
> Hmm, we would still have a problem with oom disabled (aka user space OOM
> killer), right? All processes but those in mem_cgroup_handle_oom are
> risky to be killed.

Could we still let everybody get stuck in there when the OOM killer is
disabled and let userspace take care of it?

> Other POV might be, why we should trigger an OOM killer from those paths
> in the first place. Write or read (or even readahead) are all calls that
> should rather fail than cause an OOM killer in my opinion.

Readahead is arguable, but we kill globally for read() and write() and
I think we should do the same for memcg.

The OOM killer is there to resolve a problem that comes from
overcommitting the machine but the overuse does not have to be from
the application that pushes the machine over the edge, that's why we
don't just kill the allocating task but actually go look for the best
candidate.  If you have one memory hog that overuses the resources,
attempted memory consumption in a different program should invoke the
OOM killer.  It does not matter if this is a page fault (would still
happen with your patch) or a bufferd read/write (would no longer
happen).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
