Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 91A856B0092
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 22:27:58 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id x4so779582obh.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 19:27:58 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 11/17] net,l2tp: use new hashtable implementation
Date: Wed, 22 Aug 2012 04:27:06 +0200
Message-Id: <1345602432-27673-12-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch l2tp to use the new hashtable implementation. This reduces the amount of
generic unrelated code in l2tp.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/l2tp/l2tp_core.c    |  134 +++++++++++++++++-----------------------------
 net/l2tp/l2tp_core.h    |    8 ++--
 net/l2tp/l2tp_debugfs.c |   19 +++----
 3 files changed, 61 insertions(+), 100 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 393355d..1d395ce 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -44,6 +44,7 @@
 #include <linux/udp.h>
 #include <linux/l2tp.h>
 #include <linux/hash.h>
+#include <linux/hashtable.h>
 #include <linux/sort.h>
 #include <linux/file.h>
 #include <linux/nsproxy.h>
@@ -107,8 +108,8 @@ static unsigned int l2tp_net_id;
 struct l2tp_net {
 	struct list_head l2tp_tunnel_list;
 	spinlock_t l2tp_tunnel_list_lock;
-	struct hlist_head l2tp_session_hlist[L2TP_HASH_SIZE_2];
-	spinlock_t l2tp_session_hlist_lock;
+	DEFINE_HASHTABLE(l2tp_session_hash, L2TP_HASH_BITS_2)
+	spinlock_t l2tp_session_hash_lock;
 };
 
 static void l2tp_session_set_header_len(struct l2tp_session *session, int version);
@@ -156,30 +157,17 @@ do {									\
 #define l2tp_tunnel_dec_refcount(t) l2tp_tunnel_dec_refcount_1(t)
 #endif
 
-/* Session hash global list for L2TPv3.
- * The session_id SHOULD be random according to RFC3931, but several
- * L2TP implementations use incrementing session_ids.  So we do a real
- * hash on the session_id, rather than a simple bitmask.
- */
-static inline struct hlist_head *
-l2tp_session_id_hash_2(struct l2tp_net *pn, u32 session_id)
-{
-	return &pn->l2tp_session_hlist[hash_32(session_id, L2TP_HASH_BITS_2)];
-
-}
-
 /* Lookup a session by id in the global session list
  */
 static struct l2tp_session *l2tp_session_find_2(struct net *net, u32 session_id)
 {
 	struct l2tp_net *pn = l2tp_pernet(net);
-	struct hlist_head *session_list =
-		l2tp_session_id_hash_2(pn, session_id);
 	struct l2tp_session *session;
 	struct hlist_node *walk;
 
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(session, walk, session_list, global_hlist) {
+	hash_for_each_possible_rcu(pn->l2tp_session_hash, session, walk,
+					global_hlist, session_id) {
 		if (session->session_id == session_id) {
 			rcu_read_unlock_bh();
 			return session;
@@ -190,23 +178,10 @@ static struct l2tp_session *l2tp_session_find_2(struct net *net, u32 session_id)
 	return NULL;
 }
 
-/* Session hash list.
- * The session_id SHOULD be random according to RFC2661, but several
- * L2TP implementations (Cisco and Microsoft) use incrementing
- * session_ids.  So we do a real hash on the session_id, rather than a
- * simple bitmask.
- */
-static inline struct hlist_head *
-l2tp_session_id_hash(struct l2tp_tunnel *tunnel, u32 session_id)
-{
-	return &tunnel->session_hlist[hash_32(session_id, L2TP_HASH_BITS)];
-}
-
 /* Lookup a session by id
  */
 struct l2tp_session *l2tp_session_find(struct net *net, struct l2tp_tunnel *tunnel, u32 session_id)
 {
-	struct hlist_head *session_list;
 	struct l2tp_session *session;
 	struct hlist_node *walk;
 
@@ -217,15 +192,14 @@ struct l2tp_session *l2tp_session_find(struct net *net, struct l2tp_tunnel *tunn
 	if (tunnel == NULL)
 		return l2tp_session_find_2(net, session_id);
 
-	session_list = l2tp_session_id_hash(tunnel, session_id);
-	read_lock_bh(&tunnel->hlist_lock);
-	hlist_for_each_entry(session, walk, session_list, hlist) {
+	read_lock_bh(&tunnel->hash_lock);
+	hash_for_each_possible(tunnel->session_hash, session, walk, hlist, session_id) {
 		if (session->session_id == session_id) {
-			read_unlock_bh(&tunnel->hlist_lock);
+			read_unlock_bh(&tunnel->hash_lock);
 			return session;
 		}
 	}
-	read_unlock_bh(&tunnel->hlist_lock);
+	read_unlock_bh(&tunnel->hash_lock);
 
 	return NULL;
 }
@@ -238,17 +212,15 @@ struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth)
 	struct l2tp_session *session;
 	int count = 0;
 
-	read_lock_bh(&tunnel->hlist_lock);
-	for (hash = 0; hash < L2TP_HASH_SIZE; hash++) {
-		hlist_for_each_entry(session, walk, &tunnel->session_hlist[hash], hlist) {
-			if (++count > nth) {
-				read_unlock_bh(&tunnel->hlist_lock);
-				return session;
-			}
+	read_lock_bh(&tunnel->hash_lock);
+	hash_for_each(tunnel->session_hash, hash, walk, session, hlist) {
+		if (++count > nth) {
+			read_unlock_bh(&tunnel->hash_lock);
+			return session;
 		}
 	}
 
-	read_unlock_bh(&tunnel->hlist_lock);
+	read_unlock_bh(&tunnel->hash_lock);
 
 	return NULL;
 }
@@ -265,12 +237,10 @@ struct l2tp_session *l2tp_session_find_by_ifname(struct net *net, char *ifname)
 	struct l2tp_session *session;
 
 	rcu_read_lock_bh();
-	for (hash = 0; hash < L2TP_HASH_SIZE_2; hash++) {
-		hlist_for_each_entry_rcu(session, walk, &pn->l2tp_session_hlist[hash], global_hlist) {
-			if (!strcmp(session->ifname, ifname)) {
-				rcu_read_unlock_bh();
-				return session;
-			}
+	hash_for_each_rcu(pn->l2tp_session_hash, hash, walk, session, global_hlist) {
+		if (!strcmp(session->ifname, ifname)) {
+			rcu_read_unlock_bh();
+			return session;
 		}
 	}
 
@@ -1272,7 +1242,7 @@ end:
  */
 static void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
 {
-	int hash;
+	int hash, found = 0;
 	struct hlist_node *walk;
 	struct hlist_node *tmp;
 	struct l2tp_session *session;
@@ -1282,16 +1252,14 @@ static void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
 	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: closing all sessions...\n",
 		  tunnel->name);
 
-	write_lock_bh(&tunnel->hlist_lock);
-	for (hash = 0; hash < L2TP_HASH_SIZE; hash++) {
-again:
-		hlist_for_each_safe(walk, tmp, &tunnel->session_hlist[hash]) {
-			session = hlist_entry(walk, struct l2tp_session, hlist);
-
+	write_lock_bh(&tunnel->hash_lock);
+	do {
+		found = 0;
+		hash_for_each_safe(tunnel->session_hash, hash, walk, tmp, session, hlist) {
 			l2tp_info(session, L2TP_MSG_CONTROL,
 				  "%s: closing session\n", session->name);
 
-			hlist_del_init(&session->hlist);
+			hash_del(&session->hlist);
 
 			/* Since we should hold the sock lock while
 			 * doing any unbinding, we need to release the
@@ -1302,14 +1270,14 @@ again:
 			if (session->ref != NULL)
 				(*session->ref)(session);
 
-			write_unlock_bh(&tunnel->hlist_lock);
+			write_unlock_bh(&tunnel->hash_lock);
 
 			if (tunnel->version != L2TP_HDR_VER_2) {
 				struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
 
-				spin_lock_bh(&pn->l2tp_session_hlist_lock);
-				hlist_del_init_rcu(&session->global_hlist);
-				spin_unlock_bh(&pn->l2tp_session_hlist_lock);
+				spin_lock_bh(&pn->l2tp_session_hash_lock);
+				hash_del_rcu(&session->global_hlist);
+				spin_unlock_bh(&pn->l2tp_session_hash_lock);
 				synchronize_rcu();
 			}
 
@@ -1319,17 +1287,17 @@ again:
 			if (session->deref != NULL)
 				(*session->deref)(session);
 
-			write_lock_bh(&tunnel->hlist_lock);
+			write_lock_bh(&tunnel->hash_lock);
 
 			/* Now restart from the beginning of this hash
 			 * chain.  We always remove a session from the
 			 * list so we are guaranteed to make forward
 			 * progress.
 			 */
-			goto again;
+			found = 1;
 		}
-	}
-	write_unlock_bh(&tunnel->hlist_lock);
+	} while (found);
+	write_unlock_bh(&tunnel->hash_lock);
 }
 
 /* Really kill the tunnel.
@@ -1575,7 +1543,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 
 	tunnel->magic = L2TP_TUNNEL_MAGIC;
 	sprintf(&tunnel->name[0], "tunl %u", tunnel_id);
-	rwlock_init(&tunnel->hlist_lock);
+	rwlock_init(&tunnel->hash_lock);
 
 	/* The net we belong to */
 	tunnel->l2tp_net = net;
@@ -1610,6 +1578,8 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 
 	/* Add tunnel to our list */
 	INIT_LIST_HEAD(&tunnel->list);
+
+	hash_init(tunnel->session_hash);
 	atomic_inc(&l2tp_tunnel_count);
 
 	/* Bump the reference count. The tunnel context is deleted
@@ -1674,17 +1644,17 @@ void l2tp_session_free(struct l2tp_session *session)
 		BUG_ON(tunnel->magic != L2TP_TUNNEL_MAGIC);
 
 		/* Delete the session from the hash */
-		write_lock_bh(&tunnel->hlist_lock);
-		hlist_del_init(&session->hlist);
-		write_unlock_bh(&tunnel->hlist_lock);
+		write_lock_bh(&tunnel->hash_lock);
+		hash_del(&session->hlist);
+		write_unlock_bh(&tunnel->hash_lock);
 
 		/* Unlink from the global hash if not L2TPv2 */
 		if (tunnel->version != L2TP_HDR_VER_2) {
 			struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
 
-			spin_lock_bh(&pn->l2tp_session_hlist_lock);
-			hlist_del_init_rcu(&session->global_hlist);
-			spin_unlock_bh(&pn->l2tp_session_hlist_lock);
+			spin_lock_bh(&pn->l2tp_session_hash_lock);
+			hash_del_rcu(&session->global_hlist);
+			spin_unlock_bh(&pn->l2tp_session_hash_lock);
 			synchronize_rcu();
 		}
 
@@ -1797,19 +1767,17 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 		sock_hold(tunnel->sock);
 
 		/* Add session to the tunnel's hash list */
-		write_lock_bh(&tunnel->hlist_lock);
-		hlist_add_head(&session->hlist,
-			       l2tp_session_id_hash(tunnel, session_id));
-		write_unlock_bh(&tunnel->hlist_lock);
+		write_lock_bh(&tunnel->hash_lock);
+		hash_add(tunnel->session_hash, &session->hlist, session_id);
+		write_unlock_bh(&tunnel->hash_lock);
 
 		/* And to the global session list if L2TPv3 */
 		if (tunnel->version != L2TP_HDR_VER_2) {
 			struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
 
-			spin_lock_bh(&pn->l2tp_session_hlist_lock);
-			hlist_add_head_rcu(&session->global_hlist,
-					   l2tp_session_id_hash_2(pn, session_id));
-			spin_unlock_bh(&pn->l2tp_session_hlist_lock);
+			spin_lock_bh(&pn->l2tp_session_hash_lock);
+			hash_add(pn->l2tp_session_hash, &session->global_hlist, session_id);
+			spin_unlock_bh(&pn->l2tp_session_hash_lock);
 		}
 
 		/* Ignore management session in session count value */
@@ -1828,15 +1796,13 @@ EXPORT_SYMBOL_GPL(l2tp_session_create);
 static __net_init int l2tp_init_net(struct net *net)
 {
 	struct l2tp_net *pn = net_generic(net, l2tp_net_id);
-	int hash;
 
 	INIT_LIST_HEAD(&pn->l2tp_tunnel_list);
 	spin_lock_init(&pn->l2tp_tunnel_list_lock);
 
-	for (hash = 0; hash < L2TP_HASH_SIZE_2; hash++)
-		INIT_HLIST_HEAD(&pn->l2tp_session_hlist[hash]);
+	hash_init(pn->l2tp_session_hash);
 
-	spin_lock_init(&pn->l2tp_session_hlist_lock);
+	spin_lock_init(&pn->l2tp_session_hash_lock);
 
 	return 0;
 }
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a38ec6c..23bf320 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -11,17 +11,17 @@
 #ifndef _L2TP_CORE_H_
 #define _L2TP_CORE_H_
 
+#include <linux/hashtable.h>
+
 /* Just some random numbers */
 #define L2TP_TUNNEL_MAGIC	0x42114DDA
 #define L2TP_SESSION_MAGIC	0x0C04EB7D
 
 /* Per tunnel, session hash table size */
 #define L2TP_HASH_BITS	4
-#define L2TP_HASH_SIZE	(1 << L2TP_HASH_BITS)
 
 /* System-wide, session hash table size */
 #define L2TP_HASH_BITS_2	8
-#define L2TP_HASH_SIZE_2	(1 << L2TP_HASH_BITS_2)
 
 /* Debug message categories for the DEBUG socket option */
 enum {
@@ -163,8 +163,8 @@ struct l2tp_tunnel_cfg {
 
 struct l2tp_tunnel {
 	int			magic;		/* Should be L2TP_TUNNEL_MAGIC */
-	rwlock_t		hlist_lock;	/* protect session_hlist */
-	struct hlist_head	session_hlist[L2TP_HASH_SIZE];
+	rwlock_t		hash_lock;	/* protect session_hash */
+	DEFINE_HASHTABLE(session_hash, L2TP_HASH_BITS);
 						/* hashed list of sessions,
 						 * hashed by id */
 	u32			tunnel_id;
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index c3813bc..655f1fa 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -105,21 +105,16 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 	int session_count = 0;
 	int hash;
 	struct hlist_node *walk;
-	struct hlist_node *tmp;
+	struct l2tp_session *session;
 
-	read_lock_bh(&tunnel->hlist_lock);
-	for (hash = 0; hash < L2TP_HASH_SIZE; hash++) {
-		hlist_for_each_safe(walk, tmp, &tunnel->session_hlist[hash]) {
-			struct l2tp_session *session;
+	read_lock_bh(&tunnel->hash_lock);
+	hash_for_each(tunnel->session_hash, hash, walk, session, hlist) {
+		if (session->session_id == 0)
+			continue;
 
-			session = hlist_entry(walk, struct l2tp_session, hlist);
-			if (session->session_id == 0)
-				continue;
-
-			session_count++;
-		}
+		session_count++;
 	}
-	read_unlock_bh(&tunnel->hlist_lock);
+	read_unlock_bh(&tunnel->hash_lock);
 
 	seq_printf(m, "\nTUNNEL %u peer %u", tunnel->tunnel_id, tunnel->peer_tunnel_id);
 	if (tunnel->sock) {
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
