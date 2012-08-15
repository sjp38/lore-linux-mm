Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 00C866B0069
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 11:39:28 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2331071ghr.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 08:39:28 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: try to get cpu partial slab even if we get enough objects for cpu freelist
Date: Thu, 16 Aug 2012 00:38:04 +0900
Message-Id: <1345045084-7292-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

s->cpu_partial determine the maximum number of objects kept
in the per cpu partial lists of a processor. Currently, it is used for
not only per cpu partial list but also cpu freelist. Therefore
get_partial_node() doesn't work properly according to our first intention.

Fix it as forcibly assigning 0 to objects count when we get for cpu freelist.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>

diff --git a/mm/slub.c b/mm/slub.c
index efce427..88dca1d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1550,7 +1550,12 @@ static void *get_partial_node(struct kmem_cache *s,
 			c->page = page;
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
-			available =  page->objects - page->inuse;
+
+			/*
+			 * We don't want to stop without trying to get
+			 * cpu partial slab. So, forcibly set 0 to available
+			 */
+			available = 0;
 		} else {
 			available = put_cpu_partial(s, page, 0);
 			stat(s, CPU_PARTIAL_NODE);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
