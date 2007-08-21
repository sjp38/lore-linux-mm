Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LKh93V022562
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:43:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LKgsrC558486
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:43:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LKgsNX009008
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:42:54 -0400
Subject: [RFC][PATCH 4/9] pagemap: remove open-coded sizeof(unsigned long)
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 21 Aug 2007 13:42:51 -0700
References: <20070821204248.0F506A29@kernel>
In-Reply-To: <20070821204248.0F506A29@kernel>
Message-Id: <20070821204251.67EF9E06@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I think the code gets easier to read when we give symbolic names
to some of the operations we're performing.  I was sure we needed
this when I saw the header being built like this:

	...
	buf[2] = sizeof(unsigned long)
	buf[3] = sizeof(unsigned long)

I really couldn't remember what either field did ;(

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/fs/proc/task_mmu.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff -puN fs/proc/task_mmu.c~pagemap-use-ENTRY_SIZE fs/proc/task_mmu.c
--- lxc/fs/proc/task_mmu.c~pagemap-use-ENTRY_SIZE	2007-08-21 13:30:51.000000000 -0700
+++ lxc-dave/fs/proc/task_mmu.c	2007-08-21 13:30:51.000000000 -0700
@@ -508,14 +508,16 @@ struct pagemapread {
 	unsigned long __user *out;
 };
 
+#define PM_ENTRY_BYTES sizeof(unsigned long)
+
 static int add_to_pagemap(unsigned long addr, unsigned long pfn,
 			  struct pagemapread *pm)
 {
 	__put_user(pfn, pm->out);
 	pm->out++;
-	pm->pos += sizeof(unsigned long);
-	pm->count -= sizeof(unsigned long);
 	pm->next = addr + PAGE_SIZE;
+	pm->pos += PM_ENTRY_BYTES;
+	pm->count -= PM_ENTRY_BYTES;
 	return 0;
 }
 
@@ -601,13 +603,13 @@ static ssize_t pagemap_read(struct file 
 		goto out;
 
 	ret = -EIO;
-	svpfn = src / sizeof(unsigned long);
+	svpfn = src / PM_ENTRY_BYTES;
 	addr = PAGE_SIZE * svpfn;
-	if (svpfn * sizeof(unsigned long) != src)
+	if (svpfn * PM_ENTRY_BYTES != src)
 		goto out;
 	evpfn = min((src + count) / sizeof(unsigned long) - 1,
 		    ((~0UL) >> PAGE_SHIFT) + 1);
-	count = (evpfn - svpfn) * sizeof(unsigned long);
+	count = (evpfn - svpfn) * PM_ENTRY_BYTES;
 	end = PAGE_SIZE * evpfn;
 	//printk("src %ld svpfn %d evpfn %d count %d\n", src, svpfn, evpfn, count);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
