Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 191C46B0253
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 16:56:43 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id d187so663538156ywe.1
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 13:56:43 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id j76si1441783ybj.329.2016.11.21.13.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 Nov 2016 13:56:42 -0800 (PST)
Date: Mon, 21 Nov 2016 13:56:39 -0800
From: Marc MERLIN <marc@merlins.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of RAM that should be free
Message-ID: <20161121215639.GF13371@merlins.org>
References: <20161121154336.GD19750@merlins.org> <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Nov 21, 2016 at 10:50:20PM +0100, Vlastimil Babka wrote:
> > 4.9rc5 however seems to be doing better, and is still running after 18
> > hours. However, I got a few page allocation failures as per below, but the
> > system seems to recover.
> > Vlastimil, do you want me to continue the copy on 4.9 (may take 3-5 days) 
> > or is that good enough, and i should go back to 4.8.8 with that patch applied?
> > https://marc.info/?l=linux-mm&m=147423605024993
> 
> Hi, I think it's enough for 4.9 for now and I would appreciate trying
> 4.8 with that patch, yeah.

So the good news is that it's been running for almost 5H and so far so good.

> The failures below are in a GFP_NOWAIT context, which cannot do any
> reclaim so it's not affected by OOM rewrite. If it's a regression, it
> has to be caused by something else. But it seems the code in
> cfq_get_queue() intentionally doesn't want to reclaim or use any atomic
> reserves, and has a fallback scenario for allocation failure, in which
> case I would argue that it should add __GFP_NOWARN, as these warnings
> can't help anyone. CCing Tejun as author of commit d4aad7ff0.

No, that's not a regression, I get those on occasion. The good news is that they're not
fatal. Just got another one with 4.8.8.
No idea if they're actual errors I should worry about, or just warnings that spam
the console a bit, but things retry, recover and succeed, so I can ignore them.

Another one from 4.8.8 below. I'll report back tomorrow to see if this has run for a day
and if so, I'll call your patch a fix for my problem (but at this point, it's already
looking very good).

Thanks, Marc

cron: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
CPU: 4 PID: 9748 Comm: cron Tainted: G     U          4.8.8-amd64-volpreempt-sysrq-20161108vb2 #9
Hardware name: System manufacturer System Product Name/P8H67-M PRO, BIOS 3904 04/27/2013
 0000000000000000 ffffa1e37429f6d0 ffffffff9a36a0bb 0000000000000000
 0000000000000000 ffffa1e37429f768 ffffffff9a1359d4 022040009f5e8d00
 0000000000000012 0000000000000000 0000000000000000 ffffffff9a140770
Call Trace:
 [<ffffffff9a36a0bb>] dump_stack+0x61/0x7d
 [<ffffffff9a1359d4>] warn_alloc_failed+0x11c/0x132
 [<ffffffff9a140770>] ? wakeup_kswapd+0x8e/0x153
 [<ffffffff9a1362d8>] __alloc_pages_nodemask+0x87b/0xb02
 [<ffffffff9a1362d8>] ? __alloc_pages_nodemask+0x87b/0xb02
 [<ffffffff9a17b388>] cache_grow_begin+0xb2/0x30b
 [<ffffffff9a17ba49>] fallback_alloc+0x137/0x19f
 [<ffffffff9a17b907>] ____cache_alloc_node+0xd3/0xde
 [<ffffffff9a17bb3f>] kmem_cache_alloc_node+0x8e/0x163
 [<ffffffff9a36578f>] cfq_get_queue+0x162/0x29d
 [<ffffffff9a17c1ea>] ? kmem_cache_alloc+0xd7/0x14b
 [<ffffffff9a17acc0>] ? slab_post_alloc_hook+0x5b/0x66
 [<ffffffff9a365a0b>] cfq_set_request+0x141/0x2be
 [<ffffffff9a0ba1ed>] ? timekeeping_get_ns+0x1e/0x32
 [<ffffffff9a0ba39d>] ? ktime_get+0x41/0x52
 [<ffffffff9a361bd8>] ? ktime_get_ns+0x9/0xb
 [<ffffffff9a361c0f>] ? cfq_init_icq+0x12/0x19
 [<ffffffff9a340407>] elv_set_request+0x1f/0x24
 [<ffffffff9a34367d>] get_request+0x324/0x5aa
 [<ffffffff9a091aed>] ? wake_up_atomic_t+0x2c/0x2c
 [<ffffffff9a346005>] blk_queue_bio+0x19f/0x28c
 [<ffffffff9a3448e0>] generic_make_request+0xbd/0x160
 [<ffffffff9a344a83>] submit_bio+0x100/0x11d
 [<ffffffff9a16c7cb>] ? map_swap_page+0x12/0x14
 [<ffffffff9a169835>] ? get_swap_bio+0x57/0x6c
 [<ffffffff9a169dd0>] swap_readpage+0x110/0x118
 [<ffffffff9a16a39d>] read_swap_cache_async+0x26/0x2d
 [<ffffffff9a16a4be>] swapin_readahead+0x11a/0x16a
 [<ffffffff9a159167>] do_swap_page+0x9c/0x431
 [<ffffffff9a159167>] ? do_swap_page+0x9c/0x431
 [<ffffffff9a15b4af>] handle_mm_fault+0xa4d/0xb3d
 [<ffffffff9a19ce81>] ? vfs_getattr_nosec+0x26/0x37
 [<ffffffff9a050e06>] __do_page_fault+0x267/0x43d
 [<ffffffff9a051001>] do_page_fault+0x25/0x27
 [<ffffffff9a698c18>] page_fault+0x28/0x30
Mem-Info:
active_anon:532194 inactive_anon:133376 isolated_anon:0
 active_file:4118244 inactive_file:382010 isolated_file:0
 unevictable:1687 dirty:3502 writeback:386111 unstable:0
 slab_reclaimable:41767 slab_unreclaimable:106595
 mapped:512496 shmem:582026 pagetables:5352 bounce:0
 free:92092 free_pcp:176 free_cma:2072
Node 0 active_anon:2128776kB inactive_anon:533504kB active_file:16472976kB inactive_file:1528040kB unevictable:6748kB isolated(anon):0kB isolated(file):0kB mapped:2049984kB dirty:14008kB writeback:1544444kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2328104kB writeback_tmp:0kB unstable:0kB pages_scanned:1 all_unreclaimable? no
Node 0 DMA free:15884kB min:168kB low:208kB high:248kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15976kB managed:15892kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 3200 23767 23767 23767
Node 0 DMA32 free:117580kB min:35424kB low:44280kB high:53136kB active_anon:3980kB inactive_anon:400kB active_file:2632672kB inactive_file:286956kB unevictable:0kB writepending:288296kB present:3362068kB managed:3296500kB mlocked:0kB slab_reclaimable:41632kB slab_unreclaimable:19512kB kernel_stack:880kB pagetables:676kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 0 20567 20567 20567
Node 0 Normal free:234904kB min:226544kB low:283180kB high:339816kB active_anon:2124796kB inactive_anon:533104kB active_file:13840304kB inactive_file:1241268kB unevictable:6748kB writepending:1270156kB present:21485568kB managed:21080636kB mlocked:6748kB slab_reclaimable:125436kB slab_unreclaimable:406860kB kernel_stack:12432kB pagetables:20732kB bounce:0kB free_pcp:704kB local_pcp:108kB free_cma:8288kB
lowmem_reserve[]: 0 0 0 0 0
Node 0 DMA: 1*4kB (U) 1*8kB (U) 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15884kB
Node 0 DMA32: 10970*4kB (UME) 5760*8kB (UME) 1737*16kB (UM) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 117752kB
Node 0 Normal: 32844*4kB (UMEHC) 12063*8kB (UMHC) 54*16kB (MHC) 23*32kB (MHC) 14*64kB (MC) 12*128kB (C) 2*256kB (C) 0*512kB 1*1024kB (C) 1*2048kB (C) 0*4096kB = 235496kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
5095318 total pagecache pages
12175 pages in swap cache
Swap cache stats: add 959044, delete 946869, find 485396/573209
Free swap  = 14575420kB
Total swap = 15616764kB
6215903 pages RAM
0 pages HighMem/MovableOnly
117646 pages reserved
4096 pages cma reserved
0 pages hwpoisoned

-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
