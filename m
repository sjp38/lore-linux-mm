Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E203F6B0078
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 05:38:34 -0500 (EST)
Message-ID: <4B90DF01.7070107@tensilica.com>
Date: Fri, 5 Mar 2010 02:37:53 -0800
From: Piet Delaney <pdelaney@tensilica.com>
MIME-Version: 1.0
Subject: Conceptual difference  between VM_CAN_NONLINEAR and VM_NONLINEAR
 ; path by which VM_NONLINEAR is suppose to be set.
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Piet Delaney <Piet.Delaney@tensilica.com>
Cc: piet delaney <piet.delaney@gmail.com>
List-ID: <linux-mm.kvack.org>

I'm getting a PANIC while working with mmap'd files due to the
VM_NONLINEAR not being set when working with the pte's. I looked quite
a few places and haven't found a clear explanation of how VM_NONLINEAR
differs conceptually from VM_CAN_NONLINEAR. It looks like VM_CAN_NONLINEAR
is suppose to be set earlier and VM_NONLINEAR later when something in
particular is done. I see it set via the remap_file_pages() system call
but not by mmap() via shmem_mmap().

Our open_posix_testsuite/conformance/interfaces/mmap/6-2.test panic is
avoided with by setting VM_NONLINEAR when the file is mapped but I really
doubt this is appropriate as the test runs fine on i386.
------------------------------------------------------------------------
static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
{
          file_accessed(file);
          vma->vm_ops = &shmem_vm_ops;
#if 1
	/* Wrong but didn't panic */
          vma->vm_flags |= (VM_CAN_NONLINEAR|VM_NONLINEAR);
#else
	/* Right but panics here via LTP posix mmap/6-2.test */
          vma->vm_flags |= VM_CAN_NONLINEAR;
#endif
          return 0;
}
-------------------------------------------------------------------------

I was hopping this hack would panic the system and that would help explain
why this approach is wrong, but unfortunately it worked.

Could someone take a minute and explain the conceptual difference of
these two vma flags and the path by which the VM_NONLINEAR flag is
suppose to be set.

-piet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
