Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 7FAE36B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 15:21:47 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6255470pbb.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 12:21:46 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RESEND PATCH] slub: reduce failure of this_cpu_cmpxchg in put_cpu_partial() after unfreezing
Date: Sat, 28 Jul 2012 04:20:29 +0900
Message-Id: <1343416829-3496-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

In current implementation, after unfreezing, we doesn't touch oldpage,
so it remain 'NOT NULL'. When we call this_cpu_cmpxchg()
with this old oldpage, this_cpu_cmpxchg() is mostly be failed.

We can change value of oldpage to NULL after unfreezing,
because unfreeze_partial() ensure that all the cpu partial slabs is removed
from cpu partial list. In this time, we could expect that
this_cpu_cmpxchg is mostly succeed.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
Change log: Just add "Acked-by: Christoph Lameter <cl@linux.com>"
Resend as ping for Penberg

diff --git a/mm/slub.c b/mm/slub.c
index e517d43..ca778e5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1952,6 +1952,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
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
