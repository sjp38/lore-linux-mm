Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 524726B0256
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 18:43:48 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so227189072pac.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 15:43:48 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id id4si52370072pbb.33.2015.10.06.15.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 15:43:47 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so227188814pac.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 15:43:47 -0700 (PDT)
Date: Tue, 6 Oct 2015 15:43:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: ksm: deadlock in oom killing process while breaking ksm
 pages
In-Reply-To: <alpine.LSU.2.11.1510050011280.17707@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510061533230.10181@eggly.anvils>
References: <560D448F.9050507@oracle.com> <alpine.LSU.2.11.1510050011280.17707@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 5 Oct 2015, Hugh Dickins wrote:
> On Thu, 1 Oct 2015, Sasha Levin wrote:
> 
> > Hi Hugh,
> > 
> > I've hit this (actual) lockup during testing. It seems that we were trying to allocate
> > a new page to break KSM on an existing page, ended up in the oom killer who killed our
> > process, and locked up in __ksm_exit() trying to get a write lock while already holding
> > a read lock.
> > 
> > A very similar scenario is presented in the patch that introduced this behaviour
> > (9ba6929480 ("ksm: fix oom deadlock")):
> > 
> >     There's a now-obvious deadlock in KSM's out-of-memory handling:
> >     imagine ksmd or KSM_RUN_UNMERGE handling, holding ksm_thread_mutex,
> >     trying to allocate a page to break KSM in an mm which becomes the
> >     OOM victim (quite likely in the unmerge case): it's killed and goes
> >     to exit, and hangs there waiting to acquire ksm_thread_mutex.
> > 
> > So I'm guessing that the solution is incomplete for the slow path.
> 
> Thank you, Sasha, this is a nice one.  I've only just started ruminating
> on it, will do so (intermittently!) for a few days.  Maybe the answer
> will be to take an additional reference to the mm when unmerging; but
> done wrong that can frustrate OOM freeing memory altogether, so it's
> not a solution I'll rush into without consideration.

I do believe that nice Mr Oleg Nesterov is getting me off the hook
for this one.  He even mentioned __ksm_exit() in an earlier version
of his patch.  Just a temporary blip in the next tree, which should
soon be fixed by https://lkml.org/lkml/2015/10/6/548

Thank you, Oleg!
Hugh

> 
> Plus it's not clear to me yet whether it can only be a problem when
> unmerging, or could hit other calls to break_ksm().  I do have a
> v3.9-era patch to remove all the calls to break_cow(), but IIRC
> it's a patch I didn't quite get working reliably at the time.
> 
> This does reinforce my suspicion that, one way or another, you
> happen to be targetting trinity at ksm more effectively these days:
> I don't see any cause for alarm over recent kernel changes yet.
> 
> > 
> > [3201844.610523] =============================================
> > [3201844.610988] [ INFO: possible recursive locking detected ]
> > [3201844.611405] 4.3.0-rc3-next-20150930-sasha-00077-g3434920 #4 Not tainted
> > [3201844.611907] ---------------------------------------------
> > [3201844.612373] ksm02/28830 is trying to acquire lock:
> > [3201844.612749] (&mm->mmap_sem){++++++}, at: __ksm_exit (mm/ksm.c:1821)
> > [3201844.613472] RWsem: count: 1 owner: None
> > [3201844.613782]
> > [3201844.613782] but task is already holding lock:
> > [3201844.614248] (&mm->mmap_sem){++++++}, at: run_store (mm/ksm.c:769 mm/ksm.c:2124)
> > [3201844.614904] RWsem: count: 1 owner: None
> > [3201844.615212]
> > [3201844.615212] other info that might help us debug this:
> > [3201844.615727]  Possible unsafe locking scenario:
> > [3201844.615727]
> > [3201844.616240]        CPU0
> > [3201844.616446]        ----
> > [3201844.616650]   lock(&mm->mmap_sem);
> > [3201844.616952]   lock(&mm->mmap_sem);
> > [3201844.617252]
> > [3201844.617252]  *** DEADLOCK ***
> > [3201844.617252]
> > [3201844.617733]  May be due to missing lock nesting notation
> > [3201844.617733]
> > [3201844.618265] 6 locks held by ksm02/28830:
> > [3201844.618576] #0: (sb_writers#5){.+.+.+}, at: __sb_start_write (fs/super.c:1176)
> > [3201844.619327] RWsem: count: 0 owner: None
> > [3201844.619633] #1: (&of->mutex){+.+.+.}, at: kernfs_fop_write (fs/kernfs/file.c:298)
> > [3201844.624648] Mutex: counter: 0 owner: ksm02
> > [3201844.624978] #2: (s_active#448){.+.+.+}, at: kernfs_fop_write (fs/kernfs/file.c:298)
> > [3201844.625733] #3: (ksm_thread_mutex){+.+.+.}, at: run_store (mm/ksm.c:2120)
> > [3201844.626448] Mutex: counter: -1 owner: ksm02
> > [3201844.626786] #4: (&mm->mmap_sem){++++++}, at: run_store (mm/ksm.c:769 mm/ksm.c:2124)
> > [3201844.627486] RWsem: count: 1 owner: None
> > [3201844.627792] #5: (oom_lock){+.+...}, at: __alloc_pages_nodemask (mm/page_alloc.c:2779 mm/page_alloc.c:3213 mm/page_alloc.c:3300)
> > [3201844.628594] Mutex: counter: 0 owner: ksm02
> > [3201844.628919]
> > [3201844.628919] stack backtrace:
> > [3201844.629276] CPU: 0 PID: 28830 Comm: ksm02 Not tainted 4.3.0-rc3-next-20150930-sasha-00077-g3434920 #4
> > [3201844.629970]  ffffffffaf41d680 00000000b8d5e1f1 ffff88065e42eec0 ffffffffa1d454c8
> > [3201844.630663]  ffffffffaf41d680 ffff88065e42f080 ffffffffa04269ee ffff88065e42f088
> > [3201844.631292]  ffffffffa0427746 ffff882c88b24008 ffff8806845b8e10 ffffffffafb842c0
> > [3201844.631952] Call Trace:
> > [3201844.632204] dump_stack (lib/dump_stack.c:52)
> > [3201844.636449] __lock_acquire (kernel/locking/lockdep.c:1776 kernel/locking/lockdep.c:1820 kernel/locking/lockdep.c:2152 kernel/locking/lockdep.c:3239)
> > [3201844.639909] lock_acquire (kernel/locking/lockdep.c:3620)
> > [3201844.640997] down_write (./arch/x86/include/asm/rwsem.h:130 kernel/locking/rwsem.c:51)
> > [3201844.642011] __ksm_exit (mm/ksm.c:1821)
> > [3201844.642501] mmput (./arch/x86/include/asm/bitops.h:311 include/linux/khugepaged.h:35 kernel/fork.c:701)
> 
> I assume this interesting reference to khugepaged_exit()
> is just one of those off-by-one-line things?
> 
> > [3201844.642920] oom_kill_process (mm/oom_kill.c:604)
> > [3201844.644528] out_of_memory (mm/oom_kill.c:700)
> > [3201844.646626] __alloc_pages_nodemask (mm/page_alloc.c:2822 mm/page_alloc.c:3213 mm/page_alloc.c:3300)
> > [3201844.649972] alloc_pages_vma (mm/mempolicy.c:2044)
> > [3201844.650462] ? wp_page_copy.isra.36 (mm/memory.c:2074)
> > [3201844.651000] wp_page_copy.isra.36 (mm/memory.c:2074)
> > [3201844.652544] do_wp_page (mm/memory.c:2349)
> > [3201844.654048] handle_mm_fault (mm/memory.c:3310 mm/memory.c:3404 mm/memory.c:3433)
> > [3201844.657519] break_ksm (mm/ksm.c:374)
> > [3201844.659348] unmerge_ksm_pages (mm/ksm.c:673)
> > [3201844.659831] run_store (mm/ksm.c:776 mm/ksm.c:2124)
> > [3201844.661837] kobj_attr_store (lib/kobject.c:792)
> > [3201844.662743] sysfs_kf_write (fs/sysfs/file.c:131)
> > [3201844.663656] kernfs_fop_write (fs/kernfs/file.c:312)
> > [3201844.664154] __vfs_write (fs/read_write.c:489)
> > [3201844.666502] vfs_write (fs/read_write.c:539)
> > [3201844.666935] SyS_write (fs/read_write.c:586 fs/read_write.c:577)
> > [3201844.668965] tracesys_phase2 (arch/x86/entry/entry_64.S:270)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
