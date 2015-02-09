Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 914476B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 17:45:51 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id v63so20078824oia.13
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 14:45:51 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id wh1si6662031obc.16.2015.02.09.14.45.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 14:45:50 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 0/7] Kernel huge I/O mapping support
Date: Mon,  9 Feb 2015 15:45:28 -0700
Message-Id: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

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

On x86, the huge I/O mapping may not be used when a target range is
covered by multiple MTRRs with different memory types.  The caller
must make a separate request for each MTRR range, or the huge I/O
mapping can be disabled with the kernel boot option "nohugeiomap".
The detail of this issue is described in the email below, and this
patch takes option C) in favor of simplicity since MTRRs are legacy
feature.
 https://lkml.org/lkml/2015/2/5/638

The patchset introduces the following configs:
 HUGE_IOMAP - When selected (default Y), enable huge I/O mappings.
              Require HAVE_ARCH_HUGE_VMAP set.
 HAVE_ARCH_HUGE_VMAP - Indicate arch supports huge KVA mappings.
                       Require X86_PAE set on X86_32.

Patch 1-4 changes common files to support huge I/O mappings.  There
is no change in the functinalities until HUGE_IOMAP is set in patch 7.

Patch 5,6 implement HAVE_ARCH_HUGE_VMAP and HUGE_IOMAP funcs on x86,
and set HAVE_ARCH_HUGE_VMAP on x86.

Patch 7 adds HUGE_IOMAP to Kconfig, which is set to Y by default on
x86.

---
v2:
 - Addressed review comments from Andrew Morton.
 - Changed HAVE_ARCH_HUGE_VMAP to require X86_PAE set on X86_32.
 - Documented a x86 restriction with multiple MTRRs with different
   memory types.

---
Toshi Kani (7):
  1/7 mm: Change __get_vm_area_node() to use fls_long()
  2/7 lib: Add huge I/O map capability interfaces
  3/7 mm: Change ioremap to set up huge I/O mappings
  4/7 mm: Change vunmap to tear down huge KVA mappings
  5/7 x86, mm: Support huge KVA mappings on x86
  6/7 x86, mm: Support huge I/O mappings on x86
  7/7 mm: Add config HUGE_IOMAP to enable huge I/O mappings

---
 Documentation/kernel-parameters.txt |  2 ++
 arch/Kconfig                        |  3 +++
 arch/x86/Kconfig                    |  1 +
 arch/x86/include/asm/page_types.h   |  8 ++++++
 arch/x86/mm/ioremap.c               | 26 ++++++++++++++++--
 arch/x86/mm/pgtable.c               | 34 +++++++++++++++++++++++
 include/asm-generic/pgtable.h       | 12 +++++++++
 include/linux/io.h                  |  7 +++++
 init/main.c                         |  2 ++
 lib/ioremap.c                       | 54 +++++++++++++++++++++++++++++++++++++
 mm/Kconfig                          | 11 ++++++++
 mm/vmalloc.c                        |  8 +++++-
 12 files changed, 165 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
