Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0E276B0069
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:46:44 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so34727207wjc.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:46:44 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id xs6si6846584wjc.244.2016.12.16.04.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 04:46:42 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id he10so14456049wjc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:46:42 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [DEBUG PATCH 1/2] mm, debug: report when GFP_NO{FS,IO} is used explicitly from memalloc_no{fs,io}_{save,restore} context
Date: Fri, 16 Dec 2016 13:46:27 +0100
Message-Id: <20161216124628.26846-2-mhocko@kernel.org>
In-Reply-To: <20161216124628.26846-1-mhocko@kernel.org>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161216124628.26846-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

THIS PATCH IS FOR TESTING ONLY AND NOT MEANT TO HIT LINUS TREE

It is desirable to reduce the direct GFP_NO{FS,IO} usage at minimum and
prefer scope usage defined by memalloc_no{fs,io}_{save,restore} API.

Let's help this process and add a debugging tool to catch when an
explicit allocation request for GFP_NO{FS,IO} is done from the scope
context. The printed stacktrace should help to identify the caller
and evaluate whether it can be changed to use a wider context or whether
it is called from another potentially dangerous context which needs
a scope protection as well.

The checks have to be enabled explicitly by debug_scope_gfp kernel
command line parameter.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h | 14 +++++++++++--
 include/linux/slab.h  |  3 +++
 mm/page_alloc.c       | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 73 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1c9fbcbcfcc8..288946bfc326 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1988,6 +1988,8 @@ struct task_struct {
 	/* A live task holds one reference. */
 	atomic_t stack_refcount;
 #endif
+	unsigned long nofs_caller;
+	unsigned long noio_caller;
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
@@ -2345,6 +2347,8 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
 #define used_math() tsk_used_math(current)
 
+extern void debug_scope_gfp_context(gfp_t gfp_mask);
+
 /*
  * Applies per-task gfp context to the given allocation flags.
  * PF_MEMALLOC_NOIO implies GFP_NOIO
@@ -2363,25 +2367,31 @@ static inline gfp_t current_gfp_context(gfp_t flags)
 	return flags;
 }
 
-static inline unsigned int memalloc_noio_save(void)
+static inline unsigned int __memalloc_noio_save(unsigned long caller)
 {
 	unsigned int flags = current->flags & PF_MEMALLOC_NOIO;
 	current->flags |= PF_MEMALLOC_NOIO;
+	current->noio_caller = caller;
 	return flags;
 }
 
+#define memalloc_noio_save()	__memalloc_noio_save(_RET_IP_)
+
 static inline void memalloc_noio_restore(unsigned int flags)
 {
 	current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flags;
 }
 
-static inline unsigned int memalloc_nofs_save(void)
+static inline unsigned int __memalloc_nofs_save(unsigned long caller)
 {
 	unsigned int flags = current->flags & PF_MEMALLOC_NOFS;
 	current->flags |= PF_MEMALLOC_NOFS;
+	current->nofs_caller = caller;
 	return flags;
 }
 
+#define memalloc_nofs_save()	__memalloc_nofs_save(_RET_IP_)
+
 static inline void memalloc_nofs_restore(unsigned int flags)
 {
 	current->flags = (current->flags & ~PF_MEMALLOC_NOFS) | flags;
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 084b12bad198..6559668e29db 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -477,6 +477,7 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
  */
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
+	debug_scope_gfp_context(flags);
 	if (__builtin_constant_p(size)) {
 		if (size > KMALLOC_MAX_CACHE_SIZE)
 			return kmalloc_large(size, flags);
@@ -517,6 +518,7 @@ static __always_inline int kmalloc_size(int n)
 
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 {
+	debug_scope_gfp_context(flags);
 #ifndef CONFIG_SLOB
 	if (__builtin_constant_p(size) &&
 		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
@@ -575,6 +577,7 @@ int memcg_update_all_caches(int num_memcgs);
  */
 static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
 {
+	debug_scope_gfp_context(flags);
 	if (size != 0 && n > SIZE_MAX / size)
 		return NULL;
 	if (__builtin_constant_p(n) && __builtin_constant_p(size))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e701be6b930a..9e35fb2a8681 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3734,6 +3734,63 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
+static bool debug_scope_gfp;
+
+static int __init enable_debug_scope_gfp(char *unused)
+{
+	debug_scope_gfp = true;
+	return 0;
+}
+
+/*
+ * spit the stack trace if the given gfp_mask clears flags which are context
+ * wide cleared. Such a caller can remove special flags clearing and rely on
+ * the context wide mask.
+ */
+void debug_scope_gfp_context(gfp_t gfp_mask)
+{
+	gfp_t restrict_mask;
+
+	if (likely(!debug_scope_gfp))
+		return;
+
+	/* both NOFS, NOIO are irrelevant when direct reclaim is disabled */
+	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
+		return;
+
+	if (current->flags & PF_MEMALLOC_NOIO)
+		restrict_mask = __GFP_IO;
+	else if ((current->flags & PF_MEMALLOC_NOFS) && (gfp_mask & __GFP_IO))
+		restrict_mask = __GFP_FS;
+	else
+		return;
+
+	if ((gfp_mask & restrict_mask) != restrict_mask) {
+		/*
+		 * If you see this this warning then the code does:
+		 * memalloc_no{fs,io}_save()
+		 * ...
+		 *    foo()
+		 *      alloc_page(GFP_NO{FS,IO})
+		 * ...
+		 * memalloc_no{fs,io}_restore()
+		 *
+		 * allocation which is unnecessary because the scope gfp
+		 * context will do that for all allocation requests already.
+		 * If foo() is called from multiple contexts then make sure other
+		 * contexts are safe wrt. GFP_NO{FS,IO} semantic and either add
+		 * scope protection into particular paths or change the gfp mask
+		 * to GFP_KERNEL.
+		 */
+		pr_info("Unnecesarily specific gfp mask:%#x(%pGg) for the %s task wide context from %ps\n", gfp_mask, &gfp_mask,
+				(current->flags & PF_MEMALLOC_NOIO)?"NOIO":"NOFS",
+				(void*)((current->flags & PF_MEMALLOC_NOIO)?current->noio_caller:current->nofs_caller));
+		dump_stack();
+	}
+}
+EXPORT_SYMBOL(debug_scope_gfp_context);
+early_param("debug_scope_gfp", enable_debug_scope_gfp);
+
 /*
  * This is the 'heart' of the zoned buddy allocator.
  */
@@ -3798,6 +3855,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/* First allocation attempt */
+	debug_scope_gfp_context(gfp_mask);
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
 	if (likely(page))
 		goto out;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
