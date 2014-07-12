Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2936B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 21:09:21 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so2218939pdj.5
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 18:09:21 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id dk1si4023072pbb.213.2014.07.11.18.09.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Jul 2014 18:09:20 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so2236740pde.17
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 18:09:19 -0700 (PDT)
From: Hyoungho Choi <holuyaa@gmail.com>
Subject: [PATCH] slub: remove loop redundancy in mm/slub.c
Date: Sat, 12 Jul 2014 10:09:10 +0900
Message-Id: <1405127350-13863-1-git-send-email-holuyaa@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hyoungho Choi <holuyaa@gmail.com>

set_freepointer() is invoked twice for first object at new_slab().
Remove it.

Signed-off-by: Hyoungho Choi <holuyaa@gmail.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7300480..f6d0327 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1433,7 +1433,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		memset(start, POISON_INUSE, PAGE_SIZE << order);
 
 	last = start;
-	for_each_object(p, s, start, page->objects) {
+	for_each_object(p, s, start + s->size, page->objects - 1) {
 		setup_object(s, page, last);
 		set_freepointer(s, last, p);
 		last = p;
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
