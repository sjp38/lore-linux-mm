Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE2FB6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:34:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 80so1343770wmb.7
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:34:38 -0800 (PST)
Received: from baptiste.telenet-ops.be (baptiste.telenet-ops.be. [2a02:1800:120:4::f00:13])
        by mx.google.com with ESMTPS id d12si1777794edh.286.2017.12.13.07.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 07:34:37 -0800 (PST)
From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2] mm/slab: Do not hash pointers when debugging slab
Date: Wed, 13 Dec 2017 16:34:27 +0100
Message-Id: <1513179267-2509-1-git-send-email-geert+renesas@glider.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Tobin C . Harding" <me@tobin.cc>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>

If CONFIG_DEBUG_SLAB/CONFIG_DEBUG_SLAB_LEAK are enabled, the slab code
prints extra debug information when e.g. corruption is detected.
This includes pointers, which are not very useful when hashed.

Fix this by using %px to print unhashed pointers instead where it makes
sense, and by removing the printing of a last user pointer referring to
code.

Fixes: ad67b74d2469d9b8 ("printk: hash addresses printed with %p")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
---
v2:
  - Add Acked-by,
  - Remove printing of pointer to last user, which refers to code.
---
 mm/slab.c | 23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 183e996dde5ff37a..4e51ef954026bd15 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1584,11 +1584,8 @@ static void print_objinfo(struct kmem_cache *cachep, void *objp, int lines)
 		       *dbg_redzone2(cachep, objp));
 	}
 
-	if (cachep->flags & SLAB_STORE_USER) {
-		pr_err("Last user: [<%p>](%pSR)\n",
-		       *dbg_userword(cachep, objp),
-		       *dbg_userword(cachep, objp));
-	}
+	if (cachep->flags & SLAB_STORE_USER)
+		pr_err("Last user: (%pSR)\n", *dbg_userword(cachep, objp));
 	realobj = (char *)objp + obj_offset(cachep);
 	size = cachep->object_size;
 	for (i = 0; i < size && lines; i += 16, lines--) {
@@ -1621,7 +1618,7 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 			/* Mismatch ! */
 			/* Print header */
 			if (lines == 0) {
-				pr_err("Slab corruption (%s): %s start=%p, len=%d\n",
+				pr_err("Slab corruption (%s): %s start=%px, len=%d\n",
 				       print_tainted(), cachep->name,
 				       realobj, size);
 				print_objinfo(cachep, objp, 0);
@@ -1650,13 +1647,13 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 		if (objnr) {
 			objp = index_to_obj(cachep, page, objnr - 1);
 			realobj = (char *)objp + obj_offset(cachep);
-			pr_err("Prev obj: start=%p, len=%d\n", realobj, size);
+			pr_err("Prev obj: start=%px, len=%d\n", realobj, size);
 			print_objinfo(cachep, objp, 2);
 		}
 		if (objnr + 1 < cachep->num) {
 			objp = index_to_obj(cachep, page, objnr + 1);
 			realobj = (char *)objp + obj_offset(cachep);
-			pr_err("Next obj: start=%p, len=%d\n", realobj, size);
+			pr_err("Next obj: start=%px, len=%d\n", realobj, size);
 			print_objinfo(cachep, objp, 2);
 		}
 	}
@@ -2608,7 +2605,7 @@ static void slab_put_obj(struct kmem_cache *cachep,
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
 		if (get_free_obj(page, i) == objnr) {
-			pr_err("slab: double free detected in cache '%s', objp %p\n",
+			pr_err("slab: double free detected in cache '%s', objp %px\n",
 			       cachep->name, objp);
 			BUG();
 		}
@@ -2772,7 +2769,7 @@ static inline void verify_redzone_free(struct kmem_cache *cache, void *obj)
 	else
 		slab_error(cache, "memory outside object was overwritten");
 
-	pr_err("%p: redzone 1:0x%llx, redzone 2:0x%llx\n",
+	pr_err("%px: redzone 1:0x%llx, redzone 2:0x%llx\n",
 	       obj, redzone1, redzone2);
 }
 
@@ -3078,7 +3075,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		if (*dbg_redzone1(cachep, objp) != RED_INACTIVE ||
 				*dbg_redzone2(cachep, objp) != RED_INACTIVE) {
 			slab_error(cachep, "double free, or memory outside object was overwritten");
-			pr_err("%p: redzone 1:0x%llx, redzone 2:0x%llx\n",
+			pr_err("%px: redzone 1:0x%llx, redzone 2:0x%llx\n",
 			       objp, *dbg_redzone1(cachep, objp),
 			       *dbg_redzone2(cachep, objp));
 		}
@@ -3091,7 +3088,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		cachep->ctor(objp);
 	if (ARCH_SLAB_MINALIGN &&
 	    ((unsigned long)objp & (ARCH_SLAB_MINALIGN-1))) {
-		pr_err("0x%p: not aligned to ARCH_SLAB_MINALIGN=%d\n",
+		pr_err("0x%px: not aligned to ARCH_SLAB_MINALIGN=%d\n",
 		       objp, (int)ARCH_SLAB_MINALIGN);
 	}
 	return objp;
@@ -4283,7 +4280,7 @@ static void show_symbol(struct seq_file *m, unsigned long address)
 		return;
 	}
 #endif
-	seq_printf(m, "%p", (void *)address);
+	seq_printf(m, "%px", (void *)address);
 }
 
 static int leaks_show(struct seq_file *m, void *p)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
