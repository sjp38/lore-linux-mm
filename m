Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 994D06B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 10:59:42 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BEFAE.1080800@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-24-git-send-email-kirill.shutemov@linux.intel.com>
 <519BEFAE.1080800@sr71.net>
Subject: Re: [PATCHv4 23/39] thp: wait_split_huge_page(): serialize over
 i_mmap_mutex too
Content-Transfer-Encoding: 7bit
Message-Id: <20130603150214.54C34E0090@blue.fi.intel.com>
Date: Mon,  3 Jun 2013 18:02:14 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > Since we're going to have huge pages backed by files,
> > wait_split_huge_page() has to serialize not only over anon_vma_lock,
> > but over i_mmap_mutex too.
> ...
> > -#define wait_split_huge_page(__anon_vma, __pmd)				\
> > +#define wait_split_huge_page(__vma, __pmd)				\
> >  	do {								\
> >  		pmd_t *____pmd = (__pmd);				\
> > -		anon_vma_lock_write(__anon_vma);			\
> > -		anon_vma_unlock_write(__anon_vma);			\
> > +		struct address_space *__mapping =			\
> > +					vma->vm_file->f_mapping;	\
> > +		struct anon_vma *__anon_vma = (__vma)->anon_vma;	\
> > +		if (__mapping)						\
> > +			mutex_lock(&__mapping->i_mmap_mutex);		\
> > +		if (__anon_vma) {					\
> > +			anon_vma_lock_write(__anon_vma);		\
> > +			anon_vma_unlock_write(__anon_vma);		\
> > +		}							\
> > +		if (__mapping)						\
> > +			mutex_unlock(&__mapping->i_mmap_mutex);		\
> >  		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
> >  		       pmd_trans_huge(*____pmd));			\
> >  	} while (0)
> 
> Kirill, I asked about this patch in the previous series, and you wrote
> some very nice, detailed answers to my stupid questions.  But, you
> didn't add any comments or update the patch description.  So, if a
> reviewer or anybody looking at the changelog in the future has my same
> stupid questions, they're unlikely to find the very nice description
> that you wrote up.
> 
> I'd highly suggest that you go back through the comments you've received
> before and make sure that you both answered the questions, *and* made
> sure to cover those questions either in the code or in the patch
> descriptions.

Will do.

> Could you also describe the lengths to which you've gone to try and keep
> this macro from growing in to any larger of an abomination.  Is it truly
> _impossible_ to turn this in to a normal function?  Or will it simply be
> a larger amount of work that you can do right now?  What would it take?

Okay, I've tried once again. The patch is below. It looks too invasive for
me. What do you think?

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 19c8c14..7ed4412 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_HUGE_MM_H
 #define _LINUX_HUGE_MM_H
 
+#include <linux/fs.h>
+
 extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 				      struct vm_area_struct *vma,
 				      unsigned long address, pmd_t *pmd,
@@ -114,23 +116,22 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 			__split_huge_page_pmd(__vma, __address,		\
 					____pmd);			\
 	}  while (0)
-#define wait_split_huge_page(__vma, __pmd)				\
-	do {								\
-		pmd_t *____pmd = (__pmd);				\
-		struct address_space *__mapping =			\
-					vma->vm_file->f_mapping;	\
-		struct anon_vma *__anon_vma = (__vma)->anon_vma;	\
-		if (__mapping)						\
-			mutex_lock(&__mapping->i_mmap_mutex);		\
-		if (__anon_vma) {					\
-			anon_vma_lock_write(__anon_vma);		\
-			anon_vma_unlock_write(__anon_vma);		\
-		}							\
-		if (__mapping)						\
-			mutex_unlock(&__mapping->i_mmap_mutex);		\
-		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
-		       pmd_trans_huge(*____pmd));			\
-	} while (0)
+static inline void wait_split_huge_page(struct vm_area_struct *vma,
+		pmd_t *pmd)
+{
+	struct address_space *mapping = vma->vm_file->f_mapping;
+
+	if (mapping)
+		mutex_lock(&mapping->i_mmap_mutex);
+	if (vma->anon_vma) {
+		anon_vma_lock_write(vma->anon_vma);
+		anon_vma_unlock_write(vma->anon_vma);
+	}
+	if (mapping)
+		mutex_unlock(&mapping->i_mmap_mutex);
+	BUG_ON(pmd_trans_splitting(*pmd));
+	BUG_ON(pmd_trans_huge(*pmd));
+}
 extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd);
 #if HPAGE_PMD_ORDER > MAX_ORDER
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0a60f28..9fc126e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -19,7 +19,6 @@
 #include <linux/shrinker.h>
 
 struct mempolicy;
-struct anon_vma;
 struct anon_vma_chain;
 struct file_ra_state;
 struct user_struct;
@@ -260,7 +259,6 @@ static inline int get_freepage_migratetype(struct page *page)
  * files which need it (119 of them)
  */
 #include <linux/page-flags.h>
-#include <linux/huge_mm.h>
 
 /*
  * Methods to modify the page usage count.
@@ -1475,6 +1473,28 @@ void anon_vma_interval_tree_verify(struct anon_vma_chain *node);
 	for (avc = anon_vma_interval_tree_iter_first(root, start, last); \
 	     avc; avc = anon_vma_interval_tree_iter_next(avc, start, last))
 
+static inline void anon_vma_lock_write(struct anon_vma *anon_vma)
+{
+	down_write(&anon_vma->root->rwsem);
+}
+
+static inline void anon_vma_unlock_write(struct anon_vma *anon_vma)
+{
+	up_write(&anon_vma->root->rwsem);
+}
+
+static inline void anon_vma_lock_read(struct anon_vma *anon_vma)
+{
+	down_read(&anon_vma->root->rwsem);
+}
+
+static inline void anon_vma_unlock_read(struct anon_vma *anon_vma)
+{
+	up_read(&anon_vma->root->rwsem);
+}
+
+#include <linux/huge_mm.h>
+
 /* mmap.c */
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
 extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fb425aa..9805e55 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -453,4 +453,41 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 	return mm->cpu_vm_mask_var;
 }
 
+/*
+ * The anon_vma heads a list of private "related" vmas, to scan if
+ * an anonymous page pointing to this anon_vma needs to be unmapped:
+ * the vmas on the list will be related by forking, or by splitting.
+ *
+ * Since vmas come and go as they are split and merged (particularly
+ * in mprotect), the mapping field of an anonymous page cannot point
+ * directly to a vma: instead it points to an anon_vma, on whose list
+ * the related vmas can be easily linked or unlinked.
+ *
+ * After unlinking the last vma on the list, we must garbage collect
+ * the anon_vma object itself: we're guaranteed no page can be
+ * pointing to this anon_vma once its vma list is empty.
+ */
+struct anon_vma {
+	struct anon_vma *root;		/* Root of this anon_vma tree */
+	struct rw_semaphore rwsem;	/* W: modification, R: walking the list */
+	/*
+	 * The refcount is taken on an anon_vma when there is no
+	 * guarantee that the vma of page tables will exist for
+	 * the duration of the operation. A caller that takes
+	 * the reference is responsible for clearing up the
+	 * anon_vma if they are the last user on release
+	 */
+	atomic_t refcount;
+
+	/*
+	 * NOTE: the LSB of the rb_root.rb_node is set by
+	 * mm_take_all_locks() _after_ taking the above lock. So the
+	 * rb_root must only be read/written after taking the above lock
+	 * to be sure to see a valid next pointer. The LSB bit itself
+	 * is serialized by a system wide lock only visible to
+	 * mm_take_all_locks() (mm_all_locks_mutex).
+	 */
+	struct rb_root rb_root;	/* Interval tree of private "related" vmas */
+};
+
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 6dacb93..22c7278 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -11,43 +11,6 @@
 #include <linux/memcontrol.h>
 
 /*
- * The anon_vma heads a list of private "related" vmas, to scan if
- * an anonymous page pointing to this anon_vma needs to be unmapped:
- * the vmas on the list will be related by forking, or by splitting.
- *
- * Since vmas come and go as they are split and merged (particularly
- * in mprotect), the mapping field of an anonymous page cannot point
- * directly to a vma: instead it points to an anon_vma, on whose list
- * the related vmas can be easily linked or unlinked.
- *
- * After unlinking the last vma on the list, we must garbage collect
- * the anon_vma object itself: we're guaranteed no page can be
- * pointing to this anon_vma once its vma list is empty.
- */
-struct anon_vma {
-	struct anon_vma *root;		/* Root of this anon_vma tree */
-	struct rw_semaphore rwsem;	/* W: modification, R: walking the list */
-	/*
-	 * The refcount is taken on an anon_vma when there is no
-	 * guarantee that the vma of page tables will exist for
-	 * the duration of the operation. A caller that takes
-	 * the reference is responsible for clearing up the
-	 * anon_vma if they are the last user on release
-	 */
-	atomic_t refcount;
-
-	/*
-	 * NOTE: the LSB of the rb_root.rb_node is set by
-	 * mm_take_all_locks() _after_ taking the above lock. So the
-	 * rb_root must only be read/written after taking the above lock
-	 * to be sure to see a valid next pointer. The LSB bit itself
-	 * is serialized by a system wide lock only visible to
-	 * mm_take_all_locks() (mm_all_locks_mutex).
-	 */
-	struct rb_root rb_root;	/* Interval tree of private "related" vmas */
-};
-
-/*
  * The copy-on-write semantics of fork mean that an anon_vma
  * can become associated with multiple processes. Furthermore,
  * each child process will have its own anon_vma, where new
@@ -118,27 +81,6 @@ static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
 		up_write(&anon_vma->root->rwsem);
 }
 
-static inline void anon_vma_lock_write(struct anon_vma *anon_vma)
-{
-	down_write(&anon_vma->root->rwsem);
-}
-
-static inline void anon_vma_unlock_write(struct anon_vma *anon_vma)
-{
-	up_write(&anon_vma->root->rwsem);
-}
-
-static inline void anon_vma_lock_read(struct anon_vma *anon_vma)
-{
-	down_read(&anon_vma->root->rwsem);
-}
-
-static inline void anon_vma_unlock_read(struct anon_vma *anon_vma)
-{
-	up_read(&anon_vma->root->rwsem);
-}
-
-
 /*
  * anon_vma helper functions.
  */
diff --git a/mm/memory.c b/mm/memory.c
index c845cf2..2f4fb39 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -589,7 +589,7 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 		pmd_t *pmd, unsigned long address)
 {
 	pgtable_t new = pte_alloc_one(mm, address);
-	int wait_split_huge_page;
+	int wait_split;
 	if (!new)
 		return -ENOMEM;
 
@@ -609,17 +609,17 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
 
 	spin_lock(&mm->page_table_lock);
-	wait_split_huge_page = 0;
+	wait_split = 0;
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		mm->nr_ptes++;
 		pmd_populate(mm, pmd, new);
 		new = NULL;
 	} else if (unlikely(pmd_trans_splitting(*pmd)))
-		wait_split_huge_page = 1;
+		wait_split = 1;
 	spin_unlock(&mm->page_table_lock);
 	if (new)
 		pte_free(mm, new);
-	if (wait_split_huge_page)
+	if (wait_split)
 		wait_split_huge_page(vma, pmd);
 	return 0;
 }
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
