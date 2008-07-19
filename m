Date: Sat, 19 Jul 2008 16:47:03 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][splitlru][PATCH 1/3] introduce __get_user_pages()
In-Reply-To: <20080719084303.386876790@jp.fujitsu.com>
References: <20080719084213.588795788@jp.fujitsu.com> <20080719084303.386876790@jp.fujitsu.com>
Message-Id: <20080719164434.F6B3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> new munlock processing need to GUP_FLAGS_IGNORE_VMA_PERMISSIONS.
> because current get_user_pages() can't grab PROT_NONE pages theresore
> it cause PROT_NONE pages can't munlock.
> 
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Li Zefan <lizf@cn.fujitsu.com>
> CC: Hugh Dickins <hugh@veritas.com>
> CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> CC: Rik van Riel <riel@redhat.com>


sorry, I forgot to change nommu.c
below patch is new version.

Unfortunately, I don't have nommu machine.
Then I beat up nommu tester...



---
 mm/internal.h |    8 ++++++++
 mm/memory.c   |   37 +++++++++++++++++++++++++++++++------
 mm/nommu.c    |   42 +++++++++++++++++++++++++++++++-----------
 3 files changed, 70 insertions(+), 17 deletions(-)

Index: b/mm/memory.c
===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1108,12 +1108,17 @@ static inline int use_zero_page(struct v
 	return !vma->vm_ops || !vma->vm_ops->fault;
 }
 
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, int len, int write, int force,
+
+
+int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		     unsigned long start, int len, int flags,
 		struct page **pages, struct vm_area_struct **vmas)
 {
 	int i;
-	unsigned int vm_flags;
+	unsigned int vm_flags = 0;
+	int write = !!(flags & GUP_FLAGS_WRITE);
+	int force = !!(flags & GUP_FLAGS_FORCE);
+	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
 
 	if (len <= 0)
 		return 0;
@@ -1137,7 +1142,9 @@ int get_user_pages(struct task_struct *t
 			pud_t *pud;
 			pmd_t *pmd;
 			pte_t *pte;
-			if (write) /* user gate pages are read-only */
+
+			/* user gate pages are read-only */
+			if (!ignore && write)
 				return i ? : -EFAULT;
 			if (pg > TASK_SIZE)
 				pgd = pgd_offset_k(pg);
@@ -1169,8 +1176,9 @@ int get_user_pages(struct task_struct *t
 			continue;
 		}
 
-		if (!vma || (vma->vm_flags & (VM_IO | VM_PFNMAP))
-				|| !(vm_flags & vma->vm_flags))
+		if (!vma ||
+		    (vma->vm_flags & (VM_IO | VM_PFNMAP)) ||
+		    (!ignore && !(vm_flags & vma->vm_flags)))
 			return i ? : -EFAULT;
 
 		if (is_vm_hugetlb_page(vma)) {
@@ -1245,6 +1253,23 @@ int get_user_pages(struct task_struct *t
 	} while (len);
 	return i;
 }
+
+int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, int len, int write, int force,
+		struct page **pages, struct vm_area_struct **vmas)
+{
+	int flags = 0;
+
+	if (write)
+		flags |= GUP_FLAGS_WRITE;
+	if (force)
+		flags |= GUP_FLAGS_FORCE;
+
+	return __get_user_pages(tsk, mm,
+				start, len, flags,
+				pages, vmas);
+}
+
 EXPORT_SYMBOL(get_user_pages);
 
 pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -243,4 +243,12 @@ static inline void mminit_validate_memmo
 }
 #endif /* CONFIG_SPARSEMEM */
 
+#define GUP_FLAGS_WRITE                  0x1
+#define GUP_FLAGS_FORCE                  0x2
+#define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
+
+int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		     unsigned long start, int len, int flags,
+		     struct page **pages, struct vm_area_struct **vmas);
+
 #endif
Index: b/mm/nommu.c
===================================================================
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -128,20 +128,16 @@ unsigned int kobjsize(const void *objp)
 	return PAGE_SIZE << compound_order(page);
 }
 
-/*
- * get a list of pages in an address range belonging to the specified process
- * and indicate the VMA that covers each page
- * - this is potentially dodgy as we may end incrementing the page count of a
- *   slab page or a secondary page from a compound page
- * - don't permit access to VMAs that don't support it, such as I/O mappings
- */
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-	unsigned long start, int len, int write, int force,
-	struct page **pages, struct vm_area_struct **vmas)
+int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		     unsigned long start, int len, int flags,
+		struct page **pages, struct vm_area_struct **vmas)
 {
 	struct vm_area_struct *vma;
 	unsigned long vm_flags;
 	int i;
+	int write = !!(flags & GUP_FLAGS_WRITE);
+	int force = !!(flags & GUP_FLAGS_FORCE);
+	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
 
 	/* calculate required read or write permissions.
 	 * - if 'force' is set, we only require the "MAY" flags.
@@ -156,7 +152,7 @@ int get_user_pages(struct task_struct *t
 
 		/* protect what we can, including chardevs */
 		if (vma->vm_flags & (VM_IO | VM_PFNMAP) ||
-		    !(vm_flags & vma->vm_flags))
+		    (!ignore && !(vm_flags & vma->vm_flags)))
 			goto finish_or_fault;
 
 		if (pages) {
@@ -174,6 +170,30 @@ int get_user_pages(struct task_struct *t
 finish_or_fault:
 	return i ? : -EFAULT;
 }
+
+
+/*
+ * get a list of pages in an address range belonging to the specified process
+ * and indicate the VMA that covers each page
+ * - this is potentially dodgy as we may end incrementing the page count of a
+ *   slab page or a secondary page from a compound page
+ * - don't permit access to VMAs that don't support it, such as I/O mappings
+ */
+int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+	unsigned long start, int len, int write, int force,
+	struct page **pages, struct vm_area_struct **vmas)
+{
+	int flags = 0;
+
+	if (write)
+		flags |= GUP_FLAGS_WRITE;
+	if (force)
+		flags |= GUP_FLAGS_FORCE;
+
+	return __get_user_pages(tsk, mm,
+				start, len, flags,
+				pages, vmas);
+}
 EXPORT_SYMBOL(get_user_pages);
 
 DEFINE_RWLOCK(vmlist_lock);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
