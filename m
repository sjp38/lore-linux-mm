Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 744926B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 04:01:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 91so594535wrl.13
        for <linux-mm@kvack.org>; Wed, 31 May 2017 01:01:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v64si17562347wmd.14.2017.05.31.01.01.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 01:01:39 -0700 (PDT)
Date: Wed, 31 May 2017 09:01:36 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: consider memblock reservations for deferred memory
 initialization sizing
Message-ID: <20170531080136.mczjttyijz6drdjl@suse.de>
References: <20170531064227.5753-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170531064227.5753-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, May 31, 2017 at 08:42:27AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> We have seen an early OOM killer invocation on ppc64 systems with
> crashkernel=4096M
> 	kthreadd invoked oom-killer: gfp_mask=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=7, order=0, oom_score_adj=0
> 	kthreadd cpuset=/ mems_allowed=7
> 	CPU: 0 PID: 2 Comm: kthreadd Not tainted 4.4.68-1.gd7fe927-default #1
> 	Call Trace:
> 	[c0000000072fb7c0] [c00000000080830c] dump_stack+0xb0/0xf0 (unreliable)
> 	[c0000000072fb800] [c0000000008032d4] dump_header+0xb0/0x258
> 	[c0000000072fb8e0] [c00000000023dfc0] out_of_memory+0x5f0/0x640
> 	[c0000000072fb990] [c00000000024459c] __alloc_pages_nodemask+0xa8c/0xc80
> 	[c0000000072fbb10] [c0000000002b2504] kmem_getpages+0x84/0x1a0
> 	[c0000000072fbb50] [c0000000002b5174] fallback_alloc+0x2a4/0x320
> 	[c0000000072fbbc0] [c0000000002b4240] kmem_cache_alloc_node+0xc0/0x2e0
> 	[c0000000072fbc30] [c0000000000b9a80] copy_process.isra.25+0x260/0x1b30
> 	[c0000000072fbd10] [c0000000000bb514] _do_fork+0x94/0x470
> 	[c0000000072fbd80] [c0000000000bb978] kernel_thread+0x48/0x60
> 	[c0000000072fbda0] [c0000000000e9df4] kthreadd+0x264/0x330
> 	[c0000000072fbe30] [c000000000009538] ret_from_kernel_thread+0x5c/0xa4
> 	Mem-Info:
> 	active_anon:0 inactive_anon:0 isolated_anon:0
> 	 active_file:0 inactive_file:0 isolated_file:0
> 	 unevictable:0 dirty:0 writeback:0 unstable:0
> 	 slab_reclaimable:5 slab_unreclaimable:73
> 	 mapped:0 shmem:0 pagetables:0 bounce:0
> 	 free:0 free_pcp:0 free_cma:0
> 	Node 7 DMA free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:52428800kB managed:110016kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:320kB slab_unreclaimable:4672kB kernel_stack:1152kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> 	lowmem_reserve[]: 0 0 0 0
> 	Node 7 DMA: 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB = 0kB
> 	0 total pagecache pages
> 	0 pages in swap cache
> 	Swap cache stats: add 0, delete 0, find 0/0
> 	Free swap  = 0kB
> 	Total swap = 0kB
> 	819200 pages RAM
> 	0 pages HighMem/MovableOnly
> 	817481 pages reserved
> 	0 pages cma reserved
> 	0 pages hwpoisoned
> 
> the reason is that the managed memory is too low (only 110MB) while the
> rest of the the 50GB is still waiting for the deferred intialization to
> be done. update_defer_init estimates the initial memoty to initialize to
> 2GB at least but it doesn't consider any memory allocated in that range.
> In this particular case we've had
> 	Reserving 4096MB of memory at 128MB for crashkernel (System RAM: 51200MB)
> so the low 2GB is mostly depleted.
> 
> Fix this by considering memblock allocations in the initial static
> initialization estimation. Move the max_initialise to reset_deferred_meminit
> and implement a simple memblock_reserved_memory helper which iterates all
> reserved blocks and sums the size of all that start below the given address.
> The cumulative size is than added on top of the initial estimation. This
> is still not ideal because reset_deferred_meminit doesn't consider holes
> and so reservation might be above the initial estimation whihch we
> ignore but let's make the logic simpler until we really need to handle
> more complicated cases.
> 
> Fixes: 3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
> Cc: stable # 4.2+
> Tested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
