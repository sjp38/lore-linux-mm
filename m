Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF8B6B0005
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 19:09:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g62so63023632pfb.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 16:09:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id f7si953660paa.24.2016.07.07.16.09.24
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 16:09:24 -0700 (PDT)
Subject: [RFC][PATCH] x86, pkeys: scalable pkey_set()/pkey_get()
From: Dave Hansen <dave@sr71.net>
Date: Thu, 07 Jul 2016 16:09:22 -0700
Message-Id: <20160707230922.ED44A9DA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, mingo@kernel.org, mgorman@techsingularity.net, dave.hansen@intel.com


This improves on the code I posted earlier, and you can find
here:

	http://git.kernel.org/cgit/linux/kernel/git/daveh/x86-pkeys.git/log/?h=pkeys-v039

More details on pkey_get/set() can be found here:

	https://www.sr71.net/~dave/intel/manpages/pkey_get.2.html

This is in response to some of Mel's comments regarding how
expensive it is to hold mmap_sem for write.

--

The pkey_set()/pkey_get() system calls are intented to be safer
replacements for the RDPKRU and WRPKRU instructions.  But, in
addition to what those instructions do, the syscalls also ensure
that the pkey being acted upon is allocated.

But, the "allocated" check is fundamentally racy.  By the time
the call returns, another thread could have pkey_free()'d the
key.  A valid return here means only that the key *was*
allocated/valid at some point during the syscall.

We do some pretty hard-core synchronization of
pkey_set()/pkey_get() with down_write(mm->mmap_sem) because it
also protects the allocation map that we need to query.  But,
mmap_sem doesn't really buy us anything other than a consistent
snapshot of the pkey allocation map.

So, get our snapshot another way.  Using WRITE_ONCE()/READ_ONCE()
we can ensure that we get a consistent view of this 2-byte value
for pkey_set()/pkey_get().  It might be stale by the time we act
on it, but that's OK because of the previously mentioned raciness
of pkey_set()/pkey_get() even with mmap_sem is helping out.

Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: mingo@kernel.org
Cc: mgorman@techsingularity.net
Cc: Dave Hansen (Intel) <dave.hansen@intel.com>

---

 b/arch/x86/include/asm/pkeys.h |   39 ++++++++++++++++++++++++++++++++++-----
 b/mm/mprotect.c                |    4 ----
 2 files changed, 34 insertions(+), 9 deletions(-)

diff -puN mm/mprotect.c~pkeys-119-fast-set-get mm/mprotect.c
--- a/mm/mprotect.c~pkeys-119-fast-set-get	2016-07-07 12:25:49.582075153 -0700
+++ b/mm/mprotect.c	2016-07-07 12:42:50.516384977 -0700
@@ -542,10 +542,8 @@ SYSCALL_DEFINE2(pkey_get, int, pkey, uns
 	if (flags)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
 	if (!mm_pkey_is_allocated(current->mm, pkey))
 		ret = -EBADF;
-	up_write(&current->mm->mmap_sem);
 
 	if (ret)
 		return ret;
@@ -563,10 +561,8 @@ SYSCALL_DEFINE3(pkey_set, int, pkey, uns
 	if (flags)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
 	if (!mm_pkey_is_allocated(current->mm, pkey))
 		ret = -EBADF;
-	up_write(&current->mm->mmap_sem);
 
 	if (ret)
 		return ret;
diff -puN arch/x86/include/asm/pkeys.h~pkeys-119-fast-set-get arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-119-fast-set-get	2016-07-07 12:26:19.265421712 -0700
+++ b/arch/x86/include/asm/pkeys.h	2016-07-07 15:18:15.391642423 -0700
@@ -35,18 +35,47 @@ extern int __arch_set_user_pkey_access(s
 
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
 
+#define PKEY_MAP_SET	1
+#define PKEY_MAP_CLEAR	2
 #define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
-#define mm_set_pkey_allocated(mm, pkey) do {		\
-	mm_pkey_allocation_map(mm) |= (1U << pkey);	\
+static inline
+void mm_modify_pkey_alloc_map(struct mm_struct *mm, int pkey, int setclear)
+{
+	u16 new_map = mm_pkey_allocation_map(mm);
+	if (setclear == PKEY_MAP_SET)
+		new_map |= (1U << pkey);
+	else if (setclear == PKEY_MAP_CLEAR)
+		new_map &= ~(1U << pkey);
+	else
+		BUILD_BUG_ON(1);
+	/*
+	 * Make sure that mm_pkey_is_allocated() callers never
+	 * see intermediate states by using WRITE_ONCE().
+	 * Concurrent calls to this function are excluded by
+	 * down_write(mm->mmap_sem) so we only need to protect
+	 * against readers.
+	 */
+	WRITE_ONCE(mm_pkey_allocation_map(mm), new_map);
+}
+#define mm_set_pkey_allocated(mm, pkey) do {			\
+	mm_modify_pkey_alloc_map(mm, pkey, PKEY_MAP_SET);	\
 } while (0)
-#define mm_set_pkey_free(mm, pkey) do {			\
-	mm_pkey_allocation_map(mm) &= ~(1U << pkey);	\
+#define mm_set_pkey_free(mm, pkey) do {				\
+	mm_modify_pkey_alloc_map(mm, pkey, PKEY_MAP_CLEAR);	\
 } while (0)
 
 static inline
 bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
-	return mm_pkey_allocation_map(mm) & (1U << pkey);
+	/*
+	 * Make sure we get a single, consistent view of the
+	 * allocation map.  This is racy, but that's OK since the
+	 * interfaces that depend on this are either already
+	 * fundamentally racy with respect to the allocation map
+	 * (pkey_get/set()) or called under
+	 * down_write(mm->mmap_sem).
+	 */
+	return READ_ONCE(mm_pkey_allocation_map(mm)) & (1U << pkey);
 }
 
 static inline
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
