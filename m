Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC9FB6B026D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:04:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n23-v6so4238697pfk.23
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:04:27 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id f9-v6si23564285pgk.594.2018.10.10.05.04.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Oct 2018 05:04:26 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] memblock: stop using implicit alignement to SMP_CACHE_BYTES
In-Reply-To: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
Date: Wed, 10 Oct 2018 23:04:12 +1100
Message-ID: <87o9c22ekj.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-um@lists.infradead.org

Mike Rapoport <rppt@linux.vnet.ibm.com> writes:

> When a memblock allocation APIs are called with align = 0, the alignment is
> implicitly set to SMP_CACHE_BYTES.
>
> Replace all such uses of memblock APIs with the 'align' parameter explicitly
> set to SMP_CACHE_BYTES and stop implicit alignment assignment in the
> memblock internal allocation functions.
>
> For the case when memblock APIs are used via helper functions, e.g. like
> iommu_arena_new_node() in Alpha, the helper functions were detected with
> Coccinelle's help and then manually examined and updated where appropriate.
>
> The direct memblock APIs users were updated using the semantic patch below:
>
> @@
> expression size, min_addr, max_addr, nid;
> @@
> (
> |
> - memblock_alloc_try_nid_raw(size, 0, min_addr, max_addr, nid)
> + memblock_alloc_try_nid_raw(size, SMP_CACHE_BYTES, min_addr, max_addr,
> nid)
> |
> - memblock_alloc_try_nid_nopanic(size, 0, min_addr, max_addr, nid)
> + memblock_alloc_try_nid_nopanic(size, SMP_CACHE_BYTES, min_addr, max_addr,
> nid)
> |
> - memblock_alloc_try_nid(size, 0, min_addr, max_addr, nid)
> + memblock_alloc_try_nid(size, SMP_CACHE_BYTES, min_addr, max_addr, nid)
> |
> - memblock_alloc(size, 0)
> + memblock_alloc(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_raw(size, 0)
> + memblock_alloc_raw(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_from(size, 0, min_addr)
> + memblock_alloc_from(size, SMP_CACHE_BYTES, min_addr)
> |
> - memblock_alloc_nopanic(size, 0)
> + memblock_alloc_nopanic(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_low(size, 0)
> + memblock_alloc_low(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_low_nopanic(size, 0)
> + memblock_alloc_low_nopanic(size, SMP_CACHE_BYTES)
> |
> - memblock_alloc_from_nopanic(size, 0, min_addr)
> + memblock_alloc_from_nopanic(size, SMP_CACHE_BYTES, min_addr)
> |
> - memblock_alloc_node(size, 0, nid)
> + memblock_alloc_node(size, SMP_CACHE_BYTES, nid)
> )
>
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
...
>  arch/powerpc/kernel/pci_32.c              |  3 ++-
>  arch/powerpc/lib/alloc.c                  |  2 +-
>  arch/powerpc/mm/mmu_context_nohash.c      |  7 +++---
>  arch/powerpc/platforms/powermac/nvram.c   |  2 +-
>  arch/powerpc/platforms/powernv/pci-ioda.c |  6 ++---
>  arch/powerpc/sysdev/msi_bitmap.c          |  2 +-

The powerpc changes all look fine.

I'm not quite clear on how SMP_CACHE_BYTES is getting included.

I think it's: memblock.h -> mm.h -> mmzone.h -> cache.h

So that's probably fine.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)


cheers
