Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 16CAB6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 18:31:43 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so7661753pab.26
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:31:42 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id s7si11078994pae.243.2014.02.03.15.31.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 15:31:42 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so7687705pab.34
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:31:41 -0800 (PST)
Date: Mon, 3 Feb 2014 15:31:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Fix lockdep false positive in add_full()
In-Reply-To: <20140203225725.GA4069@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402031531160.7643@chino.kir.corp.google.com>
References: <20140203225725.GA4069@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, peterz@infradead.org

On Mon, 3 Feb 2014, Paul E. McKenney wrote:

> Hello!
> 
> The add_full() function currently has a lockdep_assert_held() requiring
> that the kmem_cache_node structure's ->list_lock be held.  However,
> this lock is not acquired by add_full()'s caller deactivate_slab()
> in the full-node case unless debugging is enabled.  Because full nodes
> are accessed only by debugging code, this state of affairs results in
> lockdep false-positive splats like the following:
> 
> [   43.942868] WARNING: CPU: 0 PID: 698 at /home/paulmck/public_git/linux-rcu/mm/slub.c:1007 deactivate_slab+0x509/0x720()
> [   43.943016] Modules linked in:
> [   43.943016] CPU: 0 PID: 698 Comm: torture_onoff Not tainted 3.14.0-rc1+ #1
> [   43.943016] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [   43.943016]  00000000000003ef ffff88001e3f5ba8 ffffffff818952ec 0000000000000046
> [   43.943016]  0000000000000000 ffff88001e3f5be8 ffffffff81049517 ffffea0000784e00
> [   43.943016]  0000000000000000 ffffea00007a9000 0000000000000002 0000000000000000
> [   43.943016] Call Trace:
> [   43.943016]  [<ffffffff818952ec>] dump_stack+0x46/0x58
> [   43.943016]  [<ffffffff81049517>] warn_slowpath_common+0x87/0xb0
> [   43.943016]  [<ffffffff81049555>] warn_slowpath_null+0x15/0x20
> [   43.943016]  [<ffffffff8116e679>] deactivate_slab+0x509/0x720
> [   43.943016]  [<ffffffff8116eebb>] ? slab_cpuup_callback+0x3b/0x100
> [   43.943016]  [<ffffffff8116ef52>] ? slab_cpuup_callback+0xd2/0x100
> [   43.943016]  [<ffffffff8116ef24>] slab_cpuup_callback+0xa4/0x100
> [   43.943016]  [<ffffffff818a4c14>] notifier_call_chain+0x54/0x110
> [   43.943016]  [<ffffffff81075b79>] __raw_notifier_call_chain+0x9/0x10
> [   43.943016]  [<ffffffff8104963b>] __cpu_notify+0x1b/0x30
> [   43.943016]  [<ffffffff81049720>] cpu_notify_nofail+0x10/0x20
> [   43.943016]  [<ffffffff8188cc5d>] _cpu_down+0x10d/0x2e0
> [   43.943016]  [<ffffffff8188ce60>] cpu_down+0x30/0x50
> [   43.943016]  [<ffffffff811205f3>] torture_onoff+0xd3/0x3c0
> [   43.943016]  [<ffffffff81120520>] ? torture_onoff_stats+0x90/0x90
> [   43.943016]  [<ffffffff810710df>] kthread+0xdf/0x100
> [   43.943016]  [<ffffffff818a09cb>] ? _raw_spin_unlock_irq+0x2b/0x40
> [   43.943016]  [<ffffffff81071000>] ? flush_kthread_worker+0x130/0x130
> [   43.943016]  [<ffffffff818a983c>] ret_from_fork+0x7c/0xb0
> [   43.943016]  [<ffffffff81071000>] ? flush_kthread_worker+0x130/0x130
> 
> This commit therefore does the lockdep check only if debuggging is
> enabled, thus avoiding the false positives.
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

This was discussed in http://marc.info/?t=139145791300002, what do you 
think about the patch in that thread instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
