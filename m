Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 07DB46B003A
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:21:49 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 4/5] mm/rmap: share the i_mmap_rwsem
Date: Mon, 24 Jun 2013 17:21:37 -0700
Message-Id: <1372119698-13147-5-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
References: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, akpm@linux-foundation.org
Cc: walken@google.com, alex.shi@intel.com, tim.c.chen@linux.intel.com, a.p.zijlstra@chello.nl, riel@redhat.com, peter@hurleysoftware.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

Similar to commit 4fc3f1d6, which optimized the anon-vma rwsem, we can share
the i_mmap_rwsem among multiple readers for rmap_walk_file(),
try_to_unmap_file() and collect_procs_file().

With this change, and the rwsem optimizations discussed in
http://lkml.org/lkml/2013/6/16/38 we can see performance improvements.
On a 8 socket, 80 core DL980, when compared to a vanilla 3.10-rc5, aim7
benefits in throughput, with the following workloads (beyond 500 users):

- alltests (+14.5%)
- custom (+17%)
- disk (+11%)
- high_systime (+5%)
- shared (+15%)
- short (+4%)

For lower amounts of users, there are no significant differences as all numbers
are within the 0-2% noise range.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 include/linux/fs.h  | 10 ++++++++++
 mm/memory-failure.c |  7 +++----
 mm/rmap.c           | 12 ++++++------
 3 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 79b8548..5646641 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -485,6 +485,16 @@ static inline void i_mmap_unlock_write(struct address_space *mapping)
 	up_write(&mapping->i_mmap_rwsem);
 }
 
+static inline void i_mmap_lock_read(struct address_space *mapping)
+{
+	down_read(&mapping->i_mmap_rwsem);
+}
+
+static inline void i_mmap_unlock_read(struct address_space *mapping)
+{
+	up_read(&mapping->i_mmap_rwsem);
+}
+
 /*
  * Might pages of this file be mapped into userspace?
  */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e7e0f90..6db44eb 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -436,7 +436,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	struct task_struct *tsk;
 	struct address_space *mapping = page->mapping;
 
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -444,8 +444,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		if (!task_early_kill(tsk))
 			continue;
 
-		vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff,
-				      pgoff) {
+		vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 			/*
 			 * Send early kill signal to tasks where a vma covers
 			 * the page but the corrupted page is not necessarily
@@ -458,7 +457,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		}
 	}
 	read_unlock(&tasklist_lock);
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 }
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index bc8eeb5..98b986d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -808,7 +808,7 @@ static int page_referenced_file(struct page *page,
 	 */
 	BUG_ON(!PageLocked(page));
 
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 
 	/*
 	 * i_mmap_mutex does not stabilize mapcount at all, but mapcount
@@ -831,7 +831,7 @@ static int page_referenced_file(struct page *page,
 			break;
 	}
 
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 	return referenced;
 }
 
@@ -1516,7 +1516,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	if (PageHuge(page))
 		pgoff = page->index << compound_order(page);
 
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		ret = try_to_unmap_one(page, vma, address, flags);
@@ -1594,7 +1594,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.nonlinear)
 		vma->vm_private_data = NULL;
 out:
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 	return ret;
 }
 
@@ -1711,7 +1711,7 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 
 	if (!mapping)
 		return ret;
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		ret = rmap_one(page, vma, address, arg);
@@ -1723,7 +1723,7 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 	 * never contain migration ptes.  Decide what to do about this
 	 * limitation to linear when we need rmap_walk() on nonlinear.
 	 */
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 	return ret;
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
