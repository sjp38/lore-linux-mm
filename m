Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 188B16B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:54:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so12623086pfx.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:54:28 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id qp6si3733093pab.258.2016.08.11.08.54.27
        for <linux-mm@kvack.org>;
        Thu, 11 Aug 2016 08:54:27 -0700 (PDT)
Date: Thu, 11 Aug 2016 16:54:23 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: kmemleak: Cannot insert 0xff7f1000 into the object search tree
 (overlaps existing)
Message-ID: <20160811155423.GC18366@e104818-lin.cambridge.arm.com>
References: <7f50c137-5c6a-0882-3704-ae9bb7552c30@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f50c137-5c6a-0882-3704-ae9bb7552c30@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vignesh R <vigneshr@ti.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>

On Thu, Aug 11, 2016 at 05:20:51PM +0530, Vignesh R wrote:
> I see the below message from kmemleak when booting linux-next on AM335x
> GP EVM and DRA7 EVM

Can you also reproduce it with 4.8-rc1?

> [    0.803934] kmemleak: Cannot insert 0xff7f1000 into the object search tree (overlaps existing)
> [    0.803950] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.8.0-rc1-next-20160809 #497
> [    0.803958] Hardware name: Generic DRA72X (Flattened Device Tree)
> [    0.803979] [<c0110104>] (unwind_backtrace) from [<c010c24c>] (show_stack+0x10/0x14)
> [    0.803994] [<c010c24c>] (show_stack) from [<c0490df0>] (dump_stack+0xac/0xe0)
> [    0.804010] [<c0490df0>] (dump_stack) from [<c0296f88>] (create_object+0x214/0x278)
> [    0.804025] [<c0296f88>] (create_object) from [<c07c770c>] (kmemleak_alloc_percpu+0x54/0xc0)
> [    0.804038] [<c07c770c>] (kmemleak_alloc_percpu) from [<c025fb08>] (pcpu_alloc+0x368/0x5fc)
> [    0.804052] [<c025fb08>] (pcpu_alloc) from [<c0b1bfbc>] (crash_notes_memory_init+0x10/0x40)
> [    0.804064] [<c0b1bfbc>] (crash_notes_memory_init) from [<c010188c>] (do_one_initcall+0x3c/0x178)
> [    0.804075] [<c010188c>] (do_one_initcall) from [<c0b00e98>] (kernel_init_freeable+0x1fc/0x2c8)
> [    0.804086] [<c0b00e98>] (kernel_init_freeable) from [<c07c66b0>] (kernel_init+0x8/0x114)
> [    0.804098] [<c07c66b0>] (kernel_init) from [<c0107910>] (ret_from_fork+0x14/0x24)

This is the allocation stack trace, going via pcpu_alloc().

> [    0.804106] kmemleak: Kernel memory leak detector disabled
> [    0.804113] kmemleak: Object 0xfe800000 (size 16777216):
> [    0.804121] kmemleak:   comm "swapper/0", pid 0, jiffies 4294937296
> [    0.804127] kmemleak:   min_count = -1
> [    0.804132] kmemleak:   count = 0
> [    0.804138] kmemleak:   flags = 0x5
> [    0.804143] kmemleak:   checksum = 0
> [    0.804149] kmemleak:   backtrace:
> [    0.804155]      [<c0b26a90>] cma_declare_contiguous+0x16c/0x214
> [    0.804170]      [<c0b3c9c0>] dma_contiguous_reserve_area+0x30/0x64
> [    0.804183]      [<c0b3ca74>] dma_contiguous_reserve+0x80/0x94
> [    0.804195]      [<c0b06810>] arm_memblock_init+0x130/0x184
> [    0.804207]      [<c0b04214>] setup_arch+0x590/0xc08
> [    0.804217]      [<c0b00940>] start_kernel+0x58/0x3b4
> [    0.804227]      [<8000807c>] 0x8000807c
> [    0.804237]      [<ffffffff>] 0xffffffff

This seems to be the original object that was allocated via
cma_declare_contiguous(): 16MB range from 0xfe800000 to 0xff800000.
Since the pointer returned by pcpu_alloc is 0xff7f1000 falls in the 16MB
CMA range, kmemleak gets confused (it doesn't allow overlapping
objects).

So what I think goes wrong is that the kmemleak_alloc(__va(found)) call
in memblock_alloc_range_nid() doesn't get the right value for the VA of
the CMA block. The memblock_alloc_range() call in
cma_declare_contiguous() asks for memory above high_memory, hence on a
32-bit architecture with highmem enabled, __va() use is not really
valid, returning the wrong address. The existing kmemleak object is
bogus, it shouldn't have been created in the first place.

Now I'm trying to figure out how to differentiate between lowmem
memblocks and highmem ones. Ignoring the kmemleak_alloc() calls
altogether in mm/memblock.c is probably not an option as it would lead
to lots of false positives.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
