Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A85DE6B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 15:54:11 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b8-v6so7881282oib.4
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 12:54:11 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o66-v6si16025oif.119.2018.07.19.12.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 12:54:10 -0700 (PDT)
Date: Thu, 19 Jul 2018 12:53:33 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 0/7] kmalloc-reclaimable caches
Message-ID: <20180719195332.GB26595@castle.DHCP.thefacebook.com>
References: <20180718133620.6205-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180718133620.6205-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>, Vijayanand Jitta <vjitta@codeaurora.org>

On Wed, Jul 18, 2018 at 03:36:13PM +0200, Vlastimil Babka wrote:
> v3 changes:
> - fix missing hunk in patch 5/7
> - more verbose cover letter and patch 6/7 commit log
> v2 changes:
> - shorten cache names to kmalloc-rcl-<SIZE>
> - last patch shortens <SIZE> for all kmalloc caches to e.g. "1k", "4M"
> - include dma caches to the 2D kmalloc_caches[] array to avoid a branch
> - vmstat counter nr_indirectly_reclaimable_bytes renamed to
>   nr_kernel_misc_reclaimable, doesn't include kmalloc-rcl-*
> - /proc/meminfo counter renamed to KReclaimable, includes kmalloc-rcl*
>   and nr_kernel_misc_reclaimable
> 
> Hi,
> 
> as discussed at LSF/MM [1] here's a patchset that introduces
> kmalloc-reclaimable caches (more details in the second patch) and uses them for
> SLAB freelists and dcache external names. The latter allows us to repurpose the
> NR_INDIRECTLY_RECLAIMABLE_BYTES counter later in the series.
> 
> With patch 4/7, dcache external names are allocated from kmalloc-rcl-*
> caches, eliminating the need for manual accounting. More importantly, it
> also ensures the reclaimable kmalloc allocations are grouped in pages
> separate from the regular kmalloc allocations. The need for proper
> accounting of dcache external names has shown it's easy for misbehaving
> process to allocate lots of them, causing premature OOMs. Without the
> added grouping, it's likely that a similar workload can interleave the
> dcache external names allocations with regular kmalloc allocations
> (note: I haven't searched myself for an example of such regular kmalloc
> allocation, but I would be very surprised if there wasn't some). A
> pathological case would be e.g. one 64byte regular allocations with 63
> external dcache names in a page (64x64=4096), which means the page is
> not freed even after reclaiming after all dcache names, and the process
> can thus "steal" the whole page with single 64byte allocation.
> 
> If there other kmalloc users similar to dcache external names become
> identified, they can also benefit from the new functionality simply by
> adding __GFP_RECLAIMABLE to the kmalloc calls.
> 
> Side benefits of the patchset (that could be also merged separately)
> include removed branch for detecting __GFP_DMA kmalloc(), and shortening
> kmalloc cache names in /proc/slabinfo output. The latter is potentially
> an ABI break in case there are tools parsing the names and expecting the
> values to be in bytes.
> 
> This is how /proc/slabinfo looks like after booting in virtme:
> 
> ...
> kmalloc-rcl-4M         0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
> ...
> kmalloc-rcl-96         7     32    128   32    1 : tunables  120   60    8 : slabdata      1      1      0
> kmalloc-rcl-64        25    128     64   64    1 : tunables  120   60    8 : slabdata      2      2      0
> kmalloc-rcl-32         0      0     32  124    1 : tunables  120   60    8 : slabdata      0      0      0
> kmalloc-4M             0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
> kmalloc-2M             0      0 2097152    1  512 : tunables    1    1    0 : slabdata      0      0      0
> kmalloc-1M             0      0 1048576    1  256 : tunables    1    1    0 : slabdata      0      0      0
> ...
> 
> /proc/vmstat with renamed nr_indirectly_reclaimable_bytes counter:
> 
> ...
> nr_slab_reclaimable 2817
> nr_slab_unreclaimable 1781
> ...
> nr_kernel_misc_reclaimable 0
> ...
> 
> /proc/meminfo with new KReclaimable counter:
> 
> ...
> Shmem:               564 kB
> KReclaimable:      11260 kB
> Slab:              18368 kB
> SReclaimable:      11260 kB
> SUnreclaim:         7108 kB
> KernelStack:        1248 kB
> ...
> 
> Thanks,
> Vlastimil

Hi, Vlastimil!

Overall the patchset looks solid to me.
Please, feel free to add
Acked-by: Roman Gushchin <guro@fb.com>

Two small nits:
1) The last patch is unrelated to the main idea,
and can potentially cause ABI breakage.
I'd separate it from the rest of the patchset.

2) It's actually re-opening the security issue for SLOB
users. Is the memory overhead really big enough to
justify that?

Thanks!
