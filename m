Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 3EC766B00DA
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 23:15:25 -0500 (EST)
From: liguang <lig.fnst@cn.fujitsu.com>
Subject: [PATCH] mm: break circular include from linux/mmzone.h
Date: Tue, 5 Feb 2013 12:15:07 +0800
Message-Id: <1360037707-13935-1-git-send-email-lig.fnst@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: liguang <lig.fnst@cn.fujitsu.com>

linux/mmzone.h included linux/memory_hotplug.h,
and linux/memory_hotplug.h also included
linux/mmzone.h, so there's a bad cirlular.

Signed-off-by: liguang <lig.fnst@cn.fujitsu.com>
---
 drivers/hwmon/coretemp.c    |    2 ++
 drivers/hwmon/via-cputemp.c |    2 ++
 include/linux/mmzone.h      |    1 -
 kernel/cpu.c                |    1 +
 kernel/smp.c                |    1 +
 lib/show_mem.c              |    1 +
 mm/memory_hotplug.c         |    1 +
 mm/nobootmem.c              |    1 +
 mm/sparse.c                 |    1 +
 9 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/hwmon/coretemp.c b/drivers/hwmon/coretemp.c
index d64923d..9a90a3b 100644
--- a/drivers/hwmon/coretemp.c
+++ b/drivers/hwmon/coretemp.c
@@ -36,6 +36,8 @@
 #include <linux/cpu.h>
 #include <linux/smp.h>
 #include <linux/moduleparam.h>
+#include <linux/notifier.h>
+
 #include <asm/msr.h>
 #include <asm/processor.h>
 #include <asm/cpu_device_id.h>
diff --git a/drivers/hwmon/via-cputemp.c b/drivers/hwmon/via-cputemp.c
index 76f157b..2aab52f 100644
--- a/drivers/hwmon/via-cputemp.c
+++ b/drivers/hwmon/via-cputemp.c
@@ -35,6 +35,8 @@
 #include <linux/list.h>
 #include <linux/platform_device.h>
 #include <linux/cpu.h>
+#include <linux/notifier.h>
+
 #include <asm/msr.h>
 #include <asm/processor.h>
 #include <asm/cpu_device_id.h>
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 73b64a3..9ca72f4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -758,7 +758,6 @@ typedef struct pglist_data {
 	__pgdat->node_start_pfn + __pgdat->node_spanned_pages;\
 })
 
-#include <linux/memory_hotplug.h>
 
 extern struct mutex zonelists_mutex;
 void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 3046a50..e6e53e6 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -19,6 +19,7 @@
 #include <linux/mutex.h>
 #include <linux/gfp.h>
 #include <linux/suspend.h>
+#include <linux/memory_hotplug.h>
 
 #include "smpboot.h"
 
diff --git a/kernel/smp.c b/kernel/smp.c
index 29dd40a..6f4d485 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -12,6 +12,7 @@
 #include <linux/gfp.h>
 #include <linux/smp.h>
 #include <linux/cpu.h>
+#include <linux/notifier.h>
 
 #include "smpboot.h"
 
diff --git a/lib/show_mem.c b/lib/show_mem.c
index 4407f8c..7c90021 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -6,6 +6,7 @@
  */
 
 #include <linux/mm.h>
+#include <linux/memory_hotplug.h>
 #include <linux/nmi.h>
 #include <linux/quicklist.h>
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d04ed87..5a73123 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -29,6 +29,7 @@
 #include <linux/suspend.h>
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
+#include <linux/notifier.h>
 
 #include <asm/tlbflush.h>
 
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index b8294fc..36c1547 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -16,6 +16,7 @@
 #include <linux/kmemleak.h>
 #include <linux/range.h>
 #include <linux/memblock.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/bug.h>
 #include <asm/io.h>
diff --git a/mm/sparse.c b/mm/sparse.c
index 6b5fb76..1b407d5 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -13,6 +13,7 @@
 #include <asm/dma.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
+#include <linux/memory_hotplug.h>
 
 /*
  * Permanent SPARSEMEM data:
-- 
1.7.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
