Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AFBC26B0258
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 18:42:15 -0500 (EST)
Received: by wmww144 with SMTP id w144so8227552wmw.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:42:15 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hp9si6450543wjb.144.2015.11.12.15.42.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 15:42:14 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 05/14] net: tcp_memcontrol: protect all tcp_memcontrol calls by jump-label
Date: Thu, 12 Nov 2015 18:41:24 -0500
Message-Id: <1447371693-25143-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Move the jump-label from sock_update_memcg() and sock_release_memcg()
to the callsite, and so eliminate those function calls when socket
accounting is not enabled.

This also eliminates the need for dummy functions because the calls
will be optimized away if the Kconfig options are not enabled.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  9 +-------
 mm/memcontrol.c            | 56 +++++++++++++++++++++-------------------------
 net/core/sock.c            |  9 ++------
 net/ipv4/tcp.c             |  3 ++-
 net/ipv4/tcp_ipv4.c        |  4 +++-
 5 files changed, 33 insertions(+), 48 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 251bb51..e930803 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -709,17 +709,10 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
-struct sock;
 #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+struct sock;
 void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
-#else
-static inline void sock_update_memcg(struct sock *sk)
-{
-}
-static inline void sock_release_memcg(struct sock *sk)
-{
-}
 #endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_MEMCG_KMEM
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a5d2586..57f4539 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -293,46 +293,40 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 
 void sock_update_memcg(struct sock *sk)
 {
-	if (mem_cgroup_sockets_enabled) {
-		struct mem_cgroup *memcg;
-		struct cg_proto *cg_proto;
+	struct mem_cgroup *memcg;
+	struct cg_proto *cg_proto;
 
-		BUG_ON(!sk->sk_prot->proto_cgroup);
+	BUG_ON(!sk->sk_prot->proto_cgroup);
 
-		/* Socket cloning can throw us here with sk_cgrp already
-		 * filled. It won't however, necessarily happen from
-		 * process context. So the test for root memcg given
-		 * the current task's memcg won't help us in this case.
-		 *
-		 * Respecting the original socket's memcg is a better
-		 * decision in this case.
-		 */
-		if (sk->sk_cgrp) {
-			BUG_ON(mem_cgroup_is_root(sk->sk_cgrp->memcg));
-			css_get(&sk->sk_cgrp->memcg->css);
-			return;
-		}
+	/* Socket cloning can throw us here with sk_cgrp already
+	 * filled. It won't however, necessarily happen from
+	 * process context. So the test for root memcg given
+	 * the current task's memcg won't help us in this case.
+	 *
+	 * Respecting the original socket's memcg is a better
+	 * decision in this case.
+	 */
+	if (sk->sk_cgrp) {
+		BUG_ON(mem_cgroup_is_root(sk->sk_cgrp->memcg));
+		css_get(&sk->sk_cgrp->memcg->css);
+		return;
+	}
 
-		rcu_read_lock();
-		memcg = mem_cgroup_from_task(current);
-		cg_proto = sk->sk_prot->proto_cgroup(memcg);
-		if (cg_proto && test_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags) &&
-		    css_tryget_online(&memcg->css)) {
-			sk->sk_cgrp = cg_proto;
-		}
-		rcu_read_unlock();
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	cg_proto = sk->sk_prot->proto_cgroup(memcg);
+	if (cg_proto && test_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags) &&
+	    css_tryget_online(&memcg->css)) {
+		sk->sk_cgrp = cg_proto;
 	}
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL(sock_update_memcg);
 
 void sock_release_memcg(struct sock *sk)
 {
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct mem_cgroup *memcg;
-		WARN_ON(!sk->sk_cgrp->memcg);
-		memcg = sk->sk_cgrp->memcg;
-		css_put(&sk->sk_cgrp->memcg->css);
-	}
+	WARN_ON(!sk->sk_cgrp->memcg);
+	css_put(&sk->sk_cgrp->memcg->css);
 }
 
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e4dd54..04e54bc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1488,12 +1488,6 @@ void sk_free(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_free);
 
-static void sk_update_clone(const struct sock *sk, struct sock *newsk)
-{
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		sock_update_memcg(newsk);
-}
-
 /**
  *	sk_clone_lock - clone a socket, and lock its clone
  *	@sk: the socket to clone
@@ -1589,7 +1583,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		sk_set_socket(newsk, NULL);
 		newsk->sk_wq = NULL;
 
-		sk_update_clone(sk, newsk);
+		if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+			sock_update_memcg(newsk);
 
 		if (newsk->sk_prot->sockets_allocated)
 			sk_sockets_allocated_inc(newsk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0cfa7c0..1b324606 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -422,7 +422,8 @@ void tcp_init_sock(struct sock *sk)
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
 	local_bh_disable();
-	sock_update_memcg(sk);
+	if (mem_cgroup_sockets_enabled)
+		sock_update_memcg(sk);
 	sk_sockets_allocated_inc(sk);
 	local_bh_enable();
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 950e28c..317a246 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1812,7 +1812,9 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	tcp_saved_syn_free(tp);
 
 	sk_sockets_allocated_dec(sk);
-	sock_release_memcg(sk);
+
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		sock_release_memcg(sk);
 }
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
 
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
