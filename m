Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id DAB486B006C
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 10:39:04 -0400 (EDT)
Received: by yenl1 with SMTP id l1so666739yen.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 07:39:04 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 1/2] mm, slob: Prevent false positive trace upon allocation failure
Date: Tue, 14 Aug 2012 11:38:49 -0300
Message-Id: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>

This patch changes the __kmalloc_node() logic to return NULL
if alloc_pages() fails to return valid pages.
This is done to avoid to trace a false positive kmalloc event.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slob.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 45d4ca7..686e98b 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -450,15 +450,16 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 				   size, size + align, gfp, node);
 	} else {
 		unsigned int order = get_order(size);
+		struct page *page;
 
 		if (likely(order))
 			gfp |= __GFP_COMP;
 		ret = slob_new_pages(gfp, order, node);
-		if (ret) {
-			struct page *page;
-			page = virt_to_page(ret);
-			page->private = size;
-		}
+		if (!ret)
+			return NULL;
+
+		page = virt_to_page(ret);
+		page->private = size;
 
 		trace_kmalloc_node(_RET_IP_, ret,
 				   size, PAGE_SIZE << order, gfp, node);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
