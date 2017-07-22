Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4170D6B02C3
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 22:33:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n83so46217101pfa.3
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 19:33:49 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id r2si2096406plj.667.2017.07.21.19.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 19:33:48 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id y129so6622685pgy.3
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 19:33:48 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 1/1] mm/hmm: Kconfig improvements for device memory and HMM interaction
Date: Fri, 21 Jul 2017 19:33:33 -0700
Message-Id: <20170722023333.6923-2-jhubbard@nvidia.com>
In-Reply-To: <20170722023333.6923-1-jhubbard@nvidia.com>
References: <20170722023333.6923-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

The kernel's configuration for HMM is not perfect. You have to
select "device memory" in order to even see the HMM option, and
then it appears much earlier in the "make menuconfig" settings,
so it's easy to miss. Furthermore, the "device memory" option
doesn't mention that HMM requires it. So basically, HMM is
invisible unless You Know How To Reveal It.

Improve the kernel configuration experience for HMM, by:

1) Moving the HMM section of mm/Kconfig down to just below the
   ZONE_DEVICE option that is a prerequisite to HMM.

2) Adding "HMM" to the one-line Kconfig summary in ZONE_DEVICE

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/Kconfig | 52 ++++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 424ef60547f8..12007400b7d7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -262,31 +262,6 @@ config MIGRATION
 config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	bool
 
-config ARCH_HAS_HMM
-	bool
-	default y
-	depends on X86_64
-	depends on ZONE_DEVICE
-	depends on MMU && 64BIT
-	depends on MEMORY_HOTPLUG
-	depends on MEMORY_HOTREMOVE
-	depends on SPARSEMEM_VMEMMAP
-
-config HMM
-	bool
-
-config HMM_MIRROR
-	bool "HMM mirror CPU page table into a device page table"
-	depends on ARCH_HAS_HMM
-	select MMU_NOTIFIER
-	select HMM
-	help
-	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
-	  process into a device page table. Here, mirror means "keep synchronized".
-	  Prerequisites: the device must provide the ability to write-protect its
-	  page tables (at PAGE_SIZE granularity), and must be able to recover from
-	  the resulting potential page faults.
-
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
@@ -698,7 +673,7 @@ config ARCH_HAS_ZONE_DEVICE
 	bool
 
 config ZONE_DEVICE
-	bool "Device memory (pmem, etc...) hotplug support"
+	bool "Device memory (pmem, HMM, etc...) hotplug support"
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
@@ -733,6 +708,31 @@ config DEVICE_PUBLIC
 	  memory; i.e., memory that is accessible from both the device and
 	  the CPU
 
+config ARCH_HAS_HMM
+	bool
+	default y
+	depends on X86_64
+	depends on ZONE_DEVICE
+	depends on MMU && 64BIT
+	depends on MEMORY_HOTPLUG
+	depends on MEMORY_HOTREMOVE
+	depends on SPARSEMEM_VMEMMAP
+
+config HMM
+	bool
+
+config HMM_MIRROR
+	bool "HMM mirror CPU page table into a device page table"
+	depends on ARCH_HAS_HMM
+	select MMU_NOTIFIER
+	select HMM
+	help
+	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
+	  process into a device page table. Here, mirror means "keep synchronized".
+	  Prerequisites: the device must provide the ability to write-protect its
+	  page tables (at PAGE_SIZE granularity), and must be able to recover from
+	  the resulting potential page faults.
+
 config FRAME_VECTOR
 	bool
 
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
