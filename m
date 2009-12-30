Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4C07660021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 15:17:38 -0500 (EST)
Date: Wed, 30 Dec 2009 20:17:34 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] mm: move sys_mmap_pgoff from util.c
Message-ID: <alpine.LSU.2.00.0912302009040.30390@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, David Howells <dhowells@redhat.com>, Eric B Munson <ebmunson@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move sys_mmap_pgoff() from mm/util.c to mm/mmap.c and mm/nommu.c,
where we'd expect to find such code: especially now that it contains
the MAP_HUGETLB handling.  Revert mm/util.c to how it was in 2.6.32.

This patch just ignores MAP_HUGETLB in the nommu case, as in 2.6.32,
whereas 2.6.33-rc2 reported -ENOSYS.  Perhaps validate_mmap_request()
should reject it with -EINVAL?  Add that later if necessary.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/mmap.c  |   40 ++++++++++++++++++++++++++++++++++++++++
 mm/nommu.c |   25 +++++++++++++++++++++++++
 mm/util.c  |   44 --------------------------------------------
 3 files changed, 65 insertions(+), 44 deletions(-)

--- 2.6.33-rc2/mm/mmap.c	2009-12-18 11:42:54.000000000 +0000
+++ linux/mm/mmap.c	2009-12-26 18:28:30.000000000 +0000
@@ -1043,6 +1043,46 @@ unsigned long do_mmap_pgoff(struct file
 }
 EXPORT_SYMBOL(do_mmap_pgoff);
 
+SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
+		unsigned long, prot, unsigned long, flags,
+		unsigned long, fd, unsigned long, pgoff)
+{
+	struct file *file = NULL;
+	unsigned long retval = -EBADF;
+
+	if (!(flags & MAP_ANONYMOUS)) {
+		if (unlikely(flags & MAP_HUGETLB))
+			return -EINVAL;
+		file = fget(fd);
+		if (!file)
+			goto out;
+	} else if (flags & MAP_HUGETLB) {
+		struct user_struct *user = NULL;
+		/*
+		 * VM_NORESERVE is used because the reservations will be
+		 * taken when vm_ops->mmap() is called
+		 * A dummy user value is used because we are not locking
+		 * memory so no accounting is necessary
+		 */
+		len = ALIGN(len, huge_page_size(&default_hstate));
+		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len, VM_NORESERVE,
+						&user, HUGETLB_ANONHUGE_INODE);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+	}
+
+	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
+
+	down_write(&current->mm->mmap_sem);
+	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	up_write(&current->mm->mmap_sem);
+
+	if (file)
+		fput(file);
+out:
+	return retval;
+}
+
 /*
  * Some shared mappigns will want the pages marked read-only
  * to track write events. If so, we'll downgrade vm_page_prot
--- 2.6.33-rc2/mm/nommu.c	2009-12-18 11:42:54.000000000 +0000
+++ linux/mm/nommu.c	2009-12-26 18:28:30.000000000 +0000
@@ -1398,6 +1398,31 @@ error_getting_region:
 }
 EXPORT_SYMBOL(do_mmap_pgoff);
 
+SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
+		unsigned long, prot, unsigned long, flags,
+		unsigned long, fd, unsigned long, pgoff)
+{
+	struct file *file = NULL;
+	unsigned long retval = -EBADF;
+
+	if (!(flags & MAP_ANONYMOUS)) {
+		file = fget(fd);
+		if (!file)
+			goto out;
+	}
+
+	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
+
+	down_write(&current->mm->mmap_sem);
+	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	up_write(&current->mm->mmap_sem);
+
+	if (file)
+		fput(file);
+out:
+	return retval;
+}
+
 /*
  * split a vma into two pieces at address 'addr', a new vma is allocated either
  * for the first part or the tail.
--- 2.6.33-rc2/mm/util.c	2009-12-18 11:42:55.000000000 +0000
+++ linux/mm/util.c	2009-12-26 18:28:30.000000000 +0000
@@ -4,10 +4,6 @@
 #include <linux/module.h>
 #include <linux/err.h>
 #include <linux/sched.h>
-#include <linux/hugetlb.h>
-#include <linux/syscalls.h>
-#include <linux/mman.h>
-#include <linux/file.h>
 #include <asm/uaccess.h>
 
 #define CREATE_TRACE_POINTS
@@ -272,46 +268,6 @@ int __attribute__((weak)) get_user_pages
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
-SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
-		unsigned long, prot, unsigned long, flags,
-		unsigned long, fd, unsigned long, pgoff)
-{
-	struct file * file = NULL;
-	unsigned long retval = -EBADF;
-
-	if (!(flags & MAP_ANONYMOUS)) {
-		if (unlikely(flags & MAP_HUGETLB))
-			return -EINVAL;
-		file = fget(fd);
-		if (!file)
-			goto out;
-	} else if (flags & MAP_HUGETLB) {
-		struct user_struct *user = NULL;
-		/*
-		 * VM_NORESERVE is used because the reservations will be
-		 * taken when vm_ops->mmap() is called
-		 * A dummy user value is used because we are not locking
-		 * memory so no accounting is necessary
-		 */
-		len = ALIGN(len, huge_page_size(&default_hstate));
-		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len, VM_NORESERVE,
-						&user, HUGETLB_ANONHUGE_INODE);
-		if (IS_ERR(file))
-			return PTR_ERR(file);
-	}
-
-	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-
-	down_write(&current->mm->mmap_sem);
-	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
-
-	if (file)
-		fput(file);
-out:
-	return retval;
-}
-
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
