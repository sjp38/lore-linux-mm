Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 12DB56B0257
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 13:04:00 -0400 (EDT)
Received: by qgef3 with SMTP id f3so37372586qge.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 10:03:59 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id f5si25581334qhc.72.2015.07.07.10.03.51
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 10:03:52 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V3 1/5] mm: mlock: Refactor mlock, munlock, and munlockall code
Date: Tue,  7 Jul 2015 13:03:39 -0400
Message-Id: <1436288623-13007-2-git-send-email-emunson@akamai.com>
In-Reply-To: <1436288623-13007-1-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With the exception of mlockall() none of the mlock family of system
calls take a flags argument so they are not extensible.  A later patch
in this set will extend the mlock family to support a middle ground
between pages that are locked and faulted in immediately and unlocked
pages.  To pave the way for the new system calls, the code needs some
reorganization so that all the actual entry points handle is checking
input and translating to VMA flags.

This patch mostly moves code around with the exception of
do_munlockall().  All three functions are changed to support a follow on
patch which introduces new system calls that allow the user to specify
flags for these calls.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/mlock.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 46 insertions(+), 11 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 6fd2cf1..8e52c23 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -553,7 +553,8 @@ out:
 	return ret;
 }
 
-static int do_mlock(unsigned long start, size_t len, int on)
+static int apply_vma_flags(unsigned long start, size_t len,
+			   vm_flags_t flags, bool add_flags)
 {
 	unsigned long nstart, end, tmp;
 	struct vm_area_struct * vma, * prev;
@@ -579,9 +580,11 @@ static int do_mlock(unsigned long start, size_t len, int on)
 
 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
-		if (on)
-			newflags |= VM_LOCKED;
+		newflags = vma->vm_flags;
+		if (add_flags)
+			newflags |= flags;
+		else
+			newflags &= ~flags;
 
 		tmp = vma->vm_end;
 		if (tmp > end)
@@ -604,7 +607,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 	return error;
 }
 
-SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
+static int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 {
 	unsigned long locked;
 	unsigned long lock_limit;
@@ -628,7 +631,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
-		error = do_mlock(start, len, 1);
+		error = apply_vma_flags(start, len, flags, true);
 
 	up_write(&current->mm->mmap_sem);
 	if (error)
@@ -640,7 +643,12 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	return 0;
 }
 
-SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
+SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
+{
+	return do_mlock(start, len, VM_LOCKED);
+}
+
+static int do_munlock(unsigned long start, size_t len, vm_flags_t flags)
 {
 	int ret;
 
@@ -648,20 +656,23 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 	start &= PAGE_MASK;
 
 	down_write(&current->mm->mmap_sem);
-	ret = do_mlock(start, len, 0);
+	ret = apply_vma_flags(start, len, flags, false);
 	up_write(&current->mm->mmap_sem);
 
 	return ret;
 }
 
+SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
+{
+	return do_munlock(start, len, VM_LOCKED);
+}
+
 static int do_mlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
 
 	if (flags & MCL_FUTURE)
 		current->mm->def_flags |= VM_LOCKED;
-	else
-		current->mm->def_flags &= ~VM_LOCKED;
 	if (flags == MCL_FUTURE)
 		goto out;
 
@@ -711,12 +722,36 @@ out:
 	return ret;
 }
 
+static int do_munlockall(int flags)
+{
+	struct vm_area_struct * vma, * prev = NULL;
+
+	if (flags & MCL_FUTURE)
+		current->mm->def_flags &= ~VM_LOCKED;
+	if (flags == MCL_FUTURE)
+		goto out;
+
+	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
+		vm_flags_t newflags;
+
+		newflags = vma->vm_flags;
+		if (flags & MCL_CURRENT)
+			newflags &= ~VM_LOCKED;
+
+		/* Ignore errors */
+		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
+		cond_resched_rcu_qs();
+	}
+out:
+	return 0;
+}
+
 SYSCALL_DEFINE0(munlockall)
 {
 	int ret;
 
 	down_write(&current->mm->mmap_sem);
-	ret = do_mlockall(0);
+	ret = do_munlockall(MCL_CURRENT | MCL_FUTURE);
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
