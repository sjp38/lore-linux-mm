Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id A5F506B006E
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:58:56 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id i138so5976836oig.4
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:58:56 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id w199si7225169oiw.117.2015.02.25.13.58.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 13:58:55 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 1/3] tile/elf: reorganize notify_exec()
Date: Wed, 25 Feb 2015 13:58:35 -0800
Message-Id: <1424901517-25069-2-git-send-email-dave@stgolabs.net>
In-Reply-To: <1424901517-25069-1-git-send-email-dave@stgolabs.net>
References: <1424901517-25069-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, cmetcalf@ezchip.com, Davidlohr Bueso <dbueso@suse.de>

In the future mm->exe_file will be done without mmap_sem
serialization, thus isolate and reorganize the tile elf
code to make the transition easier. Good users will, make
use of the more standard get_mm_exe_file(), requiring only
holding the mmap_sem to read the value, and relying on reference
counting to make sure that the exe file won't dissappear
underneath us.

The visible effects of this patch are:

   o We now take and drop the mmap_sem more often. Instead of
     just in arch_setup_additional_pages(), we also do it in:

     1) get_mm_exe_file()
     2) to get the mm->vm_file and notify the simulator.

    [Note that 1) will disappear once we change the locking
     rules for exe_file.]

   o We avoid getting a free page and doing d_path() while
     holding the mmap_sem. This requires reordering the checks.

Cc: Chris Metcalf <cmetcalf@ezchip.com>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---

completely untested.

 arch/tile/mm/elf.c | 47 +++++++++++++++++++++++++++++------------------
 1 file changed, 29 insertions(+), 18 deletions(-)

diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 23f044e..f7ddae3 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -17,6 +17,7 @@
 #include <linux/binfmts.h>
 #include <linux/compat.h>
 #include <linux/mman.h>
+#include <linux/file.h>
 #include <linux/elf.h>
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -39,30 +40,34 @@ static void sim_notify_exec(const char *binary_name)
 
 static int notify_exec(struct mm_struct *mm)
 {
+	int ret = 0;
 	char *buf, *path;
 	struct vm_area_struct *vma;
+	struct file *exe_file;
 
 	if (!sim_is_simulator())
 		return 1;
 
-	if (mm->exe_file == NULL)
-		return 0;
-
-	for (vma = current->mm->mmap; ; vma = vma->vm_next) {
-		if (vma == NULL)
-			return 0;
-		if (vma->vm_file == mm->exe_file)
-			break;
-	}
-
 	buf = (char *) __get_free_page(GFP_KERNEL);
 	if (buf == NULL)
 		return 0;
 
-	path = d_path(&mm->exe_file->f_path, buf, PAGE_SIZE);
-	if (IS_ERR(path)) {
-		free_page((unsigned long)buf);
-		return 0;
+	exe_file = get_mm_exe_file(mm);
+	if (exe_file == NULL)
+		goto done_free;
+
+	path = d_path(&exe_file->f_path, buf, PAGE_SIZE);
+	if (IS_ERR(path))
+		goto done_put;
+
+	down_read(&mm->mmap_sem);
+	for (vma = current->mm->mmap; ; vma = vma->vm_next) {
+		if (vma == NULL) {
+			up_read(&mm->mmap_sem);
+			goto done_put;
+		}
+		if (vma->vm_file == exe_file)
+			break;
 	}
 
 	/*
@@ -80,14 +85,20 @@ static int notify_exec(struct mm_struct *mm)
 			__insn_mtspr(SPR_SIM_CONTROL,
 				     (SIM_CONTROL_DLOPEN
 				      | (c << _SIM_CONTROL_OPERATOR_BITS)));
-			if (c == '\0')
+			if (c == '\0') {
+				ret = 1; /* success */
 				break;
+			}
 		}
 	}
+	up_read(&mm->mmap_sem);
 
 	sim_notify_exec(path);
+done_put:
+	fput(exe_file);
+done_free:
 	free_page((unsigned long)buf);
-	return 1;
+	return ret;
 }
 
 /* Notify a running simulator, if any, that we loaded an interpreter. */
@@ -109,8 +120,6 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	struct mm_struct *mm = current->mm;
 	int retval = 0;
 
-	down_write(&mm->mmap_sem);
-
 	/*
 	 * Notify the simulator that an exec just occurred.
 	 * If we can't find the filename of the mapping, just use
@@ -119,6 +128,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	if (!notify_exec(mm))
 		sim_notify_exec(bprm->filename);
 
+	down_write(&mm->mmap_sem);
+
 	retval = setup_vdso_pages();
 
 #ifndef __tilegx__
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
