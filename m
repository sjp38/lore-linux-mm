Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B86186B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 09:55:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so237676372pfx.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 06:55:19 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id p190si4275365pfb.185.2016.07.01.06.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 06:55:18 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id 66so10132885pfy.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 06:55:18 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2] kasan/quarantine: fix bugs on qlist_move_cache()
Date: Fri,  1 Jul 2016 22:55:32 +0900
Message-Id: <1467381332-7282-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <57765157.8020909@virtuozzo.com>
References: <57765157.8020909@virtuozzo.com>
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

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/quarantine.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 4973505..061d39b 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -238,30 +238,24 @@ static void qlist_move_cache(struct qlist_head *from,
 				   struct qlist_head *to,
 				   struct kmem_cache *cache)
 {
-	struct qlist_node *prev = NULL, *curr;
+	struct qlist_node *curr;
+	struct qlist_node *head = NULL, *tail = NULL;
 
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
