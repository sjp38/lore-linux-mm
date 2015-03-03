Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id F3E3D6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 12:45:03 -0500 (EST)
Received: by obcva2 with SMTP id va2so1299393obc.6
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:45:03 -0800 (PST)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id ij4si733547obb.64.2015.03.03.09.45.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 09:45:02 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 0/6] Kernel huge I/O mapping support
Date: Tue,  3 Mar 2015 10:44:18 -0700
Message-Id: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com

ioremap() and its related interfaces are used to create I/O
mappings to memory-mapped I/O devices.  The mapping sizes of
the traditional I/O devices are relatively small.  Non-volatile
memory (NVM), however, has many GB and is going to have TB soon.
It is not very efficient to create large I/O mappings with 4KB. 

This patchset extends the ioremap() interfaces to transparently
create I/O mappings with huge pages whenever possible.  ioremap()
continues to use 4KB mappings when a huge page does not fit into
a requested range.  There is no change necessary to the drivers
using ioremap().  A requested physical address must be aligned by
a huge page size (1GB or 2MB on x86) for using huge page mapping,
though.  The kernel huge I/O mapping will improve performance of
NVM and other devices with large memory, and reduce the time to
create their mappings as well.

On x86, MTRRs can override PAT memory types with a 4KB granularity.
When using a huge page, MTRRs can override the memory type of the
huge page, which may lead a performance penalty.  The processor can
also behave in an undefined manner if a huge page is mapped to a
memory range that MTRRs have mapped with multiple different memory
types.  Therefore, the mapping code falls back to use a smaller page
size toward 4KB when a mapping range is covered by non-WB type of
MTRRs. The WB type of MTRRs has no affect on the PAT memory types.

The patchset introduces HAVE_ARCH_HUGE_VMAP, which indicates that
the arch supports huge KVA mappings for ioremap().  User may specify
a new kernel option "nohugeiomap" to disable the huge I/O mapping
capability of ioremap() when necessary.

Patch 1-4 change common files to support huge I/O mappings.  There
is no change in the functinalities unless HAVE_ARCH_HUGE_VMAP is
defined on the architecture of the system.

Patch 5-6 implement the HAVE_ARCH_HUGE_VMAP funcs on x86, and set
HAVE_ARCH_HUGE_VMAP on x86.

--
v3:
 - Removed config HUGE_IOMAP. Always enable huge page mappings to
   ioremap() when supported by the arch. (Ingo Molnar)
 - Added checks to use 4KB mappings when a memory range is covered
   by MTRRs. (Ingo Molnar, Andrew Morton)
 - Added missing PAT bit handlings to the huge page mapping funcs.

v2:
 - Addressed review comments. (Andrew Morton)
 - Changed HAVE_ARCH_HUGE_VMAP to require X86_PAE set on X86_32.
 - Documented a x86 restriction with multiple MTRRs with different
   memory types.

---
Toshi Kani (6):
  1/6 mm: Change __get_vm_area_node() to use fls_long()
  2/6 lib: Add huge I/O map capability interfaces
  3/6 mm: Change ioremap to set up huge I/O mappings
  4/6 mm: Change vunmap to tear down huge KVA mappings
  5/6 x86, mm: Support huge I/O mapping capability I/F
  6/6 x86, mm: Support huge KVA mappings on x86

---
 Documentation/kernel-parameters.txt |  2 ++
 arch/Kconfig                        |  3 ++
 arch/x86/Kconfig                    |  1 +
 arch/x86/include/asm/page_types.h   |  2 ++
 arch/x86/mm/ioremap.c               | 23 +++++++++++--
 arch/x86/mm/pgtable.c               | 65 +++++++++++++++++++++++++++++++++++++
 include/asm-generic/pgtable.h       | 19 +++++++++++
 include/linux/io.h                  |  7 ++++
 init/main.c                         |  2 ++
 lib/ioremap.c                       | 54 ++++++++++++++++++++++++++++++
 mm/vmalloc.c                        |  8 ++++-
 11 files changed, 183 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
