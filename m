Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBED6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 06:29:21 -0400 (EDT)
Date: Fri, 12 Jun 2009 13:30:12 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
In-Reply-To: <20090612101511.GC13607@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0906121328030.32274@melkki.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090612091002.GA32052@elte.hu>
 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
 <20090612100756.GA25185@elte.hu> <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
 <20090612101511.GC13607@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009, Nick Piggin wrote:
> > Hi Ingo,
> > 
> > On Fri, Jun 12, 2009 at 1:07 PM, Ingo Molnar<mingo@elte.hu> wrote:
> > > IMHO such invisible side-channels modifying the semantics of GFP
> > > flags is a bit dubious.
> > >
> > > We could do GFP_INIT or GFP_BOOT. These can imply other useful
> > > modifiers as well: panic-on-failure for example. (this would clean
> > > up a fair amount of init code that currently checks for an panics on
> > > allocation failure.)
> > 
> > OK, but that means we need to fix up every single caller. I'm fine
> > with that but Ben is not. As I am unable to test powerpc here, I am
> > inclined to just merge Ben's patch as "obviously correct".
> 
> I agree with Ingo though that exposing it as a gfp modifier is
> not so good. I just like the implementation to mask off GFP_WAIT
> better, and also prefer not to test system state, but have someone
> just call into slab to tell it not to unconditionally enable
> interrupts.
> 
> > That does not mean we can't introduce GFP_BOOT later on if we want to. Hmm?
> 
> Yes, with sufficient warnings in place, I don't think it should be
> too error prone to clean up remaining code over the course of
> a few releases.

Hmm. This is turning into one epic patch discussion for sure! But here's a 
patch to do what you suggested. With the amount of patches I am 
generating, I'm bound to hit the right one sooner or later, no?-)

			Pekka

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 4880306..219b8fb 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -319,4 +319,6 @@ static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
 	return kmalloc_node(size, flags | __GFP_ZERO, node);
 }
 
+void __init kmem_cache_init_late(void);
+
 #endif	/* _LINUX_SLAB_H */
diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
index 0ec00b3..bb5368d 100644
--- a/include/linux/slob_def.h
+++ b/include/linux/slob_def.h
@@ -34,4 +34,9 @@ static __always_inline void *__kmalloc(size_t size, gfp_t flags)
 	return kmalloc(size, flags);
 }
 
+static inline void kmem_cache_init_late(void)
+{
+	/* Nothing to do */
+}
+
 #endif /* __LINUX_SLOB_DEF_H */
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index be5d40c..4dcbc2c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -302,4 +302,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 }
 #endif
 
+void __init kmem_cache_init_late(void);
+
 #endif /* _LINUX_SLUB_DEF_H */
diff --git a/init/main.c b/init/main.c
index b3e8f14..f6204f7 100644
--- a/init/main.c
+++ b/init/main.c
@@ -640,6 +640,7 @@ asmlinkage void __init start_kernel(void)
 				 "enabled early\n");
 	early_boot_irqs_on();
 	local_irq_enable();
+	kmem_cache_init_late();
 
 	/*
 	 * HACK ALERT! This is early. We're enabling the console before
diff --git a/mm/slab.c b/mm/slab.c
index f46b65d..1fac378 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -304,6 +304,12 @@ struct kmem_list3 {
 };
 
 /*
+ * The slab allocator is initialized with interrupts disabled. Therefore, make
+ * sure early boot allocations don't accidentally enable interrupts.
+ */
+static gfp_t slab_gfp_mask __read_mostly = __GFP_BITS_MASK & ~__GFP_WAIT;
+
+/*
  * Need this for bootstrapping a per node allocator.
  */
 #define NUM_INIT_LISTS (3 * MAX_NUMNODES)
@@ -1654,6 +1660,14 @@ void __init kmem_cache_init(void)
 	 */
 }
 
+void __init kmem_cache_init_late(void)
+{
+	/*
+	 * Interrupts are enabled now so all GFP allocations are safe.
+	 */
+	slab_gfp_mask = __GFP_BITS_MASK;
+}
+
 static int __init cpucache_init(void)
 {
 	int cpu;
@@ -3237,6 +3251,8 @@ retry:
 	}
 
 	if (!obj) {
+		local_flags &= slab_gfp_mask;
+
 		/*
 		 * This allocation will be performed within the constraints
 		 * of the current cpuset / memory policy requirements.
@@ -3354,12 +3370,14 @@ __cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	unsigned long save_flags;
 	void *ptr;
 
+	flags &= slab_gfp_mask;
+
 	lockdep_trace_alloc(flags);
 
 	if (slab_should_failslab(cachep, flags))
 		return NULL;
 
-	cache_alloc_debugcheck_before(cachep, flags);
+	cache_alloc_debugcheck_before(cachep, flags & slab_gfp_flags);
 	local_irq_save(save_flags);
 
 	if (unlikely(nodeid == -1))
@@ -3434,6 +3452,8 @@ __cache_alloc(struct kmem_cache *cachep, gfp_t flags, void *caller)
 	unsigned long save_flags;
 	void *objp;
 
+	flags &= slab_gfp_flags;
+
 	lockdep_trace_alloc(flags);
 
 	if (slab_should_failslab(cachep, flags))
diff --git a/mm/slub.c b/mm/slub.c
index 3964d3c..c09cb98 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -178,6 +178,12 @@ static enum {
 	SYSFS		/* Sysfs up */
 } slab_state = DOWN;
 
+/*
+ * The slab allocator is initialized with interrupts disabled. Therefore, make
+ * sure early boot allocations don't accidentally enable interrupts.
+ */
+static gfp_t slab_gfp_mask __read_mostly = __GFP_BITS_MASK & ~__GFP_WAIT;
+
 /* A list of all slab caches on the system */
 static DECLARE_RWSEM(slub_lock);
 static LIST_HEAD(slab_caches);
@@ -1595,6 +1601,8 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
 	unsigned long flags;
 	unsigned int objsize;
 
+	gfpflags &= slab_gfp_mask;
+
 	lockdep_trace_alloc(gfpflags);
 	might_sleep_if(gfpflags & __GFP_WAIT);
 
@@ -3104,6 +3112,14 @@ void __init kmem_cache_init(void)
 		nr_cpu_ids, nr_node_ids);
 }
 
+void __init kmem_cache_init_late(void)
+{
+	/*
+	 * Interrupts are enabled now so all GFP allocations are safe.
+	 */
+	slab_gfp_mask = __GFP_BITS_MASK;
+}
+
 /*
  * Find a mergeable slab cache
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
