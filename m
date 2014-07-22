Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 06FA86B0037
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 18:58:01 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so4587814igb.3
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:58:00 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id bn6si1090028icb.24.2014.07.22.15.58.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 15:58:00 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id rd18so281495iec.14
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:58:00 -0700 (PDT)
Date: Tue, 22 Jul 2014 15:57:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm, slub: fix false-positive lockdep warning in
 free_partial()
In-Reply-To: <alpine.DEB.2.02.1407221550500.9885@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1407221556330.9885@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407221550500.9885@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Dan Carpenter <dan.carpenter@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Vladimir Davydov <vdavydov@parallels.com>

Commit c65c1877bd68 ("slub: use lockdep_assert_held") requires
remove_partial() to be called with n->list_lock held, but free_partial()
called from kmem_cache_close() on cache destruction does not follow this
rule, leading to a warning:

  WARNING: CPU: 0 PID: 2787 at mm/slub.c:1536 __kmem_cache_shutdown+0x1b2/0x1f0()
  Modules linked in:
  CPU: 0 PID: 2787 Comm: modprobe Tainted: G        W    3.14.0-rc1-mm1+ #1
  Hardware name:
   0000000000000600 ffff88003ae1dde8 ffffffff816d9583 0000000000000600
   0000000000000000 ffff88003ae1de28 ffffffff8107c107 0000000000000000
   ffff880037ab2b00 ffff88007c240d30 ffffea0001ee5280 ffffea0001ee52a0
  Call Trace:
   [<ffffffff816d9583>] dump_stack+0x51/0x6e
   [<ffffffff8107c107>] warn_slowpath_common+0x87/0xb0
   [<ffffffff8107c145>] warn_slowpath_null+0x15/0x20
   [<ffffffff811c7fe2>] __kmem_cache_shutdown+0x1b2/0x1f0
   [<ffffffff811908d3>] kmem_cache_destroy+0x43/0xf0
   [<ffffffffa013a123>] xfs_destroy_zones+0x103/0x110 [xfs]
   [<ffffffffa0192b54>] exit_xfs_fs+0x38/0x4e4 [xfs]
   [<ffffffff811036fa>] SyS_delete_module+0x19a/0x1f0
   [<ffffffff816dfcd8>] ? retint_swapgs+0x13/0x1b
   [<ffffffff810d2125>] ? trace_hardirqs_on_caller+0x105/0x1d0
   [<ffffffff81359efe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
   [<ffffffff816e8539>] system_call_fastpath+0x16/0x1b

Although this cannot actually result in a race, because on cache
destruction there should not be any concurrent frees or allocations from
the cache, let's add spin_lock/unlock to free_partial() just to keep
lockdep happy.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Pekka Enberg <penberg@kernel.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3195,12 +3195,13 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
 /*
  * Attempt to free all partial slabs on a node.
  * This is called from kmem_cache_close(). We must be the last thread
- * using the cache and therefore we do not need to lock anymore.
+ * using the cache, but we still have to lock for lockdep's sake.
  */
 static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 {
 	struct page *page, *h;
 
+	spin_lock_irq(&n->list_lock);
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
 		if (!page->inuse) {
 			__remove_partial(n, page);
@@ -3210,6 +3211,7 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 			"Objects remaining in %s on kmem_cache_close()");
 		}
 	}
+	spin_unlock_irq(&n->list_lock);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
