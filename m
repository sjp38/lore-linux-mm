Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7B00A9003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 09:02:27 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so191573251wic.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:02:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cv6si10176272wib.31.2015.08.05.06.02.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 06:02:19 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 2/4] mm, proc: account for shmem swap in /proc/pid/smaps
Date: Wed,  5 Aug 2015 15:01:23 +0200
Message-Id: <1438779685-5227-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
References: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Minchan Kim <minchan@kernel.org>

Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
mappings, even if the mapped portion does contain pages that were swapped out.
This is because unlike private anonymous mappings, shmem does not change pte
to swap entry, but pte_none when swapping the page out. In the smaps page
walk, such page thus looks like it was never faulted in.

This patch changes smaps_pte_entry() to determine the swap status for such
pte_none entries for shmem mappings, similarly to how mincore_page() does it.
Swapped out pages are thus accounted for.

The accounting is arguably still not as precise as for private anonymous
mappings, since now we will count also pages that the process in question never
accessed, but only another process populated them and then let them become
swapped out. I believe it is still less confusing and subtle than not showing
any swap usage by shmem mappings at all. Also, swapped out pages only becomee a
performance issue for future accesses, and we cannot predict those for neither
kind of mapping.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 Documentation/filesystems/proc.txt |  6 +++--
 fs/proc/task_mmu.c                 | 38 +++++++++++++++++++++++++++
 include/linux/shmem_fs.h           |  6 +++++
 mm/shmem.c                         | 54 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 102 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 29f4011..fcf67c7 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -451,8 +451,10 @@ accessed.
 a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
 "Swap" shows how much would-be-anonymous memory is also used, but out on
-swap.
-"SwapPss" shows proportional swap share of this mapping.
+swap. For shmem mappings, "Swap" shows how much of the mapped portion of the
+underlying shmem object is on swap.
+"SwapPss" shows proportional swap share of this mapping. Shmem mappings will
+currently show 0 here.
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
 manner. The codes are the following:
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7c9a174..f94f8f3 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -13,6 +13,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -625,6 +626,41 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 	seq_putc(m, '\n');
 }
 
+#if defined(CONFIG_SHMEM) && defined(CONFIG_SWAP)
+static unsigned long smaps_shmem_swap(struct vm_area_struct *vma)
+{
+	struct inode *inode;
+	unsigned long swapped;
+	pgoff_t start, end;
+
+	if (!vma->vm_file)
+		return 0;
+
+	inode = file_inode(vma->vm_file);
+
+	if (!shmem_mapping(inode->i_mapping))
+		return 0;
+
+	swapped = shmem_swap_usage(inode);
+
+	if (swapped == 0)
+		return 0;
+
+	if (vma->vm_end - vma->vm_start >= inode->i_size)
+		return swapped;
+
+	start = linear_page_index(vma, vma->vm_start);
+	end = linear_page_index(vma, vma->vm_end);
+
+	return shmem_partial_swap_usage(inode->i_mapping, start, end);
+}
+#else
+static unsigned long smaps_shmem_swap(struct vm_area_struct *vma)
+{
+	return 0;
+}
+#endif
+
 static int show_smap(struct seq_file *m, void *v, int is_pid)
 {
 	struct vm_area_struct *vma = v;
@@ -639,6 +675,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 	/* mmap_sem is held in m_start */
 	walk_page_vma(vma, &smaps_walk);
 
+	mss.swap += smaps_shmem_swap(vma);
+
 	show_map_vma(m, vma, is_pid);
 
 	seq_printf(m,
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 50777b5..12519e4 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -60,6 +60,12 @@ extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
+#ifdef CONFIG_SWAP
+extern unsigned long shmem_swap_usage(struct inode *inode);
+extern unsigned long shmem_partial_swap_usage(struct address_space *mapping,
+						pgoff_t start, pgoff_t end);
+#endif
+
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)
 {
diff --git a/mm/shmem.c b/mm/shmem.c
index aa9c82a..88319f8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -357,6 +357,60 @@ static int shmem_free_swap(struct address_space *mapping,
 	return 0;
 }
 
+#ifdef CONFIG_SWAP
+unsigned long shmem_swap_usage(struct inode *inode)
+{
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	unsigned long swapped;
+
+	spin_lock(&info->lock);
+	swapped = info->swapped;
+	spin_unlock(&info->lock);
+
+	return swapped << PAGE_SHIFT;
+}
+
+unsigned long shmem_partial_swap_usage(struct address_space *mapping,
+						pgoff_t start, pgoff_t end)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	struct page *page;
+	unsigned long swapped = 0;
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
+#endif
+
 /*
  * SysV IPC SHM_UNLOCK restore Unevictable pages to their evictable lists.
  */
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
