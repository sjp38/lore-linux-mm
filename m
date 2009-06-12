Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3950A6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 07:33:02 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1244805060.7172.126.camel@pasglop>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612100756.GA25185@elte.hu>
	 <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
	 <1244805060.7172.126.camel@pasglop>
Date: Fri, 12 Jun 2009 14:34:00 +0300
Message-Id: <1244806440.30512.51.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Fri, 2009-06-12 at 21:11 +1000, Benjamin Herrenschmidt wrote:
> > OK, but that means we need to fix up every single caller. I'm fine
> > with that but Ben is not. As I am unable to test powerpc here, I am
> > inclined to just merge Ben's patch as "obviously correct".
> > 
> > That does not mean we can't introduce GFP_BOOT later on if we want to. Hmm?
> 
> Again, you are missing part of the picture. Yes we -can- fix all the
> -direct- callers that are obviously only be run at boot time. But what
> about all the indirect ones (or even direct ones) that can be called
> either at boot time or later. vmalloc() is the perfect example (or more
> precisely __get_vm_area() which brings in ioremap etc...) but there are
> many more.

No, I don't think I am. We can fix up the indirect callers too by making
sure we pass the proper GFP flag and propagate that all the way down.
Yes, this is potentially quite a bit of code churn which is why I do see
your patch being the easy way out.

That said, Nick and Ingo seem to think special-casing is questionable
and I haven't had green light for any of the patches yet. The gfp
sanitization patch adds some overhead to kmalloc() and page allocator
paths which is obviously a concern.

So while we continue to discuss this, I'd really like to proceed with
the patch below. At least it should allow people to boot their kernels
(although it will produce warnings). I really don't want to keep other
people waiting for us to reach a resolution on this. Are you OK with
that?

			Pekka

>From f6b726dae91cc74fb3a00f192932ec4fe0949875 Mon Sep 17 00:00:00 2001
From: Pekka Enberg <penberg@cs.helsinki.fi>
Date: Fri, 12 Jun 2009 14:03:06 +0300
Subject: [PATCH] slab: don't enable interrupts during early boot

As explained by Benjamin Herrenschmidt:

  Oh and btw, your patch alone doesn't fix powerpc, because it's missing
  a whole bunch of GFP_KERNEL's in the arch code... You would have to
  grep the entire kernel for things that check slab_is_available() and
  even then you'll be missing some.

  For example, slab_is_available() didn't always exist, and so in the
  early days on powerpc, we used a mem_init_done global that is set form
  mem_init() (not perfect but works in practice). And we still have code
  using that to do the test.

Therefore, mask out __GFP_WAIT in the slab allocators in early boot code to
avoid enabling interrupts.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/slab.h     |    2 ++
 include/linux/slob_def.h |    5 +++++
 include/linux/slub_def.h |    2 ++
 init/main.c              |    1 +
 mm/slab.c                |   22 ++++++++++++++++++++++
 mm/slub.c                |   18 ++++++++++++++++++
 6 files changed, 50 insertions(+), 0 deletions(-)

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
index f46b65d..a785808 100644
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
@@ -2812,6 +2826,10 @@ static int cache_grow(struct kmem_cache *cachep,
 
 	offset *= cachep->colour_off;
 
+	/* Lets avoid crashing in early boot code. */
+	if (WARN_ON_ONCE((local_flags & ~slab_gfp_mask) != 0))
+		local_flags &= slab_gfp_mask;
+
 	if (local_flags & __GFP_WAIT)
 		local_irq_enable();
 
@@ -3237,6 +3255,10 @@ retry:
 	}
 
 	if (!obj) {
+		/* Lets avoid crashing in early boot code. */
+		if (WARN_ON_ONCE((local_flags & ~slab_gfp_mask) != 0))
+			local_flags &= slab_gfp_mask;
+
 		/*
 		 * This allocation will be performed within the constraints
 		 * of the current cpuset / memory policy requirements.
diff --git a/mm/slub.c b/mm/slub.c
index 3964d3c..651bb34 100644
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
@@ -1548,6 +1554,10 @@ new_slab:
 		goto load_freelist;
 	}
 
+	/* Lets avoid crashing in early boot code. */
+	if (WARN_ON_ONCE((gfpflags & ~slab_gfp_mask) != 0))
+		gfpflags &= slab_gfp_mask;
+
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
@@ -3104,6 +3114,14 @@ void __init kmem_cache_init(void)
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
1.6.0.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
