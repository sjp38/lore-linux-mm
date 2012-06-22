Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CF2196B020E
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 14:24:13 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id p5so3292851dak.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 11:24:13 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/3] slub: reduce failure of this_cpu_cmpxchg in put_cpu_partial() after unfreezing
Date: Sat, 23 Jun 2012 03:22:38 +0900
Message-Id: <1340389359-2407-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1340389359-2407-1-git-send-email-js1304@gmail.com>
References: <yes>
 <1340389359-2407-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

In current implementation, after unfreezing, we doesn't touch oldpage,
so it remain 'NOT NULL'. When we call this_cpu_cmpxchg()
with this old oldpage, this_cpu_cmpxchg() is mostly be failed.

We can change value of oldpage to NULL after unfreezing,
because unfreeze_partial() ensure that all the cpu partial slabs is removed
from cpu partial list. In this time, we could expect that
this_cpu_cmpxchg is mostly succeed.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 92f1c0e..531d8ed 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1968,6 +1968,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 				local_irq_save(flags);
 				unfreeze_partials(s);
 				local_irq_restore(flags);
+				oldpage = NULL;
 				pobjects = 0;
 				pages = 0;
 				stat(s, CPU_PARTIAL_DRAIN);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
