Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3B86E6B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 14:41:23 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2500297eei.14
        for <linux-mm@kvack.org>; Thu, 01 May 2014 11:41:22 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id p8si34900959eew.156.2014.05.01.11.41.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 01 May 2014 11:41:21 -0700 (PDT)
Date: Thu, 1 May 2014 14:41:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
Message-ID: <20140501184112.GH23420@cmpxchg.org>
References: <1398390340.4283.36.camel@kjgkr>
 <20140501170610.GB28745@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140501170610.GB28745@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Jaegeuk Kim <jaegeuk.kim@samsung.com>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 01, 2014 at 06:06:10PM +0100, Catalin Marinas wrote:
> On Fri, Apr 25, 2014 at 10:45:40AM +0900, Jaegeuk Kim wrote:
> > 2. Bug
> >  This is one of the results, but all the results indicate
> > __radix_tree_preload.
> > 
> > unreferenced object 0xffff88002ae2a238 (size 576):
> > comm "fsstress", pid 25019, jiffies 4295651360 (age 2276.104s)
> > hex dump (first 32 bytes):
> > 01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
> > 40 7d 37 81 ff ff ff ff 50 a2 e2 2a 00 88 ff ff  @}7.....P..*....
> > backtrace:
> >  [<ffffffff8170e546>] kmemleak_alloc+0x26/0x50
> >  [<ffffffff8119feac>] kmem_cache_alloc+0xdc/0x190
> >  [<ffffffff81378709>] __radix_tree_preload+0x49/0xc0
> >  [<ffffffff813787a1>] radix_tree_maybe_preload+0x21/0x30
> >  [<ffffffff8114bbbc>] add_to_page_cache_lru+0x3c/0xc0
> >  [<ffffffff8114c778>] grab_cache_page_write_begin+0x98/0xf0
> >  [<ffffffffa02d3151>] f2fs_write_begin+0xa1/0x370 [f2fs]
> >  [<ffffffff8114af47>] generic_perform_write+0xc7/0x1e0
> >  [<ffffffff8114d230>] __generic_file_aio_write+0x1d0/0x400
> >  [<ffffffff8114d4c0>] generic_file_aio_write+0x60/0xe0
> >  [<ffffffff811b281a>] do_sync_write+0x5a/0x90
> >  [<ffffffff811b3575>] vfs_write+0xc5/0x1f0
> >  [<ffffffff811b3a92>] SyS_write+0x52/0xb0
> >  [<ffffffff81730912>] system_call_fastpath+0x16/0x1b
> >  [<ffffffffffffffff>] 0xffffffffffffffff
> 
> Do all the backtraces look like the above (coming from
> add_to_page_cache_lru)?
> 
> There were some changes in lib/radix-tree.c since 3.14, maybe you could
> try reverting them and see if the leaks still appear (cc'ing Johannes).
> It could also be a false positive.
>
> An issue with debugging such cases is that the preloading is common for
> multiple radix trees, so the actual radix_tree_node_alloc() could be on
> a different path. You could give the patch below a try to see what
> backtrace you get (it updates backtrace in radix_tree_node_alloc()).

That patch makes a lot of sense to me.  I applied it locally but I am
unable to reproduce this with page cache heavy workloads.  Jaegeuk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
