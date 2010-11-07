Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E408C6B0087
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 13:20:35 -0500 (EST)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oA7HxHdf006804
	for <linux-mm@kvack.org>; Sun, 7 Nov 2010 12:59:17 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oA7IKVj7313974
	for <linux-mm@kvack.org>; Sun, 7 Nov 2010 13:20:31 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA7IKVIP009558
	for <linux-mm@kvack.org>; Sun, 7 Nov 2010 13:20:31 -0500
Date: Sun, 7 Nov 2010 10:20:28 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: suspicious rcu_dereference_check() usage -
 kernel/pid.c:419 invoked rcu_dereference_check() without protection!
Message-ID: <20101107182028.GZ15561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <xr93fwwbdh1d.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93fwwbdh1d.fsf@ninji.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 12, 2010 at 12:08:46AM -0700, Greg Thelen wrote:
> I observe a failing rcu_dereference_check() in linux-next (found in
> mmotm-2010-10-07-14-08).  An extra rcu assertion in
> find_task_by_pid_ns() was added by:
>   commit 4221a9918e38b7494cee341dda7b7b4bb8c04bde
>   Author: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>   Date:   Sat Jun 26 01:08:19 2010 +0900
>   
>       Add RCU check for find_task_by_vpid().
> 
> This extra assertion causes a rcu_dereference_check() failure during
> boot in 512 MIB VM.  I would be happy to get out proposed patches to
> this issue.  My config includes:
>   CONFIG_PREEMPT=y
>   CONFIG_LOCKDEP=y
>   CONFIG_PROVE_LOCKING=y
>   CONFIG_PROVE_RCU=y
> 
> The console error:
> 
> Begin: Running /scripts/local-bottom ...
> Done.
> Done.
> Begin: Running /scripts/init-bottom ...
> Done.
> [    3.394348]
> [    3.394349] ===================================================
> [    3.395162] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    3.395786] ---------------------------------------------------
> [    3.396452] kernel/pid.c:419 invoked rcu_dereference_check() without protection!
> [    3.397483]
> [    3.397484] other info that might help us debug this:
> [    3.397485]
> [    3.398363]
> [    3.398364] rcu_scheduler_active = 1, debug_locks = 0
> [    3.399073] 1 lock held by ureadahead/1438:
> [    3.399515]  #0:  (tasklist_lock){.+.+..}, at: [<ffffffff811c1d1a>] sys_ioprio_set+0x8a/0x3f0
> [    3.400500]
> [    3.400501] stack backtrace:
> [    3.401036] Pid: 1438, comm: ureadahead Not tainted 2.6.36-dbg-DEV #10
> [    3.401717] Call Trace:
> [    3.401996]  [<ffffffff810c720b>] lockdep_rcu_dereference+0xbb/0xc0
> [    3.402742]  [<ffffffff810aebb1>] find_task_by_pid_ns+0x81/0x90
> [    3.403445]  [<ffffffff810aebe2>] find_task_by_vpid+0x22/0x30
> [    3.404146]  [<ffffffff811c2074>] sys_ioprio_set+0x3e4/0x3f0
> [    3.404756]  [<ffffffff815c5919>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [    3.405455]  [<ffffffff8104331b>] system_call_fastpath+0x16/0x1b
> 
> 
> ioprio_set() contains a comment warning against of usage of
> rcu_read_lock() to avoid this warning:
> 	/*
> 	 * We want IOPRIO_WHO_PGRP/IOPRIO_WHO_USER to be "atomic",
> 	 * so we can't use rcu_read_lock(). See re-copy of ->ioprio
> 	 * in copy_process().
> 	 */
> 
> So I'm not sure what the best fix is.

I must defer to Oleg, who wrote the comment.  But please see below.

> Also I see that sys_ioprio_get() has a similar problem that might be
> addressed with:

There is a patch from Sergey Senozhatsky currently in -mm that encloses
a subset of this code (both ioprio_set and ioprio_get) in rcu_read_lock()
and rcu_read_unlock(), see http://lkml.org/lkml/2010/10/29/168.

							Thanx, Paul

> diff --git a/fs/ioprio.c b/fs/ioprio.c
> index 748cfb9..02eed30 100644
> --- a/fs/ioprio.c
> +++ b/fs/ioprio.c
> @@ -197,6 +197,7 @@ SYSCALL_DEFINE2(ioprio_get, int, which, int, who)
>  	int ret = -ESRCH;
>  	int tmpio;
> 
> +	rcu_read_lock();
>  	read_lock(&tasklist_lock);
>  	switch (which) {
>  		case IOPRIO_WHO_PROCESS:
> @@ -251,5 +252,6 @@ SYSCALL_DEFINE2(ioprio_get, int, which, int, who)
>  	}
> 
>  	read_unlock(&tasklist_lock);
> +	rcu_read_unlock();
>  	return ret;
>  }
> 
> sys_ioprio_get() didn't have an explicit warning against usage of
> rcu_read_lock(), but that doesn't mean this is a good patch.
> 
> --
> Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
