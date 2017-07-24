Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1AE66B02FA
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 09:57:19 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j124so36318695qke.6
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 06:57:19 -0700 (PDT)
Received: from mail-qt0-x236.google.com (mail-qt0-x236.google.com. [2607:f8b0:400d:c0d::236])
        by mx.google.com with ESMTPS id b3si312545qtb.257.2017.07.24.06.57.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 06:57:18 -0700 (PDT)
Received: by mail-qt0-x236.google.com with SMTP id p3so9691833qtg.2
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 06:57:18 -0700 (PDT)
Date: Mon, 24 Jul 2017 09:57:14 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: pcpu allocator on large NUMA machines
Message-ID: <20170724135714.GA3240919@devbig577.frc2.facebook.com>
References: <20170724134240.GL25221@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724134240.GL25221@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On Mon, Jul 24, 2017 at 03:42:40PM +0200, Michal Hocko wrote:
> we are seeing a strange pcpu allocation failures on a large ppc machine
> on our older distribution kernel. Please note that I am not yet sure
> this is the case with the current up-to-date kernel and I do not have
> direct access to the machine but it seems there were not many changes in
> the pcpu area since 4.4 that would make any difference.
> 
> The machine has 32TB of memory and 192 cores.
> 
> Warnings are as follows:
> WARNING: at ../mm/vmalloc.c:2423
> [...]
> NIP [c00000000028e048] pcpu_get_vm_areas+0x698/0x6d0
> LR [c000000000268be0] pcpu_create_chunk+0xb0/0x160
> Call Trace:
> [c000106c3948f900] [c000000000268684] pcpu_mem_zalloc+0x54/0xd0 (unreliable)
> [c000106c3948f9d0] [c000000000268be0] pcpu_create_chunk+0xb0/0x160
> [c000106c3948fa00] [c000000000269dc4] pcpu_alloc+0x284/0x740
> [c000106c3948faf0] [c00000000017ac90] hotplug_cfd+0x100/0x150
> [c000106c3948fb30] [c0000000000eabf8] notifier_call_chain+0x98/0x110
> [c000106c3948fb80] [c0000000000bdae0] _cpu_up+0x150/0x210
> [c000106c3948fc30] [c0000000000bdcbc] cpu_up+0x11c/0x140
> [c000106c3948fcb0] [c000000000ac47dc] smp_init+0x110/0x118
> [c000106c3948fd00] [c000000000aa4228] kernel_init_freeable+0x19c/0x364
> [c000106c3948fdc0] [c00000000000bf58] kernel_init+0x28/0x150
> [c000106c3948fe30] [c000000000009538] ret_from_kernel_thread+0x5c/0xa4

That looks like the spread between NUMA addresses is larger than the
size of vmalloc area.

> And the kernel log complains about the max_distance.
> PERCPU: max_distance=0x1d452f940000 too large for vmalloc space 0x80000000000

Yeah, that triggers when the distance becomes larger than 75%.

> The boot dies eventually...
> 
> Reducing the number of cores doesn't help but reducing the size of
> memory does.  Increasing the vmalloc space (to 56TB) helps as well. Our
> older kernels (based on 4.4) booted just fine and it seems that
> ba4a648f12f4 ("powerpc/numa: Fix percpu allocations to be NUMA aware")
> (which went to stable) changed the picture. Previously the same machine
> consumed ~400MB vmalloc area per NUMA node.
> 0xd00007ffb8000000-0xd00007ffd0000000 402653184 pcpu_get_vm_areas+0x0/0x6d0 vmalloc
> 0xd00007ffd0000000-0xd00007ffe8000000 402653184 pcpu_get_vm_areas+0x0/0x6d0 vmalloc
> 0xd00007ffe8000000-0xd000080000000000 402653184 pcpu_get_vm_areas+0x0/0x6d0 vmalloc
> 
> My understanding of the pcpu allocator is basically close to zero but it
> seems weird to me that we would need many TB of vmalloc address space
> just to allocate vmalloc areas that are in range of hundreds of MB. So I
> am wondering whether this is an expected behavior of the allocator or
> there is a problem somwehere else.

It's not actually using the entire region but the area allocations try
to follow the same topology as kernel linear address layouts.  ie. if
kernel address for different NUMA nodes are apart by certain amount,
the percpu allocator tries to replicate that for dynamic allocations
which allows leaving the static and first dynamic area in the kernel
linear address which helps reducing TLB pressure.

This optimization can be turned off when vmalloc area isn't spacious
enough by using pcpu_page_first_chunk() instead of
pcpu_embed_first_chunk() while initializing percpu allocator.  Can you
see whether replacing that in arch/powerpc/kernel/setup_64.c fixes the
issue?  If so, all it needs to do is figuring out what conditions we
need to check to opt out of embedding the first chunk.  Note that x86
32bit does about the same thing.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
