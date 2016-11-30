Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2686B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:25:05 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so52957427wms.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:25:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i17si8846591wmd.150.2016.11.30.13.25.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 13:25:03 -0800 (PST)
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz> <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9d6e922b-d853-f24d-353c-25fbac38115b@suse.cz>
Date: Wed, 30 Nov 2016 22:24:59 +0100
MIME-Version: 1.0
In-Reply-To: <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Robin H. Johnson" <robbat2@gentoo.org>, Michal Hocko <mhocko@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>

[add more CC's]

On 11/30/2016 09:19 PM, Robin H. Johnson wrote:
> Somewhere in the Radeon/DRM codebase, CMA page allocation has either
> regressed in the timeline of 4.5->4.9, and/or the drm/radeon code is
> doing something different with pages.

Could be that it didn't use dma_generic_alloc_coherent() before, or you didn't 
have the generic CMA pool configured. What's the output of "grep CMA" on your 
.config? Or any kernel boot options with cma in name? By default config this 
should not be used on x86.

> Given that I haven't seen ANY other reports of this, I'm inclined to
> believe the problem is drm/radeon specific (if I don't start X, I can't
> reproduce the problem).

It's rather CMA specific, the allocation attemps just can't be 100% reliable due 
to how CMA works. The question is if it should be spewing in the log in the 
context of dma-cma, which has a fallback allocation option. It even uses 
__GFP_NOWARN, perhaps the CMA path should respect that?

> The rate of the problem starts slow, and also is relatively low on an idle
> system (my screens blank at night, no xscreensaver running), but it still ramps
> up over time (to the point of generating 2.5GB/hour of "(timestamp)
> alloc_contig_range: [83e4d9, 83e4da) PFNs busy"), with various addresses (~100
> unique ranges for a day).
>
> My X workload is ~50 chrome tabs and ~20 terminals (over 3x 24" monitors w/ 9
> virtual desktops per monitor).

So IIUC, except the messages, everything actually works fine?

> I added a stack trace & rate limit to alloc_contig_range's PFNs busy message
> (patch in previous email on LKML/-MM lists); and they point to radeon.
>
> alloc_contig_range: [83f2a3, 83f2a4) PFNs busy
> CPU: 3 PID: 8518 Comm: X Not tainted 4.9.0-rc7-00024-g6ad4037e18ec #27
> Hardware name: System manufacturer System Product Name/P8Z68 DELUXE, BIOS 0501 05/09/2011
>  ffffad50c3d7f730 ffffffffb236c873 000000000083f2a3 000000000083f2a4
>  ffffad50c3d7f810 ffffffffb2183b38 ffff999dff4d8040 0000000020fca8c0
>  000000000083f400 000000000083f000 000000000083f2a3 0000000000000004
> Call Trace:
>  [<ffffffffb236c873>] dump_stack+0x85/0xc2
>  [<ffffffffb2183b38>] alloc_contig_range+0x368/0x370
>  [<ffffffffb2202d37>] cma_alloc+0x127/0x2e0
>  [<ffffffffb24c4b28>] dma_alloc_from_contiguous+0x38/0x40
>  [<ffffffffb2020b01>] dma_generic_alloc_coherent+0x91/0x1d0
>  [<ffffffffb2049b75>] x86_swiotlb_alloc_coherent+0x25/0x50
>  [<ffffffffc0ef17da>] ttm_dma_populate+0x48a/0x9a0 [ttm]
>  [<ffffffffb21df8d6>] ? __kmalloc+0x1b6/0x250
>  [<ffffffffc0f2a3ea>] radeon_ttm_tt_populate+0x22a/0x2d0 [radeon]
>  [<ffffffffc0ee80f7>] ? ttm_dma_tt_init+0x67/0xc0 [ttm]
>  [<ffffffffc0ee7cc7>] ttm_tt_bind+0x37/0x70 [ttm]
>  [<ffffffffc0ee9e58>] ttm_bo_handle_move_mem+0x528/0x5a0 [ttm]
>  [<ffffffffb219464a>] ? shmem_alloc_inode+0x1a/0x30
>  [<ffffffffc0eead24>] ttm_bo_validate+0x114/0x130 [ttm]
>  [<ffffffffb269346e>] ? _raw_write_unlock+0xe/0x10
>  [<ffffffffc0eeb05d>] ttm_bo_init+0x31d/0x3f0 [ttm]
>  [<ffffffffc0f2b7ab>] radeon_bo_create+0x19b/0x260 [radeon]
>  [<ffffffffc0f2b2e0>] ? radeon_update_memory_usage.isra.0+0x50/0x50 [radeon]
>  [<ffffffffc0f3e29d>] radeon_gem_object_create+0xad/0x180 [radeon]
>  [<ffffffffc0f3e6ff>] radeon_gem_create_ioctl+0x5f/0xf0 [radeon]
>  [<ffffffffc0e3a9eb>] drm_ioctl+0x21b/0x4d0 [drm]
>  [<ffffffffc0f3e6a0>] ? radeon_gem_pwrite_ioctl+0x30/0x30 [radeon]
>  [<ffffffffc0f0d04c>] radeon_drm_ioctl+0x4c/0x80 [radeon]
>  [<ffffffffb221bae2>] do_vfs_ioctl+0x92/0x5c0
>  [<ffffffffb221c089>] SyS_ioctl+0x79/0x90
>  [<ffffffffb2002bf3>] do_syscall_64+0x73/0x190
>  [<ffffffffb26936c8>] entry_SYSCALL64_slow_path+0x25/0x25
>
> The Radeon card in my case is a VisionTek HD 7750 Eyefinity 6, which is
> reported as:
>
> 01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Cape Verde PRO [Radeon HD 7750/8740 / R7 250E] (prog-if 00 [VGA controller])
> 	Subsystem: VISIONTEK Cape Verde PRO [Radeon HD 7750/8740 / R7 250E]
> 	Flags: bus master, fast devsel, latency 0, IRQ 58
> 	Memory at c0000000 (64-bit, prefetchable) [size=256M]
> 	Memory at fbe00000 (64-bit, non-prefetchable) [size=256K]
> 	I/O ports at e000 [size=256]
> 	Expansion ROM at 000c0000 [disabled] [size=128K]
> 	Capabilities: [48] Vendor Specific Information: Len=08 <?>
> 	Capabilities: [50] Power Management version 3
> 	Capabilities: [58] Express Legacy Endpoint, MSI 00
> 	Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> 	Capabilities: [100] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> 	Capabilities: [150] Advanced Error Reporting
> 	Kernel driver in use: radeon
> 	Kernel modules: radeon, amdgpu
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
