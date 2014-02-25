Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 249796B0108
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:19:26 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rr13so3598347pbb.15
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 06:19:25 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ap6si20675461pad.258.2014.02.25.06.19.24
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 06:19:25 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v6 22/22] dax: Add reporting of major faults
Date: Tue, 25 Feb 2014 09:18:38 -0500
Message-Id: <1393337918-28265-23-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

If we have to call get_block with the create argument set to 1, then
the filesystem almost certainly had to zero the block. which is an I/O,
which should be reported as a major fault.

Note that major faults on DAX files happen for different reasons than
major faults on non-DAX files.  DAX files behave as if everything except
file holes is already cached.  That's all the more reason to report
major faults when we do have to do I/O; it may be a valuable resource
for sysadmins trying to diagnose performance problems.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/dax.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index cdc8012..79a67c5 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -20,10 +20,12 @@
 #include <linux/fs.h>
 #include <linux/genhd.h>
 #include <linux/highmem.h>
+#include <linux/memcontrol.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
 #include <linux/sched.h>
 #include <linux/uio.h>
+#include <linux/vmstat.h>
 
 int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 {
@@ -286,6 +288,7 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	pgoff_t size;
 	unsigned long pfn;
 	int error;
+	int major = 0;
 
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
@@ -301,6 +304,9 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (!buffer_written(&bh) && !vmf->cow_page) {
 		if (vmf->flags & FAULT_FLAG_WRITE) {
 			error = get_block(inode, block, &bh, 1);
+			count_vm_event(PGMAJFAULT);
+			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+			major = VM_FAULT_MAJOR;
 			if (error || bh.b_size < PAGE_SIZE)
 				return VM_FAULT_SIGBUS;
 		} else {
@@ -332,7 +338,7 @@ static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	/* -EBUSY is fine, somebody else faulted on the same PTE */
 	if (error != -EBUSY)
 		BUG_ON(error);
-	return VM_FAULT_NOPAGE;
+	return VM_FAULT_NOPAGE | major;
 }
 
 /**
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
