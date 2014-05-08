Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id F144C6B00E1
	for <linux-mm@kvack.org>; Thu,  8 May 2014 06:25:14 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kx10so2673104pab.39
        for <linux-mm@kvack.org>; Thu, 08 May 2014 03:25:14 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id yi3si310029pbb.54.2014.05.08.03.25.13
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 03:25:14 -0700 (PDT)
Date: Thu, 8 May 2014 11:24:36 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
Message-ID: <20140508102436.GC17344@arm.com>
References: <1398390340.4283.36.camel@kjgkr>
 <20140501170610.GB28745@arm.com>
 <20140501184112.GH23420@cmpxchg.org>
 <1399431488.13268.29.camel@kjgkr>
 <20140507113928.GB17253@arm.com>
 <1399540611.13268.45.camel@kjgkr>
 <20140508092646.GA17349@arm.com>
 <1399541860.13268.48.camel@kjgkr>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1399541860.13268.48.camel@kjgkr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, May 08, 2014 at 10:37:40AM +0100, Jaegeuk Kim wrote:
> 2014-05-08 (ea(C)), 10:26 +0100, Catalin Marinas:
> > On Thu, May 08, 2014 at 06:16:51PM +0900, Jaegeuk Kim wrote:
> > > 2014-05-07 (i??), 12:39 +0100, Catalin Marinas:
> > > > On Wed, May 07, 2014 at 03:58:08AM +0100, Jaegeuk Kim wrote:
> > > > > unreferenced object 0xffff880004226da0 (size 576):
> > > > >   comm "fsstress", pid 14590, jiffies 4295191259 (age 706.308s)
> > > > >   hex dump (first 32 bytes):
> > > > >     01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
> > > > >     50 89 34 81 ff ff ff ff b8 6d 22 04 00 88 ff ff  P.4......m".....
> > > > >   backtrace:
> > > > >     [<ffffffff816c02e8>] kmemleak_update_trace+0x58/0x80
> > > > >     [<ffffffff81349517>] radix_tree_node_alloc+0x77/0xa0
> > > > >     [<ffffffff81349718>] __radix_tree_create+0x1d8/0x230
> > > > >     [<ffffffff8113286c>] __add_to_page_cache_locked+0x9c/0x1b0
> > > > >     [<ffffffff811329a8>] add_to_page_cache_lru+0x28/0x80
> > > > >     [<ffffffff81132f58>] grab_cache_page_write_begin+0x98/0xf0
> > > > >     [<ffffffffa02e4bf4>] f2fs_write_begin+0xb4/0x3c0 [f2fs]
> > > > >     [<ffffffff81131b77>] generic_perform_write+0xc7/0x1c0
> > > > >     [<ffffffff81133b7d>] __generic_file_aio_write+0x1cd/0x3f0
> > > > >     [<ffffffff81133dfe>] generic_file_aio_write+0x5e/0xe0
> > > > >     [<ffffffff81195c5a>] do_sync_write+0x5a/0x90
> > > > >     [<ffffffff811968d2>] vfs_write+0xc2/0x1d0
> > > > >     [<ffffffff81196daf>] SyS_write+0x4f/0xb0
> > > > >     [<ffffffff816dead2>] system_call_fastpath+0x16/0x1b
> > > > >     [<ffffffffffffffff>] 0xffffffffffffffff
> > > >
> > > > OK, it shows that the allocation happens via add_to_page_cache_locked()
> > > > and I guess it's page_cache_tree_insert() which calls
> > > > __radix_tree_create() (the latter reusing the preloaded node). I'm not
> > > > familiar enough to this code (radix-tree.c and filemap.c) to tell where
> > > > the node should have been freed, who keeps track of it.
> > > >
> > > > At a quick look at the hex dump (assuming that the above leak is struct
> > > > radix_tree_node):
> > > >
> > > > 	.path = 1
> > > > 	.count = -0x7f (or 0xffffff81 as unsigned int)
> > > > 	union {
> > > > 		{
> > > > 			.parent = NULL
> > > > 			.private_data = 0xffffffff81348950
> > > > 		}
> > > > 		{
> > > > 			.rcu_head.next = NULL
> > > > 			.rcu_head.func = 0xffffffff81348950
> > > > 		}
> > > > 	}
> > > >
> > > > The count is a bit suspicious.
> > > >
> > > > From the union, it looks most likely like rcu_head information. Is
> > > > radix_tree_node_rcu_free() function at the above rcu_head.func?
> >
> > Thanks for the config. Could you please confirm that 0xffffffff81348950
> > address corresponds to the radix_tree_node_rcu_free() function in your
> > System.map (or something else)?
> 
> Yap, the address is matched to radix_tree_node_rcu_free().

Cc'ing Paul as well, not that I blame RCU ;), but maybe he could shed
some light on why kmemleak can't track this object.

My summary so far:

- radix_tree_node reported by kmemleak as it cannot find any trace of it
  when scanning the memory
- at allocation time, radix_tree_node is memzero'ed by
  radix_tree_node_ctor(). Given that node->rcu_head.func ==
  radix_tree_node_rcu_free, my guess is that radix_tree_node_free() has
  been called
- some time later, kmemleak still hasn't received any callback for
  kmem_cache_free(node). Possibly radix_tree_node_rcu_free() hasn't been
  called either since node->count is not NULL.

For RCU queued objects, kmemleak should still track references to them
via rcu_sched_state and rcu_head members. But even if this went wrong, I
would expect the object to be freed eventually and kmemleak notified (so
just a temporary leak report which doesn't seem to be the case here).

I still cannot explain the node->count value above and how it can get
there (too many node->count--?). Maybe Johannes could shed some light.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
