Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3B33A6B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 14:08:47 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so47392359wmp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 11:08:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y3si38730190wjy.136.2016.03.01.11.08.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 11:08:46 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH mmotm] mm, sl[au]b: print gfp_flags as strings in slab_out_of_memory()
Date: Tue,  1 Mar 2016 20:08:32 +0100
Message-Id: <1456859312-26207-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can now print gfp_flags more human-readable. Make use of this in
slab_out_of_memory() for SLUB and SLAB. Also convert the SLAB variant it to
pr_warn() along the way.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
This could go after e.g. mm-oom-print-symbolic-gfp_flags-in-oom-warning.patch
Quick grep suggests there are no other places to convert.

 mm/slab.c | 10 ++++------
 mm/slub.c |  4 ++--
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b9ee77554008..c87088ae2351 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1347,10 +1347,9 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 	if ((gfpflags & __GFP_NOWARN) || !__ratelimit(&slab_oom_rs))
 		return;
 
-	printk(KERN_WARNING
-		"SLAB: Unable to allocate memory on node %d (gfp=0x%x)\n",
-		nodeid, gfpflags);
-	printk(KERN_WARNING "  cache: %s, object size: %d, order: %d\n",
+	pr_warn("SLAB: Unable to allocate memory on node %d, gfp=%#x(%pGg)\n",
+		nodeid, gfpflags, &gfpflags);
+	pr_warn("  cache: %s, object size: %d, order: %d\n",
 		cachep->name, cachep->size, cachep->gfporder);
 
 	for_each_kmem_cache_node(cachep, node, n) {
@@ -1374,8 +1373,7 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 
 		num_slabs += active_slabs;
 		num_objs = num_slabs * cachep->num;
-		printk(KERN_WARNING
-			"  node %d: slabs: %ld/%ld, objs: %ld/%ld, free: %ld\n",
+		pr_warn("  node %d: slabs: %ld/%ld, objs: %ld/%ld, free: %ld\n",
 			node, active_slabs, num_slabs, active_objs, num_objs,
 			free_objects);
 	}
diff --git a/mm/slub.c b/mm/slub.c
index d86720d93cda..8caaf2903241 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2248,8 +2248,8 @@ slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 	if ((gfpflags & __GFP_NOWARN) || !__ratelimit(&slub_oom_rs))
 		return;
 
-	pr_warn("SLUB: Unable to allocate memory on node %d (gfp=0x%x)\n",
-		nid, gfpflags);
+	pr_warn("SLUB: Unable to allocate memory on node %d, gfp=%#x(%pGg)\n",
+		nid, gfpflags, &gfpflags);
 	pr_warn("  cache: %s, object size: %d, buffer size: %d, default order: %d, min order: %d\n",
 		s->name, s->object_size, s->size, oo_order(s->oo),
 		oo_order(s->min));
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
