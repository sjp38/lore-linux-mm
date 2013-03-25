Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 386846B0027
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 02:22:00 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 1/4] mm: Per process reclaim
Date: Mon, 25 Mar 2013 15:21:31 +0900
Message-Id: <1364192494-22185-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sangseok Lee <sangseok.lee@lge.com>, Minchan Kim <minchan@kernel.org>

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

Writing 1 to /proc/pid/reclaim reclaims only file pages.
Writing 2 to /proc/pid/reclaim reclaims only anonymous pages.
Writing 3 to /proc/pid/reclaim reclaims all pages from target process.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/proc/base.c       |   3 ++
 fs/proc/internal.h   |   1 +
 fs/proc/task_mmu.c   | 115 +++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/rmap.h |   4 ++
 mm/Kconfig           |  13 ++++++
 mm/internal.h        |   7 +---
 mm/vmscan.c          |  59 ++++++++++++++++++++++++++
 7 files changed, 196 insertions(+), 6 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 9b43ff77..ed83e85 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2532,6 +2532,9 @@ static const struct pid_entry tgid_base_stuff[] = {
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
index 3f711d6..48ccb52 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -51,6 +51,7 @@ extern const struct file_operations proc_pagemap_operations;
 extern const struct file_operations proc_net_operations;
 extern const struct inode_operations proc_net_inode_operations;
 extern const struct inode_operations proc_pid_link_inode_operations;
+extern const struct file_operations proc_reclaim_operations;
 
 struct proc_maps_private {
 	struct pid *pid;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ca5ce7f..c3713a4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -11,6 +11,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mm_inline.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -1116,6 +1117,120 @@ const struct file_operations proc_pagemap_operations = {
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
+#define RECLAIM_FILE (1 << 0)
+#define RECLAIM_ANON (1 << 1)
+#define RECLAIM_ALL (RECLAIM_FILE | RECLAIM_ANON)
+
+static ssize_t reclaim_write(struct file *file, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct task_struct *task;
+	char buffer[PROC_NUMBUF];
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int type;
+	int rv;
+
+	memset(buffer, 0, sizeof(buffer));
+	if (count > sizeof(buffer) - 1)
+		count = sizeof(buffer) - 1;
+	if (copy_from_user(buffer, buf, count))
+		return -EFAULT;
+	rv = kstrtoint(strstrip(buffer), 10, &type);
+	if (rv < 0)
+		return rv;
+	if (type < RECLAIM_ALL || type > RECLAIM_FILE)
+		return -EINVAL;
+	task = get_proc_task(file->f_path.dentry->d_inode);
+	if (!task)
+		return -ESRCH;
+	mm = get_task_mm(task);
+	if (mm) {
+		struct mm_walk reclaim_walk = {
+			.pmd_entry = reclaim_pte_range,
+			.mm = mm,
+		};
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			reclaim_walk.private = vma;
+			if (is_vm_hugetlb_page(vma))
+				continue;
+			/*
+			 * Writing 1 to /proc/pid/reclaim only affects file
+			 * mapped pages.
+			 *
+			 * Writing 2 to /proc/pid/reclaim enly affects
+			 * anonymous pages.
+			 *
+			 * Writing 3 to /proc/pid/reclaim affects all pages.
+			 */
+			if (type == RECLAIM_ANON && vma->vm_file)
+				continue;
+			if (type == RECLAIM_FILE && !vma->vm_file)
+				continue;
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
index 5881e8c..a947f4b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -467,3 +467,16 @@ config FRONTSWAP
 	  and swap data is stored as normal on the matching swap device.
 
 	  If unsure, say Y to enable frontswap.
+
+config PROCESS_RECLAIM
+	bool "Enable per process reclaim"
+	depends on PROC_FS
+	default n
+	help
+	 It allows to reclaim pages of the process by /proc/pid/reclaim.
+
+	 (echo 1 > /proc/PID/reclaim) reclaims file-backed pages only.
+	 (echo 2 > /proc/PID/reclaim) reclaims anonymous pages only.
+	 (echo 3 > /proc/PID/reclaim) reclaims all pages.
+
+	 Any other vaule is ignored.
diff --git a/mm/internal.h b/mm/internal.h
index 8562de0..589a29b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -86,12 +86,6 @@ static inline void get_page_foll(struct page *page)
 extern unsigned long highest_memmap_pfn;
 
 /*
- * in mm/vmscan.c:
- */
-extern int isolate_lru_page(struct page *page);
-extern void putback_lru_page(struct page *page);
-
-/*
  * in mm/rmap.c:
  */
 extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
@@ -360,6 +354,7 @@ extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
 extern void set_pageblock_order(void);
 unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 					    struct list_head *page_list);
+
 /* The ALLOC_WMARK bits are used as an index to zone->watermark */
 #define ALLOC_WMARK_MIN		WMARK_MIN
 #define ALLOC_WMARK_LOW		WMARK_LOW
diff --git a/mm/vmscan.c b/mm/vmscan.c
index df78d17..d3dc95f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -991,6 +991,65 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
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
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
