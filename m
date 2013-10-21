Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36E296B0364
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:49:43 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id wz7so2927604pbc.38
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:49:42 -0700 (PDT)
Received: from psmtp.com ([74.125.245.164])
        by mx.google.com with SMTP id ph6si9643853pbb.187.2013.10.21.14.49.41
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:49:42 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so7280570pdj.20
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:49:40 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:49:36 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCHv2 13/13] mm, thp, tmpfs: misc fixes for thp tmpfs
Message-ID: <20131021214936.GN29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

1) get rid of the actor function pointer in shm as what Kirill did in generic
file operations.

2) add kernel command line option to turn on/off the thp page cache support.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/huge_memory.c | 27 +++++++++++++++++++++++++++
 mm/shmem.c       |  7 ++++---
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d36bdac..ea79a70 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -711,6 +711,33 @@ out:
 }
 __setup("transparent_hugepage=", setup_transparent_hugepage);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+static int __init setup_transparent_hugepage_pagecache(char *str)
+{
+	int ret = 0;
+	if (!str)
+		goto out;
+	if (!strcmp(str, "on")) {
+		set_bit(TRANSPARENT_HUGEPAGE_PAGECACHE,
+			&transparent_hugepage_flags);
+		ret = 1;
+	} else if (!strcmp(str, "off")) {
+		clear_bit(TRANSPARENT_HUGEPAGE_PAGECACHE,
+			  &transparent_hugepage_flags);
+		ret = 1;
+	}
+out:
+	if (!ret)
+		printk(KERN_WARNING
+			"transparent_hugepage_pagecache= cannot parse, "
+			"ignored\n");
+	return ret;
+}
+
+__setup("transparent_hugepage_pagecache=",
+	setup_transparent_hugepage_pagecache);
+#endif
+
 pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 {
 	if (likely(vma->vm_flags & VM_WRITE))
diff --git a/mm/shmem.c b/mm/shmem.c
index 391c4eb..77dd90b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1765,7 +1765,8 @@ static unsigned long pos_to_off(struct page *page, loff_t pos)
 	return pos & ~page_cache_to_mask(page);
 }
 
-static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_t *desc, read_actor_t actor)
+static void do_shmem_file_read(struct file *filp, loff_t *ppos,
+				read_descriptor_t *desc)
 {
 	struct inode *inode = file_inode(filp);
 	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
@@ -1862,7 +1863,7 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
-		ret = actor(desc, page, pos_to_off(page, *ppos), nr);
+		ret = file_read_actor(desc, page, pos_to_off(page, *ppos), nr);
 		*ppos += ret;
 		index = *ppos >> PAGE_CACHE_SHIFT;
 
@@ -1899,7 +1900,7 @@ static ssize_t shmem_file_aio_read(struct kiocb *iocb,
 		if (desc.count == 0)
 			continue;
 		desc.error = 0;
-		do_shmem_file_read(filp, ppos, &desc, file_read_actor);
+		do_shmem_file_read(filp, ppos, &desc);
 		retval += desc.written;
 		if (desc.error) {
 			retval = retval ?: desc.error;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
