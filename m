Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6976B0075
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 12:16:40 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so9742329wiw.15
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 09:16:40 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id y7si17510015wjy.65.2014.12.15.09.16.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 09:16:39 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id x12so15189808wgg.10
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 09:16:39 -0800 (PST)
From: Petr Cermak <petrcermak@chromium.org>
Subject: [PATCH 2/2] task_mmu: Add user-space support for resetting mm->hiwater_rss (peak RSS)
Date: Mon, 15 Dec 2014 17:15:33 +0000
Message-Id: <1418663733-15949-1-git-send-email-petrcermak@chromium.org>
References: <1418223544-11382-1-git-send-email-petrcermak@chromium.org>
In-Reply-To: <1418223544-11382-1-git-send-email-petrcermak@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Petr Cermak <petrcermak@chromium.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>

Peak resident size of a process can be reset by writing "5" to
/proc/pid/clear_refs. The driving use-case for this would be getting the
peak RSS value, which can be retrieved from the VmHWM field in
/proc/pid/status, per benchmark iteration or test scenario.

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Primiano Tucci <primiano@chromium.org>
Cc: Petr Cermak <petrcermak@chromium.org>
Signed-off-by: Petr Cermak <petrcermak@chromium.org>
---
 Documentation/filesystems/proc.txt |  3 +++
 fs/proc/task_mmu.c                 | 15 ++++++++++++++-
 include/linux/mm.h                 |  5 +++++
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index aae9dd1..eab62e3 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -488,6 +488,9 @@ To clear the bits for the file mapped pages associated with the process
 To clear the soft-dirty bit
     > echo 4 > /proc/PID/clear_refs
 
+To reset the peak resident set size ("high water mark")
+    > echo 5 > /proc/PID/clear_refs
+
 Any other value written to /proc/PID/clear_refs will have no effect.
 
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3ee8541..7967535 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -747,6 +747,7 @@ enum clear_refs_types {
 	CLEAR_REFS_ANON,
 	CLEAR_REFS_MAPPED,
 	CLEAR_REFS_SOFT_DIRTY,
+	CLEAR_REFS_MM_HIWATER_RSS,
 	CLEAR_REFS_LAST,
 };
 
@@ -855,6 +856,17 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	if (!mm)
 		goto out_task;
 
+	if (type == CLEAR_REFS_MM_HIWATER_RSS) {
+		/*
+		 * Writing 5 to /proc/pid/clear_refs resets the peak resident
+		 * set size.
+		 */
+		down_write(&mm->mmap_sem);
+		reset_mm_hiwater_rss(mm);
+		up_write(&mm->mmap_sem);
+		goto out_mm;
+	}
+
 	struct clear_refs_private cp = {
 		.type = type,
 	};
@@ -904,8 +916,9 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		mmu_notifier_invalidate_range_end(mm, 0, -1);
 	flush_tlb_mm(mm);
 	up_read(&mm->mmap_sem);
-	mmput(mm);
 
+out_mm:
+	mmput(mm);
 out_task:
 	put_task_struct(task);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c0a67b8..f3f6cee 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1368,6 +1368,11 @@ static inline void update_hiwater_vm(struct mm_struct *mm)
 		mm->hiwater_vm = mm->total_vm;
 }
 
+static inline void reset_mm_hiwater_rss(struct mm_struct *mm)
+{
+	mm->hiwater_rss = get_mm_rss(mm);
+}
+
 static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
 					 struct mm_struct *mm)
 {
-- 
2.2.0.rc0.207.ga3a616c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
