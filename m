Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A20B6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 06:27:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g202so351701599pfb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 03:27:09 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g20si18638428pfg.127.2016.09.12.03.27.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 03:27:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RESEND] ipc/shm: fix crash if CONFIG_SHMEM is not set
Date: Mon, 12 Sep 2016 13:27:04 +0300
Message-Id: <20160912102704.140442-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Commit c01d5b300774 makes use of shm_get_unmapped_area() in
shm_file_operations() unconditional to CONFIG_MMU.

As Tony Battersby pointed this can lead NULL-pointer dereference on
machine with CONFIG_MMU=y and CONFIG_SHMEM=n. In this case ipc/shm is
backed by ramfs which doesn't provide f_op->get_unmapped_area for
configurations with MMU.

The solution is to provide dummy f_op->get_unmapped_area for ramfs when
CONFIG_MMU=y, which just call current->mm->get_unmapped_area().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-and-Tested-by: Tony Battersby <tonyb@cybernetics.com>
Fixes: c01d5b300774 ("shmem: get_unmapped_area align huge page")
---
 fs/ramfs/file-mmu.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/ramfs/file-mmu.c b/fs/ramfs/file-mmu.c
index 183a212694bf..12af0490322f 100644
--- a/fs/ramfs/file-mmu.c
+++ b/fs/ramfs/file-mmu.c
@@ -27,9 +27,17 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/ramfs.h>
+#include <linux/sched.h>
 
 #include "internal.h"
 
+static unsigned long ramfs_mmu_get_unmapped_area(struct file *file,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags)
+{
+	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+}
+
 const struct file_operations ramfs_file_operations = {
 	.read_iter	= generic_file_read_iter,
 	.write_iter	= generic_file_write_iter,
@@ -38,6 +46,7 @@ const struct file_operations ramfs_file_operations = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.llseek		= generic_file_llseek,
+	.get_unmapped_area	= ramfs_mmu_get_unmapped_area,
 };
 
 const struct inode_operations ramfs_file_inode_operations = {
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
