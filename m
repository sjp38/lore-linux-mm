Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B7B496B0088
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:32:30 -0400 (EDT)
Date: Thu, 18 Jun 2009 09:33:26 -0700
From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class
 citizen
Message-ID: <20090618093326.2bf1aa43@jbarnes-g45>
In-Reply-To: <20090618012532.GB19732@localhost>
References: <20090516090005.916779788@intel.com>
	<1242485776.32543.834.camel@laptop>
	<20090617141135.0d622bfe@jbarnes-g45>
	<20090618012532.GB19732@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009 09:25:32 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Thu, Jun 18, 2009 at 05:11:35AM +0800, Jesse Barnes wrote:
> > On Sat, 16 May 2009 16:56:16 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Sat, 2009-05-16 at 17:00 +0800, Wu Fengguang wrote:
> > > > Andrew,
> > > > 
> > > > This patchset makes mapped executable pages the first class
> > > > citizen. This version has incorparated many valuable comments
> > > > from people in the CC list, and runs OK on my desktop. Let's
> > > > test it in your -mm?
> > > 
> > > Seems like a good set to me. Thanks for following this through Wu!
> > 
> > Now that this set has hit the mainline I just wanted to chime in and
> > say this makes a big difference.  Under my current load (a parallel
> > kernel build and virtualbox session the old kernel would have been
> > totally unusable.  With Linus's current bits, things are much better
> > (still a little sluggish with a big dd going on in the virtualbox,
> > but actually usable).
> > 
> > Thanks!
> 
> Jesse, thank you for the feedback :)  And I'd like to credit Rik for
> his patch on protecting active file LRU pages from being flushed by
> streaming IO!

Unfortunately I came in this morning to an OOM'd machine.  I do push it
pretty hard, but this is the first time I've seen an OOM.  It happened
yesterday evening while I was away from the machine:

Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426677] apt-check invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426682] apt-check cpuset=/ mems_allowed=0
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426686] Pid: 23105, comm: apt-check Tainted: G    B   W  2.6.30 #11
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426688] Call Trace:
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426696]  [<ffffffff810861fd>] ? cpuset_print_task_mems_allowed+0x8d/0xa0
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426701]  [<ffffffff810b984e>] oom_kill_process+0x17e/0x290
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426705]  [<ffffffff810b9e0b>] ? select_bad_process+0x8b/0x110
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426708]  [<ffffffff810b9ee0>] __out_of_memory+0x50/0xb0
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426712]  [<ffffffff810b9f9f>] out_of_memory+0x5f/0xc0
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426715]  [<ffffffff810bc5a3>] __alloc_pages_nodemask+0x623/0x640
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426719]  [<ffffffff810bf8ea>] __do_page_cache_readahead+0xda/0x210
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426722]  [<ffffffff810bfa3c>] ra_submit+0x1c/0x20
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426725]  [<ffffffff810b886e>] filemap_fault+0x3ce/0x3e0
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426729]  [<ffffffff810ce3a3>] __do_fault+0x53/0x510
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426732]  [<ffffffff810d27ea>] handle_mm_fault+0x1da/0x8c0
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426737]  [<ffffffff814b5724>] do_page_fault+0x1a4/0x310
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426740]  [<ffffffff814b31d5>] page_fault+0x25/0x30
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426742] Mem-Info:
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426744] DMA per-cpu:
Jun 18 07:44:52 jbarnes-g45 kernel: [64377.426746] CPU    0: hi:    0, btch:   1 usd:   0
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426748] CPU    1: hi:    0, btch:   1 usd:   0
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426750] CPU    2: hi:    0, btch:   1 usd:   0
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426752] CPU    3: hi:    0, btch:   1 usd:   0
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426754] DMA32 per-cpu:
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426756] CPU    0: hi:  186, btch:  31 usd: 103
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426758] CPU    1: hi:  186, btch:  31 usd: 117
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426760] CPU    2: hi:  186, btch:  31 usd: 181
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426762] CPU    3: hi:  186, btch:  31 usd: 181
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426766] Active_anon:290797 active_file:28 inactive_anon:97034
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426767]  inactive_file:61 unevictable:11322 dirty:0 writeback:0 unstable:0
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426768]  free:3341 slab:13776 mapped:5880 pagetables:6851 bounce:0
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426772] DMA free:7776kB min:40kB low:48kB high:60kB active_anon:556kB inactive_anon:524kB active_file:16kB inactive_file:0kB unevictable:0kB present:15340kB pages_scanned:30 all_unreclaimable? no
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426775] lowmem_reserve[]: 0 1935 1935 1935
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426781] DMA32 free:5588kB min:5608kB low:7008kB high:8412kB active_anon:1162632kB inactive_anon:387612kB active_file:96kB inactive_file:256kB unevictable:45288kB present:1982128kB pages_scanned:980 all_unreclaimable? no
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426784] lowmem_reserve[]: 0 0 0 0
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426787] DMA: 64*4kB 77*8kB 45*16kB 18*32kB 4*64kB 2*128kB 2*256kB 3*512kB 1*1024kB 1*2048kB 0*4096kB = 7800kB
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426796] DMA32: 871*4kB 149*8kB 1*16kB 2*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 5588kB
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426804] 151250 total pagecache pages
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426806] 18973 pages in swap cache
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426808] Swap cache stats: add 610640, delete 591667, find 144356/181468
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426810] Free swap  = 0kB
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426811] Total swap = 979956kB
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434828] 507136 pages RAM
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434831] 23325 pages reserved
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434832] 190892 pages shared
Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434833] 248816 pages non-shared

As you can see, all my swap has been eaten and my anon lists are pretty
huge (relative to memory size, I only have 2G in this box).  I suspect
the gfx driver is eating quite a bit of the anon memory, but this is
the first OOM I've seen...  I'll look around for some tools to analyze
my anon memory usage; maybe Virtualbox is doing something pathological;
clearly something is out of control here at any rate.
-- 
Jesse Barnes, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
