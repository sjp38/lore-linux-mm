Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD206B00AC
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:45:16 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so2559710wgh.24
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:45:16 -0700 (PDT)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id fm4si1300124wib.68.2014.06.13.03.45.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 03:45:15 -0700 (PDT)
Received: by mail-we0-f180.google.com with SMTP id x48so2551463wes.39
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:45:15 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v3 1/7] mm: allow drivers to prevent new writable mappings
Date: Fri, 13 Jun 2014 12:36:53 +0200
Message-Id: <1402655819-14325-2-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>, David Herrmann <dh.herrmann@gmail.com>

The i_mmap_writable field counts existing writable mappings of an
address_space. To allow drivers to prevent new writable mappings, make
this counter signed and prevent new writable mappings if it is negative.
This is modelled after i_writecount and DENYWRITE.

This will be required by the shmem-sealing infrastructure to prevent any
new writable mappings after the WRITE seal has been set. In case there
exists a writable mapping, this operation will fail with EBUSY.

Note that we rely on the fact that iff you already own a writable mapping,
you can increase the counter without using the helpers. This is the same
that we do for i_writecount.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 fs/inode.c         |  1 +
 include/linux/fs.h | 29 +++++++++++++++++++++++++++--
 kernel/fork.c      |  2 +-
 mm/mmap.c          | 24 ++++++++++++++++++------
 mm/swap_state.c    |  1 +
 5 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 6eecb7f..9945b11 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -165,6 +165,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	mapping->a_ops = &empty_aops;
 	mapping->host = inode;
 	mapping->flags = 0;
+	atomic_set(&mapping->i_mmap_writable, 0);
 	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
 	mapping->private_data = NULL;
 	mapping->backing_dev_info = &default_backing_dev_info;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 338e6f7..71d17c9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -387,7 +387,7 @@ struct address_space {
 	struct inode		*host;		/* owner: inode, block_device */
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
 	spinlock_t		tree_lock;	/* and lock protecting it */
-	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
+	atomic_t		i_mmap_writable;/* count VM_SHARED mappings */
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
@@ -470,10 +470,35 @@ static inline int mapping_mapped(struct address_space *mapping)
  * Note that i_mmap_writable counts all VM_SHARED vmas: do_mmap_pgoff
  * marks vma as VM_SHARED if it is shared, and the file was opened for
  * writing i.e. vma may be mprotected writable even if now readonly.
+ *
+ * If i_mmap_writable is negative, no new writable mappings are allowed. You
+ * can only deny writable mappings, if none exists right now.
  */
 static inline int mapping_writably_mapped(struct address_space *mapping)
 {
-	return mapping->i_mmap_writable != 0;
+	return atomic_read(&mapping->i_mmap_writable) > 0;
+}
+
+static inline int mapping_map_writable(struct address_space *mapping)
+{
+	return atomic_inc_unless_negative(&mapping->i_mmap_writable) ?
+		0 : -EPERM;
+}
+
+static inline void mapping_unmap_writable(struct address_space *mapping)
+{
+	return atomic_dec(&mapping->i_mmap_writable);
+}
+
+static inline int mapping_deny_writable(struct address_space *mapping)
+{
+	return atomic_dec_unless_positive(&mapping->i_mmap_writable) ?
+		0 : -EBUSY;
+}
+
+static inline void mapping_allow_writable(struct address_space *mapping)
+{
+	atomic_inc(&mapping->i_mmap_writable);
 }
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index d2799d1..f1f127e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -421,7 +421,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 				atomic_dec(&inode->i_writecount);
 			mutex_lock(&mapping->i_mmap_mutex);
 			if (tmp->vm_flags & VM_SHARED)
-				mapping->i_mmap_writable++;
+				atomic_inc(&mapping->i_mmap_writable);
 			flush_dcache_mmap_lock(mapping);
 			/* insert tmp into the share list, just after mpnt */
 			if (unlikely(tmp->vm_flags & VM_NONLINEAR))
diff --git a/mm/mmap.c b/mm/mmap.c
index 129b847..19b6562 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -216,7 +216,7 @@ static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 	if (vma->vm_flags & VM_DENYWRITE)
 		atomic_inc(&file_inode(file)->i_writecount);
 	if (vma->vm_flags & VM_SHARED)
-		mapping->i_mmap_writable--;
+		mapping_unmap_writable(mapping);
 
 	flush_dcache_mmap_lock(mapping);
 	if (unlikely(vma->vm_flags & VM_NONLINEAR))
@@ -617,7 +617,7 @@ static void __vma_link_file(struct vm_area_struct *vma)
 		if (vma->vm_flags & VM_DENYWRITE)
 			atomic_dec(&file_inode(file)->i_writecount);
 		if (vma->vm_flags & VM_SHARED)
-			mapping->i_mmap_writable++;
+			atomic_inc(&mapping->i_mmap_writable);
 
 		flush_dcache_mmap_lock(mapping);
 		if (unlikely(vma->vm_flags & VM_NONLINEAR))
@@ -1572,6 +1572,11 @@ munmap_back:
 			if (error)
 				goto free_vma;
 		}
+		if (vm_flags & VM_SHARED) {
+			error = mapping_map_writable(file->f_mapping);
+			if (error)
+				goto allow_write_and_free_vma;
+		}
 		vma->vm_file = get_file(file);
 		error = file->f_op->mmap(file, vma);
 		if (error)
@@ -1611,8 +1616,12 @@ munmap_back:
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	/* Once vma denies write, undo our temporary denial count */
-	if (vm_flags & VM_DENYWRITE)
-		allow_write_access(file);
+	if (file) {
+		if (vm_flags & VM_SHARED)
+			mapping_unmap_writable(file->f_mapping);
+		if (vm_flags & VM_DENYWRITE)
+			allow_write_access(file);
+	}
 	file = vma->vm_file;
 out:
 	perf_event_mmap(vma);
@@ -1641,14 +1650,17 @@ out:
 	return addr;
 
 unmap_and_free_vma:
-	if (vm_flags & VM_DENYWRITE)
-		allow_write_access(file);
 	vma->vm_file = NULL;
 	fput(file);
 
 	/* Undo any partial mapping done by a device driver. */
 	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
+	if (vm_flags & VM_SHARED)
+		mapping_unmap_writable(file->f_mapping);
+allow_write_and_free_vma:
+	if (vm_flags & VM_DENYWRITE)
+		allow_write_access(file);
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
 unacct_error:
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 2972eee..31321fa 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -39,6 +39,7 @@ static struct backing_dev_info swap_backing_dev_info = {
 struct address_space swapper_spaces[MAX_SWAPFILES] = {
 	[0 ... MAX_SWAPFILES - 1] = {
 		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
+		.i_mmap_writable = ATOMIC_INIT(0),
 		.a_ops		= &swap_aops,
 		.backing_dev_info = &swap_backing_dev_info,
 	}
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
