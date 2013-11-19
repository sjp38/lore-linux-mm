Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 330666B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 11:30:29 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so5347709pdi.38
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 08:30:28 -0800 (PST)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id sj5si12013715pab.284.2013.11.19.08.30.27
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 08:30:27 -0800 (PST)
From: James Custer <jcuster@sgi.com>
Subject: [PATCH] Reimplement old functionality of vm_munmap to vm_munmap_mm
Date: Tue, 19 Nov 2013 10:29:52 -0600
Message-Id: <1384878592-194909-1-git-send-email-jcuster@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jiang Liu <jiang.liu@huawei.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, James Custer <jcuster@sgi.com>

Commit bfce281c287a427d0841fadf5d59242757b4e620 killed the mm parameter to
vm_munmap. Although the mm parameter was not used in any in-tree kernel
modules, it is used by some out-of-tree modules.

We create a new function vm_munmap_mm that has the same functionality as
vm_munmap, whereas vm_munmap uses current->mm, vm_munmap_mm takes the mm as
a paramter.

Since this is a newly exported symbol it is marked EXPORT_SYMBOL_GPL.
---
 include/linux/mm.h | 1 +
 mm/mmap.c          | 9 +++++++--
 mm/nommu.c         | 9 +++++++--
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0548eb2..6e9917e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1724,6 +1724,7 @@ static inline void mm_populate(unsigned long addr, unsigned long len) {}
 /* These take the mm semaphore themselves */
 extern unsigned long vm_brk(unsigned long, unsigned long);
 extern int vm_munmap(unsigned long, size_t);
+extern int vm_munmap_mm(struct mm_struct *, unsigned long, size_t);
 extern unsigned long vm_mmap(struct file *, unsigned long,
         unsigned long, unsigned long,
         unsigned long, unsigned long);
diff --git a/mm/mmap.c b/mm/mmap.c
index 834b2d7..63eb96e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2539,16 +2539,21 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	return 0;
 }
 
-int vm_munmap(unsigned long start, size_t len)
+int vm_munmap_mm(struct mm_struct *mm, unsigned long start, size_t len)
 {
 	int ret;
-	struct mm_struct *mm = current->mm;
 
 	down_write(&mm->mmap_sem);
 	ret = do_munmap(mm, start, len);
 	up_write(&mm->mmap_sem);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(vm_munmap_mm);
+
+int vm_munmap(unsigned long start, size_t len)
+{
+	return vm_munmap_mm(current->mm, start, len);
+}
 EXPORT_SYMBOL(vm_munmap);
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
diff --git a/mm/nommu.c b/mm/nommu.c
index fec093a..5cf8677 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1717,9 +1717,8 @@ erase_whole_vma:
 }
 EXPORT_SYMBOL(do_munmap);
 
-int vm_munmap(unsigned long addr, size_t len)
+int vm_munmap_mm(struct mm_struct *mm, unsigned long addr, size_t len)
 {
-	struct mm_struct *mm = current->mm;
 	int ret;
 
 	down_write(&mm->mmap_sem);
@@ -1727,6 +1726,12 @@ int vm_munmap(unsigned long addr, size_t len)
 	up_write(&mm->mmap_sem);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(vm_munmap_mm);
+
+int vm_munmap(unsigned long addr, size_t len)
+{
+	return vm_munmap_mm(current->mm, addr, len);
+}
 EXPORT_SYMBOL(vm_munmap);
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
