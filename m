Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD956B0055
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:10 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id n11so10036538plp.13
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3-v6si6097054plk.275.2018.02.04.17.28.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:08 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 61/64] staging/lustre: use generic range lock
Date: Mon,  5 Feb 2018 02:27:51 +0100
Message-Id: <20180205012754.23615-62-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This replaces the in-house version. It also adds the mmrange
and makes use of mm locking wrappers.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/staging/lustre/lustre/llite/Makefile       |   2 +-
 drivers/staging/lustre/lustre/llite/file.c         |  16 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   4 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   4 +-
 drivers/staging/lustre/lustre/llite/range_lock.c   | 240 ---------------------
 drivers/staging/lustre/lustre/llite/range_lock.h   |  83 -------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   7 +-
 7 files changed, 17 insertions(+), 339 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/llite/range_lock.c
 delete mode 100644 drivers/staging/lustre/lustre/llite/range_lock.h

diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 519fd747e3ad..0a6fb56c7e89 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -4,7 +4,7 @@ subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
 obj-$(CONFIG_LUSTRE_FS) += lustre.o
 lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
-	    rw.o rw26.o namei.o symlink.o llite_mmap.o range_lock.o \
+	    rw.o rw26.o namei.o symlink.o llite_mmap.o \
 	    xattr.o xattr_cache.o xattr_security.o \
 	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
 	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o \
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 938b859b6650..a1064da457ae 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1085,10 +1085,10 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 		if (((iot == CIT_WRITE) ||
 		     (iot == CIT_READ && (file->f_flags & O_DIRECT))) &&
 		    !(vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)) {
-			CDEBUG(D_VFSTRACE, "Range lock [%llu, %llu]\n",
-			       range.rl_node.in_extent.start,
-			       range.rl_node.in_extent.end);
-			rc = range_lock(&lli->lli_write_tree, &range);
+			CDEBUG(D_VFSTRACE, "Range lock [%lu, %lu]\n",
+			       range.node.start,
+			       range.node.last);
+			rc = range_write_lock_interruptible(&lli->lli_write_tree, &range);
 			if (rc < 0)
 				goto out;
 
@@ -1098,10 +1098,10 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 		rc = cl_io_loop(env, io);
 		ll_cl_remove(file, env);
 		if (range_locked) {
-			CDEBUG(D_VFSTRACE, "Range unlock [%llu, %llu]\n",
-			       range.rl_node.in_extent.start,
-			       range.rl_node.in_extent.end);
-			range_unlock(&lli->lli_write_tree, &range);
+			CDEBUG(D_VFSTRACE, "Range unlock [%lu, %lu]\n",
+			       range.node.start,
+			       range.node.last);
+			range_write_unlock(&lli->lli_write_tree, &range);
 		}
 	} else {
 		/* cl_io_rw_init() handled IO */
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f68c2e88f12b..7dae3d032769 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -47,10 +47,10 @@
 #include <lustre_intent.h>
 #include <linux/compat.h>
 #include <linux/namei.h>
+#include <linux/range_lock.h>
 #include <linux/xattr.h>
 #include <linux/posix_acl_xattr.h>
 #include "vvp_internal.h"
-#include "range_lock.h"
 
 #ifndef FMODE_EXEC
 #define FMODE_EXEC 0
@@ -919,7 +919,7 @@ int ll_file_mmap(struct file *file, struct vm_area_struct *vma);
 void policy_from_vma(union ldlm_policy_data *policy, struct vm_area_struct *vma,
 		     unsigned long addr, size_t count);
 struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
-			       size_t count);
+			       size_t count, struct range_lock *mmrange);
 
 static inline void ll_invalidate_page(struct page *vmpage)
 {
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index c0533bd6f352..adba30973c82 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -59,12 +59,12 @@ void policy_from_vma(union ldlm_policy_data *policy,
 }
 
 struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
-			       size_t count)
+			       size_t count, struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma, *ret = NULL;
 
 	/* mmap_sem must have been held by caller. */
-	LASSERT(!down_write_trylock(&mm->mmap_sem));
+	LASSERT(!mm_write_trylock(mm, mmrange));
 
 	for (vma = find_vma(mm, addr);
 	    vma && vma->vm_start < (addr + count); vma = vma->vm_next) {
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
deleted file mode 100644
index cc9565f6bfe2..000000000000
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ /dev/null
@@ -1,240 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Range lock is used to allow multiple threads writing a single shared
- * file given each thread is writing to a non-overlapping portion of the
- * file.
- *
- * Refer to the possible upstream kernel version of range lock by
- * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
- *
- * This file could later replaced by the upstream kernel version.
- */
-/*
- * Author: Prakash Surya <surya1@llnl.gov>
- * Author: Bobi Jam <bobijam.xu@intel.com>
- */
-#include "range_lock.h"
-#include <uapi/linux/lustre/lustre_idl.h>
-
-/**
- * Initialize a range lock tree
- *
- * \param tree [in]	an empty range lock tree
- *
- * Pre:  Caller should have allocated the range lock tree.
- * Post: The range lock tree is ready to function.
- */
-void range_lock_tree_init(struct range_lock_tree *tree)
-{
-	tree->rlt_root = NULL;
-	tree->rlt_sequence = 0;
-	spin_lock_init(&tree->rlt_lock);
-}
-
-/**
- * Initialize a range lock node
- *
- * \param lock  [in]	an empty range lock node
- * \param start [in]	start of the covering region
- * \param end   [in]	end of the covering region
- *
- * Pre:  Caller should have allocated the range lock node.
- * Post: The range lock node is meant to cover [start, end] region
- */
-int range_lock_init(struct range_lock *lock, __u64 start, __u64 end)
-{
-	int rc;
-
-	memset(&lock->rl_node, 0, sizeof(lock->rl_node));
-	if (end != LUSTRE_EOF)
-		end >>= PAGE_SHIFT;
-	rc = interval_set(&lock->rl_node, start >> PAGE_SHIFT, end);
-	if (rc)
-		return rc;
-
-	INIT_LIST_HEAD(&lock->rl_next_lock);
-	lock->rl_task = NULL;
-	lock->rl_lock_count = 0;
-	lock->rl_blocking_ranges = 0;
-	lock->rl_sequence = 0;
-	return rc;
-}
-
-static inline struct range_lock *next_lock(struct range_lock *lock)
-{
-	return list_entry(lock->rl_next_lock.next, typeof(*lock), rl_next_lock);
-}
-
-/**
- * Helper function of range_unlock()
- *
- * \param node [in]	a range lock found overlapped during interval node
- *			search
- * \param arg [in]	the range lock to be tested
- *
- * \retval INTERVAL_ITER_CONT	indicate to continue the search for next
- *				overlapping range node
- * \retval INTERVAL_ITER_STOP	indicate to stop the search
- */
-static enum interval_iter range_unlock_cb(struct interval_node *node, void *arg)
-{
-	struct range_lock *lock = arg;
-	struct range_lock *overlap = node2rangelock(node);
-	struct range_lock *iter;
-
-	list_for_each_entry(iter, &overlap->rl_next_lock, rl_next_lock) {
-		if (iter->rl_sequence > lock->rl_sequence) {
-			--iter->rl_blocking_ranges;
-			LASSERT(iter->rl_blocking_ranges > 0);
-		}
-	}
-	if (overlap->rl_sequence > lock->rl_sequence) {
-		--overlap->rl_blocking_ranges;
-		if (overlap->rl_blocking_ranges == 0)
-			wake_up_process(overlap->rl_task);
-	}
-	return INTERVAL_ITER_CONT;
-}
-
-/**
- * Unlock a range lock, wake up locks blocked by this lock.
- *
- * \param tree [in]	range lock tree
- * \param lock [in]	range lock to be deleted
- *
- * If this lock has been granted, relase it; if not, just delete it from
- * the tree or the same region lock list. Wake up those locks only blocked
- * by this lock through range_unlock_cb().
- */
-void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
-{
-	spin_lock(&tree->rlt_lock);
-	if (!list_empty(&lock->rl_next_lock)) {
-		struct range_lock *next;
-
-		if (interval_is_intree(&lock->rl_node)) { /* first lock */
-			/* Insert the next same range lock into the tree */
-			next = next_lock(lock);
-			next->rl_lock_count = lock->rl_lock_count - 1;
-			interval_erase(&lock->rl_node, &tree->rlt_root);
-			interval_insert(&next->rl_node, &tree->rlt_root);
-		} else {
-			/* find the first lock in tree */
-			list_for_each_entry(next, &lock->rl_next_lock,
-					    rl_next_lock) {
-				if (!interval_is_intree(&next->rl_node))
-					continue;
-
-				LASSERT(next->rl_lock_count > 0);
-				next->rl_lock_count--;
-				break;
-			}
-		}
-		list_del_init(&lock->rl_next_lock);
-	} else {
-		LASSERT(interval_is_intree(&lock->rl_node));
-		interval_erase(&lock->rl_node, &tree->rlt_root);
-	}
-
-	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
-			range_unlock_cb, lock);
-	spin_unlock(&tree->rlt_lock);
-}
-
-/**
- * Helper function of range_lock()
- *
- * \param node [in]	a range lock found overlapped during interval node
- *			search
- * \param arg [in]	the range lock to be tested
- *
- * \retval INTERVAL_ITER_CONT	indicate to continue the search for next
- *				overlapping range node
- * \retval INTERVAL_ITER_STOP	indicate to stop the search
- */
-static enum interval_iter range_lock_cb(struct interval_node *node, void *arg)
-{
-	struct range_lock *lock = arg;
-	struct range_lock *overlap = node2rangelock(node);
-
-	lock->rl_blocking_ranges += overlap->rl_lock_count + 1;
-	return INTERVAL_ITER_CONT;
-}
-
-/**
- * Lock a region
- *
- * \param tree [in]	range lock tree
- * \param lock [in]	range lock node containing the region span
- *
- * \retval 0	get the range lock
- * \retval <0	error code while not getting the range lock
- *
- * If there exists overlapping range lock, the new lock will wait and
- * retry, if later it find that it is not the chosen one to wake up,
- * it wait again.
- */
-int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
-{
-	struct interval_node *node;
-	int rc = 0;
-
-	spin_lock(&tree->rlt_lock);
-	/*
-	 * We need to check for all conflicting intervals
-	 * already in the tree.
-	 */
-	interval_search(tree->rlt_root, &lock->rl_node.in_extent,
-			range_lock_cb, lock);
-	/*
-	 * Insert to the tree if I am unique, otherwise I've been linked to
-	 * the rl_next_lock of another lock which has the same range as mine
-	 * in range_lock_cb().
-	 */
-	node = interval_insert(&lock->rl_node, &tree->rlt_root);
-	if (node) {
-		struct range_lock *tmp = node2rangelock(node);
-
-		list_add_tail(&lock->rl_next_lock, &tmp->rl_next_lock);
-		tmp->rl_lock_count++;
-	}
-	lock->rl_sequence = ++tree->rlt_sequence;
-
-	while (lock->rl_blocking_ranges > 0) {
-		lock->rl_task = current;
-		__set_current_state(TASK_INTERRUPTIBLE);
-		spin_unlock(&tree->rlt_lock);
-		schedule();
-
-		if (signal_pending(current)) {
-			range_unlock(tree, lock);
-			rc = -EINTR;
-			goto out;
-		}
-		spin_lock(&tree->rlt_lock);
-	}
-	spin_unlock(&tree->rlt_lock);
-out:
-	return rc;
-}
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
deleted file mode 100644
index 38b2be4e378f..000000000000
--- a/drivers/staging/lustre/lustre/llite/range_lock.h
+++ /dev/null
@@ -1,83 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Range lock is used to allow multiple threads writing a single shared
- * file given each thread is writing to a non-overlapping portion of the
- * file.
- *
- * Refer to the possible upstream kernel version of range lock by
- * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
- *
- * This file could later replaced by the upstream kernel version.
- */
-/*
- * Author: Prakash Surya <surya1@llnl.gov>
- * Author: Bobi Jam <bobijam.xu@intel.com>
- */
-#ifndef _RANGE_LOCK_H
-#define _RANGE_LOCK_H
-
-#include <linux/libcfs/libcfs.h>
-#include <interval_tree.h>
-
-struct range_lock {
-	struct interval_node	rl_node;
-	/**
-	 * Process to enqueue this lock.
-	 */
-	struct task_struct	*rl_task;
-	/**
-	 * List of locks with the same range.
-	 */
-	struct list_head	rl_next_lock;
-	/**
-	 * Number of locks in the list rl_next_lock
-	 */
-	unsigned int		rl_lock_count;
-	/**
-	 * Number of ranges which are blocking acquisition of the lock
-	 */
-	unsigned int		rl_blocking_ranges;
-	/**
-	 * Sequence number of range lock. This number is used to get to know
-	 * the order the locks are queued; this is required for range_cancel().
-	 */
-	__u64			rl_sequence;
-};
-
-static inline struct range_lock *node2rangelock(const struct interval_node *n)
-{
-	return container_of(n, struct range_lock, rl_node);
-}
-
-struct range_lock_tree {
-	struct interval_node	*rlt_root;
-	spinlock_t		 rlt_lock;	/* protect range lock tree */
-	__u64			 rlt_sequence;
-};
-
-void range_lock_tree_init(struct range_lock_tree *tree);
-int range_lock_init(struct range_lock *lock, __u64 start, __u64 end);
-int  range_lock(struct range_lock_tree *tree, struct range_lock *lock);
-void range_unlock(struct range_lock_tree *tree, struct range_lock *lock);
-#endif
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index e7a4778e02e4..1d4b19bd5f53 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -378,6 +378,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 	int		 result = 0;
 	struct iov_iter i;
 	struct iovec iov;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	LASSERT(io->ci_type == CIT_READ || io->ci_type == CIT_WRITE);
 
@@ -397,8 +398,8 @@ static int vvp_mmap_locks(const struct lu_env *env,
 		count += addr & (~PAGE_MASK);
 		addr &= PAGE_MASK;
 
-		down_read(&mm->mmap_sem);
-		while ((vma = our_vma(mm, addr, count)) != NULL) {
+		mm_read_lock(mm, &mmrange);
+		while ((vma = our_vma(mm, addr, count, &mmrange)) != NULL) {
 			struct inode *inode = file_inode(vma->vm_file);
 			int flags = CEF_MUST;
 
@@ -438,7 +439,7 @@ static int vvp_mmap_locks(const struct lu_env *env,
 			count -= vma->vm_end - addr;
 			addr = vma->vm_end;
 		}
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		if (result < 0)
 			break;
 	}
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
