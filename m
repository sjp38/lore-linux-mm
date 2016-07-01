Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8896B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 10:02:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so237507195pfa.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:02:01 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id qj5si4330592pac.289.2016.07.01.07.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 07:02:00 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id c74so10161165pfb.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:02:00 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3] kasan/quarantine: fix bugs on qlist_move_cache()
Date: Fri,  1 Jul 2016 23:02:13 +0900
Message-Id: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There are two bugs on qlist_move_cache(). One is that qlist's tail
isn't set properly. curr->next can be NULL since it is singly linked
list and NULL value on tail is invalid if there is one item on qlist.
Another one is that if cache is matched, qlist_put() is called and
it will set curr->next to NULL. It would cause to stop the loop
prematurely.

These problems come from complicated implementation so I'd like to
re-implement it completely. Implementation in this patch is really
simple. Iterate all qlist_nodes and put them to appropriate list.

Unfortunately, I got this bug sometime ago and lose oops message.
But, the bug looks trivial and no need to attach oops.

v3: fix build warning

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/quarantine.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 4973505..cf92494 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -238,30 +238,23 @@ static void qlist_move_cache(struct qlist_head *from,
 				   struct qlist_head *to,
 				   struct kmem_cache *cache)
 {
-	struct qlist_node *prev = NULL, *curr;
+	struct qlist_node *curr;
 
 	if (unlikely(qlist_empty(from)))
 		return;
 
 	curr = from->head;
+	qlist_init(from);
 	while (curr) {
 		struct qlist_node *qlink = curr;
 		struct kmem_cache *obj_cache = qlink_to_cache(qlink);
 
-		if (obj_cache == cache) {
-			if (unlikely(from->head == qlink)) {
-				from->head = curr->next;
-				prev = curr;
-			} else
-				prev->next = curr->next;
-			if (unlikely(from->tail == qlink))
-				from->tail = curr->next;
-			from->bytes -= cache->size;
-			qlist_put(to, qlink, cache->size);
-		} else {
-			prev = curr;
-		}
 		curr = curr->next;
+
+		if (obj_cache == cache)
+			qlist_put(to, qlink, cache->size);
+		else
+			qlist_put(from, qlink, cache->size);
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
