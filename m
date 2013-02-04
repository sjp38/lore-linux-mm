Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 455E46B0007
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 02:17:18 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fa11so605348pad.23
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 23:17:17 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 1/3] fix mm: use long type for page counts in mm_populate() and get_user_pages()
Date: Sun,  3 Feb 2013 23:17:10 -0800
Message-Id: <1359962232-20811-2-git-send-email-walken@google.com>
In-Reply-To: <1359962232-20811-1-git-send-email-walken@google.com>
References: <1359962232-20811-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Andrew suggested I make the nr_pages argument an unsigned long rather
than just a long. I was initially worried that nr_pages would be compared
with signed longs, but this isn't the case, so his suggestion is perfectly
valid.

Sending as a 'fix' change, to be collapsed with the original in -mm.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 include/linux/hugetlb.h |  2 +-
 include/linux/mm.h      | 11 ++++++-----
 mm/hugetlb.c            |  8 ++++----
 mm/memory.c             | 12 ++++++------
 mm/mlock.c              |  2 +-
 5 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index fc6ed17cfd17..eedc334fb6f5 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -45,7 +45,7 @@ int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 long follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			 struct page **, struct vm_area_struct **,
-			 unsigned long *, long *, long, unsigned int flags);
+			 unsigned long *, unsigned long *, long, unsigned int);
 void unmap_hugepage_range(struct vm_area_struct *,
 			  unsigned long, unsigned long, struct page *);
 void __unmap_hugepage_range_final(struct mmu_gather *tlb,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d5716094f191..3d9fbcf9fa94 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1041,12 +1041,13 @@ extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, int write);
 
 long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		      unsigned long start, long len, unsigned int foll_flags,
-		      struct page **pages, struct vm_area_struct **vmas,
-		      int *nonblocking);
+		      unsigned long start, unsigned long nr_pages,
+		      unsigned int foll_flags, struct page **pages,
+		      struct vm_area_struct **vmas, int *nonblocking);
 long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, long nr_pages, int write, int force,
-		    struct page **pages, struct vm_area_struct **vmas);
+		    unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages,
+		    struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 struct kvec;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4ad07221ce60..951873c8f57e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2926,12 +2926,12 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 
 long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 struct page **pages, struct vm_area_struct **vmas,
-			 unsigned long *position, long *length, long i,
-			 unsigned int flags)
+			 unsigned long *position, unsigned long *nr_pages,
+			 long i, unsigned int flags)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
-	long remainder = *length;
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
index 381b78c20d84..f0b6b2b798c4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1674,14 +1674,14 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
  * you need some special @gup_flags.
  */
 long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, long nr_pages, unsigned int gup_flags,
-		struct page **pages, struct vm_area_struct **vmas,
-		int *nonblocking)
+		unsigned long start, unsigned long nr_pages,
+		unsigned int gup_flags, struct page **pages,
+		struct vm_area_struct **vmas, int *nonblocking)
 {
 	long i;
 	unsigned long vm_flags;
 
-	if (nr_pages <= 0)
+	if (!nr_pages)
 		return 0;
 
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
@@ -1978,8 +1978,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
  * See also get_user_pages_fast, for performance critical applications.
  */
 long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, long nr_pages, int write, int force,
-		struct page **pages, struct vm_area_struct **vmas)
+		unsigned long start, unsigned long nr_pages, int write,
+		int force, struct page **pages, struct vm_area_struct **vmas)
 {
 	int flags = FOLL_TOUCH;
 
diff --git a/mm/mlock.c b/mm/mlock.c
index e1fa9e4b0a66..6baaf4b0e591 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -160,7 +160,7 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long addr = start;
-	long nr_pages = (end - start) / PAGE_SIZE;
+	unsigned long nr_pages = (end - start) / PAGE_SIZE;
 	int gup_flags;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
