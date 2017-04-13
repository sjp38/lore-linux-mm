Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4116B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 01:17:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f5so26079020pff.13
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 22:17:26 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id h1si20385034plh.227.2017.04.12.22.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 22:17:25 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 34so6143827pgx.3
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 22:17:24 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH v2] mm, x86: Add ARCH_HAS_ZONE_DEVICE to Kconfig
Date: Thu, 13 Apr 2017 15:17:14 +1000
Message-Id: <20170413051714.25267-1-oohall@gmail.com>
In-Reply-To: <20170413021940.17649-1-oohall@gmail.com>
References: <20170413021940.17649-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org

Currently ZONE_DEVICE depends on X86_64 and this will get unwieldly as
new architectures (and platforms) get ZONE_DEVICE support. Move to an
arch selected Kconfig option to save us the trouble.

Cc: linux-mm@kvack.org
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
v2: add missing hunk
---
 arch/x86/Kconfig | 1 +
 mm/Kconfig       | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c43f47622440..535b4d514792 100644
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
index c89f472b658c..392bf8d7574c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -684,12 +684,16 @@ config IDLE_PAGE_TRACKING
 
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
