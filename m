Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1K5Hd3F016568
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 00:17:39 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1K5Hs5B116410
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 22:17:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1K5Hr3d025392
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 22:17:54 -0700
Subject: [PATCH] -mm: fix nommu path broken by procfs task exe symlink
From: Matt Helsley <matthltc@us.ibm.com>
Content-Type: text/plain
Date: Tue, 19 Feb 2008 21:17:49 -0800
Message-Id: <1203484669.7408.102.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, David Howells <dhowells@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Christoph Hellwig <chellwig@de.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Bryan Wu <Bryan.Wu@analog.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

nommu configurations will not compile because the "mm" variable does not
exist. Replace usage of the mm variable and the empty vma->vm_mm field
with correct mm pointers.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Mike Frysinger <vapier.adi@gmail.com>
---
Needs testing on a nommu system. I am working on getting an emulated nommu
environment built but it is not coming together quickly.

 mm/nommu.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

Index: linux-2.6.24-mm1/mm/nommu.c
===================================================================
--- linux-2.6.24-mm1.orig/mm/nommu.c
+++ linux-2.6.24-mm1/mm/nommu.c
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
