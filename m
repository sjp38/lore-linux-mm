Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19D8B6B0003
	for <linux-mm@kvack.org>; Fri,  4 May 2018 14:33:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id w3-v6so14176451pgv.17
        for <linux-mm@kvack.org>; Fri, 04 May 2018 11:33:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bg6-v6si14451216plb.243.2018.05.04.11.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 11:33:22 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 04/17] mm: Switch s_mem and slab_cache in struct page
Date: Fri,  4 May 2018 11:33:05 -0700
Message-Id: <20180504183318.14415-5-willy@infradead.org>
In-Reply-To: <20180504183318.14415-1-willy@infradead.org>
References: <20180504183318.14415-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This will allow us to store slub's counters in the same bits as slab's
s_mem.  slub now needs to set page->mapping to NULL as it frees the page,
just like slab does.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 4 ++--
 mm/slub.c                | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 41828fb34860..e97a310a6abe 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -83,7 +83,7 @@ struct page {
 		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
 		struct address_space *mapping;
 
-		void *s_mem;			/* slab first object */
+		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 		atomic_t compound_mapcount;	/* first tail page */
 		/* page_deferred_list().next	 -- second tail page */
 	};
@@ -194,7 +194,7 @@ struct page {
 		spinlock_t ptl;
 #endif
 #endif
-		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+		void *s_mem;			/* slab first object */
 	};
 
 #ifdef CONFIG_MEMCG
diff --git a/mm/slub.c b/mm/slub.c
index e938184ac847..7fc13c46e975 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1690,6 +1690,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	__ClearPageSlab(page);
 
 	page_mapcount_reset(page);
+	page->mapping = NULL;
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
 	memcg_uncharge_slab(page, order, s);
-- 
2.17.0
