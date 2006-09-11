Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8BMUSnx008271
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 17:30:28 -0500
Date: Mon, 11 Sep 2006 15:30:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060911223027.5032.789.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
References: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/6] Optional ZONE_DMA for x86_64
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Allow the use to specify CONFIG_ZONE_DMA32 and CONFIG_ZONE_DMA (via
CONFIG_GENERIC_ISA_DMA).

If CONFIG_ZONE_DMA is off then devices requiring ISA DMA can no
longer be selected.

There are no drivers depending on CONFIG_ZONE_DMA32. If CONFIG_ZONE_DMA32
is not set then the system assumes that DMA devices are capable of
doing DMA to all of memory (which is mostly the case since most
x86_64 motherboards only allow a max of 4GB of memory and advanced
systems have DMA subsystems that handle I/O properly).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm1/arch/x86_64/mm/init.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/x86_64/mm/init.c	2006-09-11 16:06:41.705747849 -0500
+++ linux-2.6.18-rc6-mm1/arch/x86_64/mm/init.c	2006-09-11 16:08:13.190088058 -0500
@@ -406,9 +406,15 @@
 #ifndef CONFIG_NUMA
 void __init paging_init(void)
 {
-	unsigned long max_zone_pfns[MAX_NR_ZONES] = {MAX_DMA_PFN,
-							MAX_DMA32_PFN,
-							end_pfn};
+	unsigned long max_zone_pfns[MAX_NR_ZONES] = {
+#ifdef CONFIG_ZONE_DMA
+		MAX_DMA_PFN,
+#endif
+#ifdef CONFIG_ZONE_DMA32
+		MAX_DMA32_PFN,
+#endif
+		end_pfn
+	};
 	memory_present(0, 0, end_pfn);
 	sparse_init();
 	free_area_init_nodes(max_zone_pfns);
Index: linux-2.6.18-rc6-mm1/arch/x86_64/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/x86_64/Kconfig	2006-09-11 16:06:41.713561013 -0500
+++ linux-2.6.18-rc6-mm1/arch/x86_64/Kconfig	2006-09-11 16:10:45.369039566 -0500
@@ -24,10 +24,6 @@
 	bool
 	default y
 
-config ZONE_DMA32
-	bool
-	default y
-
 config LOCKDEP_SUPPORT
 	bool
 	default y
@@ -73,10 +69,6 @@
 	bool
 	default y
 
-config GENERIC_ISA_DMA
-	bool
-	default y
-
 config GENERIC_IOMAP
 	bool
 	default y
@@ -251,6 +243,24 @@
 
 	  See <file:Documentation/mtrr.txt> for more information.
 
+config ZONE_DMA32
+	bool "32 Bit DMA Zone (only needed if memory >4GB)"
+	default y
+	help
+	  Some x64 configurations have 32 bit DMA controllers that cannot
+	  write to all of memory. If you have one of these and you have RAM
+	  beyond the 4GB boundary then enable this option.
+
+config GENERIC_ISA_DMA
+	bool "ISA DMA zone (to support ISA legacy DMA)"
+	default y
+	help
+	  If DMA for ISA boards needs to be supported then this option
+	  needs to be enabled. An additional DMA zone for <16MB memory
+	  will be created and memory below 16MB will be used for those
+	  devices. If this is deselected then devices that use ISA
+	  DMA will not be selectable.
+
 config SMP
 	bool "Symmetric multi-processing support"
 	---help---
@@ -611,6 +621,7 @@
 # we have no ISA slots, but we do have ISA-style DMA.
 config ISA_DMA_API
 	bool
+	depends on GENERIC_ISA_DMA
 	default y
 
 config GENERIC_PENDING_IRQ
Index: linux-2.6.18-rc6-mm1/arch/x86_64/kernel/Makefile
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/x86_64/kernel/Makefile	2006-09-11 16:06:41.726257405 -0500
+++ linux-2.6.18-rc6-mm1/arch/x86_64/kernel/Makefile	2006-09-11 16:08:13.214504197 -0500
@@ -7,9 +7,10 @@
 obj-y	:= process.o signal.o entry.o traps.o irq.o \
 		ptrace.o time.o ioport.o ldt.o setup.o i8259.o sys_x86_64.o \
 		x8664_ksyms.o i387.o syscall.o vsyscall.o \
-		setup64.o bootflag.o e820.o reboot.o quirks.o i8237.o \
+		setup64.o bootflag.o e820.o reboot.o quirks.o \
 		pci-dma.o pci-nommu.o alternative.o early-quirks.o
 
+obj-$(CONFIG_GENERIC_ISA_DMA)	+= i8237.o
 obj-$(CONFIG_STACKTRACE)	+= stacktrace.o
 obj-$(CONFIG_X86_MCE)         += mce.o
 obj-$(CONFIG_X86_MCE_INTEL)	+= mce_intel.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
