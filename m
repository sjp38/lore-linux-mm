Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 891C36B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 05:18:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z25so7649231pgu.18
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 02:18:22 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bi5si5192206plb.130.2017.12.08.02.18.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 02:18:21 -0800 (PST)
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
References: <1512705038.7843.6.camel@gmail.com>
 <20171208040556.GG19219@magnolia>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <b60ae517-b9ca-a07f-36cf-ed11eb3c9180@I-love.SAKURA.ne.jp>
Date: Fri, 8 Dec 2017 19:18:15 +0900
MIME-Version: 1.0
In-Reply-To: <20171208040556.GG19219@magnolia>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>, mikhail <mikhail.v.gavrilov@gmail.com>
Cc: linux-xfs@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Darrick J. Wong wrote:
> On Fri, Dec 08, 2017 at 08:50:38AM +0500, mikhail wrote:
> > Hi,
> > 
> > can anybody said what here happens?
> > And which info needed for fixing it?
> > Thanks.
> > 
> > [16712.376081] INFO: task tracker-store:27121 blocked for more than 120
> > seconds.
> > [16712.376088]       Not tainted 4.15.0-rc2-amd-vega+ #10
> > [16712.376092] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > disables this message.
> > [16712.376095] tracker-store   D13400 27121   1843 0x00000000
> > [16712.376102] Call Trace:
> > [16712.376114]  ? __schedule+0x2e3/0xb90
> > [16712.376123]  ? wait_for_completion+0x146/0x1e0
> > [16712.376128]  schedule+0x2f/0x90
> > [16712.376132]  schedule_timeout+0x236/0x540
> > [16712.376143]  ? mark_held_locks+0x4e/0x80
> > [16712.376147]  ? _raw_spin_unlock_irq+0x29/0x40
> > [16712.376153]  ? wait_for_completion+0x146/0x1e0
> > [16712.376158]  wait_for_completion+0x16e/0x1e0
> > [16712.376162]  ? wake_up_q+0x70/0x70
> > [16712.376204]  ? xfs_buf_read_map+0x134/0x2f0 [xfs]
> > [16712.376234]  xfs_buf_submit_wait+0xaf/0x520 [xfs]
> 
> Stuck waiting for a directory block to read.  Slow disk?  Bad media?
> 

Most likely cause is that I/O was getting very slow due to memory pressure.
Running memory consuming processes (e.g. web browsers) and file writing
processes might generate stresses like this report.

I can't tell whether this report is a real deadlock/lockup or just a slowdown,
for currently we don't have means for checking whether memory allocation was
making progress or not.

The OOM killer is not invoked for allocation requests without __GFP_FS flag.
Therefore, GFP_NOIO / GFP_NOFS allocation requests have possibility of hanging
up the system. We can reproduce such hang up using artificial stress (e.g.
http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp ),
but this problem will not be addressed unless it is proven to occur using real
workloads. It is a too much request for averaged users to prove that their systems
hung up due to this problem.

In order to avoid silent hang up, Linux 4.9 got warn_alloc() calls which
"synchronously" prints messages when a memory allocation request took more than
10 seconds. But since it was confirmed that concurrent warn_alloc() calls can
hang up the system, warn_alloc() was reverted in Linux 4.15-rc1
( https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/mm/page_alloc.c?id=400e22499dd92613 ).
Therefore, unfortunately your kernel does not allow you to check whether memory
allocation was making progress or not.

I have been proposing a watchdog which extends khungtaskd so that the system can
print useful information "asynchronously" without locking up the system (e.g.
http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
http://lkml.kernel.org/r/1510833448-19918-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).
But since OOM livelock is the least attractive domain, I'm stuck with zero advocate.
The watchdog did not get in time for obtaining information in your case, sorry.

For now, you can try setting /proc/sys/kernel/hung_task_warnings to -1, for the
default setting of /proc/sys/kernel/hung_task_warnings is 10 which means that
"INFO: task $commname:$pid blocked for more than 120 seconds." is printed for
only 10 times (like this report did) and makes it impossible for users to judge
whether the hung situation continued or not. There is SysRq-t and SysRq-m, but I
don't expect that current SysRq can give you enough information for analyzing
this problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
