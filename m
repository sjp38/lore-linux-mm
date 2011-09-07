Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 58D446B016F
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 00:25:14 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 6/9] per-cgroup tcp buffers control
Date: Wed,  7 Sep 2011 01:23:16 -0300
Message-Id: <1315369399-3073-7-git-send-email-glommer@parallels.com>
In-Reply-To: <1315369399-3073-1-git-send-email-glommer@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, Glauber Costa <glommer@parallels.com>, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

With all the infrastructure in place, this patch implements
per-cgroup control for tcp memory pressure handling.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/kmem_cgroup.h |    7 ++++
 include/net/sock.h          |   10 ++++++-
 mm/kmem_cgroup.c            |   10 ++++++-
 net/core/sock.c             |   18 +++++++++++
 net/ipv4/tcp.c              |   67 +++++++++++++++++++++++++++++++++++++-----
 5 files changed, 102 insertions(+), 10 deletions(-)

diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
index d983ba8..89ad0a1 100644
--- a/include/linux/kmem_cgroup.h
+++ b/include/linux/kmem_cgroup.h
@@ -23,6 +23,13 @@
 struct kmem_cgroup {
 	struct cgroup_subsys_state css;
 	struct kmem_cgroup *parent;
+
+#ifdef CONFIG_INET
+	int tcp_memory_pressure;
+	atomic_long_t tcp_memory_allocated;
+	struct percpu_counter tcp_sockets_allocated;
+	long tcp_prot_mem[3];
+#endif
 };
 
 
diff --git a/include/net/sock.h b/include/net/sock.h
index ab65640..91424e3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -64,6 +64,7 @@
 #include <net/dst.h>
 #include <net/checksum.h>
 
+int sockets_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
 /*
  * This structure really needs to be cleaned up.
  * Most of it is for TCP, and not used by any of
@@ -814,7 +815,14 @@ struct proto {
 	int			*(*memory_pressure)(struct kmem_cgroup *sg);
 	/* Pointer to the per-cgroup version of the the sysctl_mem field */
 	long			*(*prot_mem)(struct kmem_cgroup *sg);
-
+	/*
+	 * cgroup specific initialization function. Called once for all
+	 * protocols that implement it, from cgroups populate function.
+	 * This function has to setup any files the protocol want to
+	 * appear in the kmem cgroup filesystem.
+	 */
+	int			(*init_cgroup)(struct cgroup *cgrp,
+					       struct cgroup_subsys *ss);
 	int			*sysctl_wmem;
 	int			*sysctl_rmem;
 	int			max_header;
diff --git a/mm/kmem_cgroup.c b/mm/kmem_cgroup.c
index 7950e69..5e53d66 100644
--- a/mm/kmem_cgroup.c
+++ b/mm/kmem_cgroup.c
@@ -17,16 +17,24 @@
 #include <linux/cgroup.h>
 #include <linux/slab.h>
 #include <linux/kmem_cgroup.h>
+#include <net/sock.h>
 
 static int kmem_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
-	return 0;
+	int ret = 0;
+#ifdef CONFIG_NET
+	ret = sockets_populate(ss, cgrp);
+#endif
+	return ret;
 }
 
 static void
 kmem_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
 	struct kmem_cgroup *cg = kcg_from_cgroup(cgrp);
+#ifdef CONFIG_INET
+	percpu_counter_destroy(&cg->tcp_sockets_allocated);
+#endif
 	kfree(cg);
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index ead9c02..9d833cf 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -134,6 +134,24 @@
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
+		if (proto->init_cgroup)
+			ret |= proto->init_cgroup(cgrp, ss);
+	}
+	read_unlock(&proto_list_lock);
+
+	return ret;
+}
+
 /*
  * Each address family might have different locking rules, so we have
  * one slock key per address family:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 76f03ed..0725dc4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -289,13 +289,6 @@ int sysctl_tcp_rmem[3] __read_mostly;
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
@@ -305,13 +298,68 @@ struct tcp_splice_state {
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
+void tcp_enter_memory_pressure(struct sock *sk)
+{
+	struct kmem_cgroup *sg = sk->sk_cgrp;
+	if (!sg->tcp_memory_pressure) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
+		sg->tcp_memory_pressure = 1;
+	}
+}
+
+long *tcp_sysctl_mem(struct kmem_cgroup *sg)
+{
+	return sg->tcp_prot_mem;
+}
+
+atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
+{
+	return &(sg->tcp_memory_allocated);
+}
+
+int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
+{
+	struct kmem_cgroup *sg = kcg_from_cgroup(cgrp);
+	unsigned long limit;
+	struct net *net = current->nsproxy->net_ns;
+
+	sg->tcp_memory_pressure = 0;
+	atomic_long_set(&sg->tcp_memory_allocated, 0);
+	percpu_counter_init(&sg->tcp_sockets_allocated, 0);
+
+	limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
+
+	sg->tcp_prot_mem[0] = net->ipv4.sysctl_tcp_mem[0];
+	sg->tcp_prot_mem[1] = net->ipv4.sysctl_tcp_mem[1];
+	sg->tcp_prot_mem[2] = net->ipv4.sysctl_tcp_mem[2];
+
+	return 0;
+}
+EXPORT_SYMBOL(tcp_init_cgroup);
+
+int *memory_pressure_tcp(struct kmem_cgroup *sg)
+{
+	return &sg->tcp_memory_pressure;
+}
+
+struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg)
+{
+	return &sg->tcp_sockets_allocated;
+}
+#else
+
+/* Current number of TCP sockets. */
+struct percpu_counter tcp_sockets_allocated;
+atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
+int tcp_memory_pressure;
 
 int *memory_pressure_tcp(struct kmem_cgroup *sg)
 {
@@ -340,6 +388,7 @@ atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
 {
 	return &tcp_memory_allocated;
 }
+#endif /* CONFIG_CGROUP_KMEM */
 
 EXPORT_SYMBOL(memory_pressure_tcp);
 EXPORT_SYMBOL(sockets_allocated_tcp);
@@ -3247,7 +3296,9 @@ void __init tcp_init(void)
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
+#ifndef CONFIG_CGROUP_KMEM
 	percpu_counter_init(&tcp_sockets_allocated, 0);
+#endif
 	percpu_counter_init(&tcp_orphan_count, 0);
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
