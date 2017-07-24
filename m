Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C7FEA6B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 09:42:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 79so11014790wmr.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 06:42:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k82si5530247wmk.67.2017.07.24.06.42.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 06:42:45 -0700 (PDT)
Date: Mon, 24 Jul 2017 15:42:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: pcpu allocator on large NUMA machines
Message-ID: <20170724134240.GL25221@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Tejun,
we are seeing a strange pcpu allocation failures on a large ppc machine
on our older distribution kernel. Please note that I am not yet sure
this is the case with the current up-to-date kernel and I do not have
direct access to the machine but it seems there were not many changes in
the pcpu area since 4.4 that would make any difference.

The machine has 32TB of memory and 192 cores.

Warnings are as follows:
WARNING: at ../mm/vmalloc.c:2423
[...]
NIP [c00000000028e048] pcpu_get_vm_areas+0x698/0x6d0
LR [c000000000268be0] pcpu_create_chunk+0xb0/0x160
Call Trace:
[c000106c3948f900] [c000000000268684] pcpu_mem_zalloc+0x54/0xd0 (unreliable)
[c000106c3948f9d0] [c000000000268be0] pcpu_create_chunk+0xb0/0x160
[c000106c3948fa00] [c000000000269dc4] pcpu_alloc+0x284/0x740
[c000106c3948faf0] [c00000000017ac90] hotplug_cfd+0x100/0x150
[c000106c3948fb30] [c0000000000eabf8] notifier_call_chain+0x98/0x110
[c000106c3948fb80] [c0000000000bdae0] _cpu_up+0x150/0x210
[c000106c3948fc30] [c0000000000bdcbc] cpu_up+0x11c/0x140
[c000106c3948fcb0] [c000000000ac47dc] smp_init+0x110/0x118
[c000106c3948fd00] [c000000000aa4228] kernel_init_freeable+0x19c/0x364
[c000106c3948fdc0] [c00000000000bf58] kernel_init+0x28/0x150
[c000106c3948fe30] [c000000000009538] ret_from_kernel_thread+0x5c/0xa4

And the kernel log complains about the max_distance.
PERCPU: max_distance=0x1d452f940000 too large for vmalloc space 0x80000000000

The boot dies eventually...

Reducing the number of cores doesn't help but reducing the size of
memory does.  Increasing the vmalloc space (to 56TB) helps as well. Our
older kernels (based on 4.4) booted just fine and it seems that
ba4a648f12f4 ("powerpc/numa: Fix percpu allocations to be NUMA aware")
(which went to stable) changed the picture. Previously the same machine
consumed ~400MB vmalloc area per NUMA node.
0xd00007ffb8000000-0xd00007ffd0000000 402653184 pcpu_get_vm_areas+0x0/0x6d0 vmalloc
0xd00007ffd0000000-0xd00007ffe8000000 402653184 pcpu_get_vm_areas+0x0/0x6d0 vmalloc
0xd00007ffe8000000-0xd000080000000000 402653184 pcpu_get_vm_areas+0x0/0x6d0 vmalloc

My understanding of the pcpu allocator is basically close to zero but it
seems weird to me that we would need many TB of vmalloc address space
just to allocate vmalloc areas that are in range of hundreds of MB. So I
am wondering whether this is an expected behavior of the allocator or
there is a problem somwehere else.

Michael has noted
: On powerpc we use pcpu_embed_first_chunk(). That means we use the 1:1 linear
: mapping of kernel virtual to physical for the first per-cpu chunk (kernel 
: static percpu vars).
:
: Because of that, and because the percpu allocator wants to do node local
: allocations, the distance between the percpu areas ends up being dictated by 
: the distance between the real addresses of our NUMA nodes.
: 
: So if you boot a system with a lot of NUMA nodes, or with a very large
: distance between nodes, then you can hit the bug we have here.
: 
: Of course things have been complicated by the fact that the node-local
: part of the percpu allocation was broken until recently, and because
: most of us don't have access to these really large memory systems.

Let me know if you need further details.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
