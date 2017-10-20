Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 270066B026C
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so10048043pfj.21
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:13 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 31si543051ply.748.2017.10.20.05.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:11 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 03/15] sched: convert user_struct.__count to refcount_t
Date: Fri, 20 Oct 2017 15:15:45 +0300
Message-Id: <1508501757-15784-4-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable user_struct.__count is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 include/linux/sched/user.h | 5 +++--
 kernel/user.c              | 8 ++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched/user.h b/include/linux/sched/user.h
index 3c07e41..afcbf19 100644
--- a/include/linux/sched/user.h
+++ b/include/linux/sched/user.h
@@ -3,6 +3,7 @@
 
 #include <linux/uidgid.h>
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 
 struct key;
 
@@ -10,7 +11,7 @@ struct key;
  * Some day this will be a full-fledged user tracking system..
  */
 struct user_struct {
-	atomic_t __count;	/* reference count */
+	refcount_t __count;	/* reference count */
 	atomic_t processes;	/* How many processes does this user have? */
 	atomic_t sigpending;	/* How many pending signals does this user have? */
 #ifdef CONFIG_FANOTIFY
@@ -54,7 +55,7 @@ extern struct user_struct root_user;
 extern struct user_struct * alloc_uid(kuid_t);
 static inline struct user_struct *get_uid(struct user_struct *u)
 {
-	atomic_inc(&u->__count);
+	refcount_inc(&u->__count);
 	return u;
 }
 extern void free_uid(struct user_struct *);
diff --git a/kernel/user.c b/kernel/user.c
index 00281ad..c072348 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -90,7 +90,7 @@ static DEFINE_SPINLOCK(uidhash_lock);
 
 /* root_user.__count is 1, for init task cred */
 struct user_struct root_user = {
-	.__count	= ATOMIC_INIT(1),
+	.__count	= REFCOUNT_INIT(1),
 	.processes	= ATOMIC_INIT(1),
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
@@ -116,7 +116,7 @@ static struct user_struct *uid_hash_find(kuid_t uid, struct hlist_head *hashent)
 
 	hlist_for_each_entry(user, hashent, uidhash_node) {
 		if (uid_eq(user->uid, uid)) {
-			atomic_inc(&user->__count);
+			refcount_inc(&user->__count);
 			return user;
 		}
 	}
@@ -163,7 +163,7 @@ void free_uid(struct user_struct *up)
 		return;
 
 	local_irq_save(flags);
-	if (atomic_dec_and_lock(&up->__count, &uidhash_lock))
+	if (refcount_dec_and_lock(&up->__count, &uidhash_lock))
 		free_user(up, flags);
 	else
 		local_irq_restore(flags);
@@ -184,7 +184,7 @@ struct user_struct *alloc_uid(kuid_t uid)
 			goto out_unlock;
 
 		new->uid = uid;
-		atomic_set(&new->__count, 1);
+		refcount_set(&new->__count, 1);
 
 		/*
 		 * Before adding this, check whether we raced
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
