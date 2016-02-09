Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id EFFFC6B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 09:15:45 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id g62so176285496wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 06:15:45 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.134])
        by mx.google.com with ESMTPS id m4si23381357wmf.116.2016.02.09.06.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 06:15:44 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: mm, compaction: fix build errors with kcompactd
Date: Tue, 09 Feb 2016 15:15:39 +0100
Message-ID: <9230470.QhrU67iB7h@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

The newly added kcompactd code introduces multiple build errors:

include/linux/compaction.h:91:12: error: 'kcompactd_run' defined but not used [-Werror=unused-function]
mm/compaction.c:1953:2: error: implicit declaration of function 'hotcpu_notifier' [-Werror=implicit-function-declaration]

This marks the new empty wrapper functions as 'inline' to avoid unused-function warnings,
and includes linux/cpu.h to get the hotcpu_notifier declaration.

Fixes: 8364acdfa45a ("mm, compaction: introduce kcompactd")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I stumbled over this while trying out the mmots patches today for an unrelated reason.

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 1367c0564d42..d7c8de583a23 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -88,15 +88,15 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
-static int kcompactd_run(int nid)
+static inline int kcompactd_run(int nid)
 {
 	return 0;
 }
-static void kcompactd_stop(int nid)
+static inline void kcompactd_stop(int nid)
 {
 }
 
-static void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
+static inline void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
 {
 }
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 67bb651c56b1..4cb1c2ef5abb 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -7,6 +7,7 @@
  *
  * Copyright IBM Corp. 2007-2010 Mel Gorman <mel@csn.ul.ie>
  */
+#include <linux/cpu.h>
 #include <linux/swap.h>
 #include <linux/migrate.h>
 #include <linux/compaction.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
