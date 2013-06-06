Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 0FFD36B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:11:35 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa11so1987047pad.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2013 13:11:34 -0700 (PDT)
Date: Thu, 6 Jun 2013 13:11:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] memcg: do not sleep on OOM waitqueue with full charge
 context
In-Reply-To: <20130606173355.GB27226@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1306061308320.9493@chino.kir.corp.google.com>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org> <1370488193-4747-2-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.02.1306052058340.25115@chino.kir.corp.google.com> <20130606053315.GB9406@cmpxchg.org> <20130606173355.GB27226@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 6 Jun 2013, Johannes Weiner wrote:

> > If the killing task or one of the sleeping tasks is holding a lock
> > that the selected victim needs in order to exit no progress can be
> > made.
> > 
> > The report we had a few months ago was that a task held the i_mutex
> > when trying to charge a page cache page and then invoked the OOM
> > handler and looped on CHARGE_RETRY.  Meanwhile, the selected victim
> > was just entering truncate() and now stuck waiting for the i_mutex.
> > 
> > I'll add this scenario to the changelog, hopefully it will make the
> > rest a little clearer.
> 
> David, is the updated patch below easier to understand?
> 

I don't understand why memcg is unique in this regard and it doesn't 
affect the page allocator as well on system oom conditions.  Ignoring 
memecg, all allocating processes will loop forever in the page allocator 
unless there are atypical gfp flags waiting for memory to be available, 
only one will call the oom killer at a time, a process is selected and 
killed, and the oom killer defers until that process exists because it 
finds TIF_MEMDIE.  Why is memcg charging any different?

> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] memcg: do not trap chargers with full callstack on OOM
> 
> The memcg OOM handling is incredibly fragile and can deadlock.  When a
> task fails to charge memory, it invokes the OOM killer and loops right
> there in the charge code until it succeeds.  Comparably, any other
> task that enters the charge path at this point will go to a waitqueue
> right then and there and sleep until the OOM situation is resolved.
> The problem is that these tasks may hold filesystem locks and the
> mmap_sem; locks that the selected OOM victim may need to exit.
> 
> For example, in one reported case, the task invoking the OOM killer
> was about to charge a page cache page during a write(), which holds
> the i_mutex.  The OOM killer selected a task that was just entering
> truncate() and trying to acquire the i_mutex:
> 
> OOM invoking task:
> [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
> [<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
> [<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
> [<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
> [<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
> [<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
> [<ffffffff81193a18>] ext3_write_begin+0x88/0x270
> [<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
> [<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
> [<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0           # takes ->i_mutex
> [<ffffffff8111156a>] do_sync_write+0xea/0x130
> [<ffffffff81112183>] vfs_write+0xf3/0x1f0
> [<ffffffff81112381>] sys_write+0x51/0x90
> [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> OOM kill victim:
> [<ffffffff811109b8>] do_truncate+0x58/0xa0              # takes i_mutex
> [<ffffffff81121c90>] do_last+0x250/0xa30
> [<ffffffff81122547>] path_openat+0xd7/0x440
> [<ffffffff811229c9>] do_filp_open+0x49/0xa0
> [<ffffffff8110f7d6>] do_sys_open+0x106/0x240
> [<ffffffff8110f950>] sys_open+0x20/0x30
> [<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> The OOM handling task will retry the charge indefinitely while the OOM
> killed task is not releasing any resources.
> 
> A similar scenario can happen when the kernel OOM killer for a memcg
> is disabled and a userspace task is in charge of resolving OOM
> situations.  In this case, ALL tasks that enter the OOM path will be
> made to sleep on the OOM waitqueue and wait for userspace to free
> resources or increase the group's limit.  But a userspace OOM handler
> is prone to deadlock itself on the locks held by the waiting tasks.
> For example one of the sleeping tasks may be stuck in a brk() call
> with the mmap_sem held for writing but the userspace handler, in order
> to pick an optimal victim, may need to read files from /proc/<pid>,
> which tries to acquire the same mmap_sem for reading and deadlocks.
> 
> This patch changes the way tasks behave after detecting an OOM and
> makes sure nobody loops or sleeps on OOM with locks held:
> 
> 1. When OOMing in a system call (buffered IO and friends), invoke the
>    OOM killer but just return -ENOMEM, never sleep on a OOM waitqueue.
>    Userspace should be able to handle this and it prevents anybody
>    from looping or waiting with locks held.
> 
> 2. When OOMing in a page fault, invoke the OOM killer and restart the
>    fault instead of looping on the charge attempt.  This way, the OOM
>    victim can not get stuck on locks the looping task may hold.
> 
> 3. When detecting an OOM in a page fault but somebody else is handling
>    it (either the kernel OOM killer or a userspace handler), don't go
>    to sleep in the charge context.  Instead, remember the OOMing memcg
>    in the task struct and then fully unwind the page fault stack with
>    -ENOMEM.  pagefault_out_of_memory() will then call back into the
>    memcg code to check if the -ENOMEM came from the memcg, and then
>    either put the task to sleep on the memcg's OOM waitqueue or just
>    restart the fault.  The OOM victim can no longer get stuck on any
>    lock a sleeping task may hold.
> 
> While reworking the OOM routine, also remove a needless OOM waitqueue
> wakeup when invoking the killer.  Only uncharges and limit increases,
> things that actually change the memory situation, should do wakeups.
> 
> Reported-by: Reported-by: azurIt <azurit@pobox.sk>
> Debugged-by: Michal Hocko <mhocko@suse.cz>
> Reported-by: David Rientjes <rientjes@google.com>

What exactly did I report?  This isn't at all what 
memory.oom_delay_millisecs is about, which is a failure of userspace to 
respond to the condition and react in time, not because it's stuck on any 
lock.  We still need that addition regardless of what you're doing here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
