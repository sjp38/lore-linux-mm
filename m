Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1E16B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 16:00:24 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so14824701wjb.7
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 13:00:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ja7si56172445wjb.23.2016.12.14.13.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 13:00:22 -0800 (PST)
Date: Wed, 14 Dec 2016 16:00:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH v2] mm: fadvise: avoid expensive remote LRU cache draining
 after FADV_DONTNEED
Message-ID: <20161214210017.GA1465@cmpxchg.org>
References: <20161210172658.5182-1-hannes@cmpxchg.org>
 <5cc0eb6f-bede-a34a-522b-e30d06723ffa@suse.cz>
 <20161212155552.GA7148@cmpxchg.org>
 <d52c53fc-60c7-21ca-08ab-f58cd4b403f1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d52c53fc-60c7-21ca-08ab-f58cd4b403f1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When FADV_DONTNEED cannot drop all pages in the range, it observes
that some pages might still be on per-cpu LRU caches after recent
instantiation and so initiates remote calls to all CPUs to flush their
local caches. However, in most cases, the fadvise happens from the
same context that instantiated the pages, and any pre-LRU pages in the
specified range are most likely sitting on the local CPU's LRU cache,
and so in many cases this results in unnecessary remote calls, which,
in a loaded system, can hold up the fadvise() call significantly.

[ I didn't record it in the extreme case we observed at Facebook,
  unfortunately. We had a slow-to-respond system and noticed it
  lru_add_drain_all() leading the profile during fadvise calls. This
  patch came out of thinking about the code and how we commonly call
  FADV_DONTNEED.

  FWIW, I wrote a silly directory tree walker/searcher that recurses
  through /usr to read and FADV_DONTNEED each file it finds. On a 2
  socket 40 ht machine, over 1% is spent in lru_add_drain_all(). With
  the patch, that cost is gone; the local drain cost shows at 0.09%. ]

Try to avoid the remote call by flushing the local LRU cache before
even attempting to invalidate anything. It's a cheap operation, and
the local LRU cache is the most likely to hold any pre-LRU pages in
the specified fadvise range.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@suse.de>
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
