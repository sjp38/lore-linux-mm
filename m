Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3EB6B025B
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 06:46:24 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so129004998pac.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 03:46:24 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ns1si11817330pbc.169.2015.09.26.03.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 03:46:23 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 4/5] mm: add __get_free_kmem_pages helper
Date: Sat, 26 Sep 2015 13:45:56 +0300
Message-ID: <d9481b130836effa190a549e39697a4df822ad68.1443262808.git.vdavydov@parallels.com>
In-Reply-To: <cover.1443262808.git.vdavydov@parallels.com>
References: <cover.1443262808.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Works exactly as __get_free_pages except it also tries to charge newly
allocated pages to kmemcg. It will be used by the next patch.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/gfp.h |  1 +
 mm/page_alloc.c     | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index b46147c45966..34dc0db54b59 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -362,6 +362,7 @@ extern struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask,
 					  unsigned int order);
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
+extern unsigned long __get_free_kmem_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 88d85367c81e..e4a3a7aa8e42 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3296,6 +3296,18 @@ unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
 }
 EXPORT_SYMBOL(__get_free_pages);
 
+unsigned long __get_free_kmem_pages(gfp_t gfp_mask, unsigned int order)
+{
+	struct page *page;
+
+	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
+
+	page = alloc_kmem_pages(gfp_mask, order);
+	if (!page)
+		return 0;
+	return (unsigned long) page_address(page);
+}
+
 unsigned long get_zeroed_page(gfp_t gfp_mask)
 {
 	return __get_free_pages(gfp_mask | __GFP_ZERO, 0);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
