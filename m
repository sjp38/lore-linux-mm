Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 88D026B016D
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 00:24:55 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 3/9] socket: initial cgroup code.
Date: Wed,  7 Sep 2011 01:23:13 -0300
Message-Id: <1315369399-3073-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1315369399-3073-1-git-send-email-glommer@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, Glauber Costa <glommer@parallels.com>, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

We aim to control the amount of kernel memory pinned at any
time by tcp sockets. To lay the foundations for this work,
this patch adds a pointer to the kmem_cgroup to the socket
structure.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/kmem_cgroup.h |   29 +++++++++++++++++++++++++++++
 include/net/sock.h          |    2 ++
 net/core/sock.c             |    5 ++---
 3 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
index 0e4a74b..77076d8 100644
--- a/include/linux/kmem_cgroup.h
+++ b/include/linux/kmem_cgroup.h
@@ -49,5 +49,34 @@ static inline struct kmem_cgroup *kcg_from_task(struct task_struct *tsk)
 	return NULL;
 }
 #endif /* CONFIG_CGROUP_KMEM */
+
+#ifdef CONFIG_INET
+#include <net/sock.h>
+static inline void sock_update_kmem_cgrp(struct sock *sk)
+{
+#ifdef CONFIG_CGROUP_KMEM
+	sk->sk_cgrp = kcg_from_task(current);
+
+	/*
+	 * We don't need to protect against anything task-related, because
+	 * we are basically stuck with the sock pointer that won't change,
+	 * even if the task that originated the socket changes cgroups.
+	 *
+	 * What we do have to guarantee, is that the chain leading us to
+	 * the top level won't change under our noses. Incrementing the
+	 * reference count via cgroup_exclude_rmdir guarantees that.
+	 */
+	cgroup_exclude_rmdir(&sk->sk_cgrp->css);
+#endif
+}
+
+static inline void sock_release_kmem_cgrp(struct sock *sk)
+{
+#ifdef CONFIG_CGROUP_KMEM
+	cgroup_release_and_wakeup_rmdir(&sk->sk_cgrp->css);
+#endif
+}
+
+#endif /* CONFIG_INET */
 #endif /* _LINUX_KMEM_CGROUP_H */
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 8e4062f..709382f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -228,6 +228,7 @@ struct sock_common {
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
   *	@sk_classid: this socket's cgroup classid
+  *	@sk_cgrp: this socket's kernel memory (kmem) cgroup 
   *	@sk_write_pending: a write to stream socket waits to start
   *	@sk_state_change: callback to indicate change in the state of the sock
   *	@sk_data_ready: callback to indicate there is data to be processed
@@ -339,6 +340,7 @@ struct sock {
 #endif
 	__u32			sk_mark;
 	u32			sk_classid;
+	struct kmem_cgroup	*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
diff --git a/net/core/sock.c b/net/core/sock.c
index 3449df8..7109864 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1139,6 +1139,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
+		sock_update_kmem_cgrp(sk);
 	}
 
 	return sk;
@@ -1170,6 +1171,7 @@ static void __sk_free(struct sock *sk)
 		put_cred(sk->sk_peer_cred);
 	put_pid(sk->sk_peer_pid);
 	put_net(sock_net(sk));
+	sock_release_kmem_cgrp(sk);
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
 
@@ -2252,9 +2254,6 @@ void sk_common_release(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_common_release);
 
-static DEFINE_RWLOCK(proto_list_lock);
-static LIST_HEAD(proto_list);
-
 #ifdef CONFIG_PROC_FS
 #define PROTO_INUSE_NR	64	/* should be enough for the first time */
 struct prot_inuse {
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
