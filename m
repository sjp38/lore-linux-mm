Message-Id: <200405222216.i4MMGrr14911@mail.osdl.org>
Subject: [patch 56/57] rmap 40 better anon_vma sharing
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:16:12 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

anon_vma rmap will always necessarily be more restrictive about vma merging
than before: according to the history of the vmas in an mm, they are liable to
be allocated different anon_vma heads, and from that point on be unmergeable.

Most of the time this doesn't matter at all; but in two cases it may matter. 
One case is that mremap refuses (-EFAULT) to span more than a single vma: so
it is conceivable that some app has relied on vma merging prior to mremap in
the past, and will now fail with anon_vma.  Conceivable but unlikely, let's
cross that bridge if we come to it: and the right answer would be to extend
mremap, which should not be exporting the kernel's implementation detail of
vma to user interface.

The other case that matters is when a reasonable repetitive sequence of
syscalls and faults ends up with a large number of separate unmergeable vmas,
instead of the single merged vma it could have.

Andrea's mprotect-vma-merging patch fixed some such instances, but left other
plausible cases unmerged.  There is no perfect solution, and the harder you
try to allow vmas to be merged, the less efficient anon_vma becomes, in the
extreme there being one to span the whole address space, from which hangs
every private vma; but anonmm rmap is clearly superior to that extreme.

Andrea's principle was that neighbouring vmas which could be mprotected into
mergeable vmas should be allowed to share anon_vma: good insight.  His
implementation was to arrange this sharing when trying vma merge, but that
seems to be too early.  This patch sticks to the principle, but implements it
in anon_vma_prepare, when handling the first write fault on a private vma:
with better results.  The drawback is that this first write fault needs an
extra find_vma_prev (whereas prev was already to hand when implementing
anon_vma sharing at try-to-merge time).


---

 25-akpm/include/linux/mm.h |    1 
 25-akpm/mm/mmap.c          |   65 +++++++++++++++++++++++++++++++++++++++++++++
 25-akpm/mm/rmap.c          |   17 +++++++----
 3 files changed, 77 insertions(+), 6 deletions(-)

diff -puN include/linux/mm.h~rmap-40-better-anon_vma-sharing include/linux/mm.h
--- 25/include/linux/mm.h~rmap-40-better-anon_vma-sharing	2004-05-22 14:56:30.482457488 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:56:30.489456424 -0700
@@ -627,6 +627,7 @@ extern struct vm_area_struct *vma_merge(
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
 	struct mempolicy *);
+extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int split_vma(struct mm_struct *,
 	struct vm_area_struct *, unsigned long addr, int new_below);
 extern void insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
diff -puN mm/mmap.c~rmap-40-better-anon_vma-sharing mm/mmap.c
--- 25/mm/mmap.c~rmap-40-better-anon_vma-sharing	2004-05-22 14:56:30.484457184 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:56:30.491456120 -0700
@@ -642,6 +642,71 @@ struct vm_area_struct *vma_merge(struct 
 }
 
 /*
+ * find_mergeable_anon_vma is used by anon_vma_prepare, to check
+ * neighbouring vmas for a suitable anon_vma, before it goes off
+ * to allocate a new anon_vma.  It checks because a repetitive
+ * sequence of mprotects and faults may otherwise lead to distinct
+ * anon_vmas being allocated, preventing vma merge in subsequent
+ * mprotect.
+ */
+struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *vma)
+{
+	struct vm_area_struct *near;
+	unsigned long vm_flags;
+
+	near = vma->vm_next;
+	if (!near)
+		goto try_prev;
+
+	/*
+	 * Since only mprotect tries to remerge vmas, match flags
+	 * which might be mprotected into each other later on.
+	 * Neither mlock nor madvise tries to remerge at present,
+	 * so leave their flags as obstructing a merge.
+	 */
+	vm_flags = vma->vm_flags & ~(VM_READ|VM_WRITE|VM_EXEC);
+	vm_flags |= near->vm_flags & (VM_READ|VM_WRITE|VM_EXEC);
+
+	if (near->anon_vma && vma->vm_end == near->vm_start &&
+ 			mpol_equal(vma_policy(vma), vma_policy(near)) &&
+			can_vma_merge_before(near, vm_flags,
+				NULL, vma->vm_file, vma->vm_pgoff +
+				((vma->vm_end - vma->vm_start) >> PAGE_SHIFT)))
+		return near->anon_vma;
+try_prev:
+	/*
+	 * It is potentially slow to have to call find_vma_prev here.
+	 * But it's only on the first write fault on the vma, not
+	 * every time, and we could devise a way to avoid it later
+	 * (e.g. stash info in next's anon_vma_node when assigning
+	 * an anon_vma, or when trying vma_merge).  Another time.
+	 */
+	if (find_vma_prev(vma->vm_mm, vma->vm_start, &near) != vma)
+		BUG();
+	if (!near)
+		goto none;
+
+	vm_flags = vma->vm_flags & ~(VM_READ|VM_WRITE|VM_EXEC);
+	vm_flags |= near->vm_flags & (VM_READ|VM_WRITE|VM_EXEC);
+
+	if (near->anon_vma && near->vm_end == vma->vm_start &&
+  			mpol_equal(vma_policy(near), vma_policy(vma)) &&
+			can_vma_merge_after(near, vm_flags,
+				NULL, vma->vm_file, vma->vm_pgoff))
+		return near->anon_vma;
+none:
+	/*
+	 * There's no absolute need to look only at touching neighbours:
+	 * we could search further afield for "compatible" anon_vmas.
+	 * But it would probably just be a waste of time searching,
+	 * or lead to too many vmas hanging off the same anon_vma.
+	 * We're trying to allow mprotect remerging later on,
+	 * not trying to minimize memory used for anon_vmas.
+	 */
+	return NULL;
+}
+
+/*
  * The caller must hold down_write(current->mm->mmap_sem).
  */
 
diff -puN mm/rmap.c~rmap-40-better-anon_vma-sharing mm/rmap.c
--- 25/mm/rmap.c~rmap-40-better-anon_vma-sharing	2004-05-22 14:56:30.485457032 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:56:30.492455968 -0700
@@ -66,21 +66,26 @@ int anon_vma_prepare(struct vm_area_stru
 	might_sleep();
 	if (unlikely(!anon_vma)) {
 		struct mm_struct *mm = vma->vm_mm;
+		struct anon_vma *allocated = NULL;
 
-		anon_vma = anon_vma_alloc();
-		if (unlikely(!anon_vma))
-			return -ENOMEM;
+		anon_vma = find_mergeable_anon_vma(vma);
+		if (!anon_vma) {
+			anon_vma = anon_vma_alloc();
+			if (unlikely(!anon_vma))
+				return -ENOMEM;
+			allocated = anon_vma;
+		}
 
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
 			list_add(&vma->anon_vma_node, &anon_vma->head);
-			anon_vma = NULL;
+			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
-		if (unlikely(anon_vma))
-			anon_vma_free(anon_vma);
+		if (unlikely(allocated))
+			anon_vma_free(allocated);
 	}
 	return 0;
 }

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
