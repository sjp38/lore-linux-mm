Message-Id: <200405222214.i4MMEIr14545@mail.osdl.org>
Subject: [patch 50/57] rmap 34 vm_flags page_table_lock
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:13:42 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

First of a batch of seven rmap patches, based on 2.6.6-mm3.  Probably the
final batch: remaining issues outstanding can have isolated patches.  The
first half of the batch is good for anonmm or anon_vma, the second half of the
batch replaces my anonmm rmap by Andrea's anon_vma rmap.

Judge for yourselves which you prefer.  I do think I was wrong to call
anon_vma more complex than anonmm (its lists are easier to understand than my
refcounting), and I'm happy with its vma merging after the last patch.  It
just comes down to whether we can spare the extra 24 bytes (maximum, on
32-bit) per vma for its advantages in swapout and mremap.

rmap 34 vm_flags page_table_lock

Why do we guard vm_flags mods with page_table_lock when it's already
down_write guarded by mmap_sem?  There's probably a historical reason, but no
sign of any need for it now.  Andrea added a comment and removed the instance
from mprotect.c, Hugh plagiarized his comment and removed the instances from
madvise.c and mlock.c.  Huge leap in scalability...  not expected; but this
should stop people asking why those spinlocks.


---

 25-akpm/mm/madvise.c  |    5 +++--
 25-akpm/mm/mlock.c    |    9 ++++++---
 25-akpm/mm/mprotect.c |    6 ++++--
 3 files changed, 13 insertions(+), 7 deletions(-)

diff -puN mm/madvise.c~rmap-34-vm_flags-page_table_lock mm/madvise.c
--- 25/mm/madvise.c~rmap-34-vm_flags-page_table_lock	2004-05-22 14:56:29.382624688 -0700
+++ 25-akpm/mm/madvise.c	2004-05-22 14:56:29.389623624 -0700
@@ -31,7 +31,9 @@ static long madvise_behavior(struct vm_a
 			return -EAGAIN;
 	}
 
-	spin_lock(&mm->page_table_lock);
+	/*
+	 * vm_flags is protected by the mmap_sem held in write mode.
+	 */
 	VM_ClearReadHint(vma);
 
 	switch (behavior) {
@@ -44,7 +46,6 @@ static long madvise_behavior(struct vm_a
 	default:
 		break;
 	}
-	spin_unlock(&mm->page_table_lock);
 
 	return 0;
 }
diff -puN mm/mlock.c~rmap-34-vm_flags-page_table_lock mm/mlock.c
--- 25/mm/mlock.c~rmap-34-vm_flags-page_table_lock	2004-05-22 14:56:29.384624384 -0700
+++ 25-akpm/mm/mlock.c	2004-05-22 14:56:29.389623624 -0700
@@ -32,10 +32,13 @@ static int mlock_fixup(struct vm_area_st
 			goto out;
 		}
 	}
-	
-	spin_lock(&mm->page_table_lock);
+
+	/*
+	 * vm_flags is protected by the mmap_sem held in write mode.
+	 * It's okay if try_to_unmap_one unmaps a page just after we
+	 * set VM_LOCKED, make_pages_present below will bring it back.
+	 */
 	vma->vm_flags = newflags;
-	spin_unlock(&mm->page_table_lock);
 
 	/*
 	 * Keep track of amount of locked VM.
diff -puN mm/mprotect.c~rmap-34-vm_flags-page_table_lock mm/mprotect.c
--- 25/mm/mprotect.c~rmap-34-vm_flags-page_table_lock	2004-05-22 14:56:29.385624232 -0700
+++ 25-akpm/mm/mprotect.c	2004-05-22 14:59:36.127235192 -0700
@@ -213,10 +213,12 @@ mprotect_fixup(struct vm_area_struct *vm
 			goto fail;
 	}
 
-	spin_lock(&mm->page_table_lock);
+	/*
+	 * vm_flags and vm_page_prot are protected by the mmap_sem
+	 * held in write mode.
+	 */
 	vma->vm_flags = newflags;
 	vma->vm_page_prot = newprot;
-	spin_unlock(&mm->page_table_lock);
 success:
 	change_protection(vma, start, end, newprot);
 	return 0;

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
