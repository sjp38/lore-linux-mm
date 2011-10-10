Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2B26B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 08:11:53 -0400 (EDT)
Message-ID: <4E92E003.4060901@stericsson.com>
Date: Mon, 10 Oct 2011 14:07:31 +0200
From: Maxime Coquelin <maxime.coquelin-nonst@stericsson.com>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [PATCHv16 0/9] Contiguous Memory Allocator
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, benjamin.gaignard@linaro.org, frq09524 <ludovic.barre@stericsson.com>, vincent.guittot@linaro.org

On 10/06/2011 03:54 PM, Marek Szyprowski wrote:
> Welcome everyone again,
>
> Once again I decided to post an updated version of the Contiguous Memory
> Allocator patches.
>
> This version provides mainly a bugfix for a very rare issue that might
> have changed migration type of the CMA page blocks resulting in dropping
> CMA features from the affected page block and causing memory allocation
> to fail. Also the issue reported by Dave Hansen has been fixed.
>
> This version also introduces basic support for x86 architecture, what
> allows wide testing on KVM/QEMU emulators and all common x86 boxes. I
> hope this will result in wider testing, comments and easier merging to
> mainline.
>
> I've also dropped an examplary patch for s5p-fimc platform device
> private memory declaration and added the one from real life. CMA device
> private memory regions are defined for s5p-mfc device to let it allocate
> buffers from two memory banks.
>
> ARM integration code has not been changed since last version, it
> provides implementation of all the ideas that has been discussed during

Hello Marek,

     We are currently testing CMA (v16) on Snowball platform.
     This feature is very promising, thanks for pushing it!

     During our stress tests, we encountered some problems :

     1) Contiguous allocation lockup:
         When system RAM is full of Anon pages, if we try to allocate a 
contiguous buffer greater than the min_free value, we face a 
dma_alloc_from_contiguous lockup.
         The expected result would be dma_alloc_from_contiguous() to fail.
         The problem is reproduced systematically on our side.

     2) Contiguous allocation fail:
         We have developed a small driver and a shell script to 
allocate/release contiguous buffers.
         Sometimes, dma_alloc_from_contiguous() fails to allocate the 
contiguous buffer (about once every 30 runs).
         We have 270MB Memory passed to the kernel in our configuration, 
and the CMA pool is 90MB large.
         In this setup, the overall memory is either free or full of 
reclaimable pages.


     For now, we didn't had time to investigate further theses problems.
     Have you already faced this kind of issues?
     Could someone testing CMA on other boards confirm/infirm theses 
problems?

Best regards,
Maxime



> Patches in this patchset:
>
>    mm: move some functions from memory_hotplug.c to page_isolation.c
>    mm: alloc_contig_freed_pages() added
>
>      Code "stolen" from Kamezawa.  The first patch just moves code
>      around and the second provide function for "allocates" already
>      freed memory.
>
>    mm: alloc_contig_range() added
>
>      This is what Kamezawa asked: a function that tries to migrate all
>      pages from given range and then use alloc_contig_freed_pages()
>      (defined by the previous commit) to allocate those pages.
>
>    mm: MIGRATE_CMA migration type added
>    mm: MIGRATE_CMA isolation functions added
>
>      Introduction of the new migratetype and support for it in CMA.
>      MIGRATE_CMA works similar to ZONE_MOVABLE expect almost any
>      memory range can be marked as one.
>
>    mm: cma: Contiguous Memory Allocator added
>
>      The code CMA code. Manages CMA contexts and performs memory
>      allocations.
>
>    X86: integrate CMA with DMA-mapping subsystem
>    ARM: integrate CMA with dma-mapping subsystem
>
>      Main clients of CMA framework. CMA serves as a alloc_pages()
>      replacement.
>
>    ARM: Samsung: use CMA for 2 memory banks for s5p-mfc device
>
>      Use CMA device private memory regions instead of custom solution
>      based on memblock_reserve() + dma_declare_coherent().
>
>
> Patch summary:
>
> KAMEZAWA Hiroyuki (2):
>    mm: move some functions from memory_hotplug.c to page_isolation.c
>    mm: alloc_contig_freed_pages() added
>
> Marek Szyprowski (4):
>    drivers: add Contiguous Memory Allocator
>    ARM: integrate CMA with DMA-mapping subsystem
>    ARM: Samsung: use CMA for 2 memory banks for s5p-mfc device
>    X86: integrate CMA with DMA-mapping subsystem
>
> Michal Nazarewicz (3):
>    mm: alloc_contig_range() added
>    mm: MIGRATE_CMA migration type added
>    mm: MIGRATE_CMA isolation functions added
>
>   arch/Kconfig                          |    3 +
>   arch/arm/Kconfig                      |    2 +
>   arch/arm/include/asm/dma-contiguous.h |   16 ++
>   arch/arm/include/asm/mach/map.h       |    1 +
>   arch/arm/mm/dma-mapping.c             |  362 +++++++++++++++++++++++++------
>   arch/arm/mm/init.c                    |    8 +
>   arch/arm/mm/mm.h                      |    3 +
>   arch/arm/mm/mmu.c                     |   29 ++-
>   arch/arm/plat-s5p/dev-mfc.c           |   51 +----
>   arch/x86/Kconfig                      |    1 +
>   arch/x86/include/asm/dma-contiguous.h |   13 +
>   arch/x86/include/asm/dma-mapping.h    |    4 +
>   arch/x86/kernel/pci-dma.c             |   18 ++-
>   arch/x86/kernel/pci-nommu.c           |    8 +-
>   arch/x86/kernel/setup.c               |    2 +
>   drivers/base/Kconfig                  |   79 +++++++
>   drivers/base/Makefile                 |    1 +
>   drivers/base/dma-contiguous.c         |  386 +++++++++++++++++++++++++++++++++
>   include/asm-generic/dma-contiguous.h  |   27 +++
>   include/linux/device.h                |    4 +
>   include/linux/dma-contiguous.h        |  106 +++++++++
>   include/linux/mmzone.h                |   57 +++++-
>   include/linux/page-isolation.h        |   53 ++++-
>   mm/Kconfig                            |    8 +-
>   mm/compaction.c                       |   10 +
>   mm/memory_hotplug.c                   |  111 ----------
>   mm/page_alloc.c                       |  317 +++++++++++++++++++++++++--
>   mm/page_isolation.c                   |  131 +++++++++++-
>   28 files changed, 1522 insertions(+), 289 deletions(-)
>   create mode 100644 arch/arm/include/asm/dma-contiguous.h
>   create mode 100644 arch/x86/include/asm/dma-contiguous.h
>   create mode 100644 drivers/base/dma-contiguous.c
>   create mode 100644 include/asm-generic/dma-contiguous.h
>   create mode 100644 include/linux/dma-contiguous.h
>
> --
> 1.7.1.569.g6f426
>
>
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
