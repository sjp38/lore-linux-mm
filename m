Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B230D6B0264
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 02:57:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so77382418pfb.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 23:57:48 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r195si11890793pfr.240.2016.09.14.23.57.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 23:57:47 -0700 (PDT)
Subject: [PATCH v2 3/3] mm,
 mincore2(): retrieve tlb-size attributes of an address range
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 14 Sep 2016 23:54:44 -0700
Message-ID: <147392248390.9873.17462460294407718981.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147392246509.9873.17750323049785100997.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147392246509.9873.17750323049785100997.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, linux-kernel@vger.kernel.org, npiggin@gmail.com, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There are cases, particularly for testing and validating a configuration
to know the hardware mapping geometry of the pages in a given process
address range.  Consider filesystem-dax where a configuration needs to
take care to align partitions and block allocations before huge page
mappings might be used, or anonymous-transparent-huge-pages where a
process is opportunistically assigned large pages.  mincore2() allows
these configurations to be surveyed and validated.

The implementation takes advantage of the unused bits in the per-page
byte returned for each PAGE_SIZE extent of a given address range.  The
new format of each vector byte is:

(TLB_SHIFT - PAGE_SHIFT) << 1 | page_present

[1]: https://lkml.org/lkml/2016/9/7/61

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/syscalls.h               |    2 
 include/uapi/asm-generic/mman-common.h |    2 
 kernel/sys_ni.c                        |    1 
 mm/mincore.c                           |  130 ++++++++++++++++++++++++--------
 4 files changed, 104 insertions(+), 31 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index d02239022bd0..4aa2ee7e359a 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -467,6 +467,8 @@ asmlinkage long sys_munlockall(void);
 asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
 asmlinkage long sys_mincore(unsigned long start, size_t len,
 				unsigned char __user * vec);
+asmlinkage long sys_mincore2(unsigned long start, size_t len,
+				unsigned char __user * vec, int flags);
 
 asmlinkage long sys_pivot_root(const char __user *new_root,
 				const char __user *put_old);
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 58274382a616..6c7eca1a85ca 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -72,4 +72,6 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define MINCORE_ORDER	1		/* retrieve hardware mapping-size-order */
+
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 2c5e3a8e00d7..e14b87834054 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -197,6 +197,7 @@ cond_syscall(sys_mlockall);
 cond_syscall(sys_munlockall);
 cond_syscall(sys_mlock2);
 cond_syscall(sys_mincore);
+cond_syscall(sys_mincore2);
 cond_syscall(sys_madvise);
 cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
diff --git a/mm/mincore.c b/mm/mincore.c
index c0b5ba965200..b0b83ef086eb 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -15,25 +15,61 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
+#include <linux/dax.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 
+#ifndef MINCORE_ORDER
+#define MINCORE_ORDER 0
+#endif
+
+#define MINCORE_ORDER_MASK 0x3e
+#define MINCORE_ORDER_SHIFT 1
+
+struct mincore_params {
+	unsigned char *vec;
+	int flags;
+};
+
+static void mincore_set(unsigned char *vec, struct vm_area_struct *vma, int nr,
+		int flags)
+{
+	unsigned char mincore = 1;
+
+	if (!nr) {
+		*vec = 0;
+		return;
+	}
+
+	if (flags & MINCORE_ORDER) {
+		unsigned char order = ilog2(nr);
+
+		WARN_ON((order << MINCORE_ORDER_SHIFT) & ~MINCORE_ORDER_MASK);
+		mincore |= order << MINCORE_ORDER_SHIFT;
+	}
+	memset(vec, mincore, nr);
+}
+
 static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
 			unsigned long end, struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
+	struct mincore_params *p = walk->private;
+	int nr = (end - addr) >> PAGE_SHIFT;
+	unsigned char *vec = p->vec;
 	unsigned char present;
-	unsigned char *vec = walk->private;
 
 	/*
 	 * Hugepages under user process are always in RAM and never
 	 * swapped out, but theoretically it needs to be checked.
 	 */
 	present = pte && !huge_pte_none(huge_ptep_get(pte));
-	for (; addr != end; vec++, addr += PAGE_SIZE)
-		*vec = present;
-	walk->private = vec;
+	if (!present)
+		memset(vec, 0, nr);
+	else
+		mincore_set(vec, walk->vma, nr, p->flags);
+	p->vec = vec + nr;
 #else
 	BUG();
 #endif
@@ -82,20 +118,24 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 }
 
 static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
-				struct vm_area_struct *vma, unsigned char *vec)
+				struct vm_area_struct *vma, unsigned char *vec,
+				int flags)
 {
 	unsigned long nr = (end - addr) >> PAGE_SHIFT;
+	unsigned char present;
 	int i;
 
 	if (vma->vm_file) {
 		pgoff_t pgoff;
 
 		pgoff = linear_page_index(vma, addr);
-		for (i = 0; i < nr; i++, pgoff++)
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+		for (i = 0; i < nr; i++, pgoff++) {
+			present = mincore_page(vma->vm_file->f_mapping, pgoff);
+			mincore_set(vec + i, vma, present, flags);
+		}
 	} else {
 		for (i = 0; i < nr; i++)
-			vec[i] = 0;
+			mincore_set(vec + i, vma, 0, flags);
 	}
 	return nr;
 }
@@ -103,8 +143,11 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
 static int mincore_unmapped_range(unsigned long addr, unsigned long end,
 				   struct mm_walk *walk)
 {
-	walk->private += __mincore_unmapped_range(addr, end,
-						  walk->vma, walk->private);
+	struct mincore_params *p = walk->private;
+	int nr = __mincore_unmapped_range(addr, end, walk->vma, p->vec,
+			p->flags);
+
+	p->vec += nr;
 	return 0;
 }
 
@@ -114,18 +157,20 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	spinlock_t *ptl;
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *ptep;
-	unsigned char *vec = walk->private;
+	struct mincore_params *p = walk->private;
+	unsigned char *vec = p->vec;
 	int nr = (end - addr) >> PAGE_SHIFT;
+	int flags = p->flags;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
-		memset(vec, 1, nr);
+		mincore_set(vec, vma, nr, flags);
 		spin_unlock(ptl);
 		goto out;
 	}
 
 	if (pmd_trans_unstable(pmd)) {
-		__mincore_unmapped_range(addr, end, vma, vec);
+		__mincore_unmapped_range(addr, end, vma, vec, flags);
 		goto out;
 	}
 
@@ -135,9 +180,9 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 		if (pte_none(pte))
 			__mincore_unmapped_range(addr, addr + PAGE_SIZE,
-						 vma, vec);
+						 vma, vec, flags);
 		else if (pte_present(pte))
-			*vec = 1;
+			mincore_set(vec, vma, 1, flags);
 		else { /* pte is a swap entry */
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
@@ -146,14 +191,17 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 				 * migration or hwpoison entries are always
 				 * uptodate
 				 */
-				*vec = 1;
+				mincore_set(vec, vma, 1, flags);
 			} else {
 #ifdef CONFIG_SWAP
-				*vec = mincore_page(swap_address_space(entry),
-					entry.val);
+				unsigned char present;
+
+				present = mincore_page(swap_address_space(entry),
+						entry.val);
+				mincore_set(vec, vma, present, flags);
 #else
 				WARN_ON(1);
-				*vec = 1;
+				mincore_set(vec, vma, 1, flags);
 #endif
 			}
 		}
@@ -161,7 +209,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	}
 	pte_unmap_unlock(ptep - 1, ptl);
 out:
-	walk->private += nr;
+	p->vec = vec + nr;
 	cond_resched();
 	return 0;
 }
@@ -171,16 +219,21 @@ out:
  * all the arguments, we hold the mmap semaphore: we should
  * just return the amount of info we're asked for.
  */
-static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *vec)
+static long do_mincore(unsigned long addr, unsigned long pages,
+		unsigned char *vec, int flags)
 {
 	struct vm_area_struct *vma;
 	unsigned long end;
 	int err;
+	struct mincore_params p = {
+		.vec = vec,
+		.flags = flags,
+	};
 	struct mm_walk mincore_walk = {
 		.pmd_entry = mincore_pte_range,
 		.pte_hole = mincore_unmapped_range,
 		.hugetlb_entry = mincore_hugetlb,
-		.private = vec,
+		.private = &p,
 	};
 
 	vma = find_vma(current->mm, addr);
@@ -195,13 +248,18 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 }
 
 /*
- * The mincore(2) system call.
+ * The mincore2(2) system call.
  *
- * mincore() returns the memory residency status of the pages in the
- * current process's address space specified by [addr, addr + len).
- * The status is returned in a vector of bytes.  The least significant
- * bit of each byte is 1 if the referenced page is in memory, otherwise
- * it is zero.
+ * mincore2() returns the memory residency status of the pages in the
+ * current process's address space specified by [addr, addr + len).  The
+ * status is returned in a vector of bytes.  The least significant bit
+ * of each byte is 1 if the referenced page is in memory, otherwise it
+ * is zero.  When 'flags' is non-zero each byte additionally contains an
+ * indication of the hardware mapping size of each page (bits 1 through
+ * 5 of each vector byte).  Where the order relates to the hardware
+ * mapping size backing the given logical-page.  For example, a present
+ * 2MB-mapped-huge-page would correspond to 512 vector entries with the
+ * value (9 << 1) | (1) => 0x13
  *
  * Because the status of a page can change after mincore() checks it
  * but before it returns to the application, the returned vector may
@@ -218,8 +276,8 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
  *		mapped
  *  -EAGAIN - A kernel resource was temporarily unavailable.
  */
-SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
-		unsigned char __user *, vec)
+SYSCALL_DEFINE4(mincore2, unsigned long, start, size_t, len,
+		unsigned char __user *, vec, int, flags)
 {
 	long retval;
 	unsigned long pages;
@@ -229,6 +287,10 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
+	/* Check that undefined flags are zero */
+	if (flags & ~MINCORE_ORDER)
+		return -EINVAL;
+
 	/* ..and we need to be passed a valid user-space range */
 	if (!access_ok(VERIFY_READ, (void __user *) start, len))
 		return -ENOMEM;
@@ -251,7 +313,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 		 * the temporary buffer size.
 		 */
 		down_read(&current->mm->mmap_sem);
-		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp);
+		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp, flags);
 		up_read(&current->mm->mmap_sem);
 
 		if (retval <= 0)
@@ -268,3 +330,9 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	free_page((unsigned long) tmp);
 	return retval;
 }
+
+SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
+		unsigned char __user *, vec)
+{
+	return sys_mincore2(start, len, vec, 0);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
