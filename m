Date: Thu, 28 Dec 2006 23:05:55 -0200
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: [PATCH 1/2] optional GENERIC_ISA_DMA 
Message-ID: <20061229010555.GA1116@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>, Andi Kleen <ak@suse.de>, Arjan van de Ven <arjan@infradead.org>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following patch makes CONFIG_GENERIC_ISA_DMA/ISA_DMA_API a configure
option.

Newer/embedded systems usually do not have an ISA bus: kernel/dma.o and
arch/i386/kernel/i8237.o are dead code on such systems.

This is a preparation for the second patch: allow ZONE_DMA to be unset
on x86.

Against 2.6.20-rc2-mm1, on top of Christoph's ZONE_DMA work.

--- ./arch/i386/kernel/Makefile.orig	2006-12-28 22:56:50.000000000 -0200
+++ ./arch/i386/kernel/Makefile	2006-12-28 22:56:58.000000000 -0200
@@ -7,13 +7,14 @@
 obj-y	:= process.o signal.o entry.o traps.o irq.o \
 		ptrace.o time.o ioport.o ldt.o setup.o i8259.o sys_i386.o \
 		pci-dma.o i386_ksyms.o i387.o bootflag.o e820.o\
-		quirks.o i8237.o topology.o alternative.o i8253.o tsc.o
+		quirks.o topology.o alternative.o i8253.o tsc.o
 
 obj-$(CONFIG_STACKTRACE)	+= stacktrace.o
 obj-y				+= cpu/
 obj-y				+= acpi/
 obj-$(CONFIG_X86_BIOS_REBOOT)	+= reboot.o
 obj-$(CONFIG_MCA)		+= mca.o
+obj-$(CONFIG_GENERIC_ISA_DMA)	+= i8237.o
 obj-$(CONFIG_X86_MSR)		+= msr.o
 obj-$(CONFIG_X86_CPUID)		+= cpuid.o
 obj-$(CONFIG_MICROCODE)		+= microcode.o
--- ./arch/i386/Kconfig.orig	2006-12-28 22:56:43.000000000 -0200
+++ ./arch/i386/Kconfig	2006-12-28 22:58:14.000000000 -0200
@@ -53,10 +53,6 @@
 config SBUS
 	bool
 
-config GENERIC_ISA_DMA
-	bool
-	default y
-
 config GENERIC_IOMAP
 	bool
 	default y
@@ -1134,11 +1130,12 @@
 
 config ISA_DMA_API
 	bool
-	default y
+	default n
 
 config ISA
 	bool "ISA support"
 	depends on !(X86_VOYAGER || X86_VISWS)
+	select GENERIC_ISA_DMA
 	help
 	  Find out whether you have ISA slots on your motherboard.  ISA is the
 	  name of a bus system, i.e. the way the CPU talks to the other stuff
@@ -1146,6 +1143,21 @@
 	  (MCA) or VESA.  ISA is an older system, now being displaced by PCI;
 	  newer boards don't support it.  If you have ISA, say Y, otherwise N.
 
+config GENERIC_ISA_DMA
+	bool "ISA DMA API"
+	select ISA_DMA_API
+	default y
+	help
+	  This enables support for the ISA DMA API, which provides DMA
+	  channel management. Its automatically selected by CONFIG_ISA.
+
+	  Say N here if you do not have ISA devices on your x86 system.
+	  Doing so might disable the DMA zone (0-16MiB), which simplifies 
+	  virtual memory management.
+
+	  If unsure, say Y.
+
+
 config EISA
 	bool "EISA support"
 	depends on ISA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
