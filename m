Message-Id: <20070427202901.086932505@sgi.com>
References: <20070427202137.613097336@sgi.com>
Date: Fri, 27 Apr 2007 13:21:44 -0700
From: clameter@sgi.com
Subject: [patch 7/8] SLUB printk cleanup: Fix up printks in the resiliency check
Content-Disposition: inline; filename=slub_printk_resilience
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---
 mm/slub.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-04-27 10:36:34.000000000 -0700
+++ slub/mm/slub.c	2007-04-27 10:37:42.000000000 -0700
@@ -2613,6 +2613,8 @@ __initcall(cpucache_init);
 #endif
 
 #ifdef SLUB_RESILIENCY_TEST
+static unsigned long validate_slab_cache(struct kmem_cache *s);
+
 static void resiliency_test(void)
 {
 	u8 *p;
@@ -2624,7 +2626,7 @@ static void resiliency_test(void)
 	p = kzalloc(16, GFP_KERNEL);
 	p[16] = 0x12;
 	printk(KERN_ERR "\n1. kmalloc-16: Clobber Redzone/next pointer"
-			" 0x12->%p\n\n", p + 16);
+			" 0x12->0x%p\n\n", p + 16);
 
 	validate_slab_cache(kmalloc_caches + 4);
 
@@ -2632,14 +2634,14 @@ static void resiliency_test(void)
 	p = kzalloc(32, GFP_KERNEL);
 	p[32 + sizeof(void *)] = 0x34;
 	printk(KERN_ERR "\n2. kmalloc-32: Clobber next pointer/next slab"
-		 	" 0x34 -> %p\n", p);
+		 	" 0x34 -> -0x%p\n", p);
 	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
 
 	validate_slab_cache(kmalloc_caches + 5);
 	p = kzalloc(64, GFP_KERNEL);
 	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
 	*p = 0x56;
-	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->%p\n",
+	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->0x%p\n",
 									p);
 	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
 	validate_slab_cache(kmalloc_caches + 6);
@@ -2648,19 +2650,19 @@ static void resiliency_test(void)
 	p = kzalloc(128, GFP_KERNEL);
 	kfree(p);
 	*p = 0x78;
-	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->%p\n\n", p);
+	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
 	validate_slab_cache(kmalloc_caches + 7);
 
 	p = kzalloc(256, GFP_KERNEL);
 	kfree(p);
 	p[50] = 0x9a;
-	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->%p\n\n", p);
+	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n", p);
 	validate_slab_cache(kmalloc_caches + 8);
 
 	p = kzalloc(512, GFP_KERNEL);
 	kfree(p);
 	p[512] = 0xab;
-	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->%p\n\n", p);
+	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
 	validate_slab_cache(kmalloc_caches + 9);
 }
 #else

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
