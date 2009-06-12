Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7696B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 01:07:18 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1244780756.7172.58.camel@pasglop>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 15:07:15 +1000
Message-Id: <1244783235.7172.61.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 14:25 +1000, Benjamin Herrenschmidt wrote:

> I'll cook up a patch that defines a global bitmask of "forbidden" GFP
> bits and see how things go.

>From ad87215e01b257ccc1af64aa9d5776ace580dea3 Mon Sep 17 00:00:00 2001
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 12 Jun 2009 15:03:47 +1000
Subject: [PATCH] Sanitize "gfp" flags during boot

With the recent shuffle of initialization order to move memory related
inits earlier, various subtle breakage was introduced in archs like
powerpc due to code somewhat assuming that GFP_KERNEL can be used as
soon as the allocators are up. This is not true because any __GFP_WAIT
allocation will cause interrupts to be enabled, which can be fatal if
it happens too early.

This isn't trivial to fix on every call site. For example, powerpc's
ioremap implementation needs to be called early. For that, it uses two
different mechanisms to carve out virtual space. Before memory init,
by moving down VMALLOC_END, and then, by calling get_vm_area().
Unfortunately, the later does GFK_KERNEL allocations. But we can't do
anything else because once vmalloc's been initialized, we can no longer
safely move VMALLOC_END to carve out space.

There are other examples, wehere can can be called either very early
or later on when devices are hot-plugged. It would be a major pain for
such code to have to "know" whether it's in a context where it should
use GFP_KERNEL or GFP_NOWAIT.

Finally, by having the ability to silently removed __GFP_WAIT from
allocations, we pave the way for suspend-to-RAM to use that feature
to also remove __GFP_IO from allocations done after suspending devices
has started. This is important because such allocations may hang if
devices on the swap-out path have been suspended, but not-yet suspended
drivers don't know about it, and may deadlock themselves by being hung
into a kmalloc somewhere while holding a mutex for example.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/gfp.h |    8 ++++++++
 init/main.c         |    5 +++++
 mm/page_alloc.c     |    5 +++++
 mm/slab.c           |    9 +++++++++
 mm/slub.c           |    3 +++
 5 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0bbc15f..b0f7a22 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -99,6 +99,14 @@ struct vm_area_struct;
 /* 4GB DMA on some platforms */
 #define GFP_DMA32	__GFP_DMA32
 
+/* Illegal bits */
+extern gfp_t gfp_smellybits;
+
+static inline gfp_t gfp_sanitize(gfp_t gfp_flags)
+{
+	return gfp_flags & ~gfp_smellybits;
+}
+
 /* Convert GFP flags to their corresponding migrate type */
 static inline int allocflags_to_migratetype(gfp_t gfp_flags)
 {
diff --git a/init/main.c b/init/main.c
index 5616661..bb812c1 100644
--- a/init/main.c
+++ b/init/main.c
@@ -539,6 +539,9 @@ void __init __weak thread_info_cache_init(void)
  */
 static void __init mm_init(void)
 {
+	/* Degrade everything into GFP_NOWAIT for now */
+	gfp_smellybits = __GFP_WAIT | __GFP_FS | __GFP_IO;
+
 	mem_init();
 	kmem_cache_init();
 	vmalloc_init();
@@ -634,6 +637,8 @@ asmlinkage void __init start_kernel(void)
 		printk(KERN_CRIT "start_kernel(): bug: interrupts were "
 				 "enabled early\n");
 	early_boot_irqs_on();
+	/* GFP_KERNEL allocations are good to go now */
+	gfp_smellybits = 0;
 	local_irq_enable();
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17d5f53..efde0d5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -77,6 +77,8 @@ int percpu_pagelist_fraction;
 int pageblock_order __read_mostly;
 #endif
 
+gfp_t gfp_smellybits;
+
 static void __free_pages_ok(struct page *page, unsigned int order);
 
 /*
@@ -1473,6 +1475,9 @@ __alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
 	unsigned long did_some_progress;
 	unsigned long pages_reclaimed = 0;
 
+	/* Sanitize flags so we don't enable irqs too early during boot */
+	gfp_mask = gfp_sanitize(gfp_mask);
+
 	lockdep_trace_alloc(gfp_mask);
 
 	might_sleep_if(wait);
diff --git a/mm/slab.c b/mm/slab.c
index f46b65d..87b166e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2791,6 +2791,9 @@ static int cache_grow(struct kmem_cache *cachep,
 	gfp_t local_flags;
 	struct kmem_list3 *l3;
 
+	/* Sanitize flags so we don't enable irqs too early during boot */
+	gfp_mask = gfp_sanitize(gfp_mask);
+
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
 	 * critical path in kmem_cache_alloc().
@@ -3212,6 +3215,9 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	void *obj = NULL;
 	int nid;
 
+	/* Sanitize flags so we don't enable irqs too early during boot */
+	gfp_mask = gfp_sanitize(gfp_mask);
+
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
@@ -3434,6 +3440,9 @@ __cache_alloc(struct kmem_cache *cachep, gfp_t flags, void *caller)
 	unsigned long save_flags;
 	void *objp;
 
+	/* Sanitize flags so we don't enable irqs too early during boot */
+	gfp_mask = gfp_sanitize(gfp_mask);
+
 	lockdep_trace_alloc(flags);
 
 	if (slab_should_failslab(cachep, flags))
diff --git a/mm/slub.c b/mm/slub.c
index 3964d3c..5c646f7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1512,6 +1512,9 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	/* We handle __GFP_ZERO in the caller */
 	gfpflags &= ~__GFP_ZERO;
 
+	/* Sanitize flags so we don't enable irqs too early during boot */
+	gfpflags = gfp_sanitize(gfpflags);
+
 	if (!c->page)
 		goto new_slab;
 
-- 
1.6.1.2.14.gf26b5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
