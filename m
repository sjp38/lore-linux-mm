Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 457E06B0081
	for <linux-mm@kvack.org>; Thu, 17 May 2012 13:04:57 -0400 (EDT)
Received: by yenm7 with SMTP id m7so2926366yen.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 10:04:56 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1,2/4 v3] slub: use __cmpxchg_double_slab() at interrupt disabled place
Date: Fri, 18 May 2012 02:03:39 +0900
Message-Id: <1337274219-5279-1-git-send-email-js1304@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1205171149050.8534@router.home>
References: <alpine.DEB.2.00.1205171149050.8534@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

get_freelist(), unfreeze_partials() are only called with interrupt disabled,
so __cmpxchg_double_slab() is suitable.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 0c3105c..c38efce 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1935,7 +1935,7 @@ static void unfreeze_partials(struct kmem_cache *s)
 				l = m;
 			}
 
-		} while (!cmpxchg_double_slab(s, page,
+		} while (!__cmpxchg_double_slab(s, page,
 				old.freelist, old.counters,
 				new.freelist, new.counters,
 				"unfreezing slab"));
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
