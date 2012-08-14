Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id A83006B0070
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 12:25:02 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so297284bkc.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 09:25:01 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 02/16] user_ns: use new hashtable implementation
Date: Tue, 14 Aug 2012 18:24:36 +0200
Message-Id: <1344961490-4068-3-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch user_ns to use the new hashtable implementation. This reduces the amount of
generic unrelated code in user_ns.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 kernel/user.c |   33 +++++++++++++--------------------
 1 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/kernel/user.c b/kernel/user.c
index b815fef..d10c484 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/export.h>
 #include <linux/user_namespace.h>
+#include <linux/hashtable.h>
 
 /*
  * userns count is 1 for root user, 1 for init_uts_ns,
@@ -52,13 +53,9 @@ EXPORT_SYMBOL_GPL(init_user_ns);
  */
 
 #define UIDHASH_BITS	(CONFIG_BASE_SMALL ? 3 : 7)
-#define UIDHASH_SZ	(1 << UIDHASH_BITS)
-#define UIDHASH_MASK		(UIDHASH_SZ - 1)
-#define __uidhashfn(uid)	(((uid >> UIDHASH_BITS) + uid) & UIDHASH_MASK)
-#define uidhashentry(uid)	(uidhash_table + __uidhashfn((__kuid_val(uid))))
 
 static struct kmem_cache *uid_cachep;
-struct hlist_head uidhash_table[UIDHASH_SZ];
+static DEFINE_HASHTABLE(uidhash_table, UIDHASH_BITS)
 
 /*
  * The uidhash_lock is mostly taken from process context, but it is
@@ -84,22 +81,22 @@ struct user_struct root_user = {
 /*
  * These routines must be called with the uidhash spinlock held!
  */
-static void uid_hash_insert(struct user_struct *up, struct hlist_head *hashent)
+static void uid_hash_insert(struct user_struct *up)
 {
-	hlist_add_head(&up->uidhash_node, hashent);
+	hash_add(uidhash_table, &up->uidhash_node, __kuid_val(up->uid));
 }
 
 static void uid_hash_remove(struct user_struct *up)
 {
-	hlist_del_init(&up->uidhash_node);
+	hash_del(&up->uidhash_node);
 }
 
-static struct user_struct *uid_hash_find(kuid_t uid, struct hlist_head *hashent)
+static struct user_struct *uid_hash_find(kuid_t uid)
 {
 	struct user_struct *user;
 	struct hlist_node *h;
 
-	hlist_for_each_entry(user, h, hashent, uidhash_node) {
+	hash_for_each_possible(uidhash_table, user, h, uidhash_node, __kuid_val(uid)) {
 		if (uid_eq(user->uid, uid)) {
 			atomic_inc(&user->__count);
 			return user;
@@ -135,7 +132,7 @@ struct user_struct *find_user(kuid_t uid)
 	unsigned long flags;
 
 	spin_lock_irqsave(&uidhash_lock, flags);
-	ret = uid_hash_find(uid, uidhashentry(uid));
+	ret = uid_hash_find(uid);
 	spin_unlock_irqrestore(&uidhash_lock, flags);
 	return ret;
 }
@@ -156,11 +153,10 @@ void free_uid(struct user_struct *up)
 
 struct user_struct *alloc_uid(kuid_t uid)
 {
-	struct hlist_head *hashent = uidhashentry(uid);
 	struct user_struct *up, *new;
 
 	spin_lock_irq(&uidhash_lock);
-	up = uid_hash_find(uid, hashent);
+	up = uid_hash_find(uid);
 	spin_unlock_irq(&uidhash_lock);
 
 	if (!up) {
@@ -176,13 +172,13 @@ struct user_struct *alloc_uid(kuid_t uid)
 		 * on adding the same user already..
 		 */
 		spin_lock_irq(&uidhash_lock);
-		up = uid_hash_find(uid, hashent);
+		up = uid_hash_find(uid);
 		if (up) {
 			key_put(new->uid_keyring);
 			key_put(new->session_keyring);
 			kmem_cache_free(uid_cachep, new);
 		} else {
-			uid_hash_insert(new, hashent);
+			uid_hash_insert(new);
 			up = new;
 		}
 		spin_unlock_irq(&uidhash_lock);
@@ -196,17 +192,14 @@ out_unlock:
 
 static int __init uid_cache_init(void)
 {
-	int n;
-
 	uid_cachep = kmem_cache_create("uid_cache", sizeof(struct user_struct),
 			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
 
-	for(n = 0; n < UIDHASH_SZ; ++n)
-		INIT_HLIST_HEAD(uidhash_table + n);
+	hash_init(uidhash_table);
 
 	/* Insert the root user immediately (init already runs as root) */
 	spin_lock_irq(&uidhash_lock);
-	uid_hash_insert(&root_user, uidhashentry(GLOBAL_ROOT_UID));
+	uid_hash_insert(&root_user);
 	spin_unlock_irq(&uidhash_lock);
 
 	return 0;
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
