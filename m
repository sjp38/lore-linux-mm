Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA00178
	for <linux-mm@kvack.org>; Sat, 8 Feb 2003 00:48:38 -0800 (PST)
Date: Sat, 8 Feb 2003 00:48:42 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030208004842.0327e98e.akpm@digeo.com>
In-Reply-To: <6315617889C99D4BA7C14687DEC8DB4E023D2E70@fmsmsx402.fm.intel.com>
References: <6315617889C99D4BA7C14687DEC8DB4E023D2E70@fmsmsx402.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: davem@redhat.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Seth, Rohit" <rohit.seth@intel.com> wrote:
>
> Attached is the updated patch based on your comments.  

Thanks.

The MAP_FIXED alignment fix is clearly needed.

But the chk_align_and_fix_addr() part looks odd.  Bear in mind that MAP_FIXED
requests never make it down into the file_ops.get_unmapped_area() method.

So what is this check/fixup doing in hugetlbfs_get_unmapped_area()?

If we really need some arch-specific check/fixup in there then it will need
to be applied as hugetlbfs_get_unmapped_area() walks through the VMA's.  I
suspect it would be simpler to cut-n-paste the whole function into the arch
code, and work on it there.

My understanding of the ia64 problem is that a certain range of the user's
virtual address space is reserved for hugepages.  Normal size pages may not
be placed there, and huge pages may not be placed elsewhere.

In that case, we still need to put the check in mm/mmap.c for users placing
regular-sized pages inside the hugepage virtual address range with MAP_FIXED.
I thought it was pretty pointless putting that hook into Linus's tree until
the ia64 code which actually implemented the hook was also in his tree.

And the ia64 version of hugetlb_get_unmapped_area() will merely need to
maintain the VMA tree inside address region 4.

So...  I don't see why we need more than the below code, at least until
Linus's ia64 directory is up to date?

> For ia64, there is a separate kernel patch that David Mosberger
> maintains.  Linus's tree won't work as is on ia64. Not sure about
> x86_64/sparc64.

Why isn't David keeping Linus in sync?

> Yeah, I am working on Linus's 2.5.59 tree. Will download your mm9 to get
> my tree updated.  Is there any other patch that you want me to apply
> before sending you any more updates.

I threw -mm9 away.  Signals were very broken in it.  I'll do -mm10 or
2.5.60-mm1 this weekend; please check out the hugepage work in there - there
have been a number of changes.

> As far as non-ia32 kernel is concerned, hugetlbfs on ia64 should be
> working fine. Though I've not yet tried the 2.5.59 on ia64. 2.5.59 ia64
> patch that David maintains has the same level of hugetlb support as i386
> tree. 

OK, thanks.



diff -puN arch/i386/mm/hugetlbpage.c~hugepage-address-validation arch/i386/mm/hugetlbpage.c
--- 25/arch/i386/mm/hugetlbpage.c~hugepage-address-validation	2003-02-08 00:34:42.000000000 -0800
+++ 25-akpm/arch/i386/mm/hugetlbpage.c	2003-02-08 00:34:42.000000000 -0800
@@ -88,6 +88,18 @@ static void set_huge_pte(struct mm_struc
 	set_pte(page_table, entry);
 }
 
+/*
+ * This function checks for proper alignment of input addr and len parameters.
+ */
+int is_aligned_hugepage_range(unsigned long addr, unsigned long len)
+{
+	if (len & ~HPAGE_MASK)
+		return -EINVAL;
+	if (addr & ~HPAGE_MASK)
+		return -EINVAL;
+	return 0;
+}
+
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma)
 {
diff -puN arch/ia64/mm/hugetlbpage.c~hugepage-address-validation arch/ia64/mm/hugetlbpage.c
--- 25/arch/ia64/mm/hugetlbpage.c~hugepage-address-validation	2003-02-08 00:34:42.000000000 -0800
+++ 25-akpm/arch/ia64/mm/hugetlbpage.c	2003-02-08 00:34:42.000000000 -0800
@@ -96,6 +96,18 @@ set_huge_pte (struct mm_struct *mm, stru
 	return;
 }
 
+/*
+ * This function checks for proper alignment of input addr and len parameters.
+ */
+int is_aligned_hugepage_range(unsigned long addr, unsigned long len)
+{
+	if (len & ~HPAGE_MASK)
+		return -EINVAL;
+	if (addr & ~HPAGE_MASK)
+		return -EINVAL;
+	return 0;
+}
+
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma)
 {
diff -puN arch/sparc64/mm/hugetlbpage.c~hugepage-address-validation arch/sparc64/mm/hugetlbpage.c
--- 25/arch/sparc64/mm/hugetlbpage.c~hugepage-address-validation	2003-02-08 00:34:42.000000000 -0800
+++ 25-akpm/arch/sparc64/mm/hugetlbpage.c	2003-02-08 00:34:42.000000000 -0800
@@ -232,6 +232,18 @@ out_error:
 	return -1;
 }
 
+/*
+ * This function checks for proper alignment of input addr and len parameters.
+ */
+int is_aligned_hugepage_range(unsigned long addr, unsigned long len)
+{
+	if (len & ~HPAGE_MASK)
+		return -EINVAL;
+	if (addr & ~HPAGE_MASK)
+		return -EINVAL;
+	return 0;
+}
+
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			    struct vm_area_struct *vma)
 {
diff -puN arch/x86_64/mm/hugetlbpage.c~hugepage-address-validation arch/x86_64/mm/hugetlbpage.c
--- 25/arch/x86_64/mm/hugetlbpage.c~hugepage-address-validation	2003-02-08 00:34:42.000000000 -0800
+++ 25-akpm/arch/x86_64/mm/hugetlbpage.c	2003-02-08 00:34:42.000000000 -0800
@@ -86,6 +86,18 @@ static void set_huge_pte(struct mm_struc
 	set_pte(page_table, entry);
 }
 
+/*
+ * This function checks for proper alignment of input addr and len parameters.
+ */
+int is_aligned_hugepage_range(unsigned long addr, unsigned long len)
+{
+	if (len & ~HPAGE_MASK)
+		return -EINVAL;
+	if (addr & ~HPAGE_MASK)
+		return -EINVAL;
+	return 0;
+}
+
 int
 copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma)
diff -puN include/linux/hugetlb.h~hugepage-address-validation include/linux/hugetlb.h
--- 25/include/linux/hugetlb.h~hugepage-address-validation	2003-02-08 00:34:42.000000000 -0800
+++ 25-akpm/include/linux/hugetlb.h	2003-02-08 00:34:42.000000000 -0800
@@ -26,6 +26,7 @@ struct vm_area_struct *hugepage_vma(stru
 					unsigned long address);
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 				pmd_t *pmd, int write);
+int is_aligned_hugepage_range(unsigned long addr, unsigned long len);
 int pmd_huge(pmd_t pmd);
 
 extern int htlbpage_max;
@@ -56,6 +57,7 @@ static inline int is_vm_hugetlb_page(str
 #define hugepage_vma(mm, addr)			0
 #define mark_mm_hugetlb(mm, vma)		do { } while (0)
 #define follow_huge_pmd(mm, addr, pmd, write)	0
+#define is_aligned_hugepage_range(addr, len)	0
 #define pmd_huge(x)	0
 
 #ifndef HPAGE_MASK
diff -puN mm/mmap.c~hugepage-address-validation mm/mmap.c
--- 25/mm/mmap.c~hugepage-address-validation	2003-02-08 00:34:42.000000000 -0800
+++ 25-akpm/mm/mmap.c	2003-02-08 00:34:42.000000000 -0800
@@ -801,6 +801,13 @@ get_unmapped_area(struct file *file, uns
 			return -ENOMEM;
 		if (addr & ~PAGE_MASK)
 			return -EINVAL;
+		if (is_file_hugepages(file)) {
+			unsigned long ret;
+
+			ret = is_aligned_hugepage_range(addr, len);
+			if (ret)
+				return ret;
+		}
 		return addr;
 	}
 
@@ -1224,8 +1231,10 @@ int do_munmap(struct mm_struct *mm, unsi
 	/* we have  start < mpnt->vm_end  */
 
 	if (is_vm_hugetlb_page(mpnt)) {
-		if ((start & ~HPAGE_MASK) || (len & ~HPAGE_MASK))
-			return -EINVAL;
+		int ret = is_aligned_hugepage_range(start, len);
+
+		if (ret)
+			return ret;
 	}
 
 	/* if it doesn't overlap, we have nothing.. */

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
