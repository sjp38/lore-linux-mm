Received: from rgmsgw02.us.oracle.com (rgmsgw02.us.oracle.com [138.1.186.52])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id l5SIPqNZ011477
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 13:25:52 -0500
Message-ID: <4683FD2F.5090607@oracle.com>
Date: Thu, 28 Jun 2007 11:25:51 -0700
From: Herbert van den Bergh <Herbert.van.den.Bergh@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] do not limit locked memory when RLIMIT_MEMLOCK is RLIM_INFINITY
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch fixes a bug in mm/mlock.c on 32-bit architectures that prevents
a user from locking more than 4GB of shared memory, or allocating more
than 4GB of shared memory in hugepages, when rlim[RLIMIT_MEMLOCK] is
set to RLIM_INFINITY.

Signed-off-by: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
Acked-by: Chris Mason <chris.mason@oracle.com>

--- linux-2.6.22-rc6/mm/mlock.c.orig    2007-06-26 15:17:22.000000000 -0700
+++ linux-2.6.22-rc6/mm/mlock.c    2007-06-28 11:18:48.000000000 -0700
@@ -244,9 +244,12 @@ int user_shm_lock(size_t size, struct us
 
     locked = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
     lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+    if (lock_limit == RLIM_INFINITY)
+        allowed = 1;
     lock_limit >>= PAGE_SHIFT;
     spin_lock(&shmlock_user_lock);
-    if (locked + user->locked_shm > lock_limit && !capable(CAP_IPC_LOCK))
+    if (!allowed &&
+        locked + user->locked_shm > lock_limit && !capable(CAP_IPC_LOCK))
         goto out;
     get_uid(user);
     user->locked_shm += locked;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
