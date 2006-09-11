Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8C154wc011651
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:05:04 -0700
Date: Mon, 11 Sep 2006 15:30:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060911223022.5032.84395.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
References: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/6] Optional ZONE_DMA for i386
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

ZONE_DMA depends on GENERIC_ISA_DMA. We allow the user to configure
GENERIC_ISA_DMA. If it is switched off then ISA_DMA_API is also
switched off which will deselect all drivers that depend on ISA
functionality.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm1/arch/i386/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/i386/Kconfig	2006-09-08 06:42:11.697455315 -0500
+++ linux-2.6.18-rc6-mm1/arch/i386/Kconfig	2006-09-11 15:41:55.911259588 -0500
@@ -41,10 +41,6 @@
 config SBUS
 	bool
 
-config GENERIC_ISA_DMA
-	bool
-	default y
-
 config GENERIC_IOMAP
 	bool
 	default y
@@ -346,6 +342,15 @@
           XFree86 to initialize some video cards via BIOS. Disabling this
           option saves about 6k.
 
+config GENERIC_ISA_DMA
+	bool "ISA DMA zone (to support ISA legacy DMA)"
+	default y
+	help
+	  If DMA for ISA boards needs to be supported then this option
+	  needs to be enabled. An additional DMA zone for <16MB memory
+	  will be created and memory below 16MB will be used for those
+	  devices.
+
 config TOSHIBA
 	tristate "Toshiba Laptop support"
 	---help---
@@ -1071,6 +1076,7 @@
 
 config ISA_DMA_API
 	bool
+	depends on GENERIC_ISA_DMA
 	default y
 
 config ISA
Index: linux-2.6.18-rc6-mm1/arch/i386/kernel/Makefile
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/i386/kernel/Makefile	2006-09-08 06:42:11.780470103 -0500
+++ linux-2.6.18-rc6-mm1/arch/i386/kernel/Makefile	2006-09-11 15:41:55.950325419 -0500
@@ -7,8 +7,9 @@
 obj-y	:= process.o signal.o entry.o traps.o irq.o \
 		ptrace.o time.o ioport.o ldt.o setup.o i8259.o sys_i386.o \
 		pci-dma.o i386_ksyms.o i387.o bootflag.o \
-		quirks.o i8237.o topology.o alternative.o i8253.o tsc.o
+		quirks.o topology.o alternative.o i8253.o tsc.o
 
+obj-$(CONFIG_GENERIC_ISA_DMA)	+= i8237.o
 obj-$(CONFIG_STACKTRACE)	+= stacktrace.o
 obj-y				+= cpu/
 obj-y				+= acpi/
Index: linux-2.6.18-rc6-mm1/arch/i386/kernel/setup.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/i386/kernel/setup.c	2006-09-08 06:42:12.269769024 -0500
+++ linux-2.6.18-rc6-mm1/arch/i386/kernel/setup.c	2006-09-11 15:41:55.982554730 -0500
@@ -1075,13 +1075,17 @@
 {
 #ifdef CONFIG_HIGHMEM
 	unsigned long max_zone_pfns[MAX_NR_ZONES] = {
+#ifdef CONFIG_ZONE_DMA
 			virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT,
+#endif
 			max_low_pfn,
 			highend_pfn};
 	add_active_range(0, 0, highend_pfn);
 #else
 	unsigned long max_zone_pfns[MAX_NR_ZONES] = {
+#ifdef CONFIG_ZONE_DMA
 			virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT,
+#endif
 			max_low_pfn};
 	add_active_range(0, 0, max_low_pfn);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
