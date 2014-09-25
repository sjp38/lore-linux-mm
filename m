Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 445FA6B0039
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 16:36:38 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id x13so5825323qcv.36
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 13:36:38 -0700 (PDT)
Received: from n23.mail01.mtsvc.net (mailout32.mail01.mtsvc.net. [216.70.64.70])
        by mx.google.com with ESMTPS id k3si3656638qay.112.2014.09.25.13.36.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Sep 2014 13:36:37 -0700 (PDT)
Message-ID: <54247CCB.3060706@hurleysoftware.com>
Date: Thu, 25 Sep 2014 16:36:27 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: page allocator bug in 3.16?
References: <54246506.50401@hurleysoftware.com>
In-Reply-To: <54246506.50401@hurleysoftware.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Maarten Lankhorst <maarten.lankhorst@canonical.com>, Thomas Hellstrom <thellstrom@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickens <hughd@google.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

On 09/25/2014 02:55 PM, Peter Hurley wrote:
> After several days uptime with a 3.16 kernel (generally running
> Thunderbird, emacs, kernel builds, several Chrome tabs on multiple
> desktop workspaces) I've been seeing some really extreme slowdowns.
> 
> Mostly the slowdowns are associated with gpu-related tasks, like
> opening new emacs windows, switching workspaces, laughing at internet
> gifs, etc. Because this x86_64 desktop is nouveau-based, I didn't pursue
> it right away -- 3.15 is the first time suspend has worked reliably.
> 
> This week I started looking into what the slowdown was and discovered
> it's happening during dma allocation through swiotlb (the cpus can do
> intel iommu but I don't use it because it's not the default for most users).
> 
> I'm still working on a bisection but each step takes 8+ hours to
> validate and even then I'm no longer sure I still have the 'bad'
> commit in the bisection. [edit: yup, I started over]
> 
> I just discovered a smattering of these in my logs and only on 3.16-rc+ kernels:
> Sep 25 07:57:59 thor kernel: [28786.001300] alloc_contig_range test_pages_isolated(2bf560, 2bf562) failed
> 
> This dual-Xeon box has 10GB and sysrq Show Memory isn't showing heavy
> fragmentation [1].

It's swapping, which is crazy because there's 7+GB of file cache [1] which
should be dropped before swapping.

The alloc_contig_range() failure precedes the swapping but not immediately
(44 mins. earlier).

How I reproduce this is to simply do a full distro kernel build.
Skipping the TLB flush is not the problem; the results below are from
3.16-final with that commit reverted.

The slowdown is really obvious because workspace switching redraw takes
multiple seconds to complete (all-cpu perf record of that below [2])

Regards,
Peter Hurley

[1]
SysRq : Show Memory
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
CPU    4: hi:    0, btch:   1 usd:   0
CPU    5: hi:    0, btch:   1 usd:   0
CPU    6: hi:    0, btch:   1 usd:   0
CPU    7: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  71
CPU    1: hi:  186, btch:  31 usd: 166
CPU    2: hi:  186, btch:  31 usd: 183
CPU    3: hi:  186, btch:  31 usd: 109
CPU    4: hi:  186, btch:  31 usd: 106
CPU    5: hi:  186, btch:  31 usd: 161
CPU    6: hi:  186, btch:  31 usd: 120
CPU    7: hi:  186, btch:  31 usd:  54
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 159
CPU    1: hi:  186, btch:  31 usd:  66
CPU    2: hi:  186, btch:  31 usd: 178
CPU    3: hi:  186, btch:  31 usd: 173
CPU    4: hi:  186, btch:  31 usd:  91
CPU    5: hi:  186, btch:  31 usd:  57
CPU    6: hi:  186, btch:  31 usd:  58
CPU    7: hi:  186, btch:  31 usd: 158
active_anon:170368 inactive_anon:173964 isolated_anon:0
 active_file:982209 inactive_file:973911 isolated_file:0
 unevictable:15 dirty:15 writeback:1 unstable:0
 free:96067 slab_reclaimable:107401 slab_unreclaimable:12572
 mapped:58271 shmem:10857 pagetables:9898 bounce:0
 free_cma:18
Node 0 DMA free:15860kB min:104kB low:128kB high:156kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15960kB managed:15876kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 2974 9980 9980
Node 0 DMA32 free:117740kB min:20108kB low:25132kB high:30160kB active_anon:205232kB inactive_anon:196308kB active_file:1186764kB inactive_file:1173760kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3127336kB managed:3048212kB mlocked:0kB dirty:24kB writeback:4kB mapped:71600kB shmem:8776kB slab_reclaimable:129132kB slab_unreclaimable:13468kB kernel_stack:2864kB pagetables:11536kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 7006 7006
Node 0 Normal free:250668kB min:47368kB low:59208kB high:71052kB active_anon:476240kB inactive_anon:499548kB active_file:2742072kB inactive_file:2721884kB unevictable:60kB isolated(anon):0kB isolated(file):0kB present:7340032kB managed:7174484kB mlocked:60kB dirty:36kB writeback:0kB mapped:161484kB shmem:34652kB slab_reclaimable:300472kB slab_unreclaimable:36804kB kernel_stack:7232kB pagetables:28056kB unstable:0kB bounce:0kB free_cma:72kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (U) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15860kB
Node 0 DMA32: 4099*4kB (UEM) 4372*8kB (UEM) 668*16kB (UEM) 294*32kB (UEM) 47*64kB (UEM) 24*128kB (UEM) 19*256kB (UM) 5*512kB (UM) 0*1024kB 6*2048kB (M) 5*4096kB (M) = 117740kB
Node 0 Normal: 22224*4kB (UEMC) 8120*8kB (UEMC) 1594*16kB (UEMC) 301*32kB (UEMC) 154*64kB (UMC) 106*128kB (UEMC) 86*256kB (UMC) 13*512kB (UEMC) 3*1024kB (M) 3*2048kB (M) 1*4096kB (R) = 254400kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
1967616 total pagecache pages
637 pages in swap cache
Swap cache stats: add 9593, delete 8956, find 2162/2929
Free swap  = 10966116kB
Total swap = 10996456kB
2620832 pages RAM
0 pages HighMem/MovableOnly
41387 pages reserved
0 pages hwpoisoned



[2] 'perf record -a -g' while workspace switching

Samples: 27K of event 'cycles', Event count (approx.): 15793770075
+   87.11%     0.00%             Xorg  [kernel.kallsyms]                   [k] tracesys
+   86.81%     0.00%             Xorg  [unknown]                           [k] 0x00007fca2df34e77
+   86.77%     0.00%             Xorg  [kernel.kallsyms]                   [k] sys_ioctl
+   86.77%     0.00%             Xorg  [kernel.kallsyms]                   [k] do_vfs_ioctl
+   86.77%     0.00%             Xorg  [nouveau]                           [k] nouveau_drm_ioctl
+   86.77%     0.00%             Xorg  [drm]                               [k] drm_ioctl
+   86.66%     0.00%             Xorg  [nouveau]                           [k] nouveau_gem_ioctl_new
+   86.50%     0.00%             Xorg  [nouveau]                           [k] nouveau_gem_new
+   86.49%     0.00%             Xorg  [nouveau]                           [k] nouveau_bo_new
+   86.48%     0.00%             Xorg  [ttm]                               [k] ttm_bo_init
+   86.47%     0.00%             Xorg  [ttm]                               [k] ttm_bo_validate
+   86.46%     0.00%             Xorg  [ttm]                               [k] ttm_bo_handle_move_mem
+   86.45%     0.00%             Xorg  [ttm]                               [k] ttm_tt_bind
+   86.45%     0.00%             Xorg  [nouveau]                           [k] nouveau_ttm_tt_populate
+   86.45%     0.00%             Xorg  [ttm]                               [k] ttm_dma_populate
+   86.43%     0.01%             Xorg  [ttm]                               [k] ttm_dma_pool_alloc_new_pages
+   86.42%     0.00%             Xorg  [kernel.kallsyms]                   [k] x86_swiotlb_alloc_coherent
+   86.37%     0.00%             Xorg  [kernel.kallsyms]                   [k] dma_generic_alloc_coherent
+   86.19%     0.00%             Xorg  [unknown]                           [k] 0x0000000000c00000
+   85.82%     0.31%             Xorg  [kernel.kallsyms]                   [k] dma_alloc_from_contiguous
+   84.21%     1.05%             Xorg  [kernel.kallsyms]                   [k] alloc_contig_range
+   46.56%    46.56%             Xorg  [kernel.kallsyms]                   [k] move_freepages
+   46.53%     0.29%             Xorg  [kernel.kallsyms]                   [k] move_freepages_block
+   39.78%     0.13%             Xorg  [kernel.kallsyms]                   [k] start_isolate_page_range
+   39.22%     0.40%             Xorg  [kernel.kallsyms]                   [k] set_migratetype_isolate
+   27.26%     0.17%             Xorg  [kernel.kallsyms]                   [k] undo_isolate_page_range
+   26.62%     0.33%             Xorg  [kernel.kallsyms]                   [k] unset_migratetype_isolate
+   15.54%     7.93%             Xorg  [kernel.kallsyms]                   [k] drain_all_pages


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
