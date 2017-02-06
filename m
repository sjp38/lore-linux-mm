Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 768986B025E
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:07:33 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so19566153wmi.6
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:07:33 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id i204si8200622wma.127.2017.02.06.06.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:07:31 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id c85so22146374wmi.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:07:31 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/6] mm: introduce memalloc_nofs_{save,restore} API
Date: Mon,  6 Feb 2017 15:07:15 +0100
Message-Id: <20170206140718.16222-4-mhocko@kernel.org>
In-Reply-To: <20170206140718.16222-1-mhocko@kernel.org>
References: <20170206140718.16222-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

GFP_NOFS context is used for the following 5 reasons currently
	- to prevent from deadlocks when the lock held by the allocation
	  context would be needed during the memory reclaim
	- to prevent from stack overflows during the reclaim because
	  the allocation is performed from a deep context already
	- to prevent lockups when the allocation context depends on
	  other reclaimers to make a forward progress indirectly
	- just in case because this would be safe from the fs POV
	- silence lockdep false positives

Unfortunately overuse of this allocation context brings some problems
to the MM. Memory reclaim is much weaker (especially during heavy FS
metadata workloads), OOM killer cannot be invoked because the MM layer
doesn't have enough information about how much memory is freeable by the
FS layer.

In many cases it is far from clear why the weaker context is even used
and so it might be used unnecessarily. We would like to get rid of
those as much as possible. One way to do that is to use the flag in
scopes rather than isolated cases. Such a scope is declared when really
necessary, tracked per task and all the allocation requests from within
the context will simply inherit the GFP_NOFS semantic.

Not only this is easier to understand and maintain because there are
much less problematic contexts than specific allocation requests, this
also helps code paths where FS layer interacts with other layers (e.g.
crypto, security modules, MM etc...) and there is no easy way to convey
the allocation context between the layers.

Introduce memalloc_nofs_{save,restore} API to control the scope
of GFP_NOFS allocation context. This is basically copying
memalloc_noio_{save,restore} API we have for other restricted allocation
context GFP_NOIO. The PF_MEMALLOC_NOFS flag already exists and it is
just an alias for PF_FSTRANS which has been xfs specific until recently.
There are no more PF_FSTRANS users anymore so let's just drop it.

PF_MEMALLOC_NOFS is now checked in the MM layer and drops __GFP_FS
implicitly same as PF_MEMALLOC_NOIO drops __GFP_IO. memalloc_noio_flags
is renamed to current_gfp_context because it now cares about both
PF_MEMALLOC_NOFS and PF_MEMALLOC_NOIO contexts. Xfs code paths preserve
their semantic. kmem_flags_convert() doesn't need to evaluate the flag
anymore.

This patch shouldn't introduce any functional changes.

Let's hope that filesystems will drop direct GFP_NOFS (resp. ~__GFP_FS)
usage as much as possible and only use a properly documented
memalloc_nofs_{save,restore} checkpoints where they are appropriate.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.h            |  2 +-
 include/linux/gfp.h      |  8 ++++++++
 include/linux/sched.h    | 34 ++++++++++++++++++++++++++--------
 kernel/locking/lockdep.c |  2 +-
 mm/page_alloc.c          | 10 ++++++----
 mm/vmscan.c              |  6 +++---
 6 files changed, 45 insertions(+), 17 deletions(-)

diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index d973dbfc2bfa..ae08cfd9552a 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -50,7 +50,7 @@ kmem_flags_convert(xfs_km_flags_t flags)
 		lflags = GFP_ATOMIC | __GFP_NOWARN;
 	} else {
 		lflags = GFP_KERNEL | __GFP_NOWARN;
-		if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
+		if (flags & KM_NOFS)
 			lflags &= ~__GFP_FS;
 	}
 
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 978232a3b4ae..2bfcfd33e476 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -210,8 +210,16 @@ struct vm_area_struct;
  *
  * GFP_NOIO will use direct reclaim to discard clean pages or slab pages
  *   that do not require the starting of any physical IO.
+ *   Please try to avoid using this flag directly and instead use
+ *   memalloc_noio_{save,restore} to mark the whole scope which cannot
+ *   perform any IO with a short explanation why. All allocation requests
+ *   will inherit GFP_NOIO implicitly.
  *
  * GFP_NOFS will use direct reclaim but will not use any filesystem interfaces.
+ *   Please try to avoid using this flag directly and instead use
+ *   memalloc_nofs_{save,restore} to mark the whole scope which cannot/shouldn't
+ *   recurse into the FS layer with a short explanation why. All allocation
+ *   requests will inherit GFP_NOFS implicitly.
  *
  * GFP_USER is for userspace allocations that also need to be directly
  *   accessibly by the kernel or hardware. It is typically used by hardware
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5be9818e9bd9..6573e9f04aed 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2299,9 +2299,9 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define PF_USED_ASYNC	0x00004000	/* used async_schedule*(), used by module init */
 #define PF_NOFREEZE	0x00008000	/* this thread should not be frozen */
 #define PF_FROZEN	0x00010000	/* frozen for system suspend */
-#define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
-#define PF_KSWAPD	0x00040000	/* I am kswapd */
-#define PF_MEMALLOC_NOIO 0x00080000	/* Allocating memory without IO involved */
+#define PF_KSWAPD	0x00020000	/* I am kswapd */
+#define PF_MEMALLOC_NOFS 0x00040000	/* All allocation requests will inherit GFP_NOFS */
+#define PF_MEMALLOC_NOIO 0x00080000	/* All allocation requests will inherit GFP_NOIO */
 #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
 #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
@@ -2312,8 +2312,6 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezable */
 #define PF_SUSPEND_TASK 0x80000000      /* this thread called freeze_processes and should not be frozen */
 
-#define PF_MEMALLOC_NOFS PF_FSTRANS	/* Transition to a more generic GFP_NOFS scope semantic */
-
 /*
  * Only the _current_ task can read/write to tsk->flags, but other
  * tasks can access tsk->flags in readonly mode for example
@@ -2339,13 +2337,21 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
 #define used_math() tsk_used_math(current)
 
-/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags
- * __GFP_FS is also cleared as it implies __GFP_IO.
+/*
+ * Applies per-task gfp context to the given allocation flags.
+ * PF_MEMALLOC_NOIO implies GFP_NOIO
+ * PF_MEMALLOC_NOFS implies GFP_NOFS
  */
-static inline gfp_t memalloc_noio_flags(gfp_t flags)
+static inline gfp_t current_gfp_context(gfp_t flags)
 {
+	/*
+	 * NOIO implies both NOIO and NOFS and it is a weaker context
+	 * so always make sure it makes precendence
+	 */
 	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
 		flags &= ~(__GFP_IO | __GFP_FS);
+	else if (unlikely(current->flags & PF_MEMALLOC_NOFS))
+		flags &= ~__GFP_FS;
 	return flags;
 }
 
@@ -2361,6 +2367,18 @@ static inline void memalloc_noio_restore(unsigned int flags)
 	current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flags;
 }
 
+static inline unsigned int memalloc_nofs_save(void)
+{
+	unsigned int flags = current->flags & PF_MEMALLOC_NOFS;
+	current->flags |= PF_MEMALLOC_NOFS;
+	return flags;
+}
+
+static inline void memalloc_nofs_restore(unsigned int flags)
+{
+	current->flags = (current->flags & ~PF_MEMALLOC_NOFS) | flags;
+}
+
 /* Per-process atomic flags. */
 #define PFA_NO_NEW_PRIVS 0	/* May not gain new privileges. */
 #define PFA_SPREAD_PAGE  1      /* Spread page cache over cpuset */
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 7dc2375c3ec7..8ab2319dc398 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -2870,7 +2870,7 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
 		return;
 
 	/* We're only interested __GFP_FS allocations for now */
-	if (!(gfp_mask & __GFP_FS))
+	if (!(gfp_mask & __GFP_FS) || (curr->flags & PF_MEMALLOC_NOFS))
 		return;
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c3358d4f7932..e35f3a750fb9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3964,10 +3964,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		goto out;
 
 	/*
-	 * Runtime PM, block IO and its error handling path can deadlock
-	 * because I/O on the device might not complete.
+	 * Apply scoped allocation constrains. This is mainly about
+	 * GFP_NOFS resp. GFP_NOIO which has to be inherited for all
+	 * allocation requests from a particular context which has
+	 * been marked by memalloc_no{fs,io}_{save,restore}
 	 */
-	alloc_mask = memalloc_noio_flags(gfp_mask);
+	alloc_mask = current_gfp_context(gfp_mask);
 	ac.spread_dirty_pages = false;
 
 	/*
@@ -7425,7 +7427,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		.zone = page_zone(pfn_to_page(start)),
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
-		.gfp_mask = memalloc_noio_flags(gfp_mask),
+		.gfp_mask = current_gfp_context(gfp_mask),
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e60b58f37033..5119b8d983b2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2947,7 +2947,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
+		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
 		.reclaim_idx = gfp_zone(gfp_mask),
 		.order = order,
 		.nodemask = nodemask,
@@ -3027,7 +3027,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	int nid;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
-		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
+		.gfp_mask = (current_gfp_context(gfp_mask) & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
 		.reclaim_idx = MAX_NR_ZONES - 1,
 		.target_mem_cgroup = memcg,
@@ -3721,7 +3721,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	int classzone_idx = gfp_zone(gfp_mask);
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
-		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
+		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
 		.order = order,
 		.priority = NODE_RECLAIM_PRIORITY,
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
