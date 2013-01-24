Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C82016B0009
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 04:21:18 -0500 (EST)
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: [PATCH 1/1] mm: fix wrong comments about anon_vma lock
Date: Thu, 24 Jan 2013 17:21:50 +0800
Message-Id: <1359019310-23555-1-git-send-email-yuanhan.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yuanhan Liu <yuanhan.liu@linux.intel.com>, Ingo Molnar <mingo@kernel.org>

We use rwsem since commit 5a50508. And most of comments are converted to
the new rwsem lock; while just 2 more missed from:
	 $ git grep 'anon_vma->mutex'

Cc: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
---
 include/linux/mmu_notifier.h |    2 +-
 mm/mmap.c                    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index bc823c4..deca874 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -151,7 +151,7 @@ struct mmu_notifier_ops {
  * Therefore notifier chains can only be traversed when either
  *
  * 1. mmap_sem is held.
- * 2. One of the reverse map locks is held (i_mmap_mutex or anon_vma->mutex).
+ * 2. One of the reverse map locks is held (i_mmap_mutex or anon_vma->rwsem).
  * 3. No other concurrent thread can access the list (release)
  */
 struct mmu_notifier {
diff --git a/mm/mmap.c b/mm/mmap.c
index 35730ee..d1e4124 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2943,7 +2943,7 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  * vma in this mm is backed by the same anon_vma or address_space.
  *
  * We can take all the locks in random order because the VM code
- * taking i_mmap_mutex or anon_vma->mutex outside the mmap_sem never
+ * taking i_mmap_mutex or anon_vma->rwsem outside the mmap_sem never
  * takes more than one of them in a row. Secondly we're protected
  * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
  *
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
