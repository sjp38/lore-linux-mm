Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7FF058D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 04:15:28 -0500 (EST)
Message-ID: <4CE0FA2E.9070001@kernel.dk>
Date: Mon, 15 Nov 2010 10:15:26 +0100
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH] ioprio: grab rcu_read_lock in sys_ioprio_{set,get}()
References: <1289547167-32675-1-git-send-email-gthelen@google.com>
In-Reply-To: <1289547167-32675-1-git-send-email-gthelen@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2010-11-12 08:32, Greg Thelen wrote:
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

Thanks Greg, applied.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
