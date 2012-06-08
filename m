Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 7074B6B0070
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 13:25:02 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id p5so3276710dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 10:25:01 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/4] slub: use __cmpxchg_double_slab() at interrupt disabled place
Date: Sat,  9 Jun 2012 02:23:15 +0900
Message-Id: <1339176197-13270-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1339176197-13270-1-git-send-email-js1304@gmail.com>
References: <yes>
 <1339176197-13270-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

get_freelist(), unfreeze_partials() are only called with interrupt disabled,
so __cmpxchg_double_slab() is suitable.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 30ceb6d..686ed90 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1879,7 +1879,11 @@ redo:
 	}
 }
 
-/* Unfreeze all the cpu partial slabs */
+/*
+ * Unfreeze all the cpu partial slabs.
+ *
+ * This function must be called with interrupt disabled.
+ */
 static void unfreeze_partials(struct kmem_cache *s)
 {
 	struct kmem_cache_node *n = NULL;
@@ -1935,7 +1939,7 @@ static void unfreeze_partials(struct kmem_cache *s)
 				l = m;
 			}
 
-		} while (!cmpxchg_double_slab(s, page,
+		} while (!__cmpxchg_double_slab(s, page,
 				old.freelist, old.counters,
 				new.freelist, new.counters,
 				"unfreezing slab"));
@@ -2163,6 +2167,8 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
  * The page is still frozen if the return value is not NULL.
  *
  * If this function returns NULL then the page has been unfrozen.
+ *
+ * This function must be called with interrupt disabled.
  */
 static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 {
@@ -2179,7 +2185,7 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 		new.inuse = page->objects;
 		new.frozen = freelist != NULL;
 
-	} while (!cmpxchg_double_slab(s, page,
+	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
 		NULL, new.counters,
 		"get_freelist"));
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
