Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id C9CDA8E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:51:26 -0500 (EST)
Received: by mail-ua1-f70.google.com with SMTP id o13so1402746uad.6
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 14:51:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s15si2672236vsh.128.2018.12.11.14.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 14:51:25 -0800 (PST)
Message-ID: <f5a5bc600f3f956b92021ba86222b374f21044f8.camel@redhat.com>
Subject: Re: [PATCH v3 0/6] memblock: simplify several early memory
 allocation
From: Mark Salter <msalter@redhat.com>
Date: Tue, 11 Dec 2018 17:51:23 -0500
In-Reply-To: <1544367624-15376-1-git-send-email-rppt@linux.ibm.com>
References: <1544367624-15376-1-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-c6x-dev <linux-c6x-dev@linux-c6x.org>

On Sun, 2018-12-09 at 17:00 +0200, Mike Rapoport wrote:
> Hi,
> 
> These patches simplify some of the early memory allocations by replacing
> usage of older memblock APIs with newer and shinier ones.
> 
> Quite a few places in the arch/ code allocated memory using a memblock API
> that returns a physical address of the allocated area, then converted this
> physical address to a virtual one and then used memset(0) to clear the
> allocated range.
> 
> More recent memblock APIs do all the three steps in one call and their
> usage simplifies the code.
> 
> It's important to note that regardless of API used, the core allocation is
> nearly identical for any set of memblock allocators: first it tries to find
> a free memory with all the constraints specified by the caller and then
> falls back to the allocation with some or all constraints disabled.
> 
> The first three patches perform the conversion of call sites that have
> exact requirements for the node and the possible memory range.
> 
> The fourth patch is a bit one-off as it simplifies openrisc's
> implementation of pte_alloc_one_kernel(), and not only the memblock usage.
> 
> The fifth patch takes care of simpler cases when the allocation can be
> satisfied with a simple call to memblock_alloc().
> 
> The sixth patch removes one-liner wrappers for memblock_alloc on arm and
> unicore32, as suggested by Christoph.
> 
> v3:
> * added Tested-by from Michal Simek for microblaze changes
> * updated powerpc changes as per Michael Ellerman comments:
>   - use allocations that clear memory in alloc_paca_data() and alloc_stack()
>   - ensure the replacement is equivalent to old API
> 
> v2:
> * added Ack from Stafford Horne for openrisc changes
> * entirely drop early_alloc wrappers on arm and unicore32, as per Christoph
> Hellwig
> 
> 
> 
> Mike Rapoport (6):
>   powerpc: prefer memblock APIs returning virtual address
>   microblaze: prefer memblock API returning virtual address
>   sh: prefer memblock APIs returning virtual address
>   openrisc: simplify pte_alloc_one_kernel()
>   arch: simplify several early memory allocations
>   arm, unicore32: remove early_alloc*() wrappers
> 
>  arch/arm/mm/mmu.c                      | 13 +++----------
>  arch/c6x/mm/dma-coherent.c             |  9 ++-------
>  arch/microblaze/mm/init.c              |  5 +++--
>  arch/nds32/mm/init.c                   | 12 ++++--------
>  arch/openrisc/mm/ioremap.c             | 11 ++++-------
>  arch/powerpc/kernel/paca.c             | 16 ++++++----------
>  arch/powerpc/kernel/setup-common.c     |  4 ++--
>  arch/powerpc/kernel/setup_64.c         | 24 ++++++++++--------------
>  arch/powerpc/mm/hash_utils_64.c        |  6 +++---
>  arch/powerpc/mm/pgtable-book3e.c       |  8 ++------
>  arch/powerpc/mm/pgtable-book3s64.c     |  5 +----
>  arch/powerpc/mm/pgtable-radix.c        | 25 +++++++------------------
>  arch/powerpc/mm/pgtable_32.c           |  4 +---
>  arch/powerpc/mm/ppc_mmu_32.c           |  3 +--
>  arch/powerpc/platforms/pasemi/iommu.c  |  5 +++--
>  arch/powerpc/platforms/powernv/opal.c  |  3 +--
>  arch/powerpc/platforms/pseries/setup.c | 18 ++++++++++++++----
>  arch/powerpc/sysdev/dart_iommu.c       |  7 +++++--
>  arch/sh/mm/init.c                      | 18 +++++-------------
>  arch/sh/mm/numa.c                      |  5 ++---
>  arch/sparc/kernel/prom_64.c            |  7 ++-----
>  arch/sparc/mm/init_64.c                |  9 +++------
>  arch/unicore32/mm/mmu.c                | 14 ++++----------
>  23 files changed, 88 insertions(+), 143 deletions(-)
> 

For the c6x bits:
Acked-by: Mark Salter <msalter@redhat.com>
