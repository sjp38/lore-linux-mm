Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C6FED8D003E
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 22:28:07 -0400 (EDT)
Message-ID: <20110316022805.27735.qmail@science.horizon.com>
From: George Spelvin <linux@horizon.com>
Date: Tue, 15 Mar 2011 21:50:42 -0400
Subject: [PATCH 8/8] mm/slub.c: Enable Kconfig control.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@horizon.com

This introduces three CONFIG_ options:
* CONFIG_RAND_MOD, controlling the drivers/char/random.c support code
* CONFIG_SLUB_RANDOMIZE, enabling the support code
* CONFIG_SLUB_RANDOMIZE_BY_DEFAULT

Randomization may be enabled in three ways:
* By writing 1 to /sys/kernel/slab/$NAME/randomize
* By using the "r" flag in the slub_debug option
* By enabling CONFIG_SLUB_RANDOMIZE_BY_DEFAULT

The feature is independent of SLUB_DEBUG.
---
 drivers/char/Kconfig   |    4 ++++
 drivers/char/random.c  |    6 ++++++
 include/linux/random.h |    2 ++
 include/linux/slab.h   |    5 +++++
 init/Kconfig           |   37 +++++++++++++++++++++++++++++++++++--
 mm/slub.c              |   21 ++++++++++++++++++++-
 6 files changed, 72 insertions(+), 3 deletions(-)

diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index b7980a83..d62a188 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -797,6 +797,10 @@ config NWFLASH
 
 	  If you're not sure, say N.
 
+# selected by SLUB_RANDOMIZE if needed.
+config RAND_MOD
+	boolean
+
 source "drivers/char/hw_random/Kconfig"
 
 config NVRAM
diff --git a/drivers/char/random.c b/drivers/char/random.c
index fc36a98..cf7d71e 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1626,8 +1626,10 @@ EXPORT_SYMBOL(secure_dccp_sequence_number);
  */
 struct cpu_random {
 	u32 hash[4];
+#ifdef CONFIG_RAND_MOD
 	u32 lim, x;
 	int avail;	/* Trailing bytes of hash[] available for seed */
+#endif
 };
 DEFINE_PER_CPU(struct cpu_random, get_random_int_data);
 static u32 __get_random_int(u32 *hash)
@@ -1648,11 +1650,14 @@ unsigned int get_random_int(void)
 	struct cpu_random *r = &get_cpu_var(get_random_int_data);
 	u32 ret = __get_random_int(r->hash);
 
+#ifdef CONFIG_RAND_MOD
 	r->avail = 8;
+#endif
 	put_cpu_var(r);
 	return ret;
 }
 
+#ifdef CONFIG_RAND_MOD
 struct cpu_random *
 get_random_mod_start(void)
 {
@@ -1712,6 +1717,7 @@ get_random_mod_stop(struct cpu_random *r)
 {
 	put_cpu_var(r);
 }
+#endif
 
 /*
  * randomize_range() returns a start address such that
diff --git a/include/linux/random.h b/include/linux/random.h
index 2e1c227..769b2f6 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -84,10 +84,12 @@ unsigned long randomize_range(unsigned long start, unsigned long end, unsigned l
  * They use per-CPU data, so preemption is disabled in the _start
  * function and re-enabled in _stop.
  */
+#ifdef CONFIG_RAND_MOD
 struct cpu_random;	/* Opaque to acllers of this interface */
 struct cpu_random *get_random_mod_start(void);
 unsigned get_random_mod(struct cpu_random *r, unsigned m);
 void get_random_mod_stop(struct cpu_random *r);
+#endif
 
 u32 random32(void);
 void srandom32(u32 seed);
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 8e812f1..45931f8 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -80,7 +80,12 @@
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
 
+#ifdef CONFIG_SLUB_RANDOMIZE
+/* Currently only supported by SLUB, this could be generalized if useful. */
 #define SLAB_RANDOMIZE		0x04000000UL	/* Randomize allocation order */
+#else
+#define SLAB_RANDOMIZE		0UL
+#endif
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
  *
diff --git a/init/Kconfig b/init/Kconfig
index be788c0..7ccb2ea 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1180,8 +1180,41 @@ config SLUB_DEBUG
 	help
 	  SLUB has extensive debug support features. Disabling these can
 	  result in significant savings in code size. This also disables
-	  SLUB sysfs support. /sys/slab will not exist and there will be
-	  no support for cache validation etc.
+	  SLUB sysfs support. /sys/kernel/slab will not exist and there
+	  will be no support for cache validation etc.
+
+config SLUB_RANDOMIZE
+	default n
+	bool "Enable SLUB randomization support"
+	depends on SLUB
+	select CONFIG_RAND_MOD
+	help
+	  This feature randomizes the order of allocation of kernel
+	  objects within pages.  To be precise, it shuffles the initial
+	  free list of each newly allocated slab page in random order.
+
+	  The intention is to impede buffer overrun attacks against kernel
+	  objects.  It will not always work; In many cases, the attacker
+	  can simply allocate hundreds of objects before triggering the
+	  overrun, and test them all to find which was corrupted.
+	  (See discussion at http://marc.info/?t=129917479800001)
+
+	  This only enables the code; randomization must be switched
+	  on for each slab via /sys/kernel/slab, the slub_debug kernel
+	  command line ('r' flag), or CONFIG_SLUB_RANDOMIZE_BY_DEFAULT.
+
+	  This is for testing and the very paranoid.  It imposes some
+	  performance cost, and the kernel should not have bugs which
+	  allow such attacks anyway.  Say N unless you understand all
+	  of this and still want the feature.
+
+config SLUB_RANDOMIZE_BY_DEFAULT
+	default n
+	bool "Enable SLUB randomization by default"
+	depends on SLUB_RANDOMIZE
+	help
+	  Randomize all SLUB allocations starting at boot.  This can
+	  still be turned off on a per-slab basis using /sys/kernel/slab.
 
 config COMPAT_BRK
 	bool "Disable heap randomization"
diff --git a/mm/slub.c b/mm/slub.c
index 4ba1db4..867ca4f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1031,6 +1031,10 @@ static int __init setup_slub_debug(char *str)
 		case 'a':
 			slub_debug |= SLAB_FAILSLAB;
 			break;
+		case 'r':
+			/* Allowed (but ignored) even if not configured */
+			slub_debug |= SLAB_RANDOMIZE;
+			break;
 		default:
 			printk(KERN_ERR "slub_debug option '%c' "
 				"unknown. skipped\n", *str);
@@ -1181,11 +1185,15 @@ static void setup_object(struct kmem_cache *s, void *object)
 		s->ctor(object);
 }
 
+#ifdef CONFIG_SLUB_RANDOMIZE
 /*
  * Initialize a slab's free list in random order, to make
  * buffer overrun attacks harder.  Using a (moderately) secure
  * random number generator, this ensures an attacker can't
  * figure out which other object an overrun will hit.
+ *
+ * (This should be eliminated as dead code if CONFIG_SLUB_RANDOMIZE
+ * is not set.)
  */
 static void *
 setup_slab_randomized(struct kmem_cache *s, void *start, int count)
@@ -1211,6 +1219,10 @@ setup_slab_randomized(struct kmem_cache *s, void *start, int count)
 
 	return start;
 }
+#else
+/* Should be eliminated as dead code, anyway */
+#define setup_slab_randomized(s, start, count) (start)
+#endif
 
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
@@ -2377,6 +2389,9 @@ static int kmem_cache_open(struct kmem_cache *s,
 	s->ctor = ctor;
 	s->objsize = size;
 	s->align = align;
+#ifdef CONFIG_SLUB_RANDOMIZE_BY_DEFAULT
+	flags |= SLAB_RANDOMIZE;
+#endif
 	s->flags = kmem_cache_flags(size, flags, name, ctor);
 
 	if (!calculate_sizes(s, -1))
@@ -4192,6 +4207,7 @@ static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
 SLAB_ATTR(failslab);
 #endif
 
+#if CONFIG_SLUB_RANDOMIZE
 static ssize_t randomize_show(struct kmem_cache *s, char *buf)
 {
 	return flag_show(s, buf, SLAB_RANDOMIZE);
@@ -4203,6 +4219,7 @@ static ssize_t randomize_store(struct kmem_cache *s,
 	return flag_store(s, buf, length, SLAB_RANDOMIZE);
 }
 SLAB_ATTR(randomize);
+#endif
 
 static ssize_t shrink_show(struct kmem_cache *s, char *buf)
 {
@@ -4336,8 +4353,10 @@ static struct attribute *slab_attrs[] = {
 	&hwcache_align_attr.attr,
 	&reclaim_account_attr.attr,
 	&destroy_by_rcu_attr.attr,
-	&randomize_attr.attr,
 	&shrink_attr.attr,
+#ifdef CONFIG_SLUB_RANDOMIZE
+	&randomize_attr.attr,
+#endif
 #ifdef CONFIG_SLUB_DEBUG
 	&total_objects_attr.attr,
 	&slabs_attr.attr,
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
