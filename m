Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8C89000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 16:33:57 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 3 Oct 2011 16:33:44 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p93KVeKn154434
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 16:31:57 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p93KVeUN011817
	for <linux-mm@kvack.org>; Mon, 3 Oct 2011 16:31:40 -0400
Date: Mon, 3 Oct 2011 13:31:39 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep recursive locking detected (rcu_kthread / __cache_free)
Message-ID: <20111003203139.GH2403@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20111003175322.GA26122@sucs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111003175322.GA26122@sucs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sitsofe Wheeler <sitsofe@yahoo.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org

On Mon, Oct 03, 2011 at 06:53:22PM +0100, Sitsofe Wheeler wrote:
> Hi,
> 
> While running 3.1.0-rc8 the following lockdep warning (seemingly related
> to RCU) was printed as the kernel was starting.
> 
> 
> udev: starting version 151
> udevd (263): /proc/263/oom_adj is deprecated, please use /proc/263/oom_score_adj instead.
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 3.1.0-rc8-dirty #508
> ---------------------------------------------
> rcu_kthread/6 is trying to acquire lock:
>  (&(&parent->list_lock)->rlock){..-...}, at: [<b016fe11>] __cache_free+0x2dd/0x382
> 
> but task is already holding lock:
>  (&(&parent->list_lock)->rlock){..-...}, at: [<b016fe11>] __cache_free+0x2dd/0x382
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(&(&parent->list_lock)->rlock);
>   lock(&(&parent->list_lock)->rlock);
> 
>  *** DEADLOCK ***
> 
>  May be due to missing lock nesting notation
> 
> 1 lock held by rcu_kthread/6:
>  #0:  (&(&parent->list_lock)->rlock){..-...}, at: [<b016fe11>] __cache_free+0x2dd/0x382
> 
> stack backtrace:
> Pid: 6, comm: rcu_kthread Not tainted 3.1.0-rc8-dirty #508
> Call Trace:
>  [<b0144466>] __lock_acquire+0xb90/0xc0e
>  [<b044c0c2>] ? _raw_spin_unlock_irqrestore+0x2f/0x46
>  [<b0223ebc>] ? debug_object_active_state+0x94/0xbc
>  [<b01315af>] ? rcuhead_fixup_activate+0x26/0x4c
>  [<b01448be>] lock_acquire+0x5b/0x72
>  [<b016fe11>] ? __cache_free+0x2dd/0x382
>  [<b044bb22>] _raw_spin_lock+0x25/0x34
>  [<b016fe11>] ? __cache_free+0x2dd/0x382
>  [<b016fe11>] __cache_free+0x2dd/0x382
>  [<b016ff5c>] kmem_cache_free+0x3e/0x5b
>  [<b0170097>] slab_destroy+0x11e/0x126
>  [<b0170184>] free_block+0xe5/0x112
>  [<b016fe54>] __cache_free+0x320/0x382

The first lock was acquired here in an RCU callback.  The later lock that
lockdep complained about appears to have been acquired from a recursive
call to __cache_free(), with no help from RCU.  This looks to me like
one of the issues that arise from the slab allocator using itself to
allocate slab metadata.

So the allocator guys (added to CC) need to sort this one out.

							Thanx, Paul

>  [<b01759a1>] ? file_free_rcu+0x32/0x39
>  [<b016ff5c>] kmem_cache_free+0x3e/0x5b
>  [<b01759a1>] file_free_rcu+0x32/0x39
>  [<b014ca68>] rcu_process_callbacks+0x95/0xa8
>  [<b014cb34>] rcu_kthread+0xb9/0xd2
>  [<b013356c>] ? wake_up_bit+0x1b/0x1b
>  [<b014ca7b>] ? rcu_process_callbacks+0xa8/0xa8
>  [<b0133305>] kthread+0x6c/0x71
>  [<b0133299>] ? __init_kthread_worker+0x42/0x42
>  [<b044ce02>] kernel_thread_helper+0x6/0xd
> 
> -- 
> Sitsofe | http://sucs.org/~sits/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
