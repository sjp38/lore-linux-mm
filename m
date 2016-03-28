Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AED076B0266
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:59:23 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id zm5so4975323pac.0
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:59:23 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id zi6si21114674pac.32.2016.03.27.22.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 22:59:22 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id td3so90258327pab.2
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:59:22 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 2/2] mm: rename _count, field of the struct page, to _refcount
Date: Mon, 28 Mar 2016 14:59:08 +0900
Message-Id: <1459144748-13664-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459144748-13664-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459144748-13664-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Berg <johannes@sipsolutions.net>, "David S. Miller" <davem@davemloft.net>, Sunil Goutham <sgoutham@cavium.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Many developer already know that field for reference count of
the struct page is _count and atomic type. They would try to handle it
directly and this could break the purpose of page reference count
tracepoint. To prevent direct _count modification, this patch rename it
to _refcount and add warning message on the code. After that, developer
who need to handle reference count will find that field should not be
accessed directly.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mm_types.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 944b2b3..9e8eb5a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -97,7 +97,11 @@ struct page {
 					};
 					int units;	/* SLOB */
 				};
-				atomic_t _count;		/* Usage count, see below. */
+				/*
+				 * Usage count, *USE WRAPPER FUNCTION*
+				 * when manual accounting. See page_ref.h
+				 */
+				atomic_t _refcount;
 			};
 			unsigned int active;	/* SLAB */
 		};
@@ -248,7 +252,7 @@ struct page_frag_cache {
 	__u32 offset;
 #endif
 	/* we maintain a pagecount bias, so that we dont dirty cache line
-	 * containing page->_count every time we allocate a fragment.
+	 * containing page->_refcount every time we allocate a fragment.
 	 */
 	unsigned int		pagecnt_bias;
 	bool pfmemalloc;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
