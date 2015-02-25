Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id C4C426B0071
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:59:00 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id uy5so7052518obc.4
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:59:00 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id w5si10524065oej.102.2015.02.25.13.58.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 13:58:56 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 3/3] powerpc/oprofile: reduce mmap_sem hold for exe_file
Date: Wed, 25 Feb 2015 13:58:37 -0800
Message-Id: <1424901517-25069-4-git-send-email-dave@stgolabs.net>
In-Reply-To: <1424901517-25069-1-git-send-email-dave@stgolabs.net>
References: <1424901517-25069-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, arnd@arndb.de, rric@kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, oprofile-list@lists.sourceforge.net, Davidlohr Bueso <dbueso@suse.de>

In the future mm->exe_file will be done without mmap_sem
serialization, thus isolate and reorganize the related
code to make the transition easier. Good users will, make
use of the more standard get_mm_exe_file(), requiring only
holding the mmap_sem to read the value, and relying on reference
counting to make sure that the exe file won't dissappear
underneath us while getting the dcookie.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Robert Richter <rric@kernel.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: cbe-oss-dev@lists.ozlabs.org
Cc: oprofile-list@lists.sourceforge.net
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---

Completely untested.

 arch/powerpc/oprofile/cell/spu_task_sync.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/oprofile/cell/spu_task_sync.c b/arch/powerpc/oprofile/cell/spu_task_sync.c
index 1c27831..ed7b097 100644
--- a/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ b/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -22,6 +22,7 @@
 #include <linux/kref.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/module.h>
 #include <linux/notifier.h>
 #include <linux/numa.h>
@@ -322,18 +323,20 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 	unsigned long app_cookie = 0;
 	unsigned int my_offset = 0;
 	struct vm_area_struct *vma;
+	struct file *exe_file;
 	struct mm_struct *mm = spu->mm;
 
 	if (!mm)
 		goto out;
 
-	down_read(&mm->mmap_sem);
-
-	if (mm->exe_file) {
-		app_cookie = fast_get_dcookie(&mm->exe_file->f_path);
-		pr_debug("got dcookie for %pD\n", mm->exe_file);
+	exe_file = get_mm_exe_file(mm);
+	if (exe_file) {
+		app_cookie = fast_get_dcookie(&exe_file->f_path);
+		pr_debug("got dcookie for %pD\n", exe_file);
+		fput(exe_file);
 	}
 
+	down_read(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->vm_start > spu_ref || vma->vm_end <= spu_ref)
 			continue;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
