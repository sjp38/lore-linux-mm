Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F11396B038A
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:14:23 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y187so28910316wmy.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:14:23 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 74si14585679wmq.55.2017.03.06.05.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 05:14:22 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id v190so13677299wme.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:14:22 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/7] xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
Date: Mon,  6 Mar 2017 14:14:04 +0100
Message-Id: <20170306131408.9828-4-mhocko@kernel.org>
In-Reply-To: <20170306131408.9828-1-mhocko@kernel.org>
References: <20170306131408.9828-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Brian Foster <bfoster@redhat.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

xfs has defined PF_FSTRANS to declare a scope GFP_NOFS semantic quite
some time ago. We would like to make this concept more generic and use
it for other filesystems as well. Let's start by giving the flag a
more generic name PF_MEMALLOC_NOFS which is in line with an exiting
PF_MEMALLOC_NOIO already used for the same purpose for GFP_NOIO
contexts. Replace all PF_FSTRANS usage from the xfs code in the first
step before we introduce a full API for it as xfs uses the flag directly
anyway.

This patch doesn't introduce any functional change.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Brian Foster <bfoster@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xfs/kmem.c             |  4 ++--
 fs/xfs/kmem.h             |  2 +-
 fs/xfs/libxfs/xfs_btree.c |  2 +-
 fs/xfs/xfs_aops.c         |  6 +++---
 fs/xfs/xfs_trans.c        | 12 ++++++------
 include/linux/sched.h     |  2 ++
 6 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index 2dfdc62f795e..e14da724a0b5 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -81,13 +81,13 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
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
index 689f746224e7..d973dbfc2bfa 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -50,7 +50,7 @@ kmem_flags_convert(xfs_km_flags_t flags)
 		lflags = GFP_ATOMIC | __GFP_NOWARN;
 	} else {
 		lflags = GFP_KERNEL | __GFP_NOWARN;
-		if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
+		if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
 			lflags &= ~__GFP_FS;
 	}
 
diff --git a/fs/xfs/libxfs/xfs_btree.c b/fs/xfs/libxfs/xfs_btree.c
index c3decedc9455..3059a3ec7ecb 100644
--- a/fs/xfs/libxfs/xfs_btree.c
+++ b/fs/xfs/libxfs/xfs_btree.c
@@ -2886,7 +2886,7 @@ xfs_btree_split_worker(
 	struct xfs_btree_split_args	*args = container_of(work,
 						struct xfs_btree_split_args, work);
 	unsigned long		pflags;
-	unsigned long		new_pflags = PF_FSTRANS;
+	unsigned long		new_pflags = PF_MEMALLOC_NOFS;
 
 	/*
 	 * we are in a transaction context here, but may also be doing work
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index bf65a9ea8642..330c6019120e 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -189,7 +189,7 @@ xfs_setfilesize_trans_alloc(
 	 * We hand off the transaction to the completion thread now, so
 	 * clear the flag here.
 	 */
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 	return 0;
 }
 
@@ -252,7 +252,7 @@ xfs_setfilesize_ioend(
 	 * thus we need to mark ourselves as being in a transaction manually.
 	 * Similarly for freeze protection.
 	 */
-	current_set_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_set_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 	__sb_writers_acquired(VFS_I(ip)->i_sb, SB_FREEZE_FS);
 
 	/* we abort the update if there was an IO error */
@@ -1021,7 +1021,7 @@ xfs_do_writepage(
 	 * Given that we do not allow direct reclaim to call us, we should
 	 * never be called while in a filesystem transaction.
 	 */
-	if (WARN_ON_ONCE(current->flags & PF_FSTRANS))
+	if (WARN_ON_ONCE(current->flags & PF_MEMALLOC_NOFS))
 		goto redirty;
 
 	/*
diff --git a/fs/xfs/xfs_trans.c b/fs/xfs/xfs_trans.c
index 70f42ea86dfb..f5969c8274fc 100644
--- a/fs/xfs/xfs_trans.c
+++ b/fs/xfs/xfs_trans.c
@@ -134,7 +134,7 @@ xfs_trans_reserve(
 	bool		rsvd = (tp->t_flags & XFS_TRANS_RESERVE) != 0;
 
 	/* Mark this thread as being in a transaction */
-	current_set_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_set_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 
 	/*
 	 * Attempt to reserve the needed disk blocks by decrementing
@@ -144,7 +144,7 @@ xfs_trans_reserve(
 	if (blocks > 0) {
 		error = xfs_mod_fdblocks(tp->t_mountp, -((int64_t)blocks), rsvd);
 		if (error != 0) {
-			current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+			current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 			return -ENOSPC;
 		}
 		tp->t_blk_res += blocks;
@@ -221,7 +221,7 @@ xfs_trans_reserve(
 		tp->t_blk_res = 0;
 	}
 
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 
 	return error;
 }
@@ -914,7 +914,7 @@ __xfs_trans_commit(
 
 	xfs_log_commit_cil(mp, tp, &commit_lsn, regrant);
 
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 	xfs_trans_free(tp);
 
 	/*
@@ -944,7 +944,7 @@ __xfs_trans_commit(
 		if (commit_lsn == -1 && !error)
 			error = -EIO;
 	}
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 	xfs_trans_free_items(tp, NULLCOMMITLSN, !!error);
 	xfs_trans_free(tp);
 
@@ -998,7 +998,7 @@ xfs_trans_cancel(
 		xfs_log_done(mp, tp->t_ticket, NULL, false);
 
 	/* mark this thread as no longer being in a transaction */
-	current_restore_flags_nested(&tp->t_pflags, PF_FSTRANS);
+	current_restore_flags_nested(&tp->t_pflags, PF_MEMALLOC_NOFS);
 
 	xfs_trans_free_items(tp, NULLCOMMITLSN, dirty);
 	xfs_trans_free(tp);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d67eee84fd43..4528f7c9789f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1224,6 +1224,8 @@ extern struct pid *cad_pid;
 #define PF_FREEZER_SKIP		0x40000000	/* Freezer should not count it as freezable */
 #define PF_SUSPEND_TASK		0x80000000      /* This thread called freeze_processes() and should not be frozen */
 
+#define PF_MEMALLOC_NOFS PF_FSTRANS	/* Transition to a more generic GFP_NOFS scope semantic */
+
 /*
  * Only the _current_ task can read/write to tsk->flags, but other
  * tasks can access tsk->flags in readonly mode for example
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
