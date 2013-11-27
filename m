Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 764346B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 08:31:09 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so4714658eaj.21
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 05:31:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p1si25011726eey.67.2013.11.27.05.31.08
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 05:31:08 -0800 (PST)
Date: Wed, 27 Nov 2013 13:31:02 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cpuset: Fix memory allocator deadlock
Message-ID: <20131127133102.GB11295@suse.de>
References: <20131126140341.GL10022@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131126140341.GL10022@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, John Stultz <john.stultz@linaro.org>, Juri Lelli <juri.lelli@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 26, 2013 at 03:03:41PM +0100, Peter Zijlstra wrote:
> Juri hit the below lockdep report:
> 
> [    4.303391] ======================================================
> [    4.303392] [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
> [    4.303394] 3.12.0-dl-peterz+ #144 Not tainted
> [    4.303395] ------------------------------------------------------
> [    4.303397] kworker/u4:3/689 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
> [    4.303399]  (&p->mems_allowed_seq){+.+...}, at: [<ffffffff8114e63c>] new_slab+0x6c/0x290
> [    4.303417]
> [    4.303417] and this task is already holding:
> [    4.303418]  (&(&q->__queue_lock)->rlock){..-...}, at: [<ffffffff812d2dfb>] blk_execute_rq_nowait+0x5b/0x100
> [    4.303431] which would create a new lock dependency:
> [    4.303432]  (&(&q->__queue_lock)->rlock){..-...} -> (&p->mems_allowed_seq){+.+...}
> [    4.303436]
> 
> [    4.303898] the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
> [    4.303918] -> (&p->mems_allowed_seq){+.+...} ops: 2762 {
> [    4.303922]    HARDIRQ-ON-W at:
> [    4.303923]                     [<ffffffff8108ab9a>] __lock_acquire+0x65a/0x1ff0
> [    4.303926]                     [<ffffffff8108cbe3>] lock_acquire+0x93/0x140
> [    4.303929]                     [<ffffffff81063dd6>] kthreadd+0x86/0x180
> [    4.303931]                     [<ffffffff816ded6c>] ret_from_fork+0x7c/0xb0
> [    4.303933]    SOFTIRQ-ON-W at:
> [    4.303933]                     [<ffffffff8108abcc>] __lock_acquire+0x68c/0x1ff0
> [    4.303935]                     [<ffffffff8108cbe3>] lock_acquire+0x93/0x140
> [    4.303940]                     [<ffffffff81063dd6>] kthreadd+0x86/0x180
> [    4.303955]                     [<ffffffff816ded6c>] ret_from_fork+0x7c/0xb0
> [    4.303959]    INITIAL USE at:
> [    4.303960]                    [<ffffffff8108a884>] __lock_acquire+0x344/0x1ff0
> [    4.303963]                    [<ffffffff8108cbe3>] lock_acquire+0x93/0x140
> [    4.303966]                    [<ffffffff81063dd6>] kthreadd+0x86/0x180
> [    4.303969]                    [<ffffffff816ded6c>] ret_from_fork+0x7c/0xb0
> [    4.303972]  }
> 
> Which reports that we take mems_allowed_seq with interrupts enabled. A
> little digging found that this can only be from
> cpuset_change_task_nodemask().
> 
> This is an actual deadlock because an interrupt doing an allocation will
> hit get_mems_allowed()->...->__read_seqcount_begin(), which will spin
> forever waiting for the write side to complete.
> 
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Reported-by: Juri Lelli <juri.lelli@gmail.com>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
