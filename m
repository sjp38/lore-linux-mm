Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9EB6B002A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 19:43:53 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id d9-v6so38133ywd.15
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 16:43:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o83-v6sor5869ywd.284.2018.04.26.16.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 16:43:52 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 1/2] struct page: add field for vm_struct
Date: Fri, 27 Apr 2018 03:42:42 +0400
Message-Id: <20180426234243.22267-2-igor.stoppa@huawei.com>
In-Reply-To: <20180426234243.22267-1-igor.stoppa@huawei.com>
References: <20180426234243.22267-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

When a page is used for virtual memory, it is often necessary to obtain
a handler to the corresponding vm_struct, which refers to the virtually
continuous area generated when invoking vmalloc.

The struct page has a "mapping" field, which can be re-used, to store a
pointer to the parent area.

This will avoid more expensive searches, later on.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
Reviewed-by: Jay Freyensee <why2jjj.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 1 +
 mm/vmalloc.c             | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 21612347d311..c74e2aa9a48b 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -86,6 +86,7 @@ struct page {
 		void *s_mem;			/* slab first object */
 		atomic_t compound_mapcount;	/* first tail page */
 		/* page_deferred_list().next	 -- second tail page */
+		struct vm_struct *area;
 	};
 
 	/* Second double word */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ebff729cc956..61a1ca22b0f6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1536,6 +1536,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
+			page->area = NULL;
 			__free_pages(page, 0);
 		}
 
@@ -1705,6 +1706,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			area->nr_pages = i;
 			goto fail;
 		}
+		page->area = area;
 		area->pages[i] = page;
 		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
 			cond_resched();
-- 
2.14.1
