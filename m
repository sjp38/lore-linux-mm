Message-Id: <200405222207.i4MM76r12907@mail.osdl.org>
Subject: [patch 21/57] mpol in copy_vma
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:06:33 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

I think Andi missed the copy_vma I recently added for mremap, and it'll
need something like below....  (Doesn't look like it'll optimize away when
it's not needed - rather bloaty.)


---

 25-akpm/mm/mmap.c |    7 +++++++
 1 files changed, 7 insertions(+)

diff -puN mm/mmap.c~mpol-in-copy_vma mm/mmap.c
--- 25/mm/mmap.c~mpol-in-copy_vma	2004-05-22 14:56:24.820318264 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:40.804524136 -0700
@@ -1504,6 +1504,7 @@ struct vm_area_struct *copy_vma(struct v
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma, *prev;
 	struct rb_node **rb_link, *rb_parent;
+	struct mempolicy *pol;
 
 	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
 	new_vma = vma_merge(mm, prev, rb_parent, addr, addr + len,
@@ -1519,6 +1520,12 @@ struct vm_area_struct *copy_vma(struct v
 		new_vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 		if (new_vma) {
 			*new_vma = *vma;
+			pol = mpol_copy(vma_policy(vma));
+			if (IS_ERR(pol)) {
+				kmem_cache_free(vm_area_cachep, new_vma);
+				return NULL;
+			}
+			vma_set_policy(new_vma, pol);
 			INIT_LIST_HEAD(&new_vma->shared);
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
