Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CC1226B0035
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 19:04:28 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so4165789pad.3
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 16:04:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id p2si2449133pbn.175.2014.03.27.16.04.27
        for <linux-mm@kvack.org>;
        Thu, 27 Mar 2014 16:04:27 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH] Sync only the requested range in msync
Date: Thu, 27 Mar 2014 19:02:41 -0400
Message-Id: <1395961361-21307-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

[untested.  posted because it keeps coming up at lsfmm/collab]

msync() currently syncs more than POSIX requires or BSD or Solaris
implement.  It is supposed to be equivalent to fdatasync(), not fsync(),
and it is only supposed to sync the portion of the file that overlaps
the range passed to msync.

If the VMA is non-linear, fall back to syncing the entire file, but we
still optimise to only fdatasync() the entire file, not the full fsync().

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 mm/msync.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/msync.c b/mm/msync.c
index 632df45..a5c6736 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -58,6 +58,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	vma = find_vma(mm, start);
 	for (;;) {
 		struct file *file;
+		loff_t fstart, fend;
 
 		/* Still start < end. */
 		error = -ENOMEM;
@@ -77,12 +78,17 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 			goto out_unlock;
 		}
 		file = vma->vm_file;
+		fstart = start + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
+		fend = fstart + (min(end, vma->vm_end) - start) - 1;
 		start = vma->vm_end;
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
 			up_read(&mm->mmap_sem);
-			error = vfs_fsync(file, 0);
+			if (vma->vm_flags & VM_NONLINEAR)
+				error = vfs_fsync(file, 1);
+			else
+				error = vfs_fsync_range(file, fstart, fend, 1);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
