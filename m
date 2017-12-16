Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31AFD6B0069
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 11:44:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t65so10000490pfe.22
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 08:44:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t24si6750806plo.449.2017.12.16.08.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 08:44:42 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 2/8] mm: De-indent struct page
Date: Sat, 16 Dec 2017 08:44:19 -0800
Message-Id: <20171216164425.8703-3-willy@infradead.org>
In-Reply-To: <20171216164425.8703-1-willy@infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

I found the struct { union { struct { union { struct { } } } } }
layout rather confusing.  Fortunately, there is an easier way to write
this.  The innermost union is of four things which are the size of an
int, so the ones which are used by slab/slob/slub can be pulled up
two levels to be in the outermost union with 'counters'.  That leaves
us with struct { union { struct { atomic_t; atomic_t; } } } which
has the same layout, but is easier to read.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4509f0cfaf39..27973166af28 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -84,28 +84,26 @@ struct page {
 		 */
 		unsigned counters;
 #endif
-		struct {
+		unsigned int active;		/* SLAB */
+		struct {			/* SLUB */
+			unsigned inuse:16;
+			unsigned objects:15;
+			unsigned frozen:1;
+		};
+		int units;			/* SLOB */
+
+		struct {			/* Page cache */
+			/*
+			 * Count of ptes mapped in mms, to show when
+			 * page is mapped & limit reverse map searches.
+			 *
+			 * Extra information about page type may be
+			 * stored here for pages that are never mapped,
+			 * in which case the value MUST BE <= -2.
+			 * See page-flags.h for more details.
+			 */
+			atomic_t _mapcount;
 
-			union {
-				/*
-				 * Count of ptes mapped in mms, to show when
-				 * page is mapped & limit reverse map searches.
-				 *
-				 * Extra information about page type may be
-				 * stored here for pages that are never mapped,
-				 * in which case the value MUST BE <= -2.
-				 * See page-flags.h for more details.
-				 */
-				atomic_t _mapcount;
-
-				unsigned int active;		/* SLAB */
-				struct {			/* SLUB */
-					unsigned inuse:16;
-					unsigned objects:15;
-					unsigned frozen:1;
-				};
-				int units;			/* SLOB */
-			};
 			/*
 			 * Usage count, *USE WRAPPER FUNCTION* when manual
 			 * accounting. See page_ref.h
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
