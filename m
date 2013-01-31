Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 55E1D6B000C
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 19:26:26 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id hz10so1393831pad.9
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 16:26:25 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/3] mm: use long type for page counts in mm_populate() and get_user_pages()
Date: Wed, 30 Jan 2013 16:26:18 -0800
Message-Id: <1359591980-29542-2-git-send-email-walken@google.com>
In-Reply-To: <1359591980-29542-1-git-send-email-walken@google.com>
References: <1359591980-29542-1-git-send-email-walken@google.com>
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
 include/linux/mm.h      | 14 +++++++-------
 mm/hugetlb.c            | 10 +++++-----
 mm/memory.c             | 14 +++++++-------
 mm/mlock.c              |  5 +++--
 5 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 0c80d3f57a5b..fc6ed17cfd17 100644
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
+			 unsigned long *, long *, long, unsigned int flags);
 void unmap_hugepage_range(struct vm_area_struct *,
 			  unsigned long, unsigned long, struct page *);
 void __unmap_hugepage_range_final(struct mmu_gather *tlb,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a224430578f0..d5716094f191 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1040,13 +1040,13 @@ extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *
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
+		      unsigned long start, long len, unsigned int foll_flags,
+		      struct page **pages, struct vm_area_struct **vmas,
+		      int *nonblocking);
+long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		    unsigned long start, long nr_pages, int write, int force,
+		    struct page **pages, struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 struct kvec;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4f3ea0b1e57c..4ad07221ce60 100644
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
+			 unsigned long *position, long *length, long i,
+			 unsigned int flags)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
-	int remainder = *length;
+	long remainder = *length;
 	struct hstate *h = hstate_vma(vma);
 
 	spin_lock(&mm->page_table_lock);
diff --git a/mm/memory.c b/mm/memory.c
index f56683208e7f..381b78c20d84 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1673,12 +1673,12 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
  * instead of __get_user_pages. __get_user_pages should be used only if
  * you need some special @gup_flags.
  */
-int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long start, int nr_pages, unsigned int gup_flags,
-		     struct page **pages, struct vm_area_struct **vmas,
-		     int *nonblocking)
+long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, long nr_pages, unsigned int gup_flags,
+		struct page **pages, struct vm_area_struct **vmas,
+		int *nonblocking)
 {
-	int i;
+	long i;
 	unsigned long vm_flags;
 
 	if (nr_pages <= 0)
@@ -1977,8 +1977,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
  *
  * See also get_user_pages_fast, for performance critical applications.
  */
-int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, int nr_pages, int write, int force,
+long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, long nr_pages, int write, int force,
 		struct page **pages, struct vm_area_struct **vmas)
 {
 	int flags = FOLL_TOUCH;
diff --git a/mm/mlock.c b/mm/mlock.c
index b1647fbd6bce..e1fa9e4b0a66 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -160,7 +160,7 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr = start;
-	int nr_pages = (end - start) / PAGE_SIZE;
+	long nr_pages = (end - start) / PAGE_SIZE;
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
@@ -421,6 +421,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 			ret = __mlock_posix_error_return(ret);
 			break;
 		}
+		VM_BUG_ON(!ret);
 		nend = nstart + ret * PAGE_SIZE;
 		ret = 0;
 	}
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
