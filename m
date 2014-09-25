Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9766B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 14:55:11 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id z107so7963868qgd.21
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 11:55:10 -0700 (PDT)
Received: from n23.mail01.mtsvc.net (mailout32.mail01.mtsvc.net. [216.70.64.70])
        by mx.google.com with ESMTPS id y32si3380626qgd.79.2014.09.25.11.55.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Sep 2014 11:55:10 -0700 (PDT)
Message-ID: <54246506.50401@hurleysoftware.com>
Date: Thu, 25 Sep 2014 14:55:02 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: page allocator bug in 3.16?
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Maarten Lankhorst <maarten.lankhorst@canonical.com>, Thomas Hellstrom <thellstrom@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickens <hughd@google.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

After several days uptime with a 3.16 kernel (generally running
Thunderbird, emacs, kernel builds, several Chrome tabs on multiple
desktop workspaces) I've been seeing some really extreme slowdowns.

Mostly the slowdowns are associated with gpu-related tasks, like
opening new emacs windows, switching workspaces, laughing at internet
gifs, etc. Because this x86_64 desktop is nouveau-based, I didn't pursue
it right away -- 3.15 is the first time suspend has worked reliably.

This week I started looking into what the slowdown was and discovered
it's happening during dma allocation through swiotlb (the cpus can do
intel iommu but I don't use it because it's not the default for most users).

I'm still working on a bisection but each step takes 8+ hours to
validate and even then I'm no longer sure I still have the 'bad'
commit in the bisection. [edit: yup, I started over]

I just discovered a smattering of these in my logs and only on 3.16-rc+ kernels:
Sep 25 07:57:59 thor kernel: [28786.001300] alloc_contig_range test_pages_isolated(2bf560, 2bf562) failed

This dual-Xeon box has 10GB and sysrq Show Memory isn't showing heavy
fragmentation [1].

Besides Mel's page allocator changes in 3.16, another suspect commit is:

commit b13b1d2d8692b437203de7a404c6b809d2cc4d99
Author: Shaohua Li <shli@kernel.org>
Date:   Tue Apr 8 15:58:09 2014 +0800

    x86/mm: In the PTE swapout page reclaim case clear the accessed bit instead of flushing the TLB

Specifically, this statement:

    It could cause incorrect page aging and the (mistaken) reclaim of
    hot pages, but the chance of that should be relatively low.

I'm wondering if this could cause worse-case behavior with TTM? I'm
testing a revert of this on mainline 3.16-final now, with no results yet.

Thoughts?

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
CPU    0: hi:  186, btch:  31 usd:  18
CPU    1: hi:  186, btch:  31 usd:  82
CPU    2: hi:  186, btch:  31 usd:  46
CPU    3: hi:  186, btch:  31 usd:  30
CPU    4: hi:  186, btch:  31 usd:  18
CPU    5: hi:  186, btch:  31 usd:  43
CPU    6: hi:  186, btch:  31 usd: 157
CPU    7: hi:  186, btch:  31 usd:  26
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  25
CPU    1: hi:  186, btch:  31 usd:  33
CPU    2: hi:  186, btch:  31 usd:  28
CPU    3: hi:  186, btch:  31 usd:  46
CPU    4: hi:  186, btch:  31 usd:  23
CPU    5: hi:  186, btch:  31 usd:   8
CPU    6: hi:  186, btch:  31 usd: 112
CPU    7: hi:  186, btch:  31 usd:  18
active_anon:382833 inactive_anon:12103 isolated_anon:0
 active_file:1156997 inactive_file:733988 isolated_file:0
 unevictable:15 dirty:35833 writeback:0 unstable:0
 free:129383 slab_reclaimable:95038 slab_unreclaimable:11095
 mapped:81924 shmem:12509 pagetables:9039 bounce:0
 free_cma:0
Node 0 DMA free:15860kB min:104kB low:128kB high:156kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15960kB managed:15876kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 2974 9980 9980
Node 0 DMA32 free:166712kB min:20108kB low:25132kB high:30160kB active_anon:475548kB inactive_anon:15204kB active_file:1368716kB inactive_file:865832kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3127336kB managed:3048188kB mlocked:0kB dirty:38228kB writeback:0kB mapped:94340kB shmem:15436kB slab_reclaimable:116424kB slab_unreclaimable:12756kB kernel_stack:2512kB pagetables:11532kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 7006 7006
Node 0 Normal free:334960kB min:47368kB low:59208kB high:71052kB active_anon:1055784kB inactive_anon:33208kB active_file:3259272kB inactive_file:2070120kB unevictable:60kB isolated(anon):0kB isolated(file):0kB present:7340032kB managed:7174484kB mlocked:60kB dirty:105104kB writeback:0kB mapped:233356kB shmem:34600kB slab_reclaimable:263728kB slab_unreclaimable:31608kB kernel_stack:7344kB pagetables:24624kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (U) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15860kB
Node 0 DMA32: 209*4kB (UEM) 394*8kB (UEM) 303*16kB (UEM) 60*32kB (UEM) 314*64kB (UEM) 117*128kB (UEM) 9*256kB (EM) 3*512kB (UEM) 2*1024kB (EM) 2*2048kB (UM) 27*4096kB (MR) = 166404kB
Node 0 Normal: 17*4kB (UE) 460*8kB (UEM) 747*16kB (UM) 130*32kB (UEM) 521*64kB (UM) 184*128kB (UEM) 70*256kB (UM) 22*512kB (UM) 11*1024kB (UM) 2*2048kB (EM) 52*4096kB (MR) = 334292kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
1903443 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 10996456kB
Total swap = 10996456kB
2620832 pages RAM
0 pages HighMem/MovableOnly
41387 pages reserved
0 pages hwpoisoned



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
