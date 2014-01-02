Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE186B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:53:38 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so14906770pbc.12
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:53:38 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id pk8si43679770pab.184.2014.01.02.13.53.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jan 2014 13:53:37 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv3 00/11] Intermix Lowmem and vmalloc
Date: Thu,  2 Jan 2014 13:53:18 -0800
Message-Id: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>

Happy New Year! This is v3 of the series to allow lowmem and vmalloc virtual
address space to be intermixed.

v3: Lots of changes here
 - A bit of code refactoring on the ARM side
 - Fixed Kconfig per Dave Hansen. Changed the name to something slightly more
 descriptive (bike shedding still welcome)
 - changed is_vmalloc_addr to just use a bitmap per suggestions from both Dave
 and Andrew
 - get_vmalloc_info now updated. Given what get_vmalloc_info is actually trying
 to acheive, lowmem regions are omitted from the accounting.
 - VMALLOC_TOTAL now accounted for correctly
 - introduction of for_each_potential_vmalloc_area. This is used for places
 where code needs to do something on each vmalloc range (formerly
 VMALLOC_START, VMALLOC_END)
 - getting rid of users of VMALLOC_START. The decision of which clients to
 change was based on whether VMALLOC_START was being used as the start of
 vmalloc region (converted over) or the end of the direct mapped area
 (left alone).

v2: Fixed several comments by Kyungmin Park which led me to discover
several issues with the is_vmalloc_addr implementation. is_vmalloc_addr
is probably the ugliest part of the entire series and I debated if
adding extra vmalloc flags would make it less ugly.



Currently on 32-bit systems we have


                  Virtual                             Physical

   PAGE_OFFSET   +--------------+     PHYS_OFFSET   +------------+
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 | lowmem       |                   |  direct    |
                 |              |                   |   mapped   |
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 +--------------+------------------>x------------>
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |  not-direct|
                 |              |                   | mapped     |
                 | vmalloc      |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 +--------------+                   +------------+

Where part of the virtual spaced above PAGE_OFFSET is reserved for direct
mapped lowmem and part of the virtual address space is reserved for vmalloc.

Obviously, we want to optimize for having as much direct mapped memory as
possible since there is a penalty for mapping/unmapping highmem. Unfortunately
system constraints often give memory layouts such as

                  Virtual                             Physical

   PAGE_OFFSET   +--------------+     PHYS_OFFSET   +------------+
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |xxxxxxxxxxxx|
                 | lowmem       |                   |xxxxxxxxxxxx|
                 |              |                   |xxxxxxxxxxxx|
                 |              |                   |xxxxxxxxxxxx|
                 |              |                   |            |
                 |              |                   |            |
                 +--------------+------------------>x------------>
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |  not-direct|
                 |              |                   | mapped     |
                 | vmalloc      |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 +--------------+                   +------------+

                 (x = Linux cannot touch this memory)

where part of physical region that would be direct mapped as lowmem is not
actually in use by Linux.

This means that even though the system is not actually accessing the memory
we are still losing that portion of the direct mapped lowmem space. What this
series does is treat the virtual address space that would have been taken up
by the lowmem memory as vmalloc space and allows more lowmem to be mapped



                  Virtual                             Physical

   PAGE_OFFSET   +--------------+     PHYS_OFFSET   +------------+
                 |              |                   |            |
                 | lowmem       |                   |            |
                 <----------------------------------+xxxxxxxxxxxx|
                 |              |                   |xxxxxxxxxxxx|
                 | vmalloc      |                   |xxxxxxxxxxxx|
                 <----------------------------------+xxxxxxxxxxxx|
                 |              |                   |            |
                 | lowmem       |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 |              |                   |            |
                 +----------------------------------------------->
                 | vmalloc      |                   |            |
                 |              |                   |  not-direct|
                 |              |                   | mapped     |
                 |              |                   |            |
                 +--------------+                   +------------+

The goal here is to allow as much lowmem to be mapped as if the block of memory
was not reserved from the physical lowmem region. Previously, we had been
hacking up the direct virt <-> phys translation to ignore a large region of
memory. This did not scale for multiple holes of memory however.

Open issues:
	- vmalloc=<size> will account for all vmalloc now. This may have the
	side effect of shrinking 'traditional' vmalloc too much for regular
	static mappings. We were debating if this is just part of finding the
	correct size for vmalloc or if there is a need for vmalloc_upper=
	- People who like bike shedding more than I do can suggest better
	config names if there is sufficient interest in the series.


Laura Abbott (11):
  mce: acpi/apei: Use get_vm_area directly
  iommu/omap: Use get_vm_area directly
  percpu: use VMALLOC_TOTAL instead of VMALLOC_END - VMALLOC_START
  dm: Use VMALLOC_TOTAL instead of VMALLCO_END - VMALLOC_START
  staging: lustre: Use is_vmalloc_addr
  arm: use is_vmalloc_addr
  arm: mm: Add iotable_init_novmreserve
  mm/vmalloc.c: Allow lowmem to be tracked in vmalloc
  arm: mm: Track lowmem in vmalloc
  arm: Use for_each_potential_vmalloc_area
  fs/proc/kcore.c: Use for_each_potential_vmalloc_area

 arch/arm/Kconfig                                   |    3 +
 arch/arm/include/asm/mach/map.h                    |    2 +
 arch/arm/kvm/mmu.c                                 |   12 ++-
 arch/arm/mm/dma-mapping.c                          |    2 +-
 arch/arm/mm/init.c                                 |  104 ++++++++++++-----
 arch/arm/mm/iomap.c                                |    3 +-
 arch/arm/mm/ioremap.c                              |   17 ++-
 arch/arm/mm/mm.h                                   |    3 +-
 arch/arm/mm/mmu.c                                  |   55 ++++++++-
 drivers/acpi/apei/ghes.c                           |    4 +-
 drivers/iommu/omap-iovmm.c                         |    2 +-
 drivers/md/dm-bufio.c                              |    4 +-
 drivers/md/dm-stats.c                              |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    3 +-
 fs/proc/kcore.c                                    |   20 +++-
 include/linux/mm.h                                 |    6 +
 include/linux/vmalloc.h                            |   31 +++++
 mm/Kconfig                                         |    6 +
 mm/percpu.c                                        |    4 +-
 mm/vmalloc.c                                       |  119 +++++++++++++++++---
 20 files changed, 320 insertions(+), 82 deletions(-)

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
