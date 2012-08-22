Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 3A7B76B0044
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 23:40:23 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so910120pbb.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 20:40:22 -0700 (PDT)
Date: Wed, 22 Aug 2012 11:40:12 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch]readahead: fault retry breaks mmap file read random detection
Message-ID: <20120822034012.GA24099@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: fengguang.wu@intel.com, akpm@linux-foundation.org, riel@redhat.com

.fault now can retry. The retry can break state machine of .fault. In
filemap_fault, if page is miss, ra->mmap_miss is increased. In the second try,
since the page is in page cache now, ra->mmap_miss is decreased. And these are
done in one fault, so we can't detect random mmap file access.

Add a new flag to indicate .fault is tried once. In the second try, skip
ra->mmap_miss decreasing. The filemap_fault state machine is ok with it.

I only tested x86, didn't test other archs, but looks the change for other
archs is obvious, but who knows :)

Signed-off-by: Shaohua Li <shaohua.li@fusionio.com>
---
 arch/arm/mm/fault.c        |    1 +
 arch/avr32/mm/fault.c      |    1 +
 arch/cris/mm/fault.c       |    1 +
 arch/hexagon/mm/vm_fault.c |    1 +
 arch/ia64/mm/fault.c       |    1 +
 arch/m68k/mm/fault.c       |    1 +
 arch/microblaze/mm/fault.c |    1 +
 arch/mips/mm/fault.c       |    1 +
 arch/openrisc/mm/fault.c   |    1 +
 arch/powerpc/mm/fault.c    |    1 +
 arch/s390/mm/fault.c       |    1 +
 arch/sh/mm/fault.c         |    1 +
 arch/sparc/mm/fault_32.c   |    1 +
 arch/sparc/mm/fault_64.c   |    1 +
 arch/tile/mm/fault.c       |    1 +
 arch/um/kernel/trap.c      |    1 +
 arch/x86/mm/fault.c        |    1 +
 arch/xtensa/mm/fault.c     |    1 +
 include/linux/mm.h         |    1 +
 mm/filemap.c               |    4 ++--
 20 files changed, 21 insertions(+), 2 deletions(-)

Index: linux/arch/x86/mm/fault.c
===================================================================
--- linux.orig/arch/x86/mm/fault.c	2012-08-22 09:51:22.939527887 +0800
+++ linux/arch/x86/mm/fault.c	2012-08-22 09:52:22.818774975 +0800
@@ -1201,6 +1201,7 @@ good_area:
 			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
 			 * of starvation. */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
 	}
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2012-08-22 09:51:23.087526029 +0800
+++ linux/include/linux/mm.h	2012-08-22 09:52:22.822775020 +0800
@@ -157,6 +157,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
+#define FAULT_FLAG_TRIED	0x40	/* second try */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
Index: linux/mm/filemap.c
===================================================================
--- linux.orig/mm/filemap.c	2012-08-22 09:51:23.079526129 +0800
+++ linux/mm/filemap.c	2012-08-22 09:52:22.822775020 +0800
@@ -1611,13 +1611,13 @@ int filemap_fault(struct vm_area_struct
 	 * Do we have something in the page cache already?
 	 */
 	page = find_get_page(mapping, offset);
-	if (likely(page)) {
+	if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
 		/*
 		 * We found the page, so try async readahead before
 		 * waiting for the lock.
 		 */
 		do_async_mmap_readahead(vma, ra, file, page, offset);
-	} else {
+	} else if (!page) {
 		/* No page in the page cache at all */
 		do_sync_mmap_readahead(vma, ra, file, offset);
 		count_vm_event(PGMAJFAULT);
Index: linux/arch/arm/mm/fault.c
===================================================================
--- linux.orig/arch/arm/mm/fault.c	2012-08-22 09:51:22.899528391 +0800
+++ linux/arch/arm/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -336,6 +336,7 @@ retry:
 			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
 			* of starvation. */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
 	}
Index: linux/arch/avr32/mm/fault.c
===================================================================
--- linux.orig/arch/avr32/mm/fault.c	2012-08-22 09:51:23.035526683 +0800
+++ linux/arch/avr32/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -152,6 +152,7 @@ good_area:
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would have
Index: linux/arch/cris/mm/fault.c
===================================================================
--- linux.orig/arch/cris/mm/fault.c	2012-08-22 09:51:23.059526379 +0800
+++ linux/arch/cris/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -186,6 +186,7 @@ retry:
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would
Index: linux/arch/hexagon/mm/vm_fault.c
===================================================================
--- linux.orig/arch/hexagon/mm/vm_fault.c	2012-08-22 09:51:22.915528191 +0800
+++ linux/arch/hexagon/mm/vm_fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -113,6 +113,7 @@ good_area:
 				current->min_flt++;
 			if (fault & VM_FAULT_RETRY) {
 				flags &= ~FAULT_FLAG_ALLOW_RETRY;
+				flags |= FAULT_FLAG_TRIED;
 				goto retry;
 			}
 		}
Index: linux/arch/ia64/mm/fault.c
===================================================================
--- linux.orig/arch/ia64/mm/fault.c	2012-08-22 09:51:22.967527537 +0800
+++ linux/arch/ia64/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -184,6 +184,7 @@ retry:
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
Index: linux/arch/m68k/mm/fault.c
===================================================================
--- linux.orig/arch/m68k/mm/fault.c	2012-08-22 09:51:23.015526933 +0800
+++ linux/arch/m68k/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -170,6 +170,7 @@ good_area:
 			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
 			 * of starvation. */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would
Index: linux/arch/microblaze/mm/fault.c
===================================================================
--- linux.orig/arch/microblaze/mm/fault.c	2012-08-22 09:51:22.995527183 +0800
+++ linux/arch/microblaze/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -233,6 +233,7 @@ good_area:
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would
Index: linux/arch/mips/mm/fault.c
===================================================================
--- linux.orig/arch/mips/mm/fault.c	2012-08-22 09:51:22.975527437 +0800
+++ linux/arch/mips/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -171,6 +171,7 @@ good_area:
 		}
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would
Index: linux/arch/openrisc/mm/fault.c
===================================================================
--- linux.orig/arch/openrisc/mm/fault.c	2012-08-22 09:51:23.027526783 +0800
+++ linux/arch/openrisc/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -183,6 +183,7 @@ good_area:
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
Index: linux/arch/powerpc/mm/fault.c
===================================================================
--- linux.orig/arch/powerpc/mm/fault.c	2012-08-22 09:51:22.987527285 +0800
+++ linux/arch/powerpc/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -450,6 +450,7 @@ good_area:
 			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
 			 * of starvation. */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
 	}
Index: linux/arch/s390/mm/fault.c
===================================================================
--- linux.orig/arch/s390/mm/fault.c	2012-08-22 09:51:23.067526279 +0800
+++ linux/arch/s390/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -367,6 +367,7 @@ retry:
 			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
 			 * of starvation. */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 			down_read(&mm->mmap_sem);
 			goto retry;
 		}
Index: linux/arch/sh/mm/fault.c
===================================================================
--- linux.orig/arch/sh/mm/fault.c	2012-08-22 09:51:22.907528291 +0800
+++ linux/arch/sh/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
@@ -504,6 +504,7 @@ good_area:
 		}
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would
Index: linux/arch/sparc/mm/fault_32.c
===================================================================
--- linux.orig/arch/sparc/mm/fault_32.c	2012-08-22 09:51:22.955527687 +0800
+++ linux/arch/sparc/mm/fault_32.c	2012-08-22 09:52:22.826775037 +0800
@@ -265,6 +265,7 @@ good_area:
 		}
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			/* No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
Index: linux/arch/sparc/mm/fault_64.c
===================================================================
--- linux.orig/arch/sparc/mm/fault_64.c	2012-08-22 09:51:22.947527787 +0800
+++ linux/arch/sparc/mm/fault_64.c	2012-08-22 09:52:22.826775037 +0800
@@ -452,6 +452,7 @@ good_area:
 		}
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			/* No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
Index: linux/arch/tile/mm/fault.c
===================================================================
--- linux.orig/arch/tile/mm/fault.c	2012-08-22 09:51:23.007527033 +0800
+++ linux/arch/tile/mm/fault.c	2012-08-22 09:52:22.826775037 +0800
@@ -454,6 +454,7 @@ good_area:
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			 /*
 			  * No need to up_read(&mm->mmap_sem) as we would
Index: linux/arch/um/kernel/trap.c
===================================================================
--- linux.orig/arch/um/kernel/trap.c	2012-08-22 09:51:23.047526530 +0800
+++ linux/arch/um/kernel/trap.c	2012-08-22 09:52:22.826775037 +0800
@@ -89,6 +89,7 @@ good_area:
 				current->min_flt++;
 			if (fault & VM_FAULT_RETRY) {
 				flags &= ~FAULT_FLAG_ALLOW_RETRY;
+				flags |= FAULT_FLAG_TRIED;
 
 				goto retry;
 			}
Index: linux/arch/xtensa/mm/fault.c
===================================================================
--- linux.orig/arch/xtensa/mm/fault.c	2012-08-22 09:51:22.927528040 +0800
+++ linux/arch/xtensa/mm/fault.c	2012-08-22 09:52:22.826775037 +0800
@@ -126,6 +126,7 @@ good_area:
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
