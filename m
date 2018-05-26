Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33B2C6B0007
	for <linux-mm@kvack.org>; Sat, 26 May 2018 10:51:07 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 44-v6so6555185wrt.9
        for <linux-mm@kvack.org>; Sat, 26 May 2018 07:51:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1-v6sor13546638edp.37.2018.05.26.07.51.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 07:51:05 -0700 (PDT)
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
Date: Sat, 26 May 2018 16:50:46 +0200
Message-Id: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Salvatore Mesoraca <s.mesoraca16@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>, Kees Cook <keescook@chromium.org>

Prevent a task from opening, in "write" mode, any /proc/*/mem
file that operates on the task's mm.
/proc/*/mem is mainly a debugging means and, as such, it shouldn't
be used by the inspected process itself.
Current implementation always allow a task to access its own
/proc/*/mem file.
A process can use it to overwrite read-only memory, making
pointless the use of security_file_mprotect() or other ways to
enforce RO memory.

Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
---
 fs/proc/base.c       | 25 ++++++++++++++++++-------
 fs/proc/internal.h   |  3 ++-
 fs/proc/task_mmu.c   |  4 ++--
 fs/proc/task_nommu.c |  2 +-
 4 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1a76d75..01ecfec 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -762,8 +762,9 @@ static int proc_single_open(struct inode *inode, struct file *filp)
 	.release	= single_release,
 };
 
-
-struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
+struct mm_struct *proc_mem_open(struct inode *inode,
+				unsigned int mode,
+				fmode_t f_mode)
 {
 	struct task_struct *task = get_proc_task(inode);
 	struct mm_struct *mm = ERR_PTR(-ESRCH);
@@ -773,10 +774,20 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
 		put_task_struct(task);
 
 		if (!IS_ERR_OR_NULL(mm)) {
-			/* ensure this mm_struct can't be freed */
-			mmgrab(mm);
-			/* but do not pin its memory */
-			mmput(mm);
+			/*
+			 * Prevent this interface from being used as a mean
+			 * to bypass memory restrictions, including those
+			 * imposed by LSMs.
+			 */
+			if (mm == current->mm &&
+			    f_mode & FMODE_WRITE)
+				mm = ERR_PTR(-EACCES);
+			else {
+				/* ensure this mm_struct can't be freed */
+				mmgrab(mm);
+				/* but do not pin its memory */
+				mmput(mm);
+			}
 		}
 	}
 
@@ -785,7 +796,7 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
 
 static int __mem_open(struct inode *inode, struct file *file, unsigned int mode)
 {
-	struct mm_struct *mm = proc_mem_open(inode, mode);
+	struct mm_struct *mm = proc_mem_open(inode, mode, file->f_mode);
 
 	if (IS_ERR(mm))
 		return PTR_ERR(mm);
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 0f1692e..8d38cc7 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -275,7 +275,8 @@ struct proc_maps_private {
 #endif
 } __randomize_layout;
 
-struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode);
+struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode,
+				fmode_t f_mode);
 
 extern const struct file_operations proc_pid_maps_operations;
 extern const struct file_operations proc_tid_maps_operations;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c486ad4..efb6535 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -227,7 +227,7 @@ static int proc_maps_open(struct inode *inode, struct file *file,
 		return -ENOMEM;
 
 	priv->inode = inode;
-	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ, file->f_mode);
 	if (IS_ERR(priv->mm)) {
 		int err = PTR_ERR(priv->mm);
 
@@ -1534,7 +1534,7 @@ static int pagemap_open(struct inode *inode, struct file *file)
 {
 	struct mm_struct *mm;
 
-	mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	mm = proc_mem_open(inode, PTRACE_MODE_READ, file->f_mode);
 	if (IS_ERR(mm))
 		return PTR_ERR(mm);
 	file->private_data = mm;
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 5b62f57..dc38516 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -280,7 +280,7 @@ static int maps_open(struct inode *inode, struct file *file,
 		return -ENOMEM;
 
 	priv->inode = inode;
-	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ, file->f_mode);
 	if (IS_ERR(priv->mm)) {
 		int err = PTR_ERR(priv->mm);
 
-- 
1.9.1
