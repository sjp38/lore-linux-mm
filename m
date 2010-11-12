Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 200118D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 07:18:43 -0500 (EST)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oACC2X7R021527
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 07:02:33 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oACCIZYI332972
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 07:18:35 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oACCIYUA017436
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 07:18:35 -0500
Date: Fri, 12 Nov 2010 04:18:33 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] ioprio: grab rcu_read_lock in sys_ioprio_{set,get}()
Message-ID: <20101112121833.GB2825@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1289547167-32675-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289547167-32675-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Jens Axboe <axboe@kernel.dk>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 11:32:47PM -0800, Greg Thelen wrote:
> Using:
> - CONFIG_LOCKUP_DETECTOR=y
> - CONFIG_PREEMPT=y
> - CONFIG_LOCKDEP=y
> - CONFIG_PROVE_LOCKING=y
> - CONFIG_PROVE_RCU=y
> found a missing rcu lock during boot on a 512 MiB x86_64 ubuntu vm:
>   ===================================================
>   [ INFO: suspicious rcu_dereference_check() usage. ]
>   ---------------------------------------------------
>   kernel/pid.c:419 invoked rcu_dereference_check() without protection!
> 
>   other info that might help us debug this:
> 
>   rcu_scheduler_active = 1, debug_locks = 0
>   1 lock held by ureadahead/1355:
>    #0:  (tasklist_lock){.+.+..}, at: [<ffffffff8115bc09>] sys_ioprio_set+0x7f/0x29e
> 
>   stack backtrace:
>   Pid: 1355, comm: ureadahead Not tainted 2.6.37-dbg-DEV #1
>   Call Trace:
>    [<ffffffff8109c10c>] lockdep_rcu_dereference+0xaa/0xb3
>    [<ffffffff81088cbf>] find_task_by_pid_ns+0x44/0x5d
>    [<ffffffff81088cfa>] find_task_by_vpid+0x22/0x24
>    [<ffffffff8115bc3e>] sys_ioprio_set+0xb4/0x29e
>    [<ffffffff8147cf21>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>    [<ffffffff8105c409>] sysenter_dispatch+0x7/0x2c
>    [<ffffffff8147cee2>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> 
> The fix is to:
> a) grab rcu lock in sys_ioprio_{set,get}() and
> b) avoid grabbing tasklist_lock.
> Discussion in: http://marc.info/?l=linux-kernel&m=128951324702889

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
>  fs/ioprio.c |   13 ++++---------
>  1 files changed, 4 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/ioprio.c b/fs/ioprio.c
> index 748cfb9..7da2a06 100644
> --- a/fs/ioprio.c
> +++ b/fs/ioprio.c
> @@ -103,12 +103,7 @@ SYSCALL_DEFINE3(ioprio_set, int, which, int, who, int, ioprio)
>  	}
> 
>  	ret = -ESRCH;
> -	/*
> -	 * We want IOPRIO_WHO_PGRP/IOPRIO_WHO_USER to be "atomic",
> -	 * so we can't use rcu_read_lock(). See re-copy of ->ioprio
> -	 * in copy_process().
> -	 */
> -	read_lock(&tasklist_lock);
> +	rcu_read_lock();
>  	switch (which) {
>  		case IOPRIO_WHO_PROCESS:
>  			if (!who)
> @@ -153,7 +148,7 @@ free_uid:
>  			ret = -EINVAL;
>  	}
> 
> -	read_unlock(&tasklist_lock);
> +	rcu_read_unlock();
>  	return ret;
>  }
> 
> @@ -197,7 +192,7 @@ SYSCALL_DEFINE2(ioprio_get, int, which, int, who)
>  	int ret = -ESRCH;
>  	int tmpio;
> 
> -	read_lock(&tasklist_lock);
> +	rcu_read_lock();
>  	switch (which) {
>  		case IOPRIO_WHO_PROCESS:
>  			if (!who)
> @@ -250,6 +245,6 @@ SYSCALL_DEFINE2(ioprio_get, int, which, int, who)
>  			ret = -EINVAL;
>  	}
> 
> -	read_unlock(&tasklist_lock);
> +	rcu_read_unlock();
>  	return ret;
>  }
> -- 
> 1.7.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
