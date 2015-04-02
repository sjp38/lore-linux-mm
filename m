Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 53B276B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 07:53:17 -0400 (EDT)
Received: by obvd1 with SMTP id d1so125324753obv.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 04:53:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fx10si4878415obb.84.2015.04.02.04.53.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Apr 2015 04:53:15 -0700 (PDT)
Subject: Re: [PATCH 0/2] Move away from non-failing small allocations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
	<20150316153843.af945a9e452404c22c4db999@linux-foundation.org>
	<20150317090738.GB28112@dhcp22.suse.cz>
	<201503172305.DIH52162.FOFMFOVJHLOtQS@I-love.SAKURA.ne.jp>
In-Reply-To: <201503172305.DIH52162.FOFMFOVJHLOtQS@I-love.SAKURA.ne.jp>
Message-Id: <201504022053.GJI43271.FSOOOFFMQJHVtL@I-love.SAKURA.ne.jp>
Date: Thu, 2 Apr 2015 20:53:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, david@fromorbit.com
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > We are seeing issues with the fs code now because the test cases which
> > led to the current discussion exercise FS code. The code which does
> > lock(); kmalloc(GFP_KERNEL) is not reduced there though. I am pretty sure
> > we can find other subsystems if we try hard enough.
> 
> I'm expecting for patches which avoids deadlock by lock(); kmalloc(GFP_KERNEL).
> 
> > > static inline void enter_fs_code(struct super_block *sb)
> > > {
> > > 	if (sb->my_small_allocations_can_fail)
> > > 		current->small_allocations_can_fail++;
> > > }
> > > 
> > > that way (or something similar) we can select the behaviour on a per-fs
> > > basis and the rest of the kernel remains unaffected.  Other subsystems
> > > can opt in as well.
> > 
> > This is basically leading to GFP_MAYFAIL which is completely backwards
> > (the hard requirement should be an exception not a default rule).
> > I really do not want to end up with stuffing random may_fail annotations
> > all over the kernel.
> > 
> 
> I wish that GFP_NOFS / GFP_NOIO regions are annotated with
> 
>   static inline void enter_fs_code(void)
>   {
>   #ifdef CONFIG_DEBUG_GFP_FLAGS
>   	current->in_fs_code++;
>   #endif
>   }
> 
>   static inline void leave_fs_code(void)
>   {
>   #ifdef CONFIG_DEBUG_GFP_FLAGS
>   	current->in_fs_code--;
>   #endif
>   }
> 
>   static inline void enter_io_code(void)
>   {
>   #ifdef CONFIG_DEBUG_GFP_FLAGS
>   	current->in_io_code++;
>   #endif
>   }
> 
>   static inline void leave_io_code(void)
>   {
>   #ifdef CONFIG_DEBUG_GFP_FLAGS
>   	current->in_io_code--;
>   #endif
>   }
> 
> so that inappropriate GFP_KERNEL usage inside GFP_NOFS region are catchable
> by doing
> 
>   struct page *
>   __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>                           struct zonelist *zonelist, nodemask_t *nodemask)
>   {
>   	struct zoneref *preferred_zoneref;
>   	struct page *page = NULL;
>   	unsigned int cpuset_mems_cookie;
>   	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
>   	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>   	struct alloc_context ac = {
>   		.high_zoneidx = gfp_zone(gfp_mask),
>   		.nodemask = nodemask,
>   		.migratetype = gfpflags_to_migratetype(gfp_mask),
>   	};
>   	
>   	gfp_mask &= gfp_allowed_mask;
>  +#ifdef CONFIG_DEBUG_GFP_FLAGS
>  +	WARN_ON(current->in_fs_code & (gfp_mask & __GFP_FS));
>  +	WARN_ON(current->in_io_code & (gfp_mask & __GFP_IO));
>  +#endif
>   
>   	lockdep_trace_alloc(gfp_mask);
>   
> 
> . It is difficult for non-fs developers to determine whether they need to use
> GFP_NOFS than GFP_KERNEL in their code. An example is seen at
> http://marc.info/?l=linux-security-module&m=138556479607024&w=2 .

I didn't receive responses about idea of annotating GFP_NOFS/GFP_NOIO
sections. Therefore, I wrote a patch shown below.

Dave and Michal, can we assume that a thread which initiated a
GFP_NOFS/GFP_NOIO section always terminates that section (as with
rcu_read_lock()/rcu_read_unlock()) ? If we can't assume it,
mask_gfp_flags() in below patch cannot work.
----------------------------------------
>From 0b18f21c9c9aef2353d355afc83b2a2193bbced7 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 2 Apr 2015 16:47:47 +0900
Subject: [PATCH] Add macros for annotating GFP_NOFS/GFP_NOIO allocations.

While there are rules for when to use GFP_NOFS or GFP_NOIO, there are
locations where GFP_KERNEL is by error used. Such incorrect usage may
cause deadlock under memory pressure. But it is difficult for non-fs
developers to determine whether they need to use GFP_NOFS than GFP_KERNEL
in their code. Also, it is difficult to hit the deadlock caused by such
incorrect usage. Therefore, this patch introduces 4 macros for annotating
the duration where GFP_NOFS or GFP_NOIO needs to be used.

  enter_fs_code() is for annotating that allocations with __GFP_FS are
  not permitted until corresponding leave_fs_code() is called.

  leave_fs_code() is for annotating that allocations with __GFP_FS are
  permitted from now on.

  enter_io_code() is for annotating that allocations with __GFP_IO are
  not permitted until corresponding leave_io_code() is called.

  leave_io_code() is for annotating that allocations with __GFP_IO are
  permitted from now on.

These macros are no-op unless CONFIG_DEBUG_GFP_FLAGS is defined.

Note that this patch does not insert these macros into GFP_NOFS/GFP_NOIO
users. Inserting these macros with appropriate comments are up to
GFP_NOFS/GFP_NOIO users who know the dependency well.

This patch also introduces 1 function which makes use of these macros
when CONFIG_DEBUG_GFP_FLAGS is defined.

  mask_gfp_flags() is for checking and printing warnings when __GFP_FS is
  used between enter_fs_code() and leave_fs_code() or __GFP_IO is used
  between enter_io_code() and leave_io_code().

  If GFP_KERNEL allocation is requested between enter_fs_code() and
  leave_fs_code(), a warning message

    GFP_FS allocation ($gfp_mask) is unsafe for this context

  is reported with a backtrace.

  If GFP_KERNEL or GFP_NOFS allocation is requested between enter_io_code()
  and leave_io_code(), a warning message

    GFP_IO allocation ($gfp_mask) is unsafe for this context

  is reported with a backtrace.

Note that currently mask_gfp_flags() cannot work unless gfp_allowed_mask
is involved. That is, mask_gfp_flags() cannot work if memory allocation
can be handled by e.g. returning partial memory from already allocated
pages. Handling such cases is deferred to future patches.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/gfp.h   | 17 +++++++++++++++++
 include/linux/sched.h |  4 ++++
 mm/Kconfig.debug      |  7 +++++++
 mm/page_alloc.c       | 17 ++++++++++++++++-
 mm/slab.c             |  4 ++--
 mm/slob.c             |  4 ++--
 mm/slub.c             |  6 +++---
 7 files changed, 51 insertions(+), 8 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 51bd1e7..97654ff 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -421,4 +421,21 @@ extern void init_cma_reserved_pageblock(struct page *page);
 
 #endif
 
+#ifdef CONFIG_DEBUG_GFP_FLAGS
+#define enter_fs_code() { current->in_fs_code++; }
+#define leave_fs_code() { current->in_fs_code--; }
+#define enter_io_code() { current->in_io_code++; }
+#define leave_io_code() { current->in_io_code--; }
+extern gfp_t mask_gfp_flags(gfp_t gfp_mask);
+#else
+#define enter_fs_code() do { } while (0)
+#define leave_fs_code() do { } while (0)
+#define enter_io_code() do { } while (0)
+#define leave_io_code() do { } while (0)
+static inline gfp_t mask_gfp_flags(gfp_t gfp_mask)
+{
+	return gfp_mask & gfp_allowed_mask;
+}
+#endif
+
 #endif /* __LINUX_GFP_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a419b65..ebaf817 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1710,6 +1710,10 @@ struct task_struct {
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
 	unsigned long	task_state_change;
 #endif
+#ifdef CONFIG_DEBUG_GFP_FLAGS
+	unsigned char in_fs_code;
+	unsigned char in_io_code;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 957d3da..0f9ad6f 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -28,3 +28,10 @@ config DEBUG_PAGEALLOC
 
 config PAGE_POISONING
 	bool
+
+config DEBUG_GFP_FLAGS
+	bool "Check GFP flags passed to memory allocators"
+	depends on DEBUG_KERNEL
+	---help---
+	  Track and warn about incorrect use of __GFP_FS or __GFP_IO
+	  memory allocations.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40e2942..239b068 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2794,6 +2794,21 @@ got_pg:
 	return page;
 }
 
+#ifdef CONFIG_DEBUG_GFP_FLAGS
+gfp_t mask_gfp_flags(gfp_t gfp_mask)
+{
+	if (gfp_mask & __GFP_WAIT) {
+		WARN((gfp_mask & __GFP_FS) && current->in_fs_code,
+		     "GFP_FS allocation (0x%x) is unsafe for this context\n",
+		     gfp_mask);
+		WARN((gfp_mask & __GFP_IO) && current->in_io_code,
+		     "GFP_IO allocation (0x%x) is unsafe for this context\n",
+		     gfp_mask);
+	}
+	return gfp_mask & gfp_allowed_mask;
+}
+#endif
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -2812,7 +2827,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		.migratetype = gfpflags_to_migratetype(gfp_mask),
 	};
 
-	gfp_mask &= gfp_allowed_mask;
+	gfp_mask = mask_gfp_flags(gfp_mask);
 
 	lockdep_trace_alloc(gfp_mask);
 
diff --git a/mm/slab.c b/mm/slab.c
index c4b89ea..8a73788 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3136,7 +3136,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	void *ptr;
 	int slab_node = numa_mem_id();
 
-	flags &= gfp_allowed_mask;
+	flags = mask_gfp_flags(flags);
 
 	lockdep_trace_alloc(flags);
 
@@ -3224,7 +3224,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	unsigned long save_flags;
 	void *objp;
 
-	flags &= gfp_allowed_mask;
+	flags = mask_gfp_flags(flags);
 
 	lockdep_trace_alloc(flags);
 
diff --git a/mm/slob.c b/mm/slob.c
index 94a7fed..c731eb4 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -430,7 +430,7 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 	int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 	void *ret;
 
-	gfp &= gfp_allowed_mask;
+	gfp = mask_gfp_flags(gfp);
 
 	lockdep_trace_alloc(gfp);
 
@@ -536,7 +536,7 @@ void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
 
-	flags &= gfp_allowed_mask;
+	flags = mask_gfp_flags(flags);
 
 	lockdep_trace_alloc(flags);
 
diff --git a/mm/slub.c b/mm/slub.c
index 82c4737..60fe0a9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1263,7 +1263,7 @@ static inline void kfree_hook(const void *x)
 static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
 						     gfp_t flags)
 {
-	flags &= gfp_allowed_mask;
+	flags = mask_gfp_flags(flags);
 	lockdep_trace_alloc(flags);
 	might_sleep_if(flags & __GFP_WAIT);
 
@@ -1276,7 +1276,7 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
 static inline void slab_post_alloc_hook(struct kmem_cache *s,
 					gfp_t flags, void *object)
 {
-	flags &= gfp_allowed_mask;
+	flags = mask_gfp_flags(flags);
 	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
 	memcg_kmem_put_cache(s);
@@ -1339,7 +1339,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	struct kmem_cache_order_objects oo = s->oo;
 	gfp_t alloc_gfp;
 
-	flags &= gfp_allowed_mask;
+	flags = mask_gfp_flags(flags);
 
 	if (flags & __GFP_WAIT)
 		local_irq_enable();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
