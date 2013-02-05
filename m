Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 90FD56B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:59:59 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id ds1so4353395wgb.4
        for <linux-mm@kvack.org>; Tue, 05 Feb 2013 10:59:58 -0800 (PST)
Date: Tue, 5 Feb 2013 19:59:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20130205185953.GB3959@dhcp22.suse.cz>
References: <20121230020947.AA002F34@pobox.sk>
 <20121230110815.GA12940@dhcp22.suse.cz>
 <20130125160723.FAE73567@pobox.sk>
 <20130125163130.GF4721@dhcp22.suse.cz>
 <20130205134937.GA22804@dhcp22.suse.cz>
 <20130205154947.CD6411E2@pobox.sk>
 <20130205160934.GB22804@dhcp22.suse.cz>
 <xr93wqum4sh4.fsf@gthelen.mtv.corp.google.com>
 <20130205174651.GA3959@dhcp22.suse.cz>
 <xr93a9ri4op6.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93a9ri4op6.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue 05-02-13 10:09:57, Greg Thelen wrote:
> On Tue, Feb 05 2013, Michal Hocko wrote:
> 
> > On Tue 05-02-13 08:48:23, Greg Thelen wrote:
> >> On Tue, Feb 05 2013, Michal Hocko wrote:
> >> 
> >> > On Tue 05-02-13 15:49:47, azurIt wrote:
> >> > [...]
> >> >> Just to be sure - am i supposed to apply this two patches?
> >> >> http://watchdog.sk/lkml/patches/
> >> >
> >> > 5-memcg-fix-1.patch is not complete. It doesn't contain the folloup I
> >> > mentioned in a follow up email. Here is the full patch:
> >> > ---
> >> > From f2bf8437d5b9bb38a95a432bf39f32c584955171 Mon Sep 17 00:00:00 2001
> >> > From: Michal Hocko <mhocko@suse.cz>
> >> > Date: Mon, 26 Nov 2012 11:47:57 +0100
> >> > Subject: [PATCH] memcg: do not trigger OOM from add_to_page_cache_locked
> >> >
> >> > memcg oom killer might deadlock if the process which falls down to
> >> > mem_cgroup_handle_oom holds a lock which prevents other task to
> >> > terminate because it is blocked on the very same lock.
> >> > This can happen when a write system call needs to allocate a page but
> >> > the allocation hits the memcg hard limit and there is nothing to reclaim
> >> > (e.g. there is no swap or swap limit is hit as well and all cache pages
> >> > have been reclaimed already) and the process selected by memcg OOM
> >> > killer is blocked on i_mutex on the same inode (e.g. truncate it).
> >> >
> >> > Process A
> >> > [<ffffffff811109b8>] do_truncate+0x58/0xa0		# takes i_mutex
> >> > [<ffffffff81121c90>] do_last+0x250/0xa30
> >> > [<ffffffff81122547>] path_openat+0xd7/0x440
> >> > [<ffffffff811229c9>] do_filp_open+0x49/0xa0
> >> > [<ffffffff8110f7d6>] do_sys_open+0x106/0x240
> >> > [<ffffffff8110f950>] sys_open+0x20/0x30
> >> > [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> >> > [<ffffffffffffffff>] 0xffffffffffffffff
> >> >
> >> > Process B
> >> > [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
> >> > [<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
> >> > [<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
> >> > [<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
> >> > [<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
> >> > [<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
> >> > [<ffffffff81193a18>] ext3_write_begin+0x88/0x270
> >> > [<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
> >> > [<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
> >> > [<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0           # takes ->i_mutex
> >> > [<ffffffff8111156a>] do_sync_write+0xea/0x130
> >> > [<ffffffff81112183>] vfs_write+0xf3/0x1f0
> >> > [<ffffffff81112381>] sys_write+0x51/0x90
> >> > [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> >> > [<ffffffffffffffff>] 0xffffffffffffffff
> >> 
> >> It looks like grab_cache_page_write_begin() passes __GFP_FS into
> >> __page_cache_alloc() and mem_cgroup_cache_charge().  Which makes me
> >> think that this deadlock is also possible in the page allocator even
> >> before getting to add_to_page_cache_lru.  no?
> >
> > I am not that familiar with VFS but i_mutex is a high level lock AFAIR
> > and it shouldn't be called from the pageout path so __page_cache_alloc
> > should be safe.
> 
> I wasn't clear, sorry.  My concern is not that pageout() grabs i_mutex.
> My concern is that __page_cache_alloc() will invoke the oom killer and
> select a victim which wants i_mutex.  This victim will deadlock because
> the oom killer caller already holds i_mutex.  

That would be true for the memcg oom because that one is blocking but
the global oom just puts the allocator into sleep for a while and then
the allocator should back off eventually (unless this is NOFAIL
allocation). I would need to look closer whether this is really the case
- I haven't seen that allocator code path for a while...

> The wild accusation I am making is that anyone who invokes the oom
> killer and waits on the victim to die is essentially grabbing all of
> the locks that any of the oom killer victims may grab (e.g. i_mutex).

True.

> To avoid deadlock the oom killer can only be called is while holding
> no locks that the oom victim demands.  I think some locks are grabbed
> in a way that allows the lock request to fail if the task has a fatal
> signal pending, so they are safe.  But any locks acquisitions that
> cannot fail (e.g. mutex_lock) will deadlock with the oom killing
> process.  So the oom killing process cannot hold any such locks which
> the victim will attempt to grab.  Hopefully I'm missing something.

Agreed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
