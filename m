Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 039516B025F
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:56:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so11228812lfg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:56:23 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 191si24535164wmp.42.2016.04.26.04.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 04:56:22 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r12so3774877wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:56:22 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm: add PF_MEMALLOC_NOFS
Date: Tue, 26 Apr 2016 13:56:11 +0200
Message-Id: <1461671772-1269-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

GFP_NOFS context is used for the following 4 reasons currently
	- to prevent from deadlocks when the lock held by the allocation
	  context would be needed during the memory reclaim
	- to prevent from stack overflows during the reclaim because
	  the allocation is performed from a deep context already
	- to prevent lockups when the allocation context depends on
	  other reclaimers to make a forward progress indirectly
	- just in case because this would be safe from the fs POV

Unfortunately overuse of this allocation context brings some problems
to the MM. Memory reclaim is much weaker (especially during heavy FS
metadata workloads), OOM killer cannot be invoked because the MM layer
doesn't have enough information about how much memory is freeable by the
FS layer.

In many cases it is far from clear why the weaker context is even used
and so it might be used unnecessarily. We would like to get rid of
those as much as possible. One way to do that is to use the flag in the
scopes rather than isolated cases. Such a scope is declared when really
necessary, tracked per task and all the allocation requests from within
the context will simply inherit the GFP_NOFS semantic.

Not only this is easier to understand and maintain because there are
much less problematic contexts than specific allocation requests, this
also helps code paths where FS layer interacts with other layers (e.g.
crypto, security modules, MM etc...) and there is no easy way to convey
the allocation context between the layers.

Introduce PF_MEMALLOC_NOFS task specific flag and memalloc_nofs_{save,restore}
API to control the scope. This is basically copying
memalloc_noio_{save,restore} API we have for other restricted allocation
context GFP_NOIO.

Xfs has already had a similar functionality as PF_FSTRANS so let's just
give it a more generic name and make it usable for others as well and
move the GFP_NOFS context tracking to the page allocator. Xfs has its
own accessor functions but let's keep them for now to reduce this patch
as minimum.

This patch shouldn't introduce any functional changes. Xfs code paths
preserve their semantic. kmem_flags_convert() doesn't need to evaluate
the flag anymore because it is the page allocator to care about the
flag. memalloc_noio_flags is renamed to current_gfp_context because it
now cares about both PF_MEMALLOC_NOFS and PF_MEMALLOC_NOIO contexts.

Let's hope that filesystems will drop direct GFP_NOFS (resp. ~__GFP_FS)
usage as much and possible and only use a properly documented
memalloc_nofs_{save,restore} checkpoints where they are appropriate.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.c             |  4 ++--
 fs/xfs/kmem.h             |  2 +-
 fs/xfs/libxfs/xfs_btree.c |  2 +-
 fs/xfs/xfs_aops.c         |  6 +++---
 fs/xfs/xfs_trans.c        | 12 ++++++------
 include/linux/gfp.h       |  8 ++++++++
 include/linux/sched.h     | 32 ++++++++++++++++++++++++++------
 mm/page_alloc.c           |  8 +++++---
 mm/vmscan.c               |  4 ++--
 9 files changed, 54 insertions(+), 24 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index 686ba6fb20dd..73f6ab59c664 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -80,13 +80,13 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
 	 * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
 	 * the filesystem here and potentially deadlocking.
 	 */
-	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
+	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
 		noio_flag = memalloc_noio_save();
 
 	lflags = kmem_flags_convert(flags);
 	ptr = __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
 
-	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
+	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
 		memalloc_noio_restore(noio_flag);
 
 	return ptr;
diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index d1c66e465ca5..b35688a54c9a 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -50,7 +50,7 @@ kmem_flags_convert(xfs_km_flags_t flags)
 		lflags = GFP_ATOMIC | __GFP_NOWARN;
 	} else {
 		lflags = GFP_KERNEL | __GFP_NOWARN;
-		if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
+		if (flags & KM_NOFS)
 			lflags &= ~__GFP_FS;
 	}
 
diff --git a/fs/xfs/libxfs/xfs_btree.c b/fs/xfs/libxfs/xfs_btree.c
index a0eb18ce3ad3..326566f4a131 100644
--- a/fs/xfs/libxfs/xfs_btree.c
+++ b/fs/xfs/libxfs/xfs_btree.c
@@ -2540,7 +2540,7 @@ xfs_btree_split_worker(
 	struct xfs_btree_split_args	*args = container_of(work,
 						struct xfs_btree_split_args, work);
 	unsigned long		pflags;
-	unsigned long		new_pflags = PF_FSTRANS;
+	unsigned long		new_pflags = PF_MEMALLOC_NOFS;
 
 	/*
 	 * we are in a transaction context here, but may also be doing work
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index d12dfcfd0cc8..6d816ff0b763 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -124,7 +124,7 @@ xfs_setfilesize_trans_alloc(
 	 * We hand off the transaction to the completion thread now, so
 	 * clear the flag here.
 	 */
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 	return 0;
 }
 
@@ -169,7 +169,7 @@ xfs_setfilesize_ioend(
 	 * thus we need to mark ourselves as being in a transaction manually.
 	 * Similarly for freeze protection.
 	 */
-	current_set_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_set_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 	__sb_writers_acquired(VFS_I(ip)->i_sb, SB_FREEZE_FS);
 
 	/* we abort the update if there was an IO error */
@@ -979,7 +979,7 @@ xfs_vm_writepage(
 	 * Given that we do not allow direct reclaim to call us, we should
 	 * never be called while in a filesystem transaction.
 	 */
-	if (WARN_ON_ONCE(current->flags & PF_FSTRANS))
+	if (WARN_ON_ONCE(current->flags & PF_MEMALLOC_NOFS))
 		goto redirty;
 
 	/* Is this page beyond the end of the file? */
diff --git a/fs/xfs/xfs_trans.c b/fs/xfs/xfs_trans.c
index 748b16aff45a..1d247366c733 100644
--- a/fs/xfs/xfs_trans.c
+++ b/fs/xfs/xfs_trans.c
@@ -176,7 +176,7 @@ xfs_trans_reserve(
 	bool		rsvd = (tp->t_flags & XFS_TRANS_RESERVE) != 0;
 
 	/* Mark this thread as being in a transaction */
-	current_set_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_set_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 
 	/*
 	 * Attempt to reserve the needed disk blocks by decrementing
@@ -186,7 +186,7 @@ xfs_trans_reserve(
 	if (blocks > 0) {
 		error = xfs_mod_fdblocks(tp->t_mountp, -((int64_t)blocks), rsvd);
 		if (error != 0) {
-			current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+			current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 			return -ENOSPC;
 		}
 		tp->t_blk_res += blocks;
@@ -263,7 +263,7 @@ xfs_trans_reserve(
 		tp->t_blk_res = 0;
 	}
 
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 
 	return error;
 }
@@ -921,7 +921,7 @@ __xfs_trans_commit(
 
 	xfs_log_commit_cil(mp, tp, &commit_lsn, regrant);
 
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 	xfs_trans_free(tp);
 
 	/*
@@ -951,7 +951,7 @@ __xfs_trans_commit(
 		if (commit_lsn == -1 && !error)
 			error = -EIO;
 	}
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 	xfs_trans_free_items(tp, NULLCOMMITLSN, !!error);
 	xfs_trans_free(tp);
 
@@ -1005,7 +1005,7 @@ xfs_trans_cancel(
 		xfs_log_done(mp, tp->t_ticket, NULL, false);
 
 	/* mark this thread as no longer being in a transaction */
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 
 	xfs_trans_free_items(tp, NULLCOMMITLSN, dirty);
 	xfs_trans_free(tp);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 570383a41853..3ebdbdff44b4 100644
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
index acfc32b30704..e9521dc0475f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2102,9 +2102,9 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
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
@@ -2140,13 +2140,21 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
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
 
@@ -2162,6 +2170,18 @@ static inline void memalloc_noio_restore(unsigned int flags)
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0e2bb8f4ec0b..86bb5d6ddd7d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3801,10 +3801,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
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
 
 	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4a2f4512fca..cfb74de1efa3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2808,7 +2808,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
+		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
 		.order = order,
 		.nodemask = nodemask,
 		.priority = DEF_PRIORITY,
@@ -3656,7 +3656,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
-		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
+		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
 		.order = order,
 		.priority = ZONE_RECLAIM_PRIORITY,
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
