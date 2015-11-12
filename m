Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C793E6B025B
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 18:42:24 -0500 (EST)
Received: by wmvv187 with SMTP id v187so57721324wmv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:42:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id wg1si21728363wjb.38.2015.11.12.15.42.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 15:42:23 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 08/14] net: tcp_memcontrol: sanitize tcp memory accounting callbacks
Date: Thu, 12 Nov 2015 18:41:27 -0500
Message-Id: <1447371693-25143-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

There won't be a tcp control soft limit, so integrating the memcg code
into the global skmem limiting scheme complicates things
unnecessarily. Replace this with simple and clear charge and uncharge
calls--hidden behind a jump label--to account skb memory.

Note that this is not purely aesthetic: as a result of shoehorning the
per-memcg code into the same memory accounting functions that handle
the global level, the old code would compare the per-memcg consumption
against the smaller of the per-memcg limit and the global limit. This
allowed the total consumption of multiple sockets to exceed the global
limit, as long as the individual sockets stayed within bounds. After
this change, the code will always compare the per-memcg consumption to
the per-memcg limit, and the global consumption to the global limit,
and thus close this loophole.

Without a soft limit, the per-memcg memory pressure state in sockets
is generally questionable. However, we did it until now, so we
continue to enter it when the hard limit is hit, and packets are
dropped, to let other sockets in the cgroup know that they shouldn't
grow their transmit windows, either. However, keep it simple in the
new callback model and leave memory pressure lazily when the next
packet is accepted (as opposed to doing it synchroneously when packets
are processed). When packets are dropped, network performance will
already be in the toilet, so that should be a reasonable trade-off.

As described above, consumption is now checked on the per-memcg level
and the global level separately. Likewise, memory pressure states are
maintained on both the per-memcg level and the global level, and a
socket is considered under pressure when either level asserts as much.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 12 ++++-----
 include/net/sock.h         | 63 ++++++----------------------------------------
 include/net/tcp.h          |  5 ++--
 mm/memcontrol.c            | 32 +++++++++++++++++++++++
 net/core/sock.c            | 26 +++++++++++--------
 net/ipv4/tcp_output.c      |  7 ++++--
 6 files changed, 69 insertions(+), 76 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 96ca3d3..906dfff 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -676,12 +676,6 @@ void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 }
 #endif /* CONFIG_MEMCG */
 
-enum {
-	UNDER_LIMIT,
-	SOFT_LIMIT,
-	OVER_LIMIT,
-};
-
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg);
@@ -711,6 +705,12 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 struct sock;
 void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
+bool mem_cgroup_charge_skmem(struct cg_proto *proto, unsigned int nr_pages);
+void mem_cgroup_uncharge_skmem(struct cg_proto *proto, unsigned int nr_pages);
+static inline bool mem_cgroup_under_socket_pressure(struct cg_proto *proto)
+{
+	return proto->memory_pressure;
+}
 #endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_MEMCG_KMEM
diff --git a/include/net/sock.h b/include/net/sock.h
index 2eefc99..8cc7613 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1126,8 +1126,8 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
 	if (!sk->sk_prot->memory_pressure)
 		return false;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return !!sk->sk_cgrp->memory_pressure;
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
+	    mem_cgroup_under_socket_pressure(sk->sk_cgrp))
 
 	return !!*sk->sk_prot->memory_pressure;
 }
@@ -1141,9 +1141,6 @@ static inline void sk_leave_memory_pressure(struct sock *sk)
 
 	if (*memory_pressure)
 		*memory_pressure = 0;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		sk->sk_cgrp->memory_pressure = 0;
 }
 
 static inline void sk_enter_memory_pressure(struct sock *sk)
@@ -1151,76 +1148,30 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
 	if (!sk->sk_prot->enter_memory_pressure)
 		return;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		sk->sk_cgrp->memory_pressure = 1;
-
 	sk->sk_prot->enter_memory_pressure(sk);
 }
 
 static inline long sk_prot_mem_limits(const struct sock *sk, int index)
 {
-	long limit = sk->sk_prot->sysctl_mem[index];
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		limit = min_t(long, limit, sk->sk_cgrp->memory_allocated.limit);
-
-	return limit;
-}
-
-static inline void memcg_memory_allocated_add(struct cg_proto *prot,
-					      unsigned long amt,
-					      int *parent_status)
-{
-	struct page_counter *counter;
-
-	if (page_counter_try_charge(&prot->memory_allocated, amt, &counter))
-		return;
-
-	page_counter_charge(&prot->memory_allocated, amt);
-	*parent_status = OVER_LIMIT;
-}
-
-static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
-					      unsigned long amt)
-{
-	page_counter_uncharge(&prot->memory_allocated, amt);
+	return sk->sk_prot->sysctl_mem[index];
 }
 
 static inline long
 sk_memory_allocated(const struct sock *sk)
 {
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return page_counter_read(&sk->sk_cgrp->memory_allocated);
-
-	return atomic_long_read(prot->memory_allocated);
+	return atomic_long_read(sk->sk_prot->memory_allocated);
 }
 
 static inline long
-sk_memory_allocated_add(struct sock *sk, int amt, int *parent_status)
+sk_memory_allocated_add(struct sock *sk, int amt)
 {
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		memcg_memory_allocated_add(sk->sk_cgrp, amt, parent_status);
-		/* update the root cgroup regardless */
-		atomic_long_add_return(amt, prot->memory_allocated);
-		return page_counter_read(&sk->sk_cgrp->memory_allocated);
-	}
-
-	return atomic_long_add_return(amt, prot->memory_allocated);
+	return atomic_long_add_return(amt, sk->sk_prot->memory_allocated);
 }
 
 static inline void
 sk_memory_allocated_sub(struct sock *sk, int amt)
 {
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		memcg_memory_allocated_sub(sk->sk_cgrp, amt);
-
-	atomic_long_sub(amt, prot->memory_allocated);
+	atomic_long_sub(amt, sk->sk_prot->memory_allocated);
 }
 
 static inline void sk_sockets_allocated_dec(struct sock *sk)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f80e74c..04517d6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -292,8 +292,9 @@ extern int tcp_memory_pressure;
 /* optimized version of sk_under_memory_pressure() for TCP sockets */
 static inline bool tcp_under_memory_pressure(const struct sock *sk)
 {
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return !!sk->sk_cgrp->memory_pressure;
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
+	    mem_cgroup_under_socket_pressure(sk->sk_cgrp))
+		return true;
 
 	return tcp_memory_pressure;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 57f4539..3462a52 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -338,6 +338,38 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(tcp_proto_cgroup);
 
+/**
+ * mem_cgroup_charge_skmem - charge socket memory
+ * @proto: proto to charge
+ * @nr_pages: number of pages to charge
+ *
+ * Charges @nr_pages to @proto. Returns %true if the charge fit within
+ * @proto's configured limit, %false if the charge had to be forced.
+ */
+bool mem_cgroup_charge_skmem(struct cg_proto *proto, unsigned int nr_pages)
+{
+	struct page_counter *counter;
+
+	if (page_counter_try_charge(&proto->memory_allocated,
+				    nr_pages, &counter)) {
+		proto->memory_pressure = 0;
+		return true;
+	}
+	page_counter_charge(&proto->memory_allocated, nr_pages);
+	proto->memory_pressure = 1;
+	return false;
+}
+
+/**
+ * mem_cgroup_uncharge_skmem - uncharge socket memory
+ * @proto - proto to uncharge
+ * @nr_pages - number of pages to uncharge
+ */
+void mem_cgroup_uncharge_skmem(struct cg_proto *proto, unsigned int nr_pages)
+{
+	page_counter_uncharge(&proto->memory_allocated, nr_pages);
+}
+
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
diff --git a/net/core/sock.c b/net/core/sock.c
index 04e54bc..5b1b96f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2066,27 +2066,27 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 	struct proto *prot = sk->sk_prot;
 	int amt = sk_mem_pages(size);
 	long allocated;
-	int parent_status = UNDER_LIMIT;
 
 	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
 
-	allocated = sk_memory_allocated_add(sk, amt, &parent_status);
+	allocated = sk_memory_allocated_add(sk, amt);
+
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp &&
+	    !mem_cgroup_charge_skmem(sk->sk_cgrp, amt))
+		goto suppress_allocation;
 
 	/* Under limit. */
-	if (parent_status == UNDER_LIMIT &&
-			allocated <= sk_prot_mem_limits(sk, 0)) {
+	if (allocated <= sk_prot_mem_limits(sk, 0)) {
 		sk_leave_memory_pressure(sk);
 		return 1;
 	}
 
-	/* Under pressure. (we or our parents) */
-	if ((parent_status > SOFT_LIMIT) ||
-			allocated > sk_prot_mem_limits(sk, 1))
+	/* Under pressure. */
+	if (allocated > sk_prot_mem_limits(sk, 1))
 		sk_enter_memory_pressure(sk);
 
-	/* Over hard limit (we or our parents) */
-	if ((parent_status == OVER_LIMIT) ||
-			(allocated > sk_prot_mem_limits(sk, 2)))
+	/* Over hard limit. */
+	if (allocated > sk_prot_mem_limits(sk, 2))
 		goto suppress_allocation;
 
 	/* guarantee minimum buffer size under pressure */
@@ -2135,6 +2135,9 @@ suppress_allocation:
 
 	sk_memory_allocated_sub(sk, amt);
 
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		mem_cgroup_uncharge_skmem(sk->sk_cgrp, amt);
+
 	return 0;
 }
 EXPORT_SYMBOL(__sk_mem_schedule);
@@ -2150,6 +2153,9 @@ void __sk_mem_reclaim(struct sock *sk, int amount)
 	sk_memory_allocated_sub(sk, amount);
 	sk->sk_forward_alloc -= amount << SK_MEM_QUANTUM_SHIFT;
 
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		mem_cgroup_uncharge_skmem(sk->sk_cgrp, amount);
+
 	if (sk_under_memory_pressure(sk) &&
 	    (sk_memory_allocated(sk) < sk_prot_mem_limits(sk, 0)))
 		sk_leave_memory_pressure(sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cb7ca56..7aa168a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2813,13 +2813,16 @@ begin_fwd:
  */
 void sk_forced_mem_schedule(struct sock *sk, int size)
 {
-	int amt, status;
+	int amt;
 
 	if (size <= sk->sk_forward_alloc)
 		return;
 	amt = sk_mem_pages(size);
 	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
-	sk_memory_allocated_add(sk, amt, &status);
+	sk_memory_allocated_add(sk, amt);
+
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		mem_cgroup_charge_skmem(sk->sk_cgrp, amt);
 }
 
 /* Send a FIN. The caller locks the socket for us.
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
