Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94B7F6B0038
	for <linux-mm@kvack.org>; Fri,  1 May 2015 20:09:26 -0400 (EDT)
Received: by oica37 with SMTP id a37so79908331oic.0
        for <linux-mm@kvack.org>; Fri, 01 May 2015 17:09:26 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id d9si4166536oic.46.2015.05.01.17.09.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 May 2015 17:09:25 -0700 (PDT)
Message-ID: <554415B1.2050702@hp.com>
Date: Fri, 01 May 2015 20:09:21 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
References: <1430231830-7702-1-git-send-email-mgorman@suse.de> <554030D1.8080509@hp.com> <5543F802.9090504@hp.com>
In-Reply-To: <5543F802.9090504@hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/01/2015 06:02 PM, Waiman Long wrote:
>
> Bad news!
>
> I tried your patch on a 24-TB DragonHawk and got an out of memory 
> panic. The kernel log messages were:
>   :
> [   80.126186] CPU  474: hi:  186, btch:  31 usd:   0
> [   80.131457] CPU  475: hi:  186, btch:  31 usd:   0
> [   80.136726] CPU  476: hi:  186, btch:  31 usd:   0
> [   80.141997] CPU  477: hi:  186, btch:  31 usd:   0
> [   80.147267] CPU  478: hi:  186, btch:  31 usd:   0
> [   80.152538] CPU  479: hi:  186, btch:  31 usd:   0
> [   80.157813] active_anon:0 inactive_anon:0 isolated_anon:0
> [   80.157813]  active_file:0 inactive_file:0 isolated_file:0
> [   80.157813]  unevictable:0 dirty:0 writeback:0 unstable:0
> [   80.157813]  free:209 slab_reclaimable:7 slab_unreclaimable:42986
> [   80.157813]  mapped:0 shmem:0 pagetables:0 bounce:0
> [   80.157813]  free_cma:0
> [   80.190428] Node 0 DMA free:568kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB 
> managed:15896kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB 
> shmem:0kB slab_reclaimable:0kB slab_unreclaimable:14928kB 
> kernel_stack:400kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB 
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> [   80.233475] lowmem_reserve[]: 0 0 0 0
> [   80.237542] Node 0 DMA32 free:20kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1961924kB managed:1333604kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:12kB 
> slab_unreclaimable:101664kB kernel_stack:50176kB pagetables:0kB 
> unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.281456] lowmem_reserve[]: 0 0 0 0
> [   80.285527] Node 0 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1608515580kB managed:2097148kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:4kB 
> slab_unreclaimable:948kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.328958] lowmem_reserve[]: 0 0 0 0
> [   80.333031] Node 1 Normal free:248kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612732kB managed:2228220kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:12kB 
> slab_unreclaimable:46240kB kernel_stack:3232kB pagetables:0kB 
> unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.377256] lowmem_reserve[]: 0 0 0 0
> [   80.381325] Node 2 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:612kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.424764] lowmem_reserve[]: 0 0 0 0
> [   80.428842] Node 3 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:600kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.472293] lowmem_reserve[]: 0 0 0 0
> [   80.476360] Node 4 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:620kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.519803] lowmem_reserve[]: 0 0 0 0
> [   80.523875] Node 5 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:584kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.567312] lowmem_reserve[]: 0 0 0 0
> [   80.571379] Node 6 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:556kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.614814] lowmem_reserve[]: 0 0 0 0
> [   80.618881] Node 7 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:556kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.662316] lowmem_reserve[]: 0 0 0 0
> [   80.666390] Node 8 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:572kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.709827] lowmem_reserve[]: 0 0 0 0
> [   80.713898] Node 9 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:572kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.757336] lowmem_reserve[]: 0 0 0 0
> [   80.761407] Node 10 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:564kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.804941] lowmem_reserve[]: 0 0 0 0
> [   80.809015] Node 11 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:572kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.852548] lowmem_reserve[]: 0 0 0 0
> [   80.856620] Node 12 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:616kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.900158] lowmem_reserve[]: 0 0 0 0
> [   80.904236] Node 13 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:592kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.947765] lowmem_reserve[]: 0 0 0 0
> [   80.951847] Node 14 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:600kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   80.995380] lowmem_reserve[]: 0 0 0 0
> [   80.999448] Node 15 Normal free:0kB min:0kB low:0kB high:0kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:1610612736kB managed:2097152kB mlocked:0kB dirty:0kB 
> writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:548kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? yes
> [   81.042974] lowmem_reserve[]: 0 0 0 0
> [   81.047044] Node 0 DMA: 132*4kB (U) 5*8kB (U) 0*16kB 0*32kB 0*64kB 
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 568kB
> [   81.059632] Node 0 DMA32: 5*4kB (U) 0*8kB 0*16kB 0*32kB 0*64kB 
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20kB
> [   81.071733] Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.083443] Node 1 Normal: 52*4kB (U) 5*8kB (U) 0*16kB 0*32kB 
> 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 248kB
> [   81.096227] Node 2 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.107935] Node 3 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.119643] Node 4 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.131347] Node 5 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.143056] Node 6 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.154767] Node 7 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.166473] Node 8 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.178179] Node 9 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.189893] Node 10 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.201695] Node 11 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.213496] Node 12 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.225324] Node 13 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.237130] Node 14 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.248926] Node 15 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 
> 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> [   81.260726] 0 total pagecache pages
> [   81.264565] 0 pages in swap cache
> [   81.268212] Swap cache stats: add 0, delete 0, find 0/0
> [   81.273962] Free swap  = 0kB
> [   81.277125] Total swap = 0kB
> [   81.280341] 6442421132 pages RAM
> [   81.283888] 0 pages HighMem/MovableOnly
> [   81.288109] 6433662383 pages reserved
> [   81.292135] 0 pages hwpoisoned
> [   81.295491] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds 
> swapents oom_score_adj name
> [   81.305245] Kernel panic - not syncing: Out of memory and no 
> killable processes...
> [   81.305245]
> [   81.315200] CPU: 240 PID: 1 Comm: swapper/0 Not tainted 
> 4.0.1-pmm-bigsmp #1
> [   81.322856] Hardware name: HP Superdome2 16s x86, BIOS Bundle: 
> 006.000.042 SFW: 015.099.000 04/01/2015
> [   81.333096]  0000000000000000 ffff8800044c79c8 ffffffff8151b0c9 
> ffff8800044c7a48
> [   81.341262]  ffffffff8151ae1e 0000000000000008 ffff8800044c7a58 
> ffff8800044c79f8
> [   81.349428]  ffffffff810785c3 ffffffff81a13480 0000000000000000 
> ffff8800001001d0
> [   81.357595] Call Trace:
> [   81.360287]  [<ffffffff8151b0c9>] dump_stack+0x68/0x77
> [   81.365942]  [<ffffffff8151ae1e>] panic+0xb9/0x219
> [   81.371213]  [<ffffffff810785c3>] ? 
> __blocking_notifier_call_chain+0x63/0x80
> [   81.378971]  [<ffffffff811384ce>] __out_of_memory+0x34e/0x350
> [   81.385292]  [<ffffffff811385ee>] out_of_memory+0x5e/0x90
> [   81.391230]  [<ffffffff8113ce9e>] __alloc_pages_slowpath+0x6be/0x740
> [   81.398219]  [<ffffffff8113d15c>] __alloc_pages_nodemask+0x23c/0x250
> [   81.405212]  [<ffffffff81186346>] kmem_getpages+0x56/0x110
> [   81.411246]  [<ffffffff81187f44>] fallback_alloc+0x164/0x200
> [   81.417474]  [<ffffffff81187cfd>] ____cache_alloc_node+0x8d/0x170
> [   81.424179]  [<ffffffff811887bb>] kmem_cache_alloc_trace+0x17b/0x240
> [   81.431169]  [<ffffffff813d5f3a>] init_memory_block+0x3a/0x110
> [   81.437586]  [<ffffffff81b5f687>] memory_dev_init+0xd7/0x13d
> [   81.443810]  [<ffffffff81b5f2af>] driver_init+0x2f/0x37
> [   81.449556]  [<ffffffff81b1599b>] do_basic_setup+0x29/0xd5
> [   81.455597]  [<ffffffff81b372c4>] ? sched_init_smp+0x140/0x147
> [   81.462015]  [<ffffffff81b15c55>] kernel_init_freeable+0x20e/0x297
> [   81.468815]  [<ffffffff81512ea0>] ? rest_init+0x80/0x80
> [   81.474565]  [<ffffffff81512ea9>] kernel_init+0x9/0xf0
> [   81.480216]  [<ffffffff8151f788>] ret_from_fork+0x58/0x90
> [   81.486156]  [<ffffffff81512ea0>] ? rest_init+0x80/0x80
> [   81.492350] ---[ end Kernel panic - not syncing: Out of memory and 
> no killable processes...
> [   81.492350]
>
> -Longman

I increased the pre-initialized memory per node in update_defer_init() 
of mm/page_alloc.c from 2G to 4G. Now I am able to boot the 24-TB 
machine without error. The 12-TB has 0.75TB/node, while the 24-TB 
machine has 1.5TB/node. I would suggest something like pre-initializing 
1G per 0.25TB/node. In this way, it will scale properly with the memory 
size.

Before the patch, the boot time from elilo prompt to ssh login was 694s. 
After the patch, the boot up time was 346s, a saving of 348s (about 50%).

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
