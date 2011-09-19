Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1269000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 20:58:23 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 2/7] socket: initial cgroup code.
Date: Sun, 18 Sep 2011 21:56:40 -0300
Message-Id: <1316393805-3005-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1316393805-3005-1-git-send-email-glommer@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, Glauber Costa <glommer@parallels.com>

We aim to control the amount of kernel memory pinned at any
time by tcp sockets. To lay the foundations for this work,
this patch adds a pointer to the kmem_cgroup to the socket
structure.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/memcontrol.h |   15 +++++++++++++++
 include/net/sock.h         |    2 ++
 mm/memcontrol.c            |   33 +++++++++++++++++++++++++++++++++
 net/core/sock.c            |    3 +++
 4 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3b535db..2cb9226 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -395,5 +395,20 @@ mem_cgroup_print_bad_page(struct page *page)
 }
 #endif
 
+#ifdef CONFIG_INET
+struct sock;
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+void sock_update_memcg(struct sock *sk);
+void sock_release_memcg(struct sock *sk);
+
+#else
+static inline void sock_update_memcg(struct sock *sk)
+{
+}
+static inline void sock_release_memcg(struct sock *sk)
+{
+}
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
+#endif /* CONFIG_INET */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 8e4062f..afe1467 100644
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
+	struct mem_cgroup	*sk_cgrp;
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d32e931..0a7d335 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -345,6 +345,39 @@ struct mem_cgroup {
 	spinlock_t pcp_counter_lock;
 };
 
+/* Writing them here to avoid exposing memcg's inner layout */
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
+#ifdef CONFIG_INET
+#include <net/sock.h>
+
+void sock_update_memcg(struct sock *sk)
+{
+	/* right now a socket spends its whole life in the same cgroup */
+	BUG_ON(sk->sk_cgrp);
+
+	rcu_read_lock();
+	sk->sk_cgrp = mem_cgroup_from_task(current);
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
+	cgroup_exclude_rmdir(mem_cgroup_css(sk->sk_cgrp));
+	rcu_read_unlock();
+}
+
+void sock_release_memcg(struct sock *sk)
+{
+	cgroup_release_and_wakeup_rmdir(mem_cgroup_css(sk->sk_cgrp));
+}
+#endif /* CONFIG_INET */
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
+
 /* Stuffs for move charges at task migration. */
 /*
  * Types of charges to be moved. "move_charge_at_immitgrate" is treated as a
diff --git a/net/core/sock.c b/net/core/sock.c
index 3449df8..54ec8ac 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -125,6 +125,7 @@
 #include <net/xfrm.h>
 #include <linux/ipsec.h>
 #include <net/cls_cgroup.h>
+#include <linux/memcontrol.h>
 
 #include <linux/filter.h>
 
@@ -1139,6 +1140,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
+		sock_update_memcg(sk);
 	}
 
 	return sk;
@@ -1170,6 +1172,7 @@ static void __sk_free(struct sock *sk)
 		put_cred(sk->sk_peer_cred);
 	put_pid(sk->sk_peer_pid);
 	put_net(sock_net(sk));
+	sock_release_memcg(sk);
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
 
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
