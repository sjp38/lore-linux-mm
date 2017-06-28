Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 783476B0292
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 21:32:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v62so42299401pfd.10
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 18:32:51 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id q13si583134plk.482.2017.06.27.18.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 18:32:50 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id u36so6225610pgn.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 18:32:50 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH v4 1/6] mm, x86: Add ARCH_HAS_ZONE_DEVICE to Kconfig
Date: Wed, 28 Jun 2017 11:32:31 +1000
Message-Id: <20170628013236.413-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org

Currently ZONE_DEVICE depends on X86_64 and this will get unwieldly as
new architectures (and platforms) get ZONE_DEVICE support. Move to an
arch selected Kconfig option to save us the trouble.

Cc: linux-mm@kvack.org
Acked-by: Ingo Molnar <mingo@kernel.org>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
Andew, the rest of the series should be going in via the ppc tree, but
since there's nothing ppc specific about this patch do you want to
take it via mm?
--
v2: Added missing hunk.
---
 arch/x86/Kconfig | 1 +
 mm/Kconfig       | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 37a14d7a4e3f..569e39a8293d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -61,6 +61,7 @@ config X86
 	select ARCH_HAS_STRICT_KERNEL_RWX
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_HAS_ZONE_DEVICE		if X86_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
 	select ARCH_MIGHT_HAVE_PC_PARPORT
diff --git a/mm/Kconfig b/mm/Kconfig
index 5027cbc251f9..48b1af447fa7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -668,12 +668,16 @@ config IDLE_PAGE_TRACKING
 
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
