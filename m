Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id A66CF6B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 14:19:11 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id u140so14667394ywf.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:19:11 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id w7si1253561ywg.196.2017.04.27.11.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 11:19:09 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id u75so5863587qka.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:19:09 -0700 (PDT)
From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 0/3 v3] ARM/ARM64: silence large module first time allocation
Date: Thu, 27 Apr 2017 11:18:59 -0700
Message-Id: <20170427181902.28829-1-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Florian Fainelli <f.fainelli@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

With kernels built with CONFIG_ARM{,64}_MODULES_PLTS=y, the first allocation
done from module space will fail, produce a general OOM allocation and also a
vmap warning. The second allocation from vmalloc space may or may not be
successful, but is actually the one we are interested about in these cases.

This patch series passed __GFP_NOWARN to silence such allocations from the
ARM/ARM64 module loader's first time allocation when the MODULES_PLT option is
enabled, and also makes alloc_vmap_area() react to the caller setting
__GFP_NOWARN to silence "vmap allocation for size..." messages.


Changes in v3:
- check for __GFP_NOWARN not set where the check for printk_ratelimited()
  is done, add Michal's Acked-by

- use C conditionals and not CPP conditionals for IS_ENABLED(), add Ard's
  Reviewed-by tag

Changes in v2:

- check __GFP_NOWARN out of the printk_ratelimited() check (Michal)

Here is an example of what we would get without these two patches, pretty
scary huh?

# insmod /mnt/nfs/huge.ko 
[   22.114143] random: nonblocking pool is initialized
[   22.183575] vmap allocation for size 15736832 failed: use vmalloc=<size> to increase size.
[   22.191873] vmalloc: allocation failure: 15729534 bytes
[   22.197112] insmod: page allocation failure: order:0, mode:0xd0
[   22.203048] CPU: 2 PID: 1506 Comm: insmod Tainted: G           O    4.1.20-1.9pre-01082-gbbbff07bc3ce #9
[   22.212536] Hardware name: Broadcom STB (Flattened Device Tree)
[   22.218480] [<c0017eec>] (unwind_backtrace) from [<c00135c8>] (show_stack+0x10/0x14)
[   22.226238] [<c00135c8>] (show_stack) from [<c0638684>] (dump_stack+0x90/0xa4)
[   22.233473] [<c0638684>] (dump_stack) from [<c00aae1c>] (warn_alloc_failed+0x104/0x144)
[   22.241490] [<c00aae1c>] (warn_alloc_failed) from [<c00d72e0>] (__vmalloc_node_range+0x170/0x218)
[   22.250375] [<c00d72e0>] (__vmalloc_node_range) from [<c00147d0>] (module_alloc+0x50/0xac)
[   22.258651] [<c00147d0>] (module_alloc) from [<c008ae2c>] (module_alloc_update_bounds+0xc/0x6c)
[   22.267360] [<c008ae2c>] (module_alloc_update_bounds) from [<c008b778>] (load_module+0x8ec/0x2058)
[   22.276329] [<c008b778>] (load_module) from [<c008cfd4>] (SyS_init_module+0xf0/0x174)
[   22.284170] [<c008cfd4>] (SyS_init_module) from [<c0010140>] (ret_fast_syscall+0x0/0x3c)
[   22.292277] Mem-Info:
[   22.294567] active_anon:5236 inactive_anon:1773 isolated_anon:0
[   22.294567]  active_file:1 inactive_file:3822 isolated_file:0
[   22.294567]  unevictable:0 dirty:0 writeback:0 unstable:0
[   22.294567]  slab_reclaimable:238 slab_unreclaimable:1594
[   22.294567]  mapped:855 shmem:2950 pagetables:36 bounce:0
[   22.294567]  free:39031 free_pcp:198 free_cma:3928
[   22.327196] DMA free:156124kB min:1880kB low:2348kB high:2820kB active_anon:20944kB inactive_anon:7092kB active_file:4kB inactive_file:15288kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:262144kB managed:227676kB mlocked:0kB dirty:0kB writeback:0kB mapped:3420kB shmem:11800kB slab_reclaimable:952kB slab_unreclaimable:6376kB kernel_stack:560kB pagetables:144kB unstable:0kB bounce:0kB free_pcp:792kB local_pcp:68kB free_cma:15712kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[   22.371631] lowmem_reserve[]: 0 0 0 0
[   22.375372] HighMem free:0kB min:128kB low:128kB high:128kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2883584kB managed:0kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[   22.416249] lowmem_reserve[]: 0 0 0 0
[   22.419986] DMA: 3*4kB (UEM) 4*8kB (UE) 1*16kB (M) 4*32kB (UEMC) 3*64kB (EMC) 1*128kB (E) 4*256kB (UEMC) 2*512kB (UE) 2*1024kB (MC) 4*2048kB (UEMC) 35*4096kB (MRC) = 156156kB
[   22.435922] HighMem: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   22.446130] 6789 total pagecache pages
[   22.449889] 0 pages in swap cache
[   22.453212] Swap cache stats: add 0, delete 0, find 0/0
[   22.458447] Free swap  = 0kB
[   22.461334] Total swap = 0kB
[   22.464222] 786432 pages RAM
[   22.467110] 720896 pages HighMem/MovableOnly
[   22.471388] 725417 pages reserved
[   22.474711] 4096 pages cma reserved
[   22.511310] big_init: I am a big module using 3932160 bytes of data!

Florian Fainelli (3):
  mm: Silence vmap() allocation failures based on caller gfp_flags
  ARM: Silence first allocation with CONFIG_ARM_MODULE_PLTS=y
  arm64: Silence first allocation with CONFIG_ARM64_MODULE_PLTS=y

 arch/arm/kernel/module.c   | 11 +++++++++--
 arch/arm64/kernel/module.c |  7 ++++++-
 mm/vmalloc.c               |  2 +-
 3 files changed, 16 insertions(+), 4 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
