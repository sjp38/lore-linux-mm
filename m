Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 9611D6B0249
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 14:46:50 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3319376dak.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 11:46:49 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/3 v2] slub: prefetch next freelist pointer in __slab_alloc()
Date: Sat, 23 Jun 2012 03:45:29 +0900
Message-Id: <1340390729-2821-1-git-send-email-js1304@gmail.com>
In-Reply-To: <1340389359-2407-1-git-send-email-js1304@gmail.com>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, Joonsoo Kim <js1304@gmail.com>

Commit 0ad9500e16fe24aa55809a2b00e0d2d0e658fc71 ('slub: prefetch
next freelist pointer in slab_alloc') add prefetch instruction to
fast path of allocation.

Same benefit is also available in slow path of allocation, but it is not
large portion of overall allocation. Nevertheless we could get
some benifit from it, so prefetch next freelist pointer in __slab_alloc.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>
---
Add 'Cc: Eric Dumazet <eric.dumazet@gmail.com>'

diff --git a/mm/slub.c b/mm/slub.c
index f96d8bc..92f1c0e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2248,6 +2248,7 @@ load_freelist:
 	VM_BUG_ON(!c->page->frozen);
 	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
+	prefetch_freepointer(s, c->freelist);
 	local_irq_restore(flags);
 	return freelist;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
