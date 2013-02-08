Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id BB3D06B0005
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 11:29:20 -0500 (EST)
Date: Fri, 8 Feb 2013 17:29:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20130208162918.GF7557@dhcp22.suse.cz>
References: <20130125160723.FAE73567@pobox.sk>
 <20130125163130.GF4721@dhcp22.suse.cz>
 <20130205134937.GA22804@dhcp22.suse.cz>
 <20130205154947.CD6411E2@pobox.sk>
 <20130205160934.GB22804@dhcp22.suse.cz>
 <xr93wqum4sh4.fsf@gthelen.mtv.corp.google.com>
 <20130205174651.GA3959@dhcp22.suse.cz>
 <xr93a9ri4op6.fsf@gthelen.mtv.corp.google.com>
 <20130205185953.GB3959@dhcp22.suse.cz>
 <xr93ip63ig6j.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93ip63ig6j.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 07-02-13 20:27:00, Greg Thelen wrote:
> On Tue, Feb 05 2013, Michal Hocko wrote:
> 
> > On Tue 05-02-13 10:09:57, Greg Thelen wrote:
> >> On Tue, Feb 05 2013, Michal Hocko wrote:
> >> 
> >> > On Tue 05-02-13 08:48:23, Greg Thelen wrote:
> >> >> On Tue, Feb 05 2013, Michal Hocko wrote:
> >> >> 
> >> >> > On Tue 05-02-13 15:49:47, azurIt wrote:
> >> >> > [...]
> >> >> >> Just to be sure - am i supposed to apply this two patches?
> >> >> >> http://watchdog.sk/lkml/patches/
> >> >> >
> >> >> > 5-memcg-fix-1.patch is not complete. It doesn't contain the folloup I
> >> >> > mentioned in a follow up email. Here is the full patch:
> >> >> > ---
> >> >> > From f2bf8437d5b9bb38a95a432bf39f32c584955171 Mon Sep 17 00:00:00 2001
> >> >> > From: Michal Hocko <mhocko@suse.cz>
> >> >> > Date: Mon, 26 Nov 2012 11:47:57 +0100
> >> >> > Subject: [PATCH] memcg: do not trigger OOM from add_to_page_cache_locked
> >> >> >
> >> >> > memcg oom killer might deadlock if the process which falls down to
> >> >> > mem_cgroup_handle_oom holds a lock which prevents other task to
> >> >> > terminate because it is blocked on the very same lock.
> >> >> > This can happen when a write system call needs to allocate a page but
> >> >> > the allocation hits the memcg hard limit and there is nothing to reclaim
> >> >> > (e.g. there is no swap or swap limit is hit as well and all cache pages
> >> >> > have been reclaimed already) and the process selected by memcg OOM
> >> >> > killer is blocked on i_mutex on the same inode (e.g. truncate it).
> >> >> >
> >> >> > Process A
> >> >> > [<ffffffff811109b8>] do_truncate+0x58/0xa0		# takes i_mutex
> >> >> > [<ffffffff81121c90>] do_last+0x250/0xa30
> >> >> > [<ffffffff81122547>] path_openat+0xd7/0x440
> >> >> > [<ffffffff811229c9>] do_filp_open+0x49/0xa0
> >> >> > [<ffffffff8110f7d6>] do_sys_open+0x106/0x240
> >> >> > [<ffffffff8110f950>] sys_open+0x20/0x30
> >> >> > [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> >> >> > [<ffffffffffffffff>] 0xffffffffffffffff
> >> >> >
> >> >> > Process B
> >> >> > [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
> >> >> > [<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
> >> >> > [<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
> >> >> > [<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
> >> >> > [<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
> >> >> > [<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
> >> >> > [<ffffffff81193a18>] ext3_write_begin+0x88/0x270
> >> >> > [<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
> >> >> > [<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
> >> >> > [<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0           # takes ->i_mutex
> >> >> > [<ffffffff8111156a>] do_sync_write+0xea/0x130
> >> >> > [<ffffffff81112183>] vfs_write+0xf3/0x1f0
> >> >> > [<ffffffff81112381>] sys_write+0x51/0x90
> >> >> > [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> >> >> > [<ffffffffffffffff>] 0xffffffffffffffff
> >> >> 
> >> >> It looks like grab_cache_page_write_begin() passes __GFP_FS into
> >> >> __page_cache_alloc() and mem_cgroup_cache_charge().  Which makes me
> >> >> think that this deadlock is also possible in the page allocator even
> >> >> before getting to add_to_page_cache_lru.  no?
> >> >
> >> > I am not that familiar with VFS but i_mutex is a high level lock AFAIR
> >> > and it shouldn't be called from the pageout path so __page_cache_alloc
> >> > should be safe.
> >> 
> >> I wasn't clear, sorry.  My concern is not that pageout() grabs i_mutex.
> >> My concern is that __page_cache_alloc() will invoke the oom killer and
> >> select a victim which wants i_mutex.  This victim will deadlock because
> >> the oom killer caller already holds i_mutex.  
> >
> > That would be true for the memcg oom because that one is blocking but
> > the global oom just puts the allocator into sleep for a while and then
> > the allocator should back off eventually (unless this is NOFAIL
> > allocation). I would need to look closer whether this is really the case
> > - I haven't seen that allocator code path for a while...
> 
> I think the page allocator can loop forever waiting for an oom victim to
> terminate even without NOFAIL.  Especially if the oom victim wants a
> resource exclusively held by the allocating thread (e.g. i_mutex).  It
> looks like the same deadlock you describe is also possible (though more
> rare) without memcg.

OK, I have checked the allocator slow path and you are right even
GFP_KERNEL will not fail. This can lead to similar deadlocks - e.g.
OOM killed task blocked on down_write(mmap_sem) while the page fault
handler holding mmap_sem for reading and allocating a new page without
any progress.
Luckily there are memory reserves where the allocator fall back
eventually so the allocation should be able to get some memory and
release the lock. There is still a theoretical chance this would block
though. This sounds like a corner case though so I wouldn't care about
it very much.

> If the looping thread is an eligible oom victim (i.e. not oom disabled,
> not an kernel thread, etc) then the page allocator can return NULL in so
> long as NOFAIL is not used.  So any allocator which is able to call the
> oom killer and is not oom disabled (kernel thread, etc) is already
> exposed to the possibility of page allocator failure.  So if the page
> allocator could detect the deadlock, then it could safely return NULL.
> Maybe after looping N times without forward progress the page allocator
> should consider failing unless NOFAIL is given.

page allocator is quite tricky to touch and the chances of this deadlock
are not that big.

> if memcg oom kill has been tried a reasonable number of times.  Simply
> failing the memcg charge with ENOMEM seems easier to support than
> exceeding limit (Kame's loan patch).

We cannot do that in the page fault path because this would lead to a
global oom killer. We would need to either retry the page fault or send
KILL to the faulting process. But I do not like this much as this could
lead to DoS attacks.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
