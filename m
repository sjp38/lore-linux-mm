Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82D5C6B000D
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:23 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e8-v6so1482874plb.5
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n81si1634859pfj.152.2018.04.18.11.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:22 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 06/14] mm: Move _refcount out of struct page union
Date: Wed, 18 Apr 2018 11:49:04 -0700
Message-Id: <20180418184912.2851-7-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

Keeping the refcount in the union only encourages people to put
something else in the union which will overlap with _refcount and
eventually explode messily.  pahole reports no fields change location.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e83fef8c74d9..9c048a512695 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -113,7 +113,13 @@ struct page {
 		};
 	};
 
-	union {
+	union {		/* This union is 4 bytes in size. */
+		/*
+		 * If the page can be mapped to userspace, encodes the number
+		 * of times this page is referenced by a page table.
+		 */
+		atomic_t _mapcount;
+
 		/*
 		 * If the page is neither PageSlab nor mappable to userspace,
 		 * the value stored here may help determine what this page
@@ -124,22 +130,11 @@ struct page {
 
 		unsigned int active;		/* SLAB */
 		int units;			/* SLOB */
-
-		struct {			/* Page cache */
-			/*
-			 * Count of ptes mapped in mms, to show when
-			 * page is mapped & limit reverse map searches.
-			 */
-			atomic_t _mapcount;
-
-			/*
-			 * Usage count, *USE WRAPPER FUNCTION* when manual
-			 * accounting. See page_ref.h
-			 */
-			atomic_t _refcount;
-		};
 	};
 
+	/* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
+	atomic_t _refcount;
+
 	/*
 	 * WARNING: bit 0 of the first word encode PageTail(). That means
 	 * the rest users of the storage space MUST NOT use the bit to
-- 
2.17.0
