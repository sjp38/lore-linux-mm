Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12A876B0253
	for <linux-mm@kvack.org>; Sun, 26 Jun 2016 15:40:33 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so106713618lfe.0
        for <linux-mm@kvack.org>; Sun, 26 Jun 2016 12:40:33 -0700 (PDT)
Received: from mail.sig21.net (mail.sig21.net. [80.244.240.74])
        by mx.google.com with ESMTPS id la7si21540406wjc.175.2016.06.26.12.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Jun 2016 12:40:31 -0700 (PDT)
Date: Sun, 26 Jun 2016 21:40:25 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: 4.6.2 frequent crashes under memory + IO pressure
Message-ID: <20160626194025.GA8015@sig21.net>
References: <20160625155006.GA4166@sig21.net>
 <201606260204.BDB48978.FSFFJQHOMLVOtO@I-love.SAKURA.ne.jp>
 <20160625172951.GA5586@sig21.net>
 <201606261800.FGF57303.OFtMFSQHJFLOVO@I-love.SAKURA.ne.jp>
 <20160626150958.GA3780@sig21.net>
 <201606270135.CGD13081.LHFtFVQOSOMOJF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606270135.CGD13081.LHFtFVQOSOMOJF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org

(adding back Cc:, just dropped it to send the logs)

On Mon, Jun 27, 2016 at 01:35:14AM +0900, Tetsuo Handa wrote:
> 
> It seems to me that GFP_NOIO allocation requests are depleting memory reserves
> because they are passing ALLOC_NO_WATERMARKS to get_page_from_freelist().
> But I'm not familiar with block layer / swap I/O operation. So, will you post
> to linux-mm ML for somebody else to help you?

Frankly I don't care that much about 4.6.y when 4.7 is fixed.
Or, maybe the root issue is not fixed but the new oom code
covers it.  Below I see both dm and kcryptd so there is no
surprise when using swap on lvm on dm-crypt triggers it.
Maybe it's not a new issue on 4.6 but just some random variation
that makes it trigger easier with my particular workload.

So, unless you would like to keep going at it I'd
like to put the issue at rest.

> kswapd0(766) 0x2201200
>  0xffffffff81167522 : get_page_from_freelist+0x0/0x82b [kernel]
>  0xffffffff81168127 : __alloc_pages_nodemask+0x3da/0x978 [kernel]
>  0xffffffff8119fb2a : new_slab+0xbc/0x3bb [kernel]
>  0xffffffff811a1acd : ___slab_alloc.constprop.22+0x2fb/0x37b [kernel]
>  0xffffffff81162a88 : mempool_alloc_slab+0x15/0x17 [kernel] (inexact)
>  0xffffffff810c502d : put_lock_stats.isra.9+0xe/0x20 [kernel] (inexact)
>  0xffffffff811a1ba4 : __slab_alloc.isra.17.constprop.21+0x57/0x8b [kernel] (inexact)
>  0xffffffff811a1ba4 : __slab_alloc.isra.17.constprop.21+0x57/0x8b [kernel] (inexact)
>  0xffffffff81162a88 : mempool_alloc_slab+0x15/0x17 [kernel] (inexact)
>  0xffffffff811a1c78 : kmem_cache_alloc+0xa0/0x1d6 [kernel] (inexact)
>  0xffffffff81162a88 : mempool_alloc_slab+0x15/0x17 [kernel] (inexact)
>  0xffffffff81162a88 : mempool_alloc_slab+0x15/0x17 [kernel] (inexact)
>  0xffffffff81162b7a : mempool_alloc+0x72/0x154 [kernel] (inexact)
>  0xffffffff810c6438 : __lock_acquire.isra.16+0x55e/0xb4c [kernel] (inexact)
>  0xffffffff8133fdc1 : bio_alloc_bioset+0xe8/0x1d7 [kernel] (inexact)
>  0xffffffff816342ea : alloc_tio+0x2d/0x47 [kernel] (inexact)
>  0xffffffff8163587e : __split_and_process_bio+0x310/0x3a3 [kernel] (inexact)
>  0xffffffff81635e15 : dm_make_request+0xb5/0xe2 [kernel] (inexact)
>  0xffffffff81347ae7 : generic_make_request+0xcc/0x180 [kernel] (inexact)
>  0xffffffff81347c98 : submit_bio+0xfd/0x145 [kernel] (inexact)
> 
> kswapd0(766) 0x2201200
>  0xffffffff81167522 : get_page_from_freelist+0x0/0x82b [kernel]
>  0xffffffff81168127 : __alloc_pages_nodemask+0x3da/0x978 [kernel]
>  0xffffffff8119fb2a : new_slab+0xbc/0x3bb [kernel]
>  0xffffffff811a1acd : ___slab_alloc.constprop.22+0x2fb/0x37b [kernel]
>  0xffffffff81162a88 : mempool_alloc_slab+0x15/0x17 [kernel] (inexact)
>  0xffffffff81640e29 : kcryptd_queue_crypt+0x63/0x68 [kernel] (inexact)
>  0xffffffff811a1ba4 : __slab_alloc.isra.17.constprop.21+0x57/0x8b [kernel] (inexact)
>  0xffffffff811a1ba4 : __slab_alloc.isra.17.constprop.21+0x57/0x8b [kernel] (inexact)
>  0xffffffff81162a88 : mempool_alloc_slab+0x15/0x17 [kernel] (inexact)
>  0xffffffff811a1c78 : kmem_cache_alloc+0xa0/0x1d6 [kernel] (inexact)
>  0xffffffff81162a88 : mempool_alloc_slab+0x15/0x17 [kernel] (inexact)
>  0xffffffff81162a88 : mempool_alloc_slab+0x15/0x17 [kernel] (inexact)
>  0xffffffff81162b7a : mempool_alloc+0x72/0x154 [kernel] (inexact)
>  0xffffffff8101f5ba : sched_clock+0x9/0xd [kernel] (inexact)
>  0xffffffff810ae420 : local_clock+0x20/0x22 [kernel] (inexact)
>  0xffffffff8133fdc1 : bio_alloc_bioset+0xe8/0x1d7 [kernel] (inexact)
>  0xffffffff811983d0 : end_swap_bio_write+0x0/0x6a [kernel] (inexact)
>  0xffffffff8119854b : get_swap_bio+0x25/0x6c [kernel] (inexact)
>  0xffffffff811983d0 : end_swap_bio_write+0x0/0x6a [kernel] (inexact)
>  0xffffffff811988ef : __swap_writepage+0x1a9/0x225 [kernel] (inexact)
> 
> > 
> > > # ~/systemtap.tmp/bin/stap -e 'global traces_bt[65536];
> > > probe begin { printf("Probe start!\n"); }
> > > function dump_if_new(mask:long) {
> > >   bt = backtrace();
> > >   if (traces_bt[bt]++ == 0) {
> > >     printf("%s(%u) 0x%lx\n", execname(), pid(), mask);
> > >     print_backtrace();
> > >     printf("\n");
> > >   }
> > > }
> > > probe kernel.function("get_page_from_freelist") { if ($alloc_flags & 0x4) dump_if_new($gfp_mask); }
> > > probe kernel.function("gfp_pfmemalloc_allowed").return { if ($return != 0) dump_if_new($gfp_mask); }
> > > probe end { delete traces_bt; }'
> > ...
> > > # addr2line -i -e /usr/src/linux-4.6.2/vmlinux 0xffffffff811b9c82
> > > /usr/src/linux-4.6.2/mm/memory.c:1162
> > > /usr/src/linux-4.6.2/mm/memory.c:1241
> > > /usr/src/linux-4.6.2/mm/memory.c:1262
> > > /usr/src/linux-4.6.2/mm/memory.c:1283
> > 
> > I'm attaching both the stap output and the serial console log,
> > not sure what you're looking for with addr2line.  Let me know.
> 
> I just meant how to find location in source code from addresses.

I meant the log is so large I wouldn't know which
addresses would be interesting to look up.

Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
