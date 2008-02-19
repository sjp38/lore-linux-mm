Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1JLuOjv027629
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 16:56:24 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1JLsSQr227584
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 16:54:28 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1JLsRVc005123
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 16:54:28 -0500
Subject: Re: [PATCH] procfs task exe symlink
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <8bd0f97a0802160412ve49103cya446b89d8560458b@mail.gmail.com>
References: <1202348669.9062.271.camel@localhost.localdomain>
	 <8bd0f97a0802160412ve49103cya446b89d8560458b@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 19 Feb 2008 13:54:25 -0800
Message-Id: <1203458065.7408.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, David Howells <dhowells@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Christoph Hellwig <chellwig@de.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Bryan Wu <Bryan.Wu@analog.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-02-16 at 07:12 -0500, Mike Frysinger wrote:
> On Feb 6, 2008 8:44 PM, Matt Helsley <matthltc@us.ibm.com> wrote:
> > The kernel implements readlink of /proc/pid/exe by getting the file from the
> > first executable VMA. Then the path to the file is reconstructed and reported as
> > the result.
> >
> > Because of the VMA walk the code is slightly different on nommu systems. This
> > patch avoids separate /proc/pid/exe code on nommu systems. Instead of walking
> > the VMAs to find the first executable file-backed VMA we store a reference to
> > the exec'd file in the mm_struct.
> >
> > That reference would prevent the filesystem holding the executable file from
> > being unmounted even after unmapping the VMAs. So we track the number of
> > VM_EXECUTABLE VMAs and drop the new reference when the last one is unmapped.
> > This avoids pinning the mounted filesystem.
> >
> > Andrew, these are the updates I promised. Please consider this patch for
> > inclusion in -mm.
> 
> mm/nommu.c wasnt compiled tested, it's trivially broken:

Thanks for the report. I've looked into this and the "obvious" fix,
using vma->vm_mm, isn't correct since it's never set. This means the
portions of the procfs task exe symlink patch using vma->vm_mm in
mm/nommu.c are incorrect.

The patch below attempts to fix this by using current->mm during mmap
and passing the current mm to put_vma() as well.

Mike, does this patch fix the compile problem(s)?

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>

---
Mike, I don't have a nommu compile or test environment. I have yet
to to generate a good CONFIG_MMU=n config on i386 (got one?). Since I
don't have any nommu hardware I'm also looking into using qemu. It looks
like I may need to build my own image from scratch. Do you have any
recommendations on testing nommu configs without hardware?

 mm/nommu.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

Index: linux-2.6.24/mm/nommu.c
===================================================================
--- linux-2.6.24.orig/mm/nommu.c
+++ linux-2.6.24/mm/nommu.c
@@ -962,12 +962,14 @@ unsigned long do_mmap_pgoff(struct file 
 
 	INIT_LIST_HEAD(&vma->anon_vma_node);
 	atomic_set(&vma->vm_usage, 1);
 	if (file) {
 		get_file(file);
-		if (vm_flags & VM_EXECUTABLE)
-			added_exe_file_vma(mm);
+		if (vm_flags & VM_EXECUTABLE) {
+			added_exe_file_vma(current->mm);
+			vma->vm_mm = current->mm;
+		}
 	}
 	vma->vm_file	= file;
 	vma->vm_flags	= vm_flags;
 	vma->vm_start	= addr;
 	vma->vm_end	= addr + len;
@@ -1053,11 +1055,11 @@ unsigned long do_mmap_pgoff(struct file 
 EXPORT_SYMBOL(do_mmap_pgoff);
 
 /*
  * handle mapping disposal for uClinux
  */
-static void put_vma(struct vm_area_struct *vma)
+static void put_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 {
 	if (vma) {
 		down_write(&nommu_vma_sem);
 
 		if (atomic_dec_and_test(&vma->vm_usage)) {
@@ -1078,11 +1080,11 @@ static void put_vma(struct vm_area_struc
 			askedalloc -= sizeof(*vma);
 
 			if (vma->vm_file) {
 				fput(vma->vm_file);
 				if (vma->vm_flags & VM_EXECUTABLE)
-					removed_exe_file_vma(vma->vm_mm);
+					removed_exe_file_vma(mm);
 			}
 			kfree(vma);
 		}
 
 		up_write(&nommu_vma_sem);
@@ -1116,11 +1118,11 @@ int do_munmap(struct mm_struct *mm, unsi
 	return -EINVAL;
 
  found:
 	vml = *parent;
 
-	put_vma(vml->vma);
+	put_vma(mm, vml->vma);
 
 	*parent = vml->next;
 	realalloc -= kobjsize(vml);
 	askedalloc -= sizeof(*vml);
 	kfree(vml);
@@ -1161,11 +1163,11 @@ void exit_mmap(struct mm_struct * mm)
 
 		mm->total_vm = 0;
 
 		while ((tmp = mm->context.vmlist)) {
 			mm->context.vmlist = tmp->next;
-			put_vma(tmp->vma);
+			put_vma(mm, tmp->vma);
 
 			realalloc -= kobjsize(tmp);
 			askedalloc -= sizeof(*tmp);
 			kfree(tmp);
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
