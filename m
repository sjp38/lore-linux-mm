From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070413013655.17093.3472.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
References: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 5/5] Resiliency test
Date: Thu, 12 Apr 2007 18:36:55 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Add a test that can be performed on bootup to test the recoverability
from slab corruption.

Note that 2 of those tests are potentially dangerous. Off by default

Signed-off-by: Christoph Lameter <clameter@sgi.com>


Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-12 18:24:44.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-12 18:29:16.000000000 -0700
@@ -109,6 +109,9 @@
  * - Variable sizing of the per node arrays
  */
 
+/* Enable to test recovery from slab corruption on boot */
+#undef SLUB_RESILIENCY_TEST
+
 /*
  * Flags from the regular SLAB that SLUB does not support:
  */
@@ -2591,6 +2594,61 @@ static unsigned long validate_slab_cache
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
+			" 0x12->%p\n\n", p + 16);
+
+	validate_slab_cache(kmalloc_caches + 4);
+
+	/* Hmmm... The next two are dangerous */
+	p = kzalloc(32, GFP_KERNEL);
+	p[32 + sizeof(void *)] = 0x34;
+	printk(KERN_ERR "\n2. kmalloc-32: Clobber next pointer/next slab"
+		 	" 0x34 -> %p\n", p);
+	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
+
+	validate_slab_cache(kmalloc_caches + 5);
+	p = kzalloc(64, GFP_KERNEL);
+	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
+	*p = 0x56;
+	printk(KERN_ERR "\n3. kmalloc-64: corrupting random byte 0x56->%p\n",
+									p);
+	printk(KERN_ERR "If allocated object is overwritten then not detectable\n\n");
+	validate_slab_cache(kmalloc_caches + 6);
+
+	printk(KERN_ERR "\nB. Corruption after free\n");
+	p = kzalloc(128, GFP_KERNEL);
+	kfree(p);
+	*p = 0x78;
+	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->%p\n\n", p);
+	validate_slab_cache(kmalloc_caches + 7);
+
+	p = kzalloc(256, GFP_KERNEL);
+	kfree(p);
+	p[50] = 0x9a;
+	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->%p\n\n", p);
+	validate_slab_cache(kmalloc_caches + 8);
+
+	p = kzalloc(512, GFP_KERNEL);
+	kfree(p);
+	p[512] = 0xab;
+	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->%p\n\n", p);
+	validate_slab_cache(kmalloc_caches + 9);
+}
+#else
+static void resiliency_test(void) {};
+#endif
+
 /*
  * Generate lists of locations where slabcache objects are allocated
  * and freed.
@@ -3317,6 +3375,7 @@ int __init slab_sysfs_init(void)
 		kfree(al);
 	}
 
+	resiliency_test();
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
