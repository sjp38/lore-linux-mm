Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id C01E66B0070
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:58:58 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id uz6so6981402obc.9
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:58:58 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id r127si2954818oig.99.2015.02.25.13.58.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 13:58:56 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 2/3] oprofile: reduce mmap_sem hold for mm->exe_file
Date: Wed, 25 Feb 2015 13:58:36 -0800
Message-Id: <1424901517-25069-3-git-send-email-dave@stgolabs.net>
In-Reply-To: <1424901517-25069-1-git-send-email-dave@stgolabs.net>
References: <1424901517-25069-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, rric@kernel.org, oprofile-list@lists.sf.net, Davidlohr Bueso <dbueso@suse.de>

sync_buffer() needs the mmap_sem for two distinct operations,
both only occurring upon user context switch handling:

 1) Dealing with the exe_file.

 2) Adding the dcookie data as we need to lookup the vma that
   backs it. This is done via add_sample() and add_data().

This patch isolates 1), for it will no longer need the mmap_sem
for serialization. However, for now, make of the more standard
get_mm_exe_file(), requiring only holding the mmap_sem to read
the value, and relying on reference counting to make sure that
the exe file won't dissappear underneath us while doing the get
dcookie.

As a consequence, for 2) we move the mmap_sem locking into where
we really need it, in lookup_dcookie(). The benefits are twofold:
reduce mmap_sem hold times, and cleaner code.

Cc: Robert Richter <rric@kernel.org>
Cc: oprofile-list@lists.sf.net
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/oprofile/buffer_sync.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/oprofile/buffer_sync.c b/drivers/oprofile/buffer_sync.c
index d93b2b6..82f7000 100644
--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -21,6 +21,7 @@
  * objects.
  */
 
+#include <linux/file.h>
 #include <linux/mm.h>
 #include <linux/workqueue.h>
 #include <linux/notifier.h>
@@ -224,10 +225,18 @@ static inline unsigned long fast_get_dcookie(struct path *path)
 static unsigned long get_exec_dcookie(struct mm_struct *mm)
 {
 	unsigned long cookie = NO_COOKIE;
+	struct file *exe_file;
 
-	if (mm && mm->exe_file)
-		cookie = fast_get_dcookie(&mm->exe_file->f_path);
+	if (!mm)
+		goto done;
+
+	exe_file = get_mm_exe_file(mm);
+	if (!exe_file)
+		goto done;
 
+	cookie = fast_get_dcookie(&exe_file->f_path);
+	fput(exe_file);
+done:
 	return cookie;
 }
 
@@ -236,6 +245,8 @@ static unsigned long get_exec_dcookie(struct mm_struct *mm)
  * pair that can then be added to the global event buffer. We make
  * sure to do this lookup before a mm->mmap modification happens so
  * we don't lose track.
+ *
+ * The caller must ensure the mm is not nil (ie: not a kernel thread).
  */
 static unsigned long
 lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
@@ -243,6 +254,7 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct *vma;
 
+	down_read(&mm->mmap_sem);
 	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
 
 		if (addr < vma->vm_start || addr >= vma->vm_end)
@@ -262,6 +274,7 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 
 	if (!vma)
 		cookie = INVALID_COOKIE;
+	up_read(&mm->mmap_sem);
 
 	return cookie;
 }
@@ -402,20 +415,9 @@ static void release_mm(struct mm_struct *mm)
 {
 	if (!mm)
 		return;
-	up_read(&mm->mmap_sem);
 	mmput(mm);
 }
 
-
-static struct mm_struct *take_tasks_mm(struct task_struct *task)
-{
-	struct mm_struct *mm = get_task_mm(task);
-	if (mm)
-		down_read(&mm->mmap_sem);
-	return mm;
-}
-
-
 static inline int is_code(unsigned long val)
 {
 	return val == ESCAPE_CODE;
@@ -532,7 +534,7 @@ void sync_buffer(int cpu)
 				new = (struct task_struct *)val;
 				oldmm = mm;
 				release_mm(oldmm);
-				mm = take_tasks_mm(new);
+				mm = get_task_mm(new);
 				if (mm != oldmm)
 					cookie = get_exec_dcookie(mm);
 				add_user_ctx_switch(new, cookie);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
