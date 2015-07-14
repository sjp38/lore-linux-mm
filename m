Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 71EAD28024D
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:37:40 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so8567960lbb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:37:39 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id x3si1257038lal.47.2015.07.14.08.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 08:37:38 -0700 (PDT)
Subject: [PATCH v4 1/5] pagemap: check permissions and capabilities at open
 time
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 14 Jul 2015 18:37:35 +0300
Message-ID: <20150714153735.29844.38428.stgit@buzz>
In-Reply-To: <20150714152516.29844.69929.stgit@buzz>
References: <20150714152516.29844.69929.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

This patch moves permission checks from pagemap_read() into pagemap_open().

Pointer to mm is saved in file->private_data. This reference pins only
mm_struct itself. /proc/*/mem, maps, smaps already work in the same way.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Link: http://lkml.kernel.org/r/CA+55aFyKpWrt_Ajzh1rzp_GcwZ4=6Y=kOv8hBz172CFJp6L8Tg@mail.gmail.com
---
 fs/proc/task_mmu.c |   48 ++++++++++++++++++++++++++++--------------------
 1 file changed, 28 insertions(+), 20 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ca1e091881d4..270bf7cbc8a5 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1227,40 +1227,33 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 static ssize_t pagemap_read(struct file *file, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
-	struct task_struct *task = get_proc_task(file_inode(file));
-	struct mm_struct *mm;
+	struct mm_struct *mm = file->private_data;
 	struct pagemapread pm;
-	int ret = -ESRCH;
 	struct mm_walk pagemap_walk = {};
 	unsigned long src;
 	unsigned long svpfn;
 	unsigned long start_vaddr;
 	unsigned long end_vaddr;
-	int copied = 0;
+	int ret = 0, copied = 0;
 
-	if (!task)
+	if (!mm || !atomic_inc_not_zero(&mm->mm_users))
 		goto out;
 
 	ret = -EINVAL;
 	/* file position must be aligned */
 	if ((*ppos % PM_ENTRY_BYTES) || (count % PM_ENTRY_BYTES))
-		goto out_task;
+		goto out_mm;
 
 	ret = 0;
 	if (!count)
-		goto out_task;
+		goto out_mm;
 
 	pm.v2 = soft_dirty_cleared;
 	pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
 	pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
 	ret = -ENOMEM;
 	if (!pm.buffer)
-		goto out_task;
-
-	mm = mm_access(task, PTRACE_MODE_READ);
-	ret = PTR_ERR(mm);
-	if (!mm || IS_ERR(mm))
-		goto out_free;
+		goto out_mm;
 
 	pagemap_walk.pmd_entry = pagemap_pte_range;
 	pagemap_walk.pte_hole = pagemap_pte_hole;
@@ -1273,10 +1266,10 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	src = *ppos;
 	svpfn = src / PM_ENTRY_BYTES;
 	start_vaddr = svpfn << PAGE_SHIFT;
-	end_vaddr = TASK_SIZE_OF(task);
+	end_vaddr = mm->task_size;
 
 	/* watch out for wraparound */
-	if (svpfn > TASK_SIZE_OF(task) >> PAGE_SHIFT)
+	if (svpfn > mm->task_size >> PAGE_SHIFT)
 		start_vaddr = end_vaddr;
 
 	/*
@@ -1303,7 +1296,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		len = min(count, PM_ENTRY_BYTES * pm.pos);
 		if (copy_to_user(buf, pm.buffer, len)) {
 			ret = -EFAULT;
-			goto out_mm;
+			goto out_free;
 		}
 		copied += len;
 		buf += len;
@@ -1313,24 +1306,38 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!ret || ret == PM_END_OF_BUFFER)
 		ret = copied;
 
-out_mm:
-	mmput(mm);
 out_free:
 	kfree(pm.buffer);
-out_task:
-	put_task_struct(task);
+out_mm:
+	mmput(mm);
 out:
 	return ret;
 }
 
 static int pagemap_open(struct inode *inode, struct file *file)
 {
+	struct mm_struct *mm;
+
 	/* do not disclose physical addresses: attack vector */
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 	pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
 			"to stop being page-shift some time soon. See the "
 			"linux/Documentation/vm/pagemap.txt for details.\n");
+
+	mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	if (IS_ERR(mm))
+		return PTR_ERR(mm);
+	file->private_data = mm;
+	return 0;
+}
+
+static int pagemap_release(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm = file->private_data;
+
+	if (mm)
+		mmdrop(mm);
 	return 0;
 }
 
@@ -1338,6 +1345,7 @@ const struct file_operations proc_pagemap_operations = {
 	.llseek		= mem_lseek, /* borrow this */
 	.read		= pagemap_read,
 	.open		= pagemap_open,
+	.release	= pagemap_release,
 };
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
