Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9697E6B0033
	for <linux-mm@kvack.org>; Sat,  9 Dec 2017 08:17:24 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id g22so3496374lfk.0
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 05:17:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor2006396ljd.71.2017.12.09.05.17.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Dec 2017 05:17:22 -0800 (PST)
Message-ID: <1512825438.4168.14.camel@gmail.com>
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Sat, 09 Dec 2017 18:17:18 +0500
In-Reply-To: <b60ae517-b9ca-a07f-36cf-ed11eb3c9180@I-love.SAKURA.ne.jp>
References: <1512705038.7843.6.camel@gmail.com>
	 <20171208040556.GG19219@magnolia>
	 <b60ae517-b9ca-a07f-36cf-ed11eb3c9180@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2017-12-08 at 19:18 +0900, Tetsuo Handa wrote:
> Darrick J. Wong wrote:
> > On Fri, Dec 08, 2017 at 08:50:38AM +0500, mikhail wrote:
> > > Hi,
> > > 
> > > can anybody said what here happens?
> > > And which info needed for fixing it?
> > > Thanks.
> > > 
> > > [16712.376081] INFO: task tracker-store:27121 blocked for more
> > > than 120
> > > seconds.
> > > [16712.376088]       Not tainted 4.15.0-rc2-amd-vega+ #10
> > > [16712.376092] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > > disables this message.
> > > [16712.376095] tracker-store   D13400 27121   1843 0x00000000
> > > [16712.376102] Call Trace:
> > > [16712.376114]  ? __schedule+0x2e3/0xb90
> > > [16712.376123]  ? wait_for_completion+0x146/0x1e0
> > > [16712.376128]  schedule+0x2f/0x90
> > > [16712.376132]  schedule_timeout+0x236/0x540
> > > [16712.376143]  ? mark_held_locks+0x4e/0x80
> > > [16712.376147]  ? _raw_spin_unlock_irq+0x29/0x40
> > > [16712.376153]  ? wait_for_completion+0x146/0x1e0
> > > [16712.376158]  wait_for_completion+0x16e/0x1e0
> > > [16712.376162]  ? wake_up_q+0x70/0x70
> > > [16712.376204]  ? xfs_buf_read_map+0x134/0x2f0 [xfs]
> > > [16712.376234]  xfs_buf_submit_wait+0xaf/0x520 [xfs]
> > 
> > Stuck waiting for a directory block to read.  Slow disk?  Bad
> > media?
> > 
> 
> Most likely cause is that I/O was getting very slow due to memory
> pressure.
> Running memory consuming processes (e.g. web browsers) and file
> writing
> processes might generate stresses like this report.
> 
> I can't tell whether this report is a real deadlock/lockup or just a
> slowdown,
> for currently we don't have means for checking whether memory
> allocation was
> making progress or not.

It not just slowdown because after 5 hours I was still unable launch even htop.After executing command was nothing happens. I was even surprised that
dmesg could work.

> The OOM killer is not invoked for allocation requests without
> __GFP_FS flag.
> Therefore, GFP_NOIO / GFP_NOFS allocation requests have possibility
> of hanging
> up the system. We can reproduce such hang up using artificial stress
> (e.g.
> http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.
> SAKURA.ne.jp ),
> but this problem will not be addressed unless it is proven to occur
> using real
> workloads. It is a too much request for averaged users to prove that
> their systems
> hung up due to this problem.
> 
> In order to avoid silent hang up, Linux 4.9 got warn_alloc() calls
> which
> "synchronously" prints messages when a memory allocation request took
> more than
> 10 seconds. But since it was confirmed that concurrent warn_alloc()
> calls can
> hang up the system, warn_alloc() was reverted in Linux 4.15-rc1
> ( https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/
> commit/mm/page_alloc.c?id=400e22499dd92613 ).
> Therefore, unfortunately your kernel does not allow you to check
> whether memory
> allocation was making progress or not.
> 
> I have been proposing a watchdog which extends khungtaskd so that the
> system can
> print useful information "asynchronously" without locking up the
> system (e.g.
> http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-ke
> rnel@I-love.SAKURA.ne.jp
> http://lkml.kernel.org/r/1510833448-19918-1-git-send-email-penguin-ke
> rnel@I-love.SAKURA.ne.jp ).
> But since OOM livelock is the least attractive domain, I'm stuck with
> zero advocate.
> The watchdog did not get in time for obtaining information in your
> case, sorry.
> 
> For now, you can try setting /proc/sys/kernel/hung_task_warnings to
> -1, for the
> default setting of /proc/sys/kernel/hung_task_warnings is 10 which
> means that
> "INFO: task $commname:$pid blocked for more than 120 seconds." is
> printed for
> only 10 times (like this report did) and makes it impossible for
> users to judge
> whether the hung situation continued or not. There is SysRq-t and
> SysRq-m, but I
> don't expect that current SysRq can give you enough information for
> analyzing
> this problem.
> 

Thanks for the advice.
Decided to check what happens when I do SysRq-t.
SysRq-t produce a lot of the output even without running Google Chrome.
Such amout of data does not fit in the kernel output buffer and it's
impossible to read from the screen.

Demonstration: https://youtu.be/DUWB1WGBog0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
