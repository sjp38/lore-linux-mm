Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 904AC6B012F
	for <linux-mm@kvack.org>; Thu,  8 May 2014 20:03:49 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so3469487pab.40
        for <linux-mm@kvack.org>; Thu, 08 May 2014 17:03:49 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id py5si1277914pbc.357.2014.05.08.17.03.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 08 May 2014 17:03:48 -0700 (PDT)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N5A0046S5IAIZ30@mailout4.samsung.com> for linux-mm@kvack.org;
 Fri, 09 May 2014 09:03:46 +0900 (KST)
Content-transfer-encoding: 8BIT
Message-id: <1399593691.13268.58.camel@kjgkr>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
From: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Reply-to: jaegeuk.kim@samsung.com
Date: Fri, 09 May 2014 09:01:31 +0900
In-reply-to: <20140508152946.GA10470@localhost>
References: <1398390340.4283.36.camel@kjgkr> <20140501170610.GB28745@arm.com>
 <20140501184112.GH23420@cmpxchg.org> <1399431488.13268.29.camel@kjgkr>
 <20140507113928.GB17253@arm.com> <1399540611.13268.45.camel@kjgkr>
 <20140508092646.GA17349@arm.com> <1399541860.13268.48.camel@kjgkr>
 <20140508102436.GC17344@arm.com> <20140508150026.GA8754@linux.vnet.ibm.com>
 <20140508152946.GA10470@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2014-05-08 (ea(C)), 16:29 +0100, Catalin Marinas:
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

Under existing the kmemleak messeages, the fsstress test has been
running over 12 hours.
For sure now, I quit the test and umount the file system, which drops
the whole page caches used by f2fs.
Then do, echo scan > $DEBUGFS/kmemleak again, but there still exist a
bunch of leak messages.

The oldest one is:
unreferenced object 0xffff88007b167478 (size 576):
  comm "fsstress", pid 1636, jiffies 4294945289 (age 164639.728s)
  hex dump (first 32 bytes):
    01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
    50 89 34 81 ff ff ff ff 90 74 16 7b 00 88 ff ff  P.4......t.{....
  backtrace:
[snip]

> 
> > It might also be that one of the CPUs is stuck (e.g., spinning with
> > interrupts disabled), which would prevent the grace period from
> > completing, in turn preventing any memory waiting for that grace period
> > from being freed.
> 
> We should get some kernel warning if it's stuck for too long but, again,
> Jaegeuk can confirm. I haven't managed to reproduce this on ARM systems.

There are no kernel warnings, but only kmemleak messages. The fsstress
has been well running without stucks.

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

Got it. I'll do this first.
Thank you~ :)

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
> 
> BTW, is it safe to have a union overlapping node->parent and
> node->rcu_head.next? I'm still staring at the radix-tree code but a
> scenario I have in mind is that call_rcu() has been raised for a few
> nodes, other CPU may have some reference to one of them and set
> node->parent to NULL (e.g. concurrent calls to radix_tree_shrink()),
> breaking the RCU linking. I can't confirm this theory yet ;)
> 

-- 
Jaegeuk Kim
Samsung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
