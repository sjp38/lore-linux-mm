Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 458456B0069
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:38:00 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so22735491pfx.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 03:38:00 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m20si52463313pli.206.2016.12.14.03.37.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 03:37:59 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
	<20161212125535.GA3185@dhcp22.suse.cz>
	<20161212131910.GC3185@dhcp22.suse.cz>
	<201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
	<20161214093706.GA16064@pathway.suse.cz>
In-Reply-To: <20161214093706.GA16064@pathway.suse.cz>
Message-Id: <201612142037.EED00059.VJMOFLtSOQFFOH@I-love.SAKURA.ne.jp>
Date: Wed, 14 Dec 2016 20:37:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pmladek@suse.com
Cc: mhocko@suse.com, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

Petr Mladek wrote:
> On Tue 2016-12-13 21:06:57, Tetsuo Handa wrote:
> > Uptime > 400 are testcases where the stresser was invoked via "taskset -c 0".
> > Since there are some "** XXX printk messages dropped **" messages, I can't
> > tell whether the OOM killer was able to make forward progress. But guessing
> >  from the result that there is no corresponding "Killed process" line for
> > "Out of memory: " line at uptime = 450 and the duration of PID 14622 stalled,
> > I think it is OK to say that the system got stuck because the OOM killer was
> > not able to make forward progress.
> 
> I am afraid that as long as you see "** XXX printk messages dropped
> **" then there is something that is able to keep warn_alloc() busy,
> never leave the printk()/console_unlock() and and block OOM killer
> progress.

Excuse me, but it is not warn_alloc() but functions that call printk()
which are kept busy with oom_lock held (e.g. oom_kill_process()).

----------
[ 1845.191495] MemAlloc: a.out(15607) flags=0x400040 switches=18863 seq=3 gfp=0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) order=0 delay=604455
[ 1845.191498] a.out           R  running task    11824 15607  14625 0x00000080
[ 1845.191498] Call Trace:
[ 1845.191500]  ? __schedule+0x23f/0xba0
[ 1845.191501]  preempt_schedule_common+0x1f/0x32
[ 1845.191502]  _cond_resched+0x1d/0x30
[ 1845.191503]  console_unlock+0x257/0x620
[ 1845.191504]  vprintk_emit+0x33a/0x520
[ 1845.191505]  vprintk_default+0x1a/0x20
[ 1845.191506]  printk+0x58/0x6f
[ 1845.191507]  show_mem+0xb7/0xf0
[ 1845.191508]  dump_header+0xa0/0x3de
[ 1845.191509]  ? trace_hardirqs_on+0xd/0x10
[ 1845.191510]  oom_kill_process+0x226/0x500
[ 1845.191511]  out_of_memory+0x140/0x5a0
[ 1845.191512]  ? out_of_memory+0x210/0x5a0
[ 1845.191513]  __alloc_pages_nodemask+0x1077/0x10e0
[ 1845.191514]  cache_grow_begin+0xcf/0x630
[ 1845.191515]  ? ____cache_alloc_node+0x1bf/0x240
[ 1845.191515]  fallback_alloc+0x1e5/0x290
[ 1845.191516]  ____cache_alloc_node+0x235/0x240
[ 1845.191534]  ? kmem_zone_alloc+0x91/0x120 [xfs]
[ 1845.191535]  kmem_cache_alloc+0x26c/0x3e0
[ 1845.191551]  kmem_zone_alloc+0x91/0x120 [xfs]
[ 1845.191567]  xfs_trans_alloc+0x68/0x130 [xfs]
[ 1845.191584]  xfs_iomap_write_allocate+0x209/0x390 [xfs]
[ 1845.191596]  ? xfs_bmbt_get_all+0x13/0x20 [xfs]
[ 1845.191611]  ? xfs_map_blocks+0xf6/0x4d0 [xfs]
[ 1845.191612]  ? rcu_read_lock_sched_held+0x91/0xa0
[ 1845.191625]  xfs_map_blocks+0x211/0x4d0 [xfs]
[ 1845.191639]  xfs_do_writepage+0x1e0/0x870 [xfs]
[ 1845.191640]  write_cache_pages+0x24a/0x680
[ 1845.191653]  ? xfs_aops_discard_page+0x140/0x140 [xfs]
[ 1845.191666]  xfs_vm_writepages+0x66/0xa0 [xfs]
[ 1845.191667]  do_writepages+0x1c/0x30
[ 1845.191668]  __filemap_fdatawrite_range+0xc1/0x100
[ 1845.191669]  filemap_write_and_wait_range+0x28/0x60
[ 1845.191692]  xfs_file_fsync+0x86/0x310 [xfs]
[ 1845.191694]  vfs_fsync_range+0x38/0xa0
[ 1845.191696]  ? return_from_SYSCALL_64+0x2d/0x7a
[ 1845.191697]  do_fsync+0x38/0x60
[ 1845.191698]  SyS_fsync+0xb/0x10
[ 1845.191699]  do_syscall_64+0x67/0x1f0
[ 1845.191700]  entry_SYSCALL64_slow_path+0x25/0x25
----------

> 
> > ----------
> > [  450.767693] Out of memory: Kill process 14642 (a.out) score 999 or sacrifice child
> > [  450.769974] Killed process 14642 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [  450.776538] oom_reaper: reaped process 14642 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  450.781170] Out of memory: Kill process 14643 (a.out) score 999 or sacrifice child
> > [  450.783469] Killed process 14643 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [  450.787912] oom_reaper: reaped process 14643 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  450.792630] Out of memory: Kill process 14644 (a.out) score 999 or sacrifice child
> > [  450.964031] a.out: page allocation stalls for 10014ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > [  450.964033] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > (...snipped...)
> > [  740.984902] a.out: page allocation stalls for 300003ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > [  740.984905] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > ----------
> > 
> > Although it is fine to make warn_alloc() less verbose, this is not
> > a problem which can be avoided by simply reducing printk(). Unless
> > we give enough CPU time to the OOM killer and OOM victims, it is
> > trivial to lockup the system.
> 
> You could try to use printk_deferred() in warn_alloc(). It will not
> handle console. It will help to be sure that the blocked printk()
> is the main problem.

If we can map all printk() called inside oom_kill_process() to printk_deferred(),
we can avoid cond_resched() inside console_unlock() with oom_lock held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
