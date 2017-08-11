Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89F826B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 19:35:56 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q66so24728235qki.1
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:35:56 -0700 (PDT)
Received: from mail-qt0-f182.google.com (mail-qt0-f182.google.com. [209.85.216.182])
        by mx.google.com with ESMTPS id r77si106195qkl.85.2017.08.11.16.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 16:35:55 -0700 (PDT)
Received: by mail-qt0-f182.google.com with SMTP id s6so29237250qtc.1
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:35:55 -0700 (PDT)
Subject: Re: [kernel-hardening] [PATCH v5 00/10] Add support for eXclusive
 Page Frame Ownership
References: <20170809200755.11234-1-tycho@docker.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <9b3d80f0-7625-a0dc-cb00-cf0e940015b1@redhat.com>
Date: Fri, 11 Aug 2017 16:35:52 -0700
MIME-Version: 1.0
In-Reply-To: <20170809200755.11234-1-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> Hi all,
> 
> Here's a v5 of the XPFO set. Changes from v4 are:
> 
> * huge pages support actually works now on x86
> * arm64 support, which boots on several different arm64 boards
> * tests for hugepages support as well via LKDTM (thanks Kees for suggesting how
>   to make this work)
> 
> Patch 2 contains some potentially controversial stuff, exposing the cpa_lock
> and lifting some other static functions out; there is probably a better way to
> do this, thoughts welcome.
> 
> Still to do are:
> 
> * get it to work with non-64k pages on ARM
> * get rid of the BUG()s, in favor or WARN or similar
> * other things people come up with in this review
> 
> Please have a look. Thoughts welcome!
> 

I gave this a quick test on my arm64 machine and I see faults once
we hit userspace:

[    4.439714] Unhandled fault: TLB conflict abort (0x96000030) at 0xffff800391440090
[    4.447357] Internal error: : 96000030 [#1] SMP
[    4.451875] Modules linked in:
[    4.454924] CPU: 2 PID: 184 Comm: systemd Tainted: G        W       4.13.0-rc4-xpfo+ #63
[    4.462989] Hardware name: AppliedMicro X-Gene Mustang Board/X-Gene Mustang Board, BIOS 3.06.12 Aug 12 2016
[    4.472698] task: ffff8003e8d9fb00 task.stack: ffff8003f9fbc000
[    4.478602] PC is at copy_page+0x48/0x110
[    4.482601] LR is at __cpu_copy_user_page+0x28/0x48
 
I'll have to give this a closer look to see what's going on with the TLB flushing.

Thanks,
Laura


> Previously: http://www.openwall.com/lists/kernel-hardening/2017/06/07/24
> 
> Tycho
> 
> Juerg Haefliger (8):
>   mm, x86: Add support for eXclusive Page Frame Ownership (XPFO)
>   swiotlb: Map the buffer if it was unmapped by XPFO
>   arm64: Add __flush_tlb_one()
>   arm64/mm: Add support for XPFO
>   arm64/mm: Disable section mappings if XPFO is enabled
>   arm64/mm: Don't flush the data cache if the page is unmapped by XPFO
>   arm64/mm: Add support for XPFO to swiotlb
>   lkdtm: Add test for XPFO
> 
> Tycho Andersen (2):
>   mm: add MAP_HUGETLB support to vm_mmap
>   mm: add a user_virt_to_phys symbol
> 
>  Documentation/admin-guide/kernel-parameters.txt |   2 +
>  arch/arm64/Kconfig                              |   1 +
>  arch/arm64/include/asm/cacheflush.h             |  11 ++
>  arch/arm64/include/asm/tlbflush.h               |   8 +
>  arch/arm64/mm/Makefile                          |   2 +
>  arch/arm64/mm/dma-mapping.c                     |  32 ++--
>  arch/arm64/mm/flush.c                           |   5 +-
>  arch/arm64/mm/mmu.c                             |  14 +-
>  arch/arm64/mm/xpfo.c                            | 160 +++++++++++++++++
>  arch/x86/Kconfig                                |   1 +
>  arch/x86/include/asm/pgtable.h                  |  23 +++
>  arch/x86/mm/Makefile                            |   1 +
>  arch/x86/mm/pageattr.c                          |  24 +--
>  arch/x86/mm/xpfo.c                              | 153 +++++++++++++++++
>  drivers/misc/Makefile                           |   1 +
>  drivers/misc/lkdtm.h                            |   4 +
>  drivers/misc/lkdtm_core.c                       |   4 +
>  drivers/misc/lkdtm_xpfo.c                       |  62 +++++++
>  include/linux/highmem.h                         |  15 +-
>  include/linux/mm.h                              |   2 +
>  include/linux/xpfo.h                            |  47 +++++
>  lib/swiotlb.c                                   |   3 +-
>  mm/Makefile                                     |   1 +
>  mm/mmap.c                                       |  19 +--
>  mm/page_alloc.c                                 |   2 +
>  mm/page_ext.c                                   |   4 +
>  mm/util.c                                       |  32 ++++
>  mm/xpfo.c                                       | 217 ++++++++++++++++++++++++
>  security/Kconfig                                |  19 +++
>  29 files changed, 810 insertions(+), 59 deletions(-)
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
