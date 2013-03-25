Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id EC0166B0093
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 09:23:38 -0400 (EDT)
Date: Mon, 25 Mar 2013 14:24:26 +0100
From: Cyril Hrubis <chrubis@suse.cz>
Subject: [PATCH] mm/mmap: Check for RLIMIT_AS before unmapping
Message-ID: <20130325132426.GA3142@rei.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch fixes corner case for MAP_FIXED when requested mapping length
is larger than rlimit for virtual memory. In such case any overlapping
mappings are unmapped before we check for the limit and return ENOMEM.

The check is moved before the loop that unmaps overlapping parts of
existing mappings. When we are about to hit the limit (currently mapped
pages + len > limit) we scan for overlapping pages and check again
accounting for them.

This fixes situation when userspace program expects that the previous
mappings are preserved after the mmap() syscall has returned with error.
(POSIX clearly states that successfull mapping shall replace any
previous mappings.)

This corner case was found and can be tested with LTP testcase:

testcases/open_posix_testsuite/conformance/interfaces/mmap/24-2.c

In this case the mmap, which is clearly over current limit, unmaps
dynamic libraries and the testcase segfaults right after returning into
userspace.

I've also looked at the second instance of the unmapping loop in the
do_brk(). The do_brk() is called from brk() syscall and from vm_brk().
The brk() syscall checks for overlapping mappings and bails out when
there are any (so it can't be triggered from the brk syscall). The
vm_brk() is called only from binmft handlers so it shouldn't be
triggered unless binmft handler created overlapping mappings.

Signed-off-by: Cyril Hrubis <chrubis@suse.cz>
---
 mm/mmap.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 46 insertions(+), 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2664a47..e755080 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -33,6 +33,7 @@
 #include <linux/uprobes.h>
 #include <linux/rbtree_augmented.h>
 #include <linux/sched/sysctl.h>
+#include <linux/kernel.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -543,6 +544,34 @@ static int find_vma_links(struct mm_struct *mm, unsigned long addr,
 	return 0;
 }
 
+static unsigned long count_vma_pages_range(struct mm_struct *mm,
+		unsigned long addr, unsigned long end)
+{
+	unsigned long nr_pages = 0;
+	struct vm_area_struct *vma;
+
+	/* Find first overlaping mapping */
+	vma = find_vma_intersection(mm, addr, end);
+	if (!vma)
+		return 0;
+
+	nr_pages = (min(end, vma->vm_end) -
+		max(addr, vma->vm_start)) >> PAGE_SHIFT;
+
+	/* Iterate over the rest of the overlaps */
+	for (vma = vma->vm_next; vma; vma = vma->vm_next) {
+		unsigned long overlap_len;
+
+		if (vma->vm_start > end)
+			break;
+
+		overlap_len = min(end, vma->vm_end) - vma->vm_start;
+		nr_pages += overlap_len >> PAGE_SHIFT;
+	}
+
+	return nr_pages;
+}
+
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
@@ -1433,6 +1462,23 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long charged = 0;
 	struct inode *inode =  file ? file_inode(file) : NULL;
 
+	/* Check against address space limit. */
+	if (!may_expand_vm(mm, len >> PAGE_SHIFT)) {
+		unsigned long nr_pages;
+
+		/*
+		 * MAP_FIXED may remove pages of mappings that intersects with
+		 * requested mapping. Account for the pages it would unmap.
+		 */
+		if (!(vm_flags & MAP_FIXED))
+			return -ENOMEM;
+
+		nr_pages = count_vma_pages_range(mm, addr, addr + len);
+
+		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))
+			return -ENOMEM;
+	}
+
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
@@ -1442,10 +1488,6 @@ munmap_back:
 		goto munmap_back;
 	}
 
-	/* Check against address space limit. */
-	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
-		return -ENOMEM;
-
 	/*
 	 * Private writable mapping: check memory availability
 	 */
-- 
1.8.1.5

See also a testsuite that exercies the newly added codepaths which is
attached as a tarball (All testcases minus the second that tests
that this patch works succeeds both before and after this patch).

-- 
Cyril Hrubis
chrubis@suse.cz

--AhhlLboLdkugWU4S
Content-Type: application/x-bzip2
Content-Disposition: attachment; filename="mm.tar.bz2"
Content-Transfer-Encoding: base64

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
jCcIBP/F3JFOFCQPRFOdgA==

--AhhlLboLdkugWU4S--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
