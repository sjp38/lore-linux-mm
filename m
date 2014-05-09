Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 60C086B0036
	for <linux-mm@kvack.org>; Fri,  9 May 2014 05:45:55 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so3553313pde.27
        for <linux-mm@kvack.org>; Fri, 09 May 2014 02:45:55 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id ko6si1967737pbc.442.2014.05.09.02.45.54
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 02:45:54 -0700 (PDT)
Date: Fri, 9 May 2014 10:45:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
Message-ID: <20140509094511.GB7950@arm.com>
References: <20140501184112.GH23420@cmpxchg.org>
 <1399431488.13268.29.camel@kjgkr>
 <20140507113928.GB17253@arm.com>
 <1399540611.13268.45.camel@kjgkr>
 <20140508092646.GA17349@arm.com>
 <1399541860.13268.48.camel@kjgkr>
 <20140508102436.GC17344@arm.com>
 <20140508150026.GA8754@linux.vnet.ibm.com>
 <20140508152946.GA10470@localhost>
 <1399593691.13268.58.camel@kjgkr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399593691.13268.58.camel@kjgkr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, May 09, 2014 at 01:01:31AM +0100, Jaegeuk Kim wrote:
> > > > > > > > On Wed, May 07, 2014 at 03:58:08AM +0100, Jaegeuk Kim wrote:
> > > > > > > > > unreferenced object 0xffff880004226da0 (size 576):
> > > > > > > > >   comm "fsstress", pid 14590, jiffies 4295191259 (age 706.308s)
> > > > > > > > >   hex dump (first 32 bytes):
> > > > > > > > >     01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
> > > > > > > > >     50 89 34 81 ff ff ff ff b8 6d 22 04 00 88 ff ff  P.4......m".....
> > > > > > > > >   backtrace:
> > > > > > > > >     [<ffffffff816c02e8>] kmemleak_update_trace+0x58/0x80
> > > > > > > > >     [<ffffffff81349517>] radix_tree_node_alloc+0x77/0xa0
> > > > > > > > >     [<ffffffff81349718>] __radix_tree_create+0x1d8/0x230
> > > > > > > > >     [<ffffffff8113286c>] __add_to_page_cache_locked+0x9c/0x1b0
> > > > > > > > >     [<ffffffff811329a8>] add_to_page_cache_lru+0x28/0x80
> > > > > > > > >     [<ffffffff81132f58>] grab_cache_page_write_begin+0x98/0xf0
> > > > > > > > >     [<ffffffffa02e4bf4>] f2fs_write_begin+0xb4/0x3c0 [f2fs]
> > > > > > > > >     [<ffffffff81131b77>] generic_perform_write+0xc7/0x1c0
> > > > > > > > >     [<ffffffff81133b7d>] __generic_file_aio_write+0x1cd/0x3f0
> > > > > > > > >     [<ffffffff81133dfe>] generic_file_aio_write+0x5e/0xe0
> > > > > > > > >     [<ffffffff81195c5a>] do_sync_write+0x5a/0x90
> > > > > > > > >     [<ffffffff811968d2>] vfs_write+0xc2/0x1d0
> > > > > > > > >     [<ffffffff81196daf>] SyS_write+0x4f/0xb0
> > > > > > > > >     [<ffffffff816dead2>] system_call_fastpath+0x16/0x1b
> > > > > > > > >     [<ffffffffffffffff>] 0xffffffffffffffff
[...]
> Under existing the kmemleak messeages, the fsstress test has been
> running over 12 hours.
> For sure now, I quit the test and umount the file system, which drops
> the whole page caches used by f2fs.
> Then do, echo scan > $DEBUGFS/kmemleak again, but there still exist a
> bunch of leak messages.
> 
> The oldest one is:
> unreferenced object 0xffff88007b167478 (size 576):
>   comm "fsstress", pid 1636, jiffies 4294945289 (age 164639.728s)
>   hex dump (first 32 bytes):
>     01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
>     50 89 34 81 ff ff ff ff 90 74 16 7b 00 88 ff ff  P.4......t.{....
>   backtrace:
> [snip]

As Johannes pointed out, the simplest explanation would be that the
radix tree node is leaked after allocation. So let's ignore radix-tree.c
filemap.c or RCU for now.

As I read the code, a radix tree node allocated via the above call path
would be stored in the page_tree of the address_space structure. This
address_space object is inode.i_data and the inode is allocated by the
f2fs code. When the inode is destroyed by the f2fs code, can you add
some checks to make sure there are no nodes left in the radix tree? If
there are, they would just leak and have to figure out where they should
have been freed.

You could also revert some of the f2fs changes since 3.14 (assuming 3.14
didn't show leaks) and see if you still get the leaks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
