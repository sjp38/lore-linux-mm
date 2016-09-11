Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA7DE6B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 13:34:41 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu12so18534329pac.1
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 10:34:41 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id gj2si16816616pac.224.2016.09.11.10.34.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Sep 2016 10:34:41 -0700 (PDT)
Subject: [RFC PATCH 1/2] mm,
 mincore2(): retrieve dax and tlb-size attributes of an address range
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 11 Sep 2016 10:31:35 -0700
Message-ID: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As evidenced by this bug report [1], userspace libraries are interested
in whether a mapping is DAX mapped, i.e. no intervening page cache.
Rather than using the ambiguous VM_MIXEDMAP flag in smaps, provide an
explicit "is dax" indication as a new flag in the page vector populated
by mincore.

There are also cases, particularly for testing and validating a
configuration to know the hardware mapping geometry of the pages in a
given process address range.  Consider filesystem-dax where a
configuration needs to take care to align partitions and block
allocations before huge page mappings might be used, or
anonymous-transparent-huge-pages where a process is opportunistically
assigned large pages.  mincore2() allows these configurations to be
surveyed and validated.

The implementation takes advantage of the unused bits in the per-page
byte returned for each PAGE_SIZE extent of a given address range.  The
new format of each vector byte is:

(TLB_SHIFT - PAGE_SHIFT) << 2 | vma_is_dax() << 1 | page_present

[1]: https://lkml.org/lkml/2016/9/7/61

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/syscalls.h               |    2 +
 include/uapi/asm-generic/mman-common.h |    3 +
 kernel/sys_ni.c                        |    1 
 mm/mincore.c                           |  126 +++++++++++++++++++++++++-------
 4 files changed, 104 insertions(+), 28 deletions(-)

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
index 58274382a616..05037343f0da 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -72,4 +72,7 @@
 #define MAP_HUGE_SHIFT	26
 #define MAP_HUGE_MASK	0x3f
 
+#define MINCORE_DAX	1		/* indicate pages that are dax-mapped */
+#define MINCORE_ORDER	2		/* retrieve hardware mapping-size-order */
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
index c0b5ba965200..15f9eb5de65b 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -15,25 +15,62 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
+#include <linux/dax.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 
+#define MINCORE_DAX_MASK 2
+#define MINCORE_DAX_SHIFT 1
+
+#define MINCORE_ORDER_MASK 0x7c
+#define MINCORE_ORDER_SHIFT 2
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
+	if ((flags & MINCORE_DAX) && vma_is_dax(vma))
+		mincore |= 1 << MINCORE_DAX_SHIFT;
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
@@ -82,20 +119,24 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
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
@@ -103,8 +144,11 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
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
 
@@ -114,18 +158,20 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
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
 
@@ -135,9 +181,9 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 		if (pte_none(pte))
 			__mincore_unmapped_range(addr, addr + PAGE_SIZE,
-						 vma, vec);
+						 vma, vec, flags);
 		else if (pte_present(pte))
-			*vec = 1;
+			mincore_set(vec, vma, 1, flags);
 		else { /* pte is a swap entry */
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
@@ -146,14 +192,17 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
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
@@ -161,7 +210,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	}
 	pte_unmap_unlock(ptep - 1, ptl);
 out:
-	walk->private += nr;
+	p->vec = vec + nr;
 	cond_resched();
 	return 0;
 }
@@ -171,16 +220,21 @@ out:
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
@@ -195,13 +249,19 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 }
 
 /*
- * The mincore(2) system call.
+ * The mincore2(2) system call.
  *
- * mincore() returns the memory residency status of the pages in the
+ * mincore2() returns the memory residency status of the pages in the
  * current process's address space specified by [addr, addr + len).
  * The status is returned in a vector of bytes.  The least significant
  * bit of each byte is 1 if the referenced page is in memory, otherwise
- * it is zero.
+ * it is zero.  When 'flags' is non-zero each byte additionally contains
+ * an indication of whether the referenced page in memory is a DAX
+ * mapping (bit 2 of each vector byte), and/or the order of the mapping
+ * (bits 3 through 7 of each vector byte).  Where the order relates to
+ * the hardware mapping size backing the given logical-page.  For
+ * example, a 2MB-dax-mapped-huge-page would correspond to 512 vector
+ * entries with the value 0x27.
  *
  * Because the status of a page can change after mincore() checks it
  * but before it returns to the application, the returned vector may
@@ -218,8 +278,8 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
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
@@ -229,6 +289,10 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
+	/* Check that undefined flags are zero */
+	if (flags & ~(MINCORE_DAX | MINCORE_ORDER))
+		return -EINVAL;
+
 	/* ..and we need to be passed a valid user-space range */
 	if (!access_ok(VERIFY_READ, (void __user *) start, len))
 		return -ENOMEM;
@@ -251,7 +315,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 		 * the temporary buffer size.
 		 */
 		down_read(&current->mm->mmap_sem);
-		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp);
+		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp, flags);
 		up_read(&current->mm->mmap_sem);
 
 		if (retval <= 0)
@@ -268,3 +332,9 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
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
