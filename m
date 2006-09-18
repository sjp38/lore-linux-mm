Date: Mon, 18 Sep 2006 11:36:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060918183624.19679.78159.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
References: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/8] Introduce CONFIG_ZONE_DMA
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@SteelEye.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Russell King <rmk@arm.linux.org.uk>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Introduce CONFIG_ZONE_DMA

This patch simply defines CONFIG_ZONE_DMA for all arches. We later do
special things with CONFIG_ZONE_DMA after the VM and an arch are
prepared to work without ZONE_DMA.

CONFIG_ZONE_DMA can be defined in two ways depending on how
an architecture handles ISA DMA.

First if CONFIG_GENERIC_ISA_DMA is set by the arch then we know that
the arch needs ZONE_DMA because ISA DMA devices are supported. We
can catch this in mm/Kconfig and do not need to modify arch code.

Second, arches may use ZONE_DMA in an unknown way. We set CONFIG_ZONE_DMA
for all arches that do not set CONFIG_GENERIC_ISA_DMA in order to insure
backwards compatibility. The arches may later undefine ZONE_DMA
if their arch code has been verified to not depend on ZONE_DMA.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/mm/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/Kconfig	2006-09-15 12:17:39.778004366 -0500
+++ linux-2.6.18-rc6-mm2/mm/Kconfig	2006-09-18 12:27:12.303278031 -0500
@@ -139,6 +139,10 @@ config SPLIT_PTLOCK_CPUS
 	default "4096" if PARISC && !PA20
 	default "4"
 
+config ZONE_DMA
+	def_bool y
+	depends on GENERIC_ISA_DMA
+
 #
 # support for page migration
 #
Index: linux-2.6.18-rc6-mm2/arch/ia64/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/ia64/Kconfig	2006-09-15 12:17:39.786794169 -0500
+++ linux-2.6.18-rc6-mm2/arch/ia64/Kconfig	2006-09-18 12:27:12.361876548 -0500
@@ -22,6 +22,10 @@ config 64BIT
 	bool
 	default y
 
+config ZONE_DMA
+	bool
+	default y
+
 config MMU
 	bool
 	default y
Index: linux-2.6.18-rc6-mm2/arch/cris/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/cris/Kconfig	2006-09-15 12:17:39.795583972 -0500
+++ linux-2.6.18-rc6-mm2/arch/cris/Kconfig	2006-09-18 12:27:12.388245880 -0500
@@ -9,6 +9,10 @@ config MMU
 	bool
 	default y
 
+config ZONE_DMA
+	bool
+	default y
+
 config RWSEM_GENERIC_SPINLOCK
 	bool
 	default y
Index: linux-2.6.18-rc6-mm2/arch/s390/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/s390/Kconfig	2006-09-15 12:17:39.804373775 -0500
+++ linux-2.6.18-rc6-mm2/arch/s390/Kconfig	2006-09-18 12:27:12.426334916 -0500
@@ -7,6 +7,10 @@ config MMU
 	bool
 	default y
 
+config ZONE_DMA
+	bool
+	default y
+
 config LOCKDEP_SUPPORT
 	bool
 	default y
Index: linux-2.6.18-rc6-mm2/arch/xtensa/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/xtensa/Kconfig	2006-09-15 12:17:39.813163578 -0500
+++ linux-2.6.18-rc6-mm2/arch/xtensa/Kconfig	2006-09-18 12:27:12.459540742 -0500
@@ -7,6 +7,10 @@ config FRAME_POINTER
 	bool
 	default n
 
+config ZONE_DMA
+	bool
+	default y
+
 config XTENSA
 	bool
 	default y
Index: linux-2.6.18-rc6-mm2/arch/h8300/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/h8300/Kconfig	2006-09-15 12:17:39.820976736 -0500
+++ linux-2.6.18-rc6-mm2/arch/h8300/Kconfig	2006-09-18 12:27:12.496653135 -0500
@@ -17,6 +17,10 @@ config SWAP
 	bool
 	default n
 
+config ZONE_DMA
+	bool
+	default y
+
 config FPU
 	bool
 	default n
Index: linux-2.6.18-rc6-mm2/arch/v850/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/v850/Kconfig	2006-09-15 12:17:39.830743184 -0500
+++ linux-2.6.18-rc6-mm2/arch/v850/Kconfig	2006-09-18 12:27:12.524975752 -0500
@@ -10,6 +10,9 @@ mainmenu "uClinux/v850 (w/o MMU) Kernel 
 config MMU
        	bool
 	default n
+config ZONE_DMA
+	bool
+	default y
 config RWSEM_GENERIC_SPINLOCK
 	bool
 	default y
Index: linux-2.6.18-rc6-mm2/arch/frv/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/frv/Kconfig	2006-09-15 12:17:39.847346146 -0500
+++ linux-2.6.18-rc6-mm2/arch/frv/Kconfig	2006-09-18 12:27:12.604083749 -0500
@@ -6,6 +6,10 @@ config FRV
 	bool
 	default y
 
+config ZONE_DMA
+	bool
+	default y
+
 config RWSEM_GENERIC_SPINLOCK
 	bool
 	default y
Index: linux-2.6.18-rc6-mm2/arch/m68knommu/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/m68knommu/Kconfig	2006-09-15 12:17:39.860042528 -0500
+++ linux-2.6.18-rc6-mm2/arch/m68knommu/Kconfig	2006-09-18 12:27:12.630453081 -0500
@@ -17,6 +17,10 @@ config FPU
 	bool
 	default n
 
+config ZONE_DMA
+	bool
+	default y
+
 config RWSEM_GENERIC_SPINLOCK
 	bool
 	default y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
