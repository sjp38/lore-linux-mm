Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7MNI7Js025305
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:07 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MNI7iL198690
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 17:18:07 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MNI7RA018596
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 17:18:07 -0600
Subject: [PATCH 2/9] pagemap: remove file header
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 22 Aug 2007 16:18:05 -0700
References: <20070822231804.1132556D@kernel>
In-Reply-To: <20070822231804.1132556D@kernel>
Message-Id: <20070822231805.4A7114A6@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The /proc/<pid>/pagemap file has a header containing:
 * first byte:   0 for big endian, 1 for little
 * second byte:  page shift (eg 12 for 4096 byte pages)
 * third byte:   entry size in bytes (currently either 4 or 8)
 * fourth byte:  header size

The endianness is only useful when examining a raw dump of
pagemap from a different machine when you don't know the
source of the file.  This is pretty rare, and the programs
or scripts doing the copying off-machine can certainly be
made to hold this information.

The page size is available in userspace at least with libc's
getpagesize().  This will also never vary across processes,
so putting it in a per-process file doesn't make any difference.
If we need a "kernel's page size" exported to userspace,
perhaps we can put it in /proc/meminfo.

The entry size is the really tricky one.  This can't just
be sizeof(unsigned long) from userspace because we can have
32-bit processes on 64-bit kernels.  But, userspace can
certainly derive this value if it lseek()s to the end of
the file, and divides the file position by the size of its
virtual address space.

In any case, I believe this information is redundant, and
can be removed.

Acked-by: Matt Mackall <mpm@selenic.com>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/fs/proc/task_mmu.c |   14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff -puN fs/proc/task_mmu.c~pagemap-no-header fs/proc/task_mmu.c
--- lxc/fs/proc/task_mmu.c~pagemap-no-header	2007-08-22 16:16:51.000000000 -0700
+++ lxc-dave/fs/proc/task_mmu.c	2007-08-22 16:16:51.000000000 -0700
@@ -601,12 +601,12 @@ static ssize_t pagemap_read(struct file 
 		goto out;
 
 	ret = -EIO;
-	svpfn = src / sizeof(unsigned long) - 1;
+	svpfn = src / sizeof(unsigned long);
 	addr = PAGE_SIZE * svpfn;
-	if ((svpfn + 1) * sizeof(unsigned long) != src)
+	if (svpfn * sizeof(unsigned long) != src)
 		goto out;
 	evpfn = min((src + count) / sizeof(unsigned long) - 1,
-		    ((~0UL) >> PAGE_SHIFT) + 1) - 1;
+		    ((~0UL) >> PAGE_SHIFT) + 1);
 	count = (evpfn - svpfn) * sizeof(unsigned long);
 	end = PAGE_SIZE * evpfn;
 	//printk("src %ld svpfn %d evpfn %d count %d\n", src, svpfn, evpfn, count);
@@ -638,14 +638,6 @@ static ssize_t pagemap_read(struct file 
 	pm.count = count;
 	pm.out = (unsigned long __user *)buf;
 
-	if (svpfn == -1) {
-		put_user((char)(ntohl(1) != 1), buf);
-		put_user((char)PAGE_SHIFT, buf + 1);
-		put_user((char)sizeof(unsigned long), buf + 2);
-		put_user((char)sizeof(unsigned long), buf + 3);
-		add_to_pagemap(pm.next, page[0], &pm);
-	}
-
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, pm.next);
 	while (pm.count > 0 && vma) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
