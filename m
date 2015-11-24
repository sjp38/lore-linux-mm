Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5532A6B0259
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:52:43 -0500 (EST)
Received: by wmvv187 with SMTP id v187so230372379wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:52:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f194si941154wmd.103.2015.11.24.13.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:52:42 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 03/13] net: tcp_memcontrol: remove bogus hierarchy pressure propagation
Date: Tue, 24 Nov 2015 16:51:55 -0500
Message-Id: <1448401925-22501-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When a cgroup currently breaches its socket memory limit, it enters
memory pressure mode for itself and its *ancestors*. This throttles
transmission in unrelated sibling and cousin subtrees that have
nothing to do with the breached limit.

On the contrary, breaching a limit should make that group and its
*children* enter memory pressure mode. But this happens already,
albeit lazily: if an ancestor limit is breached, siblings will enter
memory pressure on their own once the next packet arrives for them.

So no additional hierarchy code is needed. Remove the bogus stuff.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: David S. Miller <davem@davemloft.net>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/net/sock.h | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8133c71..e27a8bb 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1152,14 +1152,8 @@ static inline void sk_leave_memory_pressure(struct sock *sk)
 	if (*memory_pressure)
 		*memory_pressure = 0;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct cg_proto *cg_proto = sk->sk_cgrp;
-		struct proto *prot = sk->sk_prot;
-
-		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			cg_proto->memory_pressure = 0;
-	}
-
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		sk->sk_cgrp->memory_pressure = 0;
 }
 
 static inline void sk_enter_memory_pressure(struct sock *sk)
@@ -1167,13 +1161,8 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
 	if (!sk->sk_prot->enter_memory_pressure)
 		return;
 
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
-		struct cg_proto *cg_proto = sk->sk_cgrp;
-		struct proto *prot = sk->sk_prot;
-
-		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
-			cg_proto->memory_pressure = 1;
-	}
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		sk->sk_cgrp->memory_pressure = 1;
 
 	sk->sk_prot->enter_memory_pressure(sk);
 }
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
