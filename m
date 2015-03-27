Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id B42EA6B0070
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 12:40:51 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so33286717wib.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 09:40:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fd10si4117347wjc.16.2015.03.27.09.40.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 09:40:47 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/4] mm, proc: account for shmem swap in /proc/pid/smaps
Date: Fri, 27 Mar 2015 17:40:39 +0100
Message-Id: <1427474441-17708-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1427474441-17708-1-git-send-email-vbabka@suse.cz>
References: <1427474441-17708-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Vlastimil Babka <vbabka@suse.cz>

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
 Documentation/filesystems/proc.txt |  3 ++-
 fs/proc/task_mmu.c                 | 38 +++++++++++++++++++++++++++
 include/linux/shmem_fs.h           |  6 +++++
 mm/shmem.c                         | 54 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 100 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index d4f56ec..8b30543 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -437,7 +437,8 @@ indicates the amount of memory currently marked as referenced or accessed.
 a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
 "Swap" shows how much would-be-anonymous memory is also used, but out on
-swap.
+swap. For shmem mappings, "Swap" shows how much of the mapped portion of the
+underlying shmem object is on swap.
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 6dee68d..1b271ec 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -13,6 +13,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -610,6 +611,41 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
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
@@ -624,6 +660,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
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
index cf2d0ca..f8ebd23 100644
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
