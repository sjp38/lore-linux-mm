Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BBE116B003D
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:21:29 -0400 (EDT)
Date: Fri, 20 Mar 2009 10:34:38 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: PATCH: Introduce struct vma_link_info
Message-ID: <20090320103438.08e67358@doriath.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: riel@redhat.com, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


 Andrew,

  Currently find_vma_prepare() and low-level VMA functions (eg. __vma_link())
require callers to provide three parameters to return/pass "link" information
(pprev, rb_link and rb_parent):

static struct vm_area_struct *
find_vma_prepare(struct mm_struct *mm, unsigned long addr,
                struct vm_area_struct **pprev, struct rb_node ***rb_link,
                struct rb_node ** rb_parent);

 With this patch callers can pass a struct vma_link_info instead:

static struct vm_area_struct *
find_vma_prepare(struct mm_struct *mm, unsigned long addr,
                struct vma_link_info *link_info);

 The code gets simpler and it should be better because less variables
are pushed into the stack/registers. As shown by the following
kernel build test:

kernel			real	user	sys

2.6.29-rc8-vanilla      1136.64 1033.38 82.88
2.6.29-rc8-linfo        1135.07 1032.44 82.92

 I have also ran hackbench, but I can't understand why its result
indicates a regression:

kernel                 Avarage of three runs (25 processes groups)

2.6.29.rc8-vanilla                2.03
2.6.29.rc8-linfo                  2.12

 Rik has said to me that this could be inside error margin. So, I'm
submitting the patch for inclusion.

Signed-off-by: Luiz Fernando N. Capitulino <lcapitulino@mandriva.com.br>

---
 include/linux/mm.h |    8 ++++-
 kernel/fork.c      |   12 +++---
 mm/mmap.c          |   91 +++++++++++++++++++++++++--------------------------
 3 files changed, 58 insertions(+), 53 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065cdf8..be73b86 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1097,6 +1097,12 @@ static inline void vma_nonlinear_insert(struct vm_area_struct *vma,
 }
 
 /* mmap.c */
+struct vma_link_info {
+	struct rb_node *rb_parent;
+	struct rb_node **rb_link;
+	struct vm_area_struct *prev;
+};
+
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
 extern void vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
@@ -1109,7 +1115,7 @@ extern int split_vma(struct mm_struct *,
 	struct vm_area_struct *, unsigned long addr, int new_below);
 extern int insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
-	struct rb_node **, struct rb_node *);
+		struct vma_link_info *link_info);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
diff --git a/kernel/fork.c b/kernel/fork.c
index 4854c2c..a300bf6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -261,7 +261,7 @@ out:
 static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
 	struct vm_area_struct *mpnt, *tmp, **pprev;
-	struct rb_node **rb_link, *rb_parent;
+	struct vma_link_info link_info;
 	int retval;
 	unsigned long charge;
 	struct mempolicy *pol;
@@ -281,8 +281,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	mm->map_count = 0;
 	cpus_clear(mm->cpu_vm_mask);
 	mm->mm_rb = RB_ROOT;
-	rb_link = &mm->mm_rb.rb_node;
-	rb_parent = NULL;
+	link_info.rb_link = &mm->mm_rb.rb_node;
+	link_info.rb_parent = NULL;
 	pprev = &mm->mmap;
 
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
@@ -348,9 +348,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		*pprev = tmp;
 		pprev = &tmp->vm_next;
 
-		__vma_link_rb(mm, tmp, rb_link, rb_parent);
-		rb_link = &tmp->vm_rb.rb_right;
-		rb_parent = &tmp->vm_rb;
+		__vma_link_rb(mm, tmp, &link_info);
+		link_info.rb_link = &tmp->vm_rb.rb_right;
+		link_info.rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
 		retval = copy_page_range(mm, oldmm, mpnt);
diff --git a/mm/mmap.c b/mm/mmap.c
index 00ced3e..db0852d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -352,8 +352,7 @@ void validate_mm(struct mm_struct *mm)
 
 static struct vm_area_struct *
 find_vma_prepare(struct mm_struct *mm, unsigned long addr,
-		struct vm_area_struct **pprev, struct rb_node ***rb_link,
-		struct rb_node ** rb_parent)
+		struct vma_link_info *link_info)
 {
 	struct vm_area_struct * vma;
 	struct rb_node ** __rb_link, * __rb_parent, * rb_prev;
@@ -379,25 +378,25 @@ find_vma_prepare(struct mm_struct *mm, unsigned long addr,
 		}
 	}
 
-	*pprev = NULL;
+	link_info->prev = NULL;
 	if (rb_prev)
-		*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
-	*rb_link = __rb_link;
-	*rb_parent = __rb_parent;
+		link_info->prev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
+	link_info->rb_link = __rb_link;
+	link_info->rb_parent = __rb_parent;
 	return vma;
 }
 
 static inline void
 __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
-		struct vm_area_struct *prev, struct rb_node *rb_parent)
+		struct vma_link_info *link_info)
 {
-	if (prev) {
-		vma->vm_next = prev->vm_next;
-		prev->vm_next = vma;
+	if (link_info->prev) {
+		vma->vm_next = link_info->prev->vm_next;
+		link_info->prev->vm_next = vma;
 	} else {
 		mm->mmap = vma;
-		if (rb_parent)
-			vma->vm_next = rb_entry(rb_parent,
+		if (link_info->rb_parent)
+			vma->vm_next = rb_entry(link_info->rb_parent,
 					struct vm_area_struct, vm_rb);
 		else
 			vma->vm_next = NULL;
@@ -405,9 +404,9 @@ __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
-		struct rb_node **rb_link, struct rb_node *rb_parent)
+		struct vma_link_info *link_info)
 {
-	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
+	rb_link_node(&vma->vm_rb, link_info->rb_parent, link_info->rb_link);
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
 }
 
@@ -435,17 +434,15 @@ static void __vma_link_file(struct vm_area_struct *vma)
 
 static void
 __vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
-	struct vm_area_struct *prev, struct rb_node **rb_link,
-	struct rb_node *rb_parent)
+	struct vma_link_info *link_info)
 {
-	__vma_link_list(mm, vma, prev, rb_parent);
-	__vma_link_rb(mm, vma, rb_link, rb_parent);
+	__vma_link_list(mm, vma, link_info);
+	__vma_link_rb(mm, vma, link_info);
 	__anon_vma_link(vma);
 }
 
 static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
-			struct vm_area_struct *prev, struct rb_node **rb_link,
-			struct rb_node *rb_parent)
+		struct vma_link_info *link_info)
 {
 	struct address_space *mapping = NULL;
 
@@ -458,7 +455,7 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 	anon_vma_lock(vma);
 
-	__vma_link(mm, vma, prev, rb_link, rb_parent);
+	__vma_link(mm, vma, link_info);
 	__vma_link_file(vma);
 
 	anon_vma_unlock(vma);
@@ -476,12 +473,12 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
  */
 static void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	struct vm_area_struct *__vma, *prev;
-	struct rb_node **rb_link, *rb_parent;
+	struct vm_area_struct *__vma;
+	struct vma_link_info link_info;
 
-	__vma = find_vma_prepare(mm, vma->vm_start,&prev, &rb_link, &rb_parent);
+	__vma = find_vma_prepare(mm, vma->vm_start, &link_info);
 	BUG_ON(__vma && __vma->vm_start < vma->vm_end);
-	__vma_link(mm, vma, prev, rb_link, rb_parent);
+	__vma_link(mm, vma, &link_info);
 	mm->map_count++;
 }
 
@@ -1107,17 +1104,17 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 			  unsigned int vm_flags, unsigned long pgoff)
 {
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma, *prev;
+	struct vm_area_struct *vma;
 	int correct_wcount = 0;
 	int error;
-	struct rb_node **rb_link, *rb_parent;
+	struct vma_link_info link_info;
 	unsigned long charged = 0;
 	struct inode *inode =  file ? file->f_path.dentry->d_inode : NULL;
 
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
-	vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	vma = find_vma_prepare(mm, addr, &link_info);
 	if (vma && vma->vm_start < addr + len) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
@@ -1155,7 +1152,8 @@ munmap_back:
 	/*
 	 * Can we just expand an old mapping?
 	 */
-	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff, NULL);
+	vma = vma_merge(mm, link_info.prev, addr, addr + len, vm_flags,
+			NULL, file, pgoff, NULL);
 	if (vma)
 		goto out;
 
@@ -1212,7 +1210,7 @@ munmap_back:
 	if (vma_wants_writenotify(vma))
 		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
 
-	vma_link(mm, vma, prev, rb_link, rb_parent);
+	vma_link(mm, vma, &link_info);
 	file = vma->vm_file;
 
 	/* Once vma denies write, undo our temporary denial count */
@@ -1240,7 +1238,7 @@ unmap_and_free_vma:
 	fput(file);
 
 	/* Undo any partial mapping done by a device driver. */
-	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
+	unmap_region(mm, vma, link_info.prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
@@ -1976,9 +1974,9 @@ static inline void verify_mm_writelocked(struct mm_struct *mm)
 unsigned long do_brk(unsigned long addr, unsigned long len)
 {
 	struct mm_struct * mm = current->mm;
-	struct vm_area_struct * vma, * prev;
+	struct vm_area_struct * vma;
 	unsigned long flags;
-	struct rb_node ** rb_link, * rb_parent;
+	struct vma_link_info link_info;
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
 	int error;
 
@@ -2025,7 +2023,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 	 * Clear old maps.  this also does some error checking for us
 	 */
  munmap_back:
-	vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	vma = find_vma_prepare(mm, addr, &link_info);
 	if (vma && vma->vm_start < addr + len) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
@@ -2043,7 +2041,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 		return -ENOMEM;
 
 	/* Can we just expand an old private anonymous mapping? */
-	vma = vma_merge(mm, prev, addr, addr + len, flags,
+	vma = vma_merge(mm, link_info.prev, addr, addr + len, flags,
 					NULL, NULL, pgoff, NULL);
 	if (vma)
 		goto out;
@@ -2063,7 +2061,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 	vma->vm_pgoff = pgoff;
 	vma->vm_flags = flags;
 	vma->vm_page_prot = vm_get_page_prot(flags);
-	vma_link(mm, vma, prev, rb_link, rb_parent);
+	vma_link(mm, vma, &link_info);
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -2127,8 +2125,8 @@ void exit_mmap(struct mm_struct *mm)
  */
 int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 {
-	struct vm_area_struct * __vma, * prev;
-	struct rb_node ** rb_link, * rb_parent;
+	struct vm_area_struct * __vma;
+	struct vma_link_info link_info;
 
 	/*
 	 * The vm_pgoff of a purely anonymous vma should be irrelevant
@@ -2146,13 +2144,13 @@ int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
 		BUG_ON(vma->anon_vma);
 		vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
 	}
-	__vma = find_vma_prepare(mm,vma->vm_start,&prev,&rb_link,&rb_parent);
+	__vma = find_vma_prepare(mm,vma->vm_start, &link_info);
 	if (__vma && __vma->vm_start < vma->vm_end)
 		return -ENOMEM;
 	if ((vma->vm_flags & VM_ACCOUNT) &&
 	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
 		return -ENOMEM;
-	vma_link(mm, vma, prev, rb_link, rb_parent);
+	vma_link(mm, vma, &link_info);
 	return 0;
 }
 
@@ -2166,8 +2164,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	struct vm_area_struct *vma = *vmap;
 	unsigned long vma_start = vma->vm_start;
 	struct mm_struct *mm = vma->vm_mm;
-	struct vm_area_struct *new_vma, *prev;
-	struct rb_node **rb_link, *rb_parent;
+	struct vm_area_struct *new_vma;
+	struct vma_link_info link_info;
 	struct mempolicy *pol;
 
 	/*
@@ -2177,9 +2175,10 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	if (!vma->vm_file && !vma->anon_vma)
 		pgoff = addr >> PAGE_SHIFT;
 
-	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
-	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+	find_vma_prepare(mm, addr, &link_info);
+	new_vma = vma_merge(mm, link_info.prev, addr, addr + len,
+			vma->vm_flags, vma->anon_vma, vma->vm_file,
+			pgoff, vma_policy(vma));
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
@@ -2207,7 +2206,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			}
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
-			vma_link(mm, new_vma, prev, rb_link, rb_parent);
+			vma_link(mm, new_vma, &link_info);
 		}
 	}
 	return new_vma;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
