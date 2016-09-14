Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56FF86B0253
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 15:52:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k12so23689246lfb.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 12:52:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m5si28185097wmi.65.2016.09.14.12.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 12:52:56 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/3] cgroup: duplicate cgroup reference when cloning sockets
Date: Wed, 14 Sep 2016 15:48:45 -0400
Message-Id: <20160914194846.11153-2-hannes@cmpxchg.org>
In-Reply-To: <20160914194846.11153-1-hannes@cmpxchg.org>
References: <20160914194846.11153-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Johannes Weiner <jweiner@fb.com>

When a socket is cloned, the associated sock_cgroup_data is duplicated
but not its reference on the cgroup. As a result, the cgroup reference
count will underflow when both sockets are destroyed later on.

Fixes: bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup")
Cc: <stable@vger.kernel.org> # 4.5+
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 kernel/cgroup.c | 6 ++++++
 net/core/sock.c | 5 ++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0c4db7908264..b0d727d26fc7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -6297,6 +6297,12 @@ void cgroup_sk_alloc(struct sock_cgroup_data *skcd)
 	if (cgroup_sk_alloc_disabled)
 		return;
 
+	/* Socket clone path */
+	if (skcd->val) {
+		cgroup_get(sock_cgroup_ptr(skcd));
+		return;
+	}
+
 	rcu_read_lock();
 
 	while (true) {
diff --git a/net/core/sock.c b/net/core/sock.c
index 51a730485649..038e660ef844 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1340,7 +1340,6 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		if (!try_module_get(prot->owner))
 			goto out_free_sec;
 		sk_tx_queue_clear(sk);
-		cgroup_sk_alloc(&sk->sk_cgrp_data);
 	}
 
 	return sk;
@@ -1400,6 +1399,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sock_net_set(sk, net);
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
+		cgroup_sk_alloc(&sk->sk_cgrp_data);
 		sock_update_classid(&sk->sk_cgrp_data);
 		sock_update_netprioidx(&sk->sk_cgrp_data);
 	}
@@ -1544,6 +1544,9 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_priority = 0;
 		newsk->sk_incoming_cpu = raw_smp_processor_id();
 		atomic64_set(&newsk->sk_cookie, 0);
+
+		cgroup_sk_alloc(&newsk->sk_cgrp_data);
+
 		/*
 		 * Before updating sk_refcnt, we must commit prior changes to memory
 		 * (Documentation/RCU/rculist_nulls.txt for details)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
