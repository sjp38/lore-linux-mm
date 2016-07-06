Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 87501828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 20:52:38 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ts6so429982086pac.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 17:52:38 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id e132si2849088pfg.292.2016.07.05.17.52.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 17:52:37 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id ib6so3577675pad.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 17:52:37 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v5] kasan/quarantine: fix bugs on qlist_move_cache()
Date: Wed,  6 Jul 2016 09:52:28 +0900
Message-Id: <1467766348-22419-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Kuthonuzo Luruo <poll.stdin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

v5: rename some variable for better readability
v4: fix cache size bug s/cache->size/obj_cache->size/
v3: fix build warning

Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/quarantine.c | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 4973505..65793f1 100644
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
-		struct qlist_node *qlink = curr;
-		struct kmem_cache *obj_cache = qlink_to_cache(qlink);
-
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
-		curr = curr->next;
+		struct qlist_node *next = curr->next;
+		struct kmem_cache *obj_cache = qlink_to_cache(curr);
+
+		if (obj_cache == cache)
+			qlist_put(to, curr, obj_cache->size);
+		else
+			qlist_put(from, curr, obj_cache->size);
+
+		curr = next;
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
