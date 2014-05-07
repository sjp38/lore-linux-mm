Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D7E196B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 23:00:26 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so401438pdj.6
        for <linux-mm@kvack.org>; Tue, 06 May 2014 20:00:26 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id db3si1062859pbc.402.2014.05.06.20.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 06 May 2014 20:00:25 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N5600I4OOCM0VE0@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 07 May 2014 12:00:22 +0900 (KST)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: quoted-printable
Message-id: <1399431488.13268.29.camel@kjgkr>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
From: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Reply-to: jaegeuk.kim@samsung.com
Date: Wed, 07 May 2014 11:58:08 +0900
In-reply-to: <20140501184112.GH23420@cmpxchg.org>
References: <1398390340.4283.36.camel@kjgkr> <20140501170610.GB28745@arm.com>
 <20140501184112.GH23420@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Catalin Marinas <catalin.marinas@arm.com>
Cc: "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Johannes and Catalin,

Actually bisecting is the best way, but I failed to run fsstress with
early 3.15-rcX due to BUG_ONs in mm; recently it seems that most of
there-in issues have been resolved.

So I pulled the linus tree having:

commit 38583f095c5a8138ae2a1c9173d0fd8a9f10e8aa
Merge: 8169d30 3ca9e5d
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue May 6 13:07:41 2014 -0700

    Merge branch 'akpm' (incoming from Andrew)
    
    Merge misc fixes from Andrew Morton:
     "13 fixes"

And then when I tested again with Catalin's patch, it still throws the
following warning.
Is it false alarm=3F

unreferenced object 0xffff880004226da0 (size 576):
  comm "fsstress", pid 14590, jiffies 4295191259 (age 706.308s)
  hex dump (first 32 bytes):
    01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
    50 89 34 81 ff ff ff ff b8 6d 22 04 00 88 ff ff  P.4......m".....
  backtrace:
    [<ffffffff816c02e8>] kmemleak_update_trace+0x58/0x80
    [<ffffffff81349517>] radix_tree_node_alloc+0x77/0xa0
    [<ffffffff81349718>] __radix_tree_create+0x1d8/0x230
    [<ffffffff8113286c>] __add_to_page_cache_locked+0x9c/0x1b0
    [<ffffffff811329a8>] add_to_page_cache_lru+0x28/0x80
    [<ffffffff81132f58>] grab_cache_page_write_begin+0x98/0xf0
    [<ffffffffa02e4bf4>] f2fs_write_begin+0xb4/0x3c0 [f2fs]
    [<ffffffff81131b77>] generic_perform_write+0xc7/0x1c0
    [<ffffffff81133b7d>] __generic_file_aio_write+0x1cd/0x3f0
    [<ffffffff81133dfe>] generic_file_aio_write+0x5e/0xe0
    [<ffffffff81195c5a>] do_sync_write+0x5a/0x90
    [<ffffffff811968d2>] vfs_write+0xc2/0x1d0
    [<ffffffff81196daf>] SyS_write+0x4f/0xb0
    [<ffffffff816dead2>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff


2014-05-01 (=EB=AA=A9), 14:41 -0400, Johannes Weiner:
> On Thu, May 01, 2014 at 06:06:10PM +0100, Catalin Marinas wrote:
> > On Fri, Apr 25, 2014 at 10:45:40AM +0900, Jaegeuk Kim wrote:
> > > 2. Bug
> > >  This is one of the results, but all the results indicate
> > > __radix_tree_preload.
> > > 
> > > unreferenced object 0xffff88002ae2a238 (size 576):
> > > comm "fsstress", pid 25019, jiffies 4295651360 (age 2276.104s)
> > > hex dump (first 32 bytes):
> > > 01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
> > > 40 7d 37 81 ff ff ff ff 50 a2 e2 2a 00 88 ff ff  @}7.....P..*....
> > > backtrace:
> > >  [<ffffffff8170e546>] kmemleak_alloc+0x26/0x50
> > >  [<ffffffff8119feac>] kmem_cache_alloc+0xdc/0x190
> > >  [<ffffffff81378709>] __radix_tree_preload+0x49/0xc0
> > >  [<ffffffff813787a1>] radix_tree_maybe_preload+0x21/0x30
> > >  [<ffffffff8114bbbc>] add_to_page_cache_lru+0x3c/0xc0
> > >  [<ffffffff8114c778>] grab_cache_page_write_begin+0x98/0xf0
> > >  [<ffffffffa02d3151>] f2fs_write_begin+0xa1/0x370 [f2fs]
> > >  [<ffffffff8114af47>] generic_perform_write+0xc7/0x1e0
> > >  [<ffffffff8114d230>] __generic_file_aio_write+0x1d0/0x400
> > >  [<ffffffff8114d4c0>] generic_file_aio_write+0x60/0xe0
> > >  [<ffffffff811b281a>] do_sync_write+0x5a/0x90
> > >  [<ffffffff811b3575>] vfs_write+0xc5/0x1f0
> > >  [<ffffffff811b3a92>] SyS_write+0x52/0xb0
> > >  [<ffffffff81730912>] system_call_fastpath+0x16/0x1b
> > >  [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > Do all the backtraces look like the above (coming from
> > add_to_page_cache_lru)=3F

Yap.

> > 
> > There were some changes in lib/radix-tree.c since 3.14, maybe you could
> > try reverting them and see if the leaks still appear (cc'ing Johannes).
> > It could also be a false positive.
> >
> > An issue with debugging such cases is that the preloading is common for
> > multiple radix trees, so the actual radix_tree_node_alloc() could be on
> > a different path. You could give the patch below a try to see what
> > backtrace you get (it updates backtrace in radix_tree_node_alloc()).
> 
> That patch makes a lot of sense to me.  I applied it locally but I am
> unable to reproduce this with page cache heavy workloads.  Jaegeuk=3F

-- 
Jaegeuk Kim
Samsung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
