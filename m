Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 52BF26B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 13:35:24 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2367491dak.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 10:35:23 -0700 (PDT)
From: rajman mekaco <rajman.mekaco@gmail.com>
Subject: [PATCH 1/1] mlock: split the shmlock_user_lock spinlock into per user_struct spinlock
Date: Thu,  3 May 2012 23:04:37 +0530
Message-Id: <1336066477-3964-1-git-send-email-rajman.mekaco@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@gentwo.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rajman mekaco <rajman.mekaco@gmail.com>

The user_shm_lock and user_shm_unlock functions use a single global
spinlock for protecting the user->locked_shm.

This is an overhead for multiple CPUs calling this code even if they
are having different user_struct.

Remove the global shmlock_user_lock and introduce and use a new
spinlock inside of the user_struct structure.

Signed-off-by: rajman mekaco <rajman.mekaco@gmail.com>
---
 include/linux/sched.h |    1 +
 kernel/user.c         |    1 +
 mm/mlock.c            |   10 ++++------
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 81a173c..c661cfd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -720,6 +720,7 @@ struct user_struct {
 	unsigned long mq_bytes;	/* How many bytes can be allocated to mqueue? */
 #endif
 	unsigned long locked_shm; /* How many pages of mlocked shm ? */
+	spinlock_t shmlock_user_lock; /* Protects locked_shm */
 
 #ifdef CONFIG_KEYS
 	struct key *uid_keyring;	/* UID specific keyring */
diff --git a/kernel/user.c b/kernel/user.c
index 71dd236..ca7f423 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -169,6 +169,7 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 		} else {
 			uid_hash_insert(new, hashent);
 			up = new;
+			spin_lock_init(&new->shmlock_user_lock);
 		}
 		spin_unlock_irq(&uidhash_lock);
 	}
diff --git a/mm/mlock.c b/mm/mlock.c
index ef726e8..11a78a6 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -593,8 +593,6 @@ SYSCALL_DEFINE0(munlockall)
  * Objects with different lifetime than processes (SHM_LOCK and SHM_HUGETLB
  * shm segments) get accounted against the user_struct instead.
  */
-static DEFINE_SPINLOCK(shmlock_user_lock);
-
 int user_shm_lock(size_t size, struct user_struct *user)
 {
 	unsigned long lock_limit, locked;
@@ -605,7 +603,7 @@ int user_shm_lock(size_t size, struct user_struct *user)
 	if (lock_limit == RLIM_INFINITY)
 		allowed = 1;
 	lock_limit >>= PAGE_SHIFT;
-	spin_lock(&shmlock_user_lock);
+	spin_lock(&user->shmlock_user_lock);
 	if (!allowed &&
 	    locked + user->locked_shm > lock_limit && !capable(CAP_IPC_LOCK))
 		goto out;
@@ -613,14 +611,14 @@ int user_shm_lock(size_t size, struct user_struct *user)
 	user->locked_shm += locked;
 	allowed = 1;
 out:
-	spin_unlock(&shmlock_user_lock);
+	spin_unlock(&user->shmlock_user_lock);
 	return allowed;
 }
 
 void user_shm_unlock(size_t size, struct user_struct *user)
 {
-	spin_lock(&shmlock_user_lock);
+	spin_lock(&user->shmlock_user_lock);
 	user->locked_shm -= (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	spin_unlock(&shmlock_user_lock);
+	spin_unlock(&user->shmlock_user_lock);
 	free_uid(user);
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
