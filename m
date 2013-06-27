Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 230E86B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 19:16:07 -0400 (EDT)
Subject: [RFC][PATCH] mm: madvise: MADV_POPULATE for quick pre-faulting
From: Dave Hansen <dave@sr71.net>
Date: Thu, 27 Jun 2013 16:16:05 -0700
Message-Id: <20130627231605.8F9F12E6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>


I've been doing some testing involving large amounts of
page cache.  It's quite painful to get hundreds of GB
of page cache mapped in, especially when I am trying to
do it in parallel threads.  This is true even when the
page cache is already allocated and I only need to map
it in.  The test:

1. take 160 16MB files
2. clone 160 threads, mmap the 16MB files, and either
  a. walk through the file touching each page
  b. run MADV_POPULATE on the file
3. MADV_DONTNEED on the mmap()'d area

160 threads/processes:
	    faulting | MADV_POPULATE
  Threads:       698 |        102239 (146x speedup)
Proceeses:    154247 |        297518 (1.9x speedup)

single threaded:
	    faulting | MADV_POPULATE
                1908 |          3710 (1.9x speedup)

To fix the thread suckage, this patch just walks the
VMAs and maps all the pages in.  Since it does a
bunch of them in one go, it amortizes the cost of
acquiring the mmap_sem across all of those pages.

FAQ:

Why do threads suck so much?

	Bouncing the mmap_sem cacheline around, plus anything
	else that we write to during a fault.  We do one page,
	move the cachelines to another CPU, do one more page,
	etc...

Does MADV_DONTNEED work for this?

	No.  It brings the pages in to the page cache, but
	does not map them the way it is implemented at the
	moment.  I guess we'd be within our rights to make
	it behave like MADV_POPULATE if we want though.



---

 linux.git-davehans/include/uapi/asm-generic/mman-common.h |    1 
 linux.git-davehans/mm/madvise.c                           |   40 +++++++++++++-
 2 files changed, 40 insertions(+), 1 deletion(-)

diff -puN include/uapi/asm-generic/mman-common.h~madv_populate include/uapi/asm-generic/mman-common.h
--- linux.git/include/uapi/asm-generic/mman-common.h~madv_populate	2013-06-27 15:22:35.651854196 -0700
+++ linux.git-davehans/include/uapi/asm-generic/mman-common.h	2013-06-27 15:22:35.656854418 -0700
@@ -51,6 +51,7 @@
 #define MADV_DONTDUMP   16		/* Explicity exclude from the core dump,
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
+#define MADV_POPULATE	18		/* Fill in mapping like faults would */
 
 /* compatibility flags */
 #define MAP_FILE	0
diff -puN mm/madvise.c~madv_populate mm/madvise.c
--- linux.git/mm/madvise.c~madv_populate	2013-06-27 15:22:35.652854240 -0700
+++ linux.git-davehans/mm/madvise.c	2013-06-27 15:22:35.656854418 -0700
@@ -19,6 +19,7 @@
 #include <linux/blkdev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include "internal.h"
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -31,6 +32,7 @@ static int madvise_need_mmap_write(int b
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_POPULATE:
 		return 0;
 	default:
 		/* be safe, default to 1. list exceptions explicitly */
@@ -252,6 +254,39 @@ static long madvise_willneed(struct vm_a
 }
 
 /*
+ * Do not just populate the page cache (WILLNEED), also map the pages.
+ */
+static long madvise_populate(struct vm_area_struct * vma,
+			     struct vm_area_struct ** prev,
+			     unsigned long start, unsigned long end)
+{
+	struct file *file = vma->vm_file;
+	int locked = 1;
+	int ret;
+
+	if (file && file->f_mapping->a_ops->get_xip_mem) {
+		/* no bad return value, but ignore advice */
+		return 0;
+	}
+
+	ret = __mlock_vma_pages_range(vma, start, end, &locked);
+	/*
+	 * Make sure that out down_read() matches (read vs.
+	 * write) what we did in sys_madvise.
+	 */
+	BUG_ON(madvise_need_mmap_write(MADV_POPULATE));
+	if (!locked) {
+		down_read(&current->mm->mmap_sem);
+		/* tell sys_madvise we drop mmap_sem: */
+		*prev = NULL;
+	} else {
+		*prev = vma;
+	}
+
+	return ret;
+}
+
+/*
  * Application no longer needs these pages.  If the pages are dirty,
  * it's OK to just throw them away.  The app will be more careful about
  * data it wants to keep.  Be sure to free swap resources too.  The
@@ -378,6 +413,8 @@ madvise_vma(struct vm_area_struct *vma,
 		return madvise_remove(vma, prev, start, end);
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
+	case MADV_POPULATE:
+		return madvise_populate(vma, prev, start, end);
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
 	default:
@@ -407,6 +444,7 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_POPULATE:
 		return 1;
 
 	default:
@@ -536,7 +574,7 @@ SYSCALL_DEFINE3(madvise, unsigned long,
 			goto out;
 		if (prev)
 			vma = prev->vm_next;
-		else	/* madvise_remove dropped mmap_sem */
+		else	/* madvise_remove/populate dropped mmap_sem */
 			vma = find_vma(current->mm, start);
 	}
 out:
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
