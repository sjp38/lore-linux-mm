Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9D66B0260
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 03:51:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so124725545pfx.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 00:51:10 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id uc2si9790878pac.22.2016.06.13.00.51.05
        for <linux-mm@kvack.org>;
        Mon, 13 Jun 2016 00:51:06 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 3/3] mm: per-process reclaim
Date: Mon, 13 Jun 2016 16:50:58 +0900
Message-Id: <1465804259-29345-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1465804259-29345-1-git-send-email-minchan@kernel.org>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Sangwoo Park <sangwoo2.park@lge.com>

These day, there are many platforms available in the embedded market
and sometime, they has more hints about workingset than kernel so
they want to involve memory management more heavily like android's
lowmemory killer and ashmem or user-daemon with lowmemory notifier.

This patch adds add new method for userspace to manage memory
efficiently via knob "/proc/<pid>/reclaim" so platform can reclaim
any process anytime.

One of useful usecase is to avoid process killing for getting free
memory in android, which was really terrible experience because I
lost my best score of game I had ever after I switch the phone call
while I enjoyed the game as well as slow start-up by cold launching.

Our product have used it in real procuct.

Quote from Sangwoo Park <angwoo2.park@lge.com>
Thanks for the data, Sangwoo!
"
- Test scenaro
  - platform: android
  - target: MSM8952, 2G DDR, 16G eMMC
  - scenario
    retry app launch and Back Home with 16 apps and 16 turns
    (total app launch count is 256)
  - result:
			  resume count   |  cold launching count
-----------------------------------------------------------------
 vanilla           |           85        |          171
 perproc reclaim   |           184       |           72
"

Higher resume count is better because cold launching needs loading
lots of resource data which takes above 15 ~ 20 seconds for some
games while successful resume just takes 1~5 second.

As perproc reclaim way with new management policy, we could reduce
cold launching a lot(i.e., 171-72) so that it reduces app startup
a lot.

Another useful function from this feature is to make swapout easily
which is useful for testing swapout stress and workloads.

Interface:

Reclaim file-backed pages only.
	echo 1 > /proc/<pid>/reclaim
Reclaim anonymous pages only.
	echo 2 > /proc/<pid>/reclaim
Reclaim all pages
	echo 3 > /proc/<pid>/reclaim

bit 1 : file, bit 2 : anon, bit 1 & 2 : all

Note:
If a page is shared by other processes(i.e., page_mapcount(page) > 1),
it couldn't be reclaimed.

Cc: Sangwoo Park <sangwoo2.park@lge.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/filesystems/proc.txt |  15 ++++
 fs/proc/base.c                     |   1 +
 fs/proc/internal.h                 |   1 +
 fs/proc/task_mmu.c                 | 149 +++++++++++++++++++++++++++++++++++++
 include/linux/rmap.h               |   4 +
 mm/vmscan.c                        |  40 ++++++++++
 6 files changed, 210 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 50fcf48f4d58..3b6adf370f3c 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -138,6 +138,7 @@ Table 1-1: Process specific entries in /proc
  maps		Memory maps to executables and library files	(2.4)
  mem		Memory held by this process
  root		Link to the root directory of this process
+ reclaim	Reclaim pages in this process
  stat		Process status
  statm		Process memory status information
  status		Process status in human readable form
@@ -536,6 +537,20 @@ To reset the peak resident set size ("high water mark") to the process's
 
 Any other value written to /proc/PID/clear_refs will have no effect.
 
+The file /proc/PID/reclaim is used to reclaim pages in this process.
+bit 1: file, bit 2: anon, bit 3: all
+
+To reclaim file-backed pages,
+    > echo 1 > /proc/PID/reclaim
+
+To reclaim anonymous pages,
+    > echo 2 > /proc/PID/reclaim
+
+To reclaim all pages,
+    > echo 3 > /proc/PID/reclaim
+
+If a page is shared by several processes, it cannot be reclaimed.
+
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
 using /proc/kpageflags and number of times a page is mapped using
 /proc/kpagecount. For detailed explanation, see Documentation/vm/pagemap.txt.
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 93e7754fd5b2..b957d929516d 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2848,6 +2848,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("mounts",     S_IRUGO, proc_mounts_operations),
 	REG("mountinfo",  S_IRUGO, proc_mountinfo_operations),
 	REG("mountstats", S_IRUSR, proc_mountstats_operations),
+	REG("reclaim", S_IWUSR, proc_reclaim_operations),
 #ifdef CONFIG_PROC_PAGE_MONITOR
 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index aa2781095bd1..ef2b01533c97 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -209,6 +209,7 @@ struct pde_opener {
 extern const struct inode_operations proc_link_inode_operations;
 
 extern const struct inode_operations proc_pid_link_inode_operations;
+extern const struct file_operations proc_reclaim_operations;
 
 extern void proc_init_inodecache(void);
 extern struct inode *proc_get_inode(struct super_block *, struct proc_dir_entry *);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84ef9de9..31e4657f8fe9 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -11,6 +11,7 @@
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
 #include <linux/swap.h>
+#include <linux/mm_inline.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
@@ -1465,6 +1466,154 @@ const struct file_operations proc_pagemap_operations = {
 };
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
+static int reclaim_pte_range(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	struct mm_struct *mm = walk->mm;
+	struct vm_area_struct *vma = walk->private;
+	pte_t *orig_pte, *pte, ptent;
+	spinlock_t *ptl;
+	struct page *page;
+	LIST_HEAD(page_list);
+	int isolated = 0;
+
+	split_huge_pmd(vma, pmd, addr);
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
+
+		if (!pte_present(ptent))
+			continue;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page)
+			continue;
+
+		if (page_mapcount(page) != 1)
+			continue;
+
+		if (PageTransCompound(page)) {
+			get_page(page);
+			if (!trylock_page(page)) {
+				put_page(page);
+				goto out;
+			}
+			pte_unmap_unlock(orig_pte, ptl);
+
+			if (split_huge_page(page)) {
+				unlock_page(page);
+				put_page(page);
+				orig_pte = pte_offset_map_lock(mm, pmd,
+								addr, &ptl);
+				goto out;
+			}
+			put_page(page);
+			unlock_page(page);
+			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+			pte--;
+			addr -= PAGE_SIZE;
+			continue;
+		}
+
+		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+
+		if (isolate_lru_page(page))
+			continue;
+
+		list_add(&page->lru, &page_list);
+		inc_zone_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
+		isolated++;
+		if (isolated >= SWAP_CLUSTER_MAX) {
+			pte_unmap_unlock(orig_pte, ptl);
+			reclaim_pages_from_list(&page_list);
+			isolated = 0;
+			cond_resched();
+			orig_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+		}
+	}
+
+out:
+	pte_unmap_unlock(orig_pte, ptl);
+	reclaim_pages_from_list(&page_list);
+
+	cond_resched();
+	return 0;
+}
+
+enum reclaim_type {
+	RECLAIM_FILE = 1,
+	RECLAIM_ANON,
+	RECLAIM_ALL,
+};
+
+static ssize_t reclaim_write(struct file *file, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	struct task_struct *task;
+	char buffer[PROC_NUMBUF];
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int itype;
+	int rv;
+	enum reclaim_type type;
+
+	memset(buffer, 0, sizeof(buffer));
+	if (count > sizeof(buffer) - 1)
+		count = sizeof(buffer) - 1;
+	if (copy_from_user(buffer, buf, count))
+		return -EFAULT;
+	rv = kstrtoint(strstrip(buffer), 10, &itype);
+	if (rv < 0)
+		return rv;
+	type = (enum reclaim_type)itype;
+	if (type < RECLAIM_FILE || type > RECLAIM_ALL)
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
+			if (!vma_is_anonymous(vma) && !(type & RECLAIM_FILE))
+				continue;
+
+			if (vma_is_anonymous(vma) && !(type & RECLAIM_ANON))
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
+
 #ifdef CONFIG_NUMA
 
 struct numa_maps {
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 5704f101b52e..e90a21b78da3 100644
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
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d20c9e863d35..442866f77251 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1212,6 +1212,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * appear not as the counts should be low
 		 */
 		list_add(&page->lru, &free_pages);
+		/*
+		 * If pagelist are from multiple zones, we should decrease
+		 * NR_ISOLATED_ANON + x on freed pages in here.
+		 */
+		if (!zone)
+			dec_zone_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
 		continue;
 
 cull_mlocked:
@@ -1280,6 +1287,39 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	return ret;
 }
 
+unsigned long reclaim_pages_from_list(struct list_head *page_list)
+{
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.priority = DEF_PRIORITY,
+		.may_writepage = 1,
+		.may_unmap = 1,
+		.may_swap = 1,
+		.force_reclaim = 1,
+	};
+
+	unsigned long nr_reclaimed, dummy1, dummy2, dummy3, dummy4, dummy5;
+	struct page *page;
+
+	list_for_each_entry(page, page_list, lru)
+		ClearPageActive(page);
+
+	nr_reclaimed = shrink_page_list(page_list, &sc,
+					TTU_UNMAP|TTU_IGNORE_ACCESS,
+					&dummy1, &dummy2, &dummy3,
+					&dummy4, &dummy5);
+
+	while (!list_empty(page_list)) {
+		page = lru_to_page(page_list);
+		list_del(&page->lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				page_is_file_cache(page));
+		putback_lru_page(page);
+	}
+
+	return nr_reclaimed;
+}
+
 /*
  * Attempt to remove the specified page from its LRU.  Only take this page
  * if it is of the appropriate PageActive status.  Pages which are being
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
