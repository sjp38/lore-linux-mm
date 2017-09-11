Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BEBBF6B02B6
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 06:38:15 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o200so10938036itg.2
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 03:38:15 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id r123si7732167iod.32.2017.09.11.03.38.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 03:38:14 -0700 (PDT)
Subject: Re: [PATCH v6 00/11] Add support for eXclusive Page Frame Ownership
References: <20170907173609.22696-1-tycho@docker.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <23e5bac9-329a-3a32-049e-7e7c9751abd0@huawei.com>
Date: Mon, 11 Sep 2017 18:34:45 +0800
MIME-Version: 1.0
In-Reply-To: <20170907173609.22696-1-tycho@docker.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

Hi Tycho ,

On 2017/9/8 1:35, Tycho Andersen wrote:
> Hi all,
> 
> Here is v6 of the XPFO set; see v5 discussion here:
> https://lkml.org/lkml/2017/8/9/803
> 
> Changelogs are in the individual patch notes, but the highlights are:
> * add primitives for ensuring memory areas are mapped (although these are quite
>   ugly, using stack allocation; I'm open to better suggestions)
> * instead of not flushing caches, re-map pages using the above
> * TLB flushing is much more correct (i.e. we're always flushing everything
>   everywhere). I suspect we may be able to back this off in some cases, but I'm
>   still trying to collect performance numbers to prove this is worth doing.
> 
> I have no TODOs left for this set myself, other than fixing whatever review
> feedback people have. Thoughts and testing welcome!

According to the paper of Vasileios P. Kemerlis et al, the mainline kernel
will not set the Pro. of physmap(direct map area) to RW(X), so do we really
need XPFO to protect from ret2dir attack?

Thanks
Yisheng xie

> 
> Cheers,
> 
> Tycho
> 
> Juerg Haefliger (6):
>   mm, x86: Add support for eXclusive Page Frame Ownership (XPFO)
>   swiotlb: Map the buffer if it was unmapped by XPFO
>   arm64/mm: Add support for XPFO
>   arm64/mm, xpfo: temporarily map dcache regions
>   arm64/mm: Add support for XPFO to swiotlb
>   lkdtm: Add test for XPFO
> 
> Tycho Andersen (5):
>   mm: add MAP_HUGETLB support to vm_mmap
>   x86: always set IF before oopsing from page fault
>   xpfo: add primitives for mapping underlying memory
>   arm64/mm: disable section/contiguous mappings if XPFO is enabled
>   mm: add a user_virt_to_phys symbol
> 
>  Documentation/admin-guide/kernel-parameters.txt |   2 +
>  arch/arm64/Kconfig                              |   1 +
>  arch/arm64/include/asm/cacheflush.h             |  11 +
>  arch/arm64/mm/Makefile                          |   2 +
>  arch/arm64/mm/dma-mapping.c                     |  32 +--
>  arch/arm64/mm/flush.c                           |   7 +
>  arch/arm64/mm/mmu.c                             |   2 +-
>  arch/arm64/mm/xpfo.c                            | 127 +++++++++++
>  arch/x86/Kconfig                                |   1 +
>  arch/x86/include/asm/pgtable.h                  |  25 +++
>  arch/x86/mm/Makefile                            |   1 +
>  arch/x86/mm/fault.c                             |   6 +
>  arch/x86/mm/pageattr.c                          |  22 +-
>  arch/x86/mm/xpfo.c                              | 171 +++++++++++++++
>  drivers/misc/Makefile                           |   1 +
>  drivers/misc/lkdtm.h                            |   5 +
>  drivers/misc/lkdtm_core.c                       |   3 +
>  drivers/misc/lkdtm_xpfo.c                       | 194 +++++++++++++++++
>  include/linux/highmem.h                         |  15 +-
>  include/linux/mm.h                              |   2 +
>  include/linux/xpfo.h                            |  79 +++++++
>  lib/swiotlb.c                                   |   3 +-
>  mm/Makefile                                     |   1 +
>  mm/mmap.c                                       |  19 +-
>  mm/page_alloc.c                                 |   2 +
>  mm/page_ext.c                                   |   4 +
>  mm/util.c                                       |  32 +++
>  mm/xpfo.c                                       | 273 ++++++++++++++++++++++++
>  security/Kconfig                                |  19 ++
>  29 files changed, 1005 insertions(+), 57 deletions(-)
>  create mode 100644 arch/arm64/mm/xpfo.c
>  create mode 100644 arch/x86/mm/xpfo.c
>  create mode 100644 drivers/misc/lkdtm_xpfo.c
>  create mode 100644 include/linux/xpfo.h
>  create mode 100644 mm/xpfo.c
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
