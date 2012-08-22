Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0BFB86B0098
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 22:28:22 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id x4so779582obh.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 19:28:22 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 14/17] net,rds: use new hashtable implementation
Date: Wed, 22 Aug 2012 04:27:09 +0200
Message-Id: <1345602432-27673-15-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

Switch rds to use the new hashtable implementation. This reduces the amount of
generic unrelated code in rds.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/rds/bind.c       |   28 +++++++++-----
 net/rds/connection.c |  102 ++++++++++++++++++++++----------------------------
 2 files changed, 63 insertions(+), 67 deletions(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index 637bde5..79d65ce 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -36,16 +36,16 @@
 #include <linux/if_arp.h>
 #include <linux/jhash.h>
 #include <linux/ratelimit.h>
+#include <linux/hashtable.h>
 #include "rds.h"
 
-#define BIND_HASH_SIZE 1024
-static struct hlist_head bind_hash_table[BIND_HASH_SIZE];
+#define BIND_HASH_BITS 10
+static DEFINE_HASHTABLE(bind_hash_table, BIND_HASH_BITS);
 static DEFINE_SPINLOCK(rds_bind_lock);
 
-static struct hlist_head *hash_to_bucket(__be32 addr, __be16 port)
+static u32 rds_hash(__be32 addr, __be16 port)
 {
-	return bind_hash_table + (jhash_2words((u32)addr, (u32)port, 0) &
-				  (BIND_HASH_SIZE - 1));
+	return jhash_2words((u32)addr, (u32)port, 0);
 }
 
 static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
@@ -53,12 +53,12 @@ static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
 {
 	struct rds_sock *rs;
 	struct hlist_node *node;
-	struct hlist_head *head = hash_to_bucket(addr, port);
+	u32 key = rds_hash(addr, port);
 	u64 cmp;
 	u64 needle = ((u64)be32_to_cpu(addr) << 32) | be16_to_cpu(port);
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(rs, node, head, rs_bound_node) {
+	hash_for_each_possible_rcu(bind_hash_table, rs, node, rs_bound_node, key) {
 		cmp = ((u64)be32_to_cpu(rs->rs_bound_addr) << 32) |
 		      be16_to_cpu(rs->rs_bound_port);
 
@@ -74,13 +74,13 @@ static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
 		 * make sure our addr and port are set before
 		 * we are added to the list, other people
 		 * in rcu will find us as soon as the
-		 * hlist_add_head_rcu is done
+		 * hash_add_rcu is done
 		 */
 		insert->rs_bound_addr = addr;
 		insert->rs_bound_port = port;
 		rds_sock_addref(insert);
 
-		hlist_add_head_rcu(&insert->rs_bound_node, head);
+		hash_add_rcu(bind_hash_table, &insert->rs_bound_node, key);
 	}
 	return NULL;
 }
@@ -152,7 +152,7 @@ void rds_remove_bound(struct rds_sock *rs)
 		  rs, &rs->rs_bound_addr,
 		  ntohs(rs->rs_bound_port));
 
-		hlist_del_init_rcu(&rs->rs_bound_node);
+		hash_del_rcu(&rs->rs_bound_node);
 		rds_sock_put(rs);
 		rs->rs_bound_addr = 0;
 	}
@@ -202,3 +202,11 @@ out:
 		synchronize_rcu();
 	return ret;
 }
+
+static int __init rds_init(void)
+{
+	hash_init(bind_hash_table);
+	return 0;
+}
+
+module_init(rds_init);
diff --git a/net/rds/connection.c b/net/rds/connection.c
index 9e07c75..5b09ee1 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -34,28 +34,24 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <linux/hashtable.h>
 #include <net/inet_hashtables.h>
 
 #include "rds.h"
 #include "loop.h"
 
 #define RDS_CONNECTION_HASH_BITS 12
-#define RDS_CONNECTION_HASH_ENTRIES (1 << RDS_CONNECTION_HASH_BITS)
-#define RDS_CONNECTION_HASH_MASK (RDS_CONNECTION_HASH_ENTRIES - 1)
 
 /* converting this to RCU is a chore for another day.. */
 static DEFINE_SPINLOCK(rds_conn_lock);
 static unsigned long rds_conn_count;
-static struct hlist_head rds_conn_hash[RDS_CONNECTION_HASH_ENTRIES];
+static DEFINE_HASHTABLE(rds_conn_hash, RDS_CONNECTION_HASH_BITS);
 static struct kmem_cache *rds_conn_slab;
 
-static struct hlist_head *rds_conn_bucket(__be32 laddr, __be32 faddr)
+static unsigned long rds_conn_hashfn(__be32 laddr, __be32 faddr)
 {
 	/* Pass NULL, don't need struct net for hash */
-	unsigned long hash = inet_ehashfn(NULL,
-					  be32_to_cpu(laddr), 0,
-					  be32_to_cpu(faddr), 0);
-	return &rds_conn_hash[hash & RDS_CONNECTION_HASH_MASK];
+	return inet_ehashfn(NULL,  be32_to_cpu(laddr), 0,  be32_to_cpu(faddr), 0);
 }
 
 #define rds_conn_info_set(var, test, suffix) do {		\
@@ -64,14 +60,14 @@ static struct hlist_head *rds_conn_bucket(__be32 laddr, __be32 faddr)
 } while (0)
 
 /* rcu read lock must be held or the connection spinlock */
-static struct rds_connection *rds_conn_lookup(struct hlist_head *head,
-					      __be32 laddr, __be32 faddr,
+static struct rds_connection *rds_conn_lookup(__be32 laddr, __be32 faddr,
 					      struct rds_transport *trans)
 {
 	struct rds_connection *conn, *ret = NULL;
 	struct hlist_node *pos;
+	unsigned long key = rds_conn_hashfn(laddr, faddr);
 
-	hlist_for_each_entry_rcu(conn, pos, head, c_hash_node) {
+	hash_for_each_possible_rcu(rds_conn_hash, conn, pos, c_hash_node, key) {
 		if (conn->c_faddr == faddr && conn->c_laddr == laddr &&
 				conn->c_trans == trans) {
 			ret = conn;
@@ -117,13 +113,12 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 				       int is_outgoing)
 {
 	struct rds_connection *conn, *parent = NULL;
-	struct hlist_head *head = rds_conn_bucket(laddr, faddr);
 	struct rds_transport *loop_trans;
 	unsigned long flags;
 	int ret;
 
 	rcu_read_lock();
-	conn = rds_conn_lookup(head, laddr, faddr, trans);
+	conn = rds_conn_lookup(laddr, faddr, trans);
 	if (conn && conn->c_loopback && conn->c_trans != &rds_loop_transport &&
 	    !is_outgoing) {
 		/* This is a looped back IB connection, and we're
@@ -224,13 +219,15 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 		/* Creating normal conn */
 		struct rds_connection *found;
 
-		found = rds_conn_lookup(head, laddr, faddr, trans);
+		found = rds_conn_lookup(laddr, faddr, trans);
 		if (found) {
 			trans->conn_free(conn->c_transport_data);
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = found;
 		} else {
-			hlist_add_head_rcu(&conn->c_hash_node, head);
+			unsigned long key = rds_conn_hashfn(laddr, faddr);
+
+			hash_add_rcu(rds_conn_hash, &conn->c_hash_node, key);
 			rds_cong_add_conn(conn);
 			rds_conn_count++;
 		}
@@ -303,7 +300,7 @@ void rds_conn_shutdown(struct rds_connection *conn)
 	 * conn - the reconnect is always triggered by the active peer. */
 	cancel_delayed_work_sync(&conn->c_conn_w);
 	rcu_read_lock();
-	if (!hlist_unhashed(&conn->c_hash_node)) {
+	if (hash_hashed(&conn->c_hash_node)) {
 		rcu_read_unlock();
 		rds_queue_reconnect(conn);
 	} else {
@@ -329,7 +326,7 @@ void rds_conn_destroy(struct rds_connection *conn)
 
 	/* Ensure conn will not be scheduled for reconnect */
 	spin_lock_irq(&rds_conn_lock);
-	hlist_del_init_rcu(&conn->c_hash_node);
+	hash_del(&conn->c_hash_node);
 	spin_unlock_irq(&rds_conn_lock);
 	synchronize_rcu();
 
@@ -375,7 +372,6 @@ static void rds_conn_message_info(struct socket *sock, unsigned int len,
 				  struct rds_info_lengths *lens,
 				  int want_send)
 {
-	struct hlist_head *head;
 	struct hlist_node *pos;
 	struct list_head *list;
 	struct rds_connection *conn;
@@ -388,27 +384,24 @@ static void rds_conn_message_info(struct socket *sock, unsigned int len,
 
 	rcu_read_lock();
 
-	for (i = 0, head = rds_conn_hash; i < ARRAY_SIZE(rds_conn_hash);
-	     i++, head++) {
-		hlist_for_each_entry_rcu(conn, pos, head, c_hash_node) {
-			if (want_send)
-				list = &conn->c_send_queue;
-			else
-				list = &conn->c_retrans;
-
-			spin_lock_irqsave(&conn->c_lock, flags);
-
-			/* XXX too lazy to maintain counts.. */
-			list_for_each_entry(rm, list, m_conn_item) {
-				total++;
-				if (total <= len)
-					rds_inc_info_copy(&rm->m_inc, iter,
-							  conn->c_laddr,
-							  conn->c_faddr, 0);
-			}
-
-			spin_unlock_irqrestore(&conn->c_lock, flags);
+	hash_for_each_rcu(rds_conn_hash, i, pos, conn, c_hash_node) {
+		if (want_send)
+			list = &conn->c_send_queue;
+		else
+			list = &conn->c_retrans;
+
+		spin_lock_irqsave(&conn->c_lock, flags);
+
+		/* XXX too lazy to maintain counts.. */
+		list_for_each_entry(rm, list, m_conn_item) {
+			total++;
+			if (total <= len)
+				rds_inc_info_copy(&rm->m_inc, iter,
+						  conn->c_laddr,
+						  conn->c_faddr, 0);
 		}
+
+		spin_unlock_irqrestore(&conn->c_lock, flags);
 	}
 	rcu_read_unlock();
 
@@ -438,7 +431,6 @@ void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 			  size_t item_len)
 {
 	uint64_t buffer[(item_len + 7) / 8];
-	struct hlist_head *head;
 	struct hlist_node *pos;
 	struct rds_connection *conn;
 	size_t i;
@@ -448,23 +440,19 @@ void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 	lens->nr = 0;
 	lens->each = item_len;
 
-	for (i = 0, head = rds_conn_hash; i < ARRAY_SIZE(rds_conn_hash);
-	     i++, head++) {
-		hlist_for_each_entry_rcu(conn, pos, head, c_hash_node) {
-
-			/* XXX no c_lock usage.. */
-			if (!visitor(conn, buffer))
-				continue;
-
-			/* We copy as much as we can fit in the buffer,
-			 * but we count all items so that the caller
-			 * can resize the buffer. */
-			if (len >= item_len) {
-				rds_info_copy(iter, buffer, item_len);
-				len -= item_len;
-			}
-			lens->nr++;
+	hash_for_each_rcu(rds_conn_hash, i, pos, conn, c_hash_node) {
+		/* XXX no c_lock usage.. */
+		if (!visitor(conn, buffer))
+			continue;
+
+		/* We copy as much as we can fit in the buffer,
+		 * but we count all items so that the caller
+		 * can resize the buffer. */
+		if (len >= item_len) {
+			rds_info_copy(iter, buffer, item_len);
+			len -= item_len;
 		}
+		lens->nr++;
 	}
 	rcu_read_unlock();
 }
@@ -518,6 +506,8 @@ int rds_conn_init(void)
 	rds_info_register_func(RDS_INFO_RETRANS_MESSAGES,
 			       rds_conn_message_info_retrans);
 
+	hash_init(rds_conn_hash);
+
 	return 0;
 }
 
@@ -525,8 +515,6 @@ void rds_conn_exit(void)
 {
 	rds_loop_exit();
 
-	WARN_ON(!hlist_empty(rds_conn_hash));
-
 	kmem_cache_destroy(rds_conn_slab);
 
 	rds_info_deregister_func(RDS_INFO_CONNECTIONS, rds_conn_info);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
