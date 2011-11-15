Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80C8E6B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 18:49:35 -0500 (EST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCH] kmemleak: Add support for memory hotplug
Date: Tue, 15 Nov 2011 15:49:09 -0800
Message-Id: <1321400949-1852-2-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1321400949-1852-1-git-send-email-lauraa@codeaurora.org>
References: <1321400949-1852-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, mingo@elte.hu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>

Ensure that memory hotplug can co-exist with kmemleak
by taking the hotplug lock before scanning the memory
banks.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 lib/Kconfig.debug |    2 +-
 mm/kmemleak.c     |    6 ++++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c6b006a..6a9e368 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -413,7 +413,7 @@ config SLUB_STATS
 
 config DEBUG_KMEMLEAK
 	bool "Kernel memory leak detector"
-	depends on DEBUG_KERNEL && EXPERIMENTAL && !MEMORY_HOTPLUG && \
+	depends on DEBUG_KERNEL && EXPERIMENTAL && \
 		(X86 || ARM || PPC || MIPS || S390 || SPARC64 || SUPERH || MICROBLAZE || TILE)
 
 	select DEBUG_FS
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index aacee45..4facb03 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -100,6 +100,7 @@
 
 #include <linux/kmemcheck.h>
 #include <linux/kmemleak.h>
+#include <linux/memory_hotplug.h>
 
 /*
  * Kmemleak configuration and common defines.
@@ -1220,9 +1221,9 @@ static void kmemleak_scan(void)
 #endif
 
 	/*
-	 * Struct page scanning for each node. The code below is not yet safe
-	 * with MEMORY_HOTPLUG.
+	 * Struct page scanning for each node.
 	 */
+	lock_memory_hotplug();
 	for_each_online_node(i) {
 		pg_data_t *pgdat = NODE_DATA(i);
 		unsigned long start_pfn = pgdat->node_start_pfn;
@@ -1241,6 +1242,7 @@ static void kmemleak_scan(void)
 			scan_block(page, page + 1, NULL, 1);
 		}
 	}
+	unlock_memory_hotplug();
 
 	/*
 	 * Scanning the task stacks (may introduce false negatives).
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
