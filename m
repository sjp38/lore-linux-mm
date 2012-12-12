Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 9618E6B005A
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 13:19:35 -0500 (EST)
From: Joe Perches <joe@perches.com>
Subject: [TRIVIAL PATCH 00/26] treewide: Add and use vsprintf extension %pSR
Date: Wed, 12 Dec 2012 10:18:49 -0800
Message-Id: <cover.1355335227.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <trivial@kernel.org>, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, linux-edac@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, cluster-devel@redhat.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-kernel@zh-kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, linux-am33-list@redhat.com, linux@lists.openrisc.net, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org

Remove the somewhat awkward uses of print_symbol and convert all the
existing uses to a new vsprintf pointer type of %pSR.

print_symbol can be interleaved when it is used in a sequence like:

	printk("something: ...");
	print_symbol("%s", addr);
	printk("\n");

Instead use:

	printk("something: %pSR\n", (void *)addr);

Add a new %p[SsFf]R vsprintf extension that can perform the same
symbol function/address/offset formatting as print_symbol to
reduce the number and styles of message logging functions.

print_symbol used __builtin_extract_return_addr for those architectures
like S/390 and SPARC that have offset or masked addressing.
%p[FfSs]R uses the same gcc __builtin

Joe Perches (26):
  vsprintf: Add extension %pSR - print_symbol replacement
  alpha: Convert print_symbol to %pSR
  arm: Convert print_symbol to %pSR
  arm64: Convert print_symbol to %pSR
  avr32: Convert print_symbol to %pSR
  c6x: Convert print_symbol to %pSR
  ia64: Convert print_symbol to %pSR
  m32r: Convert print_symbol to %pSR
  mn10300: Convert print_symbol to %pSR
  openrisc: Convert print_symbol to %pSR
  powerpc: Convert print_symbol to %pSR
  s390: Convert print_symbol to %pSR
  sh: Convert print_symbol to %pSR
  um: Convert print_symbol to %pSR
  unicore32: Convert print_symbol to %pSR
  x86: Convert print_symbol to %pSR
  xtensa: Convert print_symbol to %pSR
  drivers: base: Convert print_symbol to %pSR
  gfs2: Convert print_symbol to %pSR
  sysfs: Convert print_symbol to %pSR
  irq: Convert print_symbol to %pSR
  smp_processor_id: Convert print_symbol to %pSR
  mm: Convert print_symbol to %pSR
  xtensa: Convert print_symbol to %pSR
  x86: head_64.S: Use vsprintf extension %pSR not print_symbol
  kallsyms: Remove print_symbol

 Documentation/filesystems/sysfs.txt         |    4 +-
 Documentation/printk-formats.txt            |    2 +
 Documentation/zh_CN/filesystems/sysfs.txt   |    4 +-
 arch/alpha/kernel/traps.c                   |    8 ++----
 arch/arm/kernel/process.c                   |    4 +-
 arch/arm64/kernel/process.c                 |    4 +-
 arch/avr32/kernel/process.c                 |   25 ++++++-----------------
 arch/c6x/kernel/traps.c                     |    3 +-
 arch/ia64/kernel/process.c                  |   13 ++++-------
 arch/m32r/kernel/traps.c                    |    6 +---
 arch/mn10300/kernel/traps.c                 |    8 +++---
 arch/openrisc/kernel/traps.c                |    7 +----
 arch/powerpc/platforms/cell/spu_callbacks.c |   12 ++++------
 arch/s390/kernel/traps.c                    |   28 +++++++++++++++-----------
 arch/sh/kernel/process_32.c                 |    4 +-
 arch/um/kernel/sysrq.c                      |    6 +---
 arch/unicore32/kernel/process.c             |    5 ++-
 arch/x86/kernel/cpu/mcheck/mce.c            |   13 ++++++-----
 arch/x86/kernel/dumpstack.c                 |    5 +--
 arch/x86/kernel/head_64.S                   |    4 +-
 arch/x86/kernel/process_32.c                |    2 +-
 arch/x86/mm/mmio-mod.c                      |    4 +-
 arch/x86/um/sysrq_32.c                      |    9 ++-----
 arch/xtensa/kernel/traps.c                  |    6 +---
 drivers/base/core.c                         |    4 +-
 fs/gfs2/glock.c                             |    4 +-
 fs/gfs2/trans.c                             |    3 +-
 fs/sysfs/file.c                             |    4 +-
 include/linux/kallsyms.h                    |   18 -----------------
 kernel/irq/debug.h                          |   15 ++++++-------
 kernel/kallsyms.c                           |   11 ----------
 lib/smp_processor_id.c                      |    2 +-
 lib/vsprintf.c                              |   18 ++++++++++++----
 mm/memory.c                                 |    8 +++---
 mm/slab.c                                   |    8 ++----
 35 files changed, 117 insertions(+), 164 deletions(-)

-- 
1.7.8.112.g3fd21

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
