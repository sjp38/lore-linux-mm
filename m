Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA05755
	for <linux-mm@kvack.org>; Fri, 31 Jan 2003 15:14:04 -0800 (PST)
Date: Fri, 31 Jan 2003 15:16:28 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030131151628.53640630.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

1/4

Using a futex in a large page causes a kernel lockup in __pin_page() -
because __pin_page's page revalidation uses follow_page(), and follow_page()
doesn't work for hugepages.

The patch fixes up follow_page() to return the appropriate 4k page for
hugepages.

This incurs a vma lookup for each follow_page(), which is considerable
overhead in some situations.  We only _need_ to do this if the architecture
cannot determin a page's hugeness from the contents of the PMD.

So this patch is a "reference" implementation for, say, PPC BAT-based
hugepages.




 arch/i386/mm/hugetlbpage.c |   29 +++++++++++++++++++++++++++++
 include/linux/hugetlb.h    |   18 ++++++++++++++++--
 include/linux/sched.h      |    4 +++-
 mm/memory.c                |    5 +++++
 mm/mmap.c                  |    2 +-
 linux/mm.h                 |    0 
 6 files changed, 54 insertions(+), 4 deletions(-)

diff -puN mm/memory.c~pin_page-fix mm/memory.c
--- 25/mm/memory.c~pin_page-fix	Fri Jan 31 13:32:13 2003
+++ 25-akpm/mm/memory.c	Fri Jan 31 14:29:59 2003
@@ -607,6 +607,11 @@ follow_page(struct mm_struct *mm, unsign
 	pmd_t *pmd;
 	pte_t *ptep, pte;
 	unsigned long pfn;
+	struct vm_area_struct *vma;
+
+	vma = hugepage_vma(mm, address);
+	if (vma)
+		return follow_huge_addr(mm, vma, address, write);
 
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || pgd_bad(*pgd))
diff -puN include/linux/hugetlb.h~pin_page-fix include/linux/hugetlb.h
--- 25/include/linux/hugetlb.h~pin_page-fix	Fri Jan 31 13:32:13 2003
+++ 25-akpm/include/linux/hugetlb.h	Fri Jan 31 14:29:59 2003
@@ -20,16 +20,28 @@ int hugetlb_prefault(struct address_spac
 void huge_page_release(struct page *);
 int hugetlb_report_meminfo(char *);
 int is_hugepage_mem_enough(size_t);
-
+struct page *follow_huge_addr(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, int write);
+struct vm_area_struct *hugepage_vma(struct mm_struct *mm,
+					unsigned long address);
 extern int htlbpage_max;
 
+static inline void
+mark_mm_hugetlb(struct mm_struct *mm, struct vm_area_struct *vma)
+{
+	if (is_vm_hugetlb_page(vma))
+		mm->used_hugetlb = 1;
+}
+
 #else /* !CONFIG_HUGETLB_PAGE */
+
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
 	return 0;
 }
 
-#define follow_hugetlb_page(m,v,p,vs,a,b,i)		({ BUG(); 0; })
+#define follow_hugetlb_page(m,v,p,vs,a,b,i)	({ BUG(); 0; })
+#define follow_huge_addr(mm, vma, addr, write)	0
 #define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
 #define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
 #define zap_hugepage_range(vma, start, len)	BUG()
@@ -37,6 +49,8 @@ static inline int is_vm_hugetlb_page(str
 #define huge_page_release(page)			BUG()
 #define is_hugepage_mem_enough(size)		0
 #define hugetlb_report_meminfo(buf)		0
+#define hugepage_vma(mm, addr)			0
+#define mark_mm_hugetlb(mm, vma)		do { } while (0)
 
 #endif /* !CONFIG_HUGETLB_PAGE */
 
diff -puN arch/i386/mm/hugetlbpage.c~pin_page-fix arch/i386/mm/hugetlbpage.c
--- 25/arch/i386/mm/hugetlbpage.c~pin_page-fix	Fri Jan 31 13:32:13 2003
+++ 25-akpm/arch/i386/mm/hugetlbpage.c	Fri Jan 31 14:29:59 2003
@@ -150,6 +150,35 @@ back1:
 	return i;
 }
 
+struct page *
+follow_huge_addr(struct mm_struct *mm,
+	struct vm_area_struct *vma, unsigned long address, int write)
+{
+	unsigned long start = address;
+	int length = 1;
+	int nr;
+	struct page *page;
+
+	nr = follow_hugetlb_page(mm, vma, &page, NULL, &start, &length, 0);
+	if (nr == 1)
+		return page;
+	return NULL;
+}
+
+/*
+ * If virtual address `addr' lies within a huge page, return its controlling
+ * VMA, else NULL.
+ */
+struct vm_area_struct *hugepage_vma(struct mm_struct *mm, unsigned long addr)
+{
+	if (mm->used_hugetlb) {
+		struct vm_area_struct *vma = find_vma(mm, addr);
+		if (vma && is_vm_hugetlb_page(vma))
+			return vma;
+	}
+	return NULL;
+}
+
 void free_huge_page(struct page *page)
 {
 	BUG_ON(page_count(page));
diff -puN mm/mmap.c~pin_page-fix mm/mmap.c
--- 25/mm/mmap.c~pin_page-fix	Fri Jan 31 13:32:13 2003
+++ 25-akpm/mm/mmap.c	Fri Jan 31 13:32:13 2003
@@ -362,6 +362,7 @@ static void vma_link(struct mm_struct *m
 	if (mapping)
 		up(&mapping->i_shared_sem);
 
+	mark_mm_hugetlb(mm, vma);
 	mm->map_count++;
 	validate_mm(mm);
 }
@@ -1427,7 +1428,6 @@ void exit_mmap(struct mm_struct *mm)
 		kmem_cache_free(vm_area_cachep, vma);
 		vma = next;
 	}
-		
 }
 
 /* Insert vm structure into process list sorted by address
diff -puN include/linux/mm.h~pin_page-fix include/linux/mm.h
diff -puN include/linux/sched.h~pin_page-fix include/linux/sched.h
--- 25/include/linux/sched.h~pin_page-fix	Fri Jan 31 13:32:13 2003
+++ 25-akpm/include/linux/sched.h	Fri Jan 31 13:32:13 2003
@@ -203,7 +203,9 @@ struct mm_struct {
 	unsigned long swap_address;
 
 	unsigned dumpable:1;
-
+#ifdef CONFIG_HUGETLB_PAGE
+	int used_hugetlb;
+#endif
 	/* Architecture-specific MM context */
 	mm_context_t context;
 

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
