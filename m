Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E84B66B0261
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 03:44:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f193so4613683wmg.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 00:44:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a193si1401629wme.108.2016.10.12.00.44.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 00:44:14 -0700 (PDT)
Date: Wed, 12 Oct 2016 09:44:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM in v4.8
Message-ID: <20161012074411.GA9523@dhcp22.suse.cz>
References: <20161012065423.GA16092@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161012065423.GA16092@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, lkp@01.org, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>

[Let's CC Vlastimil]

On Wed 12-10-16 14:54:23, Aaron Lu wrote:
> Hello,
> 
> There is a chromeswap test case:
> https://chromium.googlesource.com/chromiumos/third_party/autotest/+/master/client/site_tests/platform_CompressedSwapPerf
> 
> We have done small changes and ported it to our LKP environment:
> https://github.com/aaronlu/chromeswap
> 
> The test starts nr_procs processes and let them each allocate some
> memory equally with realloc, so anonymous pages are used. When the
> pre-specified swap_target is reached, the allocation will stop. The
> total allocation size is: MemFree + swap_target * SwapTotal.
> After allocation, a random process is selected to touch its memory to
> trigger swap in/out.
> 
> For this test, nr_procs is 50 and swap_target is 50%.
> The test box has 8G memory where 4G is used as a pmem block device and
> created as the swap partition.
> 
> There is OOM occured for this test recently so I did more tests:
> on v4.6, 10 tests all pass;
> on v4.7, 2 tests OOMed out of 10 tests;
> on v4.8, 6 tests OOMed out of 10 tests;
> on 101105b1717f, which is yersterday's Linus' master branch head,
> 1 test OOMed out of 10 tests.

Could you try to retest with the current linux-next please?
 
> SO things are much better than v4.8 now.
> 
> When OOM occurred, there is still enough swap space though:
> 
> kern  :warn  : [   38.708419] proc-vmstat invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
[...]
> kern  :warn  : [   38.880744] Mem-Info:
> kern  :warn  : [   38.883875] active_anon:622526 inactive_anon:154230 isolated_anon:0
>                                active_file:0 inactive_file:1 isolated_file:0
>                                unevictable:94198 dirty:0 writeback:0 unstable:3
>                                slab_reclaimable:59989 slab_unreclaimable:6489
>                                mapped:6022 shmem:257 pagetables:3956 bounce:0
>                                free:17325 free_pcp:357 free_cma:897
[...]
> kern  :warn  : [   38.952034] Node 0 DMA free:2008kB min:280kB low:348kB high:416kB active_anon:1112kB inactive_anon:28kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15984kB managed:15900kB mlocked:0kB slab_reclaimable:12704kB slab_unreclaimable:48kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> kern  :warn  : [   38.984654] lowmem_reserve[]: 0 3430 3524 3524 3524
> kern  :warn  : [   38.990371] Node 0 DMA32 free:83292kB min:61984kB low:77480kB high:92976kB active_anon:2395900kB inactive_anon:454596kB active_file:0kB inactive_file:4kB unevictable:314016kB writepending:0kB present:3578492kB managed:3512924kB mlocked:92kB slab_reclaimable:218640kB slab_unreclaimable:6036kB kernel_stack:1744kB pagetables:14040kB bounce:0kB free_pcp:2160kB local_pcp:36kB free_cma:0kB
> kern  :warn  : [   39.027044] lowmem_reserve[]: 0 0 94 94 94
> kern  :warn  : [   39.031921] Node 0 Normal free:5448kB min:5316kB low:6644kB high:7972kB active_anon:61364kB inactive_anon:162752kB active_file:0kB inactive_file:0kB unevictable:62776kB writepending:0kB present:505856kB managed:420724kB mlocked:2124kB slab_reclaimable:17396kB slab_unreclaimable:19876kB kernel_stack:2992kB pagetables:1784kB bounce:0kB free_pcp:60kB local_pcp:0kB free_cma:4004kB
> kern  :warn  : [   39.067344] lowmem_reserve[]: 0 0 0 0 0
> kern  :warn  : [   39.072034] Node 0 DMA: 47*4kB (E) 9*8kB (E) 3*16kB (H) 1*32kB (H) 1*64kB (H) 1*128kB (H) 0*256kB 1*512kB (H) 1*1024kB (H) 0*2048kB 0*4096kB = 2068kB
> kern  :warn  : [   39.087289] Node 0 DMA32: 9514*4kB (UME) 3085*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 62736kB
> kern  :warn  : [   39.101342] Node 0 Normal: 203*4kB (UEC) 400*8kB (UEC) 107*16kB (HC) 5*32kB (C) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5884kB

OK, so your system is close to min watermarks and requesting order-2
page while those cannot be allocated because GFP_KERNEL (aka unmovable
allocation) cannot fall back to CMA reserved blocks. Do you see the same
when CMA is not involved?

Anyway, 4.8 had temporarily disable the compaction feedback for the oom
declaration and used watermark based estimation. 4.9 will have the
compaction feedback approach back along with many compaction
improvements so it is definitely worth retesting with linux-next or
4.9-rc1.

> kern  :info  : [   39.116367] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
> kern  :info  : [   39.126827] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> kern  :warn  : [   39.136481] 94403 total pagecache pages
> kern  :warn  : [   39.141514] 10 pages in swap cache
> kern  :warn  : [   39.145995] Swap cache stats: add 6689320, delete 6689310, find 6080/3054405
> kern  :warn  : [   39.154135] Free swap  = 1845896kB
> kern  :warn  : [   39.158638] Total swap = 4194300kB
> kern  :warn  : [   39.163152] 1025083 pages RAM
> kern  :warn  : [   39.167218] 0 pages HighMem/MovableOnly
> kern  :warn  : [   39.172167] 37696 pages reserved
> kern  :warn  : [   39.176504] 51200 pages cma reserved
> kern  :warn  : [   39.181223] 0 pages hwpoisoned
> 
> I wonder if this OOM could/should be avoided?

The system is highly fragmented and low on memory but there is a lot of
anonymous memory which we should at least try to compact into contiguous
blocks so I believe we should be able to cope with that much better.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
