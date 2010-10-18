Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6443A6B00DB
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:00:53 -0400 (EDT)
Date: Mon, 18 Oct 2010 13:00:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <1286936472.31597.50.camel@debian>
Message-ID: <alpine.DEB.2.00.1010181249540.2092@router.home>
References: <20101005185725.088808842@linux.com>  <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>  <20101006123753.GA17674@localhost> <1286936472.31597.50.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010, Alex,Shi wrote:

> I got the code from
> git://git.kernel.org/pub/scm/linux/kernel/git/christoph/slab.git unified
> on branch "origin/unified" and do a patch base on 36-rc7 kernel. Then I
> tested the patch on our 2P/4P core2 machines and 2P NHM, 2P WSM
> machines. Most of benchmark have no clear improvement or regression. The
> testing benchmarks is listed here.
> http://kernel-perf.sourceforge.net/about_tests.php

Ah. Thanks. The tests needs to show a clear benefit for this to be a
viable solution. They did earlier without all the NUMA queuing on SMP.

> BTW, I save several time kernel panic in fio testing:
> ===================
> > Pid: 776, comm: kswapd0 Not tainted 2.6.36-rc7-unified #1 X8DTN/X8DTN
> > > RIP: 0010:[<ffffffff810cc21c>]  [<ffffffff810cc21c>] slab_alloc
> > > +0x562/0x6f2

Cannot see the error message? I guess this is the result of a BUG_ON()?
I'll try to run that fio test first.

> kswapd0: page allocation failure. order:0, mode:0xd0
> Pid: 714, comm: kswapd0 Not tainted 2.6.36-rc7-unified #1
> Call Trace:
> [<ffffffff8109fcf4>] ? __alloc_pages_nodemask+0x63f/0x6c7
> [<ffffffff8100328e>] ? apic_timer_interrupt+0xe/0x20
> [<ffffffff810cc6f7>] ? new_slab+0xac/0x277
> [<ffffffff810cce1e>] ? slab_alloc+0x55c/0x6e8
> [<ffffffff810ce58b>] ? shared_caches+0x31/0xd9
> [<ffffffff810ce110>] ? __kmalloc+0xb0/0xff
> [<ffffffff810ce58b>] ? shared_caches+0x31/0xd9
> [<ffffffff810ce649>] ? expire_alien_caches+0x16/0x8d
> [<ffffffff810cde25>] ? kmem_cache_expire_all+0xf6/0x14d

Expiration needs to get the gfp flags from the reclaim context. And we
now have more allocations in a reclaim context.

> slab_unreclaimable:2963060kB kernel_stack:1016kB pagetables:656kB

3GB unreclaimable.... Memory leak.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
