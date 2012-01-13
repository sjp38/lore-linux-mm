Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 185686B005A
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 06:50:10 -0500 (EST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Fri, 13 Jan 2012 11:35:04 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0DBh7Un3481738
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:43:07 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0DBlWTd026449
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:47:32 +1100
Message-ID: <4F1019D3.8020709@linux.vnet.ibm.com>
Date: Fri, 13 Jan 2012 19:47:31 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 5/5] mm: search from free_area_cache for the bigger size
References: <4F101904.8090405@linux.vnet.ibm.com>
In-Reply-To: <4F101904.8090405@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

If the required size is bigger than cached_hole_size, we would better search
from free_area_cache, it is more easier to get free region, specifically for
the 64 bit process whose address space is large enough

Do it just as hugetlb_get_unmapped_area_topdown() in arch/x86/mm/hugetlbpage.c

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 arch/x86/kernel/sys_x86_64.c |   34 +++++++++++++++++-----------------
 mm/mmap.c                    |   36 +++++++++++++++++++++---------------
 2 files changed, 38 insertions(+), 32 deletions(-)

diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 0514890..ef59642 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -195,7 +195,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
-	unsigned long addr = addr0;
+	unsigned long addr = addr0, start_addr;

 	/* requested length too big for entire address space */
 	if (len > TASK_SIZE)
@@ -223,25 +223,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		mm->free_area_cache = mm->mmap_base;
 	}

+try_again:
 	/* either no address requested or can't fit in requested address hole */
-	addr = mm->free_area_cache;
-
-	/* make sure it can fit in the remaining address space */
-	if (addr > len) {
-		unsigned long tmp_addr = align_addr(addr - len, filp,
-						    ALIGN_TOPDOWN);
-
-		vma = find_vma(mm, tmp_addr);
-		if (!vma || tmp_addr + len <= vma->vm_start)
-			/* remember the address as a hint for next time */
-			return mm->free_area_cache = tmp_addr;
-	}
-
-	if (mm->mmap_base < len)
-		goto bottomup;
+	start_addr = addr = mm->free_area_cache;

-	addr = mm->mmap_base-len;
+	if (addr < len)
+		goto fail;

+	addr -= len;
 	do {
 		addr = align_addr(addr, filp, ALIGN_TOPDOWN);

@@ -263,6 +252,17 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		addr = vma->vm_start-len;
 	} while (len < vma->vm_start);

+fail:
+	/*
+	 * if hint left us with no space for the requested
+	 * mapping then try again:
+	 */
+	if (start_addr != mm->mmap_base) {
+		mm->free_area_cache = mm->mmap_base;
+		mm->cached_hole_size = 0;
+		goto try_again;
+	}
+
 bottomup:
 	/*
 	 * A failed mmap() very likely causes application failure,
diff --git a/mm/mmap.c b/mm/mmap.c
index 970f572..e3c4b97 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1439,7 +1439,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
-	unsigned long addr = addr0;
+	unsigned long addr = addr0, start_addr;

 	/* requested length too big for entire address space */
 	if (len > TASK_SIZE)
@@ -1463,22 +1463,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
  		mm->free_area_cache = mm->mmap_base;
  	}

+try_again:
 	/* either no address requested or can't fit in requested address hole */
-	addr = mm->free_area_cache;
+	start_addr = addr = mm->free_area_cache;

-	/* make sure it can fit in the remaining address space */
-	if (addr > len) {
-		vma = find_vma(mm, addr-len);
-		if (!vma || addr <= vma->vm_start)
-			/* remember the address as a hint for next time */
-			return (mm->free_area_cache = addr-len);
-	}
-
-	if (mm->mmap_base < len)
-		goto bottomup;
-
-	addr = mm->mmap_base-len;
+	if (addr < len)
+		goto fail;

+	addr -= len;
 	do {
 		/*
 		 * Lookup failure means no vma is above this address,
@@ -1498,7 +1490,21 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		addr = vma->vm_start-len;
 	} while (len < vma->vm_start);

-bottomup:
+fail:
+	/*
+	 * if hint left us with no space for the requested
+	 * mapping then try again:
+	 *
+	 * Note: this is different with the case of bottomup
+	 * which does the fully line-search, but we use find_vma
+	 * here that causes some holes skipped.
+	 */
+	if (start_addr != mm->mmap_base) {
+		mm->free_area_cache = mm->mmap_base;
+		mm->cached_hole_size = 0;
+		goto try_again;
+	}
+
 	/*
 	 * A failed mmap() very likely causes application failure,
 	 * so fall back to the bottom-up function here. This scenario
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
