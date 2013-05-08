Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 853436B0070
	for <linux-mm@kvack.org>; Wed,  8 May 2013 19:39:06 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 1/6] mm: Per process reclaim
Date: Thu,  9 May 2013 08:38:57 +0900
Message-Id: <1368056342-30836-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1368056342-30836-1-git-send-email-minchan@kernel.org>
References: <1368056342-30836-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Namhyung Kim <namhyung@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

These day, there are many platforms avaiable in the embedded market
and they are smarter than kernel which has very limited information
about working set so they want to involve memory management more heavily
like android's lowmemory killer and ashmem or recent many lowmemory
notifier(there was several trial for various company NOKIA, SAMSUNG,
Linaro, Google ChromeOS, Redhat).

One of the simple imagine scenario about userspace's intelligence is that
platform can manage tasks as forground and backgroud so it would be
better to reclaim background's task pages for end-user's *responsibility*
although it has frequent referenced pages.

This patch adds new knob "reclaim under proc/<pid>/" so task manager
can reclaim any target process anytime, anywhere. It could give another
method to platform for using memory efficiently.

It can avoid process killing for getting free memory, which was really
terrible experience because I lost my best score of game I had ever
after I switch the phone call while I enjoyed the game.

Reclaim file-backed pages only.
	echo file > /proc/PID/reclaim
Reclaim anonymous pages only.
	echo anon > /proc/PID/reclaim
Reclaim all pages
	echo all > /proc/PID/reclaim

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/proc/base.c       |   3 ++
 fs/proc/internal.h   |   1 +
 fs/proc/task_mmu.c   | 121 +++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/rmap.h |   4 ++
 mm/Kconfig           |  13 ++++++
 mm/vmscan.c          |  59 +++++++++++++++++++++++++
 6 files changed, 201 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 4d3ebd6..9286b43 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2669,6 +2669,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("mounts",     S_IRUGO, proc_mounts_operations),
 	REG("mountinfo",  S_IRUGO, proc_mountinfo_operations),
 	REG("mountstats", S_IRUSR, proc_mountstats_operations),
+#ifdef CONFIG_PROCESS_RECLAIM
+	REG("reclaim", S_IWUSR, proc_reclaim_operations),
+#endif
 #ifdef CONFIG_PROC_PAGE_MONITOR
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index f417d43..0c29375 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -204,6 +204,7 @@ struct pde_opener {
 };
 
 extern const struct inode_operations proc_pid_link_inode_operations;
+extern const struct file_operations proc_reclaim_operations;
 
 extern void proc_init_inodecache(void);
 extern struct inode *proc_get_inode(struct super_block *, struct proc_dir_entry *);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3240a49..cd6bb70 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -11,6 +11,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mm_inline.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -1182,6 +1183,126 @@ const struct file_operations proc_pagemap2_operations = {
 };
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
+#ifdef CONFIG_PROCESS_RECLAIM
+static int reclaim_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->private;
+	pte_t *pte, ptent;
+	spinlock_t *ptl;
+	struct page *page;
+	LIST_HEAD(page_list);
+	int isolated;
+
+	split_huge_page_pmd(vma, addr, pmd);
+	if (pmd_trans_unstable(pmd))
+		return 0;
+cont:
+	isolated = 0;
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
+		if (!pte_present(ptent))
+			continue;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page)
+			continue;
+
+		if (isolate_lru_page(page))
+			continue;
+
+		list_add(&page->lru, &page_list);
+		inc_zone_page_state(page, NR_ISOLATED_ANON +
+				page_is_file_cache(page));
+		isolated++;
+		if (isolated >= SWAP_CLUSTER_MAX)
+			break;
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	reclaim_pages_from_list(&page_list);
+	if (addr != end)
+		goto cont;
+
+	cond_resched();
+	return 0;
+}
+
+enum reclaim_type {
+	RECLAIM_FILE,
+	RECLAIM_ANON,
+	RECLAIM_ALL,
+	RECLAIM_RANGE,
+};
+
+static ssize_t reclaim_write(struct file *file, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct task_struct *task;
+	char buffer[PROC_NUMBUF];
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	enum reclaim_type type;
+	char *type_buf;
+
+	memset(buffer, 0, sizeof(buffer));
+	if (count > sizeof(buffer) - 1)
+		count = sizeof(buffer) - 1;
+
+	if (copy_from_user(buffer, buf, count))
+		return -EFAULT;
+
+	type_buf = strstrip(buffer);
+	if (!strcmp(type_buf, "file"))
+		type = RECLAIM_FILE;
+	else if (!strcmp(type_buf, "anon"))
+		type = RECLAIM_ANON;
+	else if (!strcmp(type_buf, "all"))
+		type = RECLAIM_ALL;
+	else
+		return -EINVAL;
+
+	task = get_proc_task(file->f_path.dentry->d_inode);
+	if (!task)
+		return -ESRCH;
+
+	mm = get_task_mm(task);
+	if (mm) {
+		struct mm_walk reclaim_walk = {
+			.pmd_entry = reclaim_pte_range,
+			.mm = mm,
+		};
+
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			reclaim_walk.private = vma;
+
+			if (is_vm_hugetlb_page(vma))
+				continue;
+
+			if (type == RECLAIM_ANON && vma->vm_file)
+				continue;
+			if (type == RECLAIM_FILE && !vma->vm_file)
+				continue;
+
+			walk_page_range(vma->vm_start, vma->vm_end,
+					&reclaim_walk);
+		}
+		flush_tlb_mm(mm);
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+	put_task_struct(task);
+
+	return count;
+}
+
+const struct file_operations proc_reclaim_operations = {
+	.write		= reclaim_write,
+	.llseek		= noop_llseek,
+};
+#endif
+
 #ifdef CONFIG_NUMA
 
 struct numa_maps {
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 6dacb93..a24e34e 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -10,6 +10,10 @@
 #include <linux/rwsem.h>
 #include <linux/memcontrol.h>
 
+extern int isolate_lru_page(struct page *page);
+extern void putback_lru_page(struct page *page);
+extern unsigned long reclaim_pages_from_list(struct list_head *page_list);
+
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
  * an anonymous page pointing to this anon_vma needs to be unmapped:
diff --git a/mm/Kconfig b/mm/Kconfig
index b0a7dad..d119b5b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -489,3 +489,16 @@ config MEM_SOFT_DIRTY
 	  it can be cleared by hands.
 
 	  See Documentation/vm/soft-dirty.txt for more details.
+
+config PROCESS_RECLAIM
+	bool "Enable process reclaim"
+	depends on PROC_FS
+	default n
+	help
+	 It allows to reclaim pages of the process by /proc/pid/reclaim.
+
+	 (echo file > /proc/PID/reclaim) reclaims file-backed pages only.
+	 (echo anon > /proc/PID/reclaim) reclaims anonymous pages only.
+	 (echo all > /proc/PID/reclaim) reclaims all pages.
+
+	 Any other vaule is ignored.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..6b7cba3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -992,6 +992,65 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	return ret;
 }
 
+#ifdef CONFIG_PROCESS_RECLAIM
+static unsigned long shrink_page(struct page *page,
+					struct zone *zone,
+					struct scan_control *sc,
+					enum ttu_flags ttu_flags,
+					unsigned long *ret_nr_dirty,
+					unsigned long *ret_nr_writeback,
+					bool force_reclaim,
+					struct list_head *ret_pages)
+{
+	int reclaimed;
+	LIST_HEAD(page_list);
+	list_add(&page->lru, &page_list);
+
+	reclaimed = shrink_page_list(&page_list, zone, sc, ttu_flags,
+				ret_nr_dirty, ret_nr_writeback,
+				force_reclaim);
+	if (!reclaimed)
+		list_splice(&page_list, ret_pages);
+
+	return reclaimed;
+}
+
+unsigned long reclaim_pages_from_list(struct list_head *page_list)
+{
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.priority = DEF_PRIORITY,
+		.may_unmap = 1,
+		.may_swap = 1,
+	};
+
+	LIST_HEAD(ret_pages);
+	struct page *page;
+	unsigned long dummy1, dummy2;
+	unsigned long nr_reclaimed = 0;
+
+	while (!list_empty(page_list)) {
+		page = lru_to_page(page_list);
+		list_del(&page->lru);
+
+		ClearPageActive(page);
+		nr_reclaimed += shrink_page(page, page_zone(page), &sc,
+				TTU_UNMAP|TTU_IGNORE_ACCESS,
+				&dummy1, &dummy2, true, &ret_pages);
+	}
+
+	while (!list_empty(&ret_pages)) {
+		page = lru_to_page(&ret_pages);
+		list_del(&page->lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				page_is_file_cache(page));
+		putback_lru_page(page);
+	}
+
+	return nr_reclaimed;
+}
+#endif
+
 /*
  * Attempt to remove the specified page from its LRU.  Only take this page
  * if it is of the appropriate PageActive status.  Pages which are being
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
