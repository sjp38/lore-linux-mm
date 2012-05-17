Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A2A386B00EB
	for <linux-mm@kvack.org>; Thu, 17 May 2012 11:50:07 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3846917dak.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 08:50:06 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/4] slub: change cmpxchg_double_slab in get_freelist() to __cmpxchg_double_slab
Date: Fri, 18 May 2012 00:47:45 +0900
Message-Id: <1337269668-4619-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1337269668-4619-1-git-send-email-js1304@gmail.com>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

get_freelist() is only called by __slab_alloc with interrupt disabled,
so __cmpxchg_double_slab is suitable.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 0c3105c..d28bc45 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2179,7 +2179,7 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
