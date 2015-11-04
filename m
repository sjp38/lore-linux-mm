Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id D308382F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:22:40 -0500 (EST)
Received: by wijp11 with SMTP id p11so101356918wij.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:22:40 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ef7si4114524wjd.49.2015.11.04.14.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:22:39 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/8] net: tcp_memcontrol: remove bogus hierarchy pressure propagation
Date: Wed,  4 Nov 2015 17:22:10 -0500
Message-Id: <1446675734-25671-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
References: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When a cgroup currently breaches its socket memory limit, it enters
memory pressure mode for itself and its *parents*. This throttles
transmission in unrelated groups that have nothing to do with the
breached limit.

On the contrary, breaching a limit should make that group and its
*children* enter memory pressure mode. But this happens already,
albeit lazily: if a parent limit is breached, siblings will enter
memory pressure on their own once the next packet arrives for them.

So no additional hierarchy code is needed. Remove the bogus stuff.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/net/sock.h | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 59a7196..d541bed 100644
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
