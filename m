Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 37E1D6B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 09:59:05 -0400 (EDT)
Received: by qgev79 with SMTP id v79so82657527qge.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 06:59:04 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id o16si3859833qki.9.2015.09.08.06.59.04
        for <linux-mm@kvack.org>;
        Tue, 08 Sep 2015 06:59:04 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH v9 1/6] mm: mlock: Refactor mlock, munlock, and munlockall code
Date: Tue,  8 Sep 2015 09:58:57 -0400
Message-Id: <1441720742-7803-2-git-send-email-emunson@akamai.com>
In-Reply-To: <1441720742-7803-1-git-send-email-emunson@akamai.com>
References: <1441720742-7803-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Extending the mlock system call is very difficult because it currently
does not take a flags argument.  A later patch in this set will extend
mlock to support a middle ground between pages that are locked and
faulted in immediately and unlocked pages.  To pave the way for the new
system call, the code needs some reorganization so that all the actual
entry point handles is checking input and translating to VMA flags.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/mlock.c | 30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 25936680..c32ad8f 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -554,7 +554,8 @@ out:
 	return ret;
 }
 
-static int do_mlock(unsigned long start, size_t len, int on)
+static int apply_vma_lock_flags(unsigned long start, size_t len,
+				vm_flags_t flags)
 {
 	unsigned long nstart, end, tmp;
 	struct vm_area_struct * vma, * prev;
@@ -576,14 +577,11 @@ static int do_mlock(unsigned long start, size_t len, int on)
 		prev = vma;
 
 	for (nstart = start ; ; ) {
-		vm_flags_t newflags;
-
-		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
+		vm_flags_t newflags = vma->vm_flags & ~VM_LOCKED;
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
-		if (on)
-			newflags |= VM_LOCKED;
+		newflags |= flags;
 
+		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 		tmp = vma->vm_end;
 		if (tmp > end)
 			tmp = end;
@@ -605,7 +603,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
-SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
+static int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 {
 	unsigned long locked;
 	unsigned long lock_limit;
@@ -629,7 +627,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
-		error = do_mlock(start, len, 1);
+		error = apply_vma_lock_flags(start, len, flags);
 
 	up_write(&current->mm->mmap_sem);
 	if (error)
@@ -641,6 +639,11 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	return 0;
 }
 
+SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
+{
+	return do_mlock(start, len, VM_LOCKED);
+}
+
 SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
@@ -649,13 +652,13 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 	start &= PAGE_MASK;
 
 	down_write(&current->mm->mmap_sem);
-	ret = do_mlock(start, len, 0);
+	ret = apply_vma_lock_flags(start, len, 0);
 	up_write(&current->mm->mmap_sem);
 
 	return ret;
 }
 
-static int do_mlockall(int flags)
+static int apply_mlockall_flags(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
 
@@ -663,6 +666,7 @@ static int do_mlockall(int flags)
 		current->mm->def_flags |= VM_LOCKED;
 	else
 		current->mm->def_flags &= ~VM_LOCKED;
+
 	if (flags == MCL_FUTURE)
 		goto out;
 
@@ -704,7 +708,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
-		ret = do_mlockall(flags);
+		ret = apply_mlockall_flags(flags);
 	up_write(&current->mm->mmap_sem);
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
@@ -717,7 +721,7 @@ SYSCALL_DEFINE0(munlockall)
 	int ret;
 
 	down_write(&current->mm->mmap_sem);
-	ret = do_mlockall(0);
+	ret = apply_mlockall_flags(0);
 	up_write(&current->mm->mmap_sem);
 	return ret;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
