Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B33286B0278
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 04:30:03 -0500 (EST)
Received: by wmww144 with SMTP id w144so188645143wmw.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:30:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r140si39472832wmd.52.2015.11.18.01.29.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 01:29:56 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v5 4/6] mm, proc: reduce cost of /proc/pid/smaps for unpopulated shmem mappings
Date: Wed, 18 Nov 2015 10:29:34 +0100
Message-Id: <1447838976-17607-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
References: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@suse.com>

Following the previous patch, further reduction of /proc/pid/smaps cost is
possible for private writable shmem mappings with unpopulated areas where
the page walk invokes the .pte_hole function. We can use radix tree iterator
for each such area instead of calling find_get_entry() in a loop. This is
possible at the extra maintenance cost of introducing another shmem function
shmem_partial_swap_usage().

To demonstrate the diference, I have measured this on a process that creates a
private writable 2GB mapping of a partially swapped out /dev/shm/file (which
cannot employ the optimizations from the prvious patch) and doesn't populate it
at all. I time how long does it take to cat /proc/pid/smaps of this process 100
times.

Before this patch:

real    0m3.831s
user    0m0.180s
sys     0m3.212s

After this patch:

real    0m1.176s
user    0m0.180s
sys     0m0.684s

The time is similar to case where radix tree iterator is employed on the whole
mapping.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/proc/task_mmu.c       | 42 ++++++++++---------------------
 include/linux/shmem_fs.h |  2 ++
 mm/shmem.c               | 65 ++++++++++++++++++++++++++++--------------------
 3 files changed, 53 insertions(+), 56 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 491e675..a0338ec 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -503,42 +503,16 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 }
 
 #ifdef CONFIG_SHMEM
-static unsigned long smaps_shmem_swap(struct vm_area_struct *vma,
-		unsigned long addr)
-{
-	struct page *page;
-
-	page = find_get_entry(vma->vm_file->f_mapping,
-					linear_page_index(vma, addr));
-	if (!page)
-		return 0;
-
-	if (radix_tree_exceptional_entry(page))
-		return PAGE_SIZE;
-
-	page_cache_release(page);
-	return 0;
-
-}
-
 static int smaps_pte_hole(unsigned long addr, unsigned long end,
 		struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
 
-	while (addr < end) {
-		mss->swap += smaps_shmem_swap(walk->vma, addr);
-		addr += PAGE_SIZE;
-	}
+	mss->swap += shmem_partial_swap_usage(
+			walk->vma->vm_file->f_mapping, addr, end);
 
 	return 0;
 }
-#else
-static unsigned long smaps_shmem_swap(struct vm_area_struct *vma,
-		unsigned long addr)
-{
-	return 0;
-}
 #endif
 
 static void smaps_pte_entry(pte_t *pte, unsigned long addr,
@@ -570,7 +544,17 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 			page = migration_entry_to_page(swpent);
 	} else if (unlikely(IS_ENABLED(CONFIG_SHMEM) && mss->check_shmem_swap
 							&& pte_none(*pte))) {
-		mss->swap += smaps_shmem_swap(vma, addr);
+		page = find_get_entry(vma->vm_file->f_mapping,
+						linear_page_index(vma, addr));
+		if (!page)
+			return;
+
+		if (radix_tree_exceptional_entry(page))
+			mss->swap += PAGE_SIZE;
+		else
+			page_cache_release(page);
+
+		return;
 	}
 
 	if (!page)
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index bd58be5..a43f41c 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -61,6 +61,8 @@ extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
 extern unsigned long shmem_swap_usage(struct vm_area_struct *vma);
+extern unsigned long shmem_partial_swap_usage(struct address_space *mapping,
+						pgoff_t start, pgoff_t end);
 
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)
diff --git a/mm/shmem.c b/mm/shmem.c
index bc0f676..8689a58 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -361,41 +361,18 @@ static int shmem_free_swap(struct address_space *mapping,
 
 /*
  * Determine (in bytes) how many of the shmem object's pages mapped by the
- * given vma is swapped out.
+ * given offsets are swapped out.
  *
  * This is safe to call without i_mutex or mapping->tree_lock thanks to RCU,
  * as long as the inode doesn't go away and racy results are not a problem.
  */
-unsigned long shmem_swap_usage(struct vm_area_struct *vma)
+unsigned long shmem_partial_swap_usage(struct address_space *mapping,
+						pgoff_t start, pgoff_t end)
 {
-	struct inode *inode = file_inode(vma->vm_file);
-	struct shmem_inode_info *info = SHMEM_I(inode);
-	struct address_space *mapping = inode->i_mapping;
-	unsigned long swapped;
-	pgoff_t start, end;
 	struct radix_tree_iter iter;
 	void **slot;
 	struct page *page;
-
-	/* Be careful as we don't hold info->lock */
-	swapped = READ_ONCE(info->swapped);
-
-	/*
-	 * The easier cases are when the shmem object has nothing in swap, or
-	 * the vma maps it whole. Then we can simply use the stats that we
-	 * already track.
-	 */
-	if (!swapped)
-		return 0;
-
-	if (!vma->vm_pgoff && vma->vm_end - vma->vm_start >= inode->i_size)
-		return swapped << PAGE_SHIFT;
-
-	swapped = 0;
-
-	/* Here comes the more involved part */
-	start = linear_page_index(vma, vma->vm_start);
-	end = linear_page_index(vma, vma->vm_end);
+	unsigned long swapped = 0;
 
 	rcu_read_lock();
 
@@ -430,6 +407,40 @@ unsigned long shmem_swap_usage(struct vm_area_struct *vma)
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
+	/* Here comes the more involved part */
+	return shmem_partial_swap_usage(mapping,
+			linear_page_index(vma, vma->vm_start),
+			linear_page_index(vma, vma->vm_end));
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
