Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB129000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 02:55:11 -0400 (EDT)
Received: from mail23-am1 (localhost.localdomain [127.0.0.1])	by
 mail23-am1-R.bigfish.com (Postfix) with ESMTP id 01494C1024E	for
 <linux-mm@kvack.org>; Wed, 27 Apr 2011 06:55:07 +0000 (UTC)
Received: from AM1EHSMHS003.bigfish.com (unknown [10.3.201.245])	by
 mail23-am1.bigfish.com (Postfix) with ESMTP id B37508E804B	for
 <linux-mm@kvack.org>; Wed, 27 Apr 2011 06:55:06 +0000 (UTC)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] nommu: add page_align to mmap
Date: Wed, 27 Apr 2011 15:12:14 +0800
Message-ID: <1303888334-16062-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, daniel-gl@gmx.net, vapier@gentoo.org, Bob Liu <lliubbo@gmail.com>

Currently on nommu arch mmap(),mremap() and munmap() doesn't do page_align()
which is incorrect and not consist with mmu arch.
This patch fix it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/nommu.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index c4c542c..3febfd9 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1133,7 +1133,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
 			   unsigned long capabilities)
 {
 	struct page *pages;
-	unsigned long total, point, n, rlen;
+	unsigned long total, point, n;
 	void *base;
 	int ret, order;
 
@@ -1157,13 +1157,12 @@ static int do_mmap_private(struct vm_area_struct *vma,
 		 * make a private copy of the data and map that instead */
 	}
 
-	rlen = PAGE_ALIGN(len);
 
 	/* allocate some memory to hold the mapping
 	 * - note that this may not return a page-aligned address if the object
 	 *   we're allocating is smaller than a page
 	 */
-	order = get_order(rlen);
+	order = get_order(len);
 	kdebug("alloc order %d for %lx", order, len);
 
 	pages = alloc_pages(GFP_KERNEL, order);
@@ -1173,7 +1172,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
 	total = 1 << order;
 	atomic_long_add(total, &mmap_pages_allocated);
 
-	point = rlen >> PAGE_SHIFT;
+	point = len >> PAGE_SHIFT;
 
 	/* we allocated a power-of-2 sized page set, so we may want to trim off
 	 * the excess */
@@ -1195,7 +1194,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
 	base = page_address(pages);
 	region->vm_flags = vma->vm_flags |= VM_MAPPED_COPY;
 	region->vm_start = (unsigned long) base;
-	region->vm_end   = region->vm_start + rlen;
+	region->vm_end   = region->vm_start + len;
 	region->vm_top   = region->vm_start + (total << PAGE_SHIFT);
 
 	vma->vm_start = region->vm_start;
@@ -1211,15 +1210,15 @@ static int do_mmap_private(struct vm_area_struct *vma,
 
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		ret = vma->vm_file->f_op->read(vma->vm_file, base, rlen, &fpos);
+		ret = vma->vm_file->f_op->read(vma->vm_file, base, len, &fpos);
 		set_fs(old_fs);
 
 		if (ret < 0)
 			goto error_free;
 
 		/* clear the last little bit */
-		if (ret < rlen)
-			memset(base + ret, 0, rlen - ret);
+		if (ret < len)
+			memset(base + ret, 0, len - ret);
 
 	}
 
@@ -1268,6 +1267,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 
 	/* we ignore the address hint */
 	addr = 0;
+	len = PAGE_ALIGN(len);
 
 	/* we've determined that we can make the mapping, now translate what we
 	 * now know into VMA flags */
@@ -1645,14 +1645,16 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 {
 	struct vm_area_struct *vma;
 	struct rb_node *rb;
-	unsigned long end = start + len;
+	unsigned long end;
 	int ret;
 
 	kenter(",%lx,%zx", start, len);
 
-	if (len == 0)
+	if ((len = PAGE_ALIGN(len)) == 0)
 		return -EINVAL;
 
+	end = start + len;
+
 	/* find the first potentially overlapping VMA */
 	vma = find_vma(mm, start);
 	if (!vma) {
@@ -1773,6 +1775,8 @@ unsigned long do_mremap(unsigned long addr,
 	struct vm_area_struct *vma;
 
 	/* insanity checks first */
+	old_len = PAGE_ALIGN(old_len);
+	new_len = PAGE_ALIGN(new_len);
 	if (old_len == 0 || new_len == 0)
 		return (unsigned long) -EINVAL;
 
-- 
1.6.3.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
