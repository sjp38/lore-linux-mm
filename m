Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6C516B000E
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 64so18569535pgc.17
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si1710224pgu.30.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:03 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 15/64] ipc: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:05 +0100
Message-Id: <20180205012754.23615-16-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This is straightforward as the necessary syscalls already
know about mmrange. No change in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/shm.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 6c29c791c7f2..4ab752647ca9 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1398,7 +1398,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	if (err)
 		goto out_fput;
 
-	if (down_write_killable(&current->mm->mmap_sem)) {
+	if (mm_write_lock_killable(current->mm, &mmrange)) {
 		err = -EINTR;
 		goto out_fput;
 	}
@@ -1419,7 +1419,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	if (IS_ERR_VALUE(addr))
 		err = (long)addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	if (populate)
 		mm_populate(addr, populate);
 
@@ -1494,7 +1494,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 	if (addr & ~PAGE_MASK)
 		return retval;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	/*
@@ -1585,7 +1585,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 
 #endif
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return retval;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
