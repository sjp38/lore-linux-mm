Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 895C26B0039
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:21:49 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 3/5] mm: convert i_mmap_mutex to rwsem
Date: Mon, 24 Jun 2013 17:21:36 -0700
Message-Id: <1372119698-13147-4-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
References: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, akpm@linux-foundation.org
Cc: walken@google.com, alex.shi@intel.com, tim.c.chen@linux.intel.com, a.p.zijlstra@chello.nl, riel@redhat.com, peter@hurleysoftware.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

This conversion is straightforward. All users take the write
lock, so there is really not much difference with the previous
mutex lock.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 fs/inode.c         | 2 +-
 include/linux/fs.h | 6 +++---
 mm/mmap.c          | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 00d5fc3..af5f0ea 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -345,7 +345,7 @@ void address_space_init_once(struct address_space *mapping)
 	memset(mapping, 0, sizeof(*mapping));
 	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
 	spin_lock_init(&mapping->tree_lock);
-	mutex_init(&mapping->i_mmap_mutex);
+	init_rwsem(&mapping->i_mmap_rwsem);
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
 	mapping->i_mmap = RB_ROOT;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1ea6c68..79b8548 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -410,7 +410,7 @@ struct address_space {
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct rb_root		i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
-	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
+	struct rw_semaphore     i_mmap_rwsem;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
@@ -477,12 +477,12 @@ int mapping_tagged(struct address_space *mapping, int tag);
 
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
index 01a9876..b4e142a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3016,7 +3016,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		mutex_lock_nest_lock(&mapping->i_mmap_mutex, &mm->mmap_sem);
+		down_write_nest_lock(&mapping->i_mmap_rwsem, &mm->mmap_sem);
 	}
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
