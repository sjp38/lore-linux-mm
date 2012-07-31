Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 556F96B00AD
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 14:05:07 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so4023151bkc.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 11:05:05 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC 2/4] user_ns: use new hashtable implementation
Date: Tue, 31 Jul 2012 20:05:18 +0200
Message-Id: <1343757920-19713-3-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, Sasha Levin <levinsasha928@gmail.com>

Switch user_ns to use the new hashtable implementation. This reduces the amount of
generic unrelated code in user_ns.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/user_namespace.h |   11 +++++---
 kernel/user.c                  |   54 +++++++--------------------------------
 kernel/user_namespace.c        |    4 +--
 3 files changed, 18 insertions(+), 51 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index faf4679..cbbe342 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -5,13 +5,16 @@
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/err.h>
+#include <linux/hashtable.h>
 
-#define UIDHASH_BITS	(CONFIG_BASE_SMALL ? 3 : 7)
-#define UIDHASH_SZ	(1 << UIDHASH_BITS)
-
+#define UIDHASH_BITS		(CONFIG_BASE_SMALL ? 3 : 7)
+#define UIDHASH_CMP(obj, key)	((obj)->uid == (key))
+#define UIDHASH_ENTRY(ns, key)	(HASH_GET((ns)->uidhash_table, key,	\
+				struct user_struct, uidhash_node,	\
+				UIDHASH_CMP))
 struct user_namespace {
 	struct kref		kref;
-	struct hlist_head	uidhash_table[UIDHASH_SZ];
+	DEFINE_HASHTABLE(uidhash_table, UIDHASH_BITS);
 	struct user_struct	*creator;
 	struct work_struct	destroyer;
 };
diff --git a/kernel/user.c b/kernel/user.c
index 71dd236..3b8367c 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -34,10 +34,6 @@ EXPORT_SYMBOL_GPL(init_user_ns);
  * when changing user ID's (ie setuid() and friends).
  */
 
-#define UIDHASH_MASK		(UIDHASH_SZ - 1)
-#define __uidhashfn(uid)	(((uid >> UIDHASH_BITS) + uid) & UIDHASH_MASK)
-#define uidhashentry(ns, uid)	((ns)->uidhash_table + __uidhashfn((uid)))
-
 static struct kmem_cache *uid_cachep;
 
 /*
@@ -61,35 +57,6 @@ struct user_struct root_user = {
 	.user_ns	= &init_user_ns,
 };
 
-/*
- * These routines must be called with the uidhash spinlock held!
- */
-static void uid_hash_insert(struct user_struct *up, struct hlist_head *hashent)
-{
-	hlist_add_head(&up->uidhash_node, hashent);
-}
-
-static void uid_hash_remove(struct user_struct *up)
-{
-	hlist_del_init(&up->uidhash_node);
-	put_user_ns(up->user_ns);
-}
-
-static struct user_struct *uid_hash_find(uid_t uid, struct hlist_head *hashent)
-{
-	struct user_struct *user;
-	struct hlist_node *h;
-
-	hlist_for_each_entry(user, h, hashent, uidhash_node) {
-		if (user->uid == uid) {
-			atomic_inc(&user->__count);
-			return user;
-		}
-	}
-
-	return NULL;
-}
-
 /* IRQs are disabled and uidhash_lock is held upon function entry.
  * IRQ state (as stored in flags) is restored and uidhash_lock released
  * upon function exit.
@@ -97,7 +64,8 @@ static struct user_struct *uid_hash_find(uid_t uid, struct hlist_head *hashent)
 static void free_user(struct user_struct *up, unsigned long flags)
 	__releases(&uidhash_lock)
 {
-	uid_hash_remove(up);
+	HASH_DEL(up, uidhash_node);
+	put_user_ns(up->user_ns);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 	key_put(up->uid_keyring);
 	key_put(up->session_keyring);
@@ -117,7 +85,9 @@ struct user_struct *find_user(uid_t uid)
 	struct user_namespace *ns = current_user_ns();
 
 	spin_lock_irqsave(&uidhash_lock, flags);
-	ret = uid_hash_find(uid, uidhashentry(ns, uid));
+	ret = UIDHASH_ENTRY(ns, uid);
+	if (ret)
+		atomic_inc(&ret->__count);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 	return ret;
 }
@@ -138,11 +108,10 @@ void free_uid(struct user_struct *up)
 
 struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 {
-	struct hlist_head *hashent = uidhashentry(ns, uid);
 	struct user_struct *up, *new;
 
 	spin_lock_irq(&uidhash_lock);
-	up = uid_hash_find(uid, hashent);
+	up = UIDHASH_ENTRY(ns, uid);
 	spin_unlock_irq(&uidhash_lock);
 
 	if (!up) {
@@ -160,14 +129,14 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 		 * on adding the same user already..
 		 */
 		spin_lock_irq(&uidhash_lock);
-		up = uid_hash_find(uid, hashent);
+		up = UIDHASH_ENTRY(ns, uid);
 		if (up) {
 			put_user_ns(ns);
 			key_put(new->uid_keyring);
 			key_put(new->session_keyring);
 			kmem_cache_free(uid_cachep, new);
 		} else {
-			uid_hash_insert(new, hashent);
+			HASH_ADD(ns->uidhash_table, &new->uidhash_node, uid);
 			up = new;
 		}
 		spin_unlock_irq(&uidhash_lock);
@@ -181,17 +150,14 @@ out_unlock:
 
 static int __init uid_cache_init(void)
 {
-	int n;
-
 	uid_cachep = kmem_cache_create("uid_cache", sizeof(struct user_struct),
 			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
 
-	for(n = 0; n < UIDHASH_SZ; ++n)
-		INIT_HLIST_HEAD(init_user_ns.uidhash_table + n);
+	HASH_INIT(init_user_ns.uidhash_table);
 
 	/* Insert the root user immediately (init already runs as root) */
 	spin_lock_irq(&uidhash_lock);
-	uid_hash_insert(&root_user, uidhashentry(&init_user_ns, 0));
+	HASH_ADD(init_user_ns.uidhash_table, &root_user.uidhash_node, 0);
 	spin_unlock_irq(&uidhash_lock);
 
 	return 0;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 3b906e9..914c8c5 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -26,7 +26,6 @@ int create_user_ns(struct cred *new)
 {
 	struct user_namespace *ns;
 	struct user_struct *root_user;
-	int n;
 
 	ns = kmem_cache_alloc(user_ns_cachep, GFP_KERNEL);
 	if (!ns)
@@ -34,8 +33,7 @@ int create_user_ns(struct cred *new)
 
 	kref_init(&ns->kref);
 
-	for (n = 0; n < UIDHASH_SZ; ++n)
-		INIT_HLIST_HEAD(ns->uidhash_table + n);
+	HASH_INIT(ns->uidhash_table);
 
 	/* Alloc new root user.  */
 	root_user = alloc_uid(ns, 0);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
