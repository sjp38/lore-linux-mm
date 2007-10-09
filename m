Date: Mon, 8 Oct 2007 21:29:33 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH v2] remap_file_pages: kernel-doc corrections
Message-Id: <20071008212933.e829966b.randy.dunlap@oracle.com>
In-Reply-To: <200710081844.42501.nickpiggin@yahoo.com.au>
References: <20071008170320.eb123276.randy.dunlap@oracle.com>
	<200710081844.42501.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007 18:44:42 +1000 Nick Piggin wrote:

> > Fix kernel-doc for sys_remap_file_pages() and add info to the __prot NOTE.
> 
> Why not just get rid of the double underscore, I wonder?

ok, did that.

> > -/***
> > - * sys_remap_file_pages - remap arbitrary pages of a shared backing store
> > - *                        file within an existing vma.
> > +/**
> > + * sys_remap_file_pages - remap arbitrary pages of a shared backing store
> 
> I think the "vma" part is kind of important, and probably not emphasised
> enough in the original, and "shared backing store file" is a bit vague. It's
> actually a VM_SHARED _vma_.

I modified that comment based on your comments.
See if it's better now, please.

---

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc for sys_remap_file_pages() and add info to the 'prot' NOTE.
Rename __prot parameter to prot.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/fremap.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

--- linux-2.6.23-rc9-git3.orig/mm/fremap.c
+++ linux-2.6.23-rc9-git3/mm/fremap.c
@@ -97,26 +97,28 @@ static int populate_range(struct mm_stru
 
 }
 
-/***
- * sys_remap_file_pages - remap arbitrary pages of a shared backing store
- *                        file within an existing vma.
+/**
+ * sys_remap_file_pages - remap arbitrary pages of an existing VM_SHARED vma
  * @start: start of the remapped virtual memory range
  * @size: size of the remapped virtual memory range
- * @prot: new protection bits of the range
- * @pgoff: to be mapped page of the backing store file
+ * @prot: new protection bits of the range (see NOTE)
+ * @pgoff: to-be-mapped page of the backing store file
  * @flags: 0 or MAP_NONBLOCKED - the later will cause no IO.
  *
- * this syscall works purely via pagetables, so it's the most efficient
+ * sys_remap_file_pages remaps arbitrary pages of an existing VM_SHARED vma
+ * (shared backing store file).
+ *
+ * This syscall works purely via pagetables, so it's the most efficient
  * way to map the same (large) file into a given virtual window. Unlike
  * mmap()/mremap() it does not create any new vmas. The new mappings are
  * also safe across swapout.
  *
- * NOTE: the 'prot' parameter right now is ignored, and the vma's default
- * protection is used. Arbitrary protections might be implemented in the
- * future.
+ * NOTE: the 'prot' parameter right now is ignored (but must be zero),
+ * and the vma's default protection is used. Arbitrary protections
+ * might be implemented in the future.
  */
 asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
-	unsigned long __prot, unsigned long pgoff, unsigned long flags)
+	unsigned long prot, unsigned long pgoff, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
 	struct address_space *mapping;
@@ -125,7 +127,7 @@ asmlinkage long sys_remap_file_pages(uns
 	int err = -EINVAL;
 	int has_write_lock = 0;
 
-	if (__prot)
+	if (prot)
 		return err;
 	/*
 	 * Sanitize the syscall parameters:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
