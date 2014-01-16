Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4854D6B0069
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:12 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so1872013pde.41
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:11 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ek3si5327793pbd.145.2014.01.15.17.25.10
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:10 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 21/22] xip: Add reporting of major faults
Date: Wed, 15 Jan 2014 20:24:39 -0500
Message-Id: <256d3855b43f76f5f26bb65c816955978561ffe2.1389779962.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

If we have to call get_block with the create argument set to 1, then
the filesystem almost certainly had to zero the block. which is an I/O,
which should be reported as a major fault.

Note that major faults on XIP files happen for different reasons than
major faults on non-XIP files.  XIP files behave as if everything except
file holes is already cached.  That's all the more reason to report
major faults when we do have to do I/O; it may be a valuable resource
for sysadmins trying to diagnose performance problems.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/xip.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/xip.c b/fs/xip.c
index 9087e0f..88a516b 100644
--- a/fs/xip.c
+++ b/fs/xip.c
@@ -19,10 +19,12 @@
 #include <linux/fs.h>
 #include <linux/genhd.h>
 #include <linux/highmem.h>
+#include <linux/memcontrol.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
 #include <linux/sched.h>
 #include <linux/uio.h>
+#include <linux/vmstat.h>
 
 int xip_clear_blocks(struct inode *inode, sector_t block, long size)
 {
@@ -250,6 +252,7 @@ static int do_xip_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	pgoff_t size;
 	unsigned long pfn;
 	int error;
+	int major = 0;
 
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
@@ -265,6 +268,9 @@ static int do_xip_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (!buffer_mapped(&bh) && !vmf->cow_page) {
 		if (vmf->flags & FAULT_FLAG_WRITE) {
 			error = get_block(inode, block, &bh, 1);
+			count_vm_event(PGMAJFAULT);
+			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+			major = VM_FAULT_MAJOR;
 			if (error || bh.b_size < PAGE_SIZE)
 				return VM_FAULT_SIGBUS;
 		} else {
@@ -296,7 +302,7 @@ static int do_xip_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	/* -EBUSY is fine, somebody else faulted on the same PTE */
 	if (error != -EBUSY)
 		BUG_ON(error);
-	return VM_FAULT_NOPAGE;
+	return VM_FAULT_NOPAGE | major;
 }
 
 /**
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
