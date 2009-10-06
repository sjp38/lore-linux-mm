Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4E4B46B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 05:51:14 -0400 (EDT)
Date: Tue, 6 Oct 2009 11:51:11 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH][RFC] add MAP_UNLOCKED mmap flag
Message-ID: <20091006095111.GG9832@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If application does mlockall(MCL_FUTURE) it is no longer possible to
mmap file bigger than main memory or allocate big area of anonymous
memory. Sometimes it is desirable to lock everything related to program
execution into memory, but still be able to mmap big file or allocate
huge amount of memory and allow OS to swap them on demand. MAP_UNLOCKED
allows to do that.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
diff --git a/include/asm-generic/mman.h b/include/asm-generic/mman.h
index 32c8bd6..0ab4c74 100644
--- a/include/asm-generic/mman.h
+++ b/include/asm-generic/mman.h
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_UNLOKED	0x80000         /* pages are unlocked */
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
diff --git a/mm/mmap.c b/mm/mmap.c
index 73f5e4b..7c2abdb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -985,6 +985,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		if (!can_do_mlock())
 			return -EPERM;
 
+        if (flags & MAP_UNLOKED)
+                vm_flags &= ~VM_LOCKED;
+
 	/* mlock MCL_FUTURE? */
 	if (vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
