Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j31JrEhR012362
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 14:53:14 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j31JrAZo080020
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 14:53:14 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j31JrAj4031174
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 14:53:10 -0500
Subject: [RFC][PATCH] make all non-file-backed madvise() calls fail
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-k4+DCbLhIqxhRSHCN05P"
Date: Fri, 01 Apr 2005 11:43:00 -0800
Message-Id: <1112384580.12201.30.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-k4+DCbLhIqxhRSHCN05P
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This is related to this bug:
http://bugme.osdl.org/show_bug.cgi?id=2995

The kernel currently only checks that the memory is file-backed if
MADV_WILLNEED is set.  It's not entirely clear from the manpage at least
that *all* non-file-backed madvise() calls should fail.  

The attached patch returns -EBADF for all non-file-backed madvise()
calls.  I'm not suggesting that this is the absolutely right behavior,
but it certainly does what the bug submitter wants.

Comments?

-- Dave

--=-k4+DCbLhIqxhRSHCN05P
Content-Disposition: attachment; filename=madvise-allebadf.patch
Content-Type: text/x-patch; name=madvise-allebadf.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

--- mm/madvise.c.orig	2005-04-01 10:40:59.000000000 -0800
+++ mm/madvise.c	2005-04-01 10:56:50.000000000 -0800
@@ -58,13 +58,9 @@
  * Schedule all required I/O operations.  Do not wait for completion.
  */
 static long madvise_willneed(struct vm_area_struct * vma,
-			     unsigned long start, unsigned long end)
+			     unsigned long start, unsigned long end,
+			     struct file *file)
 {
-	struct file *file = vma->vm_file;
-
-	if (!file)
-		return -EBADF;
-
 	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 	if (end > vma->vm_end)
 		end = vma->vm_end;
@@ -115,6 +111,10 @@
 			unsigned long end, int behavior)
 {
 	long error = -EBADF;
+	struct file *file = vma->vm_file;
+
+	if (!file)
+		goto out;
 
 	switch (behavior) {
 	case MADV_NORMAL:
@@ -124,7 +124,7 @@
 		break;
 
 	case MADV_WILLNEED:
-		error = madvise_willneed(vma, start, end);
+		error = madvise_willneed(vma, start, end, file);
 		break;
 
 	case MADV_DONTNEED:
@@ -136,6 +136,7 @@
 		break;
 	}
 		
+out:
 	return error;
 }
 

--=-k4+DCbLhIqxhRSHCN05P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
