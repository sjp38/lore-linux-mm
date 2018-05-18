Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 764FA6B0667
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:45:31 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x32-v6so5610732pld.16
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:45:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z26-v6si9025337pfl.209.2018.05.18.12.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 12:45:23 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 06/17] mm: Move _refcount out of struct page union
Date: Fri, 18 May 2018 12:45:08 -0700
Message-Id: <20180518194519.3820-7-willy@infradead.org>
In-Reply-To: <20180518194519.3820-1-willy@infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Keeping the refcount in the union only encourages people to put
something else in the union which will overlap with _refcount and
eventually explode messily.  pahole reports no fields change location.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 23378a789af4..9828cd170251 100644
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
