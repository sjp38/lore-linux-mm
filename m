Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E47B66B04B2
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 04:05:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z53so36485252wrz.10
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:05:32 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id k32si3681497wrc.311.2017.07.28.00.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 00:58:40 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id y43so25925172wrd.0
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 00:58:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] fs, proc: remove priv argument from is_stack
Date: Fri, 28 Jul 2017 09:58:33 +0200
Message-Id: <20170728075833.7241-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

b18cb64ead40 ("fs/proc: Stop trying to report thread stacks") has
removed the priv parameter user in is_stack so the argument is
redundant. Drop it.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
I have sent this trivial cleanup earlier when we were discussing stack
gap issue and it seemed to fall between cracks. I have just rebased it
on top of the current mmotm tree. It is a trivial cleanup. I was also
considering to move it out of task_{no}mmu.c and do a generic helper out
of it but then I just thought it might be more confusing than helpful
so I kept it there with their only users.

 fs/proc/task_mmu.c   | 7 +++----
 fs/proc/task_nommu.c | 5 ++---
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b836fd61ed87..7f331ce63fc8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -266,8 +266,7 @@ static int do_maps_open(struct inode *inode, struct file *file,
  * Indicate if the VMA is a stack for the given task; for
  * /proc/PID/maps that is the stack of the main task.
  */
-static int is_stack(struct proc_maps_private *priv,
-		    struct vm_area_struct *vma)
+static int is_stack(struct vm_area_struct *vma)
 {
 	/*
 	 * We make no effort to guess what a given thread considers to be
@@ -341,7 +340,7 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 			goto done;
 		}
 
-		if (is_stack(priv, vma))
+		if (is_stack(vma))
 			name = "[stack]";
 	}
 
@@ -1670,7 +1669,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 		seq_file_path(m, file, "\n\t= ");
 	} else if (vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk) {
 		seq_puts(m, " heap");
-	} else if (is_stack(proc_priv, vma)) {
+	} else if (is_stack(vma)) {
 		seq_puts(m, " stack");
 	}
 
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 23266694db11..dea90b566a6e 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -125,8 +125,7 @@ unsigned long task_statm(struct mm_struct *mm,
 	return size;
 }
 
-static int is_stack(struct proc_maps_private *priv,
-		    struct vm_area_struct *vma)
+static int is_stack(struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;
 
@@ -178,7 +177,7 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
 	if (file) {
 		seq_pad(m, ' ');
 		seq_file_path(m, file, "");
-	} else if (mm && is_stack(priv, vma)) {
+	} else if (mm && is_stack(vma)) {
 		seq_pad(m, ' ');
 		seq_printf(m, "[stack]");
 	}
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
