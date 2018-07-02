Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 650A86B000D
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 22:48:41 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so9103788plv.0
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:48:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s65-v6si13637228pgb.486.2018.07.01.19.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 01 Jul 2018 19:48:39 -0700 (PDT)
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] x86: make Memory Management options more visible
Message-ID: <af12c83d-2533-ae00-b53c-1fc1a9d8e9ce@infradead.org>
Date: Sun, 1 Jul 2018 19:48:38 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Currently for x86, the "Memory Management" kconfig options are
displayed under "Processor type and features."  This tends to
make them hidden or difficult to find.

This patch makes Memory Managment options a first-class menu by moving
it away from "Processor type and features" and into the main menu.

Also clarify "endmenu" lines with '#' comments of their respective
menu names, just to help people who are reading or editing the
Kconfig file.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 arch/x86/Kconfig |  186 ++++++++++++++++++++++-----------------------
 1 file changed, 95 insertions(+), 91 deletions(-)

--- lnx-418-rc3.orig/arch/x86/Kconfig
+++ lnx-418-rc3/arch/x86/Kconfig
@@ -1638,93 +1638,6 @@ config ILLEGAL_POINTER_VALUE
        default 0 if X86_32
        default 0xdead000000000000 if X86_64
 
-source "mm/Kconfig"
-
-config X86_PMEM_LEGACY_DEVICE
-	bool
-
-config X86_PMEM_LEGACY
-	tristate "Support non-standard NVDIMMs and ADR protected memory"
-	depends on PHYS_ADDR_T_64BIT
-	depends on BLK_DEV
-	select X86_PMEM_LEGACY_DEVICE
-	select LIBNVDIMM
-	help
-	  Treat memory marked using the non-standard e820 type of 12 as used
-	  by the Intel Sandy Bridge-EP reference BIOS as protected memory.
-	  The kernel will offer these regions to the 'pmem' driver so
-	  they can be used for persistent storage.
-
-	  Say Y if unsure.
-
-config HIGHPTE
-	bool "Allocate 3rd-level pagetables from highmem"
-	depends on HIGHMEM
-	---help---
-	  The VM uses one page table entry for each page of physical memory.
-	  For systems with a lot of RAM, this can be wasteful of precious
-	  low memory.  Setting this option will put user-space page table
-	  entries in high memory.
-
-config X86_CHECK_BIOS_CORRUPTION
-	bool "Check for low memory corruption"
-	---help---
-	  Periodically check for memory corruption in low memory, which
-	  is suspected to be caused by BIOS.  Even when enabled in the
-	  configuration, it is disabled at runtime.  Enable it by
-	  setting "memory_corruption_check=1" on the kernel command
-	  line.  By default it scans the low 64k of memory every 60
-	  seconds; see the memory_corruption_check_size and
-	  memory_corruption_check_period parameters in
-	  Documentation/admin-guide/kernel-parameters.rst to adjust this.
-
-	  When enabled with the default parameters, this option has
-	  almost no overhead, as it reserves a relatively small amount
-	  of memory and scans it infrequently.  It both detects corruption
-	  and prevents it from affecting the running system.
-
-	  It is, however, intended as a diagnostic tool; if repeatable
-	  BIOS-originated corruption always affects the same memory,
-	  you can use memmap= to prevent the kernel from using that
-	  memory.
-
-config X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK
-	bool "Set the default setting of memory_corruption_check"
-	depends on X86_CHECK_BIOS_CORRUPTION
-	default y
-	---help---
-	  Set whether the default state of memory_corruption_check is
-	  on or off.
-
-config X86_RESERVE_LOW
-	int "Amount of low memory, in kilobytes, to reserve for the BIOS"
-	default 64
-	range 4 640
-	---help---
-	  Specify the amount of low memory to reserve for the BIOS.
-
-	  The first page contains BIOS data structures that the kernel
-	  must not use, so that page must always be reserved.
-
-	  By default we reserve the first 64K of physical RAM, as a
-	  number of BIOSes are known to corrupt that memory range
-	  during events such as suspend/resume or monitor cable
-	  insertion, so it must not be used by the kernel.
-
-	  You can set this to 4 if you are absolutely sure that you
-	  trust the BIOS to get all its memory reservations and usages
-	  right.  If you know your BIOS have problems beyond the
-	  default 64K area, you can set this to 640 to avoid using the
-	  entire low memory range.
-
-	  If you have doubts about the BIOS (e.g. suspend/resume does
-	  not work or there's kernel crashes after certain hardware
-	  hotplug events) then you might want to enable
-	  X86_CHECK_BIOS_CORRUPTION=y to allow the kernel to check
-	  typical corruption patterns.
-
-	  Leave this to the default value of 64 if you are unsure.
-
 config MATH_EMULATION
 	bool
 	depends on MODIFY_LDT_SYSCALL
@@ -2392,7 +2305,98 @@ config MODIFY_LDT_SYSCALL
 
 source "kernel/livepatch/Kconfig"
 
-endmenu
+endmenu # Processor type and features
+
+menu "Memory Management options"
+
+source "mm/Kconfig"
+
+config X86_PMEM_LEGACY_DEVICE
+	bool
+
+config X86_PMEM_LEGACY
+	tristate "Support non-standard NVDIMMs and ADR protected memory"
+	depends on PHYS_ADDR_T_64BIT
+	depends on BLK_DEV
+	select X86_PMEM_LEGACY_DEVICE
+	select LIBNVDIMM
+	help
+	  Treat memory marked using the non-standard e820 type of 12 as used
+	  by the Intel Sandy Bridge-EP reference BIOS as protected memory.
+	  The kernel will offer these regions to the 'pmem' driver so
+	  they can be used for persistent storage.
+
+	  Say Y if unsure.
+
+config HIGHPTE
+	bool "Allocate 3rd-level pagetables from highmem"
+	depends on HIGHMEM
+	---help---
+	  The VM uses one page table entry for each page of physical memory.
+	  For systems with a lot of RAM, this can be wasteful of precious
+	  low memory.  Setting this option will put user-space page table
+	  entries in high memory.
+
+config X86_CHECK_BIOS_CORRUPTION
+	bool "Check for low memory corruption"
+	---help---
+	  Periodically check for memory corruption in low memory, which
+	  is suspected to be caused by BIOS.  Even when enabled in the
+	  configuration, it is disabled at runtime.  Enable it by
+	  setting "memory_corruption_check=1" on the kernel command
+	  line.  By default it scans the low 64k of memory every 60
+	  seconds; see the memory_corruption_check_size and
+	  memory_corruption_check_period parameters in
+	  Documentation/admin-guide/kernel-parameters.rst to adjust this.
+
+	  When enabled with the default parameters, this option has
+	  almost no overhead, as it reserves a relatively small amount
+	  of memory and scans it infrequently.  It both detects corruption
+	  and prevents it from affecting the running system.
+
+	  It is, however, intended as a diagnostic tool; if repeatable
+	  BIOS-originated corruption always affects the same memory,
+	  you can use memmap= to prevent the kernel from using that
+	  memory.
+
+config X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK
+	bool "Set the default setting of memory_corruption_check"
+	depends on X86_CHECK_BIOS_CORRUPTION
+	default y
+	---help---
+	  Set whether the default state of memory_corruption_check is
+	  on or off.
+
+config X86_RESERVE_LOW
+	int "Amount of low memory, in kilobytes, to reserve for the BIOS"
+	default 64
+	range 4 640
+	---help---
+	  Specify the amount of low memory to reserve for the BIOS.
+
+	  The first page contains BIOS data structures that the kernel
+	  must not use, so that page must always be reserved.
+
+	  By default we reserve the first 64K of physical RAM, as a
+	  number of BIOSes are known to corrupt that memory range
+	  during events such as suspend/resume or monitor cable
+	  insertion, so it must not be used by the kernel.
+
+	  You can set this to 4 if you are absolutely sure that you
+	  trust the BIOS to get all its memory reservations and usages
+	  right.  If you know your BIOS have problems beyond the
+	  default 64K area, you can set this to 640 to avoid using the
+	  entire low memory range.
+
+	  If you have doubts about the BIOS (e.g. suspend/resume does
+	  not work or there's kernel crashes after certain hardware
+	  hotplug events) then you might want to enable
+	  X86_CHECK_BIOS_CORRUPTION=y to allow the kernel to check
+	  typical corruption patterns.
+
+	  Leave this to the default value of 64 if you are unsure.
+
+endmenu # MM options
 
 config ARCH_HAS_ADD_PAGES
 	def_bool y
@@ -2566,7 +2570,7 @@ source "drivers/cpuidle/Kconfig"
 
 source "drivers/idle/Kconfig"
 
-endmenu
+endmenu # Power management and ACPI options
 
 
 menu "Bus options (PCI etc.)"
@@ -2862,7 +2866,7 @@ config X86_SYSFB
 
 	  If unsure, say Y.
 
-endmenu
+endmenu # Bus options
 
 
 menu "Executable file formats / Emulations"
@@ -2919,7 +2923,7 @@ config SYSVIPC_COMPAT
 	depends on SYSVIPC
 endif
 
-endmenu
+endmenu # Executable file formats
 
 
 config HAVE_ATOMIC_IOMAP
