Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id AF66B6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 02:33:25 -0400 (EDT)
From: Feng Tang <feng.tang@intel.com>
Subject: [PATCH] slab: Fix a tpyo in commit 8c138b "slab: Get rid of obj_size macro"
Date: Mon,  2 Jul 2012 14:29:10 +0800
Message-Id: <1341210550-11038-1-git-send-email-feng.tang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: linux-kernel@vger.kernel.org, fengguang.wu@intel.com, sfr@canb.auug.org.au, linux-mm@kvack.org, Feng Tang <feng.tang@intel.com>, Christoph Lameter <cl@linux.com>

Commit  8c138b only sits in Pekka's and linux-next tree now, which tries
to replace obj_size(cachep) with cachep->object_size, but has a typo in
kmem_cache_free() by using "size" instead of "object_size", which casues
some regressions.

Reported-and-tested-by: Fengguang Wu <wfg@linux.intel.com>
Signed-off-by: Feng Tang <feng.tang@intel.com>
Cc: Christoph Lameter <cl@linux.com>
---
 mm/slab.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 64c3d03..605b3b7 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3890,7 +3890,7 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 	unsigned long flags;
 
 	local_irq_save(flags);
-	debug_check_no_locks_freed(objp, cachep->size);
+	debug_check_no_locks_freed(objp, cachep->object_size);
 	if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(objp, cachep->object_size);
 	__cache_free(cachep, objp, __builtin_return_address(0));
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
