Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 368B86B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 03:27:10 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f4so1709205plr.14
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 00:27:10 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id f10si1112785pge.270.2018.02.09.00.27.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 00:27:09 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH] mm/page_poison: move PAGE_POISON to page_poison.c
Date: Fri,  9 Feb 2018 16:08:14 +0800
Message-Id: <1518163694-27155-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org

The PAGE_POISON macro is used in page_poison.c only, so avoid exporting
it. Also remove the "mm/debug-pagealloc.c" related comment, which is
obsolete.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/poison.h | 7 -------
 mm/page_poison.c       | 6 ++++++
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/linux/poison.h b/include/linux/poison.h
index 15927eb..348bf67 100644
--- a/include/linux/poison.h
+++ b/include/linux/poison.h
@@ -30,13 +30,6 @@
  */
 #define TIMER_ENTRY_STATIC	((void *) 0x300 + POISON_POINTER_DELTA)
 
-/********** mm/debug-pagealloc.c **********/
-#ifdef CONFIG_PAGE_POISONING_ZERO
-#define PAGE_POISON 0x00
-#else
-#define PAGE_POISON 0xaa
-#endif
-
 /********** mm/page_alloc.c ************/
 
 #define TAIL_MAPPING	((void *) 0x400 + POISON_POINTER_DELTA)
diff --git a/mm/page_poison.c b/mm/page_poison.c
index e83fd44..8aaf076 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -7,6 +7,12 @@
 #include <linux/poison.h>
 #include <linux/ratelimit.h>
 
+#ifdef CONFIG_PAGE_POISONING_ZERO
+#define PAGE_POISON 0x00
+#else
+#define PAGE_POISON 0xaa
+#endif
+
 static bool want_page_poisoning __read_mostly;
 
 static int early_page_poison_param(char *buf)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
