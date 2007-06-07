Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-4.corp.sgi.com (Postfix) with ESMTP id 3573961B84
	for <linux-mm@kvack.org>; Thu,  7 Jun 2007 14:43:13 -0700 (PDT)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1HwPlB-0006yM-00
	for <linux-mm@kvack.org>; Thu, 07 Jun 2007 14:43:13 -0700
Date: Thu, 7 Jun 2007 14:43:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Use list_for_each_entry for loops over all slabs (fwd)
Message-ID: <Pine.LNX.4.64.0706071442590.26798@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Forgot to include linux-mm.

---------- Forwarded message ----------
Date: Thu, 7 Jun 2007 14:01:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
To: akpm@linux-foundation.org
Subject: SLUB: Use list_for_each_entry for loops over all slabs

Use list_for_each_entry() instead of list_for_each().

Get rid of for_all_slabs(). It had only one user. So fold it into the 
callback. This also gets rid of cpu_slab_flush.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   51 +++++++++++++--------------------------------------
 1 file changed, 13 insertions(+), 38 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-06-04 20:04:10.000000000 -0700
+++ slub/mm/slub.c	2007-06-04 20:08:01.000000000 -0700
@@ -2582,7 +2582,7 @@ static struct kmem_cache *find_mergeable
 		size_t align, unsigned long flags,
 		void (*ctor)(void *, struct kmem_cache *, unsigned long))
 {
-	struct list_head *h;
+	struct kmem_cache *s;
 
 	if (slub_nomerge || (flags & SLUB_NEVER_MERGE))
 		return NULL;
@@ -2594,10 +2594,7 @@ static struct kmem_cache *find_mergeable
 	align = calculate_alignment(flags, align, size);
 	size = ALIGN(size, align);
 
-	list_for_each(h, &slab_caches) {
-		struct kmem_cache *s =
-			container_of(h, struct kmem_cache, list);
-
+	list_for_each_entry(s, &slab_caches, list) {
 		if (slab_unmergeable(s))
 			continue;
 
@@ -2680,33 +2677,6 @@ void *kmem_cache_zalloc(struct kmem_cach
 EXPORT_SYMBOL(kmem_cache_zalloc);
 
 #ifdef CONFIG_SMP
-static void for_all_slabs(void (*func)(struct kmem_cache *, int), int cpu)
-{
-	struct list_head *h;
-
-	down_read(&slub_lock);
-	list_for_each(h, &slab_caches) {
-		struct kmem_cache *s =
-			container_of(h, struct kmem_cache, list);
-
-		func(s, cpu);
-	}
-	up_read(&slub_lock);
-}
-
-/*
- * Version of __flush_cpu_slab for the case that interrupts
- * are enabled.
- */
-static void cpu_slab_flush(struct kmem_cache *s, int cpu)
-{
-	unsigned long flags;
-
-	local_irq_save(flags);
-	__flush_cpu_slab(s, cpu);
-	local_irq_restore(flags);
-}
-
 /*
  * Use the cpu notifier to insure that the cpu slabs are flushed when
  * necessary.
@@ -2715,13 +2685,21 @@ static int __cpuinit slab_cpuup_callback
 		unsigned long action, void *hcpu)
 {
 	long cpu = (long)hcpu;
+	struct kmem_cache *s;
+	unsigned long flags;
 
 	switch (action) {
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
-		for_all_slabs(cpu_slab_flush, cpu);
+		down_read(&slub_lock);
+		list_for_each_entry(s, &slab_caches, list) {
+			local_irq_save(flags);
+			__flush_cpu_slab(s, cpu);
+			local_irq_restore(flags);
+		}
+		up_read(&slub_lock);
 		break;
 	default:
 		break;
@@ -3744,7 +3722,7 @@ static int sysfs_slab_alias(struct kmem_
 
 static int __init slab_sysfs_init(void)
 {
-	struct list_head *h;
+	struct kmem_cache *s;
 	int err;
 
 	err = subsystem_register(&slab_subsys);
@@ -3755,10 +3733,7 @@ static int __init slab_sysfs_init(void)
 
 	slab_state = SYSFS;
 
-	list_for_each(h, &slab_caches) {
-		struct kmem_cache *s =
-			container_of(h, struct kmem_cache, list);
-
+	list_for_each_entry(s, &slab_caches, list) {
 		err = sysfs_slab_add(s);
 		BUG_ON(err);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
