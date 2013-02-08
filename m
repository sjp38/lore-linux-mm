Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 0FAFF6B0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 15:28:26 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 8 Feb 2013 13:28:26 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 3482D3E4003F
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 13:28:09 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r18KSGk7254360
	for <linux-mm@kvack.org>; Fri, 8 Feb 2013 13:28:16 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r18KSFmQ009506
	for <linux-mm@kvack.org>; Fri, 8 Feb 2013 13:28:15 -0700
Subject: [PATCH 2/2] make /dev/kmem return error for highmem
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 08 Feb 2013 12:28:14 -0800
References: <20130208202813.62965F25@kernel.stglabs.ibm.com>
In-Reply-To: <20130208202813.62965F25@kernel.stglabs.ibm.com>
Message-Id: <20130208202814.E1196596@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, bp@alien8.de, hpa@zytor.com, mingo@kernel.org, tglx@linutronix.de, Dave Hansen <dave@linux.vnet.ibm.com>


I was auding the /dev/mem code for more questionable uses of
__pa(), and ran across this.

My assumption is that if you use /dev/kmem, you expect to be
able to read the kernel virtual mappings.  However, those
mappings _stop_ as soon as we hit high memory.  The
pfn_valid() check in here is good for memory holes, but since
highmem pages are still valid, it does no good for those.

Also, since we are now checking that __pa() is being done on
valid virtual addresses, this might have tripped the new
check.  Even with the new check, this code would have been
broken with the NUMA remapping code had we not ripped it
out:

	https://patchwork.kernel.org/patch/2075911/

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/drivers/char/mem.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff -puN drivers/char/mem.c~make-kmem-return-error-for-highmem drivers/char/mem.c
--- linux-2.6.git/drivers/char/mem.c~make-kmem-return-error-for-highmem	2013-02-08 12:27:57.033770045 -0800
+++ linux-2.6.git-dave/drivers/char/mem.c	2013-02-08 12:27:57.041770125 -0800
@@ -337,10 +337,19 @@ static int mmap_mem(struct file *file, s
 #ifdef CONFIG_DEVKMEM
 static int mmap_kmem(struct file *file, struct vm_area_struct *vma)
 {
+	unsigned long kernel_vaddr;
 	unsigned long pfn;
 
+	kernel_vaddr = (u64)vma->vm_pgoff << PAGE_SHIFT;
+	/*
+	 * pfn_valid() (below) does not trip for highmem addresses.  This
+	 * essentially means that we will be mapping gibberish in for them
+	 * instead of what the _kernel_ has mapped at the requested address.
+	 */
+	if (kernel_vaddr >= high_memory)
+		return -EIO;
 	/* Turn a kernel-virtual address into a physical page frame */
-	pfn = __pa((u64)vma->vm_pgoff << PAGE_SHIFT) >> PAGE_SHIFT;
+	pfn = __pa(kernel_vaddr) >> PAGE_SHIFT;
 
 	/*
 	 * RED-PEN: on some architectures there is more mapped memory than
diff -puN mm/nommu.c~make-kmem-return-error-for-highmem mm/nommu.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
