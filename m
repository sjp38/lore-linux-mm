Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1D15A6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 03:27:42 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id r10so15481692pdi.29
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 00:27:39 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id j4si2324187pdb.62.2014.09.05.00.27.36
        for <linux-mm@kvack.org>;
        Fri, 05 Sep 2014 00:27:38 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH -mmotm] mm: fix kmemcheck.c build errors
Date: Fri,  5 Sep 2014 16:28:06 +0900
Message-Id: <1409902086-32311-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Pekka Enberg <penberg@kernel.org>, Vegard Nossum <vegardno@ifi.uio.no>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Randy Dunlap <rdunlap@infradead.org>

mm-slab_common-move-kmem_cache-definition-to-internal-header.patch
in mmotm makes following build failure.

../mm/kmemcheck.c:70:7: error: dereferencing pointer to incomplete type
../mm/kmemcheck.c:83:15: error: dereferencing pointer to incomplete type
../mm/kmemcheck.c:95:8: error: dereferencing pointer to incomplete type
../mm/kmemcheck.c:95:21: error: dereferencing pointer to incomplete type

../mm/slab.h: In function 'cache_from_obj':
../mm/slab.h:283:2: error: implicit declaration of function
'memcg_kmem_enabled' [-Werror=implicit-function-declaration]

Add header files to fix kmemcheck.c build errors.

[iamjoonsoo.kim@lge.com] move up memcontrol.h header
to fix build failure if CONFIG_MEMCG_KMEM=y too.
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kmemcheck.c |    1 +
 mm/slab.h      |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
index fd814fd..cab58bb 100644
--- a/mm/kmemcheck.c
+++ b/mm/kmemcheck.c
@@ -2,6 +2,7 @@
 #include <linux/mm_types.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include "slab.h"
 #include <linux/kmemcheck.h>
 
 void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
diff --git a/mm/slab.h b/mm/slab.h
index 13845d0..963a3f8 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -37,6 +37,8 @@ struct kmem_cache {
 #include <linux/slub_def.h>
 #endif
 
+#include <linux/memcontrol.h>
+
 /*
  * State of the slab allocator.
  *
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
