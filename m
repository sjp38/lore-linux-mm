Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4D5E6B03A9
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:31:58 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 33so37593087pgx.14
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:31:58 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id p188si2834789pga.470.2017.06.23.01.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:31:57 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id s66so6425640pfs.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:31:57 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH v3 1/6] mm, x86: Add ARCH_HAS_ZONE_DEVICE to Kconfig
Date: Fri, 23 Jun 2017 18:31:17 +1000
Message-Id: <20170623083122.5992-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: bsingharora@gmail.com, Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org

Currently ZONE_DEVICE depends on X86_64 and this will get unwieldly as
new architectures (and platforms) get ZONE_DEVICE support. Move to an
arch selected Kconfig option to save us the trouble.

Cc: linux-mm@kvack.org
Acked-by: Ingo Molnar <mingo@kernel.org>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
v2: Added missing hunk.
v3: No changes
---
 arch/x86/Kconfig | 1 +
 mm/Kconfig       | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0efb4c9497bc..325429a3f32f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -59,6 +59,7 @@ config X86
 	select ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_HAS_ZONE_DEVICE		if X86_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
 	select ARCH_MIGHT_HAVE_PC_PARPORT
diff --git a/mm/Kconfig b/mm/Kconfig
index beb7a455915d..790e52a8a486 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -683,12 +683,16 @@ config IDLE_PAGE_TRACKING
 
 	  See Documentation/vm/idle_page_tracking.txt for more details.
 
+# arch_add_memory() comprehends device memory
+config ARCH_HAS_ZONE_DEVICE
+	bool
+
 config ZONE_DEVICE
 	bool "Device memory (pmem, etc...) hotplug support"
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
-	depends on X86_64 #arch_add_memory() comprehends device memory
+	depends on ARCH_HAS_ZONE_DEVICE
 
 	help
 	  Device memory hotplug support allows for establishing pmem,
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
