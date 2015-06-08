Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFC36B006C
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:07:07 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so83875384wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:07:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj6si754629wib.101.2015.06.08.05.07.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:07:02 -0700 (PDT)
From: Juergen Gross <jgross@suse.com>
Subject: [Patch V4 00/16] xen: support pv-domains larger than 512GB
Date: Mon,  8 Jun 2015 14:06:41 +0200
Message-Id: <1433765217-16333-1-git-send-email-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>

Support 64 bit pv-domains with more than 512GB of memory.

Tested with 64 bit dom0 on machines with 8GB and 1TB and 32 bit dom0 on a
8GB machine. Conflicts between E820 map and different hypervisor populated
memory areas have been tested via a fake E820 map reserved area on the
8GB machine.

Changes in V4:
- new patch 13 (add explicit memblock_reserve() calls for special pages)

Changes in V3:
- rename xen_chk_e820_reserved() to xen_is_e820_reserved() as requested by
  David Vrabel
- add __initdata tag to global variables in patch 10
- move initrd conflict checking after reserving p2m memory (patch 11)

Changes in V2:
- some clarifications and better explanations in commit messages 
- add header changes of include/xen/interface/xen.h (patch 01)
- add wmb() when incrementing p2m_generation (patch 02)
- add new patch 03 (don't build mfn tree if tools don't need it)
- add new patch 06 (split counting of extra memory pages from remapping)
- add new patch 07 (check memory area against e820 map)
- replace early_iounmap() with early_memunmap() (patch 07->patch 08)
- rework patch 09 (check for kernel memory conflicting with memory layout)
- rework patch 10 (check pre-allocated page tables for conflict with memory map)
- combine old patches 08 and 11 into patch 11
- add new patch 12 (provide early_memremap_ro to establish read-only mapping)
- rework old patch 12 (if p2m list located in to be remapped region delay
  remapping) to copy p2m list in case of a conflict (now patch 13)
- correct Kconfig dependency (patch 13->14)
- don't limit dom0 to 512GB (patch 13->14)
- modify parameter parsing to work in very early boot (patch 13->14)
- add new patch 15 to do some cleanup
- remove old patch 05 (simplify xen_set_identity_and_remap() by using global
  variables)
- remove old patch 08 (detect pre-allocated memory interfering with e820 map)


Juergen Gross (16):
  xen: sync with xen headers
  xen: save linear p2m list address in shared info structure
  xen: don't build mfn tree if tools don't need it
  xen: eliminate scalability issues from initial mapping setup
  xen: move static e820 map to global scope
  xen: split counting of extra memory pages from remapping
  xen: check memory area against e820 map
  xen: find unused contiguous memory area
  xen: check for kernel memory conflicting with memory layout
  xen: check pre-allocated page tables for conflict with memory map
  xen: check for initrd conflicting with e820 map
  mm: provide early_memremap_ro to establish read-only mapping
  xen: add explicit memblock_reserve() calls for special pages
  xen: move p2m list if conflicting with e820 map
  xen: allow more than 512 GB of RAM for 64 bit pv-domains
  xen: remove no longer needed p2m.h

 Documentation/kernel-parameters.txt  |   7 +
 arch/x86/include/asm/xen/interface.h |  96 +++++++-
 arch/x86/include/asm/xen/page.h      |   8 +-
 arch/x86/xen/Kconfig                 |  20 +-
 arch/x86/xen/enlighten.c             |   1 +
 arch/x86/xen/mmu.c                   | 376 +++++++++++++++++++++++++++++--
 arch/x86/xen/p2m.c                   |  43 +++-
 arch/x86/xen/p2m.h                   |  15 --
 arch/x86/xen/setup.c                 | 414 ++++++++++++++++++++++++++---------
 arch/x86/xen/xen-head.S              |   2 +
 arch/x86/xen/xen-ops.h               |   7 +
 include/asm-generic/early_ioremap.h  |   2 +
 include/asm-generic/fixmap.h         |   3 +
 include/xen/interface/xen.h          |  10 +-
 mm/early_ioremap.c                   |  11 +
 15 files changed, 833 insertions(+), 182 deletions(-)
 delete mode 100644 arch/x86/xen/p2m.h

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
