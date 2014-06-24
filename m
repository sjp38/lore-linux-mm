Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BF37E6B003D
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 03:39:43 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so6942298pab.1
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:39:43 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ty7si25103564pab.10.2014.06.24.00.39.39
        for <linux-mm@kvack.org>;
        Tue, 24 Jun 2014 00:39:42 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] slub: fix off by one in number of slab tests
Date: Tue, 24 Jun 2014 16:44:01 +0900
Message-Id: <1403595842-28270-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

min_partial means minimum number of slab cached in node partial
list. So, if nr_partial is less than it, we keep newly empty slab
on node partial list rather than freeing it. But if nr_partial is
equal or greater than it, it means that we have enough partial slabs
so should free newly empty slab. Current implementation missed
the equal case so if we set min_partial is 0, then, at least one slab
could be cached. This is critical problem to kmemcg destroying logic
because it doesn't works properly if some slabs is cached. This patch
fixes this problem.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index c567927..67da14d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1851,7 +1851,7 @@ redo:
 
 	new.frozen = 0;
 
-	if (!new.inuse && n->nr_partial > s->min_partial)
+	if (!new.inuse && n->nr_partial >= s->min_partial)
 		m = M_FREE;
 	else if (new.freelist) {
 		m = M_PARTIAL;
@@ -1962,7 +1962,7 @@ static void unfreeze_partials(struct kmem_cache *s,
 				new.freelist, new.counters,
 				"unfreezing slab"));
 
-		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
+		if (unlikely(!new.inuse && n->nr_partial >= s->min_partial)) {
 			page->next = discard_page;
 			discard_page = page;
 		} else {
@@ -2595,7 +2595,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
                 return;
         }
 
-	if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
+	if (unlikely(!new.inuse && n->nr_partial >= s->min_partial))
 		goto slab_empty;
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
