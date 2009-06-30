Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 91B7F6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:05:09 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so39615rvb.26
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 07:05:16 -0700 (PDT)
Date: Tue, 30 Jun 2009 22:05:12 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090630140512.GA16923@localhost>
References: <20090628142239.GA20986@localhost> <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com> <20090628151026.GB25076@localhost> <20090629091741.ab815ae7.minchan.kim@barrios-desktop> <17678.1246270219@redhat.com> <20090629125549.GA22932@localhost> <29432.1246285300@redhat.com> <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com> <30071.1246290885@redhat.com> <1246291007.663.630.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246291007.663.630.camel@macbook.infradead.org>
Sender: owner-linux-mm@kvack.org
To: David Woodhouse <dwmw2@infradead.org>
Cc: David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 29, 2009 at 11:56:47PM +0800, David Woodhouse wrote:
> On Mon, 2009-06-29 at 16:54 +0100, David Howells wrote:
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> >
> > > Yes this time the OOM order/flags are much different from all previous OOMs.
> > >
> > > btw, I found that msgctl11 is pretty good at making a lot of SUnreclaim and
> > > PageTables pages:
> >
> > I got David Woodhouse to run this on one of this boxes, but he doesn't see the
> > problem, I think because he's got 4GB of RAM, and never comes close to running
> > out.
> >
> > I've asked him to reboot with mem=1G to see if that helps reproduce it.
>
> msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
> Pid: 5795, comm: msgctl11 Not tainted 2.6.31-rc1 #147
> Call Trace:
>  [<ffffffff81092c77>] oom_kill_process.clone.0+0xac/0x254
>  [<ffffffff81092b5c>] ? badness+0x24d/0x2bc
>  [<ffffffff81092f5f>] __out_of_memory+0x140/0x157
>  [<ffffffff8109308f>] out_of_memory+0x119/0x150
>  [<ffffffff81095c65>] ? drain_local_pages+0x16/0x18
>  [<ffffffff810967ab>] __alloc_pages_nodemask+0x45a/0x55b
>  [<ffffffff810a32b0>] ? __inc_zone_page_state+0x2e/0x30
>  [<ffffffff810bb6b9>] alloc_pages_current+0xae/0xb6
>  [<ffffffff810a604a>] ? do_wp_page+0x621/0x6c3
>  [<ffffffff81094d7e>] __get_free_pages+0xe/0x4b
>  [<ffffffff810403a7>] copy_process+0xab/0x11a5
>  [<ffffffff810327c8>] ? check_preempt_wakeup+0x11a/0x142
>  [<ffffffff810a7a06>] ? handle_mm_fault+0x678/0x6e9
>  [<ffffffff810415ec>] do_fork+0x14b/0x338
>  [<ffffffff8105b50a>] ? up_read+0xe/0x10
>  [<ffffffff814ee655>] ? do_page_fault+0x2da/0x307
>  [<ffffffff8100a55c>] sys_clone+0x28/0x2a
>  [<ffffffff8100bfc3>] stub_clone+0x13/0x20
>  [<ffffffff8100bcdb>] ? system_call_fastpath+0x16/0x1b
> Mem-Info:
> Node 0 DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> CPU    2: hi:    0, btch:   1 usd:   0
> CPU    3: hi:    0, btch:   1 usd:   0
> CPU    4: hi:    0, btch:   1 usd:   0
> CPU    5: hi:    0, btch:   1 usd:   0
> CPU    6: hi:    0, btch:   1 usd:   0
> CPU    7: hi:    0, btch:   1 usd:   0
> Node 0 DMA32 per-cpu:
> CPU    0: hi:  186, btch:  31 usd:   0
> CPU    1: hi:  186, btch:  31 usd:  20
> CPU    2: hi:  186, btch:  31 usd:  19
> CPU    3: hi:  186, btch:  31 usd:  20
> CPU    4: hi:  186, btch:  31 usd:  19
> CPU    5: hi:  186, btch:  31 usd:  24
> CPU    6: hi:  186, btch:  31 usd:  41
> CPU    7: hi:  186, btch:  31 usd:  25
> Active_anon:72835 active_file:89 inactive_anon:575
>  inactive_file:103 unevictable:0 dirty:36 writeback:0 unstable:0
>  free:2467 slab:38211 mapped:229 pagetables:66918 bounce:0
> Node 0 DMA free:4036kB min:60kB low:72kB high:88kB active_anon:3228kB inactive_a
> non:256kB active_file:0kB inactive_file:0kB unevictable:0kB present:15356kB page
> s_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 994 994 994
> Node 0 DMA32 free:5832kB min:4000kB low:5000kB high:6000kB active_anon:288112kB
> inactive_anon:2044kB active_file:356kB inactive_file:412kB unevictable:0kB prese
> nt:1018080kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 0 DMA: 1*4kB 2*8kB 1*16kB 0*32kB 1*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 1*
> 2048kB 0*4096kB = 3940kB
> Node 0 DMA32: 852*4kB 1*8kB 0*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024k
> B 0*2048kB 0*4096kB = 5304kB
> 437 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 262144 pages RAM
> 6503 pages reserved
> 205864 pages shared
> 226536 pages non-shared
> Out of memory: kill process 3855 (msgctl11) score 179248 or a child
> Killed process 4222 (msgctl11)

More data: I boot 2.6.30-rc1 with mem=1G and enabled 1GB swap and run msgctl11.

It goes OOM at the 2nd run. They are very interesting numbers: memory leaked?

        [ 2259.825958] msgctl11 invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0
        [ 2259.828092] Pid: 29657, comm: msgctl11 Not tainted 2.6.31-rc1 #22
        [ 2259.830505] Call Trace:
        [ 2259.832010]  [<ffffffff8156f366>] ? _spin_unlock+0x26/0x30
        [ 2259.834219]  [<ffffffff810c8b26>] oom_kill_process+0x176/0x270
        [ 2259.837603]  [<ffffffff810c8def>] ? badness+0x18f/0x300
        [ 2259.839906]  [<ffffffff810c9095>] __out_of_memory+0x135/0x170
        [ 2259.842035]  [<ffffffff810c91c5>] out_of_memory+0xf5/0x180
        [ 2259.844270]  [<ffffffff810cd86c>] __alloc_pages_nodemask+0x6ac/0x6c0
        [ 2259.846743]  [<ffffffff810f8fa8>] alloc_pages_current+0x78/0x100
        [ 2259.849083]  [<ffffffff81033515>] pte_alloc_one+0x15/0x50
        [ 2259.851282]  [<ffffffff810e0eda>] __pte_alloc+0x2a/0xf0
        [ 2259.853454]  [<ffffffff810e16e2>] handle_mm_fault+0x742/0x830
        [ 2259.855793]  [<ffffffff815725cb>] do_page_fault+0x1cb/0x330
        [ 2259.858033]  [<ffffffff8156fdf5>] page_fault+0x25/0x30
        [ 2259.860301] Mem-Info:
        [ 2259.861706] Node 0 DMA per-cpu:
        [ 2259.862523] CPU    0: hi:    0, btch:   1 usd:   0
        [ 2259.864454] CPU    1: hi:    0, btch:   1 usd:   0
        [ 2259.866608] Node 0 DMA32 per-cpu:
        [ 2259.867404] CPU    0: hi:  186, btch:  31 usd: 197
        [ 2259.869283] CPU    1: hi:  186, btch:  31 usd: 175
        [ 2259.870511] Active_anon:0 active_file:11 inactive_anon:0

zero anon pages!

        [ 2259.870512]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
        [ 2259.870513]  free:1986 slab:42170 mapped:96 pagetables:59427 bounce:0
        [ 2259.877722] Node 0 DMA free:3976kB min:56kB low:68kB high:84kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15164kB pages_scanned:429 all_unreclaimable? no
        [ 2259.883804] lowmem_reserve[]: 0 982 982 982
        [ 2259.885814] Node 0 DMA32 free:3968kB min:3980kB low:4972kB high:5968kB active_anon:0kB inactive_anon:0kB active_file:44kB inactive_file:0kB unevictable:0kB present:1005984kB pages_scanned:152 all_unreclaimable? no
        [ 2259.890958] lowmem_reserve[]: 0 0 0 0
        [ 2259.893183] Node 0 DMA: 4*4kB 3*8kB 2*16kB 0*32kB 1*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3976kB
        [ 2259.897406] Node 0 DMA32: 334*4kB 77*8kB 24*16kB 27*32kB 10*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3968kB
        [ 2259.902753] 625 total pagecache pages
        [ 2259.903623] 454 pages in swap cache
        [ 2259.905299] Swap cache stats: add 95129, delete 94675, find 55783/67607
        [ 2259.908858] Free swap  = 1041232kB
        [ 2259.909618] Total swap = 1048568kB

swap far from full!

        [ 2259.919456] 262144 pages RAM
        [ 2259.921071] 12513 pages reserved
        [ 2259.922790] 314212 pages shared
        [ 2259.923548] 165757 pages non-shared
        [ 2259.925234] Out of memory: kill process 20791 (msgctl11) score 2280094 or a child
        [ 2259.928982] Killed process 21946 (msgctl11)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
