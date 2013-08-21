Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 7C3FE6B0071
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 06:17:04 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Date: Wed, 21 Aug 2013 18:15:35 +0800
Message-Id: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch-set aims to move acpi_initrd_override() earlier on x86.
Some of the patches are from Yinghai's patch-set:
https://lkml.org/lkml/2013/6/14/561

The difference between this patch-set and Yinghai's original patch-set are:
1. This patch-set doesn't split acpi_initrd_override(), but call it as a
   whole operation at early time.
2. Allocate memory from BRK to store override tables.
   (This idea is also from Yinghai.)


[Current state]

The current Linux kernel will initialize acpi tables like the following:

1. Find all acpi override table provided by users in initrd.
   (Linux allows users to override acpi tables in firmware, by specifying
   their own tables in initrd.)

2. Use acpica code to initialize acpi global root table list and install all
   tables into it. If any override tables exists, use it to override the one
   provided by firmware.

Then others can parse these tables and get useful info.

Both of the two steps happen after direct mapping page tables are setup.

[Issues]

In the current Linux kernel, the initialization of acpi tables is too late for
new functionalities.

We have some issues about this:

* For memory hotplug, we need ACPI SRAT at early time to be aware of which memory
  ranges are hotpluggable, and prevent bootmem allocator from allocating memory
  for the kernel. (Kernel pages cannot be hotplugged because )

* As suggested by Yinghai Lu <yinghai@kernel.org>, we should allocate page tables
  in local node. This also needs SRAT before direct mapping page tables are setup.

* As mentioned by Toshi Kani <toshi.kani@hp.com>, ACPI SCPR/DBGP/DBG2 tables
  allow the OS to initialize serial console/debug ports at early boot time. The
  earlier it can be initialized, the better this feature will be.  These tables
  are not currently used by Linux due to a licensing issue, but it could be
  addressed some time soon.


[What are we doing]

We are trying to initialize acip tables as early as possible. But Linux kernel
allows users to override acpi tables by specifying their own tables in initrd.
So we have to do acpi_initrd_override() earlier first.


[About this patch-set]

This patch-set aims to move acpi_initrd_override() as early as possible on x86.
As suggested by Yinghai, we are trying to do it like this:

On 32bit: do it in head_32.S, before paging is enabled. In this case, we can
          access initrd with physical address without page tables.

On 64bit: do it in head_64.c, after paging is enabled but before direct mapping
          is setup.

And also, acpi_initrd_override() needs to allocate memory for override tables.
But at such an early time, there is no memory allocator works. So the basic idea
from Yinghai is to use BRK. We will extend BRK 256KB in this patch-set.


Tang Chen (6):
  x86, acpi: Move table_sigs[] to stack.
  x86, acpi, brk: Extend BRK 256KB to store acpi override tables.
  x86, brk: Make extend_brk() available with va/pa.
  x86, acpi: Make acpi_initrd_override() available with va or pa.
  x86, acpi, brk: Make early_alloc_acpi_override_tables_buf() available
    with va/pa.
  x86, acpi: Do acpi_initrd_override() earlier in head_32.S/head64.c.

Yinghai Lu (2):
  x86: Make get_ramdisk_{image|size}() global.
  x86, microcode: Use get_ramdisk_{image|size}() in microcode handling.

 arch/x86/include/asm/dmi.h              |    2 +-
 arch/x86/include/asm/setup.h            |   11 +++-
 arch/x86/kernel/head64.c                |    4 +
 arch/x86/kernel/head_32.S               |    4 +
 arch/x86/kernel/microcode_intel_early.c |    8 +-
 arch/x86/kernel/setup.c                 |   93 ++++++++++++++++------
 arch/x86/mm/init.c                      |    2 +-
 arch/x86/xen/enlighten.c                |    2 +-
 arch/x86/xen/mmu.c                      |    6 +-
 arch/x86/xen/p2m.c                      |   27 ++++---
 drivers/acpi/osl.c                      |  130 ++++++++++++++++++++-----------
 include/linux/acpi.h                    |    5 +-
 12 files changed, 196 insertions(+), 98 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
