Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 378916B0069
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 12:27:07 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so2285372wme.4
        for <linux-mm@kvack.org>; Sat, 10 Dec 2016 09:27:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x6si38437317wjk.170.2016.12.10.09.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Dec 2016 09:27:05 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: fadvise: avoid expensive remote LRU cache draining after FADV_DONTNEED
Date: Sat, 10 Dec 2016 12:26:58 -0500
Message-Id: <20161210172658.5182-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When FADV_DONTNEED cannot drop all pages in the range, it observes
that some pages might still be on per-cpu LRU caches after recent
instantiation and so initiates remote calls to all CPUs to flush their
local caches. However, in most cases, the fadvise happens from the
same context that instantiated the pages, and any pre-LRU pages in the
specified range are most likely sitting on the local CPU's LRU cache,
and so in many cases this results in unnecessary remote calls, which,
in a loaded system, can hold up the fadvise() call significantly.

Try to avoid the remote call by flushing the local LRU cache before
even attempting to invalidate anything. It's a cheap operation, and
the local LRU cache is the most likely to hold any pre-LRU pages in
the specified fadvise range.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/fadvise.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 6c707bfe02fd..a43013112581 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -139,7 +139,20 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		}
 
 		if (end_index >= start_index) {
-			unsigned long count = invalidate_mapping_pages(mapping,
+			unsigned long count;
+
+			/*
+			 * It's common to FADV_DONTNEED right after
+			 * the read or write that instantiates the
+			 * pages, in which case there will be some
+			 * sitting on the local LRU cache. Try to
+			 * avoid the expensive remote drain and the
+			 * second cache tree walk below by flushing
+			 * them out right away.
+			 */
+			lru_add_drain();
+
+			count = invalidate_mapping_pages(mapping,
 						start_index, end_index);
 
 			/*
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
