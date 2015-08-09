Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1F85D9003C8
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 01:23:08 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so49320692qkd.3
        for <linux-mm@kvack.org>; Sat, 08 Aug 2015 22:23:07 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id u77si27485415qge.46.2015.08.08.22.22.59
        for <linux-mm@kvack.org>;
        Sat, 08 Aug 2015 22:22:59 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH v7 1/6] mm: mlock: Refactor mlock, munlock, and munlockall code
Date: Sun,  9 Aug 2015 01:22:51 -0400
Message-Id: <1439097776-27695-2-git-send-email-emunson@akamai.com>
In-Reply-To: <1439097776-27695-1-git-send-email-emunson@akamai.com>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
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
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/mlock.c | 30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 6fd2cf1..5692ee5 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -553,7 +553,8 @@ out:
 	return ret;
 }
 
-static int do_mlock(unsigned long start, size_t len, int on)
+static int apply_vma_lock_flags(unsigned long start, size_t len,
+				vm_flags_t flags)
 {
 	unsigned long nstart, end, tmp;
 	struct vm_area_struct * vma, * prev;
@@ -575,14 +576,11 @@ static int do_mlock(unsigned long start, size_t len, int on)
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
@@ -604,7 +602,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
-SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
+static int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 {
 	unsigned long locked;
 	unsigned long lock_limit;
@@ -628,7 +626,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
-		error = do_mlock(start, len, 1);
+		error = apply_vma_lock_flags(start, len, flags);
 
 	up_write(&current->mm->mmap_sem);
 	if (error)
@@ -640,6 +638,11 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
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
@@ -648,13 +651,13 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
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
 
@@ -662,6 +665,7 @@ static int do_mlockall(int flags)
 		current->mm->def_flags |= VM_LOCKED;
 	else
 		current->mm->def_flags &= ~VM_LOCKED;
+
 	if (flags == MCL_FUTURE)
 		goto out;
 
@@ -703,7 +707,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
-		ret = do_mlockall(flags);
+		ret = apply_mlockall_flags(flags);
 	up_write(&current->mm->mmap_sem);
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
@@ -716,7 +720,7 @@ SYSCALL_DEFINE0(munlockall)
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
