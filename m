Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8517C6B00DF
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 11:46:46 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr4so2148478pbb.11
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 08:46:46 -0700 (PDT)
Received: from psmtp.com ([74.125.245.192])
        by mx.google.com with SMTP id qk4si5447680pac.119.2013.10.25.08.46.44
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 08:46:45 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcjenn@linux.vnet.ibm.com>;
	Fri, 25 Oct 2013 21:16:41 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 4AA2CE0018
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 21:18:11 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9PFkXUq37617798
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 21:16:34 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9PFkZq6010898
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 21:16:36 +0530
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH v2 2/2] vmsplice: Add limited zero copy to vmsplice
Date: Fri, 25 Oct 2013 10:46:24 -0500
Message-Id: <1382715984-10558-3-git-send-email-rcj@linux.vnet.ibm.com>
In-Reply-To: <1382715984-10558-1-git-send-email-rcj@linux.vnet.ibm.com>
References: <1382715984-10558-1-git-send-email-rcj@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, Robert Jennings <rcj@linux.vnet.ibm.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Simon Jin <simonjin@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

From: Robert C Jennings <rcj@linux.vnet.ibm.com>

It is sometimes useful to move anonymous pages over a pipe rather than
save/swap them. Check the SPLICE_F_GIFT and SPLICE_F_MOVE flags to see
if userspace would like to move such pages. This differs from plain
SPLICE_F_GIFT in that the memory written to the pipe will no longer
have the same contents as the original -- it effectively faults in new,
empty anonymous pages.

On the read side the page written to the pipe will be copied unless
SPLICE_F_MOVE is used. Otherwise page flipping will be performed and the
page will be reclaimed. Note that so long as there is a mapping to the
page copies will be performed instead because rmap will have upped the
map count for each anonymous mapping; this can happen due to fork(),
for example. This is necessary because moving the page will usually
change the anonymous page's nonlinear index and that can only be done
if it's unmapped.

Signed-off-by: Matt Helsley <matt.helsley@gmail.com>
Signed-off-by: Robert C Jennings <rcj@linux.vnet.ibm.com>
---
Changes since v1:
 - Page flipping in pipe_to_user pulled out into a new function,
   __pipe_to_user_move
 - Improved documentation in code and patch description
 - Fixed locking issue in flipping code found by sparse
 - Updated vmsplice comments for vmsplice_to_user(), 
   vmsplice_to_pipe, and vmsplice syscall
---
 fs/splice.c | 121 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 112 insertions(+), 9 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index c14be6f..955afc0 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -32,6 +32,10 @@
 #include <linux/gfp.h>
 #include <linux/socket.h>
 #include <linux/compat.h>
+#include <linux/page-flags.h>
+#include <linux/hugetlb.h>
+#include <linux/ksm.h>
+#include <linux/swapops.h>
 #include "internal.h"
 
 /*
@@ -1545,12 +1549,108 @@ static int get_iovec_page_array(const struct iovec __user *iov,
 	return error;
 }
 
+/* __pipe_to_user_move - Attempt to move pages into user vma by flipping
+ *
+ * Description:
+ *	This function will try to flip pages in the pipe to the user rather
+ *	than copying.
+ */
+/* Returns:
+ *  Success, number of bytes flipped
+ *  Failure, negative error value
+ */
+static int __pipe_to_user_move(struct pipe_inode_info *pipe,
+			     struct pipe_buffer *buf, struct splice_desc *sd)
+{
+	int ret = -EFAULT;
+	struct page *page = buf->page;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	spinlock_t *ptl;
+	pte_t *ptep, pte;
+	unsigned long useraddr;
+
+
+	if (!(buf->flags & PIPE_BUF_FLAG_GIFT) ||
+			!(sd->flags & SPLICE_F_MOVE) ||
+			(buf->offset) || (buf->len != PAGE_SIZE))
+		goto out;
+
+	/* Moving pages is done only for a subset of pages.
+	 * They must be anonymous and unmapped. The anon page's
+	 * nonlinear index will probably change which can only be
+	 * done if it is unmapped.
+	 */
+	if (!PageAnon(page))
+		goto out;
+	if (page_mapped(page))
+		goto out;
+
+	/* Huge pages must be copied as we are not tracking if
+	 * all of the PAGE_SIZE pipe_buffers which compose the
+	 * huge page are in the pipe.
+	 */
+	if (PageCompound(page))
+		goto out;
+	/* TODO: Add support for TransHuge pages */
+	if (PageHuge(page) || PageTransHuge(page))
+		goto out;
+
+	useraddr = (unsigned long)sd->u.userptr;
+	mm = current->mm;
+
+	down_read(&mm->mmap_sem);
+	vma = find_vma(mm, useraddr);
+	if (IS_ERR_OR_NULL(vma))
+		goto up_copy;
+	if (!vma->anon_vma) {
+		ret = anon_vma_prepare(vma);
+		if (ret)
+			goto up_copy;
+	}
+	zap_page_range(vma, useraddr, PAGE_SIZE, NULL);
+	ret = lock_page_killable(page);
+	if (ret)
+		goto up_copy;
+	ptep = get_locked_pte(mm, useraddr, &ptl);
+	if (!ptep)
+		goto page_unlock_up_copy;
+	pte = *ptep;
+	if (pte_present(pte))
+		goto pte_unlock_up_copy;
+	get_page(page);
+	page_add_anon_rmap(page, vma, useraddr);
+	pte = mk_pte(page, vma->vm_page_prot);
+	set_pte_at(mm, useraddr, ptep, pte);
+	update_mmu_cache(vma, useraddr, ptep);
+	ret = 0;
+pte_unlock_up_copy:
+	pte_unmap_unlock(ptep, ptl);
+page_unlock_up_copy:
+	unlock_page(page);
+up_copy:
+	up_read(&mm->mmap_sem);
+	if (!ret) {
+		ret = sd->len;
+		goto out;
+	}
+	/* else ret < 0 and we should fallback to copying */
+	VM_BUG_ON(ret > 0);
+out:
+	return ret;
+}
+
 static int pipe_to_user(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 			struct splice_desc *sd)
 {
 	char *src;
 	int ret;
 
+	/* Attempt to move pages rather than copy */
+	ret = __pipe_to_user_move(pipe, buf, sd);
+	if (ret > 0)
+		goto out;
+
 	/*
 	 * See if we can use the atomic maps, by prefaulting in the
 	 * pages and doing an atomic copy
@@ -1583,8 +1683,11 @@ out:
 }
 
 /*
- * For lack of a better implementation, implement vmsplice() to userspace
- * as a simple copy of the pipes pages to the user iov.
+ * Implement vmsplice() to userspace as a simple copy of the pipe's pages
+ * to the user iov.
+ *
+ * The SPLICE_F_MOVE flag for vmsplice() will cause pipe_to_user() to attempt
+ * moving pages into the user iov when possible, replacing the current pages.
  */
 static long vmsplice_to_user(struct file *file, const struct iovec __user *iov,
 			     unsigned long nr_segs, unsigned int flags)
@@ -1707,16 +1810,16 @@ static long vmsplice_to_pipe(struct file *file, const struct iovec __user *iov,
  * to a pipe, not the other way around. Splicing from user memory is a simple
  * operation that can be supported without any funky alignment restrictions
  * or nasty vm tricks. We simply map in the user memory and fill them into
- * a pipe. The reverse isn't quite as easy, though. There are two possible
- * solutions for that:
+ * a pipe.  The reverse isn't quite as easy, though. There are two paths
+ * taken:
  *
  *	- memcpy() the data internally, at which point we might as well just
  *	  do a regular read() on the buffer anyway.
- *	- Lots of nasty vm tricks, that are neither fast nor flexible (it
- *	  has restriction limitations on both ends of the pipe).
- *
- * Currently we punt and implement it as a normal copy, see pipe_to_user().
- *
+ *	- Move pages from source to destination when the flags
+ *	  (SPLICE_F_GIFT | SPLICE_F_MOVE) are present.  Pages are zapped on
+ *	  the source then moved into the destination process.  This falls
+ *	  back to memcpy() when necessary. See pipe_to_user() for fall-back
+ *	  conditions.
  */
 SYSCALL_DEFINE4(vmsplice, int, fd, const struct iovec __user *, iov,
 		unsigned long, nr_segs, unsigned int, flags)
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
