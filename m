Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7E56B000D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 18:29:46 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 94-v6so10717361pla.5
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 15:29:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t9si8444038plz.427.2018.11.13.15.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 15:29:45 -0800 (PST)
Date: Tue, 13 Nov 2018 15:29:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-Id: <20181113152941.cc328e48d5c0c2f366f5db83@linux-foundation.org>
In-Reply-To: <20181113094305.GM15120@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
	<20181109084353.GA5321@dhcp22.suse.cz>
	<20181113094305.GM15120@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kyungtae Kim <kt0755@gmail.com>, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Tue, 13 Nov 2018 10:43:05 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 9 Nov 2018 09:35:29 +0100
> Subject: [PATCH] mm, page_alloc: check for max order in hot path
> 
> Konstantin has noticed that kvmalloc might trigger the following warning
> [Thu Nov  1 08:43:56 2018] WARNING: CPU: 0 PID: 6676 at mm/vmstat.c:986 __fragmentation_index+0x54/0x60

um, wait...

> [...]
> [Thu Nov  1 08:43:56 2018] Call Trace:
> [Thu Nov  1 08:43:56 2018]  fragmentation_index+0x76/0x90
> [Thu Nov  1 08:43:56 2018]  compaction_suitable+0x4f/0xf0
> [Thu Nov  1 08:43:56 2018]  shrink_node+0x295/0x310
> [Thu Nov  1 08:43:56 2018]  node_reclaim+0x205/0x250
> [Thu Nov  1 08:43:56 2018]  get_page_from_freelist+0x649/0xad0
> [Thu Nov  1 08:43:56 2018]  ? get_page_from_freelist+0x2d4/0xad0
> [Thu Nov  1 08:43:56 2018]  ? release_sock+0x19/0x90
> [Thu Nov  1 08:43:56 2018]  ? do_ipv6_setsockopt.isra.5+0x10da/0x1290
> [Thu Nov  1 08:43:56 2018]  __alloc_pages_nodemask+0x12a/0x2a0
> [Thu Nov  1 08:43:56 2018]  kmalloc_large_node+0x47/0x90
> [Thu Nov  1 08:43:56 2018]  __kmalloc_node+0x22b/0x2e0
> [Thu Nov  1 08:43:56 2018]  kvmalloc_node+0x3e/0x70
> [Thu Nov  1 08:43:56 2018]  xt_alloc_table_info+0x3a/0x80 [x_tables]
> [Thu Nov  1 08:43:56 2018]  do_ip6t_set_ctl+0xcd/0x1c0 [ip6_tables]
> [Thu Nov  1 08:43:56 2018]  nf_setsockopt+0x44/0x60
> [Thu Nov  1 08:43:56 2018]  SyS_setsockopt+0x6f/0xc0
> [Thu Nov  1 08:43:56 2018]  do_syscall_64+0x67/0x120
> [Thu Nov  1 08:43:56 2018]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2

If kvalloc_node() is going to call kmalloc() without checking for a
huge allocation request then surely it should set __GFP_NOWARN.  And it
shouldn't bother at all if size > KMALLOC_MAX_SIZE, surely?  So
something like

--- a/mm/util.c~a
+++ a/mm/util.c
@@ -393,11 +393,16 @@ void *kvmalloc_node(size_t size, gfp_t f
 	void *ret;
 
 	/*
-	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
-	 * so the given set of flags has to be compatible.
+	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page
+	 * tables) so the given set of flags has to be compatible.
 	 */
-	if ((flags & GFP_KERNEL) != GFP_KERNEL)
+	if ((flags & GFP_KERNEL) != GFP_KERNEL) {
+		if (size > KMALLOC_MAX_SIZE)
+			return NULL;
+		if (size > PAGE_SIZE)
+			flags |= __GFP_NOWARN;
 		return kmalloc_node(size, flags, node);
+	}
 
 	/*
 	 * We want to attempt a large physically contiguous block first because


> the problem is that we only check for an out of bound order in the slow
> path and the node reclaim might happen from the fast path already. This
> is fixable by making sure that kvmalloc doesn't ever use kmalloc for
> requests that are larger than KMALLOC_MAX_SIZE but this also shows that
> the code is rather fragile. A recent UBSAN report just underlines that
> by the following report
> 
>  UBSAN: Undefined behaviour in mm/page_alloc.c:3117:19
>  shift exponent 51 is too large for 32-bit type 'int'
>  CPU: 0 PID: 6520 Comm: syz-executor1 Not tainted 4.19.0-rc2 #1
>  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  Call Trace:
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0xd2/0x148 lib/dump_stack.c:113
>   ubsan_epilogue+0x12/0x94 lib/ubsan.c:159
>   __ubsan_handle_shift_out_of_bounds+0x2b6/0x30b lib/ubsan.c:425
>   __zone_watermark_ok+0x2c7/0x400 mm/page_alloc.c:3117
>   zone_watermark_fast mm/page_alloc.c:3216 [inline]
>   get_page_from_freelist+0xc49/0x44c0 mm/page_alloc.c:3300
>   __alloc_pages_nodemask+0x21e/0x640 mm/page_alloc.c:4370
>   alloc_pages_current+0xcc/0x210 mm/mempolicy.c:2093
>   alloc_pages include/linux/gfp.h:509 [inline]
>   __get_free_pages+0x12/0x60 mm/page_alloc.c:4414
>   dma_mem_alloc+0x36/0x50 arch/x86/include/asm/floppy.h:156
>   raw_cmd_copyin drivers/block/floppy.c:3159 [inline]
>   raw_cmd_ioctl drivers/block/floppy.c:3206 [inline]
>   fd_locked_ioctl+0xa00/0x2c10 drivers/block/floppy.c:3544
>   fd_ioctl+0x40/0x60 drivers/block/floppy.c:3571
>   __blkdev_driver_ioctl block/ioctl.c:303 [inline]
>   blkdev_ioctl+0xb3c/0x1a30 block/ioctl.c:601
>   block_ioctl+0x105/0x150 fs/block_dev.c:1883
>   vfs_ioctl fs/ioctl.c:46 [inline]
>   do_vfs_ioctl+0x1c0/0x1150 fs/ioctl.c:687
>   ksys_ioctl+0x9e/0xb0 fs/ioctl.c:702
>   __do_sys_ioctl fs/ioctl.c:709 [inline]
>   __se_sys_ioctl fs/ioctl.c:707 [inline]
>   __x64_sys_ioctl+0x7e/0xc0 fs/ioctl.c:707
>   do_syscall_64+0xc4/0x510 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe

And we could fix this in the floppy driver.

> Note that this is not a kvmalloc path. It is just that the fast path
> really depends on having sanitzed order as well. Therefore move the
> order check to the fast path.

But do we really need to do this?  Are there any other known potential
callsites?
