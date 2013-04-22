Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4A48E6B0034
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:23:53 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so847034pde.18
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 08:23:52 -0700 (PDT)
From: vinayakm.list@gmail.com
Subject: [PATCH] mm: add an option to disable bounce
Date: Mon, 22 Apr 2013 20:53:00 +0530
Message-Id: <1366644180-6140-1-git-send-email-vinayakm.list@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Vinayak Menon <vinayakm.list@gmail.com>

From: Vinayak Menon <vinayakm.list@gmail.com>

There are times when HIGHMEM is enabled, but
we don't prefer CONFIG_BOUNCE to be enabled.
CONFIG_BOUNCE can reduce the block device
throughput, and this is not ideal for machines
where we don't gain much by enabling it. So
provide an option to deselect CONFIG_BOUNCE. The
observation was made while measuring eMMC throughput
using iozone on an ARM device with 1GB RAM.

Signed-off-by: Vinayak Menon <vinayakm.list@gmail.com>
---
 mm/Kconfig |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 3bea74f..29f9736 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -263,8 +263,14 @@ config ZONE_DMA_FLAG
 	default "1"
 
 config BOUNCE
+	bool "Enable bounce buffers"
 	def_bool y
 	depends on BLOCK && MMU && (ZONE_DMA || HIGHMEM)
+	help
+	  Enable bounce buffers for devices that cannot access
+	  the full range of memory available to the CPU. Enabled
+	  by default when ZONE_DMA or HIGMEM is selected, but you
+	  may say n to override this.
 
 # On the 'tile' arch, USB OHCI needs the bounce pool since tilegx will often
 # have more than 4GB of memory, but we don't currently use the IOTLB to present
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
