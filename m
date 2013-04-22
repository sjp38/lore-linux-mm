Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 446736B0037
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 04:45:31 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 5/6] mm: Support address range reclaim
Date: Mon, 22 Apr 2013 17:45:05 +0900
Message-Id: <1366620306-30940-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1366620306-30940-1-git-send-email-minchan@kernel.org>
References: <1366620306-30940-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

This patch adds address range reclaim of a process.
The requirement is following as,

Like webkit1, it uses a address space for handling multi tabs.
IOW, it uses *one* process model so all tabs shares address space
of the process. In such scenario, per-process reclaim is rather
coarse-grained so this patch supports more fine-grained reclaim
for being able to reclaim target address range of the process.
For reclaim target range, you should use following format.

	echo 4 [address] [size] > /proc/pid/reclaim

So reclaim konb's interface is following as.

echo 1 > /proc/pid/reclaim
	reclaim file-backed pages only

echo 2 > /proc/pid/reclaim
	reclaim anonymous pages only

echo 3 > /proc/pid/reclaim
	reclaim all pages

echo 4 $((1<<20)) 4096 > /proc/pid/reclaim
	reclaim file-backed pages in (0x100000 - 0x101000)
echo 5 $((1<<20)) 4096 > /proc/pid/reclaim
	reclaim anonymous pages in (0x100000 - 0x101000)
echo 6 $((1<<20)) 4096 > /proc/pid/reclaim
	reclaim all pages in (0x100000 - 0x101000)

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/proc/task_mmu.c | 123 ++++++++++++++++++++++++++++++++++++++++-------------
 mm/internal.h      |   3 ++
 2 files changed, 96 insertions(+), 30 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3f67b32..5bd00d9 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1228,67 +1228,130 @@ cont:
 	return 0;
 }
 
-#define RECLAIM_FILE (1 << 0)
-#define RECLAIM_ANON (1 << 1)
-#define RECLAIM_ALL (RECLAIM_FILE | RECLAIM_ANON)
+enum reclaim_type {
+	RECLAIM_FILE = 1,
+	RECLAIM_ANON,
+	RECLAIM_ALL,
+	RECLAIM_FILE_RANGE,
+	RECLAIM_ANON_RANGE,
+	RECLAIM_BOTH_RANGE,
+};
 
 static ssize_t reclaim_write(struct file *file, const char __user *buf,
 				size_t count, loff_t *ppos)
 {
 	struct task_struct *task;
-	char buffer[PROC_NUMBUF];
+	char buffer[200];
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int type;
-	int rv;
+	int ret;
+	char *sptr, *token;
+	unsigned long len_in;
+	unsigned long start = 0;
+	unsigned long end = 0;
+	struct mm_walk reclaim_walk = {};
 
 	memset(buffer, 0, sizeof(buffer));
 	if (count > sizeof(buffer) - 1)
-		count = sizeof(buffer) - 1;
+		goto out_err;
+
 	if (copy_from_user(buffer, buf, count))
 		return -EFAULT;
-	rv = kstrtoint(strstrip(buffer), 10, &type);
-	if (rv < 0)
-		return rv;
-	if (type < RECLAIM_FILE || type > RECLAIM_ALL)
-		return -EINVAL;
+
+	sptr = strstrip(buffer);
+	token = strsep(&sptr, " ");
+	if (!token)
+		goto out_err;
+	ret = kstrtoint(token, 10, &type);
+	if (ret < 0 || (type < RECLAIM_FILE || type > RECLAIM_BOTH_RANGE))
+		goto out_err;
+
+	if (type > RECLAIM_ALL) {
+		size_t len;
+		token = strsep(&sptr, " ");
+		if (!token)
+			goto out_err;
+		ret = kstrtoul(token, 10, &start);
+		if (ret < 0)
+			goto out_err;
+
+		token = strsep(&sptr, " ");
+		if (!token)
+			goto out_err;
+		ret = kstrtoul(token, 10, &len_in);
+		if (ret < 0)
+			goto out_err;
+		len = (len_in + ~PAGE_MASK) & PAGE_MASK;
+
+		/*
+		 * Check to see whether len was rounded up from small -ve
+		 * to zero.
+		 */
+		if (len_in && !len)
+			goto out_err;
+
+		end = start + len;
+		if (end < start)
+			goto out_err;
+	}
+
 	task = get_proc_task(file->f_path.dentry->d_inode);
 	if (!task)
 		return -ESRCH;
+
 	mm = get_task_mm(task);
-	if (mm) {
-		struct mm_walk reclaim_walk = {
-			.pmd_entry = reclaim_pte_range,
-			.mm = mm,
-		};
-		down_read(&mm->mmap_sem);
+	if (!mm)
+		goto out;
+
+	reclaim_walk.mm = mm;
+	reclaim_walk.pmd_entry = reclaim_pte_range;
+
+	down_read(&mm->mmap_sem);
+	if (type > RECLAIM_ALL) {
+		vma = find_vma(mm, start);
+		while (vma) {
+			if (vma->vm_start > end)
+				break;
+
+			reclaim_walk.private = vma;
+			if (is_vm_hugetlb_page(vma))
+				continue;
+			if (type == RECLAIM_ANON_RANGE && vma->vm_file)
+				continue;
+			if (type == RECLAIM_FILE_RANGE && !vma->vm_file)
+				continue;
+
+			walk_page_range(max(vma->vm_start, start),
+					min(vma->vm_end, end),
+					&reclaim_walk);
+
+			vma = vma->vm_next;
+		}
+	} else {
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			reclaim_walk.private = vma;
 			if (is_vm_hugetlb_page(vma))
 				continue;
-			/*
-			 * Writing 1 to /proc/pid/reclaim only affects file
-			 * mapped pages.
-			 *
-			 * Writing 2 to /proc/pid/reclaim enly affects
-			 * anonymous pages.
-			 *
-			 * Writing 3 to /proc/pid/reclaim affects all pages.
-			 */
 			if (type == RECLAIM_ANON && vma->vm_file)
 				continue;
 			if (type == RECLAIM_FILE && !vma->vm_file)
 				continue;
 			walk_page_range(vma->vm_start, vma->vm_end,
-					&reclaim_walk);
+				&reclaim_walk);
 		}
-		flush_tlb_mm(mm);
-		up_read(&mm->mmap_sem);
-		mmput(mm);
 	}
+
+	flush_tlb_mm(mm);
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+out:
 	put_task_struct(task);
 
 	return count;
+
+out_err:
+	return -EINVAL;
 }
 
 const struct file_operations proc_reclaim_operations = {
diff --git a/mm/internal.h b/mm/internal.h
index 589a29b..1f7ce8f 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -85,6 +85,9 @@ static inline void get_page_foll(struct page *page)
 
 extern unsigned long highest_memmap_pfn;
 
+extern int isolate_lru_page(struct page *page);
+extern void putback_lru_page(struct page *page);
+
 /*
  * in mm/rmap.c:
  */
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
