Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AEC46B0069
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 09:24:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b201so74898145wmb.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 06:24:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yz4si4489067wjc.87.2016.10.04.06.24.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Oct 2016 06:24:55 -0700 (PDT)
Subject: Re: [PATCH] oom: print nodemask in the oom report
References: <20160930214146.28600-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <65c637df-a9a3-777d-f6d3-322033980f86@suse.cz>
Date: Tue, 4 Oct 2016 15:24:53 +0200
MIME-Version: 1.0
In-Reply-To: <20160930214146.28600-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Sellami Abdelkader <abdelkader.sellami@sap.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/30/2016 11:41 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> We have received a hard to explain oom report from a customer. The oom
> triggered regardless there is a lot of free memory:
>
> PoolThread invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0, oom_score_adj=0
> PoolThread cpuset=/ mems_allowed=0-7
> Pid: 30055, comm: PoolThread Tainted: G           E X 3.0.101-80-default #1
> Call Trace:
>  [<ffffffff81004b95>] dump_trace+0x75/0x300
>  [<ffffffff81466ba3>] dump_stack+0x69/0x6f
>  [<ffffffff810fea8e>] dump_header+0x8e/0x110
>  [<ffffffff810fee36>] oom_kill_process+0xa6/0x350
>  [<ffffffff810ff397>] out_of_memory+0x2b7/0x310
>  [<ffffffff81104dfd>] __alloc_pages_slowpath+0x7dd/0x820
>  [<ffffffff81105029>] __alloc_pages_nodemask+0x1e9/0x200
>  [<ffffffff81141f21>] alloc_pages_vma+0xe1/0x290
>  [<ffffffff8112083e>] do_anonymous_page+0x13e/0x300
>  [<ffffffff8146d96d>] do_page_fault+0x1fd/0x4c0
>  [<ffffffff8146a445>] page_fault+0x25/0x30
>  [<00007f19a9e9194c>] 0x7f19a9e9194b
> [...]
> active_anon:1135959151 inactive_anon:1051962 isolated_anon:0
>  active_file:13093 inactive_file:222506 isolated_file:0
>  unevictable:262144 dirty:2 writeback:0 unstable:0
>  free:432672819 slab_reclaimable:7917 slab_unreclaimable:95308
>  mapped:261139 shmem:166297 pagetables:2228282 bounce:0
> [...]
> Node 0 DMA free:15896kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15672kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> lowmem_reserve[]: 0 2892 775542 775542
> Node 0 DMA32 free:2783784kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2961572kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> lowmem_reserve[]: 0 0 772650 772650
> Node 0 Normal free:8120kB min:8160kB low:10200kB high:12240kB active_anon:779334960kB inactive_anon:2198744kB active_file:0kB inactive_file:180kB unevictable:131072kB isolated(anon):0kB isolated(file):0kB present:791193600kB mlocked:131072kB dirty:0kB writeback:0kB mapped:372940kB shmem:361480kB slab_reclaimable:4536kB slab_unreclaimable:68472kB kernel_stack:10104kB pagetables:1414820kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2280 all_unreclaimable? yes
> lowmem_reserve[]: 0 0 0 0
> Node 1 Normal free:476718144kB min:8192kB low:10240kB high:12288kB active_anon:307623696kB inactive_anon:283620kB active_file:10392kB inactive_file:69908kB unevictable:131072kB isolated(anon):0kB isolated(file):0kB present:794296320kB mlocked:131072kB dirty:4kB writeback:0kB mapped:257208kB shmem:189896kB slab_reclaimable:3868kB slab_unreclaimable:44756kB kernel_stack:1848kB pagetables:1369432kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 2 Normal free:386002452kB min:8192kB low:10240kB high:12288kB active_anon:398563752kB inactive_anon:68184kB active_file:10292kB inactive_file:29936kB unevictable:131072kB isolated(anon):0kB isolated(file):0kB present:794296320kB mlocked:131072kB dirty:0kB writeback:0kB mapped:32084kB shmem:776kB slab_reclaimable:6888kB slab_unreclaimable:60056kB kernel_stack:8208kB pagetables:1282880kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 3 Normal free:196406760kB min:8192kB low:10240kB high:12288kB active_anon:587445640kB inactive_anon:164396kB active_file:5716kB inactive_file:709844kB unevictable:131072kB isolated(anon):0kB isolated(file):0kB present:794296320kB mlocked:131072kB dirty:0kB writeback:0kB mapped:291776kB shmem:111416kB slab_reclaimable:5152kB slab_unreclaimable:44516kB kernel_stack:2168kB pagetables:1455956kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 4 Normal free:425338880kB min:8192kB low:10240kB high:12288kB active_anon:359695204kB inactive_anon:43216kB active_file:5748kB inactive_file:14772kB unevictable:131072kB isolated(anon):0kB isolated(file):0kB present:794296320kB mlocked:131072kB dirty:0kB writeback:0kB mapped:24708kB shmem:1120kB slab_reclaimable:1884kB slab_unreclaimable:41060kB kernel_stack:1856kB pagetables:1100208kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 5 Normal free:11140kB min:8192kB low:10240kB high:12288kB active_anon:784240872kB inactive_anon:1217164kB active_file:28kB inactive_file:48kB unevictable:131072kB isolated(anon):0kB isolated(file):0kB present:794296320kB mlocked:131072kB dirty:0kB writeback:0kB mapped:11408kB shmem:0kB slab_reclaimable:2008kB slab_unreclaimable:49220kB kernel_stack:1360kB pagetables:531600kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1202 all_unreclaimable? yes
> lowmem_reserve[]: 0 0 0 0
> Node 6 Normal free:243395332kB min:8192kB low:10240kB high:12288kB active_anon:542015544kB inactive_anon:40208kB active_file:968kB inactive_file:8484kB unevictable:131072kB isolated(anon):0kB isolated(file):0kB present:794296320kB mlocked:131072kB dirty:0kB writeback:0kB mapped:19992kB shmem:496kB slab_reclaimable:1672kB slab_unreclaimable:37052kB kernel_stack:2088kB pagetables:750264kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 7 Normal free:10768kB min:8192kB low:10240kB high:12288kB active_anon:784916936kB inactive_anon:192316kB active_file:19228kB inactive_file:56852kB unevictable:131072kB isolated(anon):0kB isolated(file):0kB present:794296320kB mlocked:131072kB dirty:4kB writeback:0kB mapped:34440kB shmem:4kB slab_reclaimable:5660kB slab_unreclaimable:36100kB kernel_stack:1328kB pagetables:1007968kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
>
> So all nodes but Node 0 have a lot of free memory which should suggest
> that there is an available memory especially when mems_allowed=0-7. One
> could speculate that a massive process has managed to terminate and free
> up a lot of memory while racing with the above allocation request.
> Although this is highly unlikely it cannot be ruled out.
>
> A further debugging, however shown that the faulting process had
> mempolicy (not cpuset) to bind to Node 0. We cannot see that information
> from the report though. mems_allowed turned out to be more confusing
> than really helpful.
>
> Fix this by always priting the nodemask. It is either mempolicy mask
> (and non-null) or the one defined by the cpusets.

I wonder if it's helpful to print the cpuset one when that's printed 
separately, and seeing both pieces of information (nodemask and cpuset) 
unmodified might tell us more. Is it to make it easier to deal with NULL 
nodemask? Or to make sure the info gets through pr_warn() and not pr_info()?

> The new output for
> the above oom report would be
>
> PoolThread invoked oom-killer: gfp_mask=0x280da(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, order=0, oom_adj=0, oom_score_adj=0
>
> This patch doesn't touch show_mem and the node filtering based on the
> cpuset node mask because mempolicy is always a subset of cpusets and
> seeing the full cpuset oom context might be helpful for tunning more
> specific mempolicies inside cpusets (e.g. when they turn out to be too
> restrictive). To prevent from ugly ifdefs the mask is printed even
> for !NUMA configurations but this should be OK (a single node will be
> printed).
>
> Reported-by: Sellami Abdelkader <abdelkader.sellami@sap.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Other than that,

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
