Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9586B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 10:55:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y84so38573323lfc.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 07:55:34 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id 124si39229095wma.104.2016.05.11.07.55.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 07:55:33 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: unhide vmstat_text definition for CONFIG_SMP
Date: Wed, 11 May 2016 16:54:55 +0200
Message-Id: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In randconfig builds with sysfs, procfs and numa all disabled,
but SMP enabled, we now get a link error in the newly introduced
vmstat_refresh function:

mm/built-in.o: In function `vmstat_refresh':
:(.text+0x15c78): undefined reference to `vmstat_text'

This modifes the already elaborate #ifdef to also cover that
configuration.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: mmotm ("mm: /proc/sys/vm/stat_refresh to force vmstat update")
---
 mm/vmstat.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 57a24e919907..5367eb9b858b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -678,7 +678,8 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 }
 #endif
 
-#if defined(CONFIG_PROC_FS) || defined(CONFIG_SYSFS) || defined(CONFIG_NUMA)
+#if defined(CONFIG_PROC_FS) || defined(CONFIG_SYSFS) || \
+    defined(CONFIG_NUMA) || defined(CONFIG_SMP)
 #ifdef CONFIG_ZONE_DMA
 #define TEXT_FOR_DMA(xx) xx "_dma",
 #else
@@ -857,7 +858,7 @@ const char * const vmstat_text[] = {
 #endif
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
-#endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
+#endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA || CONFIG_SMP */
 
 
 #if (defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)) || \
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
