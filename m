Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j666qBOU014572
	for <linux-mm@kvack.org>; Wed, 6 Jul 2005 02:52:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j666qAL3158748
	for <linux-mm@kvack.org>; Wed, 6 Jul 2005 02:52:10 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j666qArI029236
	for <linux-mm@kvack.org>; Wed, 6 Jul 2005 02:52:10 -0400
Received: from [9.182.14.122] ([9.182.14.122])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j666q8bJ029196
	for <linux-mm@kvack.org>; Wed, 6 Jul 2005 02:52:09 -0400
Message-ID: <42CB812E.8060605@in.ibm.com>
Date: Wed, 06 Jul 2005 12:28:54 +0530
From: suzuki <suzuki@in.ibm.com>
MIME-Version: 1.0
Subject: [RFC] [PATCH] madvise() does not always return -EBADF on non-file
 mapped area
Content-Type: multipart/mixed;
 boundary="------------000001090701010901090407"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000001090701010901090407
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit

hi,

I came across the following problem. The madvise() system call returns 
-EBADF for areas which does not map to files, only for *behaviour* 
request MADV_WILLNEED.

Is this the intended behaviour of madvise() ?

According to man pages, madvise returns :

EBADF - the map exists, but the area maps something that isn?t a file.

I have attached a patch which could resolve the issue.

[ There is already a bug reported in OSDL regarding this issue: Bug # 
2995 ].


-- 
regards,

Suzuki K P
Linux Technology Centre
IBM Software Labs


--------------000001090701010901090407
Content-Type: text/plain;
 name="madvise-ebadf-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="madvise-ebadf-fix.patch"

Patch to fix madvise() syscall to return -EBADF on non-file mapped regions.

Signed Off by: Suzuki K P <suzuki@in.ibm.com>

--- mm/madvise.c	2005-07-01 16:08:26.000000000 +0530
+++ mm/madvise.c.new	2005-07-01 16:07:45.000000000 +0530
@@ -62,9 +62,6 @@ static long madvise_willneed(struct vm_a
 {
 	struct file *file = vma->vm_file;
 
-	if (!file)
-		return -EBADF;
-
 	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 	if (end > vma->vm_end)
 		end = vma->vm_end;
@@ -114,8 +111,12 @@ static long madvise_dontneed(struct vm_a
 static long madvise_vma(struct vm_area_struct * vma, unsigned long start,
 			unsigned long end, int behavior)
 {
+	struct file* filp = vma->vm_file;
 	long error = -EBADF;
 
+	if(!filp)
+		goto  out;
+
 	switch (behavior) {
 	case MADV_NORMAL:
 	case MADV_SEQUENTIAL:
@@ -136,6 +137,7 @@ static long madvise_vma(struct vm_area_s
 		break;
 	}
 		
+out:	
 	return error;
 }
 

--------------000001090701010901090407--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
