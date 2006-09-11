Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8C14rUO011563
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:04:53 -0700
Date: Mon, 11 Sep 2006 15:30:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060911223012.5032.53231.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
References: <20060911223001.5032.24593.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/6] Introduce CONFIG_ZONE_DMA
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>
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

Index: linux-2.6.18-rc6-mm1/mm/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/mm/Kconfig	2006-09-11 15:42:32.736665338 -0500
+++ linux-2.6.18-rc6-mm1/mm/Kconfig	2006-09-11 15:53:12.072397960 -0500
@@ -139,6 +139,10 @@
 	default "4096" if PARISC && !PA20
 	default "4"
 
+config ZONE_DMA
+	def_bool y
+	depends on GENERIC_ISA_DMA
+
 #
 # support for page migration
 #
Index: linux-2.6.18-rc6-mm1/arch/ia64/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/ia64/Kconfig	2006-09-11 15:42:32.746431796 -0500
+++ linux-2.6.18-rc6-mm1/arch/ia64/Kconfig	2006-09-11 15:53:12.089977582 -0500
@@ -22,6 +22,10 @@
 	bool
 	default y
 
+config ZONE_DMA
+	bool
+	default y
+
 config MMU
 	bool
 	default y
Index: linux-2.6.18-rc6-mm1/arch/cris/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/cris/Kconfig	2006-09-11 15:42:32.754244962 -0500
+++ linux-2.6.18-rc6-mm1/arch/cris/Kconfig	2006-09-11 15:53:12.101697331 -0500
@@ -9,6 +9,10 @@
 	bool
 	default y
 
+config ZONE_DMA
+	bool
+	default y
+
 config RWSEM_GENERIC_SPINLOCK
 	bool
 	default y
Index: linux-2.6.18-rc6-mm1/arch/s390/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/s390/Kconfig	2006-09-11 15:42:32.764988066 -0500
+++ linux-2.6.18-rc6-mm1/arch/s390/Kconfig	2006-09-11 15:53:12.112440433 -0500
@@ -7,6 +7,10 @@
 	bool
 	default y
 
+config ZONE_DMA
+	bool
+	default y
+
 config LOCKDEP_SUPPORT
 	bool
 	default y
Index: linux-2.6.18-rc6-mm1/arch/xtensa/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/xtensa/Kconfig	2006-09-11 15:42:32.773777878 -0500
+++ linux-2.6.18-rc6-mm1/arch/xtensa/Kconfig	2006-09-11 15:53:12.124160181 -0500
@@ -7,6 +7,10 @@
 	bool
 	default n
 
+config ZONE_DMA
+	bool
+	default y
+
 config XTENSA
 	bool
 	default y
Index: linux-2.6.18-rc6-mm1/arch/h8300/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/h8300/Kconfig	2006-09-11 15:42:32.782567690 -0500
+++ linux-2.6.18-rc6-mm1/arch/h8300/Kconfig	2006-09-11 15:53:12.134903284 -0500
@@ -17,6 +17,10 @@
 	bool
 	default n
 
+config ZONE_DMA
+	bool
+	default y
+
 config FPU
 	bool
 	default n
Index: linux-2.6.18-rc6-mm1/arch/v850/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/v850/Kconfig	2006-09-11 15:42:32.791357502 -0500
+++ linux-2.6.18-rc6-mm1/arch/v850/Kconfig	2006-09-11 15:53:12.145646386 -0500
@@ -10,6 +10,9 @@
 config MMU
        	bool
 	default n
+config ZONE_DMA
+	bool
+	default y
 config RWSEM_GENERIC_SPINLOCK
 	bool
 	default y
Index: linux-2.6.18-rc6-mm1/arch/sh/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/sh/Kconfig	2006-09-11 15:42:32.800147314 -0500
+++ linux-2.6.18-rc6-mm1/arch/sh/Kconfig	2006-09-11 15:53:12.158342780 -0500
@@ -14,6 +14,10 @@
 	  gaming console.  The SuperH port has a home page at
 	  <http://www.linux-sh.org/>.
 
+config ZONE_DMA
+	bool
+	default y
+
 config RWSEM_GENERIC_SPINLOCK
 	bool
 	default y
Index: linux-2.6.18-rc6-mm1/arch/frv/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/frv/Kconfig	2006-09-11 15:42:32.808937126 -0500
+++ linux-2.6.18-rc6-mm1/arch/frv/Kconfig	2006-09-11 15:53:12.171039174 -0500
@@ -6,6 +6,10 @@
 	bool
 	default y
 
+config ZONE_DMA
+	bool
+	default y
+
 config RWSEM_GENERIC_SPINLOCK
 	bool
 	default y
Index: linux-2.6.18-rc6-mm1/arch/m68knommu/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm1.orig/arch/m68knommu/Kconfig	2006-09-11 15:42:32.820656875 -0500
+++ linux-2.6.18-rc6-mm1/arch/m68knommu/Kconfig	2006-09-11 15:53:12.183735568 -0500
@@ -17,6 +17,10 @@
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
