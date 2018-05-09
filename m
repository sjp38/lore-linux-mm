Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8596B056F
	for <linux-mm@kvack.org>; Wed,  9 May 2018 15:38:45 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k27-v6so23814807wre.23
        for <linux-mm@kvack.org>; Wed, 09 May 2018 12:38:44 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m127si8047182wmm.43.2018.05.09.12.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 12:38:43 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/8] userns: use refcount_t for reference counting instead atomic_t
Date: Wed,  9 May 2018 21:36:39 +0200
Message-Id: <20180509193645.830-3-bigeasy@linutronix.de>
In-Reply-To: <20180509193645.830-1-bigeasy@linutronix.de>
References: <20180509193645.830-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

refcount_t type and corresponding API should be used instead of atomic_t wh=
en
the variable is used as a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free situations.

Suggested-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/sched/user.h | 5 +++--
 kernel/user.c              | 8 ++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched/user.h b/include/linux/sched/user.h
index 96fe289c4c6e..39ad98c09c58 100644
--- a/include/linux/sched/user.h
+++ b/include/linux/sched/user.h
@@ -4,6 +4,7 @@
=20
 #include <linux/uidgid.h>
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <linux/ratelimit.h>
=20
 struct key;
@@ -12,7 +13,7 @@ struct key;
  * Some day this will be a full-fledged user tracking system..
  */
 struct user_struct {
-	atomic_t __count;	/* reference count */
+	refcount_t __count;	/* reference count */
 	atomic_t processes;	/* How many processes does this user have? */
 	atomic_t sigpending;	/* How many pending signals does this user have? */
 #ifdef CONFIG_FANOTIFY
@@ -59,7 +60,7 @@ extern struct user_struct root_user;
 extern struct user_struct * alloc_uid(kuid_t);
 static inline struct user_struct *get_uid(struct user_struct *u)
 {
-	atomic_inc(&u->__count);
+	refcount_inc(&u->__count);
 	return u;
 }
 extern void free_uid(struct user_struct *);
diff --git a/kernel/user.c b/kernel/user.c
index 36288d840675..5f65ef195259 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -96,7 +96,7 @@ static DEFINE_SPINLOCK(uidhash_lock);
=20
 /* root_user.__count is 1, for init task cred */
 struct user_struct root_user =3D {
-	.__count	=3D ATOMIC_INIT(1),
+	.__count	=3D REFCOUNT_INIT(1),
 	.processes	=3D ATOMIC_INIT(1),
 	.sigpending	=3D ATOMIC_INIT(0),
 	.locked_shm     =3D 0,
@@ -123,7 +123,7 @@ static struct user_struct *uid_hash_find(kuid_t uid, st=
ruct hlist_head *hashent)
=20
 	hlist_for_each_entry(user, hashent, uidhash_node) {
 		if (uid_eq(user->uid, uid)) {
-			atomic_inc(&user->__count);
+			refcount_inc(&user->__count);
 			return user;
 		}
 	}
@@ -170,7 +170,7 @@ void free_uid(struct user_struct *up)
 		return;
=20
 	local_irq_save(flags);
-	if (atomic_dec_and_lock(&up->__count, &uidhash_lock))
+	if (refcount_dec_and_lock(&up->__count, &uidhash_lock))
 		free_user(up, flags);
 	else
 		local_irq_restore(flags);
@@ -191,7 +191,7 @@ struct user_struct *alloc_uid(kuid_t uid)
 			goto out_unlock;
=20
 		new->uid =3D uid;
-		atomic_set(&new->__count, 1);
+		refcount_set(&new->__count, 1);
 		ratelimit_state_init(&new->ratelimit, HZ, 100);
 		ratelimit_set_flags(&new->ratelimit, RATELIMIT_MSG_ON_RELEASE);
=20
--=20
2.17.0
