Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AA60F6B003A
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 11:27:40 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so1474808pde.31
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 08:27:40 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bc9si8715467pdb.22.2014.09.12.08.27.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 08:27:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC] memcg: revert kmem.tcp accounting
Date: Fri, 12 Sep 2014 19:26:58 +0400
Message-ID: <1410535618-9601-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Pavel Emelianov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>

memory.kmem.tcp.limit_in_bytes works as the system-wide tcp_mem sysctl,
but per memory cgroup. While the existence of the latter is justified
(it prevents the system from becoming unusable due to uncontrolled tcp
buffers growth) the reason why we need such a knob in containers isn't
clear to me.

Kernel memory usage of a memory cgroup can be limited by the kmem
resource counter, so tcp buffers created by processes inside a container
don't threaten to the whole system.

One might think that it could be useful to protect processes of a
container against tcp growth inside a continaer, but that's also rather
redundant. Memory cgroups can be nested one into another so the user of
a container can isolate a potentially dangerous load by creating a
container inside the container.

The system-wide sysctl was introduced very long time ago when cgroups
hadn't been invented yet. If they had, probably there wouldn't be a
reason to introduce tcp_mem at all. Anyway, we shouldn't have projected
an abstraction like tcp_mem on cgroups.

So this patch reverts all the code doing kmem.tcp accounting and removes
memory.kmem.tcp.* files from cgroup fs. Though it alters the memory.kmem
user interface, I don't think it's critical, because the whole kmem is
characterized as not working properly and being only useful for
development/testing (see init/Kconfig) and therefore shouldn't be
selected by most distributions.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Pavel Emelianov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
---
 Documentation/cgroups/memory.txt |   22 +--
 include/linux/memcontrol.h       |   13 --
 include/net/sock.h               |  272 --------------------------------------
 include/net/tcp.h                |    3 +-
 include/net/tcp_memcontrol.h     |    7 -
 mm/memcontrol.c                  |  107 +--------------
 net/core/sock.c                  |  120 ++++-------------
 net/ipv4/Makefile                |    1 -
 net/ipv4/proc.c                  |    6 +-
 net/ipv4/sysctl_net_ipv4.c       |    1 -
 net/ipv4/tcp.c                   |    3 +-
 net/ipv4/tcp_input.c             |   12 +-
 net/ipv4/tcp_ipv4.c              |    9 +-
 net/ipv4/tcp_memcontrol.c        |  228 --------------------------------
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv4/tcp_timer.c             |    2 +-
 net/ipv6/tcp_ipv6.c              |    4 -
 17 files changed, 51 insertions(+), 761 deletions(-)
 delete mode 100644 include/net/tcp_memcontrol.h
 delete mode 100644 net/ipv4/tcp_memcontrol.c

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 02ab997a1ed2..814fd23dbfdc 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -78,11 +78,6 @@ Brief summary of control files.
  memory.kmem.failcnt             # show the number of kernel memory usage hits limits
  memory.kmem.max_usage_in_bytes  # show max kernel memory usage recorded
 
- memory.kmem.tcp.limit_in_bytes  # set/show hard limit for tcp buf memory
- memory.kmem.tcp.usage_in_bytes  # show current tcp buf memory allocation
- memory.kmem.tcp.failcnt            # show the number of tcp buf memory usage hits limits
- memory.kmem.tcp.max_usage_in_bytes # show max tcp buf memory usage recorded
-
 1. History
 
 The memory controller has a long history. A request for comments for the memory
@@ -292,12 +287,11 @@ is removed. The memory limitation itself, can of course be removed by writing
 -1 to memory.kmem.limit_in_bytes. In this case, kmem will be accounted, but not
 limited.
 
-Kernel memory limits are not imposed for the root cgroup. Usage for the root
-cgroup may or may not be accounted. The memory used is accumulated into
-memory.kmem.usage_in_bytes, or in a separate counter when it makes sense.
-(currently only for tcp).
-The main "kmem" counter is fed into the main counter, so kmem charges will
-also be visible from the user counter.
+Kernel memory limits are not imposed for the root cgroup. The memory used is
+accumulated into memory.kmem.usage_in_bytes.
+
+The kmem counter is fed into the main counter, so kmem charges will also be
+visible from the user counter.
 
 Currently no soft limit is implemented for kernel memory. It is future work
 to trigger slab reclaim when those limits are reached.
@@ -315,12 +309,6 @@ skipped while the cache is being created. All objects in a slab page should
 belong to the same memcg. This only fails to hold when a task is migrated to a
 different memcg during the page allocation by the cache.
 
-* sockets memory pressure: some sockets protocols have memory pressure
-thresholds. The Memory Controller allows them to be controlled individually
-per cgroup, instead of globally.
-
-* tcp memory pressure: sockets memory pressure for the tcp protocol.
-
 2.7.3 Common use cases
 
 Because the "kmem" counter is fed to the main user counter, kernel memory can
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e0752d204d9e..3b98e3479bca 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -390,19 +390,6 @@ enum {
 	OVER_LIMIT,
 };
 
-struct sock;
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
-void sock_update_memcg(struct sock *sk);
-void sock_release_memcg(struct sock *sk);
-#else
-static inline void sock_update_memcg(struct sock *sk)
-{
-}
-static inline void sock_release_memcg(struct sock *sk)
-{
-}
-#endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
-
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key memcg_kmem_enabled_key;
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 049ab1b732a6..d31037e3d661 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -46,7 +46,6 @@
 #include <linux/list_nulls.h>
 #include <linux/timer.h>
 #include <linux/cache.h>
-#include <linux/bitops.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>	/* struct sk_buff */
@@ -54,8 +53,6 @@
 #include <linux/security.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
-#include <linux/memcontrol.h>
-#include <linux/res_counter.h>
 #include <linux/static_key.h>
 #include <linux/aio.h>
 #include <linux/sched.h>
@@ -69,22 +66,6 @@
 #include <net/checksum.h>
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
@@ -217,7 +198,6 @@ struct sock_common {
 	/* public: */
 };
 
-struct cg_proto;
 /**
   *	struct sock - network layer representation of sockets
   *	@__sk_common: shared layout with inet_timewait_sock
@@ -289,7 +269,6 @@ struct cg_proto;
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
   *	@sk_classid: this socket's cgroup classid
-  *	@sk_cgrp: this socket's cgroup-specific proto data
   *	@sk_write_pending: a write to stream socket waits to start
   *	@sk_state_change: callback to indicate change in the state of the sock
   *	@sk_data_ready: callback to indicate there is data to be processed
@@ -427,7 +406,6 @@ struct sock {
 #endif
 	__u32			sk_mark;
 	u32			sk_classid;
-	struct cg_proto		*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk);
 	void			(*sk_write_space)(struct sock *sk);
@@ -1041,61 +1019,11 @@ struct proto {
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
-};
-
-/*
- * Bits in struct cg_proto.flags
- */
-enum cg_proto_flags {
-	/* Currently active and new sockets should be assigned to cgroups */
-	MEMCG_SOCK_ACTIVE,
-	/* It was ever activated; we must disarm static keys on destruction */
-	MEMCG_SOCK_ACTIVATED,
-};
-
-struct cg_proto {
-	struct res_counter	memory_allocated;	/* Current allocated memory. */
-	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
-	int			memory_pressure;
-	long			sysctl_mem[3];
-	unsigned long		flags;
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
 
 int proto_register(struct proto *prot, int alloc_slab);
 void proto_unregister(struct proto *prot);
 
-static inline bool memcg_proto_active(struct cg_proto *cg_proto)
-{
-	return test_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
-}
-
-static inline bool memcg_proto_activated(struct cg_proto *cg_proto)
-{
-	return test_bit(MEMCG_SOCK_ACTIVATED, &cg_proto->flags);
-}
-
 #ifdef SOCK_REFCNT_DEBUG
 static inline void sk_refcnt_debug_inc(struct sock *sk)
 {
@@ -1121,23 +1049,6 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 #define sk_refcnt_debug_release(sk) do { } while (0)
 #endif /* SOCK_REFCNT_DEBUG */
 
-#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_NET)
-extern struct static_key memcg_socket_limit_enabled;
-static inline struct cg_proto *parent_cg_proto(struct proto *proto,
-					       struct cg_proto *cg_proto)
-{
-	return proto->proto_cgroup(parent_mem_cgroup(cg_proto->memcg));
-}
-#define mem_cgroup_sockets_enabled static_key_false(&memcg_socket_limit_enabled)
-#else
-#define mem_cgroup_sockets_enabled 0
-static inline struct cg_proto *parent_cg_proto(struct proto *proto,
-					       struct cg_proto *cg_proto)
-{
-	return NULL;
-}
-#endif
-
 static inline bool sk_stream_memory_free(const struct sock *sk)
 {
 	if (sk->sk_wmem_queued >= sk->sk_sndbuf)
@@ -1153,189 +1064,6 @@ static inline bool sk_stream_is_writeable(const struct sock *sk)
 	       sk_stream_memory_free(sk);
 }
 
-
-static inline bool sk_has_memory_pressure(const struct sock *sk)
-{
-	return sk->sk_prot->memory_pressure != NULL;
-}
-
-static inline bool sk_under_memory_pressure(const struct sock *sk)
-{
-	if (!sk->sk_prot->memory_pressure)
-		return false;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return !!sk->sk_cgrp->memory_pressure;
-
-	return !!*sk->sk_prot->memory_pressure;
-}
-
-static inline void sk_leave_memory_pressure(struct sock *sk)
-{
-	int *memory_pressure = sk->sk_prot->memory_pressure;
-
-	if (!memory_pressure)
-		return;
-
-	if (*memory_pressure)
-		*memory_pressure = 0;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct cg_proto *cg_proto = sk->sk_cgrp;
-		struct proto *prot = sk->sk_prot;
-
-		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			cg_proto->memory_pressure = 0;
-	}
-
-}
-
-static inline void sk_enter_memory_pressure(struct sock *sk)
-{
-	if (!sk->sk_prot->enter_memory_pressure)
-		return;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct cg_proto *cg_proto = sk->sk_cgrp;
-		struct proto *prot = sk->sk_prot;
-
-		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			cg_proto->memory_pressure = 1;
-	}
-
-	sk->sk_prot->enter_memory_pressure(sk);
-}
-
-static inline long sk_prot_mem_limits(const struct sock *sk, int index)
-{
-	long *prot = sk->sk_prot->sysctl_mem;
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		prot = sk->sk_cgrp->sysctl_mem;
-	return prot[index];
-}
-
-static inline void memcg_memory_allocated_add(struct cg_proto *prot,
-					      unsigned long amt,
-					      int *parent_status)
-{
-	struct res_counter *fail;
-	int ret;
-
-	ret = res_counter_charge_nofail(&prot->memory_allocated,
-					amt << PAGE_SHIFT, &fail);
-	if (ret < 0)
-		*parent_status = OVER_LIMIT;
-}
-
-static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
-					      unsigned long amt)
-{
-	res_counter_uncharge(&prot->memory_allocated, amt << PAGE_SHIFT);
-}
-
-static inline u64 memcg_memory_allocated_read(struct cg_proto *prot)
-{
-	u64 ret;
-	ret = res_counter_read_u64(&prot->memory_allocated, RES_USAGE);
-	return ret >> PAGE_SHIFT;
-}
-
-static inline long
-sk_memory_allocated(const struct sock *sk)
-{
-	struct proto *prot = sk->sk_prot;
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return memcg_memory_allocated_read(sk->sk_cgrp);
-
-	return atomic_long_read(prot->memory_allocated);
-}
-
-static inline long
-sk_memory_allocated_add(struct sock *sk, int amt, int *parent_status)
-{
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		memcg_memory_allocated_add(sk->sk_cgrp, amt, parent_status);
-		/* update the root cgroup regardless */
-		atomic_long_add_return(amt, prot->memory_allocated);
-		return memcg_memory_allocated_read(sk->sk_cgrp);
-	}
-
-	return atomic_long_add_return(amt, prot->memory_allocated);
-}
-
-static inline void
-sk_memory_allocated_sub(struct sock *sk, int amt)
-{
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		memcg_memory_allocated_sub(sk->sk_cgrp, amt);
-
-	atomic_long_sub(amt, prot->memory_allocated);
-}
-
-static inline void sk_sockets_allocated_dec(struct sock *sk)
-{
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
-}
-
-static inline void sk_sockets_allocated_inc(struct sock *sk)
-{
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
-}
-
-static inline int
-sk_sockets_allocated_read_positive(struct sock *sk)
-{
-	struct proto *prot = sk->sk_prot;
-
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return percpu_counter_read_positive(&sk->sk_cgrp->sockets_allocated);
-
-	return percpu_counter_read_positive(prot->sockets_allocated);
-}
-
-static inline int
-proto_sockets_allocated_sum_positive(struct proto *prot)
-{
-	return percpu_counter_sum_positive(prot->sockets_allocated);
-}
-
-static inline long
-proto_memory_allocated(struct proto *prot)
-{
-	return atomic_long_read(prot->memory_allocated);
-}
-
-static inline bool
-proto_memory_pressure(struct proto *prot)
-{
-	if (!prot->memory_pressure)
-		return false;
-	return !!*prot->memory_pressure;
-}
-
-
 #ifdef CONFIG_PROC_FS
 /* Called with local bh disabled */
 void sock_prot_inuse_add(struct net *net, struct proto *prot, int inc);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a4201ef216e8..6528690db360 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -46,7 +46,6 @@
 #include <net/dst.h>
 
 #include <linux/seq_file.h>
-#include <linux/memcontrol.h>
 
 extern struct inet_hashinfo tcp_hashinfo;
 
@@ -303,7 +302,7 @@ static inline bool between(__u32 seq1, __u32 seq2, __u32 seq3)
 static inline bool tcp_out_of_memory(struct sock *sk)
 {
 	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
-	    sk_memory_allocated(sk) > sk_prot_mem_limits(sk, 2))
+	    atomic_long_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
 		return true;
 	return false;
 }
diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
deleted file mode 100644
index 05b94d9453de..000000000000
--- a/include/net/tcp_memcontrol.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _TCP_MEMCG_H
-#define _TCP_MEMCG_H
-
-struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
-int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
-void tcp_destroy_cgroup(struct mem_cgroup *memcg);
-#endif /* _TCP_MEMCG_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 085dc6d2f876..8545804c6278 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -57,9 +57,6 @@
 #include <linux/lockdep.h>
 #include <linux/file.h>
 #include "internal.h"
-#include <net/sock.h>
-#include <net/ip.h>
-#include <net/tcp_memcontrol.h>
 #include "slab.h"
 
 #include <asm/uaccess.h>
@@ -353,9 +350,6 @@ struct mem_cgroup {
 	spinlock_t pcp_counter_lock;
 
 	atomic_t	dead_count;
-#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
-	struct cg_proto tcp_mem;
-#endif
 #if defined(CONFIG_MEMCG_KMEM)
 	/* analogous to slab_common's slab_caches list, but per-memcg;
 	 * protected by memcg_slab_mutex */
@@ -537,75 +531,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 	return mem_cgroup_from_css(css);
 }
 
-/* Writing them here to avoid exposing memcg's inner layout */
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
-
-void sock_update_memcg(struct sock *sk)
-{
-	if (mem_cgroup_sockets_enabled) {
-		struct mem_cgroup *memcg;
-		struct cg_proto *cg_proto;
-
-		BUG_ON(!sk->sk_prot->proto_cgroup);
-
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
-
-		rcu_read_lock();
-		memcg = mem_cgroup_from_task(current);
-		cg_proto = sk->sk_prot->proto_cgroup(memcg);
-		if (!mem_cgroup_is_root(memcg) &&
-		    memcg_proto_active(cg_proto) &&
-		    css_tryget_online(&memcg->css)) {
-			sk->sk_cgrp = cg_proto;
-		}
-		rcu_read_unlock();
-	}
-}
-EXPORT_SYMBOL(sock_update_memcg);
-
-void sock_release_memcg(struct sock *sk)
-{
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct mem_cgroup *memcg;
-		WARN_ON(!sk->sk_cgrp->memcg);
-		memcg = sk->sk_cgrp->memcg;
-		css_put(&sk->sk_cgrp->memcg->css);
-	}
-}
-
-struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
-{
-	if (!memcg || mem_cgroup_is_root(memcg))
-		return NULL;
-
-	return &memcg->tcp_mem;
-}
-EXPORT_SYMBOL(tcp_proto_cgroup);
-
-static void disarm_sock_keys(struct mem_cgroup *memcg)
-{
-	if (!memcg_proto_activated(&memcg->tcp_mem))
-		return;
-	static_key_slow_dec(&memcg_socket_limit_enabled);
-}
-#else
-static void disarm_sock_keys(struct mem_cgroup *memcg)
-{
-}
-#endif
-
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * This will be the memcg's index in each cache's ->memcg_params->memcg_caches.
@@ -664,12 +589,6 @@ static void disarm_kmem_keys(struct mem_cgroup *memcg)
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
-static void disarm_static_keys(struct mem_cgroup *memcg)
-{
-	disarm_sock_keys(memcg);
-	disarm_kmem_keys(memcg);
-}
-
 static void drain_all_stock_async(struct mem_cgroup *memcg);
 
 static struct mem_cgroup_per_zone *
@@ -4952,21 +4871,10 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
-static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
+static int memcg_init_kmem(struct mem_cgroup *memcg)
 {
-	int ret;
-
 	memcg->kmemcg_id = -1;
-	ret = memcg_propagate_kmem(memcg);
-	if (ret)
-		return ret;
-
-	return mem_cgroup_sockets_init(memcg, ss);
-}
-
-static void memcg_destroy_kmem(struct mem_cgroup *memcg)
-{
-	mem_cgroup_sockets_destroy(memcg);
+	return memcg_propagate_kmem(memcg);
 }
 
 static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
@@ -5003,15 +4911,11 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 		css_put(&memcg->css);
 }
 #else
-static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
+static int memcg_init_kmem(struct mem_cgroup *memcg)
 {
 	return 0;
 }
 
-static void memcg_destroy_kmem(struct mem_cgroup *memcg)
-{
-}
-
 static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 {
 }
@@ -5467,7 +5371,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	 * to move this code around, and make sure it is outside
 	 * the cgroup_lock.
 	 */
-	disarm_static_keys(memcg);
+	disarm_kmem_keys(memcg);
 	kfree(memcg);
 }
 
@@ -5585,7 +5489,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	}
 	mutex_unlock(&memcg_create_mutex);
 
-	return memcg_init_kmem(memcg, &memory_cgrp_subsys);
+	return memcg_init_kmem(memcg);
 }
 
 /*
@@ -5679,7 +5583,6 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	 */
 	mem_cgroup_reparent_charges(memcg);
 
-	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 07e2464e8841..29b7b493dc19 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -115,7 +115,6 @@
 #include <linux/highmem.h>
 #include <linux/user_namespace.h>
 #include <linux/static_key.h>
-#include <linux/memcontrol.h>
 #include <linux/prefetch.h>
 
 #include <asm/uaccess.h>
@@ -193,44 +192,6 @@ bool sk_net_capable(const struct sock *sk, int cap)
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
@@ -238,11 +199,6 @@ void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
 static struct lock_class_key af_family_keys[AF_MAX];
 static struct lock_class_key af_family_slock_keys[AF_MAX];
 
-#if defined(CONFIG_MEMCG_KMEM)
-struct static_key memcg_socket_limit_enabled;
-EXPORT_SYMBOL(memcg_socket_limit_enabled);
-#endif
-
 /*
  * Make lock validator output more readable. (we pre-construct these
  * strings build-time, so that runtime initialization of socket
@@ -1441,12 +1397,6 @@ void sk_release_kernel(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_release_kernel);
 
-static void sk_update_clone(const struct sock *sk, struct sock *newsk)
-{
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		sock_update_memcg(newsk);
-}
-
 /**
  *	sk_clone_lock - clone a socket, and lock its clone
  *	@sk: the socket to clone
@@ -1542,10 +1492,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		sk_set_socket(newsk, NULL);
 		newsk->sk_wq = NULL;
 
-		sk_update_clone(sk, newsk);
-
 		if (newsk->sk_prot->sockets_allocated)
-			sk_sockets_allocated_inc(newsk);
+			percpu_counter_inc(newsk->sk_prot->sockets_allocated);
 
 		if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
 			net_enable_timestamp();
@@ -1906,7 +1854,8 @@ bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
 	if (likely(skb_page_frag_refill(32U, pfrag, sk->sk_allocation)))
 		return true;
 
-	sk_enter_memory_pressure(sk);
+	if (sk->sk_prot->enter_memory_pressure)
+		sk->sk_prot->enter_memory_pressure(sk);
 	sk_stream_moderate_sndbuf(sk);
 	return false;
 }
@@ -2008,34 +1957,30 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 	struct proto *prot = sk->sk_prot;
 	int amt = sk_mem_pages(size);
 	long allocated;
-	int parent_status = UNDER_LIMIT;
 
 	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
-
-	allocated = sk_memory_allocated_add(sk, amt, &parent_status);
+	allocated = atomic_long_add_return(amt, prot->memory_allocated);
 
 	/* Under limit. */
-	if (parent_status == UNDER_LIMIT &&
-			allocated <= sk_prot_mem_limits(sk, 0)) {
-		sk_leave_memory_pressure(sk);
+	if (allocated <= prot->sysctl_mem[0]) {
+		if (prot->memory_pressure && *prot->memory_pressure)
+			*prot->memory_pressure = 0;
 		return 1;
 	}
 
-	/* Under pressure. (we or our parents) */
-	if ((parent_status > SOFT_LIMIT) ||
-			allocated > sk_prot_mem_limits(sk, 1))
-		sk_enter_memory_pressure(sk);
+	/* Under pressure. */
+	if (allocated > prot->sysctl_mem[1])
+		if (prot->enter_memory_pressure)
+			prot->enter_memory_pressure(sk);
 
-	/* Over hard limit (we or our parents) */
-	if ((parent_status == OVER_LIMIT) ||
-			(allocated > sk_prot_mem_limits(sk, 2)))
+	/* Over hard limit. */
+	if (allocated > prot->sysctl_mem[2])
 		goto suppress_allocation;
 
 	/* guarantee minimum buffer size under pressure */
 	if (kind == SK_MEM_RECV) {
 		if (atomic_read(&sk->sk_rmem_alloc) < prot->sysctl_rmem[0])
 			return 1;
-
 	} else { /* SK_MEM_SEND */
 		if (sk->sk_type == SOCK_STREAM) {
 			if (sk->sk_wmem_queued < prot->sysctl_wmem[0])
@@ -2045,13 +1990,13 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 				return 1;
 	}
 
-	if (sk_has_memory_pressure(sk)) {
+	if (prot->memory_pressure) {
 		int alloc;
 
-		if (!sk_under_memory_pressure(sk))
+		if (!*prot->memory_pressure)
 			return 1;
-		alloc = sk_sockets_allocated_read_positive(sk);
-		if (sk_prot_mem_limits(sk, 2) > alloc *
+		alloc = percpu_counter_read_positive(prot->sockets_allocated);
+		if (prot->sysctl_mem[2] > alloc *
 		    sk_mem_pages(sk->sk_wmem_queued +
 				 atomic_read(&sk->sk_rmem_alloc) +
 				 sk->sk_forward_alloc))
@@ -2074,9 +2019,7 @@ suppress_allocation:
 
 	/* Alas. Undo changes. */
 	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
-
-	sk_memory_allocated_sub(sk, amt);
-
+	atomic_long_sub(amt, prot->memory_allocated);
 	return 0;
 }
 EXPORT_SYMBOL(__sk_mem_schedule);
@@ -2087,13 +2030,15 @@ EXPORT_SYMBOL(__sk_mem_schedule);
  */
 void __sk_mem_reclaim(struct sock *sk)
 {
-	sk_memory_allocated_sub(sk,
-				sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT);
+	struct proto *prot = sk->sk_prot;
+
+	atomic_long_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
+		   prot->memory_allocated);
 	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
 
-	if (sk_under_memory_pressure(sk) &&
-	    (sk_memory_allocated(sk) < sk_prot_mem_limits(sk, 0)))
-		sk_leave_memory_pressure(sk);
+	if (prot->memory_pressure && *prot->memory_pressure &&
+	    (atomic_long_read(prot->memory_allocated) < prot->sysctl_mem[0]))
+		*prot->memory_pressure = 0;
 }
 EXPORT_SYMBOL(__sk_mem_reclaim);
 
@@ -2862,27 +2807,16 @@ static char proto_method_implemented(const void *method)
 {
 	return method == NULL ? 'n' : 'y';
 }
-static long sock_prot_memory_allocated(struct proto *proto)
-{
-	return proto->memory_allocated != NULL ? proto_memory_allocated(proto) : -1L;
-}
-
-static char *sock_prot_memory_pressure(struct proto *proto)
-{
-	return proto->memory_pressure != NULL ?
-	proto_memory_pressure(proto) ? "yes" : "no" : "NI";
-}
 
 static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
 {
-
 	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
 			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
 		   proto->name,
 		   proto->obj_size,
 		   sock_prot_inuse_get(seq_file_net(seq), proto),
-		   sock_prot_memory_allocated(proto),
-		   sock_prot_memory_pressure(proto),
+		   proto->memory_allocated != NULL ? atomic_long_read(proto->memory_allocated) : -1L,
+		   proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
 		   proto->max_header,
 		   proto->slab == NULL ? "no" : "yes",
 		   module_name(proto->owner),
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 8ee1cd4053ee..67fb5f0342fe 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -52,7 +52,6 @@ obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
-obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8e3eb39f84e7..53c9561002dd 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -57,17 +57,17 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 
 	local_bh_disable();
 	orphans = percpu_counter_sum_positive(&tcp_orphan_count);
-	sockets = proto_sockets_allocated_sum_positive(&tcp_prot);
+	sockets = percpu_counter_sum_positive(&tcp_sockets_allocated);
 	local_bh_enable();
 
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld\n",
 		   sock_prot_inuse_get(net, &tcp_prot), orphans,
 		   tcp_death_row.tw_count, sockets,
-		   proto_memory_allocated(&tcp_prot));
+		   atomic_long_read(&tcp_memory_allocated));
 	seq_printf(seq, "UDP: inuse %d mem %ld\n",
 		   sock_prot_inuse_get(net, &udp_prot),
-		   proto_memory_allocated(&udp_prot));
+		   atomic_long_read(&udp_memory_allocated));
 	seq_printf(seq, "UDPLITE: inuse %d\n",
 		   sock_prot_inuse_get(net, &udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n",
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 45d156dacd61..1163633ec73b 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -24,7 +24,6 @@
 #include <net/cipso_ipv4.h>
 #include <net/inet_frag.h>
 #include <net/ping.h>
-#include <net/tcp_memcontrol.h>
 
 static int zero;
 static int one = 1;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6f1031511dfc..0525c926501d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -420,8 +420,7 @@ void tcp_init_sock(struct sock *sk)
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
 	local_bh_disable();
-	sock_update_memcg(sk);
-	sk_sockets_allocated_inc(sk);
+	percpu_counter_inc(&tcp_sockets_allocated);
 	local_bh_enable();
 }
 EXPORT_SYMBOL(tcp_init_sock);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f97003ad0af5..5d7a91359e9a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -347,7 +347,7 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
-	    !sk_under_memory_pressure(sk)) {
+	    !tcp_memory_pressure) {
 		int incr;
 
 		/* Check #2. Increase window, if skb with such overhead
@@ -434,8 +434,8 @@ static void tcp_clamp_window(struct sock *sk)
 
 	if (sk->sk_rcvbuf < sysctl_tcp_rmem[2] &&
 	    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK) &&
-	    !sk_under_memory_pressure(sk) &&
-	    sk_memory_allocated(sk) < sk_prot_mem_limits(sk, 0)) {
+	    !tcp_memory_pressure &&
+	    atomic_long_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
 		sk->sk_rcvbuf = min(atomic_read(&sk->sk_rmem_alloc),
 				    sysctl_tcp_rmem[2]);
 	}
@@ -4676,7 +4676,7 @@ static int tcp_prune_queue(struct sock *sk)
 
 	if (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
 		tcp_clamp_window(sk);
-	else if (sk_under_memory_pressure(sk))
+	else if (tcp_memory_pressure)
 		tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U * tp->advmss);
 
 	tcp_collapse_ofo_queue(sk);
@@ -4720,11 +4720,11 @@ static bool tcp_should_expand_sndbuf(const struct sock *sk)
 		return false;
 
 	/* If we are under global TCP memory pressure, do not expand.  */
-	if (sk_under_memory_pressure(sk))
+	if (tcp_memory_pressure)
 		return false;
 
 	/* If we are under soft global TCP memory pressure, do not expand.  */
-	if (sk_memory_allocated(sk) >= sk_prot_mem_limits(sk, 0))
+	if (atomic_long_read(&tcp_memory_allocated) >= sysctl_tcp_mem[0])
 		return false;
 
 	/* If we filled the congestion window, do not expand.  */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3f9bc3f0bba0..57eebf09b045 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -74,7 +74,6 @@
 #include <net/xfrm.h>
 #include <net/netdma.h>
 #include <net/secure_seq.h>
-#include <net/tcp_memcontrol.h>
 #include <net/busy_poll.h>
 
 #include <linux/inet.h>
@@ -1858,8 +1857,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	/* If socket is aborted during connect operation */
 	tcp_free_fastopen_req(tp);
 
-	sk_sockets_allocated_dec(sk);
-	sock_release_memcg(sk);
+	percpu_counter_dec(&tcp_sockets_allocated);
 }
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
 
@@ -2431,11 +2429,6 @@ struct proto tcp_prot = {
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
deleted file mode 100644
index 1d191357bf88..000000000000
--- a/net/ipv4/tcp_memcontrol.c
+++ /dev/null
@@ -1,228 +0,0 @@
-#include <net/tcp.h>
-#include <net/tcp_memcontrol.h>
-#include <net/sock.h>
-#include <net/ip.h>
-#include <linux/nsproxy.h>
-#include <linux/memcontrol.h>
-#include <linux/module.h>
-
-int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
-{
-	/*
-	 * The root cgroup does not use res_counters, but rather,
-	 * rely on the data already collected by the network
-	 * subsystem
-	 */
-	struct res_counter *res_parent = NULL;
-	struct cg_proto *cg_proto, *parent_cg;
-	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return 0;
-
-	cg_proto->sysctl_mem[0] = sysctl_tcp_mem[0];
-	cg_proto->sysctl_mem[1] = sysctl_tcp_mem[1];
-	cg_proto->sysctl_mem[2] = sysctl_tcp_mem[2];
-	cg_proto->memory_pressure = 0;
-	cg_proto->memcg = memcg;
-
-	parent_cg = tcp_prot.proto_cgroup(parent);
-	if (parent_cg)
-		res_parent = &parent_cg->memory_allocated;
-
-	res_counter_init(&cg_proto->memory_allocated, res_parent);
-	percpu_counter_init(&cg_proto->sockets_allocated, 0, GFP_KERNEL);
-
-	return 0;
-}
-EXPORT_SYMBOL(tcp_init_cgroup);
-
-void tcp_destroy_cgroup(struct mem_cgroup *memcg)
-{
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return;
-
-	percpu_counter_destroy(&cg_proto->sockets_allocated);
-}
-EXPORT_SYMBOL(tcp_destroy_cgroup);
-
-static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
-{
-	struct cg_proto *cg_proto;
-	int i;
-	int ret;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return -EINVAL;
-
-	if (val > RES_COUNTER_MAX)
-		val = RES_COUNTER_MAX;
-
-	ret = res_counter_set_limit(&cg_proto->memory_allocated, val);
-	if (ret)
-		return ret;
-
-	for (i = 0; i < 3; i++)
-		cg_proto->sysctl_mem[i] = min_t(long, val >> PAGE_SHIFT,
-						sysctl_tcp_mem[i]);
-
-	if (val == RES_COUNTER_MAX)
-		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
-	else if (val != RES_COUNTER_MAX) {
-		/*
-		 * The active bit needs to be written after the static_key
-		 * update. This is what guarantees that the socket activation
-		 * function is the last one to run. See sock_update_memcg() for
-		 * details, and note that we don't mark any socket as belonging
-		 * to this memcg until that flag is up.
-		 *
-		 * We need to do this, because static_keys will span multiple
-		 * sites, but we can't control their order. If we mark a socket
-		 * as accounted, but the accounting functions are not patched in
-		 * yet, we'll lose accounting.
-		 *
-		 * We never race with the readers in sock_update_memcg(),
-		 * because when this value change, the code to process it is not
-		 * patched in yet.
-		 *
-		 * The activated bit is used to guarantee that no two writers
-		 * will do the update in the same memcg. Without that, we can't
-		 * properly shutdown the static key.
-		 */
-		if (!test_and_set_bit(MEMCG_SOCK_ACTIVATED, &cg_proto->flags))
-			static_key_slow_inc(&memcg_socket_limit_enabled);
-		set_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
-	}
-
-	return 0;
-}
-
-static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
-				char *buf, size_t nbytes, loff_t off)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
-	unsigned long long val;
-	int ret = 0;
-
-	buf = strstrip(buf);
-
-	switch (of_cft(of)->private) {
-	case RES_LIMIT:
-		/* see memcontrol.c */
-		ret = res_counter_memparse_write_strategy(buf, &val);
-		if (ret)
-			break;
-		ret = tcp_update_limit(memcg, val);
-		break;
-	default:
-		ret = -EINVAL;
-		break;
-	}
-	return ret ?: nbytes;
-}
-
-static u64 tcp_read_stat(struct mem_cgroup *memcg, int type, u64 default_val)
-{
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return default_val;
-
-	return res_counter_read_u64(&cg_proto->memory_allocated, type);
-}
-
-static u64 tcp_read_usage(struct mem_cgroup *memcg)
-{
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
-
-	return res_counter_read_u64(&cg_proto->memory_allocated, RES_USAGE);
-}
-
-static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
-{
-	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	u64 val;
-
-	switch (cft->private) {
-	case RES_LIMIT:
-		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
-		break;
-	case RES_USAGE:
-		val = tcp_read_usage(memcg);
-		break;
-	case RES_FAILCNT:
-	case RES_MAX_USAGE:
-		val = tcp_read_stat(memcg, cft->private, 0);
-		break;
-	default:
-		BUG();
-	}
-	return val;
-}
-
-static ssize_t tcp_cgroup_reset(struct kernfs_open_file *of,
-				char *buf, size_t nbytes, loff_t off)
-{
-	struct mem_cgroup *memcg;
-	struct cg_proto *cg_proto;
-
-	memcg = mem_cgroup_from_css(of_css(of));
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return nbytes;
-
-	switch (of_cft(of)->private) {
-	case RES_MAX_USAGE:
-		res_counter_reset_max(&cg_proto->memory_allocated);
-		break;
-	case RES_FAILCNT:
-		res_counter_reset_failcnt(&cg_proto->memory_allocated);
-		break;
-	}
-
-	return nbytes;
-}
-
-static struct cftype tcp_files[] = {
-	{
-		.name = "kmem.tcp.limit_in_bytes",
-		.write = tcp_cgroup_write,
-		.read_u64 = tcp_cgroup_read,
-		.private = RES_LIMIT,
-	},
-	{
-		.name = "kmem.tcp.usage_in_bytes",
-		.read_u64 = tcp_cgroup_read,
-		.private = RES_USAGE,
-	},
-	{
-		.name = "kmem.tcp.failcnt",
-		.private = RES_FAILCNT,
-		.write = tcp_cgroup_reset,
-		.read_u64 = tcp_cgroup_read,
-	},
-	{
-		.name = "kmem.tcp.max_usage_in_bytes",
-		.private = RES_MAX_USAGE,
-		.write = tcp_cgroup_reset,
-		.read_u64 = tcp_cgroup_read,
-	},
-	{ }	/* terminate */
-};
-
-static int __init tcp_memcontrol_init(void)
-{
-	WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys, tcp_files));
-	return 0;
-}
-__initcall(tcp_memcontrol_init);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 96121ab6f194..007c0191d27f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2265,7 +2265,7 @@ u32 __tcp_select_window(struct sock *sk)
 	if (free_space < (full_space >> 1)) {
 		icsk->icsk_ack.quick = 0;
 
-		if (sk_under_memory_pressure(sk))
+		if (tcp_memory_pressure)
 			tp->rcv_ssthresh = min(tp->rcv_ssthresh,
 					       4U * tp->advmss);
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a339e7ba05a4..52304123bab5 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -243,7 +243,7 @@ void tcp_delack_timer_handler(struct sock *sk)
 	}
 
 out:
-	if (sk_under_memory_pressure(sk))
+	if (tcp_memory_pressure)
 		sk_mem_reclaim(sk);
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5b3c70ff7a72..77fb43f11409 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -62,7 +62,6 @@
 #include <net/netdma.h>
 #include <net/inet_common.h>
 #include <net/secure_seq.h>
-#include <net/tcp_memcontrol.h>
 #include <net/busy_poll.h>
 
 #include <linux/proc_fs.h>
@@ -1889,9 +1888,6 @@ struct proto tcpv6_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
-#ifdef CONFIG_MEMCG_KMEM
-	.proto_cgroup		= tcp_proto_cgroup,
-#endif
 	.clear_sk		= tcp_v6_clear_sk,
 };
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
