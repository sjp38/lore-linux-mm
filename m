Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4A87C6B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 21:52:46 -0400 (EDT)
Received: by pxi1 with SMTP id 1so465641pxi.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2009 18:52:52 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] mmap : save some cycles for the shared anonymous mapping
Date: Fri, 11 Sep 2009 09:52:46 +0800
Message-Id: <1252633966-20541-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

The shmem_zere_setup() does not change vm_start, pgoff or vm_flags,
only some drivers change them (such as /driver/video/bfin-t350mcqb-fb.c).

Moving these codes to a more proper place to save cycles for shared anonymous mapping.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/mmap.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 8101de4..840e91e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1195,21 +1195,21 @@ munmap_back:
 			goto unmap_and_free_vma;
 		if (vm_flags & VM_EXECUTABLE)
 			added_exe_file_vma(mm);
+
+		/* Can addr have changed??
+		 *
+		 * Answer: Yes, several device drivers can do it in their
+		 *         f_op->mmap method. -DaveM
+		 */
+		addr = vma->vm_start;
+		pgoff = vma->vm_pgoff;
+		vm_flags = vma->vm_flags;
 	} else if (vm_flags & VM_SHARED) {
 		error = shmem_zero_setup(vma);
 		if (error)
 			goto free_vma;
 	}
 
-	/* Can addr have changed??
-	 *
-	 * Answer: Yes, several device drivers can do it in their
-	 *         f_op->mmap method. -DaveM
-	 */
-	addr = vma->vm_start;
-	pgoff = vma->vm_pgoff;
-	vm_flags = vma->vm_flags;
-
 	if (vma_wants_writenotify(vma))
 		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
 
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
