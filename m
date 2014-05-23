Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id B10F66B003B
	for <linux-mm@kvack.org>; Thu, 22 May 2014 23:33:44 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id eb12so4935714oac.8
        for <linux-mm@kvack.org>; Thu, 22 May 2014 20:33:44 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id de9si2201509oeb.36.2014.05.22.20.33.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 20:33:44 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 3/5] mm: convert i_mmap_mutex to rwsem
Date: Thu, 22 May 2014 20:33:24 -0700
Message-Id: <1400816006-3083-4-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, davidlohr@hp.com, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The i_mmap_mutex is a close cousin of the anon vma lock,
both protecting similar data, one for file backed pages
and the other for anon memory. To this end, this lock can
also be a rwsem.

This conversion is straightforward. For now, all users take
the write lock.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 fs/hugetlbfs/inode.c | 10 +++++-----
 fs/inode.c           |  2 +-
 include/linux/fs.h   |  7 ++++---
 mm/mmap.c            |  8 ++++----
 4 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index bcaf4df..020ace5 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -472,12 +472,12 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
 }
 
 /*
- * Hugetlbfs is not reclaimable; therefore its i_mmap_mutex will never
+ * Hugetlbfs is not reclaimable; therefore its i_mmap_rwsem will never
  * be taken from reclaim -- unlike regular filesystems. This needs an
  * annotation because huge_pmd_share() does an allocation under
- * i_mmap_mutex.
+ * i_mmap_rwsem.
  */
-static struct lock_class_key hugetlbfs_i_mmap_mutex_key;
+static struct lock_class_key hugetlbfs_i_mmap_rwsem_key;
 
 static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 					struct inode *dir,
@@ -495,8 +495,8 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		struct hugetlbfs_inode_info *info;
 		inode->i_ino = get_next_ino();
 		inode_init_owner(inode, dir, mode);
-		lockdep_set_class(&inode->i_mapping->i_mmap_mutex,
-				&hugetlbfs_i_mmap_mutex_key);
+		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
+				&hugetlbfs_i_mmap_rwsem_key);
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
diff --git a/fs/inode.c b/fs/inode.c
index 2feb9b6..d26e9f8 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -348,7 +348,7 @@ void address_space_init_once(struct address_space *mapping)
 	memset(mapping, 0, sizeof(*mapping));
 	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
 	spin_lock_init(&mapping->tree_lock);
-	mutex_init(&mapping->i_mmap_mutex);
+	init_rwsem(&mapping->i_mmap_rwsem);
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 524d2c1..60a1d7d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -18,6 +18,7 @@
 #include <linux/pid.h>
 #include <linux/bug.h>
 #include <linux/mutex.h>
+#include <linux/rwsem.h>
 #include <linux/capability.h>
 #include <linux/semaphore.h>
 #include <linux/fiemap.h>
@@ -390,7 +391,7 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
+	struct rw_semaphore	i_mmap_rwsem;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	unsigned long		nrshadows;	/* number of shadow entries */
@@ -458,12 +459,12 @@ int mapping_tagged(struct address_space *mapping, int tag);
 
 static inline void i_mmap_lock_write(struct address_space *mapping)
 {
-	mutex_lock(&mapping->i_mmap_mutex);
+	down_write(&mapping->i_mmap_rwsem);
 }
 
 static inline void i_mmap_unlock_write(struct address_space *mapping)
 {
-	mutex_unlock(&mapping->i_mmap_mutex);
+	up_write(&mapping->i_mmap_rwsem);
 }
 
 /*
diff --git a/mm/mmap.c b/mm/mmap.c
index 41a0083..bc7a3b2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -208,7 +208,7 @@ error:
 }
 
 /*
- * Requires inode->i_mapping->i_mmap_mutex
+ * Requires inode->i_mapping->i_mmap_rwsem
  */
 static void __remove_shared_vm_struct(struct vm_area_struct *vma,
 		struct file *file, struct address_space *mapping)
@@ -2814,7 +2814,7 @@ void exit_mmap(struct mm_struct *mm)
 
 /* Insert vm structure into process list sorted by address
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
- * then i_mmap_mutex is taken here.
+ * then i_mmap_rwsem is taken here.
  */
 int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
@@ -3078,7 +3078,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		mutex_lock_nest_lock(&mapping->i_mmap_mutex, &mm->mmap_sem);
+		down_write_nest_lock(&mapping->i_mmap_rwsem, &mm->mmap_sem);
 	}
 }
 
@@ -3105,7 +3105,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
- * taking i_mmap_mutex or anon_vma->rwsem outside the mmap_sem never
+ * taking i_mmap_rwsem or anon_vma->rwsem outside the mmap_sem never
  * takes more than one of them in a row. Secondly we're protected
  * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
  *
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
