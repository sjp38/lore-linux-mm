Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B09AE6B006E
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 10:39:11 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so664828ghr.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 07:39:10 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [RFC/PATCH 2/2] mm, slob: Save real allocated size in page->private
Date: Tue, 14 Aug 2012 11:38:50 -0300
Message-Id: <1344955130-29478-2-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
References: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>

As documented in slob.c header, page->private field is used to return
accurately the allocated size, through ksize().
Therefore, if one allocates a contiguous set of pages the available size
is PAGE_SIZE << order, instead of the requested size.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slob.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 686e98b..4c89b7d 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -459,7 +459,7 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 			return NULL;
 
 		page = virt_to_page(ret);
-		page->private = size;
+		page->private = PAGE_SIZE << order;
 
 		trace_kmalloc_node(_RET_IP_, ret,
 				   size, PAGE_SIZE << order, gfp, node);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
