Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0461E6B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:27:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b140so9179158wme.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:27:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v63si3598544wma.38.2017.03.16.01.27.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 01:27:17 -0700 (PDT)
Date: Thu, 16 Mar 2017 09:27:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170316082714.GC30501@dhcp22.suse.cz>
References: <20161223025505.GA30876@bbox>
 <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
 <20170104091120.GD25453@dhcp22.suse.cz>
 <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
 <20170227090236.GA2789@bbox>
 <20170227094448.GF14029@dhcp22.suse.cz>
 <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz>
 <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu 16-03-17 07:38:08, Gerhard Wiesinger wrote:
[...]
> The following commit is included in that version:
> commit 710531320af876192d76b2c1f68190a1df941b02
> Author: Michal Hocko <mhocko@suse.com>
> Date:   Wed Feb 22 15:45:58 2017 -0800
> 
>     mm, vmscan: cleanup lru size claculations
> 
>     commit fd538803731e50367b7c59ce4ad3454426a3d671 upstream.

This patch shouldn't make any difference. It is a cleanup patch.
I guess you meant 71ab6cfe88dc ("mm, vmscan: consider eligible zones in
get_scan_count") but even that one shouldn't make any difference for 64b
systems.

> But still OOMs:
> [157048.030760] clamscan: page allocation stalls for 19405ms, order:0, mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)

This is not OOM it is an allocation stall. The allocation request cannot
simply make forward progress for more than 10s. This alone is bad but
considering this is GFP_HIGHUSER_MOVABLE which has the full reclaim
capabilities I would suspect your workload overcommits the available
memory too much. You only have ~380MB of RAM with ~160MB sitting in the
anonymous memory, almost nothing in the page cache so I am not wondering
that you see a constant swap activity. There seems to be only 40M in the
slab so we are still missing ~180MB which is neither on the LRU lists
nor allocated by slab. This means that some kernel subsystem allocates
from the page allocator directly.

That being said, I believe that what you are seeing is not a bug in the
MM subsystem but rather some susbsytem using more memory than it used to
before so your workload doesn't fit into the amount of memory you have
anymore.

[...]
> [157048.081827] Mem-Info:
> [157048.083005] active_anon:19902 inactive_anon:19920 isolated_anon:383
>                  active_file:816 inactive_file:529 isolated_file:0
>                  unevictable:0 dirty:0 writeback:19 unstable:0
>                  slab_reclaimable:4225 slab_unreclaimable:6483
>                  mapped:942 shmem:3 pagetables:3553 bounce:0
>                  free:944 free_pcp:87 free_cma:0
> [157048.089470] Node 0 active_anon:79552kB inactive_anon:79588kB
> active_file:3108kB inactive_file:2144kB unevictable:0kB
> isolated(anon):1624kB isolated(file):0kB mapped:3612kB dirty:0kB
> writeback:76kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 12kB
> writeback_tmp:0kB unstable:0kB pages_scanned:247 all_unreclaimable? no
> [157048.092318] Node 0 DMA free:1408kB min:104kB low:128kB high:152kB
> active_anon:664kB inactive_anon:3124kB active_file:48kB inactive_file:40kB
> unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB
> slab_reclaimable:564kB slab_unreclaimable:2148kB kernel_stack:92kB
> pagetables:1328kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [157048.096008] lowmem_reserve[]: 0 327 327 327 327
> [157048.097234] Node 0 DMA32 free:2576kB min:2264kB low:2828kB high:3392kB
> active_anon:78844kB inactive_anon:76612kB active_file:2840kB
> inactive_file:1896kB unevictable:0kB writepending:76kB present:376688kB
> managed:353792kB mlocked:0kB slab_reclaimable:16336kB
> slab_unreclaimable:23784kB kernel_stack:2388kB pagetables:12884kB bounce:0kB
> free_pcp:644kB local_pcp:312kB free_cma:0kB
> [157048.101118] lowmem_reserve[]: 0 0 0 0 0
> [157048.102190] Node 0 DMA: 37*4kB (UEH) 12*8kB (H) 13*16kB (H) 10*32kB (H)
> 4*64kB (H) 3*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1412kB
> [157048.104989] Node 0 DMA32: 79*4kB (UMEH) 199*8kB (UMEH) 18*16kB (UMH)
> 5*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
> 2484kB
> [157048.107789] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> [157048.107790] 2027 total pagecache pages
> [157048.109125] 710 pages in swap cache
> [157048.115088] Swap cache stats: add 36179491, delete 36179123, find
> 86964755/101977142
> [157048.116934] Free swap  = 808064kB
> [157048.118466] Total swap = 2064380kB
> [157048.122828] 98170 pages RAM
> [157048.124039] 0 pages HighMem/MovableOnly
> [157048.125051] 5745 pages reserved
> [157048.125997] 0 pages cma reserved
> [157048.127008] 0 pages hwpoisoned
> 
> 
> Thnx.
> 
> Ciao,
> Gerhard

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
