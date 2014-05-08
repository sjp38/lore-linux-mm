Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 387DA6B00FB
	for <linux-mm@kvack.org>; Thu,  8 May 2014 11:53:37 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so2967680qgf.7
        for <linux-mm@kvack.org>; Thu, 08 May 2014 08:53:37 -0700 (PDT)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id di5si688728qcb.56.2014.05.08.08.53.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 08:53:36 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 8 May 2014 09:53:35 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 32EAA3E40040
	for <linux-mm@kvack.org>; Thu,  8 May 2014 09:53:33 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s48Fqh0r36831272
	for <linux-mm@kvack.org>; Thu, 8 May 2014 17:52:43 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s48FvMir004122
	for <linux-mm@kvack.org>; Thu, 8 May 2014 09:57:23 -0600
Date: Thu, 8 May 2014 08:53:30 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
Message-ID: <20140508155330.GE8754@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140501170610.GB28745@arm.com>
 <20140501184112.GH23420@cmpxchg.org>
 <1399431488.13268.29.camel@kjgkr>
 <20140507113928.GB17253@arm.com>
 <1399540611.13268.45.camel@kjgkr>
 <20140508092646.GA17349@arm.com>
 <1399541860.13268.48.camel@kjgkr>
 <20140508102436.GC17344@arm.com>
 <20140508150026.GA8754@linux.vnet.ibm.com>
 <20140508152946.GA10470@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140508152946.GA10470@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Jaegeuk Kim <jaegeuk.kim@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 08, 2014 at 04:29:48PM +0100, Catalin Marinas wrote:
> On Thu, May 08, 2014 at 04:00:27PM +0100, Paul E. McKenney wrote:
> > On Thu, May 08, 2014 at 11:24:36AM +0100, Catalin Marinas wrote:
> > > On Thu, May 08, 2014 at 10:37:40AM +0100, Jaegeuk Kim wrote:
> > > > 2014-05-08 (ea(C)), 10:26 +0100, Catalin Marinas:
> > > > > On Thu, May 08, 2014 at 06:16:51PM +0900, Jaegeuk Kim wrote:
> > > > > > 2014-05-07 (i??), 12:39 +0100, Catalin Marinas:
> > > > > > > On Wed, May 07, 2014 at 03:58:08AM +0100, Jaegeuk Kim wrote:
> > > > > > > > unreferenced object 0xffff880004226da0 (size 576):
> > > > > > > >   comm "fsstress", pid 14590, jiffies 4295191259 (age 706.308s)
> > > > > > > >   hex dump (first 32 bytes):
> > > > > > > >     01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
> > > > > > > >     50 89 34 81 ff ff ff ff b8 6d 22 04 00 88 ff ff  P.4......m".....
> > > > > > > >   backtrace:
> > > > > > > >     [<ffffffff816c02e8>] kmemleak_update_trace+0x58/0x80
> > > > > > > >     [<ffffffff81349517>] radix_tree_node_alloc+0x77/0xa0
> > > > > > > >     [<ffffffff81349718>] __radix_tree_create+0x1d8/0x230
> > > > > > > >     [<ffffffff8113286c>] __add_to_page_cache_locked+0x9c/0x1b0
> > > > > > > >     [<ffffffff811329a8>] add_to_page_cache_lru+0x28/0x80
> > > > > > > >     [<ffffffff81132f58>] grab_cache_page_write_begin+0x98/0xf0
> > > > > > > >     [<ffffffffa02e4bf4>] f2fs_write_begin+0xb4/0x3c0 [f2fs]
> > > > > > > >     [<ffffffff81131b77>] generic_perform_write+0xc7/0x1c0
> > > > > > > >     [<ffffffff81133b7d>] __generic_file_aio_write+0x1cd/0x3f0
> > > > > > > >     [<ffffffff81133dfe>] generic_file_aio_write+0x5e/0xe0
> > > > > > > >     [<ffffffff81195c5a>] do_sync_write+0x5a/0x90
> > > > > > > >     [<ffffffff811968d2>] vfs_write+0xc2/0x1d0
> > > > > > > >     [<ffffffff81196daf>] SyS_write+0x4f/0xb0
> > > > > > > >     [<ffffffff816dead2>] system_call_fastpath+0x16/0x1b
> > > > > > > >     [<ffffffffffffffff>] 0xffffffffffffffff
> > > > > > >
> > > > > > > OK, it shows that the allocation happens via add_to_page_cache_locked()
> > > > > > > and I guess it's page_cache_tree_insert() which calls
> > > > > > > __radix_tree_create() (the latter reusing the preloaded node). I'm not
> > > > > > > familiar enough to this code (radix-tree.c and filemap.c) to tell where
> > > > > > > the node should have been freed, who keeps track of it.
> > > > > > >
> > > > > > > At a quick look at the hex dump (assuming that the above leak is struct
> > > > > > > radix_tree_node):
> > > > > > >
> > > > > > > 	.path = 1
> > > > > > > 	.count = -0x7f (or 0xffffff81 as unsigned int)
> > > > > > > 	union {
> > > > > > > 		{
> > > > > > > 			.parent = NULL
> > > > > > > 			.private_data = 0xffffffff81348950
> > > > > > > 		}
> > > > > > > 		{
> > > > > > > 			.rcu_head.next = NULL
> > > > > > > 			.rcu_head.func = 0xffffffff81348950
> > > > > > > 		}
> > > > > > > 	}
> > > > > > >
> > > > > > > The count is a bit suspicious.
> > > > > > >
> > > > > > > From the union, it looks most likely like rcu_head information. Is
> > > > > > > radix_tree_node_rcu_free() function at the above rcu_head.func?
> > > > >
> > > > > Thanks for the config. Could you please confirm that 0xffffffff81348950
> > > > > address corresponds to the radix_tree_node_rcu_free() function in your
> > > > > System.map (or something else)?
> > > > 
> > > > Yap, the address is matched to radix_tree_node_rcu_free().
> > > 
> > > Cc'ing Paul as well, not that I blame RCU ;), but maybe he could shed
> > > some light on why kmemleak can't track this object.
> > 
> > Do we have any information on how long it has been since that data
> > structure was handed to call_rcu()?  If that time is short, then it
> > is quite possible that its grace period simply has not yet completed.
> 
> kmemleak scans every 10 minutes but Jaegeuk can confirm how long he has
> waited.

OK.  If RCU was stalled for that long, you should get stall warnings,
at least assuming that they were not disabled, for example, using
the rcupdate.rcu_cpu_stall_suppress=1 boot parameter.

> > It might also be that one of the CPUs is stuck (e.g., spinning with
> > interrupts disabled), which would prevent the grace period from
> > completing, in turn preventing any memory waiting for that grace period
> > from being freed.
> 
> We should get some kernel warning if it's stuck for too long but, again,
> Jaegeuk can confirm. I haven't managed to reproduce this on ARM systems.
> 
> > > My summary so far:
> > > 
> > > - radix_tree_node reported by kmemleak as it cannot find any trace of it
> > >   when scanning the memory
> > > - at allocation time, radix_tree_node is memzero'ed by
> > >   radix_tree_node_ctor(). Given that node->rcu_head.func ==
> > >   radix_tree_node_rcu_free, my guess is that radix_tree_node_free() has
> > >   been called
> > > - some time later, kmemleak still hasn't received any callback for
> > >   kmem_cache_free(node). Possibly radix_tree_node_rcu_free() hasn't been
> > >   called either since node->count is not NULL.
> > > 
> > > For RCU queued objects, kmemleak should still track references to them
> > > via rcu_sched_state and rcu_head members. But even if this went wrong, I
> > > would expect the object to be freed eventually and kmemleak notified (so
> > > just a temporary leak report which doesn't seem to be the case here).
> > 
> > OK, so you are saying that this memory has been in this state for quite
> > some time?
> 
> These leaks don't seem to disappear (time lapsed to be confirmed) and
> the object checksum not changed either (otherwise kmemleak would not
> report it).
> 
> > If the system is responsive during this time, I recommend building with
> > CONFIG_RCU_TRACE=y, then polling the debugfs rcu/*/rcugp files.  The value
> > of "*" will be "rcu_sched" for kernels built with CONFIG_PREEMPT=n and
> > "rcu_preempt" for kernels built with CONFIG_PREEMPT=y.
> > 
> > If the number printed does not advance, then the RCU grace period is
> > stalled, which will prevent memory waiting for that grace period from
> > ever being freed.
> 
> Thanks for the suggestions
> 
> > Of course, if the value of node->count is preventing call_rcu() from
> > being invoked in the first place, then the needed grace period won't
> > start, much less finish.  ;-)
> 
> Given the rcu_head.func value, my assumption is that call_rcu() has
> already been called.

Fair point -- given that it is a union, you would expect this field to
be overwritten upon reuse.

> BTW, is it safe to have a union overlapping node->parent and
> node->rcu_head.next? I'm still staring at the radix-tree code but a
> scenario I have in mind is that call_rcu() has been raised for a few
> nodes, other CPU may have some reference to one of them and set
> node->parent to NULL (e.g. concurrent calls to radix_tree_shrink()),
> breaking the RCU linking. I can't confirm this theory yet ;)

If this were reproducible, I would suggest retrying with non-overlapping
node->parent and node->rcu_head.next, but you knew that already.  ;-)

But the usual practice would be to make node removal exclude shrinking.
And the radix-tree code seems to delegate locking to the caller.

So, is the correct locking present in the page cache?  The radix-tree
code seems to assume that all update operations for a given tree are
protected by a lock global to that tree.

Another diagnosis approach would be to build with
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y, which would complain about double
call_rcu() invocations.  Rumor has it that is is necessary to turn off
other kmem debugging for this to tell you anything -- I have seen cases
where the kmem debugging obscures the debug-objects diagnostics.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
