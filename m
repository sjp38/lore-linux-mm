Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E6B116B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 16:49:24 -0400 (EDT)
Message-ID: <201206162049.q5GKnN74019488@farm-0002.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Sat, 16 Jun 2012 16:41:05 -0400
Subject: [PATCH 3/3] bounce: allow use of bounce pool via config option
In-Reply-To: <201206162048.q5GKm1rt019464@farm-0002.internal.tilera.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-usb@vger.kernel.org

The tilegx USB OHCI support needs the bounce pool since we're not
using the IOMMU to handle 32-bit addresses.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/Kconfig |    6 ++++++
 mm/bounce.c       |    8 +++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/arch/tile/Kconfig b/arch/tile/Kconfig
index cf4bb69e..932e443 100644
--- a/arch/tile/Kconfig
+++ b/arch/tile/Kconfig
@@ -406,6 +406,12 @@ config TILE_USB
 	  Provides USB host adapter support for the built-in EHCI and OHCI
 	  interfaces on TILE-Gx chips.
 
+# USB OHCI needs the bounce pool since tilegx will often have more
+# than 4GB of memory, but we don't currently use the IOTLB to present
+# a 32-bit address to OHCI.  So we need to use a bounce pool instead.
+config NEED_BOUNCE_POOL
+	def_bool USB_OHCI_HCD
+
 config HOTPLUG
 	bool "Support for hot-pluggable devices"
 	---help---
diff --git a/mm/bounce.c b/mm/bounce.c
index d1be02c..0420867 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -24,23 +24,25 @@
 
 static mempool_t *page_pool, *isa_page_pool;
 
-#ifdef CONFIG_HIGHMEM
+#if defined(CONFIG_HIGHMEM) || defined(CONFIG_NEED_BOUNCE_POOL)
 static __init int init_emergency_pool(void)
 {
-#ifndef CONFIG_MEMORY_HOTPLUG
+#if defined(CONFIG_HIGHMEM) && !defined(CONFIG_MEMORY_HOTPLUG)
 	if (max_pfn <= max_low_pfn)
 		return 0;
 #endif
 
 	page_pool = mempool_create_page_pool(POOL_SIZE, 0);
 	BUG_ON(!page_pool);
-	printk("highmem bounce pool size: %d pages\n", POOL_SIZE);
+	printk("bounce pool size: %d pages\n", POOL_SIZE);
 
 	return 0;
 }
 
 __initcall(init_emergency_pool);
+#endif
 
+#ifdef CONFIG_HIGHMEM
 /*
  * highmem version, map in to vec
  */
-- 
1.7.10.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
