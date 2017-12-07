Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] mm/slab: Do not hash pointers when debugging slab
Date: Thu,  7 Dec 2017 11:17:41 +0100
Message-Id: <1512641861-5113-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C . Harding" <me@tobin.cc>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>
List-ID: <linux-mm.kvack.org>

If CONFIG_DEBUG_SLAB/CONFIG_DEBUG_SLAB_LEAK are enabled, the slab code
prints extra debug information when e.g. corruption is detected.
This includes pointers, which are not very useful when hashed.

Fix this by using %px to print unhashed pointers instead.

Fixes: ad67b74d2469d9b8 ("printk: hash addresses printed with %p")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
It's been ages I needed the above options.  But of course I need them
just after the introduction of address hashing...
---
 mm/slab.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 183e996dde5ff37a..70be5823227dcb3e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1585,7 +1585,7 @@ static void print_objinfo(struct kmem_cache *cachep, void *objp, int lines)
 	}
 
 	if (cachep->flags & SLAB_STORE_USER) {
-		pr_err("Last user: [<%p>](%pSR)\n",
+		pr_err("Last user: [<%px>](%pSR)\n",
 		       *dbg_userword(cachep, objp),
 		       *dbg_userword(cachep, objp));
 	}
@@ -1621,7 +1621,7 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 			/* Mismatch ! */
 			/* Print header */
 			if (lines == 0) {
-				pr_err("Slab corruption (%s): %s start=%p, len=%d\n",
+				pr_err("Slab corruption (%s): %s start=%px, len=%d\n",
 				       print_tainted(), cachep->name,
 				       realobj, size);
 				print_objinfo(cachep, objp, 0);
@@ -1650,13 +1650,13 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
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
@@ -2608,7 +2608,7 @@ static void slab_put_obj(struct kmem_cache *cachep,
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
 		if (get_free_obj(page, i) == objnr) {
-			pr_err("slab: double free detected in cache '%s', objp %p\n",
+			pr_err("slab: double free detected in cache '%s', objp %px\n",
 			       cachep->name, objp);
 			BUG();
 		}
@@ -2772,7 +2772,7 @@ static inline void verify_redzone_free(struct kmem_cache *cache, void *obj)
 	else
 		slab_error(cache, "memory outside object was overwritten");
 
-	pr_err("%p: redzone 1:0x%llx, redzone 2:0x%llx\n",
+	pr_err("%px: redzone 1:0x%llx, redzone 2:0x%llx\n",
 	       obj, redzone1, redzone2);
 }
 
@@ -3078,7 +3078,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		if (*dbg_redzone1(cachep, objp) != RED_INACTIVE ||
 				*dbg_redzone2(cachep, objp) != RED_INACTIVE) {
 			slab_error(cachep, "double free, or memory outside object was overwritten");
-			pr_err("%p: redzone 1:0x%llx, redzone 2:0x%llx\n",
+			pr_err("%px: redzone 1:0x%llx, redzone 2:0x%llx\n",
 			       objp, *dbg_redzone1(cachep, objp),
 			       *dbg_redzone2(cachep, objp));
 		}
@@ -3091,7 +3091,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		cachep->ctor(objp);
 	if (ARCH_SLAB_MINALIGN &&
 	    ((unsigned long)objp & (ARCH_SLAB_MINALIGN-1))) {
-		pr_err("0x%p: not aligned to ARCH_SLAB_MINALIGN=%d\n",
+		pr_err("0x%px: not aligned to ARCH_SLAB_MINALIGN=%d\n",
 		       objp, (int)ARCH_SLAB_MINALIGN);
 	}
 	return objp;
@@ -4283,7 +4283,7 @@ static void show_symbol(struct seq_file *m, unsigned long address)
 		return;
 	}
 #endif
-	seq_printf(m, "%p", (void *)address);
+	seq_printf(m, "%px", (void *)address);
 }
 
 static int leaks_show(struct seq_file *m, void *p)
-- 
2.7.4
