Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 994ED828E4
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 02:41:26 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ts6so190392087pac.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:41:26 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id r85si2606715pfb.223.2016.06.30.23.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 23:41:24 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i123so9302662pfg.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:41:24 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH 1/8] mm/zsmalloc: modify zs compact trace interface
Date: Fri,  1 Jul 2016 14:40:59 +0800
Message-Id: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

1. change trace_zsmalloc_compact_* to trace_zs_compact_* to keep
consistent with other definition in zsmalloc module.

2. remove pages_total_compacted information in trace_zs_compact_end(),
since this is not very userfull for per zs_compact.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 include/trace/events/zsmalloc.h | 16 ++++++----------
 mm/zsmalloc.c                   |  7 +++----
 2 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/include/trace/events/zsmalloc.h b/include/trace/events/zsmalloc.h
index 3b6f14e..c7a39f4 100644
--- a/include/trace/events/zsmalloc.h
+++ b/include/trace/events/zsmalloc.h
@@ -7,7 +7,7 @@
 #include <linux/types.h>
 #include <linux/tracepoint.h>
 
-TRACE_EVENT(zsmalloc_compact_start,
+TRACE_EVENT(zs_compact_start,
 
 	TP_PROTO(const char *pool_name),
 
@@ -25,29 +25,25 @@ TRACE_EVENT(zsmalloc_compact_start,
 		  __entry->pool_name)
 );
 
-TRACE_EVENT(zsmalloc_compact_end,
+TRACE_EVENT(zs_compact_end,
 
-	TP_PROTO(const char *pool_name, unsigned long pages_compacted,
-			unsigned long pages_total_compacted),
+	TP_PROTO(const char *pool_name, unsigned long pages_compacted),
 
-	TP_ARGS(pool_name, pages_compacted, pages_total_compacted),
+	TP_ARGS(pool_name, pages_compacted),
 
 	TP_STRUCT__entry(
 		__field(const char *, pool_name)
 		__field(unsigned long, pages_compacted)
-		__field(unsigned long, pages_total_compacted)
 	),
 
 	TP_fast_assign(
 		__entry->pool_name = pool_name;
 		__entry->pages_compacted = pages_compacted;
-		__entry->pages_total_compacted = pages_total_compacted;
 	),
 
-	TP_printk("pool %s: %ld pages compacted(total %ld)",
+	TP_printk("pool %s: %ld pages compacted",
 		  __entry->pool_name,
-		  __entry->pages_compacted,
-		  __entry->pages_total_compacted)
+		  __entry->pages_compacted)
 );
 
 #endif /* _TRACE_ZSMALLOC_H */
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e425de4..c7f79d5 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -2323,7 +2323,7 @@ unsigned long zs_compact(struct zs_pool *pool)
 	struct size_class *class;
 	unsigned long pages_compacted_before = pool->stats.pages_compacted;
 
-	trace_zsmalloc_compact_start(pool->name);
+	trace_zs_compact_start(pool->name);
 
 	for (i = zs_size_classes - 1; i >= 0; i--) {
 		class = pool->size_class[i];
@@ -2334,9 +2334,8 @@ unsigned long zs_compact(struct zs_pool *pool)
 		__zs_compact(pool, class);
 	}
 
-	trace_zsmalloc_compact_end(pool->name,
-		pool->stats.pages_compacted - pages_compacted_before,
-		pool->stats.pages_compacted);
+	trace_zs_compact_end(pool->name,
+		pool->stats.pages_compacted - pages_compacted_before);
 
 	return pool->stats.pages_compacted;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
