Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id E73B26B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 01:39:00 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so9774986pbb.28
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 22:39:00 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id sg3si32877646pbb.103.2013.11.26.22.38.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 22:38:59 -0800 (PST)
Message-ID: <52959328.3090407@huawei.com>
Date: Wed, 27 Nov 2013 14:37:28 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] cpuset: Fix memory allocator deadlock
References: <20131126140341.GL10022@twins.programming.kicks-ass.net>
In-Reply-To: <20131126140341.GL10022@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tejun Heo <tj@kernel.org>, John Stultz <john.stultz@linaro.org>, Mel
 Gorman <mgorman@suse.de>, Juri Lelli <juri.lelli@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2013/11/26 22:03, Peter Zijlstra wrote:
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

Yeah, the other one in set_mems_allowed() was fixed by John.

> This is an actual deadlock because an interrupt doing an allocation will
> hit get_mems_allowed()->...->__read_seqcount_begin(), which will spin
> forever waiting for the write side to complete.
> 
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Reported-by: Juri Lelli <juri.lelli@gmail.com>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>

Acked-by: Li Zefan <lizefan@huawei.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
