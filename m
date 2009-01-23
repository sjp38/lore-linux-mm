Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 945B36B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 22:57:07 -0500 (EST)
Date: Fri, 23 Jan 2009 04:57:03 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090123035703.GE20098@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de> <1232613933.11429.127.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1232613933.11429.127.camel@ymzhang>
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 22, 2009 at 04:45:33PM +0800, Zhang, Yanmin wrote:
> On Wed, 2009-01-21 at 15:30 +0100, Nick Piggin wrote:
> > Hi,
> > 
> > Since last posted, I've cleaned up a few bits and pieces, (hopefully)
> > fixed a known bug where it wouldn't boot on memoryless nodes (I don't
> > have a system to test with), 
> Panic again on my Montvale Itanium NUMA machine if I start kernel with parameter
> mem=2G.
> 
> The call chain is mnt_init => sysfs_init. ???kmem_cache_create fails, so later on
> when ???mnt_init uses kmem_cache sysfs_dir_cache, kernel panic
> at __slab_alloc => get_cpu_slab because parameter s is equal to NULL.
> 
> Function __remote_slab_alloc return NULL when s->node[node]==NULL. That causes
> ???sysfs_init => kmem_cache_create fails.

Hmm, I'll probably have to add a bit more fallback logic. I'll have to
work out what semantics the callers require here. Thanks for the report.

> 
> 
> ------------------log----------------
> 
> Dentry cache hash table entries: 262144 (order: 7, 2097152 bytes)
> Inode-cache hash table entries: 131072 (order: 6, 1048576 bytes)
> Mount-cache hash table entries: 1024
> mnt_init: sysfs_init error: -12
> Unable to handle kernel NULL pointer dereference (address 0000000000002058)
> swapper[0]: Oops 8813272891392 [1]
> Modules linked in:
> 
> Pid: 0, CPU 0, comm:              swapper
> psr : 00001010084a2018 ifs : 8000000000000690 ip  : [<a000000100180350>]    Not tainted (2.6.29-rc2slqb0121)
> ip is at kmem_cache_alloc+0x150/0x4e0
> unat: 0000000000000000 pfs : 0000000000000690 rsc : 0000000000000003
> rnat: 0009804c8a70433f bsps: a000000100f484b0 pr  : 656960155aa65959
> ldrs: 0000000000000000 ccv : 000000000000001a fpsr: 0009804c8a70433f
> csd : 893fffff000f0000 ssd : 893fffff00090000
> b0  : a000000100180270 b6  : a000000100507360 b7  : a000000100507360
> f6  : 000000000000000000000 f7  : 1003e0000000000000800
> f8  : 1003e0000000000000008 f9  : 1003e0000000000000001
> f10 : 1003e0000000000000031 f11 : 1003e7d6343eb1a1f58d1
> r1  : a0000001011bc810 r2  : 0000000000000008 r3  : ffffffffffffffff
> r8  : 0000000000000000 r9  : a000000100ded800 r10 : 0000000000000000
> r11 : a000000100ded800 r12 : a000000100db3d80 r13 : a000000100dac000
> r14 : 0000000000000000 r15 : fffffffffffffffe r16 : a000000100fbcd30
> r17 : a000000100dacc44 r18 : 0000000000002058 r19 : 0000000000000000
> r20 : 0000000000000000 r21 : a000000100dacc44 r22 : 0000000000000002
> r23 : 0000000000000066 r24 : 0000000000000073 r25 : 0000000000000000
> r26 : e000000102014030 r27 : a0007fffffc9f120 r28 : 0000000000000000
> r29 : 0000000000000000 r30 : 0000000000000008 r31 : 0000000000000001
> 
> Call Trace:
>  [<a000000100016240>] show_stack+0x40/0xa0
>                                 sp=a000000100db3950 bsp=a000000100dad140
>  [<a000000100016b50>] show_regs+0x850/0x8a0
>                                 sp=a000000100db3b20 bsp=a000000100dad0e8
>  [<a00000010003a5f0>] die+0x230/0x360
>                                 sp=a000000100db3b20 bsp=a000000100dad0a0
>  [<a00000010005e0e0>] ia64_do_page_fault+0x8e0/0xa40
>                                 sp=a000000100db3b20 bsp=a000000100dad050
>  [<a00000010000c700>] ia64_native_leave_kernel+0x0/0x280
>                                 sp=a000000100db3bb0 bsp=a000000100dad050
>  [<a000000100180350>] kmem_cache_alloc+0x150/0x4e0
>                                 sp=a000000100db3d80 bsp=a000000100dacfc8
>  [<a000000100238610>] sysfs_new_dirent+0x90/0x240
>                                 sp=a000000100db3d80 bsp=a000000100dacf80
>  [<a000000100239140>] create_dir+0x40/0x100
>                                 sp=a000000100db3d90 bsp=a000000100dacf48
>  [<a0000001002392b0>] sysfs_create_dir+0xb0/0x100
>                                 sp=a000000100db3db0 bsp=a000000100dacf28
>  [<a0000001004eca60>] kobject_add_internal+0x1e0/0x420
>                                 sp=a000000100db3dc0 bsp=a000000100dacee8
>  [<a0000001004eceb0>] kobject_add_varg+0x90/0xc0
>                                 sp=a000000100db3dc0 bsp=a000000100daceb0
>  [<a0000001004ed620>] kobject_add+0x100/0x140
>                                 sp=a000000100db3dc0 bsp=a000000100dace50
>  [<a0000001004ed6b0>] kobject_create_and_add+0x50/0xc0
>                                 sp=a000000100db3e00 bsp=a000000100dace20
>  [<a000000100c28ff0>] mnt_init+0x1b0/0x480
>                                 sp=a000000100db3e00 bsp=a000000100dacde0
>  [<a000000100c28610>] vfs_caches_init+0x230/0x280
>                                 sp=a000000100db3e20 bsp=a000000100dacdb8
>  [<a000000100c01410>] start_kernel+0x830/0x8c0
>                                 sp=a000000100db3e20 bsp=a000000100dacd40
>  [<a0000001009d7b60>] __kprobes_text_end+0x760/0x780
>                                 sp=a000000100db3e30 bsp=a000000100dacca0
> Kernel panic - not syncing: Attempted to kill the idle task!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
