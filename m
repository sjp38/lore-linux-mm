Subject: [PATCH] Fix for vma merging refcounting bug
From: "Stephen C. Tweedie" <sct@redhat.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1052483661.3642.16.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Date: 09 May 2003 13:34:21 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Stephen Tweedie <sct@redhat.com>, Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

When a new vma can be merged simultaneously with its two immediate
neighbours in both directions, vma_merge() extends the predecessor vma
and deletes the successor.  However, if the vma maps a file, it fails to
fput() when doing the delete, leaving the file's refcount inconsistent.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1083  -> 1.1084 
#	           mm/mmap.c	1.79    -> 1.80   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/09	sct@sisko.scot.redhat.com	1.1084
# Fix vma merging problem leading to file refcount getting out of sync.
# --------------------------------------------
#
diff -Nru a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c	Fri May  9 13:26:53 2003
+++ b/mm/mmap.c	Fri May  9 13:26:53 2003
@@ -471,6 +471,8 @@
 			spin_unlock(lock);
 			if (need_up)
 				up(&inode->i_mapping->i_shared_sem);
+			if (file)
+				fput(file);
 
 			mm->map_count--;
 			kmem_cache_free(vm_area_cachep, next);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
