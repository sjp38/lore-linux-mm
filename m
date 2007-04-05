Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 785DE12240
	for <linux-mm@kvack.org>; Thu,  5 Apr 2007 11:01:54 +0200 (CEST)
Date: Thu, 5 Apr 2007 11:01:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: madvise avoid mmap_sem write
Message-ID: <20070405090154.GA11102@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Here is a newer version of the patch.

--

Avoid down_write of the mmap_sem in madvise when we can help it.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/madvise.c
===================================================================
--- linux-2.6.orig/mm/madvise.c
+++ linux-2.6/mm/madvise.c
@@ -12,6 +12,24 @@
 #include <linux/hugetlb.h>
 
 /*
+ * Any behaviour which results in changes to the vma->vm_flags needs to
+ * take mmap_sem for writing. Others, which simply traverse vmas, need
+ * to only take it for reading.
+ */
+static int madvise_need_mmap_write(int behavior)
+{
+	switch (behavior) {
+	case MADV_REMOVE:
+	case MADV_WILLNEED:
+	case MADV_DONTNEED:
+		return 0;
+	default:
+		/* be safe, default to 1. list exceptions explicitly */
+		return 1;
+	}
+}
+
+/*
  * We can potentially split a vm area into separate
  * areas, each area with its own behavior.
  */
@@ -183,9 +201,9 @@ static long madvise_remove(struct vm_are
 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 
 	/* vmtruncate_range needs to take i_mutex and i_alloc_sem */
-	up_write(&current->mm->mmap_sem);
+	up_read(&current->mm->mmap_sem);
 	error = vmtruncate_range(mapping->host, offset, endoff);
-	down_write(&current->mm->mmap_sem);
+	down_read(&current->mm->mmap_sem);
 	return error;
 }
 
@@ -270,7 +288,10 @@ asmlinkage long sys_madvise(unsigned lon
 	int error = -EINVAL;
 	size_t len;
 
-	down_write(&current->mm->mmap_sem);
+	if (madvise_need_mmap_write(behavior))
+		down_write(&current->mm->mmap_sem);
+	else
+		down_read(&current->mm->mmap_sem);
 
 	if (start & ~PAGE_MASK)
 		goto out;
@@ -332,6 +353,10 @@ asmlinkage long sys_madvise(unsigned lon
 			vma = find_vma(current->mm, start);
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	if (madvise_need_mmap_write(behavior))
+		up_write(&current->mm->mmap_sem);
+	else
+		up_read(&current->mm->mmap_sem);
+
 	return error;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
