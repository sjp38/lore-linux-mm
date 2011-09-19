Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC7D9000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 20:58:45 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 4/7] per-cgroup tcp buffers control
Date: Sun, 18 Sep 2011 21:56:42 -0300
Message-Id: <1316393805-3005-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1316393805-3005-1-git-send-email-glommer@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, Glauber Costa <glommer@parallels.com>

With all the infrastructure in place, this patch implements
per-cgroup control for tcp memory pressure handling.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/memcontrol.h |    6 +++
 include/net/sock.h         |   15 ++++++-
 include/net/tcp.h          |   10 ++--
 mm/memcontrol.c            |  107 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c            |   38 ++++++++++++++-
 net/ipv4/tcp.c             |   44 +++++++++---------
 net/ipv4/tcp_ipv4.c        |   14 ++++--
 net/ipv6/tcp_ipv6.c        |   13 +++--
 8 files changed, 205 insertions(+), 42 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1744ae8..6b8c0c0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -410,6 +410,12 @@ void memcg_sock_mem_alloc(struct mem_cgroup *mem, struct proto *prot,
 void memcg_sock_mem_free(struct mem_cgroup *mem, struct proto *prot, int amt);
 void memcg_sockets_allocated_dec(struct mem_cgroup *mem, struct proto *prot);
 void memcg_sockets_allocated_inc(struct mem_cgroup *mem, struct proto *prot);
+int tcp_init_cgroup(struct proto *prot, struct cgroup *cgrp,
+		    struct cgroup_subsys *ss);
+int tcp_init_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
+			 struct cgroup_subsys *ss);
+void tcp_destroy_cgroup(struct proto *prot, struct cgroup *cgrp,
+			struct cgroup_subsys *ss);
 #else
 /* memcontrol includes sockets.h, that includes memcontrol.h ... */
 static inline void memcg_sock_mem_alloc(struct mem_cgroup *mem,
diff --git a/include/net/sock.h b/include/net/sock.h
index 78832f9..e9ae8a4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -64,6 +64,8 @@
 #include <net/dst.h>
 #include <net/checksum.h>
 
+int sockets_populate(struct cgroup *cgrp, struct cgroup_subsys *ss);
+void sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss);
 /*
  * This structure really needs to be cleaned up.
  * Most of it is for TCP, and not used by any of
@@ -814,7 +816,18 @@ struct proto {
 	int			*(*memory_pressure)(struct mem_cgroup *sg);
 	/* Pointer to the per-cgroup version of the the sysctl_mem field */
 	long			*(*prot_mem)(struct mem_cgroup *sg);
-
+	/*
+	 * cgroup specific init/deinit functions. Called once for all
+	 * protocols that implement it, from cgroups populate function.
+	 * This function has to setup any files the protocol want to
+	 * appear in the kmem cgroup filesystem.
+	 */
+	int			(*init_cgroup)(struct proto *prot,
+					       struct cgroup *cgrp,
+					       struct cgroup_subsys *ss);
+	void			(*destroy_cgroup)(struct proto *prot,
+						  struct cgroup *cgrp,
+						  struct cgroup_subsys *ss);
 	int			*sysctl_wmem;
 	int			*sysctl_rmem;
 	int			max_header;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c835ae3..ce3c211 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -255,10 +255,10 @@ extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 
 struct mem_cgroup;
-extern long *tcp_sysctl_mem(struct mem_cgroup *sg);
-struct percpu_counter *sockets_allocated_tcp(struct mem_cgroup *sg);
-int *memory_pressure_tcp(struct mem_cgroup *sg);
-atomic_long_t *memory_allocated_tcp(struct mem_cgroup *sg);
+extern long *tcp_sysctl_mem_nocg(struct mem_cgroup *sg);
+struct percpu_counter *sockets_allocated_tcp_nocg(struct mem_cgroup *sg);
+int *memory_pressure_tcp_nocg(struct mem_cgroup *sg);
+atomic_long_t *memory_allocated_tcp_nocg(struct mem_cgroup *sg);
 
 /*
  * The next routines deal with comparing 32 bit unsigned ints
@@ -1002,7 +1002,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->loc_port = tcp_hdr(skb)->dest;
 }
 
-extern void tcp_enter_memory_pressure(struct sock *sk);
+extern void tcp_enter_memory_pressure_nocg(struct sock *sk);
 
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 03d6d61..4bcb052 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -343,6 +343,13 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
+
+	/* per-cgroup tcp memory pressure knobs */
+	atomic_long_t tcp_memory_allocated;
+	struct percpu_counter tcp_sockets_allocated;
+	/* those two are read-mostly, leave them at the end */
+	long tcp_prot_mem[3];
+	int tcp_memory_pressure;
 };
 
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -350,6 +357,8 @@ static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
 #ifdef CONFIG_INET
 #include <net/sock.h>
+#include <net/tcp.h>
+#include <net/ip.h>
 
 void sock_update_memcg(struct sock *sk)
 {
@@ -419,6 +428,90 @@ void memcg_sockets_allocated_inc(struct mem_cgroup *mem, struct proto *prot)
 		percpu_counter_inc(prot->sockets_allocated(mem));
 }
 EXPORT_SYMBOL(memcg_sockets_allocated_inc);
+
+static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont);
+/*
+ * Pressure flag: try to collapse.
+ * Technical note: it is used by multiple contexts non atomically.
+ * All the __sk_mem_schedule() is of this nature: accounting
+ * is strict, actions are advisory and have some latency.
+ */
+void tcp_enter_memory_pressure(struct sock *sk)
+{
+	struct mem_cgroup *sg = sk->sk_cgrp;
+	if (!sg->tcp_memory_pressure) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
+		sg->tcp_memory_pressure = 1;
+	}
+}
+
+long *tcp_sysctl_mem(struct mem_cgroup *cg)
+{
+	return cg->tcp_prot_mem;
+}
+
+atomic_long_t *memory_allocated_tcp(struct mem_cgroup *cg)
+{
+	return &(cg->tcp_memory_allocated);
+}
+
+int *memory_pressure_tcp(struct mem_cgroup *sg)
+{
+	return &sg->tcp_memory_pressure;
+}
+
+struct percpu_counter *sockets_allocated_tcp(struct mem_cgroup *sg)
+{
+	return &sg->tcp_sockets_allocated;
+}
+
+/*
+ * For ipv6, we only need to fill in the function pointers (can't initialize
+ * things twice). So keep it separated
+ */
+int tcp_init_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
+			 struct cgroup_subsys *ss)
+{
+	prot->enter_memory_pressure = tcp_enter_memory_pressure;
+	prot->memory_allocated = memory_allocated_tcp;
+	prot->prot_mem = tcp_sysctl_mem;
+	prot->sockets_allocated = sockets_allocated_tcp;
+	prot->memory_pressure = memory_pressure_tcp;
+
+	return 0;
+}
+EXPORT_SYMBOL(tcp_init_cgroup_fill);
+
+int tcp_init_cgroup(struct proto *prot, struct cgroup *cgrp,
+		    struct cgroup_subsys *ss)
+{
+	struct mem_cgroup *cg = mem_cgroup_from_cont(cgrp);
+	unsigned long limit;
+
+	cg->tcp_memory_pressure = 0;
+	atomic_long_set(&cg->tcp_memory_allocated, 0);
+	percpu_counter_init(&cg->tcp_sockets_allocated, 0);
+
+	limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
+
+	cg->tcp_prot_mem[0] = sysctl_tcp_mem[0];
+	cg->tcp_prot_mem[1] = sysctl_tcp_mem[1];
+	cg->tcp_prot_mem[2] = sysctl_tcp_mem[2];
+
+	tcp_init_cgroup_fill(prot, cgrp, ss);
+	return 0;
+}
+EXPORT_SYMBOL(tcp_init_cgroup);
+
+void tcp_destroy_cgroup(struct proto *prot, struct cgroup *cgrp,
+			struct cgroup_subsys *ss)
+{
+	struct mem_cgroup *cg = mem_cgroup_from_cont(cgrp);
+
+	percpu_counter_destroy(&cg->tcp_sockets_allocated);
+}
+EXPORT_SYMBOL(tcp_destroy_cgroup);
 #endif /* CONFIG_INET */
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
 
@@ -5026,9 +5119,21 @@ static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
 	if (!mem_cgroup_is_root(mem))
 		ret = cgroup_add_files(cont, ss, kmem_cgroup_files,
 					ARRAY_SIZE(kmem_cgroup_files));
+
+	if (!ret)
+		ret = sockets_populate(cont, ss);
+
 	return ret;
 };
 
+static void kmem_cgroup_destroy(struct cgroup_subsys *ss,
+				struct cgroup *cont)
+{
+	if (!do_kmem_account)
+		return;
+
+	sockets_destroy(cont, ss);
+}
 #else
 static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
 {
@@ -5277,6 +5382,8 @@ static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	kmem_cgroup_destroy(ss, cont);
+
 	mem_cgroup_put(mem);
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 338d572..92cf417 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -135,6 +135,41 @@
 #include <net/tcp.h>
 #endif
 
+static DEFINE_RWLOCK(proto_list_lock);
+static LIST_HEAD(proto_list);
+
+int sockets_populate(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+	struct proto *proto;
+	int ret = 0;
+
+	read_lock(&proto_list_lock);
+	list_for_each_entry(proto, &proto_list, node) {
+		if (proto->init_cgroup)
+			ret |= proto->init_cgroup(proto, cgrp, ss);
+	}
+	if (!ret)
+		goto out;
+
+	list_for_each_entry_continue_reverse(proto, &proto_list, node)
+		if (proto->destroy_cgroup)
+			proto->destroy_cgroup(proto, cgrp, ss);
+
+out:
+	read_unlock(&proto_list_lock);
+	return ret;
+}
+
+void sockets_destroy(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+	struct proto *proto;
+	read_lock(&proto_list_lock);
+	list_for_each_entry_reverse(proto, &proto_list, node)
+		if (proto->destroy_cgroup)
+			proto->destroy_cgroup(proto, cgrp, ss);
+	read_unlock(&proto_list_lock);
+}
+
 /*
  * Each address family might have different locking rules, so we have
  * one slock key per address family:
@@ -2260,9 +2295,6 @@ void sk_common_release(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_common_release);
 
-static DEFINE_RWLOCK(proto_list_lock);
-static LIST_HEAD(proto_list);
-
 #ifdef CONFIG_PROC_FS
 #define PROTO_INUSE_NR	64	/* should be enough for the first time */
 struct prot_inuse {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 452245f..156b836 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -290,13 +290,6 @@ EXPORT_SYMBOL(sysctl_tcp_mem);
 EXPORT_SYMBOL(sysctl_tcp_rmem);
 EXPORT_SYMBOL(sysctl_tcp_wmem);
 
-atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
-
-/*
- * Current number of TCP sockets.
- */
-struct percpu_counter tcp_sockets_allocated;
-
 /*
  * TCP splice context
  */
@@ -306,46 +299,49 @@ struct tcp_splice_state {
 	unsigned int flags;
 };
 
-/*
- * Pressure flag: try to collapse.
- * Technical note: it is used by multiple contexts non atomically.
- * All the __sk_mem_schedule() is of this nature: accounting
- * is strict, actions are advisory and have some latency.
- */
+/* Current number of TCP sockets. */
+struct percpu_counter tcp_sockets_allocated;
+atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
 int tcp_memory_pressure __read_mostly;
 
-int *memory_pressure_tcp(struct mem_cgroup *sg)
+int *memory_pressure_tcp_nocg(struct mem_cgroup *sg)
 {
 	return &tcp_memory_pressure;
 }
-EXPORT_SYMBOL(memory_pressure_tcp);
+EXPORT_SYMBOL(memory_pressure_tcp_nocg);
 
-struct percpu_counter *sockets_allocated_tcp(struct mem_cgroup *sg)
+struct percpu_counter *sockets_allocated_tcp_nocg(struct mem_cgroup *sg)
 {
 	return &tcp_sockets_allocated;
 }
-EXPORT_SYMBOL(sockets_allocated_tcp);
+EXPORT_SYMBOL(sockets_allocated_tcp_nocg);
 
-void tcp_enter_memory_pressure(struct sock *sk)
+/*
+ * Pressure flag: try to collapse.
+ * Technical note: it is used by multiple contexts non atomically.
+ * All the __sk_mem_schedule() is of this nature: accounting
+ * is strict, actions are advisory and have some latency.
+ */
+void tcp_enter_memory_pressure_nocg(struct sock *sk)
 {
 	if (!tcp_memory_pressure) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
 		tcp_memory_pressure = 1;
 	}
 }
-EXPORT_SYMBOL(tcp_enter_memory_pressure);
+EXPORT_SYMBOL(tcp_enter_memory_pressure_nocg);
 
-long *tcp_sysctl_mem(struct mem_cgroup *sg)
+long *tcp_sysctl_mem_nocg(struct mem_cgroup *sg)
 {
 	return sysctl_tcp_mem;
 }
-EXPORT_SYMBOL(tcp_sysctl_mem);
+EXPORT_SYMBOL(tcp_sysctl_mem_nocg);
 
-atomic_long_t *memory_allocated_tcp(struct mem_cgroup *sg)
+atomic_long_t *memory_allocated_tcp_nocg(struct mem_cgroup *sg)
 {
 	return &tcp_memory_allocated;
 }
-EXPORT_SYMBOL(memory_allocated_tcp);
+EXPORT_SYMBOL(memory_allocated_tcp_nocg);
 
 /* Convert seconds to retransmits based on initial and max timeout */
 static u8 secs_to_retrans(int seconds, int timeout, int rto_max)
@@ -3247,7 +3243,9 @@ void __init tcp_init(void)
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
+#ifndef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
 	percpu_counter_init(&tcp_sockets_allocated, 0);
+#endif
 	percpu_counter_init(&tcp_orphan_count, 0);
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cbb0d5e..c857baf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2597,12 +2597,16 @@ struct proto tcp_prot = {
 	.hash			= inet_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
-	.enter_memory_pressure	= tcp_enter_memory_pressure,
-	.memory_pressure	= memory_pressure_tcp,
-	.sockets_allocated	= sockets_allocated_tcp,
+	.enter_memory_pressure	= tcp_enter_memory_pressure_nocg,
+	.memory_pressure	= memory_pressure_tcp_nocg,
+	.sockets_allocated	= sockets_allocated_tcp_nocg,
 	.orphan_count		= &tcp_orphan_count,
-	.memory_allocated	= memory_allocated_tcp,
-	.prot_mem		= tcp_sysctl_mem,
+	.memory_allocated	= memory_allocated_tcp_nocg,
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+	.init_cgroup		= tcp_init_cgroup,
+	.destroy_cgroup		= tcp_destroy_cgroup,
+#endif
+	.prot_mem		= tcp_sysctl_mem_nocg,
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 807797a..5cd13c9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2220,12 +2220,15 @@ struct proto tcpv6_prot = {
 	.hash			= tcp_v6_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
-	.enter_memory_pressure	= tcp_enter_memory_pressure,
-	.sockets_allocated	= sockets_allocated_tcp,
-	.memory_allocated	= memory_allocated_tcp,
-	.memory_pressure	= memory_pressure_tcp,
+	.enter_memory_pressure	= tcp_enter_memory_pressure_nocg,
+	.sockets_allocated	= sockets_allocated_tcp_nocg,
+	.memory_allocated	= memory_allocated_tcp_nocg,
+	.memory_pressure	= memory_pressure_tcp_nocg,
 	.orphan_count		= &tcp_orphan_count,
-	.prot_mem		= tcp_sysctl_mem,
+	.prot_mem		= tcp_sysctl_mem_nocg,
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+	.init_cgroup		= tcp_init_cgroup_fill,
+#endif
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
