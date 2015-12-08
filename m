Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 791956B025C
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:31:09 -0500 (EST)
Received: by wmww144 with SMTP id w144so34327592wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:31:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q5si4955732wjq.6.2015.12.08.07.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 07:31:08 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 08/14] net: tcp_memcontrol: simplify linkage between socket and page counter
Date: Tue,  8 Dec 2015 10:30:18 -0500
Message-Id: <1449588624-9220-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

There won't be any separate counters for socket memory consumed by
protocols other than TCP in the future. Remove the indirection and
link sockets directly to their owning memory cgroup.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/linux/memcontrol.h   | 20 ++++---------
 include/net/sock.h           | 36 +++---------------------
 include/net/tcp.h            |  4 +--
 include/net/tcp_memcontrol.h |  1 -
 mm/memcontrol.c              | 57 +++++++++++++++----------------------
 net/core/sock.c              | 52 +++++-----------------------------
 net/ipv4/tcp_ipv4.c          |  7 +----
 net/ipv4/tcp_memcontrol.c    | 67 +++++++++++++++++---------------------------
 net/ipv4/tcp_output.c        |  4 +--
 net/ipv6/tcp_ipv6.c          |  3 --
 10 files changed, 69 insertions(+), 182 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ef3f584..daf6dbe 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -89,16 +89,6 @@ struct cg_proto {
 	struct page_counter	memory_allocated;	/* Current allocated memory. */
 	int			memory_pressure;
 	bool			active;
-	/*
-	 * memcg field is used to find which memcg we belong directly
-	 * Each memcg struct can hold more than one cg_proto, so container_of
-	 * won't really cut.
-	 *
-	 * The elegant solution would be having an inverse function to
-	 * proto_cgroup in struct proto, but that means polluting the structure
-	 * for everybody, instead of just for memcg users.
-	 */
-	struct mem_cgroup	*memcg;
 };
 
 #ifdef CONFIG_MEMCG
@@ -692,15 +682,15 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 struct sock;
 void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
-bool mem_cgroup_charge_skmem(struct cg_proto *proto, unsigned int nr_pages);
-void mem_cgroup_uncharge_skmem(struct cg_proto *proto, unsigned int nr_pages);
+bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
+void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
-static inline bool mem_cgroup_under_socket_pressure(struct cg_proto *proto)
+static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
-	return proto->memory_pressure;
+	return memcg->tcp_mem.memory_pressure;
 }
 #else
-static inline bool mem_cgroup_under_pressure(struct cg_proto *proto)
+static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 	return false;
 }
diff --git a/include/net/sock.h b/include/net/sock.h
index 888aa3f..1a94b85 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -69,22 +69,6 @@
 #include <net/tcp_states.h>
 #include <linux/net_tstamp.h>
 
-struct cgroup;
-struct cgroup_subsys;
-#ifdef CONFIG_NET
-int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
-void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg);
-#else
-static inline
-int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
-{
-	return 0;
-}
-static inline
-void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
-{
-}
-#endif
 /*
  * This structure really needs to be cleaned up.
  * Most of it is for TCP, and not used by any of
@@ -310,7 +294,7 @@ struct cg_proto;
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
   *	@sk_classid: this socket's cgroup classid
-  *	@sk_cgrp: this socket's cgroup-specific proto data
+  *	@sk_memcg: this socket's memory cgroup association
   *	@sk_write_pending: a write to stream socket waits to start
   *	@sk_state_change: callback to indicate change in the state of the sock
   *	@sk_data_ready: callback to indicate there is data to be processed
@@ -447,7 +431,7 @@ struct sock {
 #ifdef CONFIG_CGROUP_NET_CLASSID
 	u32			sk_classid;
 #endif
-	struct cg_proto		*sk_cgrp;
+	struct mem_cgroup	*sk_memcg;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk);
 	void			(*sk_write_space)(struct sock *sk);
@@ -1051,18 +1035,6 @@ struct proto {
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
-#ifdef CONFIG_MEMCG_KMEM
-	/*
-	 * cgroup specific init/deinit functions. Called once for all
-	 * protocols that implement it, from cgroups populate function.
-	 * This function has to setup any files the protocol want to
-	 * appear in the kmem cgroup filesystem.
-	 */
-	int			(*init_cgroup)(struct mem_cgroup *memcg,
-					       struct cgroup_subsys *ss);
-	void			(*destroy_cgroup)(struct mem_cgroup *memcg);
-	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
-#endif
 };
 
 int proto_register(struct proto *prot, int alloc_slab);
@@ -1126,8 +1098,8 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
 	if (!sk->sk_prot->memory_pressure)
 		return false;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
-	    mem_cgroup_under_socket_pressure(sk->sk_cgrp))
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg &&
+	    mem_cgroup_under_socket_pressure(sk->sk_memcg))
 		return true;
 
 	return !!*sk->sk_prot->memory_pressure;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 04517d6..c008535 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -292,8 +292,8 @@ extern int tcp_memory_pressure;
 /* optimized version of sk_under_memory_pressure() for TCP sockets */
 static inline bool tcp_under_memory_pressure(const struct sock *sk)
 {
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
-	    mem_cgroup_under_socket_pressure(sk->sk_cgrp))
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg &&
+	    mem_cgroup_under_socket_pressure(sk->sk_memcg))
 		return true;
 
 	return tcp_memory_pressure;
diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index 05b94d9..3a17b16 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -1,7 +1,6 @@
 #ifndef _TCP_MEMCG_H
 #define _TCP_MEMCG_H
 
-struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
 void tcp_destroy_cgroup(struct mem_cgroup *memcg);
 #endif /* _TCP_MEMCG_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4b586ea..68d67fc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -294,9 +294,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 void sock_update_memcg(struct sock *sk)
 {
 	struct mem_cgroup *memcg;
-	struct cg_proto *cg_proto;
-
-	BUG_ON(!sk->sk_prot->proto_cgroup);
 
 	/* Socket cloning can throw us here with sk_cgrp already
 	 * filled. It won't however, necessarily happen from
@@ -306,68 +303,58 @@ void sock_update_memcg(struct sock *sk)
 	 * Respecting the original socket's memcg is a better
 	 * decision in this case.
 	 */
-	if (sk->sk_cgrp) {
-		BUG_ON(mem_cgroup_is_root(sk->sk_cgrp->memcg));
-		css_get(&sk->sk_cgrp->memcg->css);
+	if (sk->sk_memcg) {
+		BUG_ON(mem_cgroup_is_root(sk->sk_memcg));
+		css_get(&sk->sk_memcg->css);
 		return;
 	}
 
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(current);
-	cg_proto = sk->sk_prot->proto_cgroup(memcg);
-	if (cg_proto && cg_proto->active &&
-	    css_tryget_online(&memcg->css)) {
-		sk->sk_cgrp = cg_proto;
-	}
+	if (memcg != root_mem_cgroup &&
+	    memcg->tcp_mem.active &&
+	    css_tryget_online(&memcg->css))
+		sk->sk_memcg = memcg;
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL(sock_update_memcg);
 
 void sock_release_memcg(struct sock *sk)
 {
-	WARN_ON(!sk->sk_cgrp->memcg);
-	css_put(&sk->sk_cgrp->memcg->css);
-}
-
-struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
-{
-	if (!memcg || mem_cgroup_is_root(memcg))
-		return NULL;
-
-	return &memcg->tcp_mem;
+	WARN_ON(!sk->sk_memcg);
+	css_put(&sk->sk_memcg->css);
 }
-EXPORT_SYMBOL(tcp_proto_cgroup);
 
 /**
  * mem_cgroup_charge_skmem - charge socket memory
- * @proto: proto to charge
+ * @memcg: memcg to charge
  * @nr_pages: number of pages to charge
  *
- * Charges @nr_pages to @proto. Returns %true if the charge fit within
- * @proto's configured limit, %false if the charge had to be forced.
+ * Charges @nr_pages to @memcg. Returns %true if the charge fit within
+ * @memcg's configured limit, %false if the charge had to be forced.
  */
-bool mem_cgroup_charge_skmem(struct cg_proto *proto, unsigned int nr_pages)
+bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	struct page_counter *counter;
 
-	if (page_counter_try_charge(&proto->memory_allocated,
+	if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
 				    nr_pages, &counter)) {
-		proto->memory_pressure = 0;
+		memcg->tcp_mem.memory_pressure = 0;
 		return true;
 	}
-	page_counter_charge(&proto->memory_allocated, nr_pages);
-	proto->memory_pressure = 1;
+	page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
+	memcg->tcp_mem.memory_pressure = 1;
 	return false;
 }
 
 /**
  * mem_cgroup_uncharge_skmem - uncharge socket memory
- * @proto - proto to uncharge
+ * @memcg - memcg to uncharge
  * @nr_pages - number of pages to uncharge
  */
-void mem_cgroup_uncharge_skmem(struct cg_proto *proto, unsigned int nr_pages)
+void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-	page_counter_uncharge(&proto->memory_allocated, nr_pages);
+	page_counter_uncharge(&memcg->tcp_mem.memory_allocated, nr_pages);
 }
 
 #endif
@@ -3629,7 +3616,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	if (ret)
 		return ret;
 
-	return mem_cgroup_sockets_init(memcg, ss);
+	return tcp_init_cgroup(memcg, ss);
 }
 
 static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
@@ -3685,7 +3672,7 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 		static_key_slow_dec(&memcg_kmem_enabled_key);
 		WARN_ON(page_counter_read(&memcg->kmem));
 	}
-	mem_cgroup_sockets_destroy(memcg);
+	tcp_destroy_cgroup(memcg);
 }
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
diff --git a/net/core/sock.c b/net/core/sock.c
index 5b1b96f..6486b0d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -194,44 +194,6 @@ bool sk_net_capable(const struct sock *sk, int cap)
 }
 EXPORT_SYMBOL(sk_net_capable);
 
-
-#ifdef CONFIG_MEMCG_KMEM
-int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
-{
-	struct proto *proto;
-	int ret = 0;
-
-	mutex_lock(&proto_list_mutex);
-	list_for_each_entry(proto, &proto_list, node) {
-		if (proto->init_cgroup) {
-			ret = proto->init_cgroup(memcg, ss);
-			if (ret)
-				goto out;
-		}
-	}
-
-	mutex_unlock(&proto_list_mutex);
-	return ret;
-out:
-	list_for_each_entry_continue_reverse(proto, &proto_list, node)
-		if (proto->destroy_cgroup)
-			proto->destroy_cgroup(memcg);
-	mutex_unlock(&proto_list_mutex);
-	return ret;
-}
-
-void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
-{
-	struct proto *proto;
-
-	mutex_lock(&proto_list_mutex);
-	list_for_each_entry_reverse(proto, &proto_list, node)
-		if (proto->destroy_cgroup)
-			proto->destroy_cgroup(memcg);
-	mutex_unlock(&proto_list_mutex);
-}
-#endif
-
 /*
  * Each address family might have different locking rules, so we have
  * one slock key per address family:
@@ -1583,7 +1545,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		sk_set_socket(newsk, NULL);
 		newsk->sk_wq = NULL;
 
-		if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		if (mem_cgroup_sockets_enabled && sk->sk_memcg)
 			sock_update_memcg(newsk);
 
 		if (newsk->sk_prot->sockets_allocated)
@@ -2071,8 +2033,8 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 
 	allocated = sk_memory_allocated_add(sk, amt);
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
-	    !mem_cgroup_charge_skmem(sk->sk_cgrp, amt))
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg &&
+	    !mem_cgroup_charge_skmem(sk->sk_memcg, amt))
 		goto suppress_allocation;
 
 	/* Under limit. */
@@ -2135,8 +2097,8 @@ suppress_allocation:
 
 	sk_memory_allocated_sub(sk, amt);
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		mem_cgroup_uncharge_skmem(sk->sk_cgrp, amt);
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
+		mem_cgroup_uncharge_skmem(sk->sk_memcg, amt);
 
 	return 0;
 }
@@ -2153,8 +2115,8 @@ void __sk_mem_reclaim(struct sock *sk, int amount)
 	sk_memory_allocated_sub(sk, amount);
 	sk->sk_forward_alloc -= amount << SK_MEM_QUANTUM_SHIFT;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		mem_cgroup_uncharge_skmem(sk->sk_cgrp, amount);
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
+		mem_cgroup_uncharge_skmem(sk->sk_memcg, amount);
 
 	if (sk_under_memory_pressure(sk) &&
 	    (sk_memory_allocated(sk) < sk_prot_mem_limits(sk, 0)))
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4027e02..34c2678 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1814,7 +1814,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 
 	sk_sockets_allocated_dec(sk);
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
 		sock_release_memcg(sk);
 }
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
@@ -2339,11 +2339,6 @@ struct proto tcp_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
-#ifdef CONFIG_MEMCG_KMEM
-	.init_cgroup		= tcp_init_cgroup,
-	.destroy_cgroup		= tcp_destroy_cgroup,
-	.proto_cgroup		= tcp_proto_cgroup,
-#endif
 };
 EXPORT_SYMBOL(tcp_prot);
 
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index ef4268d..e507825 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -8,60 +8,47 @@
 
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
+	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+	struct page_counter *counter_parent = NULL;
 	/*
 	 * The root cgroup does not use page_counters, but rather,
 	 * rely on the data already collected by the network
 	 * subsystem
 	 */
-	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
-	struct page_counter *counter_parent = NULL;
-	struct cg_proto *cg_proto, *parent_cg;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
+	if (memcg == root_mem_cgroup)
 		return 0;
 
-	cg_proto->memory_pressure = 0;
-	cg_proto->memcg = memcg;
+	memcg->tcp_mem.memory_pressure = 0;
 
-	parent_cg = tcp_prot.proto_cgroup(parent);
-	if (parent_cg)
-		counter_parent = &parent_cg->memory_allocated;
+	if (parent)
+		counter_parent = &parent->tcp_mem.memory_allocated;
 
-	page_counter_init(&cg_proto->memory_allocated, counter_parent);
+	page_counter_init(&memcg->tcp_mem.memory_allocated, counter_parent);
 
 	return 0;
 }
-EXPORT_SYMBOL(tcp_init_cgroup);
 
 void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 {
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
+	if (memcg == root_mem_cgroup)
 		return;
 
-	if (cg_proto->active)
+	if (memcg->tcp_mem.active)
 		static_key_slow_dec(&memcg_socket_limit_enabled);
-
 }
-EXPORT_SYMBOL(tcp_destroy_cgroup);
 
 static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 {
-	struct cg_proto *cg_proto;
 	int ret;
 
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
+	if (memcg == root_mem_cgroup)
 		return -EINVAL;
 
-	ret = page_counter_limit(&cg_proto->memory_allocated, nr_pages);
+	ret = page_counter_limit(&memcg->tcp_mem.memory_allocated, nr_pages);
 	if (ret)
 		return ret;
 
-	if (!cg_proto->active) {
+	if (!memcg->tcp_mem.active) {
 		/*
 		 * The active flag needs to be written after the static_key
 		 * update. This is what guarantees that the socket activation
@@ -79,7 +66,7 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 		 * patched in yet.
 		 */
 		static_key_slow_inc(&memcg_socket_limit_enabled);
-		cg_proto->active = true;
+		memcg->tcp_mem.active = true;
 	}
 
 	return 0;
@@ -123,32 +110,32 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	struct cg_proto *cg_proto = tcp_prot.proto_cgroup(memcg);
 	u64 val;
 
 	switch (cft->private) {
 	case RES_LIMIT:
-		if (!cg_proto)
-			return PAGE_COUNTER_MAX;
-		val = cg_proto->memory_allocated.limit;
+		if (memcg == root_mem_cgroup)
+			val = PAGE_COUNTER_MAX;
+		else
+			val = memcg->tcp_mem.memory_allocated.limit;
 		val *= PAGE_SIZE;
 		break;
 	case RES_USAGE:
-		if (!cg_proto)
+		if (memcg == root_mem_cgroup)
 			val = atomic_long_read(&tcp_memory_allocated);
 		else
-			val = page_counter_read(&cg_proto->memory_allocated);
+			val = page_counter_read(&memcg->tcp_mem.memory_allocated);
 		val *= PAGE_SIZE;
 		break;
 	case RES_FAILCNT:
-		if (!cg_proto)
+		if (memcg == root_mem_cgroup)
 			return 0;
-		val = cg_proto->memory_allocated.failcnt;
+		val = memcg->tcp_mem.memory_allocated.failcnt;
 		break;
 	case RES_MAX_USAGE:
-		if (!cg_proto)
+		if (memcg == root_mem_cgroup)
 			return 0;
-		val = cg_proto->memory_allocated.watermark;
+		val = memcg->tcp_mem.memory_allocated.watermark;
 		val *= PAGE_SIZE;
 		break;
 	default:
@@ -161,19 +148,17 @@ static ssize_t tcp_cgroup_reset(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg;
-	struct cg_proto *cg_proto;
 
 	memcg = mem_cgroup_from_css(of_css(of));
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
+	if (memcg == root_mem_cgroup)
 		return nbytes;
 
 	switch (of_cft(of)->private) {
 	case RES_MAX_USAGE:
-		page_counter_reset_watermark(&cg_proto->memory_allocated);
+		page_counter_reset_watermark(&memcg->tcp_mem.memory_allocated);
 		break;
 	case RES_FAILCNT:
-		cg_proto->memory_allocated.failcnt = 0;
+		memcg->tcp_mem.memory_allocated.failcnt = 0;
 		break;
 	}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7aa168a..7b83a65 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2821,8 +2821,8 @@ void sk_forced_mem_schedule(struct sock *sk, int size)
 	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
 	sk_memory_allocated_add(sk, amt);
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		mem_cgroup_charge_skmem(sk->sk_cgrp, amt);
+	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
+		mem_cgroup_charge_skmem(sk->sk_memcg, amt);
 }
 
 /* Send a FIN. The caller locks the socket for us.
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c5429a6..1bfb682 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1880,9 +1880,6 @@ struct proto tcpv6_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
-#ifdef CONFIG_MEMCG_KMEM
-	.proto_cgroup		= tcp_proto_cgroup,
-#endif
 	.clear_sk		= tcp_v6_clear_sk,
 };
 
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
