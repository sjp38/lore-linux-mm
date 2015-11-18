Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 705406B0273
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 04:29:58 -0500 (EST)
Received: by wmww144 with SMTP id w144so63126705wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:29:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7si2773101wjw.86.2015.11.18.01.29.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 01:29:56 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v5 3/6] mm, proc: reduce cost of /proc/pid/smaps for shmem mappings
Date: Wed, 18 Nov 2015 10:29:33 +0100
Message-Id: <1447838976-17607-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
References: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@suse.com>

The previous patch has improved swap accounting for shmem mapping, which
however made /proc/pid/smaps more expensive for shmem mappings, as we consult
the radix tree for each pte_none entry, so the overal complexity is
O(n*log(n)).

We can reduce this significantly for mappings that cannot contain COWed pages,
because then we can either use the statistics tha shmem object itself tracks
(if the mapping contains the whole object, or the swap usage of the whole
object is zero), or use the radix tree iterator, which is much more effective
than repeated find_get_entry() calls.

This patch therefore introduces a function shmem_swap_usage(vma) and makes
/proc/pid/smaps use it when possible. Only for writable private mappings of
shmem objects (i.e. tmpfs files) with the shmem object itself (partially)
swapped outwe have to resort to the find_get_entry() approach. Hopefully
such mappings are relatively uncommon.

To demonstrate the diference, I have measured this on a process that creates
a 2GB mapping and dirties single pages with a stride of 2MB, and time how long
does it take to cat /proc/pid/smaps of this process 100 times.

Private writable mapping of a /dev/shm/file (the most complex case):

real    0m3.831s
user    0m0.180s
sys     0m3.212s

Shared mapping of an almost full mapping of a partially swapped /dev/shm/file
(which needs to employ the radix tree iterator).

real    0m1.351s
user    0m0.096s
sys     0m0.768s

Same, but with /dev/shm/file not swapped (so no radix tree walk needed)

real    0m0.935s
user    0m0.128s
sys     0m0.344s

Private anonymous mapping:

real    0m0.949s
user    0m0.116s
sys     0m0.348s

The cost is now much closer to the private anonymous mapping case, unless the
shmem mapping is private and writable.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/proc/task_mmu.c       | 22 +++++++++++++--
 include/linux/shmem_fs.h |  2 ++
 mm/shmem.c               | 70 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 92 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7e0c4c2..491e675 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -14,6 +14,7 @@
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -732,8 +733,25 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
 #ifdef CONFIG_SHMEM
 	if (vma->vm_file && shmem_mapping(vma->vm_file->f_mapping)) {
-		mss.check_shmem_swap = true;
-		smaps_walk.pte_hole = smaps_pte_hole;
+		/*
+		 * For shared or readonly shmem mappings we know that all
+		 * swapped out pages belong to the shmem object, and we can
+		 * obtain the swap value much more efficiently. For private
+		 * writable mappings, we might have COW pages that are
+		 * not affected by the parent swapped out pages of the shmem
+		 * object, so we have to distinguish them during the page walk.
+		 * Unless we know that the shmem object (or the part mapped by
+		 * our VMA) has no swapped out pages at all.
+		 */
+		unsigned long shmem_swapped = shmem_swap_usage(vma);
+
+		if (!shmem_swapped || (vma->vm_flags & VM_SHARED) ||
+					!(vma->vm_flags & VM_WRITE)) {
+			mss.swap = shmem_swapped;
+		} else {
+			mss.check_shmem_swap = true;
+			smaps_walk.pte_hole = smaps_pte_hole;
+		}
 	}
 #endif
 
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 50777b5..bd58be5 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -60,6 +60,8 @@ extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
+extern unsigned long shmem_swap_usage(struct vm_area_struct *vma);
+
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)
 {
diff --git a/mm/shmem.c b/mm/shmem.c
index 529a7d5..bc0f676 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -360,6 +360,76 @@ static int shmem_free_swap(struct address_space *mapping,
 }
 
 /*
+ * Determine (in bytes) how many of the shmem object's pages mapped by the
+ * given vma is swapped out.
+ *
+ * This is safe to call without i_mutex or mapping->tree_lock thanks to RCU,
+ * as long as the inode doesn't go away and racy results are not a problem.
+ */
+unsigned long shmem_swap_usage(struct vm_area_struct *vma)
+{
+	struct inode *inode = file_inode(vma->vm_file);
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct address_space *mapping = inode->i_mapping;
+	unsigned long swapped;
+	pgoff_t start, end;
+	struct radix_tree_iter iter;
+	void **slot;
+	struct page *page;
+
+	/* Be careful as we don't hold info->lock */
+	swapped = READ_ONCE(info->swapped);
+
+	/*
+	 * The easier cases are when the shmem object has nothing in swap, or
+	 * the vma maps it whole. Then we can simply use the stats that we
+	 * already track.
+	 */
+	if (!swapped)
+		return 0;
+
+	if (!vma->vm_pgoff && vma->vm_end - vma->vm_start >= inode->i_size)
+		return swapped << PAGE_SHIFT;
+
+	swapped = 0;
+
+	/* Here comes the more involved part */
+	start = linear_page_index(vma, vma->vm_start);
+	end = linear_page_index(vma, vma->vm_end);
+
+	rcu_read_lock();
+
+restart:
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		if (iter.index >= end)
+			break;
+
+		page = radix_tree_deref_slot(slot);
+
+		/*
+		 * This should only be possible to happen at index 0, so we
+		 * don't need to reset the counter, nor do we risk infinite
+		 * restarts.
+		 */
+		if (radix_tree_deref_retry(page))
+			goto restart;
+
+		if (radix_tree_exceptional_entry(page))
+			swapped++;
+
+		if (need_resched()) {
+			cond_resched_rcu();
+			start = iter.index + 1;
+			goto restart;
+		}
+	}
+
+	rcu_read_unlock();
+
+	return swapped << PAGE_SHIFT;
+}
+
+/*
  * SysV IPC SHM_UNLOCK restore Unevictable pages to their evictable lists.
  */
 void shmem_unlock_mapping(struct address_space *mapping)
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
