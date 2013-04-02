From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/mmap: Check for RLIMIT_AS before unmapping
Date: Tue, 2 Apr 2013 20:29:48 +0800
Message-ID: <44436.0560541556$1364905833@news.gmane.org>
References: <20130402095402.GA6568@rei>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UN0MA-0005Y3-GI
	for glkm-linux-mm-2@m.gmane.org; Tue, 02 Apr 2013 14:30:30 +0200
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 54DDB6B0006
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 08:30:02 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 17:55:44 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 863DF1258023
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 18:01:11 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r32CTkcI62586892
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 17:59:46 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r32CToZm007814
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 23:29:50 +1100
Content-Disposition: inline
In-Reply-To: <20130402095402.GA6568@rei>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 02, 2013 at 11:54:03AM +0200, Cyril Hrubis wrote:
>This patch fixes corner case for MAP_FIXED when requested mapping length
>is larger than rlimit for virtual memory. In such case any overlapping
>mappings are unmapped before we check for the limit and return ENOMEM.
>
>The check is moved before the loop that unmaps overlapping parts of
>existing mappings. When we are about to hit the limit (currently mapped
>pages + len > limit) we scan for overlapping pages and check again
>accounting for them.
>
>This fixes situation when userspace program expects that the previous
>mappings are preserved after the mmap() syscall has returned with error.
>(POSIX clearly states that successfull mapping shall replace any
>previous mappings.)
>
>This corner case was found and can be tested with LTP testcase:
>
>testcases/open_posix_testsuite/conformance/interfaces/mmap/24-2.c
>
>In this case the mmap, which is clearly over current limit, unmaps
>dynamic libraries and the testcase segfaults right after returning into
>userspace.
>
>I've also looked at the second instance of the unmapping loop in the
>do_brk(). The do_brk() is called from brk() syscall and from vm_brk().
>The brk() syscall checks for overlapping mappings and bails out when
>there are any (so it can't be triggered from the brk syscall). The
>vm_brk() is called only from binmft handlers so it shouldn't be
>triggered unless binmft handler created overlapping mappings.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Cyril Hrubis <chrubis@suse.cz>
>---
> mm/mmap.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++----
> 1 file changed, 46 insertions(+), 4 deletions(-)
>
>diff --git a/mm/mmap.c b/mm/mmap.c
>index 2664a47..e755080 100644
>--- a/mm/mmap.c
>+++ b/mm/mmap.c
>@@ -33,6 +33,7 @@
> #include <linux/uprobes.h>
> #include <linux/rbtree_augmented.h>
> #include <linux/sched/sysctl.h>
>+#include <linux/kernel.h>
>
> #include <asm/uaccess.h>
> #include <asm/cacheflush.h>
>@@ -543,6 +544,34 @@ static int find_vma_links(struct mm_struct *mm, unsigned long addr,
> 	return 0;
> }
>
>+static unsigned long count_vma_pages_range(struct mm_struct *mm,
>+		unsigned long addr, unsigned long end)
>+{
>+	unsigned long nr_pages = 0;
>+	struct vm_area_struct *vma;
>+
>+	/* Find first overlaping mapping */
>+	vma = find_vma_intersection(mm, addr, end);
>+	if (!vma)
>+		return 0;
>+
>+	nr_pages = (min(end, vma->vm_end) -
>+		max(addr, vma->vm_start)) >> PAGE_SHIFT;
>+
>+	/* Iterate over the rest of the overlaps */
>+	for (vma = vma->vm_next; vma; vma = vma->vm_next) {
>+		unsigned long overlap_len;
>+
>+		if (vma->vm_start > end)
>+			break;
>+
>+		overlap_len = min(end, vma->vm_end) - vma->vm_start;
>+		nr_pages += overlap_len >> PAGE_SHIFT;
>+	}
>+
>+	return nr_pages;
>+}
>+
> void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
> 		struct rb_node **rb_link, struct rb_node *rb_parent)
> {
>@@ -1433,6 +1462,23 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
> 	unsigned long charged = 0;
> 	struct inode *inode =  file ? file_inode(file) : NULL;
>
>+	/* Check against address space limit. */
>+	if (!may_expand_vm(mm, len >> PAGE_SHIFT)) {
>+		unsigned long nr_pages;
>+
>+		/*
>+		 * MAP_FIXED may remove pages of mappings that intersects with
>+		 * requested mapping. Account for the pages it would unmap.
>+		 */
>+		if (!(vm_flags & MAP_FIXED))
>+			return -ENOMEM;
>+
>+		nr_pages = count_vma_pages_range(mm, addr, addr + len);
>+
>+		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))
>+			return -ENOMEM;
>+	}
>+
> 	/* Clear old maps */
> 	error = -ENOMEM;
> munmap_back:
>@@ -1442,10 +1488,6 @@ munmap_back:
> 		goto munmap_back;
> 	}
>
>-	/* Check against address space limit. */
>-	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
>-		return -ENOMEM;
>-
> 	/*
> 	 * Private writable mapping: check memory availability
> 	 */
>-- 
>1.8.1.5
>
>See also a testsuite that exercies the newly added codepaths which is
>attached as a tarball (All testcases minus the second that tests
>that this patch works succeeds both before and after this patch).
>
>-- 
>Cyril Hrubis
>chrubis@suse.cz


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
