Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A76E76B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:26:06 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o8-v6so18053484wra.12
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:26:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 23si12328600edt.285.2018.04.23.05.26.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 05:26:04 -0700 (PDT)
Date: Mon, 23 Apr 2018 14:26:00 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180423122600.sozmrytiasd32bhc@pathway.suse.cz>
References: <20180413124704.19335-1-pmladek@suse.com>
 <20180413101233.0792ebf0@gandalf.local.home>
 <20180414023516.GA17806@tigerII.localdomain>
 <20180416014729.GB1034@jagdpanzerIV>
 <20180416042553.GA555@jagdpanzerIV>
 <20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
 <20180420021511.GB6397@jagdpanzerIV>
 <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
 <20180423052133.GA3643@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423052133.GA3643@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon 2018-04-23 14:21:33, Sergey Senozhatsky wrote:
> On (04/20/18 11:12), Petr Mladek wrote:
> call_console_drivers() is super complex, unbelievable complex. In fact,
> it's so complex that we never know where we will end up, because it can
> pass the control to almost every core kernel mechanism or subsystem:

I fully agree. We will never be able to completely avoid messages
from these code paths and it would even be contra-productive. People
need to see the problems and be able to debug them. BTW: I wrote
this in the patch description.

> A very quick googling:

Nice collection. Just note that the useful (ratelimited) information
always fits into the first 100 lines in all these examples:

> 	https://bugzilla.altlinux.org/attachment.cgi?id=5811

The two WARNINGs starts repeating after 65 lines.

Note that the backtraces at the end of the log are from
NMI watchdog => not ratelimited by this patch (with the extra fix)


> 	https://access.redhat.com/solutions/702533

fits into 52 lines

> 	https://bugzilla.redhat.com/attachment.cgi?id=561164

both warnings fit into 54 lines

> 	https://lists.gt.net/linux/kernel/2341113

BUG report fits into 26 lines

> 	https://www.systutorials.com/linux-kernels/56987/ib-mlx4-reduce-sriov-multicast-cleanup-warning-message-to-debug-level-linux-4-10-17/

NMI bactrace => not affected by this patch (with the extra fix)

> 	https://github.com/raspberrypi/linux/issues/663

Bug report fits into 29 lines

> 	https://bugs.openvz.org/browse/VZWEB-36

Starts to repeat after 79 lines. I wonder if it ever ended without
killing the system.




> Throttling down that error mechanism to 100 lines
> per hour, or 1000 lines per hour is unlikely will be welcomed.

I wonder if you have bigger problems with the number of lines
or with the length of the period.

We simply _must_ limit the number of lines. Otherwise we would
never be able to break an _infinite_ loop.

But we could eventually replace the time period with a more
complex solution. For example, if we call console drivers
outside printk_safe context then the "recursive" messages
will be written to the mail log buffer directly. Then we could
reset the counter of the recursive messages when leaving
console_unlock() the regular way. I mean when all lines are
handled.


> Among all the patches and proposal that we saw so far, one stands out - it's
> the original Tejun's patch [offloading to work queue]. Because it has zero
> interference with the existing call_console_drivers()->printk()
> channels.

The only problem is that it does not solve the infinite loop. If
writing one line produces one or more new lines (warnings/errors)
than the only way out is to start dropping the recursive messages.
Offloading would just move the infinite loop to another process.

Note that the offload might help if there is a deadlock/livelock
between the original printk() caller and console drivers. Then moving
console_unlock() to another "safe" context helps to unblock the
situation. But the offload has its own problems and limiting
the number of recursive messages would solve this as well.


> What is so special about this case that we decided to screw up printk()
> instead?

There are many situations where printk() is limited. For example, we
are limited to 8kB in NMI or printk_safe() context. The printk_safe()
context is about printk debugging. Also messages from console drivers
are about printk debugging. There must be some limitations by
definition.


> I think that we need to apply the patch below.
> That call_console_drivers()->printk->IRQ_work->irq->flush appears to be
> pointless.

I agree that calling console drivers in printk_safe context is
pointless. Normal vprintk_emit() can be safely called because
logbuf_lock is not taken here. Also console_unlock() will
never by called recursively because it is guarded by console_sem.

> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  kernel/printk/printk.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 247808333ba4..484c456c095a 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -2385,9 +2385,11 @@ void console_unlock(void)
>  		 */
>  		console_lock_spinning_enable();
>  
> +		__printk_safe_exit();
>  		stop_critical_timings();	/* don't trace print latency */
>  		call_console_drivers(ext_text, ext_len, text, len);
>  		start_critical_timings();
> +		__printk_safe_enter();

Is this by intention? What is the reason to call
console_lock_spinning_disable_and_check() in printk_safe() context, please?

>  		if (console_lock_spinning_disable_and_check()) {
>  			printk_safe_exit_irqrestore(flags);

Best Regards,
Petr
