Date: Wed, 15 Aug 2001 23:26:49 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH] mmap tail merging
In-Reply-To: <Pine.LNX.4.33L.0108152004380.5646-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.33.0108152326001.20014-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Rik van Riel wrote:

> On Wed, 15 Aug 2001, Ben LaHaise wrote:
>
> > Here's a patch to mmap.c that performs tail merging on mmap.
>
> This patch sure is compact ;)

Right.  Let's try this instead:

		-ben

diff -ur /md0/kernels/2.4/v2.4.8-ac5/mm/mmap.c work-v2.4.8-ac5/mm/mmap.c
--- /md0/kernels/2.4/v2.4.8-ac5/mm/mmap.c	Wed Aug 15 12:57:40 2001
+++ work-v2.4.8-ac5/mm/mmap.c	Wed Aug 15 18:24:58 2001
@@ -17,6 +17,10 @@
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>

+#define vm_avl_empty	(struct vm_area_struct *) NULL
+
+#include "mmap_avl.c"
+
 /* description of effects of mapping type and prot in current implementation.
  * this is due to the limited x86 page protection hardware.  The expected
  * behavior is in parens:
@@ -307,7 +311,7 @@

 	/* Can we just expand an old anonymous mapping? */
 	if (addr && !file && !(vm_flags & VM_SHARED)) {
-		struct vm_area_struct * vma = find_vma(mm, addr-1);
+		vma = find_vma(mm, addr-1);
 		if (vma && vma->vm_end == addr && !vma->vm_file &&
 		    vma->vm_flags == vm_flags) {
 			vma->vm_end = addr + len;
@@ -363,12 +367,30 @@
 	if (correct_wcount)
 		atomic_inc(&file->f_dentry->d_inode->i_writecount);

-out:
+out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
 		make_pages_present(addr, addr + len);
 	}
+
+	/* Can we merge this anonymous mapping with the one following it? */
+	if (!file && !(vm_flags & VM_SHARED)) {
+		struct vm_area_struct *next = vma->vm_next;
+		if (next && vma->vm_end == next->vm_start && !next->vm_file &&
+		    vma->vm_flags == next->vm_flags) {
+			spin_lock(&mm->page_table_lock);
+			vma->vm_next = next->vm_next;
+			if (mm->mmap_avl)
+				avl_remove(next, &mm->mmap_avl);
+			vma->vm_end = next->vm_end;
+			mm->mmap_cache = vma;	/* Kill the cache. */
+			spin_unlock(&mm->page_table_lock);
+
+			kmem_cache_free(vm_area_cachep, next);
+		}
+	}
+
 	return addr;

 unmap_and_free_vma:
@@ -443,10 +465,6 @@
 	return arch_get_unmapped_area(file, addr, len, pgoff, flags);
 }

-#define vm_avl_empty	(struct vm_area_struct *) NULL
-
-#include "mmap_avl.c"
-
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
 struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
