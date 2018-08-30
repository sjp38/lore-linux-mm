Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB526B529B
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:23:59 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j9-v6so9314591qtn.22
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 11:23:59 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e66-v6si2236495qkh.277.2018.08.30.11.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 11:23:58 -0700 (PDT)
Date: Thu, 30 Aug 2018 14:23:56 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] arm64: mm: always enable CONFIG_HOLES_IN_ZONE
In-Reply-To: <20180830150532.22745-1-james.morse@arm.com>
Message-ID: <alpine.LRH.2.02.1808301422590.17830@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180830150532.22745-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Pavel Tatashin <Pavel.Tatashin@microsoft.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>



On Thu, 30 Aug 2018, James Morse wrote:

> Commit 6d526ee26ccd ("arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA")
> only enabled HOLES_IN_ZONE for NUMA systems because the NUMA code was
> choking on the missing zone for nomap pages. This problem doesn't just
> apply to NUMA systems.
> 
> If the architecture doesn't set HAVE_ARCH_PFN_VALID, pfn_valid() will
> return true if the pfn is part of a valid sparsemem section.
> 
> When working with multiple pages, the mm code uses pfn_valid_within()
> to test each page it uses within the sparsemem section is valid. On
> most systems memory comes in MAX_ORDER_NR_PAGES chunks which all
> have valid/initialised struct pages. In this case pfn_valid_within()
> is optimised out.
> 
> Systems where this isn't true (e.g. due to nomap) should set
> HOLES_IN_ZONE and provide HAVE_ARCH_PFN_VALID so that mm tests each
> page as it works with it.
> 
> Currently non-NUMA arm64 systems can't enable HOLES_IN_ZONE, leading to
> VM_BUG_ON():
> | page:fffffdff802e1780 is uninitialized and poisoned
> | raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> | raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> | page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> | ------------[ cut here ]------------
> | kernel BUG at include/linux/mm.h:978!
> | Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> [...]
> | CPU: 1 PID: 25236 Comm: dd Not tainted 4.18.0 #7
> | Hardware name: QEMU KVM Virtual Machine, BIOS 0.0.0 02/06/2015
> | pstate: 40000085 (nZcv daIf -PAN -UAO)
> | pc : move_freepages_block+0x144/0x248
> | lr : move_freepages_block+0x144/0x248
> | sp : fffffe0071177680
> [...]
> | Process dd (pid: 25236, stack limit = 0x0000000094cc07fb)
> | Call trace:
> |  move_freepages_block+0x144/0x248
> |  steal_suitable_fallback+0x100/0x16c
> |  get_page_from_freelist+0x440/0xb20
> |  __alloc_pages_nodemask+0xe8/0x838
> |  new_slab+0xd4/0x418
> |  ___slab_alloc.constprop.27+0x380/0x4a8
> |  __slab_alloc.isra.21.constprop.26+0x24/0x34
> |  kmem_cache_alloc+0xa8/0x180
> |  alloc_buffer_head+0x1c/0x90
> |  alloc_page_buffers+0x68/0xb0
> |  create_empty_buffers+0x20/0x1ec
> |  create_page_buffers+0xb0/0xf0
> |  __block_write_begin_int+0xc4/0x564
> |  __block_write_begin+0x10/0x18
> |  block_write_begin+0x48/0xd0
> |  blkdev_write_begin+0x28/0x30
> |  generic_perform_write+0x98/0x16c
> |  __generic_file_write_iter+0x138/0x168
> |  blkdev_write_iter+0x80/0xf0
> |  __vfs_write+0xe4/0x10c
> |  vfs_write+0xb4/0x168
> |  ksys_write+0x44/0x88
> |  sys_write+0xc/0x14
> |  el0_svc_naked+0x30/0x34
> | Code: aa1303e0 90001a01 91296421 94008902 (d4210000)
> | ---[ end trace 1601ba47f6e883fe ]---
> 
> Remove the NUMA dependency.
> 
> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> Link: https://www.spinics.net/lists/arm-kernel/msg671851.html
> Fixes: 6d526ee26ccd ("arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA")
> CC: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  arch/arm64/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 29e75b47becd..1b1a0e95c751 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -763,7 +763,6 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
>  
>  config HOLES_IN_ZONE
>  	def_bool y
> -	depends on NUMA
>  
>  source kernel/Kconfig.hz
>  
> -- 
> 2.18.0

I confirm that this patch works.

Tested-by: Mikulas Patocka <mpatocka@redhat.com>

Mikulas
