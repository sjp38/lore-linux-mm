Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6DE6831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 11:06:35 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id b68so91959254ywe.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 08:06:35 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r29si6033302ywa.221.2017.05.22.08.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 08:06:34 -0700 (PDT)
Date: Mon, 22 May 2017 16:06:06 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/2] mm, oom: make sure that the oom victim uses memory
 reserves
Message-ID: <20170522150606.GA22625@castle>
References: <20170519112604.29090-1-mhocko@kernel.org>
 <20170519112604.29090-2-mhocko@kernel.org>
 <201705192112.IAF69238.OQOHSJLFOFFMtV@I-love.SAKURA.ne.jp>
 <20170519124632.GD29839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170519124632.GD29839@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 19, 2017 at 02:46:32PM +0200, Michal Hocko wrote:
> On Fri 19-05-17 21:12:36, Tetsuo Handa wrote:
> > >From 41b663d0324bbaa29c01d7fee01e897b8b3b7397 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Fri, 19 May 2017 21:06:49 +0900
> > Subject: [PATCH] mm,page_alloc: Make sure OOM victim can try allocations with
> >  no watermarks once
> > 
> > Roman Gushchin has reported that the OOM killer can trivially selects next
> > OOM victim when a thread doing memory allocation from page fault path was
> > selected as first OOM victim.
> > 
> > ----------
> > [   25.721494] allocate invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
> > [   25.725658] allocate cpuset=/ mems_allowed=0
> > [   25.727033] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
> > [   25.729215] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> > [   25.729598] Call Trace:
> > [   25.729598]  dump_stack+0x63/0x82
> > [   25.729598]  dump_header+0x97/0x21a
> > [   25.729598]  ? do_try_to_free_pages+0x2d7/0x360
> > [   25.729598]  ? security_capable_noaudit+0x45/0x60
> > [   25.729598]  oom_kill_process+0x219/0x3e0
> > [   25.729598]  out_of_memory+0x11d/0x480
> > [   25.729598]  __alloc_pages_slowpath+0xc84/0xd40
> > [   25.729598]  __alloc_pages_nodemask+0x245/0x260
> > [   25.729598]  alloc_pages_vma+0xa2/0x270
> > [   25.729598]  __handle_mm_fault+0xca9/0x10c0
> > [   25.729598]  handle_mm_fault+0xf3/0x210
> > [   25.729598]  __do_page_fault+0x240/0x4e0
> > [   25.729598]  trace_do_page_fault+0x37/0xe0
> > [   25.729598]  do_async_page_fault+0x19/0x70
> > [   25.729598]  async_page_fault+0x28/0x30
> > (...snipped...)
> > [   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
> > [   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB
> > [   25.785680] allocate: page allocation failure: order:0, mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
> > [   25.786797] allocate cpuset=/ mems_allowed=0
> > [   25.787246] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
> > [   25.787935] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> > [   25.788867] Call Trace:
> > [   25.789119]  dump_stack+0x63/0x82
> > [   25.789451]  warn_alloc+0x114/0x1b0
> > [   25.789451]  __alloc_pages_slowpath+0xd32/0xd40
> > [   25.789451]  __alloc_pages_nodemask+0x245/0x260
> > [   25.789451]  alloc_pages_vma+0xa2/0x270
> > [   25.789451]  __handle_mm_fault+0xca9/0x10c0
> > [   25.789451]  handle_mm_fault+0xf3/0x210
> > [   25.789451]  __do_page_fault+0x240/0x4e0
> > [   25.789451]  trace_do_page_fault+0x37/0xe0
> > [   25.789451]  do_async_page_fault+0x19/0x70
> > [   25.789451]  async_page_fault+0x28/0x30
> > (...snipped...)
> > [   25.810868] oom_reaper: reaped process 492 (allocate), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > (...snipped...)
> > [   25.817589] allocate invoked oom-killer: gfp_mask=0x0(), nodemask=(null),  order=0, oom_score_adj=0
> > [   25.818821] allocate cpuset=/ mems_allowed=0
> > [   25.819259] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
> > [   25.819847] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> > [   25.820549] Call Trace:
> > [   25.820733]  dump_stack+0x63/0x82
> > [   25.820961]  dump_header+0x97/0x21a
> > [   25.820961]  ? security_capable_noaudit+0x45/0x60
> > [   25.820961]  oom_kill_process+0x219/0x3e0
> > [   25.820961]  out_of_memory+0x11d/0x480
> > [   25.820961]  pagefault_out_of_memory+0x68/0x80
> > [   25.820961]  mm_fault_error+0x8f/0x190
> > [   25.820961]  ? handle_mm_fault+0xf3/0x210
> > [   25.820961]  __do_page_fault+0x4b2/0x4e0
> > [   25.820961]  trace_do_page_fault+0x37/0xe0
> > [   25.820961]  do_async_page_fault+0x19/0x70
> > [   25.820961]  async_page_fault+0x28/0x30
> > (...snipped...)
> > [   25.863078] Out of memory: Kill process 233 (firewalld) score 10 or sacrifice child
> > [   25.863634] Killed process 233 (firewalld) total-vm:246076kB, anon-rss:20956kB, file-rss:0kB, shmem-rss:0kB
> > ----------
> > 
> > There is a race window that the OOM reaper completes reclaiming the first
> > victim's memory while nothing but mutex_trylock() prevents the first victim
> >  from calling out_of_memory() from pagefault_out_of_memory() after memory
> > allocation for page fault path failed due to being selected as an OOM
> > victim.
> > 
> > This is a side effect of commit 9a67f6488eca926f ("mm: consolidate
> > GFP_NOFAIL checks in the allocator slowpath") because that commit
> > silently changed the behavior from
> > 
> >     /* Avoid allocations with no watermarks from looping endlessly */
> > 
> > to
> > 
> >     /*
> >      * Give up allocations without trying memory reserves if selected
> >      * as an OOM victim
> >      */
> > 
> > in __alloc_pages_slowpath() by moving the location to check TIF_MEMDIE
> > flag. I have noticed this change but I didn't post a patch because
> > I thought it is an acceptable change other than noise by warn_alloc()
> > because !__GFP_NOFAIL allocations are allowed to fail.
> > But we overlooked that failing memory allocation from page fault path
> > makes difference due to the race window explained above.
> > 
> > While it might be possible to add a check to pagefault_out_of_memory()
> > that prevents the first victim from calling out_of_memory() or remove
> > out_of_memory() from pagefault_out_of_memory(), changing
> > pagefault_out_of_memory() does not suppress noise by warn_alloc() when
> > allocating thread was selected as an OOM victim. There is little point
> > with printing similar backtraces and memory information from both
> > out_of_memory() and warn_alloc().
> > 
> > Instead, if we guarantee that current thread can try allocations with
> > no watermarks once when current thread looping inside
> > __alloc_pages_slowpath() was selected as an OOM victim, we can follow
> > "who can use memory reserves" rules and suppress noise by warn_alloc()
> > and prevent memory allocations from page fault path from calling
> > pagefault_out_of_memory().
> > 
> > If we take the comment literally, this patch would do
> > 
> > -    if (test_thread_flag(TIF_MEMDIE))
> > -        goto nopage;
> > +    if (alloc_flags == ALLOC_NO_WATERMARKS || (gfp_mask & __GFP_NOMEMALLOC))
> > +        goto nopage;
> > 
> > because gfp_pfmemalloc_allowed() returns false if __GFP_NOMEMALLOC is
> > given. But if I recall correctly (I couldn't find the message), the
> > condition is meant to apply to only OOM victims despite the comment.
> > Therefore, this patch preserves TIF_MEMDIE check.
> > 
> > Reported-by: Roman Gushchin <guro@fb.com>
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Fixes: 9a67f6488eca926f ("mm: consolidate GFP_NOFAIL checks in the allocator slowpath")
> > Cc: stable # v4.11
> 
> I cannot say I would love how this gets convoluted but let's go with
> what you have here and think about a cleaner version later.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks!

Tested-by: Roman Gushchin <guro@fb.com>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
