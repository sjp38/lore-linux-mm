Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5F106B0008
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o11so18613714pgp.14
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n14si4850747pgt.469.2018.02.04.17.28.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:02 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 03/64] mm: introduce mm locking wrappers
Date: Mon,  5 Feb 2018 02:26:53 +0100
Message-Id: <20180205012754.23615-4-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This patch adds the necessary wrappers to encapsulate mmap_sem
locking and will enable any future changes to be a lot more
confined to here. In addition, future users will incrementally
be added in the next patches. mm_[read/write]_[un]lock() naming
is used.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/mm.h | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47c06fd20f6a..9d2ed23aa894 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -12,6 +12,7 @@
 #include <linux/list.h>
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
+#include <linux/range_lock.h>
 #include <linux/atomic.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
@@ -2675,5 +2676,77 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+/*
+ * Address space locking wrappers.
+ */
+static inline bool mm_is_locked(struct mm_struct *mm,
+				struct range_lock *range)
+{
+	return rwsem_is_locked(&mm->mmap_sem);
+}
+
+/* Reader wrappers */
+static inline int mm_read_trylock(struct mm_struct *mm,
+				  struct range_lock *range)
+{
+	return down_read_trylock(&mm->mmap_sem);
+}
+
+static inline void mm_read_lock(struct mm_struct *mm, struct range_lock *range)
+{
+	down_read(&mm->mmap_sem);
+}
+
+static inline void mm_read_lock_nested(struct mm_struct *mm,
+				       struct range_lock *range, int subclass)
+{
+	down_read_nested(&mm->mmap_sem, subclass);
+}
+
+static inline void mm_read_unlock(struct mm_struct *mm,
+				  struct range_lock *range)
+{
+	up_read(&mm->mmap_sem);
+}
+
+/* Writer wrappers */
+static inline int mm_write_trylock(struct mm_struct *mm,
+				   struct range_lock *range)
+{
+	return down_write_trylock(&mm->mmap_sem);
+}
+
+static inline void mm_write_lock(struct mm_struct *mm, struct range_lock *range)
+{
+	down_write(&mm->mmap_sem);
+}
+
+static inline int mm_write_lock_killable(struct mm_struct *mm,
+					 struct range_lock *range)
+{
+	return down_write_killable(&mm->mmap_sem);
+}
+
+static inline void mm_downgrade_write(struct mm_struct *mm,
+				      struct range_lock *range)
+{
+	downgrade_write(&mm->mmap_sem);
+}
+
+static inline void mm_write_unlock(struct mm_struct *mm,
+				   struct range_lock *range)
+{
+	up_write(&mm->mmap_sem);
+}
+
+static inline void mm_write_lock_nested(struct mm_struct *mm,
+					struct range_lock *range, int subclass)
+{
+	down_write_nested(&mm->mmap_sem, subclass);
+}
+
+#define mm_write_nest_lock(mm, range, nest_lock)		\
+	down_write_nest_lock(&(mm)->mmap_sem, nest_lock)
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
