Message-Id: <20070507212409.900835105@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:51 -0700
From: clameter@sgi.com
Subject: [patch 11/17] SLUB: Move resiliency check into SYSFS section
Content-Disposition: inline; filename=move_resiliency_check
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move the resiliency check into the SYSFS section after validate_slab that
is used by the resiliency check. This will avoid a forward declaration.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |  112 ++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 55 insertions(+), 57 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:54:31.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:54:35.000000000 -0700
@@ -2445,63 +2445,6 @@ static struct notifier_block __cpuinitda
 
 #endif
 
-#ifdef SLUB_RESILIENCY_TEST
-static unsigned long validate_slab_cache(struct kmem_cache *s);
-
-static void resiliency_test(void)
-{
-	u8 *p;
-
-	printk(KERN_ERR "SLUB resiliency testing\n");
-	printk(KERN_ERR "-----------------------\n");
-	printk(KERN_ERR "A. Corruption after allocation\n");
-
-	p = kzalloc(16, GFP_KERNEL);
-	p[16] = 0x12;
-	printk(KERN_ERR "\n1. kmalloc-16: Clobber Redzone/next pointer"
-			" 0x12->0x%p\n\n", p + 16);
-
-	validate_slab_cache(kmalloc_caches + 4);
-
-	/* Hmmm... The next two are dangerous */
-	p = kzalloc(32, GFP_KERNEL);
-	p[32 + sizeof(void *)] = 0x34;
-	printk(KERN_ERR "\n2. kmalloc-32: Clobber next pointer/next slab"
-		 	" 0x34 -> -0x%p\n", p);
-	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
-
-	validate_slab_cache(kmalloc_caches + 5);
-	p = kzalloc(64, GFP_KERNEL);
-	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
-	*p = 0x56;
-	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
-									p);
-	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
-	validate_slab_cache(kmalloc_caches + 6);
-
-	printk(KERN_ERR "\nB. Corruption after free\n");
-	p = kzalloc(128, GFP_KERNEL);
-	kfree(p);
-	*p = 0x78;
-	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches + 7);
-
-	p = kzalloc(256, GFP_KERNEL);
-	kfree(p);
-	p[50] = 0x9a;
-	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches + 8);
-
-	p = kzalloc(512, GFP_KERNEL);
-	kfree(p);
-	p[512] = 0xab;
-	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches + 9);
-}
-#else
-static void resiliency_test(void) {};
-#endif
-
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, void *caller)
 {
 	struct kmem_cache *s = get_slab(size, gfpflags);
@@ -2618,6 +2561,61 @@ static unsigned long validate_slab_cache
 	return count;
 }
 
+#ifdef SLUB_RESILIENCY_TEST
+static void resiliency_test(void)
+{
+	u8 *p;
+
+	printk(KERN_ERR "SLUB resiliency testing\n");
+	printk(KERN_ERR "-----------------------\n");
+	printk(KERN_ERR "A. Corruption after allocation\n");
+
+	p = kzalloc(16, GFP_KERNEL);
+	p[16] = 0x12;
+	printk(KERN_ERR "\n1. kmalloc-16: Clobber Redzone/next pointer"
+			" 0x12->0x%p\n\n", p + 16);
+
+	validate_slab_cache(kmalloc_caches + 4);
+
+	/* Hmmm... The next two are dangerous */
+	p = kzalloc(32, GFP_KERNEL);
+	p[32 + sizeof(void *)] = 0x34;
+	printk(KERN_ERR "\n2. kmalloc-32: Clobber next pointer/next slab"
+		 	" 0x34 -> -0x%p\n", p);
+	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
+
+	validate_slab_cache(kmalloc_caches + 5);
+	p = kzalloc(64, GFP_KERNEL);
+	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
+	*p = 0x56;
+	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
+									p);
+	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
+	validate_slab_cache(kmalloc_caches + 6);
+
+	printk(KERN_ERR "\nB. Corruption after free\n");
+	p = kzalloc(128, GFP_KERNEL);
+	kfree(p);
+	*p = 0x78;
+	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
+	validate_slab_cache(kmalloc_caches + 7);
+
+	p = kzalloc(256, GFP_KERNEL);
+	kfree(p);
+	p[50] = 0x9a;
+	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
+	validate_slab_cache(kmalloc_caches + 8);
+
+	p = kzalloc(512, GFP_KERNEL);
+	kfree(p);
+	p[512] = 0xab;
+	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
+	validate_slab_cache(kmalloc_caches + 9);
+}
+#else
+static void resiliency_test(void) {};
+#endif
+
 /*
  * Generate lists of code addresses where slabcache objects are allocated
  * and freed.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
