Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id D6ADE6B0038
	for <linux-mm@kvack.org>; Sun, 13 Dec 2015 09:27:05 -0500 (EST)
Received: by ioae126 with SMTP id e126so20543923ioa.1
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 06:27:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k9si16703979igx.15.2015.12.13.06.27.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 13 Dec 2015 06:27:04 -0800 (PST)
Subject: Re: [PATCH v4] mm,oom: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp>
	<20151212170032.GB7107@cmpxchg.org>
In-Reply-To: <20151212170032.GB7107@cmpxchg.org>
Message-Id: <201512132326.AHJ86403.OFFVJOLQHSMFtO@I-love.SAKURA.ne.jp>
Date: Sun, 13 Dec 2015 23:26:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com, arekm@maven.pl

Johannes Weiner wrote:
> On Sun, Dec 13, 2015 at 12:33:04AM +0900, Tetsuo Handa wrote:
> > +Currently, when something went wrong inside memory allocation request,
> > +the system will stall with either 100% CPU usage (if memory allocating
> > +tasks are doing busy loop) or 0% CPU usage (if memory allocating tasks
> > +are waiting for file data to be flushed to storage).
> > +But /proc/sys/kernel/hung_task_warnings is not helpful because memory
> > +allocating tasks unlikely sleep in uninterruptible state for
> > +/proc/sys/kernel/hung_task_timeout_secs seconds.
> 
> Yes, this is very annoying. Other tasks in the system get dumped out
> as they are blocked for too long, but not the allocating task itself
> as it's busy looping.
> 

Off-topic, but judging from my experience at support center, people are not
utilizing hung task detector well. Since /proc/sys/kernel/hung_task_warnings
is defaulted to 10 and people are using it with default value, hung task
detector complains nothing because hung_task_warnings is likely already 0
when their systems hang up after many days/months...

> That being said, I'm not entirely sure why we need daemon to do this,
> which then requires us to duplicate allocation state to task_struct.

I thought doing this using timer interrupt (i.e. add_timer()/del_timer())
because allocating tasks can be blocked at locks (e.g. mutex_lock()) or
loops (e.g. too_many_isolated() in shrink_inactive_list()).

  [   99.793156] MemAlloc: write(3787) seq=46308 gfp=0x2400240 order=0 delay=30798 uninterruptible exiting
  [   99.795428] write           D ffff880075c974b8     0  3787   3786 0x20020086
  [   99.797381]  ffff880075c974b8 ffff880035d98000 ffff8800777995c0 ffff880075c98000
  [   99.799459]  ffff880075c974f0 ffff88007fc10240 00000000fffcf09e 0000000000000000
  [   99.801518]  ffff880075c974d0 ffffffff816f4127 ffff88007fc10240 ffff880075c97578
  [   99.803571] Call Trace:
  [   99.804605]  [<ffffffff816f4127>] schedule+0x37/0x90
  [   99.806102]  [<ffffffff816f8427>] schedule_timeout+0x117/0x1c0
  [   99.807738]  [<ffffffff810dfbc0>] ? init_timer_key+0x40/0x40
  [   99.809332]  [<ffffffff816f8554>] schedule_timeout_uninterruptible+0x24/0x30
  [   99.811199]  [<ffffffff81147eba>] __alloc_pages_nodemask+0x8ba/0xc80
  [   99.812940]  [<ffffffff8118f2c6>] alloc_pages_current+0x96/0x1b0
  [   99.814621]  [<ffffffff812e3e64>] xfs_buf_allocate_memory+0x170/0x29f
  [   99.816373]  [<ffffffff812ac204>] xfs_buf_get_map+0xe4/0x140
  [   99.817981]  [<ffffffff812ac7e9>] xfs_buf_read_map+0x29/0xd0
  [   99.819603]  [<ffffffff812d65c7>] xfs_trans_read_buf_map+0x97/0x1a0
  [   99.821326]  [<ffffffff81286b53>] xfs_btree_read_buf_block.constprop.28+0x73/0xc0
  [   99.823262]  [<ffffffff81286c1b>] xfs_btree_lookup_get_block+0x7b/0xf0
  [   99.825029]  [<ffffffff8128b15b>] xfs_btree_lookup+0xbb/0x500
  [   99.826662]  [<ffffffff8127561c>] ? xfs_allocbt_init_cursor+0x3c/0xc0
  [   99.828430]  [<ffffffff81273c3b>] xfs_free_ag_extent+0x6b/0x5f0
  [   99.830053]  [<ffffffff81274fb4>] xfs_free_extent+0xf4/0x120
  [   99.831734]  [<ffffffff812d6b31>] xfs_trans_free_extent+0x21/0x60
  [   99.833453]  [<ffffffff812a8eca>] xfs_bmap_finish+0xfa/0x120
  [   99.835087]  [<ffffffff812bda7d>] xfs_itruncate_extents+0x10d/0x190
  [   99.836812]  [<ffffffff812a9bf5>] xfs_free_eofblocks+0x1d5/0x240
  [   99.838494]  [<ffffffff812bdc9f>] xfs_release+0x8f/0x150
  [   99.840017]  [<ffffffff812af330>] xfs_file_release+0x10/0x20
  [   99.841593]  [<ffffffff811c1018>] __fput+0xb8/0x230
  [   99.843071]  [<ffffffff811c11c9>] ____fput+0x9/0x10
  [   99.844449]  [<ffffffff8108d922>] task_work_run+0x72/0xa0
  [   99.845968]  [<ffffffff81071a91>] do_exit+0x2f1/0xb50
  [   99.847406]  [<ffffffff81072377>] do_group_exit+0x47/0xc0
  [   99.848883]  [<ffffffff8107dc22>] get_signal+0x222/0x7e0
  [   99.850406]  [<ffffffff8100f362>] do_signal+0x32/0x670
  [   99.851900]  [<ffffffff8106a3c7>] ? syscall_slow_exit_work+0x4b/0x10d
  [   99.853600]  [<ffffffff811c1b9c>] ? __sb_end_write+0x1c/0x20
  [   99.855142]  [<ffffffff8106a31a>] ? exit_to_usermode_loop+0x2e/0x90
  [   99.856778]  [<ffffffff8106a338>] exit_to_usermode_loop+0x4c/0x90
  [   99.858399]  [<ffffffff810036f2>] do_syscall_32_irqs_off+0x122/0x190
  [   99.860055]  [<ffffffff816fbc38>] entry_INT80_compat+0x38/0x50
  [   99.861630] 3 locks held by write/3787:
  [   99.863151]  #0:  (sb_internal){.+.+.?}, at: [<ffffffff811c2b3c>] __sb_start_write+0xcc/0xe0
  [   99.865391]  #1:  (&(&ip->i_iolock)->mr_lock){++++++}, at: [<ffffffff812bb629>] xfs_ilock_nowait+0x59/0x140
  [   99.867910]  #2:  (&xfs_nondir_ilock_class){++++--}, at: [<ffffffff812bb4ff>] xfs_ilock+0x7f/0xe0
  [   99.871842] MemAlloc: write(3788) uninterruptible dying victim
  [   99.873491] write           D ffff8800793cbcb8     0  3788   3786 0x20120084
  [   99.875414]  ffff8800793cbcb8 ffffffff81c11500 ffff8800766b0000 ffff8800793cc000
  [   99.877443]  ffff88007a9e76b0 ffff8800766b0000 0000000000000246 00000000ffffffff
  [   99.879460]  ffff8800793cbcd0 ffffffff816f4127 ffff88007a9e76a8 ffff8800793cbce0
  [   99.881472] Call Trace:
  [   99.882543]  [<ffffffff816f4127>] schedule+0x37/0x90
  [   99.883993]  [<ffffffff816f4450>] schedule_preempt_disabled+0x10/0x20
  [   99.885726]  [<ffffffff816f51db>] mutex_lock_nested+0x17b/0x3e0
  [   99.887342]  [<ffffffff812b0b7f>] ? xfs_file_buffered_aio_write+0x5f/0x1f0
  [   99.889125]  [<ffffffff812b0b7f>] xfs_file_buffered_aio_write+0x5f/0x1f0
  [   99.890874]  [<ffffffff812b0d94>] xfs_file_write_iter+0x84/0x140
  [   99.892498]  [<ffffffff811be7b7>] __vfs_write+0xc7/0x100
  [   99.894013]  [<ffffffff811bf21d>] vfs_write+0x9d/0x190
  [   99.895482]  [<ffffffff811deb0a>] ? __fget_light+0x6a/0x90
  [   99.897020]  [<ffffffff811c0133>] SyS_write+0x53/0xd0
  [   99.898469]  [<ffffffff8100362f>] do_syscall_32_irqs_off+0x5f/0x190
  [   99.900133]  [<ffffffff816fbc38>] entry_INT80_compat+0x38/0x50
  [   99.901752] 2 locks held by write/3788:
  [   99.903061]  #0:  (sb_writers#8){.+.+.+}, at: [<ffffffff811c2b3c>] __sb_start_write+0xcc/0xe0
  [   99.905412]  #1:  (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff812b0b7f>] xfs_file_buffered_aio_write+0x5f/0x1f0

But I realized that trying to printk() from timer interrupt generates
unreadable/corrupted dumps because there could be thousands of tasks to
report (e.g. when we entered into OOM livelock) while we don't want to do
busy loop inside timer interrupt for serializing printk().

  [  211.563810] MemAlloc-Info: 3914 stalling task, 0 dying task, 1 victim task.

Same thing would happen for warn_alloc_failed() approach when many tasks
called warn_alloc_failed() at the same time...

> There is no scenario where the allocating task is not moving at all
> anymore, right? So can't we dump the allocation state from within the
> allocator and leave the rest to the hung task detector?

I don't think we can reliably get information with hung task detector
approach.

Duplicating allocation state to task_struct allows us to keep information
about last memory allocation request. That is, we will get some hint for
understanding last-minute behavior of the kernel when we analyze vmcore
(or memory snapshot of a virtualized machine).

Besides that, duplicating allocation state to task_struct will allow OOM killer
(a task calling select_bad_process()) to check whether the candidate is stuck
(e.g. http://lkml.kernel.org/r/201505232339.DAB00557.VFFLHMSOJFOOtQ@I-love.SAKURA.ne.jp ),
compared to current situation (i.e. whether the candidate already has TIF_MEMDIE
or not).

"[PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks" tried to judge it
using the candidate's task state but was not accepted. I already showed that it
is not difficult to defeat OOM reaper using "mmap_sem livelock case" and "least
memory consuming victim case". We will eventually need to consider timeout based
next OOM victim selection...

Even if we don't use a daemon, I think that duplicating allocation state
itself is helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
