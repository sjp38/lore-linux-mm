Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EB0E76B0075
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:59:59 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kx10so7858253pab.9
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:59 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id yp3si12848228pab.136.2014.10.14.04.59.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:56 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF00A2BNZUG800@mailout3.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:54 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 8/9] mm/zbud: allow clients to use highmem pages
Date: Tue, 14 Oct 2014 20:59:27 +0900
Message-id: <1413287968-13940-9-git-send-email-heesub.shin@samsung.com>
In-reply-to: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

Now that all fields for the internal data structure of zbud are moved to
struct page, there is no reason to restrict zbud pages to be allocated
only in lowmem. This patch allows to use highmem pages for zbud pages.
Pages from highmem are mapped using kmap_atomic() before accessing.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/zbud.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index 5a392f3..677fdc1 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -52,6 +52,7 @@
 #include <linux/spinlock.h>
 #include <linux/zbud.h>
 #include <linux/zpool.h>
+#include <linux/highmem.h>
 
 /*****************
  * Structures
@@ -94,6 +95,9 @@ struct zbud_pool {
 	struct zbud_ops *ops;
 };
 
+/* per-cpu mapping addresses of kmap_atomic()'ed zbud pages */
+static DEFINE_PER_CPU(void *, zbud_mapping);
+
 /*****************
  * zpool
  ****************/
@@ -310,9 +314,6 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * performed first. If no suitable free region is found, then a new page is
  * allocated and added to the pool to satisfy the request.
  *
- * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
- * as zbud pool pages.
- *
  * Return: 0 if success and handle is set, otherwise -EINVAL if the size or
  * gfp arguments are invalid or -ENOMEM if the pool was unable to allocate
  * a new page.
@@ -324,7 +325,7 @@ int zbud_alloc(struct zbud_pool *pool, size_t size, gfp_t gfp,
 	enum buddy bud;
 	struct page *page;
 
-	if (!size || (gfp & __GFP_HIGHMEM))
+	if (!size)
 		return -EINVAL;
 	if (size > PAGE_SIZE - CHUNK_SIZE)
 		return -ENOSPC;
@@ -543,14 +544,24 @@ next:
  */
 void *zbud_map(struct zbud_pool *pool, unsigned long handle)
 {
+	void **mapping;
 	size_t offset = 0;
 	struct page *page = handle_to_zbud_page(handle);
 
+	/*
+	 * Because we use per-cpu mapping shared among the pools/users,
+	 * we can't allow mapping in interrupt context because it can
+	 * corrupt another users mappings.
+	 */
+	BUG_ON(in_interrupt());
+
 	if (is_last_chunk(handle))
 		offset = PAGE_SIZE -
 				(get_num_chunks(page, LAST) << CHUNK_SHIFT);
 
-	return (unsigned char *) page_address(page) + offset;
+	mapping = &get_cpu_var(zbud_mapping);
+	*mapping = kmap_atomic(page);
+	return (char *) *mapping + offset;
 }
 
 /**
@@ -560,6 +571,10 @@ void *zbud_map(struct zbud_pool *pool, unsigned long handle)
  */
 void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
 {
+	void **mapping = this_cpu_ptr(&zbud_mapping);
+
+	kunmap_atomic(*mapping);
+	put_cpu_var(zbud_mapping);
 }
 
 /**
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
