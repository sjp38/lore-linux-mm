Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 235546B000C
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 09:50:35 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v16so5679791wrv.14
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 06:50:35 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id v131si1391937wme.276.2018.02.23.06.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 06:50:33 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 3/7] struct page: add field for vm_struct
Date: Fri, 23 Feb 2018 16:48:03 +0200
Message-ID: <20180223144807.1180-4-igor.stoppa@huawei.com>
In-Reply-To: <20180223144807.1180-1-igor.stoppa@huawei.com>
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

When a page is used for virtual memory, it is often necessary to obtain
a handler to the corresponding vm_struct, which refers to the virtually
continuous area generated when invoking vmalloc.

The struct page has a "mapping" field, which can be re-used, to store a
pointer to the parent area.

This will avoid more expensive searches, later on.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/mm_types.h | 1 +
 mm/vmalloc.c             | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fd1af6b9591d..c3a4825e10c0 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -84,6 +84,7 @@ struct page {
 		void *s_mem;			/* slab first object */
 		atomic_t compound_mapcount;	/* first tail page */
 		/* page_deferred_list().next	 -- second tail page */
+		struct vm_struct *area;
 	};
 
 	/* Second double word */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..14d99ed22397 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1536,6 +1536,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
+			page->area = NULL;
 			__free_pages(page, 0);
 		}
 
@@ -1744,6 +1745,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			const void *caller)
 {
 	struct vm_struct *area;
+	unsigned int i;
 	void *addr;
 	unsigned long real_size = size;
 
@@ -1769,6 +1771,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 
 	kmemleak_vmalloc(area, size, gfp_mask);
 
+	for (i = 0; i < area->nr_pages; i++)
+		area->pages[i]->area = area;
+
 	return addr;
 
 fail:
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
