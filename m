Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 730D36B0273
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 04:29:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l17-v6so4317825edq.11
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 01:29:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y95-v6si5771221ede.17.2018.07.06.01.29.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 01:29:28 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w668SvjQ137125
	for <linux-mm@kvack.org>; Fri, 6 Jul 2018 04:29:26 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k21j3ysqp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 06 Jul 2018 04:29:26 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 6 Jul 2018 04:29:25 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH 1/2] mm/nvidmm: Drop x86 dependency on nvdimm e820 device
Date: Fri,  6 Jul 2018 13:59:10 +0530
Message-Id: <20180706082911.13405-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>, Oliver <oohall@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

This patch adds new Kconfig variable PMEM_PLATFORM_DEVICE and use that to select
the nvdimm e820 device. The x86 config is now named X86_PMEM_LEGACY_DEVICE.

Not-Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/x86/Kconfig                  | 5 +----
 arch/x86/include/asm/e820/types.h | 2 +-
 arch/x86/include/uapi/asm/e820.h  | 2 +-
 drivers/nvdimm/Kconfig            | 5 ++++-
 drivers/nvdimm/Makefile           | 2 +-
 tools/testing/nvdimm/Kbuild       | 2 +-
 6 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index f1dbb4ee19d7..1186e1330876 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1641,13 +1641,10 @@ config ILLEGAL_POINTER_VALUE
 source "mm/Kconfig"
 
 config X86_PMEM_LEGACY_DEVICE
-	bool
-
-config X86_PMEM_LEGACY
 	tristate "Support non-standard NVDIMMs and ADR protected memory"
 	depends on PHYS_ADDR_T_64BIT
 	depends on BLK_DEV
-	select X86_PMEM_LEGACY_DEVICE
+	select PMEM_PLATFORM_DEVICE
 	select LIBNVDIMM
 	help
 	  Treat memory marked using the non-standard e820 type of 12 as used
diff --git a/arch/x86/include/asm/e820/types.h b/arch/x86/include/asm/e820/types.h
index c3aa4b5e49e2..0fb25d04dd26 100644
--- a/arch/x86/include/asm/e820/types.h
+++ b/arch/x86/include/asm/e820/types.h
@@ -20,7 +20,7 @@ enum e820_type {
 	 * NVDIMM regions that persist over a reboot.
 	 *
 	 * The kernel will ignore their special capabilities
-	 * unless the CONFIG_X86_PMEM_LEGACY=y option is set.
+	 * unless the CONFIG_X86_PMEM_LEGACY_DEVICE=y option is set.
 	 *
 	 * ( Note that older platforms also used 6 for the same
 	 *   type of memory, but newer versions switched to 12 as
diff --git a/arch/x86/include/uapi/asm/e820.h b/arch/x86/include/uapi/asm/e820.h
index 2f491efe3a12..b8ae7c221269 100644
--- a/arch/x86/include/uapi/asm/e820.h
+++ b/arch/x86/include/uapi/asm/e820.h
@@ -38,7 +38,7 @@
 /*
  * This is a non-standardized way to represent ADR or NVDIMM regions that
  * persist over a reboot.  The kernel will ignore their special capabilities
- * unless the CONFIG_X86_PMEM_LEGACY option is set.
+ * unless the CONFIG_X86_PMEM_LEGACY_DEVICE option is set.
  *
  * ( Note that older platforms also used 6 for the same type of memory,
  *   but newer versions switched to 12 as 6 was assigned differently.  Some
diff --git a/drivers/nvdimm/Kconfig b/drivers/nvdimm/Kconfig
index 9d36473dc2a2..50d2a33de441 100644
--- a/drivers/nvdimm/Kconfig
+++ b/drivers/nvdimm/Kconfig
@@ -27,7 +27,7 @@ config BLK_DEV_PMEM
 	  Memory ranges for PMEM are described by either an NFIT
 	  (NVDIMM Firmware Interface Table, see CONFIG_NFIT_ACPI), a
 	  non-standard OEM-specific E820 memory type (type-12, see
-	  CONFIG_X86_PMEM_LEGACY), or it is manually specified by the
+	  CONFIG_X86_PMEM_LEGACY_DEVICE), or it is manually specified by the
 	  'memmap=nn[KMG]!ss[KMG]' kernel command line (see
 	  Documentation/admin-guide/kernel-parameters.rst).  This driver converts
 	  these persistent memory ranges into block devices that are
@@ -112,4 +112,7 @@ config OF_PMEM
 
 	  Select Y if unsure.
 
+config PMEM_PLATFORM_DEVICE
+       bool
+
 endif
diff --git a/drivers/nvdimm/Makefile b/drivers/nvdimm/Makefile
index e8847045dac0..94f7f29146ce 100644
--- a/drivers/nvdimm/Makefile
+++ b/drivers/nvdimm/Makefile
@@ -3,7 +3,7 @@ obj-$(CONFIG_LIBNVDIMM) += libnvdimm.o
 obj-$(CONFIG_BLK_DEV_PMEM) += nd_pmem.o
 obj-$(CONFIG_ND_BTT) += nd_btt.o
 obj-$(CONFIG_ND_BLK) += nd_blk.o
-obj-$(CONFIG_X86_PMEM_LEGACY) += nd_e820.o
+obj-$(CONFIG_PMEM_PLATFORM_DEVICE) += nd_e820.o
 obj-$(CONFIG_OF_PMEM) += of_pmem.o
 
 nd_pmem-y := pmem.o
diff --git a/tools/testing/nvdimm/Kbuild b/tools/testing/nvdimm/Kbuild
index 0392153a0009..82e84253a6ae 100644
--- a/tools/testing/nvdimm/Kbuild
+++ b/tools/testing/nvdimm/Kbuild
@@ -27,7 +27,7 @@ obj-$(CONFIG_LIBNVDIMM) += libnvdimm.o
 obj-$(CONFIG_BLK_DEV_PMEM) += nd_pmem.o
 obj-$(CONFIG_ND_BTT) += nd_btt.o
 obj-$(CONFIG_ND_BLK) += nd_blk.o
-obj-$(CONFIG_X86_PMEM_LEGACY) += nd_e820.o
+obj-$(CONFIG_PMEM_PLATFORM_DEVICE) += nd_e820.o
 obj-$(CONFIG_ACPI_NFIT) += nfit.o
 ifeq ($(CONFIG_DAX),m)
 obj-$(CONFIG_DAX) += dax.o
-- 
2.17.1
