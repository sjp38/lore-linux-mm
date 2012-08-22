Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 363636B009D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 22:28:41 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id x4so779582obh.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 19:28:40 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 17/17] SUNRPC: use new hashtable implementation in auth
Date: Wed, 22 Aug 2012 04:27:12 +0200
Message-Id: <1345602432-27673-18-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch sunrpc/auth.c  to use the new hashtable implementation. This reduces the amount of
generic unrelated code in auth.c.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/sunrpc/auth.c |   45 +++++++++++++++++++--------------------------
 1 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b5c067b..5d50e2d 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/spinlock.h>
+#include <linux/hashtable.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -222,7 +223,7 @@ static DEFINE_SPINLOCK(rpc_credcache_lock);
 static void
 rpcauth_unhash_cred_locked(struct rpc_cred *cred)
 {
-	hlist_del_rcu(&cred->cr_hash);
+	hash_del_rcu(&cred->cr_hash);
 	smp_mb__before_clear_bit();
 	clear_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
 }
@@ -249,16 +250,15 @@ int
 rpcauth_init_credcache(struct rpc_auth *auth)
 {
 	struct rpc_cred_cache *new;
-	unsigned int hashsize;
 
 	new = kmalloc(sizeof(*new), GFP_KERNEL);
 	if (!new)
 		goto out_nocache;
 	new->hashbits = auth_hashbits;
-	hashsize = 1U << new->hashbits;
-	new->hashtable = kcalloc(hashsize, sizeof(new->hashtable[0]), GFP_KERNEL);
+	new->hashtable = kmalloc(HASH_REQUIRED_SIZE(new->hashbits), GFP_KERNEL);
 	if (!new->hashtable)
 		goto out_nohashtbl;
+	hash_init_size(new->hashtable, new->hashbits);
 	spin_lock_init(&new->lock);
 	auth->au_credcache = new;
 	return 0;
@@ -292,25 +292,20 @@ void
 rpcauth_clear_credcache(struct rpc_cred_cache *cache)
 {
 	LIST_HEAD(free);
-	struct hlist_head *head;
+	struct hlist_node *n, *t;
 	struct rpc_cred	*cred;
-	unsigned int hashsize = 1U << cache->hashbits;
-	int		i;
+	int i;
 
 	spin_lock(&rpc_credcache_lock);
 	spin_lock(&cache->lock);
-	for (i = 0; i < hashsize; i++) {
-		head = &cache->hashtable[i];
-		while (!hlist_empty(head)) {
-			cred = hlist_entry(head->first, struct rpc_cred, cr_hash);
-			get_rpccred(cred);
-			if (!list_empty(&cred->cr_lru)) {
-				list_del(&cred->cr_lru);
-				number_cred_unused--;
-			}
-			list_add_tail(&cred->cr_lru, &free);
-			rpcauth_unhash_cred_locked(cred);
+	hash_for_each_safe_size(cache->hashtable, cache->hashbits, i, n, t, cred, cr_hash) {
+		get_rpccred(cred);
+		if (!list_empty(&cred->cr_lru)) {
+			list_del(&cred->cr_lru);
+			number_cred_unused--;
 		}
+		list_add_tail(&cred->cr_lru, &free);
+		rpcauth_unhash_cred_locked(cred);
 	}
 	spin_unlock(&cache->lock);
 	spin_unlock(&rpc_credcache_lock);
@@ -408,14 +403,11 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	LIST_HEAD(free);
 	struct rpc_cred_cache *cache = auth->au_credcache;
 	struct hlist_node *pos;
-	struct rpc_cred	*cred = NULL,
-			*entry, *new;
-	unsigned int nr;
-
-	nr = hash_long(acred->uid, cache->hashbits);
+	struct rpc_cred	*cred = NULL, *entry = NULL, *new;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
+	hash_for_each_possible_rcu_size(cache->hashtable, cred, cache->hashbits,
+					pos, cr_hash, acred->uid) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
 		spin_lock(&cache->lock);
@@ -439,7 +431,8 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	}
 
 	spin_lock(&cache->lock);
-	hlist_for_each_entry(entry, pos, &cache->hashtable[nr], cr_hash) {
+	hash_for_each_possible_size(cache->hashtable, entry, cache->hashbits, pos,
+					cr_hash, acred->uid) {
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
 		cred = get_rpccred(entry);
@@ -448,7 +441,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	if (cred == NULL) {
 		cred = new;
 		set_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
-		hlist_add_head_rcu(&cred->cr_hash, &cache->hashtable[nr]);
+		hash_add_size(cache->hashtable, cache->hashbits, &cred->cr_hash, acred->uid);
 	} else
 		list_add_tail(&new->cr_lru, &free);
 	spin_unlock(&cache->lock);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
