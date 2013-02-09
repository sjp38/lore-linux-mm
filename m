Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D44026B0007
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 19:04:03 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa10so2392886pad.41
        for <linux-mm@kvack.org>; Fri, 08 Feb 2013 16:04:03 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v3 1/3] mm: use long type for page counts in mm_populate() and get_user_pages()
Date: Fri,  8 Feb 2013 16:03:55 -0800
Message-Id: <1360368237-26768-2-git-send-email-walken@google.com>
In-Reply-To: <1360368237-26768-1-git-send-email-walken@google.com>
References: <1360368237-26768-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Use long type for page counts in mm_populate() so as to avoid integer
overflow when running the following test code:

int main(void) {
  void *p = mmap(NULL, 0x100000000000, PROT_READ,
                 MAP_PRIVATE | MAP_ANON, -1, 0);
  printf("p: %p\n", p);
  mlockall(MCL_CURRENT);
  printf("done\n");
  return 0;
}

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 include/linux/hugetlb.h |  6 +++---
 include/linux/mm.h      | 15 ++++++++-------
 mm/hugetlb.c            | 12 ++++++------
 mm/memory.c             | 18 +++++++++---------
 mm/mlock.c              |  4 ++--
 mm/nommu.c              | 15 ++++++++-------
 6 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 0c80d3f57a5b..eedc334fb6f5 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -43,9 +43,9 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
 #endif
 
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
-int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
-			struct page **, struct vm_area_struct **,
-			unsigned long *, int *, int, unsigned int flags);
+long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
+			 struct page **, struct vm_area_struct **,
+			 unsigned long *, unsigned long *, long, unsigned int);
 void unmap_hugepage_range(struct vm_area_struct *,
 			  unsigned long, unsigned long, struct page *);
 void __unmap_hugepage_range_final(struct mmu_gather *tlb,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a224430578f0..3d9fbcf9fa94 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1040,13 +1040,14 @@ extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *
 extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, int write);
 
-int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long start, int len, unsigned int foll_flags,
-		     struct page **pages, struct vm_area_struct **vmas,
-		     int *nonblocking);
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-			unsigned long start, int nr_pages, int write, int force,
-			struct page **pages, struct vm_area_struct **vmas);
+long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		      unsigned long start, unsigned long nr_pages,
+		      unsigned int foll_flags, struct page **pages,
+		      struct vm_area_struct **vmas, int *nonblocking);
+long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		    unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages,
+		    struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 struct kvec;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4f3ea0b1e57c..951873c8f57e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2924,14 +2924,14 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 	return NULL;
 }
 
-int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			struct page **pages, struct vm_area_struct **vmas,
-			unsigned long *position, int *length, int i,
-			unsigned int flags)
+long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			 struct page **pages, struct vm_area_struct **vmas,
+			 unsigned long *position, unsigned long *nr_pages,
+			 long i, unsigned int flags)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
-	int remainder = *length;
+	unsigned long remainder = *nr_pages;
 	struct hstate *h = hstate_vma(vma);
 
 	spin_lock(&mm->page_table_lock);
@@ -3001,7 +3001,7 @@ same_page:
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	*length = remainder;
+	*nr_pages = remainder;
 	*position = vaddr;
 
 	return i ? i : -EFAULT;
diff --git a/mm/memory.c b/mm/memory.c
index f56683208e7f..f0b6b2b798c4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1673,15 +1673,15 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
  * instead of __get_user_pages. __get_user_pages should be used only if
  * you need some special @gup_flags.
  */
-int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long start, int nr_pages, unsigned int gup_flags,
-		     struct page **pages, struct vm_area_struct **vmas,
-		     int *nonblocking)
+long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		unsigned int gup_flags, struct page **pages,
+		struct vm_area_struct **vmas, int *nonblocking)
 {
-	int i;
+	long i;
 	unsigned long vm_flags;
 
-	if (nr_pages <= 0)
+	if (!nr_pages)
 		return 0;
 
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
@@ -1977,9 +1977,9 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
  *
  * See also get_user_pages_fast, for performance critical applications.
  */
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, int nr_pages, int write, int force,
-		struct page **pages, struct vm_area_struct **vmas)
+long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages, int write,
+		int force, struct page **pages, struct vm_area_struct **vmas)
 {
 	int flags = FOLL_TOUCH;
 
diff --git a/mm/mlock.c b/mm/mlock.c
index b1647fbd6bce..1f863a1481d3 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -160,7 +160,7 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr = start;
-	int nr_pages = (end - start) / PAGE_SIZE;
+	unsigned long nr_pages = (end - start) / PAGE_SIZE;
 	int gup_flags;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
@@ -378,7 +378,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 	unsigned long end, nstart, nend;
 	struct vm_area_struct *vma = NULL;
 	int locked = 0;
-	int ret = 0;
+	long ret = 0;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(len != PAGE_ALIGN(len));
diff --git a/mm/nommu.c b/mm/nommu.c
index 429a3d5217fa..207452d649f2 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -139,10 +139,10 @@ unsigned int kobjsize(const void *objp)
 	return PAGE_SIZE << compound_order(page);
 }
 
-int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long start, int nr_pages, unsigned int foll_flags,
-		     struct page **pages, struct vm_area_struct **vmas,
-		     int *retry)
+long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		      unsigned long start, unsigned long nr_pages,
+		      unsigned int foll_flags, struct page **pages,
+		      struct vm_area_struct **vmas, int *nonblocking)
 {
 	struct vm_area_struct *vma;
 	unsigned long vm_flags;
@@ -189,9 +189,10 @@ finish_or_fault:
  *   slab page or a secondary page from a compound page
  * - don't permit access to VMAs that don't support it, such as I/O mappings
  */
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-	unsigned long start, int nr_pages, int write, int force,
-	struct page **pages, struct vm_area_struct **vmas)
+long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		    unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages,
+		    struct vm_area_struct **vmas)
 {
 	int flags = 0;
 
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
