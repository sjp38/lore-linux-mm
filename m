Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 71AB86B016D
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 00:25:03 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 4/9] function wrappers for upcoming socket
Date: Wed,  7 Sep 2011 01:23:14 -0300
Message-Id: <1315369399-3073-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1315369399-3073-1-git-send-email-glommer@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, Glauber Costa <glommer@parallels.com>, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Instead of dealing with global values for memory pressure scenarios,
per-cgroup values will be needed. This patch just writes down the
acessor functions to be used later.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/kmem_cgroup.h |  104 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 104 insertions(+), 0 deletions(-)

diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
index 77076d8..d983ba8 100644
--- a/include/linux/kmem_cgroup.h
+++ b/include/linux/kmem_cgroup.h
@@ -52,6 +52,110 @@ static inline struct kmem_cgroup *kcg_from_task(struct task_struct *tsk)
 
 #ifdef CONFIG_INET
 #include <net/sock.h>
+static inline int *sk_memory_pressure(struct sock *sk)
+{
+	int *ret = NULL;
+	if (sk->sk_prot->memory_pressure)
+		ret = sk->sk_prot->memory_pressure(sk->sk_cgrp);
+	return ret;
+}
+
+static inline long sk_prot_mem(struct sock *sk, int index)
+{
+	long *prot = sk->sk_prot->prot_mem(sk->sk_cgrp);
+	return prot[index];
+}
+
+static inline long
+sk_memory_allocated(struct sock *sk)
+{
+	struct proto *prot = sk->sk_prot;
+	struct kmem_cgroup *cg = sk->sk_cgrp;
+
+	return atomic_long_read(prot->memory_allocated(cg));
+}
+
+static inline long
+sk_memory_allocated_add(struct sock *sk, int amt, int *parent_failure)
+{
+	struct proto *prot = sk->sk_prot;
+	struct kmem_cgroup *cg = sk->sk_cgrp;
+	long allocated = atomic_long_add_return(amt, prot->memory_allocated(cg));
+
+#ifdef CONFIG_CGROUP_KMEM
+	for (cg = cg->parent; cg != NULL; cg = cg->parent) {
+		long alloc;
+		/*
+		 * Large nestings are not the common case, and stopping in the
+		 * middle would be complicated enough, that we bill it all the
+		 * way through the root, and if needed, unbill everything later
+		 */
+		alloc = atomic_long_add_return(amt, prot->memory_allocated(cg));
+		*parent_failure |= (alloc > sk_prot_mem(sk, 2));
+	}
+#endif
+	return allocated;
+}
+
+static inline void
+sk_memory_allocated_sub(struct sock *sk, int amt)
+{
+	struct proto *prot = sk->sk_prot;
+	struct kmem_cgroup *cg = sk->sk_cgrp;
+
+	atomic_long_sub(amt, prot->memory_allocated(cg));
+
+#ifdef CONFIG_CGROUP_KMEM
+	for (cg = sk->sk_cgrp->parent; cg != NULL; cg = cg->parent)
+		atomic_long_sub(amt, prot->memory_allocated(cg));
+#endif
+}
+
+static inline void sk_sockets_allocated_dec(struct sock *sk)
+{
+	struct proto *prot = sk->sk_prot;
+	struct kmem_cgroup *cg = sk->sk_cgrp;
+
+	percpu_counter_dec(prot->sockets_allocated(cg));
+#ifdef CONFIG_CGROUP_KMEM
+	for (cg = sk->sk_cgrp->parent; cg; cg = cg->parent)
+		percpu_counter_dec(prot->sockets_allocated(cg));
+#endif
+}
+
+static inline void sk_sockets_allocated_inc(struct sock *sk)
+{
+	struct proto *prot = sk->sk_prot;
+	struct kmem_cgroup *cg = sk->sk_cgrp;
+
+	percpu_counter_inc(prot->sockets_allocated(cg));
+#ifdef CONFIG_CGROUP_KMEM
+	for (cg = sk->sk_cgrp->parent; cg; cg = cg->parent)
+		percpu_counter_inc(prot->sockets_allocated(cg));
+#endif
+}
+
+static inline int
+sk_sockets_allocated_read_positive(struct sock *sk)
+{
+	struct proto *prot = sk->sk_prot;
+	struct kmem_cgroup *cg = sk->sk_cgrp;
+
+	return percpu_counter_sum_positive(prot->sockets_allocated(cg));
+}
+
+static inline int
+kcg_sockets_allocated_sum_positive(struct proto *prot, struct kmem_cgroup *cg)
+{
+	return percpu_counter_sum_positive(prot->sockets_allocated(cg));
+}
+
+static inline long
+kcg_memory_allocated(struct proto *prot, struct kmem_cgroup *cg)
+{
+	return atomic_long_read(prot->memory_allocated(cg));
+}
+
 static inline void sock_update_kmem_cgrp(struct sock *sk)
 {
 #ifdef CONFIG_CGROUP_KMEM
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
