Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE1C36B029B
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:38 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v17so18514725pgb.18
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8si4884195pgn.184.2018.02.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 19/64] mm/mlock: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:09 +0100
Message-Id: <20180205012754.23615-20-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

Conversion is straightforward, mmap_sem is used within the
same function context. No changes in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/mlock.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 3f6bd953e8b0..dfd175b2cf20 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -686,7 +686,7 @@ static __must_check int do_mlock(unsigned long start, size_t len,
 	lock_limit >>= PAGE_SHIFT;
 	locked = len >> PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 
 	locked += current->mm->locked_vm;
@@ -705,7 +705,7 @@ static __must_check int do_mlock(unsigned long start, size_t len,
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = apply_vma_lock_flags(start, len, flags, &mmrange);
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	if (error)
 		return error;
 
@@ -741,10 +741,10 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 	ret = apply_vma_lock_flags(start, len, 0, &mmrange);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 
 	return ret;
 }
@@ -811,14 +811,14 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 
 	ret = -ENOMEM;
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = apply_mlockall_flags(flags, &mmrange);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	if (!ret && (flags & MCL_CURRENT))
 		mm_populate(0, TASK_SIZE);
 
@@ -830,10 +830,10 @@ SYSCALL_DEFINE0(munlockall)
 	int ret;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 	ret = apply_mlockall_flags(0, &mmrange);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	return ret;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
