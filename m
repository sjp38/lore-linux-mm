Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2B26B025B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:52:50 -0500 (EST)
Received: by wmec201 with SMTP id c201so229830101wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:52:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id it3si29779827wjb.195.2015.11.24.13.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:52:49 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 05/13] net: tcp_memcontrol: remove dead per-memcg count of allocated sockets
Date: Tue, 24 Nov 2015 16:51:57 -0500
Message-Id: <1448401925-22501-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The number of allocated sockets is used for calculations in the soft
limit phase, where packets are accepted but the socket is under memory
pressure. Since there is no soft limit phase in tcp_memcontrol, and
memory pressure is only entered when packets are already dropped, this
is actually dead code. Remove it.

As this is the last user of parent_cg_proto(), remove that too.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: David S. Miller <davem@davemloft.net>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h |  1 -
 include/net/sock.h         | 39 +++------------------------------------
 net/ipv4/tcp_memcontrol.c  |  3 ---
 3 files changed, 3 insertions(+), 40 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 724b76a..cc45407 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -87,7 +87,6 @@ enum mem_cgroup_events_target {
 
 struct cg_proto {
 	struct page_counter	memory_allocated;	/* Current allocated memory. */
-	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
 	int			memory_pressure;
 	bool			active;
 	long			sysctl_mem[3];
diff --git a/include/net/sock.h b/include/net/sock.h
index e27a8bb..7afbdab 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1095,19 +1095,9 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_NET)
 extern struct static_key memcg_socket_limit_enabled;
-static inline struct cg_proto *parent_cg_proto(struct proto *proto,
-					       struct cg_proto *cg_proto)
-{
-	return proto->proto_cgroup(parent_mem_cgroup(cg_proto->memcg));
-}
 #define mem_cgroup_sockets_enabled static_key_false(&memcg_socket_limit_enabled)
 #else
 #define mem_cgroup_sockets_enabled 0
-static inline struct cg_proto *parent_cg_proto(struct proto *proto,
-					       struct cg_proto *cg_proto)
-{
-	return NULL;
-}
 #endif
 
 static inline bool sk_stream_memory_free(const struct sock *sk)
@@ -1233,41 +1223,18 @@ sk_memory_allocated_sub(struct sock *sk, int amt)
 
 static inline void sk_sockets_allocated_dec(struct sock *sk)
 {
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct cg_proto *cg_proto = sk->sk_cgrp;
-
-		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			percpu_counter_dec(&cg_proto->sockets_allocated);
-	}
-
-	percpu_counter_dec(prot->sockets_allocated);
+	percpu_counter_dec(sk->sk_prot->sockets_allocated);
 }
 
 static inline void sk_sockets_allocated_inc(struct sock *sk)
 {
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct cg_proto *cg_proto = sk->sk_cgrp;
-
-		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			percpu_counter_inc(&cg_proto->sockets_allocated);
-	}
-
-	percpu_counter_inc(prot->sockets_allocated);
+	percpu_counter_inc(sk->sk_prot->sockets_allocated);
 }
 
 static inline int
 sk_sockets_allocated_read_positive(struct sock *sk)
 {
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return percpu_counter_read_positive(&sk->sk_cgrp->sockets_allocated);
-
-	return percpu_counter_read_positive(prot->sockets_allocated);
+	return percpu_counter_read_positive(sk->sk_prot->sockets_allocated);
 }
 
 static inline int
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index d07579a..6759e0d 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -32,7 +32,6 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 		counter_parent = &parent_cg->memory_allocated;
 
 	page_counter_init(&cg_proto->memory_allocated, counter_parent);
-	percpu_counter_init(&cg_proto->sockets_allocated, 0, GFP_KERNEL);
 
 	return 0;
 }
@@ -46,8 +45,6 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 	if (!cg_proto)
 		return;
 
-	percpu_counter_destroy(&cg_proto->sockets_allocated);
-
 	if (cg_proto->active)
 		static_key_slow_dec(&memcg_socket_limit_enabled);
 
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
