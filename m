Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9828E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 01:57:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i189-v6so2485908pge.6
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 22:57:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13-v6sor576683pgm.62.2018.09.25.22.57.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 22:57:23 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCH] mm/slub: remove useless condition in deactivate_slab
Date: Wed, 26 Sep 2018 13:57:10 +0800
Message-Id: <1537941430-16217-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

The var l should be used to reflect the original list, on which the page
should be. But c->page is not on any list. Furthermore, the current code
does not update the value of l. Hence remove the related logic

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slub.c | 30 +++++++-----------------------
 1 file changed, 7 insertions(+), 23 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8da34a8..a68c2ae 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1992,7 +1992,7 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 	enum slab_modes { M_NONE, M_PARTIAL, M_FULL, M_FREE };
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 	int lock = 0;
-	enum slab_modes l = M_NONE, m = M_NONE;
+	enum slab_modes m = M_NONE;
 	void *nextfree;
 	int tail = DEACTIVATE_TO_HEAD;
 	struct page new;
@@ -2088,30 +2088,14 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 		}
 	}
 
-	if (l != m) {
-
-		if (l == M_PARTIAL)
-
-			remove_partial(n, page);
-
-		else if (l == M_FULL)
-
-			remove_full(s, n, page);
-
-		if (m == M_PARTIAL) {
-
-			add_partial(n, page, tail);
-			stat(s, tail);
-
-		} else if (m == M_FULL) {
-
-			stat(s, DEACTIVATE_FULL);
-			add_full(s, n, page);
-
-		}
+	if (m == M_PARTIAL) {
+		add_partial(n, page, tail);
+		stat(s, tail);
+	} else if (m == M_FULL) {
+		stat(s, DEACTIVATE_FULL);
+		add_full(s, n, page);
 	}
 
-	l = m;
 	if (!__cmpxchg_double_slab(s, page,
 				old.freelist, old.counters,
 				new.freelist, new.counters,
-- 
2.7.4
