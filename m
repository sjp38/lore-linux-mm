Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 20DE26B016A
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 22:45:09 -0400 (EDT)
Message-ID: <4E5EF14F.3040300@parallels.com>
Date: Wed, 31 Aug 2011 23:43:27 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: [RFMC] per-container tcp buffer limitation
Content-Type: multipart/mixed;
	boundary="------------080304050906080906060401"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: Linux Containers <containers@lists.osdl.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, "Eric W. Biederman" <ebiederm@xmission.com>, David Miller <davem@davemloft.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Stephen Hemminger <shemminger@vyatta.com>, penberg@kernel.org

--------------080304050906080906060401
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

Hello People,

[ For the ones in linux-mm that are receiving this for the first time,
   this is a follow up of
   http://thread.gmane.org/gmane.linux.kernel.containers/21295 ]

Here is a new, a bit more mature version of my previous RFC. Now I 
Request For More Comments from you guys in this new version of the patch.

Highlights:

* Although I do intend to experiment with more scenarios (suggestions 
welcome), there does not seem to be a (huge) performance hit with this 
patch applied, at least in a basic latency benchmark. That indicates 
that even if we can demonstrate a performance hit, it won't be too hard 
to optimize it away (famous last words?)

Since the patch touches both rcv and snd sides, I benchmarked it with 
netperf against localhost. Command line: netperf -t TCP_RR -H localhost.

Without the patch
=================

Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    26996.35
16384  87380

With the patch
===============

Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    27291.86
16384  87380


As you can see, rate is a bit higher, but still under an one percent 
range, meaning it is basically unchanged. I will benchmark it with 
various levels of cgroup nesting on my next submission so we can have a 
better idea of the impact of it when enabled.

* As nicely pointed out by Kamezawa, I dropped the sockets cgroup, and 
introduced a kmem cgroup. After careful consideration, I decided not to 
reuse the memcg. Basically, my impression is that memcg is concerned 
with user objects, with page granularity and its swap attributes. 
Because kernel objects are entirely different, I prefer to group them here.

* Only tcp ipv4 is converted - because it is basically the one in which
memory pressure thresholds are really put to use. I plan to touch the 
other protocols in the next submission.

* As with other sysctls, the sysctl controlling tcp memory pressure 
behaviour was made per-netns. But it will show cgroup-data for the 
current cgroup. The cgroup control file, however, will only set a 
maximum value. The pressure thresholds is not the business of the box 
administrator, but rather, of the container's - anything goes, provided 
none of the 3 values go over the maximum.

Comments welcome

--------------080304050906080906060401
Content-Type: text/plain; name="tcp-membuf.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="tcp-membuf.patch"

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index ac663c1..363b8e8 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -35,6 +35,10 @@ SUBSYS(cpuacct)
 SUBSYS(mem_cgroup)
 #endif
 
+#ifdef CONFIG_CGROUP_KMEM
+SUBSYS(kmem)
+#endif
+
 /* */
 
 #ifdef CONFIG_CGROUP_DEVICE
diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
new file mode 100644
index 0000000..9c62718
--- /dev/null
+++ b/include/linux/kmem_cgroup.h
@@ -0,0 +1,68 @@
+/* kmem_cgroup.h - Kernel Memory Controller
+ *
+ * Copyright Parallels Inc., 2011
+ * Author: Glauber Costa <glommer@parallels.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _LINUX_KMEM_CGROUP_H
+#define _LINUX_KMEM_CGROUP_H
+#include <linux/cgroup.h>
+#include <linux/atomic.h>
+#include <linux/percpu_counter.h>
+
+struct kmem_cgroup {
+	struct cgroup_subsys_state css;
+	struct kmem_cgroup *parent;
+
+	int tcp_memory_pressure;
+	int tcp_max_memory;
+	atomic_long_t tcp_memory_allocated;
+	struct percpu_counter tcp_sockets_allocated;
+	long tcp_prot_mem[3];
+
+	atomic_long_t udp_memory_allocated;
+};
+
+
+#ifdef CONFIG_CGROUP_KMEM
+static inline struct kmem_cgroup *cgroup_sk(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, kmem_subsys_id),
+		struct kmem_cgroup, css);
+}
+
+static inline struct kmem_cgroup *task_sk(struct task_struct *tsk)
+{
+	return container_of(task_subsys_state(tsk, kmem_subsys_id),
+		struct kmem_cgroup, css);
+}
+
+static inline bool kmem_cgroup_disabled(void)
+{
+	if (kmem_subsys.disabled)
+		return true;
+	return false;
+}
+#else
+static inline struct kmem_cgroup *cgroup_sk(struct cgroup *cgrp)
+{
+	return NULL;
+}
+
+static inline struct kmem_cgroup *task_sk(struct task_struct *tsk)
+{
+	return NULL;
+}
+#endif /* CONFIG_CGROUP_KMEM */
+#endif /* _LINUX_KMEM_CGROUP_H */
+
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d786b4f..bbd023a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -55,6 +55,7 @@ struct netns_ipv4 {
 	int current_rt_cache_rebuild_count;
 
 	unsigned int sysctl_ping_group_range[2];
+	long sysctl_tcp_mem[3];
 
 	atomic_t rt_genid;
 	atomic_t dev_addr_genid;
diff --git a/include/net/sock.h b/include/net/sock.h
index 8e4062f..b68e6ea 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -62,7 +62,9 @@
 #include <linux/atomic.h>
 #include <net/dst.h>
 #include <net/checksum.h>
+#include <linux/kmem_cgroup.h>
 
+int sockets_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
 /*
  * This structure really needs to be cleaned up.
  * Most of it is for TCP, and not used by any of
@@ -339,6 +341,7 @@ struct sock {
 #endif
 	__u32			sk_mark;
 	u32			sk_classid;
+	struct kmem_cgroup	*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
@@ -786,16 +789,18 @@ struct proto {
 
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(struct sock *sk);
-	atomic_long_t		*memory_allocated;	/* Current allocated memory. */
-	struct percpu_counter	*sockets_allocated;	/* Current number of sockets. */
+	atomic_long_t		*(*memory_allocated)(struct kmem_cgroup *sg);	/* Current allocated memory. */
+	struct percpu_counter	*(*sockets_allocated)(struct kmem_cgroup *sg);	/* Current number of sockets. */
+
+	int			(*init_cgroup)(struct cgroup *cgrp, struct cgroup_subsys *ss);
 	/*
 	 * Pressure flag: try to collapse.
 	 * Technical note: it is used by multiple contexts non atomically.
 	 * All the __sk_mem_schedule() is of this nature: accounting
 	 * is strict, actions are advisory and have some latency.
 	 */
-	int			*memory_pressure;
-	long			*sysctl_mem;
+	int			*(*memory_pressure)(struct kmem_cgroup *sg);
+	long			*(*prot_mem)(struct kmem_cgroup *sg);
 	int			*sysctl_wmem;
 	int			*sysctl_rmem;
 	int			max_header;
@@ -826,6 +831,56 @@ struct proto {
 #endif
 };
 
+#define sk_memory_pressure(sk)						\
+({									\
+	int *__ret = NULL;						\
+	if (sk->sk_prot->memory_pressure)				\
+		__ret = sk->sk_prot->memory_pressure(sk->sk_cgrp);	\
+	__ret;								\
+})
+
+#define sk_sockets_allocated(sk)				\
+({ 								\
+	struct percpu_counter *__p;				\
+	__p = sk->sk_prot->sockets_allocated(sk->sk_cgrp);	\
+	__p;							\
+})
+
+#define sk_memory_allocated(sk)					\
+({								\
+	atomic_long_t *__mem;					\
+	__mem = sk->sk_prot->memory_allocated(sk->sk_cgrp);	\
+	__mem;							\
+})
+
+#define sk_prot_mem(sk)						\
+({								\
+	long *__mem = sk->sk_prot->prot_mem(sk->sk_cgrp);	\
+	__mem;							\
+})
+
+#define sg_memory_pressure(prot, sg)				\
+({								\
+	int *__ret = NULL;  					\
+	if (prot->memory_pressure)				\
+		__ret = prot->memory_pressure(sg);		\
+	__ret;							\
+})
+
+#define sg_memory_allocated(prot, sg)				\
+({								\
+	atomic_long_t *__mem; 					\
+	__mem = prot->memory_allocated(sg);			\
+	__mem;							\
+})
+
+#define sg_sockets_allocated(prot, sg)				\
+({ 								\
+	struct percpu_counter *__p;				\
+	__p = prot->sockets_allocated(sg);			\
+	__p;							\
+})
+
 extern int proto_register(struct proto *prot, int alloc_slab);
 extern void proto_unregister(struct proto *prot);
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 149a415..97405ed 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -230,7 +230,6 @@ extern int sysctl_tcp_fack;
 extern int sysctl_tcp_reordering;
 extern int sysctl_tcp_ecn;
 extern int sysctl_tcp_dsack;
-extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
 extern int sysctl_tcp_app_win;
@@ -255,7 +254,13 @@ extern int sysctl_tcp_thin_dupack;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
-extern int tcp_memory_pressure;
+
+struct kmem_cgroup;
+extern long *tcp_sysctl_mem(struct kmem_cgroup *sg);
+struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg);
+int *memory_pressure_tcp(struct kmem_cgroup *sg);
+int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
+atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg);
 
 /*
  * The next routines deal with comparing 32 bit unsigned ints
@@ -286,7 +291,7 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 	}
 
 	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
-	    atomic_long_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
+	    atomic_long_read(sk_memory_allocated(sk)) > sk_prot_mem(sk)[2])
 		return true;
 	return false;
 }
diff --git a/include/trace/events/sock.h b/include/trace/events/sock.h
index 779abb9..44d2191 100644
--- a/include/trace/events/sock.h
+++ b/include/trace/events/sock.h
@@ -31,13 +31,14 @@ TRACE_EVENT(sock_rcvqueue_full,
 
 TRACE_EVENT(sock_exceed_buf_limit,
 
-	TP_PROTO(struct sock *sk, struct proto *prot, long allocated),
+	TP_PROTO(struct sock *sk, struct proto *prot, long allocated,
+		 long *prot_mem),
 
-	TP_ARGS(sk, prot, allocated),
+	TP_ARGS(sk, prot, allocated, prot_mem),
 
 	TP_STRUCT__entry(
 		__array(char, name, 32)
-		__field(long *, sysctl_mem)
+		__field(long *, prot_mem)
 		__field(long, allocated)
 		__field(int, sysctl_rmem)
 		__field(int, rmem_alloc)
@@ -45,7 +46,7 @@ TRACE_EVENT(sock_exceed_buf_limit,
 
 	TP_fast_assign(
 		strncpy(__entry->name, prot->name, 32);
-		__entry->sysctl_mem = prot->sysctl_mem;
+		__entry->prot_mem = prot_mem;
 		__entry->allocated = allocated;
 		__entry->sysctl_rmem = prot->sysctl_rmem[0];
 		__entry->rmem_alloc = atomic_read(&sk->sk_rmem_alloc);
@@ -54,9 +55,9 @@ TRACE_EVENT(sock_exceed_buf_limit,
 	TP_printk("proto:%s sysctl_mem=%ld,%ld,%ld allocated=%ld "
 		"sysctl_rmem=%d rmem_alloc=%d",
 		__entry->name,
-		__entry->sysctl_mem[0],
-		__entry->sysctl_mem[1],
-		__entry->sysctl_mem[2],
+		__entry->prot_mem[0],
+		__entry->prot_mem[1],
+		__entry->prot_mem[2],
 		__entry->allocated,
 		__entry->sysctl_rmem,
 		__entry->rmem_alloc)
diff --git a/init/Kconfig b/init/Kconfig
index d627783..ed3019c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -690,6 +690,17 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
 	  select this option (if, for some reason, they need to disable it
 	  then swapaccount=0 does the trick).
 
+config CGROUP_KMEM
+	bool "Kernel Memory Resource Controller for Control Groups"
+	depends on CGROUPS 
+	help
+	  The Kernel Memory cgroup can limit the amount of memory used by
+	  certain kernel objects in the system. Those are fundamentally
+	  different from the entities handled by the Memory Controller,
+	  which are page-based, and can be swapped. Users of the kmem
+	  cgroup can use it to guarantee that no group of processes will
+	  ever exhaust kernel resources alone.
+
 config CGROUP_PERF
 	bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
 	depends on PERF_EVENTS && CGROUPS
diff --git a/mm/Makefile b/mm/Makefile
index 836e416..1b1aa24 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_KMEM) += kmem_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
diff --git a/mm/kmem_cgroup.c b/mm/kmem_cgroup.c
new file mode 100644
index 0000000..d2a86dd
--- /dev/null
+++ b/mm/kmem_cgroup.c
@@ -0,0 +1,53 @@
+/* kmem_cgroup.c - Kernel Memory Controller
+ *
+ * Copyright Parallels Inc, 2011
+ * Author: Glauber Costa <glommer@parallels.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/cgroup.h>
+#include <linux/slab.h>
+#include <net/sock.h>
+
+static int kmem_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return sockets_populate(ss, cgrp);
+}
+
+static void
+kmem_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct kmem_cgroup *sk = cgroup_sk(cgrp);
+	kfree(sk);
+}
+
+static struct cgroup_subsys_state *kmem_create(
+	struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct kmem_cgroup *sk = kzalloc(sizeof(*sk), GFP_KERNEL);
+
+	if (!sk)
+		return ERR_PTR(-ENOMEM);
+
+	if (cgrp->parent)
+		sk->parent = cgroup_sk(cgrp->parent);
+
+	return &sk->css;
+}
+
+struct cgroup_subsys kmem_subsys = {
+	.name = "kmem",
+	.create = kmem_create,
+	.destroy = kmem_destroy,
+	.populate = kmem_populate,
+	.subsys_id = kmem_subsys_id,
+};
diff --git a/net/core/sock.c b/net/core/sock.c
index bc745d0..2b748d5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -134,6 +134,25 @@
 #include <net/tcp.h>
 #endif
 
+static DEFINE_RWLOCK(proto_list_lock);
+static LIST_HEAD(proto_list);
+
+int sockets_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct proto *proto;
+	int ret = 0;
+
+	read_lock(&proto_list_lock);
+	list_for_each_entry(proto, &proto_list, node) {
+		if (proto->init_cgroup) {
+			ret |= proto->init_cgroup(cgrp, ss);
+		}
+	}
+	read_unlock(&proto_list_lock);
+	
+	return ret;
+}
+
 /*
  * Each address family might have different locking rules, so we have
  * one slock key per address family:
@@ -1114,6 +1133,16 @@ void sock_update_classid(struct sock *sk)
 		sk->sk_classid = classid;
 }
 EXPORT_SYMBOL(sock_update_classid);
+
+void sock_update_cgrp(struct sock *sk)
+{
+#ifdef CONFIG_CGROUP_KMEM
+	rcu_read_lock(); 
+	sk->sk_cgrp = task_sk(current);
+	rcu_read_unlock();
+#endif
+}
+
 #endif
 
 /**
@@ -1141,6 +1170,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
+		sock_update_cgrp(sk);
 	}
 
 	return sk;
@@ -1289,8 +1319,8 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sk_set_socket(newsk, NULL);
 		newsk->sk_wq = NULL;
 
-		if (newsk->sk_prot->sockets_allocated)
-			percpu_counter_inc(newsk->sk_prot->sockets_allocated);
+		if (sk_sockets_allocated(sk))
+			percpu_counter_inc(sk_sockets_allocated(sk));
 
 		if (sock_flag(newsk, SOCK_TIMESTAMP) ||
 		    sock_flag(newsk, SOCK_TIMESTAMPING_RX_SOFTWARE))
@@ -1678,29 +1708,50 @@ EXPORT_SYMBOL(sk_wait_data);
  */
 int __sk_mem_schedule(struct sock *sk, int size, int kind)
 {
-	struct proto *prot = sk->sk_prot;
 	int amt = sk_mem_pages(size);
+	struct proto *prot = sk->sk_prot;
 	long allocated;
+	int *memory_pressure;
+	long *prot_mem;
+	int parent_failure = 0;
+	struct kmem_cgroup *sg = sk->sk_cgrp;
 
 	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
-	allocated = atomic_long_add_return(amt, prot->memory_allocated);
+
+	memory_pressure = sk_memory_pressure(sk);
+	prot_mem = sk_prot_mem(sk);
+
+	allocated = atomic_long_add_return(amt, sk_memory_allocated(sk));
+
+#ifdef CONFIG_KMEM_CGROUP
+	for (sg = sk->sk_cgrp->parent; sg != NULL; sg = sg->parent) {
+		long alloc;
+		/*
+		 * Large nestings are not the common case, and stopping in the
+		 * middle would be complicated enough, that we bill it all the
+		 * way through the root, and if needed, unbill everything later
+		 */
+		alloc = atomic_long_add_return(amt, sg_memory_allocated(prot, sg));
+		parent_failure |= (alloc > sk_prot_mem(sk)[2]);
+	} 
+#endif
+
+	/* Over hard limit (we, or our parents) */
+	if (parent_failure || (allocated > prot_mem[2]))
+		goto suppress_allocation;
 
 	/* Under limit. */
-	if (allocated <= prot->sysctl_mem[0]) {
-		if (prot->memory_pressure && *prot->memory_pressure)
-			*prot->memory_pressure = 0;
+	if (allocated <= prot_mem[0]) {
+		if (memory_pressure && *memory_pressure)
+			*memory_pressure = 0;
 		return 1;
 	}
 
 	/* Under pressure. */
-	if (allocated > prot->sysctl_mem[1])
+	if (allocated > prot_mem[1])
 		if (prot->enter_memory_pressure)
 			prot->enter_memory_pressure(sk);
 
-	/* Over hard limit. */
-	if (allocated > prot->sysctl_mem[2])
-		goto suppress_allocation;
-
 	/* guarantee minimum buffer size under pressure */
 	if (kind == SK_MEM_RECV) {
 		if (atomic_read(&sk->sk_rmem_alloc) < prot->sysctl_rmem[0])
@@ -1714,13 +1765,13 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
 				return 1;
 	}
 
-	if (prot->memory_pressure) {
+	if (memory_pressure) {
 		int alloc;
 
-		if (!*prot->memory_pressure)
+		if (!*memory_pressure)
 			return 1;
-		alloc = percpu_counter_read_positive(prot->sockets_allocated);
-		if (prot->sysctl_mem[2] > alloc *
+		alloc = percpu_counter_read_positive(sk_sockets_allocated(sk));
+		if (prot_mem[2] > alloc *
 		    sk_mem_pages(sk->sk_wmem_queued +
 				 atomic_read(&sk->sk_rmem_alloc) +
 				 sk->sk_forward_alloc))
@@ -1739,11 +1790,19 @@ suppress_allocation:
 			return 1;
 	}
 
-	trace_sock_exceed_buf_limit(sk, prot, allocated);
+	trace_sock_exceed_buf_limit(sk, prot, allocated, prot_mem);
 
 	/* Alas. Undo changes. */
 	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
-	atomic_long_sub(amt, prot->memory_allocated);
+
+	atomic_long_sub(amt, sk_memory_allocated(sk));
+
+#ifdef CONFIG_CGROUP_KMEM
+	for (sg = sk->sk_cgrp->parent; sg != NULL; sg = sg->parent) {
+		atomic_long_sub(amt, sg_memory_allocated(prot, sg));
+	}
+#endif
+
 	return 0;
 }
 EXPORT_SYMBOL(__sk_mem_schedule);
@@ -1755,14 +1814,25 @@ EXPORT_SYMBOL(__sk_mem_schedule);
 void __sk_mem_reclaim(struct sock *sk)
 {
 	struct proto *prot = sk->sk_prot;
+	struct kmem_cgroup *sg = sk->sk_cgrp;
+	int *memory_pressure = sk_memory_pressure(sk);
+	
 
 	atomic_long_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
-		   prot->memory_allocated);
+		   sk_memory_allocated(sk));
+
+#ifdef CONFIG_CGROUP_KMEM
+	for (sg = sk->sk_cgrp->parent; sg != NULL; sg = sg->parent) {
+		atomic_long_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
+						sg_memory_allocated(prot, sg));
+	}
+#endif
+
 	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
 
-	if (prot->memory_pressure && *prot->memory_pressure &&
-	    (atomic_long_read(prot->memory_allocated) < prot->sysctl_mem[0]))
-		*prot->memory_pressure = 0;
+	if (memory_pressure && *memory_pressure &&
+	    (atomic_long_read(sk_memory_allocated(sk)) < sk_prot_mem(sk)[0]))
+		*memory_pressure = 0;
 }
 EXPORT_SYMBOL(__sk_mem_reclaim);
 
@@ -2254,9 +2324,6 @@ void sk_common_release(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_common_release);
 
-static DEFINE_RWLOCK(proto_list_lock);
-static LIST_HEAD(proto_list);
-
 #ifdef CONFIG_PROC_FS
 #define PROTO_INUSE_NR	64	/* should be enough for the first time */
 struct prot_inuse {
@@ -2481,13 +2548,15 @@ static char proto_method_implemented(const void *method)
 
 static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
 {
+	struct kmem_cgroup *sg = task_sk(current);
+
 	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
 			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
 		   proto->name,
 		   proto->obj_size,
 		   sock_prot_inuse_get(seq_file_net(seq), proto),
-		   proto->memory_allocated != NULL ? atomic_long_read(proto->memory_allocated) : -1L,
-		   proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
+		   proto->memory_allocated != NULL ? atomic_long_read(sg_memory_allocated(proto, sg)) : -1L,
+		   proto->memory_pressure != NULL ? *sg_memory_pressure(proto, sg) ? "yes" : "no" : "NI",
 		   proto->max_header,
 		   proto->slab == NULL ? "no" : "yes",
 		   module_name(proto->owner),
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index b14ec7d..e8e8889 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -53,19 +53,21 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 	struct net *net = seq->private;
 	int orphans, sockets;
 
+	struct kmem_cgroup *sg = task_sk(current);
+
 	local_bh_disable();
 	orphans = percpu_counter_sum_positive(&tcp_orphan_count);
-	sockets = percpu_counter_sum_positive(&tcp_sockets_allocated);
+	sockets = percpu_counter_sum_positive(sg_sockets_allocated((&tcp_prot), sg));
 	local_bh_enable();
 
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld\n",
 		   sock_prot_inuse_get(net, &tcp_prot), orphans,
 		   tcp_death_row.tw_count, sockets,
-		   atomic_long_read(&tcp_memory_allocated));
+		   atomic_long_read(sg_memory_allocated((&tcp_prot), sg)));
 	seq_printf(seq, "UDP: inuse %d mem %ld\n",
 		   sock_prot_inuse_get(net, &udp_prot),
-		   atomic_long_read(&udp_memory_allocated));
+		   atomic_long_read(sg_memory_allocated((&udp_prot), sg)));
 	seq_printf(seq, "UDPLITE: inuse %d\n",
 		   sock_prot_inuse_get(net, &udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n",
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 69fd720..9ce7e75 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -14,6 +14,8 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/nsproxy.h>
+#include <linux/kmem_cgroup.h>
+#include <linux/swap.h>
 #include <net/snmp.h>
 #include <net/icmp.h>
 #include <net/ip.h>
@@ -174,6 +176,43 @@ static int proc_allowed_congestion_control(ctl_table *ctl,
 	return ret;
 }
 
+static int ipv4_tcp_mem(ctl_table *ctl, int write,
+			   void __user *buffer, size_t *lenp,
+			   loff_t *ppos)
+{
+	int ret;
+	unsigned long vec[3];
+	struct kmem_cgroup *kmem = task_sk(current);
+	struct net *net = current->nsproxy->net_ns;
+	int i;
+
+	ctl_table tmp = {
+		.data = &vec,
+		.maxlen = sizeof(vec),
+		.mode = ctl->mode,
+	};
+
+	if (!write) {
+		ctl->data = &net->ipv4.sysctl_tcp_mem;
+		return proc_doulongvec_minmax(ctl, write, buffer, lenp, ppos);
+	}
+
+	ret = proc_doulongvec_minmax(&tmp, write, buffer, lenp, ppos);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < 3; i++)
+		if (vec[i] > kmem->tcp_max_memory)
+			return -EINVAL;
+
+	for (i = 0; i < 3; i++) {
+		net->ipv4.sysctl_tcp_mem[i] = vec[i];
+		kmem->tcp_prot_mem[i] = net->ipv4.sysctl_tcp_mem[i];
+	}
+
+	return 0;
+}
+
 static struct ctl_table ipv4_table[] = {
 	{
 		.procname	= "tcp_timestamps",
@@ -433,13 +472,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_mem",
-		.data		= &sysctl_tcp_mem,
-		.maxlen		= sizeof(sysctl_tcp_mem),
-		.mode		= 0644,
-		.proc_handler	= proc_doulongvec_minmax
-	},
-	{
 		.procname	= "tcp_wmem",
 		.data		= &sysctl_tcp_wmem,
 		.maxlen		= sizeof(sysctl_tcp_wmem),
@@ -721,6 +753,12 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_ping_group_range,
 	},
+	{
+		.procname	= "tcp_mem",
+		.maxlen		= sizeof(init_net.ipv4.sysctl_tcp_mem),
+		.mode		= 0644,
+		.proc_handler	= ipv4_tcp_mem,
+	},
 	{ }
 };
 
@@ -734,6 +772,7 @@ EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
 static __net_init int ipv4_sysctl_init_net(struct net *net)
 {
 	struct ctl_table *table;
+	unsigned long limit;
 
 	table = ipv4_net_table;
 	if (!net_eq(net, &init_net)) {
@@ -769,6 +808,12 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 
 	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
 
+	limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
+	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
+	net->ipv4.sysctl_tcp_mem[1] = limit;
+	net->ipv4.sysctl_tcp_mem[2] = net->ipv4.sysctl_tcp_mem[0] * 2;
+
 	net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
 			net_ipv4_ctl_path, table);
 	if (net->ipv4.ipv4_hdr == NULL)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 46febca..beec487 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -266,6 +266,7 @@
 #include <linux/crypto.h>
 #include <linux/time.h>
 #include <linux/slab.h>
+#include <linux/nsproxy.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -282,23 +283,12 @@ int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
-long sysctl_tcp_mem[3] __read_mostly;
 int sysctl_tcp_wmem[3] __read_mostly;
 int sysctl_tcp_rmem[3] __read_mostly;
 
-EXPORT_SYMBOL(sysctl_tcp_mem);
 EXPORT_SYMBOL(sysctl_tcp_rmem);
 EXPORT_SYMBOL(sysctl_tcp_wmem);
 
-atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
-EXPORT_SYMBOL(tcp_memory_allocated);
-
-/*
- * Current number of TCP sockets.
- */
-struct percpu_counter tcp_sockets_allocated;
-EXPORT_SYMBOL(tcp_sockets_allocated);
-
 /*
  * TCP splice context
  */
@@ -308,17 +298,141 @@ struct tcp_splice_state {
 	unsigned int flags;
 };
 
+#ifdef CONFIG_CGROUP_KMEM
 /*
  * Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the __sk_mem_schedule() is of this nature: accounting
  * is strict, actions are advisory and have some latency.
  */
-int tcp_memory_pressure __read_mostly;
-EXPORT_SYMBOL(tcp_memory_pressure);
-
 void tcp_enter_memory_pressure(struct sock *sk)
 {
+	struct kmem_cgroup *sg = sk->sk_cgrp;
+	if (!sg->tcp_memory_pressure) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
+		sg->tcp_memory_pressure = 1;
+	}
+}
+EXPORT_SYMBOL(tcp_enter_memory_pressure);
+
+long *tcp_sysctl_mem(struct kmem_cgroup *sg)
+{
+	return sg->tcp_prot_mem;
+}
+EXPORT_SYMBOL(tcp_sysctl_mem);
+
+atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
+{
+	return &(sg->tcp_memory_allocated);
+}
+EXPORT_SYMBOL(memory_allocated_tcp);
+
+static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	struct kmem_cgroup *sg = cgroup_sk(cgrp);
+
+	if (!cgroup_lock_live_group(cgrp))
+		return -ENODEV;
+
+	/*
+	 * We can't allow more memory than our parents. Since this
+	 * will be tested for all calls, by induction, there is no need
+	 * to test any parent other than our own
+	 * */
+	if (sg->parent && (val > sg->parent->tcp_max_memory))
+		val = sg->parent->tcp_max_memory;
+
+	sg->tcp_max_memory = val;
+
+	sg->tcp_prot_mem[0] = val / 2;
+	sg->tcp_prot_mem[1] = (val * 2) / 3;
+	sg->tcp_prot_mem[2] = val;
+
+	cgroup_unlock();
+
+	return 0;
+}
+
+static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct kmem_cgroup *sg = cgroup_sk(cgrp);
+	u64 ret;
+
+	if (!cgroup_lock_live_group(cgrp))
+		return -ENODEV;
+	ret = sg->tcp_max_memory;
+
+	cgroup_unlock();
+	return ret;
+}
+
+static struct cftype tcp_files[] = {
+	{
+		.name = "tcp_maxmem",
+		.write_u64 = tcp_write_maxmem,
+		.read_u64 = tcp_read_maxmem,
+	},
+};
+
+int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+	struct kmem_cgroup *sg = cgroup_sk(cgrp);
+	unsigned long limit;
+	struct net *net = current->nsproxy->net_ns;
+
+	sg->tcp_memory_pressure = 0;
+
+	percpu_counter_init(&sg->tcp_sockets_allocated, 0);
+	atomic_long_set(&sg->tcp_memory_allocated, 0);
+
+	limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
+
+	if (sg->parent)
+		sg->tcp_max_memory = sg->parent->tcp_max_memory;
+	else
+		sg->tcp_max_memory = limit * 2;
+
+	sg->tcp_prot_mem[0] = net->ipv4.sysctl_tcp_mem[0];
+	sg->tcp_prot_mem[1] = net->ipv4.sysctl_tcp_mem[1];
+	sg->tcp_prot_mem[2] = net->ipv4.sysctl_tcp_mem[2];
+
+	return cgroup_add_files(cgrp, ss, tcp_files, ARRAY_SIZE(tcp_files));
+}
+EXPORT_SYMBOL(tcp_init_cgroup);
+
+int *memory_pressure_tcp(struct kmem_cgroup *sg)
+{
+	return &sg->tcp_memory_pressure;
+}
+EXPORT_SYMBOL(memory_pressure_tcp);
+
+struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg)
+{
+	return &sg->tcp_sockets_allocated;
+}
+EXPORT_SYMBOL(sockets_allocated_tcp);
+#else
+
+/* Current number of TCP sockets. */
+struct percpu_counter tcp_sockets_allocated;
+atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
+int tcp_memory_pressure;
+
+int *memory_pressure_tcp(struct kmem_cgroup *sg)
+{
+	return &tcp_memory_pressure;
+}
+EXPORT_SYMBOL(memory_pressure_tcp);
+
+struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg)
+{
+	return &tcp_sockets_allocated;
+}
+EXPORT_SYMBOL(sockets_allocated_tcp);
+
+void tcp_enter_memory_pressure(struct sock *sock)
+{
 	if (!tcp_memory_pressure) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
 		tcp_memory_pressure = 1;
@@ -326,6 +440,19 @@ void tcp_enter_memory_pressure(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_enter_memory_pressure);
 
+long *tcp_sysctl_mem(struct kmem_cgroup *sg)
+{
+	return init_net.ipv4.sysctl_tcp_mem;
+}
+EXPORT_SYMBOL(tcp_sysctl_mem);
+
+atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
+{
+	return &tcp_memory_allocated;
+}
+EXPORT_SYMBOL(memory_allocated_tcp);
+#endif /* CONFIG_CGROUP_KMEM */
+
 /* Convert seconds to retransmits based on initial and max timeout */
 static u8 secs_to_retrans(int seconds, int timeout, int rto_max)
 {
@@ -3226,7 +3353,9 @@ void __init tcp_init(void)
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
+#ifndef CONFIG_CGROUP_KMEM
 	percpu_counter_init(&tcp_sockets_allocated, 0);
+#endif
 	percpu_counter_init(&tcp_orphan_count, 0);
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
@@ -3277,14 +3406,8 @@ void __init tcp_init(void)
 	sysctl_tcp_max_orphans = cnt / 2;
 	sysctl_max_syn_backlog = max(128, cnt / 256);
 
-	limit = nr_free_buffer_pages() / 8;
-	limit = max(limit, 128UL);
-	sysctl_tcp_mem[0] = limit / 4 * 3;
-	sysctl_tcp_mem[1] = limit;
-	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
-
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
-	limit = ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
+	limit = ((unsigned long)init_net.ipv4.sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
 	max_share = min(4UL*1024*1024, limit);
 
 	sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ea0d218..c44e830 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -316,7 +316,7 @@ static void tcp_grow_window(struct sock *sk, struct sk_buff *skb)
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
-	    !tcp_memory_pressure) {
+	    !sk_memory_pressure(sk)) {
 		int incr;
 
 		/* Check #2. Increase window, if skb with such overhead
@@ -393,15 +393,16 @@ static void tcp_clamp_window(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct proto *prot = sk->sk_prot;
 
 	icsk->icsk_ack.quick = 0;
 
-	if (sk->sk_rcvbuf < sysctl_tcp_rmem[2] &&
+	if (sk->sk_rcvbuf < prot->sysctl_rmem[2] &&
 	    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK) &&
-	    !tcp_memory_pressure &&
-	    atomic_long_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
+	    !sk_memory_pressure(sk) &&
+	    atomic_long_read(sk_memory_allocated(sk)) < sk_prot_mem(sk)[0]) {
 		sk->sk_rcvbuf = min(atomic_read(&sk->sk_rmem_alloc),
-				    sysctl_tcp_rmem[2]);
+				    prot->sysctl_rmem[2]);
 	}
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf)
 		tp->rcv_ssthresh = min(tp->window_clamp, 2U * tp->advmss);
@@ -4806,7 +4807,7 @@ static int tcp_prune_queue(struct sock *sk)
 
 	if (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
 		tcp_clamp_window(sk);
-	else if (tcp_memory_pressure)
+	else if (sk_memory_pressure(sk))
 		tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U * tp->advmss);
 
 	tcp_collapse_ofo_queue(sk);
@@ -4872,11 +4873,11 @@ static int tcp_should_expand_sndbuf(struct sock *sk)
 		return 0;
 
 	/* If we are under global TCP memory pressure, do not expand.  */
-	if (tcp_memory_pressure)
+	if (sk_memory_pressure(sk))
 		return 0;
 
 	/* If we are under soft global TCP memory pressure, do not expand.  */
-	if (atomic_long_read(&tcp_memory_allocated) >= sysctl_tcp_mem[0])
+	if (atomic_long_read(sk_memory_allocated(sk)) >= sk_prot_mem(sk)[0])
 		return 0;
 
 	/* If we filled the congestion window, do not expand.  */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1c12b8e..88034a3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1901,7 +1901,7 @@ static int tcp_v4_init_sock(struct sock *sk)
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
 	local_bh_disable();
-	percpu_counter_inc(&tcp_sockets_allocated);
+	percpu_counter_inc(sk_sockets_allocated(sk));
 	local_bh_enable();
 
 	return 0;
@@ -1957,7 +1957,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		tp->cookie_values = NULL;
 	}
 
-	percpu_counter_dec(&tcp_sockets_allocated);
+	percpu_counter_dec(sk_sockets_allocated(sk));
 }
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
 
@@ -2598,11 +2598,14 @@ struct proto tcp_prot = {
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
 	.enter_memory_pressure	= tcp_enter_memory_pressure,
-	.sockets_allocated	= &tcp_sockets_allocated,
+	.memory_pressure	= memory_pressure_tcp,
+	.sockets_allocated	= sockets_allocated_tcp,
 	.orphan_count		= &tcp_orphan_count,
-	.memory_allocated	= &tcp_memory_allocated,
-	.memory_pressure	= &tcp_memory_pressure,
-	.sysctl_mem		= sysctl_tcp_mem,
+	.memory_allocated	= memory_allocated_tcp,
+#ifdef CONFIG_CGROUP_KMEM
+	.init_cgroup		= tcp_init_cgroup,
+#endif
+	.prot_mem		= tcp_sysctl_mem,
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 882e0b0..06aeb31 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1912,7 +1912,7 @@ u32 __tcp_select_window(struct sock *sk)
 	if (free_space < (full_space >> 1)) {
 		icsk->icsk_ack.quick = 0;
 
-		if (tcp_memory_pressure)
+		if (sk_memory_pressure(sk))
 			tp->rcv_ssthresh = min(tp->rcv_ssthresh,
 					       4U * tp->advmss);
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index ecd44b0..2c67617 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -261,7 +261,7 @@ static void tcp_delack_timer(unsigned long data)
 	}
 
 out:
-	if (tcp_memory_pressure)
+	if (sk_memory_pressure(sk))
 		sk_mem_reclaim(sk);
 out_unlock:
 	bh_unlock_sock(sk);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1b5a193..258f137 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -120,9 +120,6 @@ EXPORT_SYMBOL(sysctl_udp_rmem_min);
 int sysctl_udp_wmem_min __read_mostly;
 EXPORT_SYMBOL(sysctl_udp_wmem_min);
 
-atomic_long_t udp_memory_allocated;
-EXPORT_SYMBOL(udp_memory_allocated);
-
 #define MAX_UDP_PORTS 65536
 #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
 
@@ -1918,6 +1915,24 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 }
 EXPORT_SYMBOL(udp_poll);
 
+#ifdef CONFIG_CGROUP_KMEM
+static atomic_long_t *memory_allocated_udp(struct kmem_cgroup *sg)
+{
+	return &sg->udp_memory_allocated;
+}
+#else
+atomic_long_t udp_memory_allocated;
+static atomic_long_t *memory_allocated_udp(struct kmem_cgroup *sg)
+{
+	return &udp_memory_allocated;
+}
+#endif
+
+static long *udp_sysctl_mem(struct kmem_cgroup *sg)
+{
+	return sysctl_udp_mem;
+}
+
 struct proto udp_prot = {
 	.name		   = "UDP",
 	.owner		   = THIS_MODULE,
@@ -1936,8 +1951,8 @@ struct proto udp_prot = {
 	.unhash		   = udp_lib_unhash,
 	.rehash		   = udp_v4_rehash,
 	.get_port	   = udp_v4_get_port,
-	.memory_allocated  = &udp_memory_allocated,
-	.sysctl_mem	   = sysctl_udp_mem,
+	.memory_allocated  = &memory_allocated_udp,
+	.prot_mem	   = udp_sysctl_mem,
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp_sock),

--------------080304050906080906060401--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
