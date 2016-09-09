Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4177A6B0260
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 18:25:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so215415029pfb.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 15:25:35 -0700 (PDT)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id g4si5911570pax.227.2016.09.09.15.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 15:25:34 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 2/2] shmem: call __thp_get_unmapped_area to alloc a pmd-aligned addr
Date: Fri,  9 Sep 2016 16:24:23 -0600
Message-Id: <1473459863-11287-3-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1473459863-11287-1-git-send-email-toshi.kani@hpe.com>
References: <1473459863-11287-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, mawilcox@microsoft.com, hughd@google.com, kirill.shutemov@linux.intel.com, toshi.kani@hpe.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

shmem_get_unmapped_area() provides a functionality similar
to __thp_get_unmapped_area() as both allocate a pmd-aligned
address.

Change shmem_get_unmapped_area() to do shm-specific checks
and then call __thp_get_unmapped_area() for allocating
a pmd-aligned address.

link: https://lkml.org/lkml/2016/8/29/620
Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/huge_mm.h |   10 +++++++
 mm/shmem.c              |   68 +++++++++--------------------------------------
 2 files changed, 23 insertions(+), 55 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4fca526..1b65924 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -90,6 +90,9 @@ extern unsigned long transparent_hugepage_flags;
 extern unsigned long thp_get_unmapped_area(struct file *filp,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags);
+extern unsigned long __thp_get_unmapped_area(struct file *filp,
+		unsigned long len, loff_t off, unsigned long flags,
+		unsigned long size);
 
 extern void prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
@@ -176,6 +179,13 @@ static inline void prep_transhuge_page(struct page *page) {}
 
 #define thp_get_unmapped_area	NULL
 
+static inline unsigned long __thp_get_unmapped_area(struct file *filp,
+		unsigned long len, loff_t off, unsigned long flags,
+		unsigned long size)
+{
+	return 0;
+}
+
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
 {
diff --git a/mm/shmem.c b/mm/shmem.c
index aec5b49..ef27455 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1925,45 +1925,23 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 
 unsigned long shmem_get_unmapped_area(struct file *file,
-				      unsigned long uaddr, unsigned long len,
+				      unsigned long addr, unsigned long len,
 				      unsigned long pgoff, unsigned long flags)
 {
-	unsigned long (*get_area)(struct file *,
-		unsigned long, unsigned long, unsigned long, unsigned long);
-	unsigned long addr;
-	unsigned long offset;
-	unsigned long inflated_len;
-	unsigned long inflated_addr;
-	unsigned long inflated_offset;
-
-	if (len > TASK_SIZE)
-		return -ENOMEM;
-
-	get_area = current->mm->get_unmapped_area;
-	addr = get_area(file, uaddr, len, pgoff, flags);
+	loff_t off = (loff_t)pgoff << PAGE_SHIFT;
 
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
-		return addr;
-	if (IS_ERR_VALUE(addr))
-		return addr;
-	if (addr & ~PAGE_MASK)
-		return addr;
-	if (addr > TASK_SIZE - len)
-		return addr;
-
+		goto out;
 	if (shmem_huge == SHMEM_HUGE_DENY)
-		return addr;
-	if (len < HPAGE_PMD_SIZE)
-		return addr;
-	if (flags & MAP_FIXED)
-		return addr;
+		goto out;
+
 	/*
 	 * Our priority is to support MAP_SHARED mapped hugely;
 	 * and support MAP_PRIVATE mapped hugely too, until it is COWed.
 	 * But if caller specified an address hint, respect that as before.
 	 */
-	if (uaddr)
-		return addr;
+	if (addr)
+		goto out;
 
 	if (shmem_huge != SHMEM_HUGE_FORCE) {
 		struct super_block *sb;
@@ -1977,39 +1955,19 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 			 * for "/dev/zero", to create a shared anonymous object.
 			 */
 			if (IS_ERR(shm_mnt))
-				return addr;
+				goto out;
 			sb = shm_mnt->mnt_sb;
 		}
 		if (SHMEM_SB(sb)->huge == SHMEM_HUGE_NEVER)
-			return addr;
+			goto out;
 	}
 
-	offset = (pgoff << PAGE_SHIFT) & (HPAGE_PMD_SIZE-1);
-	if (offset && offset + len < 2 * HPAGE_PMD_SIZE)
-		return addr;
-	if ((addr & (HPAGE_PMD_SIZE-1)) == offset)
-		return addr;
-
-	inflated_len = len + HPAGE_PMD_SIZE - PAGE_SIZE;
-	if (inflated_len > TASK_SIZE)
-		return addr;
-	if (inflated_len < len)
-		return addr;
-
-	inflated_addr = get_area(NULL, 0, inflated_len, 0, flags);
-	if (IS_ERR_VALUE(inflated_addr))
-		return addr;
-	if (inflated_addr & ~PAGE_MASK)
+	addr = __thp_get_unmapped_area(file, len, off, flags, HPAGE_PMD_SIZE);
+	if (addr)
 		return addr;
 
-	inflated_offset = inflated_addr & (HPAGE_PMD_SIZE-1);
-	inflated_addr += offset - inflated_offset;
-	if (inflated_offset > offset)
-		inflated_addr += HPAGE_PMD_SIZE;
-
-	if (inflated_addr > TASK_SIZE - len)
-		return addr;
-	return inflated_addr;
+ out:
+	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
 }
 
 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
