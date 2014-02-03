Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5549B6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 18:53:08 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id gq1so8574424obb.7
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:53:08 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id p8si10657410oeq.30.2014.02.03.15.53.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 15:53:07 -0800 (PST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 3 Feb 2014 16:53:07 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 35CD21FF0044
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 16:53:04 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s13Nqkdr9765162
	for <linux-mm@kvack.org>; Tue, 4 Feb 2014 00:52:46 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s13NuM2F007719
	for <linux-mm@kvack.org>; Mon, 3 Feb 2014 16:56:23 -0700
Date: Mon, 3 Feb 2014 15:53:02 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Fix lockdep false positive in add_full()
Message-ID: <20140203235302.GK4333@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140203225725.GA4069@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402031531160.7643@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402031531160.7643@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, peterz@infradead.org

On Mon, Feb 03, 2014 at 03:31:40PM -0800, David Rientjes wrote:
> On Mon, 3 Feb 2014, Paul E. McKenney wrote:
> 
> > Hello!
> > 
> > The add_full() function currently has a lockdep_assert_held() requiring
> > that the kmem_cache_node structure's ->list_lock be held.  However,
> > this lock is not acquired by add_full()'s caller deactivate_slab()
> > in the full-node case unless debugging is enabled.  Because full nodes
> > are accessed only by debugging code, this state of affairs results in
> > lockdep false-positive splats like the following:
> > 
> > [   43.942868] WARNING: CPU: 0 PID: 698 at /home/paulmck/public_git/linux-rcu/mm/slub.c:1007 deactivate_slab+0x509/0x720()
> > [   43.943016] Modules linked in:
> > [   43.943016] CPU: 0 PID: 698 Comm: torture_onoff Not tainted 3.14.0-rc1+ #1
> > [   43.943016] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> > [   43.943016]  00000000000003ef ffff88001e3f5ba8 ffffffff818952ec 0000000000000046
> > [   43.943016]  0000000000000000 ffff88001e3f5be8 ffffffff81049517 ffffea0000784e00
> > [   43.943016]  0000000000000000 ffffea00007a9000 0000000000000002 0000000000000000
> > [   43.943016] Call Trace:
> > [   43.943016]  [<ffffffff818952ec>] dump_stack+0x46/0x58
> > [   43.943016]  [<ffffffff81049517>] warn_slowpath_common+0x87/0xb0
> > [   43.943016]  [<ffffffff81049555>] warn_slowpath_null+0x15/0x20
> > [   43.943016]  [<ffffffff8116e679>] deactivate_slab+0x509/0x720
> > [   43.943016]  [<ffffffff8116eebb>] ? slab_cpuup_callback+0x3b/0x100
> > [   43.943016]  [<ffffffff8116ef52>] ? slab_cpuup_callback+0xd2/0x100
> > [   43.943016]  [<ffffffff8116ef24>] slab_cpuup_callback+0xa4/0x100
> > [   43.943016]  [<ffffffff818a4c14>] notifier_call_chain+0x54/0x110
> > [   43.943016]  [<ffffffff81075b79>] __raw_notifier_call_chain+0x9/0x10
> > [   43.943016]  [<ffffffff8104963b>] __cpu_notify+0x1b/0x30
> > [   43.943016]  [<ffffffff81049720>] cpu_notify_nofail+0x10/0x20
> > [   43.943016]  [<ffffffff8188cc5d>] _cpu_down+0x10d/0x2e0
> > [   43.943016]  [<ffffffff8188ce60>] cpu_down+0x30/0x50
> > [   43.943016]  [<ffffffff811205f3>] torture_onoff+0xd3/0x3c0
> > [   43.943016]  [<ffffffff81120520>] ? torture_onoff_stats+0x90/0x90
> > [   43.943016]  [<ffffffff810710df>] kthread+0xdf/0x100
> > [   43.943016]  [<ffffffff818a09cb>] ? _raw_spin_unlock_irq+0x2b/0x40
> > [   43.943016]  [<ffffffff81071000>] ? flush_kthread_worker+0x130/0x130
> > [   43.943016]  [<ffffffff818a983c>] ret_from_fork+0x7c/0xb0
> > [   43.943016]  [<ffffffff81071000>] ? flush_kthread_worker+0x130/0x130
> > 
> > This commit therefore does the lockdep check only if debuggging is
> > enabled, thus avoiding the false positives.
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> This was discussed in http://marc.info/?t=139145791300002, what do you 
> think about the patch in that thread instead?

Looks fine to me!  I also tried it out and it avoided the splats, as noted
in my mail in the other thread, so please feel free to add my Tested-by.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
